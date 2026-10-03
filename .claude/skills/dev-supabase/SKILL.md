---
name: dev-supabase
description: Backend development with Supabase. Trigger when the user wants to configure auth, the database, or Supabase storage.
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
- **Security**: RLS on every public table, `service_role` key server-side only — `.claude/rules/supabase.md` (below) and `.claude/rules/security.md`.

## Foundation rules: `.claude/rules/supabase.md`

The RLS, `service_role`, secret and query rules this pointer used to carry live in [`.claude/rules/supabase.md`](../../rules/supabase.md), scoped to the Supabase files. Installed next to the vendor's skills, only one side fires (measured 2026-10-03: Supabase's own skill alone 3/3; Prisma's pointer used to win 3/3 until its description stepped aside, now `prisma-cli` fires 3/3), so a rule kept in a skill reaches the session only when that skill wins — a rule loaded by the files holds whichever skill fires.
