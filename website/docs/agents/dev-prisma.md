---
sidebar_position: 15
title: "dev-prisma"
description: "Prisma ORM for type-safe databases."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-prisma

<span className="badge badge--haiku">Haiku</span>

> Prisma ORM for type-safe databases.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent DEV-PRISMA

Prisma ORM for type-safe databases.

## Goal

Configure and use Prisma efficiently.

## Schema

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  posts     Post[]
  createdAt DateTime @default(now())

  @@index([email])
}
```

## Relations

| Type | Example |
|------|---------|
| 1:1 | User-Profile |
| 1:n | User-Posts |
| n:m | Post-Categories |

## Commands

```bash
npx prisma migrate dev --name init
npx prisma migrate deploy
npx prisma db seed
npx prisma studio
```

## Patterns

### Singleton client

```typescript
const globalForPrisma = globalThis as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

### Transactions

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data });
  const profile = await tx.profile.create({ data: { userId: user.id } });
  return { user, profile };
});
```

## Expected output

- Prisma schema
- Migrations
- Seed data
- Optimized queries

## Constraints

- Index WHERE/ORDER BY columns
- Use transactions for multiple operations
- Do not expose Prisma errors to users

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
