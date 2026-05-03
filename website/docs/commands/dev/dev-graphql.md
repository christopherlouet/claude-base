---
sidebar_position: 11
title: "/dev:dev-graphql"
description: "Design and implement GraphQL APIs with a Flutter client."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-GRAPHQL Agent

Design and implement GraphQL APIs with a Flutter client.

## Request context
`<arguments>`

## Objective

Define a complete GraphQL schema (types, inputs, queries, mutations, subscriptions)
and implement the Flutter client with cache and error handling.

## Workflow

- Define base types with custom scalars (DateTime, UUID)
- Create input types for creation/modification and filtering/pagination
- Implement queries with pagination (offset or cursor-based Relay-style)
- Implement mutations with auth payload
- Add subscriptions for real-time
- Configure the Flutter client (graphql_flutter or ferry with codegen)
- Implement error handling (NetworkFailure, AuthFailure, ValidationFailure, ServerFailure)
- Configure the cache with the appropriate policy (cacheFirst, cacheAndNetwork, networkOnly)

## Expected output

Complete GraphQL schema, Flutter client configured with auth and WebSocket,
error handling, cache policy and tests.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-flutter` | Widgets and screens |
| `/dev:dev-supabase` | Supabase alternative/complement |
| `/dev:dev-api` | REST API design |
| `/doc:doc-api-spec` | OpenAPI documentation |

---

IMPORTANT: Always use GraphQL variables - never string interpolation.

YOU MUST implement GraphQL error handling (network + business).

NEVER expose sensitive data in client-side queries.

Think hard about the schema before implementing - it's the API contract.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
