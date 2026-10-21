-- Nile Accounting: update #2 (discounts, nursing qualification, course months)
-- Run ONCE in Supabase -> SQL Editor BEFORE uploading the new app.js. Safe to re-run.

alter table courses     add column if not exists months text default '';
alter table enrollments add column if not exists "originalFees" numeric default 0;
alter table enrollments add column if not exists "discountAdmin" numeric not null default 0;
alter table enrollments add column if not exists "discountMulti" numeric not null default 0;
alter table enrollments add column if not exists "discountRelative" numeric not null default 0;
alter table enrollments add column if not exists "discountScholarship" numeric not null default 0;
alter table enrollments add column if not exists waived boolean not null default false;
alter table enrollments add column if not exists qualification text;

-- Existing enrollments had no discounts: original fees = current fees
update enrollments set "originalFees" = "totalFees" where coalesce("originalFees",0) = 0;

-- Data-integrity rules
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'enrollments_discounts_nonneg') then
    alter table enrollments add constraint enrollments_discounts_nonneg check
      ("discountAdmin" >= 0 and "discountMulti" >= 0 and "discountRelative" >= 0
       and "discountScholarship" >= 0 and coalesce("originalFees",0) >= 0);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'enrollments_qualification_valid') then
    alter table enrollments add constraint enrollments_qualification_valid check
      (qualification is null or qualification in ('أساس','ثانوي','جامعي'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'courses_months_valid') then
    alter table courses add constraint courses_months_valid check
      (months is null or months = '' or months ~ '^(1[0-2]|[1-9])(,(1[0-2]|[1-9]))*$');
  end if;
end $$;

-- Indexes for the lookups the app does constantly
create index if not exists idx_enrollments_student on enrollments("studentId");
create index if not exists idx_enrollments_course  on enrollments("courseId");
create index if not exists idx_payments_enrollment on payments("enrollmentId");
create index if not exists idx_payments_student    on payments("studentId");
create index if not exists idx_payments_course     on payments("courseId");
