create policy "Users can read own error logs"
on public.error_log
for select
to authenticated
using (
  pg_catalog.lower(user_email) = pg_catalog.lower(
    (select auth.jwt() ->> 'email')
  )
);

grant select on table public.error_log to authenticated;
