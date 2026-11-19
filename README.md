# Overseas Infrastructure — Finance Management (Phase 1)

Phase 1 foundation scaffold for a secure finance-management web application.

## Included
- Next.js App Router + TypeScript starter structure
- Supabase browser/server client helpers
- Supabase SQL migration with core finance tables, constraints, indexes and RLS policies
- Role model: `admin` and `finance_handler`
- Append-only audit log foundation
- Environment variable template

## Important status
This is **Phase 1 foundation code**, not a completed or deployed ERP. The app requires a Supabase project, environment variables, database migration, and initial user provisioning before login or data operations can run. Finance modules and approval workflows are planned for later phases.

## Local setup
1. Copy `.env.example` to `.env.local` and fill in Supabase URL and anon key.
2. Run `npm install`.
3. Apply `supabase/migrations/0001_phase1_foundation.sql` in Supabase SQL Editor.
4. Run `npm run dev` and open `http://localhost:3000`.

## Financial integrity
- Amounts use `numeric(18,2)`.
- Actual payments/receipts are separate from plans/forecasts.
- Financial records are not physically deleted by normal app roles.
- Corrections should use reversal/replacement entries and audit events.

See project files for deployment and role setup instructions.