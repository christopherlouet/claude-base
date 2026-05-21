---
sidebar_position: 19
title: "dev-supabase"
description: "Backend development with Supabase. Trigger when the user wants to configure auth, the database, or Supabase storage."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-supabase

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Backend development with Supabase. Trigger when the user wants to configure auth, the database, or Supabase storage.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `dev`, `supabase`, `supabase — `, `make a query work` |

## Detailed description

# Supabase (pointer)

Supabase publishes the canonical agent skills at [`supabase/agent-skills`](https://github.com/supabase/agent-skills) — maintained by the Supabase team, in sync with current API (Auth, DB, Edge Functions, Realtime, Storage). The repo ships two skills that stay current with every API release; the prior foundation skill (224 lines) drifted on each Supabase version.

## Delegate to the vendor skills

```bash
# Vendor publishes via marketplace (verify on their README):
claude plugin install supabase@supabase

# Fallback — clone and symlink both skills:
git clone --depth 1 https://github.com/supabase/agent-skills ~/dev/vendor-skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase ./.claude/skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase-postgres-best-practices \
      ./.claude/skills/supabase-postgres-best-practices
```

- **`supabase`** — Auth, DB, Edge Functions, Realtime, Storage with current API patterns.
- **`supabase-postgres-best-practices`** — 30 rules across 8 categories (indexing, RLS perf, schema design, pg_* extensions).

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Supabase — `supabase/agent-skills`". Reduction rationale: [`specs/foundation-positioning-review/spec.md`](../../../specs/foundation-positioning-review/spec.md) Wave 1.

## Foundation-unique angle preserved: cross-cutting discipline

The vendor covers the Supabase API surface. The foundation enforces version-agnostic conventions that survive across releases:

- **Auth**: Supabase Auth is one option among many — cross-ref the `dev-auth` skill for framework-agnostic patterns (sessions, OAuth, magic links) before deciding on Supabase-specific flows.
- **ORM interop**: Prisma operates against the same Postgres, and Supabase RLS coexists with Prisma queries — cross-ref the `dev-prisma` skill.
- **General Postgres**: the vendor's `supabase-postgres-best-practices` skill is useful for any Postgres project, not just Supabase-managed — cross-ref the `ops-database` skill.
- **Security**: RLS on every public table; never disable it to "make a query work" — cross-ref `.claude/rules/security.md`.

## Foundation rules preserved

- YOU MUST enable Row Level Security on every public-schema table before exposing it via PostgREST. No exceptions.
- YOU MUST use the Supavisor pooler (port 6543) for serverless / edge runtimes. Direct connections (5432) exhaust limits.
- NEVER `SELECT *` in production queries — specify columns (security + perf + payload size).
- YOU MUST store monetary amounts as `INTEGER` cents, never `FLOAT` / `NUMERIC` rounded — avoids drift footgun.
- YOU MUST index every foreign key and every column in frequent WHERE clauses.
- YOU MUST use cursor-based pagination (`gt('created_at', ...)`) for large tables, never `range()` / OFFSET (slow scan).
- NEVER commit `.env` with `SUPABASE_URL` / service-role key. Always `.env.example` with placeholders.
- NEVER expose the `service_role` key client-side — it bypasses RLS. Use it only in server-side code (Edge Functions, API routes).

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to supabase..."_
- _"I want to supabase — ..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: Supabase Auth + Row Level Security

# Example: Supabase Auth + Row Level Security

## Scenario
A multi-tenant task management app where users can only see their own tasks and team-shared tasks.

## Database Schema

```sql
-- Create tables
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  team_id UUID REFERENCES teams(id),
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member'))
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  owner_id UUID REFERENCES auth.users(id) NOT NULL,
  team_id UUID REFERENCES teams(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## Row Level Security Policies

```sql
-- Enable RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Users can read their own tasks + team tasks
CREATE POLICY "Users can view own and team tasks"
  ON tasks FOR SELECT
  USING (
    owner_id = auth.uid()
    OR team_id IN (
      SELECT team_id FROM profiles WHERE id = auth.uid()
    )
  );

-- Users can only insert tasks they own
CREATE POLICY "Users can create own tasks"
  ON tasks FOR INSERT
  WITH CHECK (owner_id = auth.uid());

-- Users can update only their own tasks
CREATE POLICY "Users can update own tasks"
  ON tasks FOR UPDATE
  USING (owner_id = auth.uid());

-- Admins can delete any team task
CREATE POLICY "Admins can delete team tasks"
  ON tasks FOR DELETE
  USING (
    owner_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
        AND team_id = tasks.team_id
    )
  );
```

## Client Usage (TypeScript)

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Sign up - profile created via trigger
const { data } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword123',
});

// Fetch tasks - RLS automatically filters to user's own + team tasks
const { data: tasks } = await supabase
  .from('tasks')
  .select('id, title, completed, owner_id')
  .order('created_at', { ascending: false });

// Insert task - RLS ensures owner_id matches auth.uid()
const { error } = await supabase
  .from('tasks')
  .insert({ title: 'New task', owner_id: user.id, team_id: user.team_id });
```

## Key Decisions

- **RLS over application-level filtering**: Security enforced at database level, not bypassable
- **`auth.uid()` function**: Built-in Supabase function, no need to pass user ID manually
- **Team visibility**: Users see team tasks via profile lookup, not task-level ACL
- **Role-based delete**: Only admins can delete others' tasks within their team
- **Anon key on client**: Safe because RLS restricts all access by authenticated user



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
