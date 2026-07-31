create table public.agent_memory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  key text not null,
  value text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, key),
  check (char_length(key) between 1 and 80),
  check (char_length(value) between 1 and 1000)
);

alter table public.agent_memory enable row level security;

create policy "Users can manage own agent memory"
on public.agent_memory
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.agent_memory from anon, authenticated;
grant select, insert, update, delete on table public.agent_memory to authenticated;
