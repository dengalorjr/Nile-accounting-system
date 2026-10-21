-- Nile Accounting: update #3 (month-based tracking for monthly courses)
-- Run ONCE in Supabase -> SQL Editor -> New query, BEFORE uploading the new app.js. Safe to re-run.
-- (Requires migration-v2.sql to have been run before.)

alter table enrollments add column if not exists months text default '';
alter table payments    add column if not exists "periodMonth" integer;

-- Fill the month of existing monthly payments (from the period text, else from the payment date)
update payments p set "periodMonth" = coalesce(
  array_position(array['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'],
                 split_part(trim(p.period), ' ', 1)),
  extract(month from p.date)::int)
from enrollments e
where e.id = p."enrollmentId" and e."paymentType" = 'Monthly' and p."periodMonth" is null;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'payments_period_month_valid') then
    alter table payments add constraint payments_period_month_valid check ("periodMonth" is null or "periodMonth" between 1 and 12);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'enrollments_months_valid') then
    alter table enrollments add constraint enrollments_months_valid check
      (months is null or months = '' or months ~ '^(1[0-2]|[1-9])(,(1[0-2]|[1-9]))*$');
  end if;
end $$;
