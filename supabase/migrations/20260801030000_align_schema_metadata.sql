do $$
begin
  if exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.budgets'::regclass
      and conname = 'budgeting_pkey'
  ) then
    alter table public.budgets
    rename constraint budgeting_pkey to budgets_pkey;
  end if;

  if exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.budgets'::regclass
      and conname = 'budgeting_user_id_fkey'
  ) then
    alter table public.budgets
    rename constraint budgeting_user_id_fkey to budgets_user_id_fkey;
  end if;
end;
$$;

alter table public.goals
alter column target set default 0::bigint;

alter table public.profiles
alter column pay_day set default 28::smallint;

alter table public.assets replica identity full;
alter table public.expense replica identity full;
alter table public.goals replica identity full;
alter table public.notes replica identity full;

create or replace function public.rls_auto_enable()
returns event_trigger
language plpgsql
security definer
set search_path = 'pg_catalog'
as $$
declare
  command record;
begin
  for command in
    select *
    from pg_event_trigger_ddl_commands()
    where command_tag in ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      and object_type in ('table', 'partitioned table')
  loop
    if command.schema_name = 'public' then
      begin
        execute format(
          'alter table if exists %s enable row level security',
          command.object_identity
        );
      exception
        when others then
          raise log 'rls_auto_enable: failed to enable RLS on %', command.object_identity;
      end;
    end if;
  end loop;
end;
$$;

drop event trigger if exists ensure_rls;
create event trigger ensure_rls
on ddl_command_end
when tag in ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
execute function public.rls_auto_enable();

revoke all on function public.rls_auto_enable() from public, anon, authenticated;
grant execute on function public.rls_auto_enable() to service_role;
