create table public.asset_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  snapshot_date date not null default date_trunc('month', now())::date,
  amount numeric not null default 0 check (amount >= 0),
  created_at timestamptz not null default now(),
  unique (user_id, snapshot_date)
);

alter table public.asset_snapshots enable row level security;

create policy "Users can manage own asset snapshots"
on public.asset_snapshots
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.asset_snapshots from anon, authenticated;
grant select, insert, update, delete on table public.asset_snapshots to authenticated;
