---
name: dev-prisma
description: Pointer to Prisma's own agent skills (prisma-cli, prisma-client-api...) and how to install them, plus the schema-change workflow. Use for Prisma ORM work (schema, migrations, queries, schema.prisma) only when no prisma-* skill is installed; when one is, use it instead.
---

# Prisma ORM (pointer + workflow)

Prisma's own skills (`prisma-cli`, `prisma-client-api`, …) track each Prisma release: install them. This pointer adds the workflow below.

Prisma publishes them at [`prisma/skills`](https://github.com/prisma/skills) (9 skills: CLI, Client API, database setup, Prisma Postgres, the v6 → v7 upgrade, driver adapters, MongoDB, Compute). The foundation's former 418-line skill drifted on every Prisma release.

```bash
git clone https://github.com/prisma/skills ~/dev/vendor-skills/prisma
git -C ~/dev/vendor-skills/prisma checkout 1123817e60d15ca0f3af91878923241dee7e3b09   # the registry pin
ln -s ~/dev/vendor-skills/prisma/prisma-cli ./.claude/skills/prisma-cli
ln -s ~/dev/vendor-skills/prisma/prisma-client-api ./.claude/skills/prisma-client-api
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Prisma — `prisma/skills`".

## Schema change workflow

1. Edit `schema.prisma`: the relation on both sides; indexes per `.claude/rules/prisma.md`.
2. `npx prisma migrate dev --create-only --name <change>` — writes the migration without applying it.
3. Read the generated SQL: a rename shows up as drop + add (data loss) — split it as `.claude/rules/prisma.md` says before anything runs.
4. `npx prisma migrate dev` to apply it, then `npx prisma generate` — since Prisma 7, `migrate dev` no longer regenerates the client (v6 did). Commit the migration folder with the schema; one migration per change, never a second `init`.
5. Production: apply the committed migrations from CI or the deploy step — the exact commands, and what never runs against production, are in `.claude/rules/prisma.md`.

## Discipline that holds whichever skill fires

The migration, secret and query rules live in `.claude/rules/prisma.md`, scoped to the Prisma files, so they load even when a vendor skill fires instead of this one.

- **Security**: never fetch `passwordHash` or any sensitive column without explicit need; `select` over `include` — `.claude/rules/prisma.md` and `.claude/rules/security.md`.
- **TDD with a real DB**: integration tests hit a real test database (Docker Compose pattern), never a Prisma mock — the `dev-tdd` skill.
- **Postgres interop**: with Supabase, Prisma runs against the same Postgres and RLS still applies — the `dev-supabase` skill.

Why this pointer steps aside when Prisma's skills are installed, even though a session then often loads no skill: measured 2026-10-04, the work came out right either way (schema and migration correct 3/3 with and without this skill firing), and `.claude/rules/prisma.md` loads from the files in both cases — `eval/skill-triggering/FINDINGS.md`.
