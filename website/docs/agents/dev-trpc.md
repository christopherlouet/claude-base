---
sidebar_position: 19
title: "dev-trpc"
description: "Type-safe APIs with tRPC."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-trpc

<span className="badge badge--haiku">Haiku</span>

> Type-safe APIs with tRPC.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent DEV-TRPC

Type-safe APIs with tRPC.

## Goal

Create APIs with automatic type inference.

## Architecture

```
server/
├── trpc.ts          # Config
├── context.ts       # Context
└── routers/
    ├── index.ts     # App router
    └── user.ts      # Procedures
```

## Server

### Public procedure

```typescript
export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return ctx.prisma.user.findUnique({ where: { id: input.id } });
    }),
});
```

### Protected procedure

```typescript
me: protectedProcedure.query(async ({ ctx }) => {
  return ctx.prisma.user.findUnique({ where: { id: ctx.user.id } });
}),
```

## Client

```typescript
const { data, isLoading } = trpc.user.getById.useQuery({ id: userId });

const mutation = trpc.user.update.useMutation({
  onSuccess: () => utils.user.getById.invalidate({ id: userId }),
});
```

## Expected output

- Routers structure
- Procedures with Zod validation
- Client configuration
- React Query integration

## Constraints

- Validate all inputs with Zod
- Use protectedProcedure for auth
- Handle errors cleanly

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
