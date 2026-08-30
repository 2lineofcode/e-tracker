set lock_timeout = '15s';
set statement_timeout = '2min';

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := pg_catalog.now();
  return new;
end;
$$;

update public.expense
set date = pg_catalog.concat(
  pg_catalog.substr(date, 1, 4), '-',
  pg_catalog.substr(date, 5, 2), '-',
  pg_catalog.substr(date, 7, 2)
)
where date ~ '^[0-9]{8}$';

alter table public.expense
drop constraint if exists expense_category_name_fkey,
drop constraint if exists expense_user_id_fkey;

update public.expense
set category_name = coalesce(
      nullif(pg_catalog.btrim(pg_catalog.split_part(category_name, '#', 1)), ''),
      'expense:unknown'
    ),
    note = coalesce(note, ''),
    detail = coalesce(detail, '');

alter table public.expense
alter column date type date using date::date,
alter column amount type bigint using amount::bigint,
alter column amount set default 0,
alter column created_at set default now(),
alter column created_at set not null,
alter column category_name set default 'expense:unknown',
alter column category_name set not null,
alter column note set default '',
alter column note set not null,
alter column user_id set not null,
alter column detail set default '',
alter column detail set not null;

alter table public.expense
add constraint expense_user_id_fkey
foreign key (user_id) references auth.users(id) on delete cascade,
add constraint expense_amount_nonnegative check (amount >= 0),
add constraint expense_category_not_blank check (pg_catalog.btrim(category_name) <> '');

alter table public.assets
alter column created_at set default now(),
alter column created_at set not null,
alter column updated_at type timestamptz using updated_at at time zone 'UTC',
alter column updated_at set default now(),
alter column updated_at set not null;

alter table public.assets
drop constraint if exists assets_amount_nonnegative,
drop constraint if exists assets_title_not_blank;

alter table public.assets
add constraint assets_amount_nonnegative check (amount >= 0),
add constraint assets_title_not_blank check (pg_catalog.btrim(title) <> '');

comment on table public.assets is 'User-owned financial assets';

alter table public.budgets
add column if not exists updated_at timestamptz not null default now();

alter table public.budgets
alter column created_at set default now(),
alter column created_at set not null;

alter table public.budgets
drop constraint if exists budgets_amount_nonnegative,
drop constraint if exists budgets_category_not_blank;

alter table public.budgets
add constraint budgets_amount_nonnegative check (amount >= 0),
add constraint budgets_category_not_blank check (pg_catalog.btrim(category_name) <> '');

create unique index if not exists budgets_user_category_key
on public.budgets (user_id, category_name);

update public.goals
set release_date = null
where release_date is not null and pg_catalog.btrim(release_date) = '';

alter table public.goals
alter column updated_at type timestamptz using updated_at at time zone 'UTC',
alter column updated_at set default now(),
alter column release_date type date using release_date::date;

alter table public.goals
drop constraint if exists goals_amount_nonnegative,
drop constraint if exists goals_target_nonnegative,
drop constraint if exists goals_title_not_blank;

alter table public.goals
add constraint goals_amount_nonnegative check (amount >= 0),
add constraint goals_target_nonnegative check (target >= 0),
add constraint goals_title_not_blank check (pg_catalog.btrim(title) <> '');

alter table public.notes
alter column created_at set default now(),
alter column created_at set not null,
alter column updated_at type timestamptz using updated_at at time zone 'UTC',
alter column updated_at set default now(),
alter column updated_at set not null;

alter table public.notes
drop constraint if exists notes_title_not_blank;

alter table public.notes
add constraint notes_title_not_blank check (pg_catalog.btrim(title) <> '');

alter table public.profiles
add column if not exists created_at timestamptz not null default now(),
add column if not exists birth_year smallint;

update public.profiles
set birth_year = case
  when age ~ '^[0-9]{4}$' then age::smallint
  when age ~ '^[0-9]{1,3}$' then (extract(year from current_date)::integer - age::integer)::smallint
  else null
end
where birth_year is null;

alter table public.profiles
alter column updated_at set default now(),
alter column updated_at set not null,
alter column income type bigint using coalesce(
  nullif(pg_catalog.regexp_replace(income, '[^0-9-]', '', 'g'), '')::bigint,
  0
),
alter column income set default 0,
alter column income set not null,
alter column balance type bigint using coalesce(
  nullif(pg_catalog.regexp_replace(balance, '[^0-9-]', '', 'g'), '')::bigint,
  0
),
alter column balance set default 0,
alter column balance set not null,
alter column eco_day type bigint using pg_catalog.round(coalesce(eco_day, 50000))::bigint,
alter column eco_day set default 50000,
alter column eco_day set not null,
alter column average_day type bigint using pg_catalog.round(coalesce(average_day, 100000))::bigint,
alter column average_day set default 100000,
alter column average_day set not null,
alter column spender_day type bigint using pg_catalog.round(coalesce(spender_day, 100000))::bigint,
alter column spender_day set default 100000,
alter column spender_day set not null,
alter column pay_day type smallint using pay_day::smallint;

alter table public.profiles
drop column if exists age,
drop column if exists website,
drop column if exists dob,
drop constraint if exists profiles_username_key,
drop constraint if exists profiles_income_nonnegative,
drop constraint if exists profiles_birth_year_valid,
drop constraint if exists profiles_thresholds_nonnegative,
drop constraint if exists profiles_pay_day_valid;

alter table public.profiles
add constraint profiles_income_nonnegative check (income >= 0),
add constraint profiles_birth_year_valid check (
  birth_year is null or birth_year between 1900 and extract(year from current_date)::smallint
),
add constraint profiles_thresholds_nonnegative check (
  eco_day >= 0 and average_day >= 0 and spender_day >= 0
),
add constraint profiles_pay_day_valid check (pay_day between 1 and 31);

create unique index if not exists profiles_username_lower_key
on public.profiles (pg_catalog.lower(username))
where username is not null;

drop policy if exists "Users can insert own error logs" on public.error_log;
drop policy if exists "Users can read own error logs" on public.error_log;

alter table public.error_log
add column if not exists user_id uuid;

update public.error_log as error
set user_id = users.id
from auth.users as users
where error.user_id is null
  and pg_catalog.lower(error.user_email) = pg_catalog.lower(users.email);

delete from public.error_log
where user_id is null;

alter table public.error_log
alter column user_id set not null,
drop column if exists user_email;

alter table public.error_log
add constraint error_log_user_id_fkey
foreign key (user_id) references auth.users(id) on delete cascade;

create policy "Users can insert own error logs"
on public.error_log
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can read own error logs"
on public.error_log
for select
to authenticated
using ((select auth.uid()) = user_id);

create table public.recurring_expenses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  note text not null,
  category_name text not null,
  amount bigint not null,
  due_day smallint not null,
  interval_months smallint not null default 1,
  start_month smallint not null default extract(month from current_date)::smallint,
  active boolean not null default true,
  last_run_date date,
  archived_at timestamptz,
  legacy_job_name text unique,
  constraint recurring_expenses_note_not_blank check (pg_catalog.btrim(note) <> ''),
  constraint recurring_expenses_category_not_blank check (pg_catalog.btrim(category_name) <> ''),
  constraint recurring_expenses_amount_positive check (amount > 0),
  constraint recurring_expenses_due_day_valid check (due_day between 1 and 31),
  constraint recurring_expenses_interval_valid check (interval_months in (1, 3, 6, 12)),
  constraint recurring_expenses_start_month_valid check (start_month between 1 and 12)
);

alter table public.recurring_expenses enable row level security;

create policy "Users can manage own recurring expenses"
on public.recurring_expenses
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create index recurring_expenses_due_idx
on public.recurring_expenses (active, due_day)
where active;

alter table public.expense
add column source_recurring_id uuid references public.recurring_expenses(id) on delete set null;

create unique index expense_recurring_date_key
on public.expense (source_recurring_id, date)
where source_recurring_id is not null;

create temporary table migration_legacy_recurring as
select
  job.jobid,
  job.jobname,
  job.schedule,
  job.command,
  pg_catalog.regexp_match(job.schedule, '^0 0 ([0-9]{1,2}) ([^ ]+) [*]$') as schedule_parts,
  pg_catalog.regexp_match(
    job.command,
    $pattern$values[[:space:]]*[(][[:space:]]*'([^']*)'[[:space:]]*,[[:space:]]*'([^']*)'[[:space:]]*,[[:space:]]*([0-9]+(?:[.][0-9]+)?)[[:space:]]*,[[:space:]]*current_date[[:space:]]*,[[:space:]]*'([0-9a-f-]{36})'[[:space:]]*[)]$pattern$,
    'i'
  ) as value_parts
from cron.job as job
where job.command ~* 'insert[[:space:]]+into[[:space:]]+(public[.])?expense';

do $$
begin
  if exists (
    select 1
    from migration_legacy_recurring
    where schedule_parts is null or value_parts is null
  ) then
    raise exception 'A legacy recurring expense could not be migrated safely';
  end if;
end;
$$;

insert into public.recurring_expenses (
  user_id,
  note,
  category_name,
  amount,
  due_day,
  interval_months,
  start_month,
  legacy_job_name
)
select
  (value_parts[4])::uuid,
  value_parts[1],
  pg_catalog.split_part(value_parts[2], '#', 1),
  pg_catalog.round((value_parts[3])::numeric)::bigint,
  (schedule_parts[1])::smallint,
  case
    when schedule_parts[2] = '*' then 1
    when pg_catalog.array_length(pg_catalog.string_to_array(schedule_parts[2], ','), 1) = 1 then 12
    else (
      pg_catalog.split_part(schedule_parts[2], ',', 2)::integer
      - pg_catalog.split_part(schedule_parts[2], ',', 1)::integer
    )::smallint
  end,
  case
    when schedule_parts[2] = '*' then extract(month from current_date)::smallint
    else pg_catalog.split_part(schedule_parts[2], ',', 1)::smallint
  end,
  jobname
from migration_legacy_recurring
where exists (
  select 1 from auth.users where id = (value_parts[4])::uuid
);

do $$
declare
  legacy_job record;
begin
  for legacy_job in
    select jobid from migration_legacy_recurring
  loop
    perform cron.unschedule(legacy_job.jobid);
  end loop;
end;
$$;

create or replace function public.process_recurring_expenses(process_date date default current_date)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  inserted_count integer;
begin
  if process_date is null then
    raise exception 'Process date is required' using errcode = '22023';
  end if;

  insert into public.expense (
    user_id,
    category_name,
    note,
    amount,
    date,
    source_recurring_id
  )
  select
    recurring.user_id,
    recurring.category_name,
    recurring.note,
    recurring.amount,
    process_date,
    recurring.id
  from public.recurring_expenses as recurring
  where recurring.active
    and recurring.archived_at is null
    and recurring.created_at::date <= process_date
    and process_date = pg_catalog.make_date(
      extract(year from process_date)::integer,
      extract(month from process_date)::integer,
      least(
        recurring.due_day::integer,
        extract(day from (pg_catalog.date_trunc('month', process_date) + interval '1 month - 1 day'))::integer
      )
    )
    and mod(
      extract(year from process_date)::integer * 12 + extract(month from process_date)::integer - recurring.start_month::integer,
      recurring.interval_months::integer
    ) = 0
    and (recurring.last_run_date is null or recurring.last_run_date < process_date)
  on conflict (source_recurring_id, date)
  where source_recurring_id is not null
  do nothing;

  get diagnostics inserted_count = row_count;

  update public.recurring_expenses as recurring
  set last_run_date = process_date,
      updated_at = pg_catalog.now()
  where recurring.active
    and recurring.archived_at is null
    and exists (
      select 1
      from public.expense as expense
      where expense.source_recurring_id = recurring.id
        and expense.date = process_date
    );

  return inserted_count;
end;
$$;

do $$
declare
  existing_job record;
begin
  for existing_job in
    select jobid from cron.job where jobname = 'expense-tracker-recurring-daily'
  loop
    perform cron.unschedule(existing_job.jobid);
  end loop;

  perform cron.schedule(
    'expense-tracker-recurring-daily',
    '5 0 * * *',
    $command$select public.process_recurring_expenses((pg_catalog.now() at time zone 'Asia/Jakarta')::date);$command$
  );
end;
$$;

create or replace function public.create_expense_cron(
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
  recurring_id uuid;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  if user_id_value is not null and user_id_value <> caller_id then
    raise exception 'User mismatch' using errcode = '42501';
  end if;
  if user_email is not null and pg_catalog.btrim(user_email) <> '' and not exists (
    select 1 from auth.users
    where id = caller_id and pg_catalog.lower(email) = pg_catalog.lower(user_email)
  ) then
    raise exception 'Email mismatch' using errcode = '42501';
  end if;
  if day_of_month !~ '^([1-9]|[12][0-9]|3[01])$'
      or repeat_months not in (1, 3, 6, 12)
      or start_month not between 1 and 12
      or amount_value is null
      or amount_value <= 0
      or amount_value <> pg_catalog.trunc(amount_value)
      or pg_catalog.btrim(coalesce(note_text, '')) = ''
      or pg_catalog.btrim(coalesce(category_text, '')) = '' then
    raise exception 'Invalid recurring expense' using errcode = '22023';
  end if;

  insert into public.recurring_expenses (
    user_id,
    note,
    category_name,
    amount,
    due_day,
    interval_months,
    start_month,
    legacy_job_name
  ) values (
    caller_id,
    pg_catalog.btrim(note_text),
    pg_catalog.btrim(category_text),
    amount_value::bigint,
    day_of_month::smallint,
    repeat_months::smallint,
    start_month::smallint,
    caller_id::text || ':' || pg_catalog.btrim(job_name)
  )
  returning id into recurring_id;

  return pg_catalog.hashtextextended(recurring_id::text, 0);
end;
$$;

create or replace function public.get_expense_cron()
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
security invoker
set search_path = ''
as $$
  select
    pg_catalog.hashtextextended(recurring.id::text, 0),
    pg_catalog.format(
      '0 0 %s %s *',
      recurring.due_day,
      case
        when recurring.interval_months = 1 then '*'
        when recurring.interval_months = 12 then recurring.start_month::text
        else (
          select pg_catalog.string_agg(month_number::text, ',' order by month_number)
          from (
            select distinct ((recurring.start_month - 1 + month_offset.value) % 12) + 1 as month_number
            from pg_catalog.generate_series(0, 11, recurring.interval_months) as month_offset(value)
          ) as months
        )
      end
    ),
    pg_catalog.format(
      'insert into public.expense (note, category_name, amount, date, user_id) values (%L, %L, %s, current_date, %L)',
      recurring.note,
      recurring.category_name,
      recurring.amount,
      recurring.user_id
    ),
    ''::text,
    0,
    ''::text,
    ''::text,
    recurring.active,
    recurring.id::text
  from public.recurring_expenses as recurring
  where recurring.user_id = auth.uid()
    and recurring.archived_at is null
  order by recurring.created_at;
$$;

create or replace function public.delete_expense_cron(job_name text)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  update public.recurring_expenses
  set active = false,
      archived_at = pg_catalog.now(),
      updated_at = pg_catalog.now()
  where user_id = auth.uid()
    and (id::text = job_name or legacy_job_name = job_name)
    and archived_at is null;

  if not found then
    raise exception 'Recurring expense not found' using errcode = 'P0002';
  end if;
end;
$$;

drop function if exists public.get_spender_day(uuid, character varying);
create function public.get_spender_day(userid uuid, periode character varying)
returns table(date character varying, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select expense.date::character varying, sum(expense.amount)::bigint
  from public.expense as expense
  join public.profiles as profile on profile.id = expense.user_id
  where userid = auth.uid()
    and expense.user_id = auth.uid()
    and expense.date >= (periode || '-01')::date
    and expense.date < (periode || '-01')::date + interval '1 month'
  group by expense.date, profile.spender_day
  having sum(expense.amount) > profile.spender_day
  order by expense.date;
$$;

drop function if exists public.sum_all_month(uuid, integer);
create function public.sum_all_month(userid uuid, periode integer)
returns table(period character varying, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    pg_catalog.to_char(expense.date, 'YYYY-MM')::character varying,
    sum(expense.amount)::bigint
  from public.expense as expense
  where userid = auth.uid()
    and expense.user_id = auth.uid()
    and expense.date >= pg_catalog.make_date(periode, 1, 1)
    and expense.date < pg_catalog.make_date(periode + 1, 1, 1)
  group by 1
  order by 1;
$$;

drop function if exists public.sum_note_times(uuid, character varying);
create function public.sum_note_times(userid uuid, periode character varying)
returns table(period character varying, note character varying, times bigint, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    pg_catalog.to_char(expense.date, 'YYYY-MM')::character varying,
    expense.note::character varying,
    count(*)::bigint,
    sum(expense.amount)::bigint
  from public.expense as expense
  where userid = auth.uid()
    and expense.user_id = auth.uid()
    and pg_catalog.to_char(expense.date, 'YYYY-MM') like periode || '%'
  group by 1, expense.note
  order by sum(expense.amount) desc;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url')
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  delete from auth.users where id = caller_id;
  if not found then
    raise exception 'Authenticated user not found' using errcode = 'P0002';
  end if;
end;
$$;

drop trigger if exists assets_set_updated_at on public.assets;
create trigger assets_set_updated_at
before update on public.assets
for each row execute function public.set_updated_at();

drop trigger if exists budgets_set_updated_at on public.budgets;
create trigger budgets_set_updated_at
before update on public.budgets
for each row execute function public.set_updated_at();

drop trigger if exists goals_set_updated_at on public.goals;
create trigger goals_set_updated_at
before update on public.goals
for each row execute function public.set_updated_at();

drop trigger if exists notes_set_updated_at on public.notes;
create trigger notes_set_updated_at
before update on public.notes
for each row execute function public.set_updated_at();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists recurring_expenses_set_updated_at on public.recurring_expenses;
create trigger recurring_expenses_set_updated_at
before update on public.recurring_expenses
for each row execute function public.set_updated_at();

drop index if exists public.idx_expense_user_id;
create index expense_user_date_idx
on public.expense (user_id, date);

create index error_log_user_created_idx
on public.error_log (user_id, created_at desc);

do $$
declare
  obsolete_function regprocedure;
begin
  for obsolete_function in
    select function_definition.oid::regprocedure
    from pg_catalog.pg_proc as function_definition
    join pg_catalog.pg_namespace as function_schema
      on function_schema.oid = function_definition.pronamespace
    where function_schema.nspname = 'public'
      and function_definition.proname in (
        'get_ihsg',
        'get_pintu',
        'javlib_bycode',
        'javlib_byid',
        'sum_by_category'
      )
  loop
    execute pg_catalog.format('drop function %s', obsolete_function);
  end loop;
end;
$$;

drop table if exists public.autocomplete cascade;
drop table if exists public.category cascade;

revoke all on table public.recurring_expenses from anon, authenticated;
grant select, insert, update on table public.recurring_expenses to authenticated;

revoke all on table public.error_log from anon, authenticated;
grant select, insert on table public.error_log to authenticated;

revoke execute on function public.process_recurring_expenses(date)
from public, anon, authenticated;

revoke execute on function public.set_updated_at()
from public, anon, authenticated;

grant execute on function public.create_expense_cron(text, text, text, text, numeric, text, uuid, integer, integer)
to authenticated;
grant execute on function public.get_expense_cron() to authenticated;
grant execute on function public.delete_expense_cron(text) to authenticated;
grant execute on function public.delete_own_account() to authenticated;
grant execute on function public.get_spender_day(uuid, character varying) to authenticated;
grant execute on function public.sum_all_month(uuid, integer) to authenticated;
grant execute on function public.sum_note_times(uuid, character varying) to authenticated;
