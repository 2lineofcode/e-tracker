-- Preserve memory for databases that ran the previous schema.
do $$
begin
  if to_regclass('public.agnes_memory') is not null
      and to_regclass('public.agent_memory') is null then
    alter table public.agnes_memory rename to agent_memory;
  end if;
end
$$;

do $$
begin
  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'agent_memory'
      and policyname = 'Users can manage own Agnes memory'
  ) then
    alter policy "Users can manage own Agnes memory"
    on public.agent_memory
    rename to "Users can manage own agent memory";
  end if;
end
$$;

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'agnes_memory_pkey'
      and conrelid = 'public.agent_memory'::regclass
  ) then
    alter table public.agent_memory
    rename constraint agnes_memory_pkey to agent_memory_pkey;
  end if;

  if exists (
    select 1
    from pg_constraint
    where conname = 'agnes_memory_user_id_key_key'
      and conrelid = 'public.agent_memory'::regclass
  ) then
    alter table public.agent_memory
    rename constraint agnes_memory_user_id_key_key
    to agent_memory_user_id_key_key;
  end if;

  if exists (
    select 1
    from pg_constraint
    where conname = 'agnes_memory_key_check'
      and conrelid = 'public.agent_memory'::regclass
  ) then
    alter table public.agent_memory
    rename constraint agnes_memory_key_check to agent_memory_key_check;
  end if;

  if exists (
    select 1
    from pg_constraint
    where conname = 'agnes_memory_value_check'
      and conrelid = 'public.agent_memory'::regclass
  ) then
    alter table public.agent_memory
    rename constraint agnes_memory_value_check to agent_memory_value_check;
  end if;
end
$$;
