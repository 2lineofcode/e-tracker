do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'agnes_memory_user_id_fkey'
      and conrelid = 'public.agent_memory'::regclass
  ) then
    alter table public.agent_memory
    rename constraint agnes_memory_user_id_fkey
    to agent_memory_user_id_fkey;
  end if;
end
$$;
