---
name: dev-prisma
description: Prisma ORM work - schema.prisma models and relations, migrations, Prisma Client queries. Points to Prisma's own skills (prisma-cli, prisma-client-api...) and holds the workflow and discipline that apply whichever is installed. Trigger when the user wants to add or change a model, create or apply a migration, or write or optimize Prisma queries.
---

# Prisma ORM (pointer + workflow)

**If Prisma's own skills are installed (`prisma-cli`, `prisma-client-api`, …), invoke the relevant one now** (Skill tool) for the API detail — they track each Prisma release. Either way, follow the workflow below.

Prisma publishes them at [`prisma/skills`](https://github.com/prisma/skills) (9 skills: CLI, Client API, database setup, Prisma Postgres, the v6 → v7 upgrade, driver adapters, MongoDB, Compute). The foundation's former 418-line skill drifted on every Prisma release.

```bash
git clone https://github.com/prisma/skills ~/dev/vendor-skills/prisma
git -C ~/dev/vendor-skills/prisma checkout 1123817e60d15ca0f3af91878923241dee7e3b09   # the registry pin
ln -s ~/dev/vendor-skills/prisma/prisma-cli ./.claude/skills/prisma-cli
ln -s ~/dev/vendor-skills/prisma/prisma-client-api ./.claude/skills/prisma-client-api
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Prisma — `prisma/skills`".

## Schema change workflow

1. Edit `schema.prisma`: the relation on both sides, an `@@index` on every foreign key.
2. `npx prisma migrate dev --name <change>` locally, then `npx prisma generate` — since Prisma 7, `migrate dev` no longer regenerates the client (v6 did). Commit the migration folder with the schema.
3. Read the generated SQL before committing: a rename shows up as drop + add (data loss) — split it into add column → backfill → drop old.
4. Production: apply the committed migrations from CI or the deploy step — the exact commands, and what never runs against production, are in `.claude/rules/prisma.md`.

## Discipline that holds whichever skill fires

The migration, secret and query rules live in `.claude/rules/prisma.md`, scoped to the Prisma files, so they load even when a vendor skill fires instead of this one.

- **Security**: never fetch `passwordHash` or any sensitive column without explicit need; `select` over `include` — `.claude/rules/prisma.md` and `.claude/rules/security.md`.
- **TDD with a real DB**: integration tests hit a real test database (Docker Compose pattern), never a Prisma mock — the `dev-tdd` skill.
- **Postgres interop**: with Supabase, Prisma runs against the same Postgres and RLS still applies — the `dev-supabase` skill.

Why this pointer fires instead of stepping aside: measured 2026-10-04 in a Prisma project with Prisma's skills installed, a description deferring to them left 2 of 3 sessions with no skill at all — `eval/skill-triggering/FINDINGS.md`.
