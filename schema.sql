-- Nile Accounting Online -- Supabase schema
-- Run this once: Supabase dashboard -> SQL Editor -> New query -> paste all of this -> Run

create table if not exists users (
  id text primary key,
  username text not null unique,
  name text not null,
  role text not null,
  active boolean not null default true,
  salt text not null,
  "passwordHash" text not null,
  "mustChange" boolean not null default true,
  "createdAt" timestamptz not null default now()
);

create table if not exists students (
  id text primary key,
  name text not null,
  phone text,
  gender text,
  address text,
  notes text,
  "registrationDate" date,
  deleted boolean not null default false
);

create table if not exists trainers (
  id text primary key,
  name text not null,
  phone text,
  "courseId" text,
  "monthlySalary" numeric not null default 0,
  notes text,
  deleted boolean not null default false
);

create table if not exists courses (
  id text primary key,
  name text not null,
  description text,
  "defaultPaymentType" text default 'Monthly',
  "defaultFees" numeric default 0,
  "defaultMonthly" numeric default 0,
  "defaultInstallments" integer default 1,
  active boolean not null default true
);

create table if not exists enrollments (
  id text primary key,
  "studentId" text references students(id),
  "courseId" text references courses(id),
  "paymentType" text,
  date date,
  "totalFees" numeric default 0,
  "unitAmount" numeric default 0,
  "installmentCount" integer default 0,
  "dueDay" integer default 0,
  "startDate" date,
  notes text,
  deleted boolean not null default false
);

create table if not exists payments (
  id text primary key,
  "enrollmentId" text references enrollments(id),
  "studentId" text references students(id),
  "courseId" text references courses(id),
  sequence integer,
  amount numeric not null default 0,
  date date,
  method text,
  period text,
  notes text,
  "receiptNumber" text,
  "createdAt" timestamptz default now(),
  deleted boolean not null default false
);

create table if not exists expenses (
  id text primary key,
  date date,
  category text,
  "trainerId" text references trainers(id),
  description text,
  amount numeric not null default 0,
  method text,
  notes text,
  "createdAt" timestamptz default now(),
  deleted boolean not null default false
);

create table if not exists audit_logs (
  id text primary key,
  at timestamptz not null default now(),
  username text,
  role text,
  action text,
  type text,
  "entityId" text,
  details text
);

create table if not exists settings (
  key text primary key,
  value text
);

-- Row Level Security -------------------------------------------------------
-- The app does its own login screen inside the browser; there is no Supabase
-- Auth session to key policies off of. These policies grant full read/write
-- to anyone holding the anon (public) key, which ships inside app.js/config.js
-- and is therefore effectively public once the site is online.
-- Read the "Security notes" section of README.md before relying on this for
-- real money -- it is the known trade-off of choosing the simple-auth option.

alter table users enable row level security;
alter table students enable row level security;
alter table trainers enable row level security;
alter table courses enable row level security;
alter table enrollments enable row level security;
alter table payments enable row level security;
alter table expenses enable row level security;
alter table audit_logs enable row level security;
alter table settings enable row level security;

create policy "anon full access" on users for all using (true) with check (true);
create policy "anon full access" on students for all using (true) with check (true);
create policy "anon full access" on trainers for all using (true) with check (true);
create policy "anon full access" on courses for all using (true) with check (true);
create policy "anon full access" on enrollments for all using (true) with check (true);
create policy "anon full access" on payments for all using (true) with check (true);
create policy "anon full access" on expenses for all using (true) with check (true);
create policy "anon full access" on audit_logs for all using (true) with check (true);
create policy "anon full access" on settings for all using (true) with check (true);
