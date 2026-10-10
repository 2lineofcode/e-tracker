do $$
begin
  if exists (select 1 from pg_catalog.pg_publication where pubname = 'supabase_realtime')
    and not exists (
      select 1 from pg_catalog.pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'recurring_expenses'
    ) then
    alter publication supabase_realtime add table public.recurring_expenses;
  end if;
end;
$$;

alter table public.expense replica identity full;
alter table public.recurring_expenses replica identity full;
