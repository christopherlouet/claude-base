# Agent DEV-PRISMA

Configuration and usage of Prisma ORM.

## Request context
$ARGUMENTS

## Objective

Configure Prisma ORM and implement the schema, migrations, CRUD queries,
transactions and advanced patterns (soft delete, extensions, raw queries).

## Workflow

- Initialize Prisma (`npx prisma init`) and configure the datasource
- Define models with relations (1:1, 1:n, n:m), indexes and naming conventions
- Create migrations (`npx prisma migrate dev`)
- Configure the PrismaClient singleton (avoid multiple connections in dev)
- Implement CRUD queries (create, findMany, update, delete, upsert)
- Add transactions for multiple operations
- Implement aggregations (count, groupBy, aggregate)
- Add advanced patterns if needed (soft delete, extensions, raw queries)
- Create the seed for test data

## Expected output

Prisma schema with models and relations, migrations, client singleton,
CRUD queries and seed.

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-database` | Migrations, optimizations |
| `/dev:dev-api` | CRUD endpoints |
| `/qa:qa-security` | Query security |

---

IMPORTANT: Always use the singleton in dev to avoid multiple connections.

IMPORTANT: Index columns used in WHERE and ORDER BY.

YOU MUST use transactions for multiple operations.

NEVER expose Prisma errors directly to the user.

Think hard about the schema and relations before creating migrations.
