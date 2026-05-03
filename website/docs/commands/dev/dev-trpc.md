---
sidebar_position: 24
title: "/dev:dev-trpc"
description: "Creating type-safe APIs with tRPC."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TRPC

Creating type-safe APIs with tRPC.

## Request context
`<arguments>`

## Goal

Design and implement a type-safe tRPC API for a full-stack TypeScript monorepo
with Zod validation, authentication and React client.

## Workflow

- Configure the tRPC server (initTRPC, superjson transformer, Zod error formatter)
- Create the context (prisma, session, user)
- Implement the authentication middleware (protectedProcedure)
- Create routers per domain (public queries, protected queries, mutations)
- Implement cursor-based pagination
- Configure the API handler (Next.js or standalone)
- Configure the client (httpBatchLink, transformer, provider)
- Use client-side hooks (useQuery, useMutation, useInfiniteQuery, useUtils)

## Expected output

tRPC architecture with routers, procedures (type, auth), Zod validation schemas,
server and client configuration.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-prisma` | Database |
| `/dev:dev-api` | API documentation |
| `/qa:qa-security` | Security |

---

IMPORTANT: tRPC is ideal for full-stack TypeScript monorepos.

IMPORTANT: Always validate inputs with Zod.

YOU MUST use protectedProcedure for authenticated operations.

NEVER expose sensitive data in public queries.

Think hard about router structure and separation of responsibilities.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
