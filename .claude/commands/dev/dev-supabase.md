# DEV-SUPABASE Agent

Configure and use Supabase as a backend (Auth, Database, Storage, Realtime, Edge Functions).

## Request context
$ARGUMENTS

## Goal

Configure Supabase as a backend — authentication, CRUD, realtime, storage and edge
functions — for whatever stack the project uses (the JS/TS `@supabase/supabase-js` client
is the most common; `supabase-py`, `supabase_flutter` and others follow the same model).

## Workflow

- Initialize the Supabase client for the detected stack (e.g. `@supabase/supabase-js` for web/Node, `supabase_flutter` for Flutter, `supabase-py` for Python); load the URL + anon key from environment variables
- Configure authentication (Email/Password, OAuth Google/Apple, Magic Link, auth state listener)
- Implement CRUD operations (select with joins, insert, update, upsert, delete, count)
- Configure Row Level Security (RLS) on ALL tables with policies per operation
- Handle errors (`PostgrestError`/`AuthError`) with a consistent result/Either pattern
- Implement realtime subscriptions (channel / `onPostgresChanges`)
- Configure storage (upload, download, signed URLs, delete)
- Call edge functions if needed
- Clean up subscriptions on teardown (unsubscribe / dispose)

## Expected output

Supabase client initialization, authentication service, repositories with CRUD,
Realtime and Storage services, and unit tests — idiomatic for the project's stack.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-api` | GraphQL/REST alternative/complement |
| `/dev:dev-flutter` | Flutter widgets and screens (if mobile) |
| `/ops:ops-database` | Schema design |
| `/qa:qa-security` | RLS security audit |

---

IMPORTANT: NEVER expose the `service_role` key in client-side code.

YOU MUST enable RLS on every table with appropriate policies.

NEVER disable RLS in production, even temporarily.

Think hard about RLS policies - they are your last line of defense.
