---
name: dev-prisma
description: Development with Prisma ORM (schema, migrations, type-safe queries, Accelerate, transactions). Trigger when the user wants to add a model, create a migration, optimize Prisma queries, or when schema.prisma is detected in the project.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Prisma ORM (pointer)

Prisma publishes the canonical agent skill at [`prisma/skills`](https://github.com/prisma/skills) — maintained by the Prisma team, in sync with v7 (ESM-only, driver adapters, `prisma.config.ts`). The vendor reference stays current with every release; the prior foundation skill (418 lines) drifted on each Prisma version bump.

## Delegate to the vendor skill

```bash
# Prisma's preferred path (verify on their README):
npx skills add prisma/skills

# Fallback — clone and copy:
git clone --depth 1 https://github.com/prisma/skills ~/dev/vendor-skills/prisma
# Skill content lives in CLAUDE.md / AGENTS.md per their convention.
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Prisma — `prisma/skills`". Reduction rationale: [`specs/foundation-positioning-review/spec.md`](../../../specs/foundation-positioning-review/spec.md) Wave 1.

## Foundation-unique angle preserved: cross-cutting discipline

The vendor covers the Prisma API surface. The foundation enforces version-agnostic conventions that survive across releases:

- **Security**: never `select: { passwordHash: true }` or any sensitive column without explicit need; default to `select` over `include` for security + perf — cross-ref `.claude/rules/security.md`.
- **TDD with a real DB**: integration tests hit a real test database (Docker Compose pattern), never a Prisma mock — cross-ref the `dev-tdd` skill.
- **Postgres interop**: if the stack uses Supabase, Prisma operates against the same Postgres — cross-ref the `dev-supabase` skill (Supabase RLS coexists with Prisma queries).

## Foundation rules preserved

- NEVER use `prisma migrate dev` in production. Always `prisma migrate deploy`.
- `prisma generate` MUST run after every schema change. Add it to the CI build step.
- Singleton PrismaClient (HMR-safe `globalThis` pattern in dev) — avoid connection leaks.
- YOU MUST add an index on every foreign key and on every column in frequent WHERE clauses.
- YOU MUST use `select` instead of `include` when you know the fields (security + perf).
- NEVER commit `.env` with `DATABASE_URL`. Always `.env.example` with placeholders.
- NEVER rename a field in one migration. Two steps: add new column → backfill → remove old column (avoids prod downtime).
