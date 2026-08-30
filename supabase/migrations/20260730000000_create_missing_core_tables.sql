create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  amount bigint not null default 0,
  updated_at timestamp default now()
);

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_name text not null,
  amount bigint not null default 0
);

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  amount bigint not null default 0,
  updated_at timestamp not null default now(),
  target bigint not null default 0,
  icon text,
  release_date text
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  content text not null default '',
  updated_at timestamp default now()
);

alter table public.expense
add column if not exists image_url text;

alter table public.profiles
add column if not exists income text,
add column if not exists age text,
add column if not exists balance text,
add column if not exists eco_day numeric,
add column if not exists average_day numeric,
add column if not exists spender_day numeric,
add column if not exists pay_day bigint not null default 28;
