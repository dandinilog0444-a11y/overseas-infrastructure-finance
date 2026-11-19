-- Overseas Infrastructure Finance Management
-- Phase 1 database foundation. Apply in Supabase SQL Editor.
create extension if not exists pgcrypto;

create type public.app_role as enum ('admin','finance_handler');
create type public.party_type as enum ('customer','supplier','both','other');
create type public.tx_status as enum ('draft','submitted','approved','rejected','posted','reversed');
create type public.pay_mode as enum ('cash','neft','rtgs','imps','upi','cheque','other');
create type public.priority_level as enum ('urgent','high','normal','low');
create type public.plan_status as enum ('upcoming','due','paid','postponed','cancelled');

create table public.companies (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 created_at timestamptz not null default now()
);
create table public.profiles (
 id uuid primary key references auth.users(id) on delete restrict,
 company_id uuid not null references public.companies(id) on delete restrict,
 full_name text not null,
 role public.app_role not null default 'finance_handler',
 is_active boolean not null default true,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.bank_accounts (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 account_name text not null,
 bank_name text,
 account_label text,
 opening_balance numeric(18,2) not null default 0 check(opening_balance >= 0),
 opening_balance_date date not null default current_date,
 is_cash_account boolean not null default false,
 is_active boolean not null default true,
 created_by uuid references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now(),
 unique(company_id,account_name)
);
create table public.parties (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 party_name text not null,
 company_name text,
 party_type public.party_type not null default 'other',
 contact_number text,
 email text,
 address text,
 tax_identifier text,
 notes text,
 is_active boolean not null default true,
 created_by uuid references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now()
);
create index parties_company_name_idx on public.parties(company_id,party_name);

create table public.payments (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 voucher_number text not null,
 payment_date date not null,
 party_id uuid references public.parties(id) on delete restrict,
 party_name_snapshot text not null,
 category text not null,
 amount numeric(18,2) not null check(amount > 0),
 payment_mode public.pay_mode not null,
 bank_account_id uuid not null references public.bank_accounts(id) on delete restrict,
 reference_number text,
 purpose text,
 due_date date,
 status public.tx_status not null default 'draft',
 entered_by uuid not null references public.profiles(id) on delete restrict,
 approved_by uuid references public.profiles(id) on delete restrict,
 approved_at timestamptz,
 posted_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(company_id,voucher_number)
);
create index payments_company_date_idx on public.payments(company_id,payment_date);
create table public.receipts (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 voucher_number text not null,
 receipt_date date not null,
 party_id uuid references public.parties(id) on delete restrict,
 received_from_snapshot text not null,
 amount numeric(18,2) not null check(amount > 0),
 receipt_mode public.pay_mode not null,
 bank_account_id uuid not null references public.bank_accounts(id) on delete restrict,
 reference_number text,
 purpose text,
 invoice_number text,
 status public.tx_status not null default 'draft',
 entered_by uuid not null references public.profiles(id) on delete restrict,
 approved_by uuid references public.profiles(id) on delete restrict,
 approved_at timestamptz,
 posted_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(company_id,voucher_number)
);
create index receipts_company_date_idx on public.receipts(company_id,receipt_date);

create table public.invoices (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 party_id uuid not null references public.parties(id) on delete restrict,
 invoice_number text not null,
 invoice_date date not null,
 due_date date,
 invoice_amount numeric(18,2) not null check(invoice_amount > 0),
 description text,
 created_by uuid not null references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now(),
 unique(company_id,party_id,invoice_number)
);
create table public.bills (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 party_id uuid not null references public.parties(id) on delete restrict,
 bill_number text not null,
 bill_date date not null,
 due_date date,
 bill_amount numeric(18,2) not null check(bill_amount > 0),
 priority public.priority_level not null default 'normal',
 description text,
 created_by uuid not null references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now(),
 unique(company_id,party_id,bill_number)
);
create table public.invoice_receipt_allocations (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 invoice_id uuid not null references public.invoices(id) on delete restrict,
 receipt_id uuid not null references public.receipts(id) on delete restrict,
 allocated_amount numeric(18,2) not null check(allocated_amount > 0),
 created_at timestamptz not null default now(),
 unique(invoice_id,receipt_id)
);
create table public.bill_payment_allocations (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 bill_id uuid not null references public.bills(id) on delete restrict,
 payment_id uuid not null references public.payments(id) on delete restrict,
 allocated_amount numeric(18,2) not null check(allocated_amount > 0),
 created_at timestamptz not null default now(),
 unique(bill_id,payment_id)
);
create table public.payment_plans (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 payment_name text not null,
 party_id uuid references public.parties(id) on delete restrict,
 party_name_snapshot text,
 amount_required numeric(18,2) not null check(amount_required > 0),
 expected_payment_date date not null,
 category text not null,
 priority public.priority_level not null default 'normal',
 is_recurring boolean not null default false,
 frequency text check(frequency in ('weekly','monthly','quarterly','yearly') or frequency is null),
 status public.plan_status not null default 'upcoming',
 remarks text,
 created_by uuid not null references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.receipt_forecasts (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 party_id uuid references public.parties(id) on delete restrict,
 customer_name text not null,
 expected_amount numeric(18,2) not null check(expected_amount > 0),
 expected_receipt_date date not null,
 invoice_number text,
 description text,
 collection_status text not null default 'expected',
 probability_percent integer check(probability_percent between 0 and 100),
 remarks text,
 created_by uuid not null references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now()
);
create table public.approval_events (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 record_type text not null check(record_type in ('payment','receipt','payment_plan')),
 record_id uuid not null,
 action text not null check(action in ('submitted','approved','rejected','verified','reopened')),
 action_by uuid not null references public.profiles(id) on delete restrict,
 action_at timestamptz not null default now(),
 comments text
);
create table public.attachments (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 parent_type text not null,
 parent_id uuid not null,
 storage_path text not null,
 original_filename text not null,
 mime_type text,
 file_size_bytes bigint check(file_size_bytes >= 0),
 uploaded_by uuid not null references public.profiles(id) on delete restrict,
 created_at timestamptz not null default now()
);
create table public.audit_logs (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete restrict,
 actor_id uuid references public.profiles(id) on delete restrict,
 action text not null,
 entity_type text not null,
 entity_id uuid,
 before_data jsonb,
 after_data jsonb,
 occurred_at timestamptz not null default now(),
 request_id text
);
create index audit_logs_company_time_idx on public.audit_logs(company_id,occurred_at desc);

create or replace function public.current_company_id()
returns uuid language sql stable security definer set search_path=public
as $$ select company_id from public.profiles where id=auth.uid() and is_active=true $$;
create or replace function public.current_app_role()
returns public.app_role language sql stable security definer set search_path=public
as $$ select role from public.profiles where id=auth.uid() and is_active=true $$;
create or replace function public.is_company_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select coalesce(public.current_app_role()='admin',false) $$;

create or replace function public.block_financial_delete()
returns trigger language plpgsql as $$
begin
 raise exception 'Financial records cannot be permanently deleted. Use a reversal or cancellation workflow.';
end; $$;
create trigger no_delete_payments before delete on public.payments for each row execute function public.block_financial_delete();
create trigger no_delete_receipts before delete on public.receipts for each row execute function public.block_financial_delete();
create trigger no_delete_invoices before delete on public.invoices for each row execute function public.block_financial_delete();
create trigger no_delete_bills before delete on public.bills for each row execute function public.block_financial_delete();
create trigger no_delete_audit_logs before delete on public.audit_logs for each row execute function public.block_financial_delete();

alter table public.companies enable row level security;
create policy companies_select_own on public.companies for select to authenticated using(id=public.current_company_id());
do $$ declare t text; begin
 foreach t in array array['profiles','bank_accounts','parties','payments','receipts','invoices','bills','invoice_receipt_allocations','bill_payment_allocations','payment_plans','receipt_forecasts','approval_events','attachments','audit_logs']
 loop execute format('alter table public.%I enable row level security',t); end loop;
end $$;

create policy profiles_select_company on public.profiles for select to authenticated using(company_id=public.current_company_id());
create policy profiles_admin_update on public.profiles for update to authenticated
 using(company_id=public.current_company_id() and public.is_company_admin())
 with check(company_id=public.current_company_id() and public.is_company_admin());

create policy banks_select on public.bank_accounts for select to authenticated using(company_id=public.current_company_id());
create policy banks_insert on public.bank_accounts for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy banks_update_admin on public.bank_accounts for update to authenticated using(company_id=public.current_company_id() and public.is_company_admin()) with check(company_id=public.current_company_id());

create policy parties_select on public.parties for select to authenticated using(company_id=public.current_company_id());
create policy parties_insert on public.parties for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy parties_update on public.parties for update to authenticated using(company_id=public.current_company_id()) with check(company_id=public.current_company_id());

create policy payments_select on public.payments for select to authenticated using(company_id=public.current_company_id());
create policy payments_insert on public.payments for insert to authenticated with check(company_id=public.current_company_id() and entered_by=auth.uid() and status in ('draft','submitted'));
create policy payments_update_draft_or_admin on public.payments for update to authenticated
 using(company_id=public.current_company_id() and (status in ('draft','submitted') or public.is_company_admin()))
 with check(company_id=public.current_company_id());
create policy receipts_select on public.receipts for select to authenticated using(company_id=public.current_company_id());
create policy receipts_insert on public.receipts for insert to authenticated with check(company_id=public.current_company_id() and entered_by=auth.uid() and status in ('draft','submitted'));
create policy receipts_update_draft_or_admin on public.receipts for update to authenticated
 using(company_id=public.current_company_id() and (status in ('draft','submitted') or public.is_company_admin()))
 with check(company_id=public.current_company_id());

create policy invoices_select on public.invoices for select to authenticated using(company_id=public.current_company_id());
create policy invoices_insert on public.invoices for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy invoices_update_admin on public.invoices for update to authenticated using(company_id=public.current_company_id() and public.is_company_admin()) with check(company_id=public.current_company_id());
create policy bills_select on public.bills for select to authenticated using(company_id=public.current_company_id());
create policy bills_insert on public.bills for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy bills_update_admin on public.bills for update to authenticated using(company_id=public.current_company_id() and public.is_company_admin()) with check(company_id=public.current_company_id());

create policy invoice_alloc_select on public.invoice_receipt_allocations for select to authenticated using(company_id=public.current_company_id());
create policy invoice_alloc_insert on public.invoice_receipt_allocations for insert to authenticated with check(company_id=public.current_company_id());
create policy bill_alloc_select on public.bill_payment_allocations for select to authenticated using(company_id=public.current_company_id());
create policy bill_alloc_insert on public.bill_payment_allocations for insert to authenticated with check(company_id=public.current_company_id());

create policy payment_plans_select on public.payment_plans for select to authenticated using(company_id=public.current_company_id());
create policy payment_plans_insert on public.payment_plans for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy payment_plans_update on public.payment_plans for update to authenticated using(company_id=public.current_company_id()) with check(company_id=public.current_company_id());
create policy forecasts_select on public.receipt_forecasts for select to authenticated using(company_id=public.current_company_id());
create policy forecasts_insert on public.receipt_forecasts for insert to authenticated with check(company_id=public.current_company_id() and created_by=auth.uid());
create policy forecasts_update on public.receipt_forecasts for update to authenticated using(company_id=public.current_company_id()) with check(company_id=public.current_company_id());

create policy approvals_select on public.approval_events for select to authenticated using(company_id=public.current_company_id());
create policy approvals_insert on public.approval_events for insert to authenticated with check(company_id=public.current_company_id() and action_by=auth.uid());
create policy attachments_select on public.attachments for select to authenticated using(company_id=public.current_company_id());
create policy attachments_insert on public.attachments for insert to authenticated with check(company_id=public.current_company_id() and uploaded_by=auth.uid());
create policy audit_select_admin on public.audit_logs for select to authenticated using(company_id=public.current_company_id() and public.is_company_admin());
create policy audit_insert_actor on public.audit_logs for insert to authenticated with check(company_id=public.current_company_id() and actor_id=auth.uid());

-- Company name only; do not seed fictional balances, parties or transactions.
insert into public.companies(name) values('Overseas Infrastructure');
