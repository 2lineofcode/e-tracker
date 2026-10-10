create or replace function public.restore_own_expenses(expense_rows jsonb)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  restored_count integer;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  if expense_rows is null or pg_catalog.jsonb_typeof(expense_rows) <> 'array' then
    raise exception 'Expense rows must be an array' using errcode = '22023';
  end if;
  if exists (
    select 1 from pg_catalog.jsonb_array_elements(expense_rows) as item
    where pg_catalog.jsonb_typeof(item) <> 'object'
      or nullif(item->>'id', '') is null
      or nullif(item->>'created_at', '') is null
      or nullif(item->>'date', '') is null
      or nullif(item->>'amount', '') is null
      or nullif(pg_catalog.btrim(item->>'category_name'), '') is null
      or item->>'note' is null
      or item->>'detail' is null
      or (item->>'user_id')::uuid is distinct from caller_id
      or (nullif(item->>'image_path', '') is not null
          and pg_catalog.split_part(item->>'image_path', '/', 1) <> caller_id::text)
      or (nullif(item->>'source_recurring_id', '') is not null and not exists (
        select 1 from public.recurring_expenses as recurring
        where recurring.id = (item->>'source_recurring_id')::uuid and recurring.user_id = caller_id
      ))
  ) then
    raise exception 'Invalid expense or ownership in backup' using errcode = '22023';
  end if;

  -- Keep recurring inserts outside the restore transaction.
  lock table public.expense in share row exclusive mode;
  delete from public.expense where user_id = caller_id;
  insert into public.expense (
    id, user_id, date, category_name, note, detail, amount,
    created_at, updated_at, image_path, source_recurring_id
  )
  select
    (item->>'id')::uuid, caller_id, (item->>'date')::date,
    item->>'category_name', item->>'note', item->>'detail', (item->>'amount')::bigint,
    (item->>'created_at')::timestamptz,
    coalesce(nullif(item->>'updated_at', '')::timestamptz, (item->>'created_at')::timestamptz),
    nullif(item->>'image_path', ''), nullif(item->>'source_recurring_id', '')::uuid
  from pg_catalog.jsonb_array_elements(expense_rows) as item;
  get diagnostics restored_count = row_count;
  return restored_count;
end;
$$;

create or replace function public.delete_own_data()
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
  lock table public.expense in share row exclusive mode;
  delete from public.expense where user_id = caller_id;
  delete from public.recurring_expenses where user_id = caller_id;
  delete from public.budgets where user_id = caller_id;
  delete from public.asset_snapshots where user_id = caller_id;
  delete from public.assets where user_id = caller_id;
  delete from public.goals where user_id = caller_id;
  delete from public.notes where user_id = caller_id;
  delete from public.agent_memory where user_id = caller_id;
  delete from public.error_log where user_id = caller_id;
end;
$$;

revoke all on function public.restore_own_expenses(jsonb) from public, anon;
revoke all on function public.delete_own_data() from public, anon;
grant execute on function public.restore_own_expenses(jsonb) to authenticated;
grant execute on function public.delete_own_data() to authenticated;
