---
name: dev-prisma
description: Pointer to Prisma's own agent skills (prisma-cli, prisma-client-api...) and how to install them. Use for Prisma ORM work (schema, migrations, queries, schema.prisma) only when no prisma-* skill is installed; when one is, use it instead.
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

- **Security**: never fetch `passwordHash` or any sensitive column without explicit need; `select` over `include` — `.claude/rules/prisma.md` (below) and `.claude/rules/security.md`.
- **TDD with a real DB**: integration tests hit a real test database (Docker Compose pattern), never a Prisma mock — cross-ref the `dev-tdd` skill.
- **Postgres interop**: if the stack uses Supabase, Prisma operates against the same Postgres — cross-ref the `dev-supabase` skill (Supabase RLS coexists with Prisma queries).

## Foundation rules: `.claude/rules/prisma.md`

The migration, secret and query rules this pointer used to carry live in [`.claude/rules/prisma.md`](../../rules/prisma.md), scoped to the Prisma files. Installed together, only one of the two skills fires (measured 2026-10-03: Supabase's own skill alone 3/3, Prisma's pointer alone 3/3), so rules kept in a skill reach the session only when that skill wins — a rule loaded by the files holds whichever skill fires.
