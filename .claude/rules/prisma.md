---
paths:
  - "**/schema.prisma"
  - "**/prisma/**"
  - "**/prisma.config.*"
  - "**/*prisma*"
---

# Prisma Rules

Prisma's own skills ([`prisma/skills`](https://github.com/prisma/skills)) own the API; these rules
own what must hold whichever skill is loaded — they live here, not in the `dev-prisma` pointer,
because with the vendor skills installed the pointer does not fire.

## Migrations

- NEVER use `prisma migrate dev` in production. Always `prisma migrate deploy`.
- NEVER rename a field in one migration. Two steps: add the new column → backfill → remove the old one (avoids prod downtime).
- `prisma generate` MUST run after every schema change. Add it to the CI build step.

## Security

- NEVER commit `.env` with `DATABASE_URL`. Always `.env.example` with placeholders.
- YOU MUST use `select` instead of `include` when you know the fields — never fetch `passwordHash` or another sensitive column without explicit need (security + perf).

## Performance

- YOU MUST add an index on every foreign key and on every column in frequent WHERE clauses.
- Singleton PrismaClient (HMR-safe `globalThis` pattern in dev) — avoid connection leaks.
