---
paths:
  - "**/supabase/**"
  - "**/*supabase*"
---

# Supabase Rules

Supabase's own skills ([`supabase/agent-skills`](https://github.com/supabase/agent-skills)) own the
API; these rules own what must hold whichever skill is loaded — they live here, not in the
`dev-supabase` pointer, because with the vendor skills installed the pointer does not fire.

## Security

- YOU MUST enable Row Level Security on every public-schema table before exposing it via PostgREST. No exceptions — never disable it to "make a query work".
- NEVER expose the `service_role` key client-side — it bypasses RLS. Use it only in server-side code (Edge Functions, API routes).
- NEVER commit `.env` with `SUPABASE_URL` / service-role key. Always `.env.example` with placeholders.
- NEVER `SELECT *` in production queries — specify columns (security + perf + payload size).

## Data and performance

- YOU MUST use the Supavisor pooler (port 6543) for serverless / edge runtimes. Direct connections (5432) exhaust limits.
- YOU MUST store monetary amounts as `INTEGER` cents, never `FLOAT` / `NUMERIC` rounded — avoids drift.
- YOU MUST index every foreign key and every column in frequent WHERE clauses.
- YOU MUST use cursor-based pagination (`gt('created_at', ...)`) for large tables, never `range()` / OFFSET (slow scan).
