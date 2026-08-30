do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'expense' and column_name = 'image_url'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'expense' and column_name = 'image_path'
  ) then
    alter table public.expense rename column image_url to image_path;
  end if;

  if exists (
    select 1 from pg_catalog.pg_constraint
    where conrelid = 'public.expense'::regclass and conname = 'expanse_pkey'
  ) then
    alter table public.expense rename constraint expanse_pkey to expense_pkey;
  end if;
end;
$$;

alter table public.expense
add column if not exists updated_at timestamptz not null default now();

alter table public.asset_snapshots
alter column amount type bigint using round(amount)::bigint,
add column if not exists updated_at timestamptz not null default now();

alter table public.expense
drop constraint if exists expense_amount_upper_bound,
drop constraint if exists expense_text_bounds,
add constraint expense_amount_upper_bound check (amount between 0 and 1000000000000000),
add constraint expense_text_bounds check (
  length(note) <= 500
  and length(category_name) <= 120
  and length(coalesce(detail, '')) <= 10000
  and length(coalesce(image_path, '')) <= 1024
);

alter table public.assets
drop constraint if exists assets_input_bounds,
add constraint assets_input_bounds check (
  amount <= 1000000000000000 and length(title) <= 200
);

alter table public.budgets
drop constraint if exists budgets_input_bounds,
add constraint budgets_input_bounds check (
  amount <= 1000000000000000 and length(category_name) <= 120
);

alter table public.goals
drop constraint if exists goals_input_bounds,
add constraint goals_input_bounds check (
  amount <= 1000000000000000
  and target <= 1000000000000000
  and length(title) <= 200
  and length(coalesce(icon, '')) <= 100
);

alter table public.profiles
drop constraint if exists profiles_input_bounds,
add constraint profiles_input_bounds check (
  income <= 1000000000000000
  and abs(balance) <= 1000000000000000
  and length(coalesce(username, '')) <= 100
  and length(coalesce(full_name, '')) <= 200
  and length(coalesce(avatar_url, '')) <= 2048
);

alter table public.asset_snapshots
drop constraint if exists asset_snapshots_amount_upper_bound,
add constraint asset_snapshots_amount_upper_bound check (amount <= 1000000000000000);

alter table public.recurring_expenses
drop constraint if exists recurring_expenses_input_bounds,
add constraint recurring_expenses_input_bounds check (
  amount <= 1000000000000000
  and length(note) <= 500
  and length(category_name) <= 120
);

alter table public.error_log
drop constraint if exists error_log_text_bounds,
add constraint error_log_text_bounds check (
  length(coalesce(page, '')) <= 200
  and length(coalesce(action, '')) <= 200
  and length(coalesce(stack, '')) <= 20000
);

drop trigger if exists expense_set_updated_at on public.expense;
create trigger expense_set_updated_at
before update on public.expense
for each row execute function public.set_updated_at();

drop trigger if exists asset_snapshots_set_updated_at on public.asset_snapshots;
create trigger asset_snapshots_set_updated_at
before update on public.asset_snapshots
for each row execute function public.set_updated_at();

drop index if exists public.recurring_expenses_due_idx;
create index recurring_expenses_due_idx
on public.recurring_expenses (due_day)
where active and archived_at is null;

create or replace function public.sum_own_expenses()
returns bigint
language sql
stable
security invoker
set search_path = ''
as $$
  select coalesce(sum(expense.amount), 0)::bigint
  from public.expense
  where expense.user_id = auth.uid();
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
    due.due_date,
    recurring.id
  from public.recurring_expenses as recurring
  cross join lateral (
    select pg_catalog.make_date(
      extract(year from month_start)::integer,
      extract(month from month_start)::integer,
      least(
        recurring.due_day::integer,
        extract(day from (month_start + interval '1 month - 1 day'))::integer
      )
    ) as due_date
    from pg_catalog.generate_series(
      pg_catalog.date_trunc('month', recurring.created_at),
      pg_catalog.date_trunc('month', process_date::timestamp),
      interval '1 month'
    ) as month_start
    where mod(
      extract(year from month_start)::integer * 12 + extract(month from month_start)::integer - recurring.start_month::integer,
      recurring.interval_months::integer
    ) = 0
  ) as due
  where recurring.active
    and recurring.archived_at is null
    and due.due_date between recurring.created_at::date and process_date
    and (recurring.last_run_date is null or due.due_date > recurring.last_run_date)
  on conflict (source_recurring_id, date)
  where source_recurring_id is not null
  do nothing;

  get diagnostics inserted_count = row_count;

  update public.recurring_expenses as recurring
  set last_run_date = latest.date,
      updated_at = pg_catalog.now()
  from (
    select source_recurring_id, max(date) as date
    from public.expense
    where source_recurring_id is not null and date <= process_date
    group by source_recurring_id
  ) as latest
  where latest.source_recurring_id = recurring.id
    and (recurring.last_run_date is null or recurring.last_run_date < latest.date);

  return inserted_count;
end;
$$;

revoke execute on function public.get_spender_day(uuid, character varying)
from public, anon;
revoke execute on function public.sum_all_month(uuid, integer)
from public, anon;
revoke execute on function public.sum_note_times(uuid, character varying)
from public, anon;
revoke all on function public.sum_own_expenses() from public, anon;
grant execute on function public.sum_own_expenses() to authenticated;

grant delete on table public.recurring_expenses to authenticated;
grant delete on table public.error_log to authenticated;

drop policy if exists "Users can delete own error logs" on public.error_log;
create policy "Users can delete own error logs"
on public.error_log for delete to authenticated
using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png']),
  ('backup', 'backup', false, 52428800, null),
  ('expense-images', 'expense-images', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Anyone can read expense images" on storage.objects;
drop policy if exists "Users can read own expense images" on storage.objects;
create policy "Users can read own expense images"
on storage.objects for select to authenticated
using (
  bucket_id = 'expense-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Users can upload own expense images" on storage.objects;
create policy "Users can upload own expense images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'expense-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Users can update own expense images" on storage.objects;
create policy "Users can update own expense images"
on storage.objects for update to authenticated
using (
  bucket_id = 'expense-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'expense-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Users can delete own expense images" on storage.objects;
create policy "Users can delete own expense images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'expense-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

analyze public.expense;
analyze public.recurring_expenses;
