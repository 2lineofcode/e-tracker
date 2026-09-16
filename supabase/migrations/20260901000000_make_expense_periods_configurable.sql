create or replace function public.expense_period_start(value date, start_day integer)
returns date
language sql
immutable
strict
set search_path = ''
as $$
  with month_starts as (
    select
      pg_catalog.date_trunc('month', value)::date as current_month,
      (pg_catalog.date_trunc('month', value) - interval '1 month')::date as previous_month
  ), boundaries as (
    select
      pg_catalog.make_date(
        extract(year from current_month)::integer,
        extract(month from current_month)::integer,
        least(
          greatest(start_day, 1),
          extract(day from current_month + interval '1 month - 1 day')::integer
        )
      ) as current_start,
      pg_catalog.make_date(
        extract(year from previous_month)::integer,
        extract(month from previous_month)::integer,
        least(
          greatest(start_day, 1),
          extract(day from previous_month + interval '1 month - 1 day')::integer
        )
      ) as previous_start
    from month_starts
  )
  select case when value >= current_start then current_start else previous_start end
  from boundaries;
$$;

drop function if exists public.get_spender_day(uuid, character varying);
create function public.get_spender_day(userid uuid, start_date date, end_date date)
returns table(date character varying, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select expense.date::character varying, pg_catalog.sum(expense.amount)::bigint
  from public.expense as expense
  join public.profiles as profile on profile.id = expense.user_id
  where userid = auth.uid()
    and expense.user_id = auth.uid()
    and expense.date >= start_date
    and expense.date < end_date
  group by expense.date, profile.spender_day
  having pg_catalog.sum(expense.amount) > profile.spender_day
  order by expense.date;
$$;

drop function if exists public.sum_all_month(uuid, integer);
create function public.sum_all_month(userid uuid, periode integer, start_day integer)
returns table(period character varying, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    pg_catalog.to_char(label_date, 'YYYY-MM')::character varying,
    coalesce(pg_catalog.sum(expense.amount), 0)::bigint
  from pg_catalog.generate_series(1, 12) as month(month_number)
  cross join lateral (
    select pg_catalog.make_date(periode, month_number, 1) as label_date
  ) as label
  left join public.expense as expense
    on expense.user_id = auth.uid()
    and expense.date >= public.expense_period_start(label_date, start_day)
    and expense.date < public.expense_period_start(
      (label_date + interval '1 month')::date,
      start_day
    )
  where userid = auth.uid()
  group by month_number, label_date
  order by month_number;
$$;

drop function if exists public.sum_note_times(uuid, character varying);
create function public.sum_note_times(
  userid uuid,
  start_date date,
  end_date date,
  start_day integer
)
returns table(period character varying, note character varying, times bigint, total bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    pg_catalog.to_char(
      case
        when start_day <= 1 then expense.date
        when public.expense_period_start(expense.date, start_day) >=
          pg_catalog.date_trunc('month', expense.date)::date
          then (expense.date + interval '1 month')::date
        else expense.date
      end,
      'YYYY-MM'
    )::character varying,
    expense.note::character varying,
    pg_catalog.count(*)::bigint,
    pg_catalog.sum(expense.amount)::bigint
  from public.expense as expense
  where userid = auth.uid()
    and expense.user_id = auth.uid()
    and expense.date >= start_date
    and expense.date < end_date
  group by 1, expense.note
  order by pg_catalog.sum(expense.amount) desc;
$$;

revoke execute on function public.expense_period_start(date, integer) from public, anon;
revoke execute on function public.get_spender_day(uuid, date, date) from public, anon;
revoke execute on function public.sum_all_month(uuid, integer, integer) from public, anon;
revoke execute on function public.sum_note_times(uuid, date, date, integer) from public, anon;

grant execute on function public.expense_period_start(date, integer) to authenticated;
grant execute on function public.get_spender_day(uuid, date, date) to authenticated;
grant execute on function public.sum_all_month(uuid, integer, integer) to authenticated;
grant execute on function public.sum_note_times(uuid, date, date, integer) to authenticated;
