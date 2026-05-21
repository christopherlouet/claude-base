---
name: dev-supabase
description: Backend development with Supabase. Trigger when the user wants to configure auth, the database, or Supabase storage.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Supabase (pointer)

Supabase publishes the canonical agent skills at [`supabase/agent-skills`](https://github.com/supabase/agent-skills) — maintained by the Supabase team, in sync with current API (Auth, DB, Edge Functions, Realtime, Storage). The repo ships two skills that stay current with every API release; the prior foundation skill (224 lines) drifted on each Supabase version.

## Delegate to the vendor skills

```bash
# Vendor publishes via marketplace (verify on their README):
claude plugin install supabase@supabase

# Fallback — clone and symlink both skills:
git clone --depth 1 https://github.com/supabase/agent-skills ~/dev/vendor-skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase ./.claude/skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase-postgres-best-practices \
      ./.claude/skills/supabase-postgres-best-practices
```

- **`supabase`** — Auth, DB, Edge Functions, Realtime, Storage with current API patterns.
- **`supabase-postgres-best-practices`** — 30 rules across 8 categories (indexing, RLS perf, schema design, pg_* extensions).

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Supabase — `supabase/agent-skills`". Reduction rationale: [`specs/foundation-positioning-review/spec.md`](../../../specs/foundation-positioning-review/spec.md) Wave 1.

## Foundation-unique angle preserved: cross-cutting discipline

The vendor covers the Supabase API surface. The foundation enforces version-agnostic conventions that survive across releases:

- **Auth**: Supabase Auth is one option among many — cross-ref the `dev-auth` skill for framework-agnostic patterns (sessions, OAuth, magic links) before deciding on Supabase-specific flows.
- **ORM interop**: Prisma operates against the same Postgres, and Supabase RLS coexists with Prisma queries — cross-ref the `dev-prisma` skill.
- **General Postgres**: the vendor's `supabase-postgres-best-practices` skill is useful for any Postgres project, not just Supabase-managed — cross-ref the `ops-database` skill.
- **Security**: RLS on every public table; never disable it to "make a query work" — cross-ref `.claude/rules/security.md`.

## Foundation rules preserved

- YOU MUST enable Row Level Security on every public-schema table before exposing it via PostgREST. No exceptions.
- YOU MUST use the Supavisor pooler (port 6543) for serverless / edge runtimes. Direct connections (5432) exhaust limits.
- NEVER `SELECT *` in production queries — specify columns (security + perf + payload size).
- YOU MUST store monetary amounts as `INTEGER` cents, never `FLOAT` / `NUMERIC` rounded — avoids drift footgun.
- YOU MUST index every foreign key and every column in frequent WHERE clauses.
- YOU MUST use cursor-based pagination (`gt('created_at', ...)`) for large tables, never `range()` / OFFSET (slow scan).
- NEVER commit `.env` with `SUPABASE_URL` / service-role key. Always `.env.example` with placeholders.
- NEVER expose the `service_role` key client-side — it bypasses RLS. Use it only in server-side code (Edge Functions, API routes).
