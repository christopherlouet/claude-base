# Agent DEV-PRISMA (pointer)

Configuration and usage of Prisma ORM.

## Context
$ARGUMENTS

## Delegate to the vendor toolkit

`claude-base`'s prior `dev-prisma` content (49-line checklist) is **superseded** by [`prisma/skills`](https://github.com/prisma/skills) — Prisma's own toolkit, maintained by the Prisma team in sync with v7 (ESM-only, driver adapters, `prisma.config.ts`), covers schema, migrations, the client singleton, transactions and advanced patterns at a depth and currency a hand-maintained checklist cannot match; this command wrapped a tool the vendor owns. The sibling `dev-prisma` **skill** already graduated to this pointer.

Install:

```bash
# Prisma's preferred path (verify on their README):
npx skills add prisma/skills

# Fallback — clone and copy:
git clone --depth 1 https://github.com/prisma/skills ~/dev/vendor-skills/prisma
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Prisma — `prisma/skills`". Reduction rationale: [`specs/dev-command-vendor-graduation/spec.md`](../../../specs/dev-command-vendor-graduation/spec.md).

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-database` | Migrations, optimizations |
| `/dev:dev-api` | CRUD endpoints |
| `/qa:qa-security` | Query security |

---

NEVER expose Prisma errors directly to the user; use the client singleton in dev to avoid multiple connections.
