begin;
select plan(20);

insert into auth.users (id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('00000000-0000-0000-0000-000000000321', 'authenticated', 'authenticated', 'restore-test@example.com', '', '{}', '{}', now(), now()),
  ('00000000-0000-0000-0000-000000000322', 'authenticated', 'authenticated', 'restore-other@example.com', '', '{}', '{}', now(), now());

insert into public.recurring_expenses (id, user_id, note, category_name, amount, due_day)
values
  ('00000000-0000-0000-0000-000000000331', '00000000-0000-0000-0000-000000000321', 'Own bill', 'expense:unknown', 10, 10),
  ('00000000-0000-0000-0000-000000000332', '00000000-0000-0000-0000-000000000322', 'Other bill', 'expense:unknown', 10, 10);

insert into public.expense (id, user_id, note, category_name, amount, date, image_path, source_recurring_id)
values
  ('00000000-0000-0000-0000-000000000341', '00000000-0000-0000-0000-000000000321', 'Zero note', 'notes', 0, '2026-10-10', '00000000-0000-0000-0000-000000000321/image.png', null),
  ('00000000-0000-0000-0000-000000000342', '00000000-0000-0000-0000-000000000321', 'Own bill', 'expense:unknown', 10, '2026-10-10', null, '00000000-0000-0000-0000-000000000331'),
  ('00000000-0000-0000-0000-000000000343', '00000000-0000-0000-0000-000000000322', 'Other expense', 'expense:unknown', 10, '2026-10-10', null, null);

insert into public.notes (user_id, title, content)
values ('00000000-0000-0000-0000-000000000321', 'Delete rollback test', 'Keep until the entire delete succeeds');
create function pg_temp.reject_test_note_delete()
returns trigger language plpgsql as $$
begin
  raise exception 'Forced note deletion failure';
end;
$$;
create trigger restore_test_reject_note_delete
before delete on public.notes
for each row when (old.user_id = '00000000-0000-0000-0000-000000000321')
execute function pg_temp.reject_test_note_delete();

create temporary table restore_test_backup as
select jsonb_agg(to_jsonb(expense) order by id) as rows
from public.expense where user_id = '00000000-0000-0000-0000-000000000321';
grant select on restore_test_backup to authenticated;

select ok(not has_function_privilege('anon', 'public.restore_own_expenses(jsonb)', 'EXECUTE'), 'anon cannot restore');
select ok(not has_function_privilege('anon', 'public.delete_own_data()', 'EXECUTE'), 'anon cannot delete user data');

set local role authenticated;
set local request.jwt.claim.sub = '';
select throws_ok('select public.restore_own_expenses(''[]''::jsonb)', '28000', 'Authentication required', 'restore requires identity');
select throws_ok('select public.delete_own_data()', '28000', 'Authentication required', 'delete requires identity');
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000321';

select throws_ok(
  'select public.restore_own_expenses(jsonb_set(rows, ''{1,amount}'', ''-1''::jsonb)) from restore_test_backup',
  '23514', null, 'invalid money rolls back restore'
);
select is(
  (select jsonb_agg(to_jsonb(expense) order by id) from public.expense),
  (select rows from restore_test_backup),
  'failed restore keeps original rows unchanged'
);
select throws_ok(
  'select public.restore_own_expenses(jsonb_set(rows, ''{0,user_id}'', ''"00000000-0000-0000-0000-000000000322"''::jsonb)) from restore_test_backup',
  '22023', 'Invalid expense or ownership in backup', 'cannot restore another owner'
);
select throws_ok(
  'select public.restore_own_expenses(jsonb_set(rows, ''{0,source_recurring_id}'', ''"00000000-0000-0000-0000-000000000332"''::jsonb)) from restore_test_backup',
  '22023', 'Invalid expense or ownership in backup', 'cannot link another owner recurring bill'
);
select throws_ok(
  'select public.restore_own_expenses(jsonb_set(rows, ''{0,id}'', ''"00000000-0000-0000-0000-000000000343"''::jsonb)) from restore_test_backup',
  '23505', null, 'another owner ID collision rolls back restore'
);
select is(
  (select public.restore_own_expenses(rows) from restore_test_backup), 2,
  'restore keeps both zero note and recurring expense'
);
select is(
  (select jsonb_agg(to_jsonb(expense) order by id) from public.expense),
  (select rows from restore_test_backup),
  'successful restore preserves all transaction fields'
);
select throws_ok('select public.delete_own_data()', 'P0001', 'Forced note deletion failure', 'delete failure rolls back earlier table deletions');
select is((select count(*) from public.expense), 2::bigint, 'failed delete keeps expenses');
select is((select count(*) from public.recurring_expenses), 1::bigint, 'failed delete keeps recurring bills');
select is((select count(*) from public.notes), 1::bigint, 'failed delete keeps notes');
reset role;
drop trigger restore_test_reject_note_delete on public.notes;
set local role authenticated;
select lives_ok('select public.delete_own_data()', 'deletes all own data atomically');
select is((select count(*) from public.expense), 0::bigint, 'own expenses removed');
select is((select count(*) from public.recurring_expenses), 0::bigint, 'own recurring bills removed');

reset role;
select is(
  (select count(*) from public.expense where user_id = '00000000-0000-0000-0000-000000000322'),
  1::bigint, 'other owner expense survives restore and delete'
);
select is(
  (select count(*) from public.recurring_expenses where user_id = '00000000-0000-0000-0000-000000000322'),
  1::bigint, 'other owner recurring bill survives'
);
select * from finish();
rollback;
