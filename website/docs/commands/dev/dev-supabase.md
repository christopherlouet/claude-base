---
sidebar_position: 19
title: "/dev:dev-supabase"
description: "Configure and use Supabase as a backend (Auth, Database, Storage, Realtime, Edge Functions)."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-SUPABASE Agent

Configure and use Supabase as a backend (Auth, Database, Storage, Realtime, Edge Functions).

## Request context
`<arguments>`

## Goal

Configure Supabase for a Flutter application with authentication,
CRUD operations, realtime subscriptions, storage and edge functions.

## Workflow

- Initialize Supabase (supabase_flutter, environment variables via --dart-define)
- Configure authentication (Email/Password, OAuth Google/Apple, Magic Link, Auth State Listener)
- Implement CRUD operations (select with joins, insert, update, upsert, delete, count)
- Configure Row Level Security (RLS) on ALL tables with policies per operation
- Handle errors (PostgrestException, AuthException) with Either pattern
- Implement realtime subscriptions (stream, onPostgresChanges)
- Configure storage (upload, download, signed URLs, delete)
- Call edge functions if needed
- Clean up subscriptions (dispose/close)

## Expected output

Supabase configuration in main.dart, authentication service,
repositories with CRUD, Realtime and Storage services, unit tests.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-flutter` | Widgets and screens |
| `/dev:dev-graphql` | GraphQL alternative/complement |
| `/ops:ops-database` | Schema design |
| `/qa:qa-security` | RLS security audit |

---

IMPORTANT: NEVER expose the `service_role` key in the Flutter client code.

YOU MUST enable RLS on every table with appropriate policies.

NEVER disable RLS in production, even temporarily.

Think hard about RLS policies - they are your last line of defense.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
