begin;

select plan(21);

select has_table('public', 'recurring_expenses', 'recurring_expenses table exists');
select col_type_is('public', 'expense', 'date', 'date', 'expense date uses date');
select col_type_is('public', 'expense', 'amount', 'bigint', 'expense amount uses bigint');
select col_type_is('public', 'profiles', 'income', 'bigint', 'profile income uses bigint');
select col_type_is('public', 'profiles', 'birth_year', 'smallint', 'profile birth year uses smallint');
select col_type_is('public', 'asset_snapshots', 'amount', 'bigint', 'asset snapshots use bigint');
select col_not_null('public', 'expense', 'updated_at', 'expense tracks updates');
select col_not_null('public', 'error_log', 'user_id', 'error log owner is required');
select has_index('public', 'expense', 'expense_user_date_idx', 'expense user-date index exists');
select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.recurring_expenses'::regclass),
  'recurring_expenses has RLS enabled'
);
select is(
  (select public from storage.buckets where id = 'expense-images'),
  false,
  'expense images bucket is private'
);
select is(
  (select file_size_limit from storage.buckets where id = 'expense-images'),
  5242880::bigint,
  'expense images are limited to 5 MB'
);
select has_function('public', 'sum_own_expenses', array[]::text[], 'sum RPC exists');
select ok(
  not has_function_privilege('anon', 'public.sum_own_expenses()', 'EXECUTE'),
  'anon cannot execute sum RPC'
);
select ok(
  not has_function_privilege('anon', 'public.get_spender_day(uuid, character varying)', 'EXECUTE'),
  'anon cannot execute expense RPC'
);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) values (
  '00000000-0000-0000-0000-000000000123',
  'authenticated',
  'authenticated',
  'database-test@example.com',
  '',
  '{}',
  '{}',
  '2026-01-01',
  '2026-01-01'
);

insert into public.recurring_expenses (
  created_at,
  user_id,
  note,
  category_name,
  amount,
  due_day,
  interval_months,
  start_month
) values (
  '2026-01-01',
  '00000000-0000-0000-0000-000000000123',
  'Month-end test',
  'expense:bill:subscription',
  1000,
  31,
  1,
  1
);

select is(public.process_recurring_expenses('2026-02-28'), 2, 'backfills month-end expenses');
select is(public.process_recurring_expenses('2026-02-28'), 0, 'does not create duplicate expense');
select is(public.process_recurring_expenses('2026-04-30'), 2, 'catches up after a missed schedule');
select is(
  (select count(*) from public.expense where source_recurring_id is not null),
  4::bigint,
  'recurring catch-up stays complete and unique'
);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) values (
  '00000000-0000-0000-0000-000000000124',
  'authenticated',
  'authenticated',
  'database-test-2@example.com',
  '',
  '{}',
  '{}',
  '2026-01-01',
  '2026-01-01'
);

insert into public.expense (user_id, note, category_name, amount, date)
values
  ('00000000-0000-0000-0000-000000000123', 'RLS tenant check', 'expense:unknown', 1, '2026-03-01'),
  ('00000000-0000-0000-0000-000000000124', 'RLS tenant check', 'expense:unknown', 1, '2026-03-01');

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000123';

select is(
  (
    select count(*)
    from public.sum_all_month(
      '00000000-0000-0000-0000-000000000123',
      2026
    )
  ),
  12::bigint,
  'year summary always returns every month'
);

select is(
  (select count(*) from public.expense where note = 'RLS tenant check'),
  1::bigint,
  'expense RLS isolates tenants'
);

select * from finish();

rollback;
