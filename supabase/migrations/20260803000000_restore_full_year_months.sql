create or replace function public.sum_all_month(userid uuid, periode integer)
returns table(period character varying, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    pg_catalog.to_char(
      pg_catalog.make_date(periode, month_number, 1),
      'YYYY-MM'
    )::character varying,
    coalesce(sum(expense.amount), 0)::bigint
  from pg_catalog.generate_series(1, 12) as month(month_number)
  left join public.expense as expense
    on expense.user_id = auth.uid()
    and expense.date >= pg_catalog.make_date(periode, month_number, 1)
    and expense.date <
      pg_catalog.make_date(periode, month_number, 1) + interval '1 month'
  where userid = auth.uid()
  group by month_number
  order by month_number;
$$;

revoke execute on function public.sum_all_month(uuid, integer)
from public, anon;
grant execute on function public.sum_all_month(uuid, integer)
to authenticated;
