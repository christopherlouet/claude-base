---
sidebar_position: 15
title: "dev-prisma"
description: "Development with Prisma ORM (schema, migrations, type-safe queries, Accelerate, transactions). Trigger when the user wants to add a model, create a migration, optimize Prisma queries, or when schema.prisma is detected in the project."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-prisma

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Development with Prisma ORM (schema, migrations, type-safe queries, Accelerate, transactions). Trigger when the user wants to add a model, create a migration, optimize Prisma queries, or when schema.prisma is detected in the project.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `dev`, `prisma` |

## Detailed description

# Prisma ORM

## Setup

```bash
npm install prisma --save-dev
npm install @prisma/client

npx prisma init
```

Produces:
- `prisma/schema.prisma`: declarative schema
- `.env`: `DATABASE_URL` (do NOT commit)

## Schema: conventions

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
  // Or prisma-client (new, tree-shakable, v6+)
  // provider = "prisma-client"
  // output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  posts     Post[]

  @@index([email])
  @@map("users")  // Table in snake_case in DB
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?  @db.Text
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())

  @@index([authorId])
  @@index([published, createdAt])
  @@map("posts")
}
```

### Naming rules

- **Models**: singular PascalCase (`User`, `Post`)
- **Fields**: camelCase (`createdAt`, `authorId`)
- **DB table**: plural snake_case via `@@map("users")`
- **IDs**: cuid() by default (URL-safe, ordered), uuid() for inter-systems, autoincrement() for numeric IDs

## Migrations

### Dev workflow

```bash
# Create a migration (prompts for the name)
npx prisma migrate dev --name add_user_email_index

# Regenerate the client after schema change
npx prisma generate

# Full reset (WIPES all data)
npx prisma migrate reset
```

IMPORTANT: `prisma migrate dev` modifies the local DB. **NEVER** use it in production.

### Production workflow

```bash
# Apply PENDING migrations to the target DB (production)
npx prisma migrate deploy

# Check the state
npx prisma migrate status
```

### Dangerous migrations

| Operation | Risk | Solution |
|-----------|------|----------|
| Rename a field | Data loss (Prisma will drop the field and create the new one) | 2 steps: add new, backfill, remove old |
| Change a field's type | Conversion impossible depending on the case | Manual ALTER TYPE or custom migration |
| Remove a model with FK | Cascade delete | Check all relations, backup plan |
| Add NOT NULL | Breaks if existing rows are null | Default value OR 2-step migration (nullable → backfill → NOT NULL) |

## Type-safe queries

### Read

```ts
// findUnique: 1 row by PK or unique
const user = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
});

// findFirst: first matching row
const post = await prisma.post.findFirst({
  where: { published: true },
  orderBy: { createdAt: "desc" },
});

// findMany: list
const posts = await prisma.post.findMany({
  where: { published: true, authorId: userId },
  orderBy: { createdAt: "desc" },
  take: 10,
  skip: page * 10,
});
```

### Include / select

```ts
// include: joined relations
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: { where: { published: true }, take: 5 },
  },
});

// select: specific fields (more efficient if you only need part of them)
const user = await prisma.user.findUnique({
  where: { id },
  select: { id: true, email: true, posts: { select: { id: true, title: true } } },
});
```

IMPORTANT: `include` fetches ALL fields. Prefer `select` if you know what you want (avoids exposing sensitive fields like `passwordHash`).

### Write

```ts
// Create
const user = await prisma.user.create({
  data: { email: "alice@example.com", name: "Alice" },
});

// Create with relations
const post = await prisma.post.create({
  data: {
    title: "Hello",
    author: { connect: { id: userId } },
    // Or connectOrCreate if you want to create if non-existent
  },
});

// Update
const user = await prisma.user.update({
  where: { id },
  data: { name: "New Name" },
});

// Upsert (create OR update)
const user = await prisma.user.upsert({
  where: { email },
  create: { email, name },
  update: { name },
});

// Delete
await prisma.post.delete({ where: { id } });
```

## Transactions

### Interactive transaction (recommended)

```ts
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email } });
  await tx.post.create({ data: { authorId: user.id, title: "..." } });
  // If throw → automatic rollback
});
```

### Sequential transaction

```ts
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email } }),
  prisma.post.create({ data: { authorId: "...", title: "..." } }),
]);
```

IMPORTANT: Prisma transactions have a timeout (5s by default). For long-running, pass `{ timeout: 30000 }`.

## N+1 — the classic trap

```ts
// N+1: 1 query for users, then 1 query per user for posts
const users = await prisma.user.findMany();
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { authorId: user.id } });  // N queries
}

// SOLUTION: include
const users = await prisma.user.findMany({ include: { posts: true } });  // 2 queries
```

### Detect N+1

```ts
// Enable SQL logs in dev
const prisma = new PrismaClient({
  log: ["query"],  // Logs each SQL query
});
```

Pattern: seeing the same SELECT repeated N times → N+1.

## Pagination

### Offset pagination (simple, slow on large volumes)

```ts
const posts = await prisma.post.findMany({
  take: 20,
  skip: page * 20,
  orderBy: { createdAt: "desc" },
});
```

### Cursor pagination (fast, recommended > 10K rows)

```ts
const posts = await prisma.post.findMany({
  take: 20,
  cursor: lastId ? { id: lastId }: undefined,
  skip: lastId ? 1: 0,
  orderBy: { id: "desc" },
});
```

## Indexes and performance

Add indexes on:
- **Foreign keys**: always (Prisma does not create them automatically in certain providers)
- **Columns in frequent WHERE** clauses
- **Columns in ORDER BY** + WHERE

```prisma
model Post {
  // Composite index for WHERE published + ORDER BY createdAt
  @@index([published, createdAt])
}
```

Check slow queries:

```sql
EXPLAIN ANALYZE SELECT * FROM posts WHERE published = true ORDER BY created_at DESC LIMIT 20;
```

## Prisma Accelerate (cache + pooling)

For serverless/edge apps with connection pool:

```bash
npm install @prisma/extension-accelerate
```

```ts
import { PrismaClient } from "@prisma/client";
import { withAccelerate } from "@prisma/extension-accelerate";

const prisma = new PrismaClient().$extends(withAccelerate());

// Enable cache on a query
const users = await prisma.user.findMany({
  cacheStrategy: { swr: 60, ttl: 300 },  // serve stale 60s, TTL 5min
});
```

Without Accelerate, use pgBouncer or a manual pool.

## Seed

```ts
// prisma/seed.ts
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { email: "admin@example.com" },
    create: { email: "admin@example.com", name: "Admin" },
    update: {},
  });
}

main().finally(() => prisma.$disconnect());
```

```json
// package.json
"prisma": {
  "seed": "tsx prisma/seed.ts"
}
```

Run: `npx prisma db seed`

## Tests with Prisma

### Option 1: real test DB (recommended)

```bash
# .env.test
DATABASE_URL=postgresql://user:pass@localhost:5432/test_db

# Setup
npx prisma migrate deploy --schema=./prisma/schema.prisma
```

Reset between tests:

```ts
beforeEach(async () => {
  await prisma.$executeRaw`TRUNCATE "users", "posts" CASCADE`;
});
```

### Option 2: mock (beware of divergences)

Use `prisma-mock` or `vitest-mock-extended`. Keep this for pure unit tests, integration tests must use a real DB.

## Common traps

| Trap | Prevention |
|------|------------|
| `prisma migrate dev` in prod | Use ONLY `prisma migrate deploy` |
| Schema modified without `prisma generate` | CI step: `prisma generate` before build |
| Connection leak | `await prisma.$disconnect()` at the end of script, or singleton in app |
| Non-type-safe $queryRaw query | Use `$queryRawUnsafe` only if truly necessary, prefer the builders |
| Multiple PrismaClient instances | Singleton via globalThis in dev (HMR-safe) |

### HMR-safe singleton

```ts
// lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = global as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## Complement with the foundation

- Agent `dev-prisma`: schema creation, complex migrations
- Rule `.claude/rules/security.md`: do not expose `select: { passwordHash: true }`
- Skill `dev-supabase`: if Supabase stack (Supabase also uses Postgres, interop possible)
- Skill `dev-tdd`: tests with a real DB

## Expected output

1. **Schema** correctly structured (PascalCase models, camelCase fields, explicit indexes)
2. **Type-safe queries** with `select` rather than `include` when possible
3. **Transactions** for multi-table mutations
4. **Singleton Prisma client** (never an ad-hoc instance)
5. **Explicitly named migrations** (no auto-generated name)

## Rules

IMPORTANT: NEVER use `prisma migrate dev` in production. Always `prisma migrate deploy`.

IMPORTANT: `prisma generate` after every schema change. Add it to the CI build.

IMPORTANT: Singleton PrismaClient (avoid connection leaks).

YOU MUST add an index on every foreign key and every column in frequent WHERE clauses.

YOU MUST use `select` instead of `include` when you know the fields (security + perf).

NEVER commit `.env` with DATABASE_URL. Always `.env.example` with placeholders.

NEVER rename a field directly: 2 steps (add new → backfill → remove old).

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to prisma..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
