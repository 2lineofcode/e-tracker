do $$
declare
  function_signature regprocedure;
begin
  for function_signature in
    select function_definition.oid::regprocedure
    from pg_catalog.pg_proc as function_definition
    join pg_catalog.pg_namespace as function_schema
      on function_schema.oid = function_definition.pronamespace
    where function_schema.nspname = 'public'
      and function_definition.proname in (
        'create_expense_cron',
        'delete_expense_cron',
        'get_expense_cron',
        'delete_own_account'
      )
  loop
    execute pg_catalog.format('drop function %s', function_signature);
  end loop;
end;
$$;

create function public.create_expense_cron(
  job_name text,
  day_of_month text,
  note_text text,
  category_text text,
  amount_value numeric,
  user_email text,
  user_id_value uuid,
  repeat_months integer default 1,
  start_month integer default 1
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  caller_email text;
  parsed_day integer;
  month_field text;
  cron_schedule text;
  cron_command text;
  owned_job_name text;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(caller_id::text, 0)
  );

  select email
  into caller_email
  from auth.users
  where id = caller_id;
  if not found then
    raise exception 'Authenticated user not found' using errcode = '28000';
  end if;

  if job_name is null or pg_catalog.btrim(job_name) = '' then
    raise exception 'Job name is required' using errcode = '22023';
  end if;
  if day_of_month is null
      or day_of_month !~ '^(?:[1-9]|[12][0-9]|3[01])$' then
    raise exception 'Day must be between 1 and 31' using errcode = '22023';
  end if;
  if note_text is null
      or category_text is null
      or pg_catalog.btrim(note_text) = ''
      or pg_catalog.btrim(category_text) = '' then
    raise exception 'Note and category are required' using errcode = '22023';
  end if;
  if pg_catalog.char_length(job_name) > 100
      or pg_catalog.char_length(note_text) > 200
      or pg_catalog.char_length(category_text) > 120 then
    raise exception 'Recurring expense input is too long' using errcode = '22023';
  end if;
  if amount_value is null
      or amount_value <= 0
      or amount_value > 1000000000000000
      or amount_value = 'NaN'::numeric then
    raise exception 'Amount is outside the allowed range' using errcode = '22023';
  end if;
  if repeat_months is null or repeat_months not in (1, 3, 6, 12) then
    raise exception 'Invalid repeat interval' using errcode = '22023';
  end if;
  if start_month is null or start_month not between 1 and 12 then
    raise exception 'Invalid start month' using errcode = '22023';
  end if;

  parsed_day := day_of_month::integer;
  if repeat_months = 1 then
    month_field := '*';
  else
    select pg_catalog.string_agg(month_number::text, ',' order by month_number)
    into month_field
    from (
      select distinct ((start_month - 1 + month_offset) % 12) + 1 as month_number
      from pg_catalog.generate_series(0, 11, repeat_months) as month_offset
    ) as allowed_months;
  end if;

  cron_schedule := pg_catalog.format('0 0 %s %s *', parsed_day, month_field);
  cron_command := pg_catalog.format(
    'insert into public.expense (note, category_name, amount, date, user_id) values (%L, %L, %s, current_date, %L)',
    pg_catalog.btrim(note_text),
    pg_catalog.btrim(category_text) || '#' || coalesce(caller_email, ''),
    amount_value,
    caller_id
  );
  owned_job_name := caller_id::text || ':' || pg_catalog.btrim(job_name);
  if (
    select pg_catalog.count(*)
    from cron.job as job
    where job.jobname <> owned_job_name
      and (
        job.jobname like caller_id::text || ':%'
        or job.command ~ pg_catalog.format(
          '[,][[:space:]]*%L[)][[:space:]]*;?[[:space:]]*$',
          caller_id::text
        )
      )
  ) >= 50 then
    raise exception 'Recurring expense limit reached' using errcode = '54000';
  end if;

  -- Identity comes from JWT; legacy identity parameters are intentionally ignored.
  return cron.schedule(owned_job_name, cron_schedule, cron_command);
end;
$$;

create function public.get_expense_cron()
returns table (
  jobid bigint,
  schedule text,
  command text,
  nodename text,
  nodeport integer,
  database text,
  username text,
  active boolean,
  jobname text
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    job.jobid,
    job.schedule,
    job.command,
    ''::text as nodename,
    0::integer as nodeport,
    ''::text as database,
    ''::text as username,
    job.active,
    job.jobname
  from cron.job as job
  where exists (
      select 1
      from auth.users
      where id = auth.uid()
    )
    and (
      job.jobname like auth.uid()::text || ':%'
      or job.command ~ pg_catalog.format(
        '[,][[:space:]]*%L[)][[:space:]]*;?[[:space:]]*$',
        auth.uid()::text
      )
    )
  order by job.jobid;
$$;

create function public.delete_expense_cron(job_name text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  owned_job_id bigint;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(caller_id::text, 0)
  );
  if not exists (
    select 1
    from auth.users
    where id = caller_id
  ) then
    raise exception 'Authenticated user not found' using errcode = '28000';
  end if;

  select job.jobid
  into owned_job_id
  from cron.job as job
  where job.jobname = delete_expense_cron.job_name
    and (
      job.jobname like caller_id::text || ':%'
      or job.command ~ pg_catalog.format(
        '[,][[:space:]]*%L[)][[:space:]]*;?[[:space:]]*$',
        caller_id::text
      )
    )
  limit 1;

  if owned_job_id is null then
    raise exception 'Recurring expense not found' using errcode = '42501';
  end if;

  perform cron.unschedule(owned_job_id);
end;
$$;

create function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  caller_email text;
  owned_job record;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(caller_id::text, 0)
  );
  select email
  into caller_email
  from auth.users
  where id = caller_id;
  if not found then
    raise exception 'Authenticated user not found' using errcode = '28000';
  end if;

  for owned_job in
    select job.jobid
    from cron.job as job
    where job.jobname like caller_id::text || ':%'
      or job.command ~ pg_catalog.format(
        '[,][[:space:]]*%L[)][[:space:]]*;?[[:space:]]*$',
        caller_id::text
      )
  loop
    perform cron.unschedule(owned_job.jobid);
  end loop;

  delete from public.expense where user_id = caller_id;
  if pg_catalog.to_regclass('public.autocomplete') is not null then
    execute 'delete from public.autocomplete where user_id = $1'
    using caller_id;
  end if;
  if pg_catalog.to_regclass('public.category') is not null then
    execute 'delete from public.category where user_id = $1'
    using caller_id;
  end if;
  delete from public.budgets where user_id = caller_id;
  delete from public.assets where user_id = caller_id;
  delete from public.goals where user_id = caller_id;
  delete from public.notes where user_id = caller_id;
  delete from public.error_log where user_email = caller_email;
  delete from public.profiles where id = caller_id;
  delete from auth.users where id = caller_id;
end;
$$;

alter table public.assets enable row level security;
alter table public.budgets enable row level security;
alter table public.error_log enable row level security;
alter table public.expense enable row level security;
alter table public.goals enable row level security;
alter table public.notes enable row level security;
alter table public.profiles enable row level security;

drop policy if exists "Enable crud for authenticated users only" on public.assets;
drop policy if exists "Enable crud for authenticated users only" on public.budgets;
drop policy if exists "Enable crud for authenticated users only" on public.error_log;
drop policy if exists "Enable crud for authenticated users only" on public.expense;
drop policy if exists "Enable crud for authenticated users only" on public.goals;
drop policy if exists "Enable crud for authenticated users only" on public.notes;
drop policy if exists "Public profiles are viewable by everyone." on public.profiles;
drop policy if exists "Users can insert their own profile." on public.profiles;
drop policy if exists "Users can update own profile." on public.profiles;
drop policy if exists "anon_insert_expense" on public.expense;
drop policy if exists "anon_select_expense" on public.expense;

create policy "Users can manage own assets"
on public.assets
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can manage own budgets"
on public.budgets
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can insert own error logs"
on public.error_log
for insert
to authenticated
with check (
  pg_catalog.lower(user_email) = pg_catalog.lower(
    (select auth.jwt() ->> 'email')
  )
);

create policy "Users can manage own expenses"
on public.expense
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can manage own goals"
on public.goals
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can manage own notes"
on public.notes
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can manage own profile"
on public.profiles
for all
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

revoke all on table public.assets from anon, authenticated;
revoke all on table public.budgets from anon, authenticated;
revoke all on table public.error_log from anon, authenticated;
revoke all on table public.expense from anon, authenticated;
revoke all on table public.goals from anon, authenticated;
revoke all on table public.notes from anon, authenticated;
revoke all on table public.profiles from anon, authenticated;

grant select, insert, update, delete on table public.assets to authenticated;
grant select, insert, update, delete on table public.budgets to authenticated;
grant insert on table public.error_log to authenticated;
grant select, insert, update, delete on table public.expense to authenticated;
grant select, insert, update, delete on table public.goals to authenticated;
grant select, insert, update, delete on table public.notes to authenticated;
grant select, insert, update, delete on table public.profiles to authenticated;

do $$
declare
  realtime_table text;
begin
  if exists (
    select 1
    from pg_catalog.pg_publication
    where pubname = 'supabase_realtime'
  ) then
    foreach realtime_table in array array[
      'assets',
      'expense',
      'goals',
      'notes'
    ]
    loop
      if not exists (
        select 1
        from pg_catalog.pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = realtime_table
      ) then
        execute pg_catalog.format(
          'alter publication supabase_realtime add table public.%I',
          realtime_table
        );
      end if;
    end loop;
  end if;
end;
$$;

create or replace function public.truncate_error_log()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.error_log
  where created_at < pg_catalog.now() - interval '3 months';
  return new;
end;
$$;

drop trigger if exists truncate_error_log_trigger on public.error_log;
create trigger truncate_error_log_trigger
after insert on public.error_log
for each statement
execute function public.truncate_error_log();

alter function public.handle_new_user() set search_path = '';

drop policy if exists "User can ADD avatar" on storage.objects;
drop policy if exists "User can READ avatar" on storage.objects;
drop policy if exists "User can UPDATE avatar" on storage.objects;
drop policy if exists "User can ADD backup" on storage.objects;
drop policy if exists "User can READ backup" on storage.objects;
drop policy if exists "User can UPDATE backup" on storage.objects;
drop policy if exists "User can DELETE backup" on storage.objects;

create policy "Users can add own avatar"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can read own avatar"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'avatars'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can update own avatar"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
)
with check (
  bucket_id = 'avatars'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can delete own avatar"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can add own backup"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'backup'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can read own backup"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'backup'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can update own backup"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'backup'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
)
with check (
  bucket_id = 'backup'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

create policy "Users can delete own backup"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'backup'
  and coalesce(owner_id, owner::text) = (select auth.uid())::text
);

revoke execute on all functions in schema public
from public, anon, authenticated;

grant execute on function public.create_expense_cron(text, text, text, text, numeric, text, uuid, integer, integer) to authenticated;
grant execute on function public.get_expense_cron() to authenticated;
grant execute on function public.delete_expense_cron(text) to authenticated;
grant execute on function public.delete_own_account() to authenticated;
grant execute on function public.get_spender_day(uuid, character varying) to authenticated;
grant execute on function public.sum_all_month(uuid, integer) to authenticated;
grant execute on function public.sum_note_times(uuid, character varying) to authenticated;

alter default privileges for role postgres in schema public
revoke all on tables from anon;
alter default privileges for role postgres in schema public
revoke all on sequences from anon;
alter default privileges for role postgres in schema public
revoke execute on functions from public, anon, authenticated;
