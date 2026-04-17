---
sidebar_position: 18
title: "dev-supabase"
description: "Developpement backend avec Supabase. Declencher quand l'utilisateur veut configurer l'auth, la base de donnees, ou le storage Supabase."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-supabase

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Developpement backend avec Supabase. Declencher quand l'utilisateur veut configurer l'auth, la base de donnees, ou le storage Supabase.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `supabase` |

## Description detaillee

# Supabase Development

## Configuration

```typescript
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);
```

## Authentication

```typescript
// Sign up
await supabase.auth.signUp({ email, password });

// Sign in
await supabase.auth.signInWithPassword({ email, password });

// OAuth
await supabase.auth.signInWithOAuth({ provider: 'google' });

// Sign out
await supabase.auth.signOut();
```

## Database avec RLS

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: users can read own data
CREATE POLICY "Users read own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Policy: users can update own data
CREATE POLICY "Users update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);
```

## Queries

```typescript
// Select
const { data } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', userId);

// Insert
await supabase.from('profiles').insert({ name, email });

// Update
await supabase.from('profiles').update({ name }).eq('id', userId);

// Delete
await supabase.from('profiles').delete().eq('id', userId);
```

## Storage

```typescript
// Upload
await supabase.storage.from('avatars').upload(path, file);

// Get URL
supabase.storage.from('avatars').getPublicUrl(path);
```

## Realtime

```typescript
supabase
  .channel('messages')
  .on('postgres_changes', { event: 'INSERT', table: 'messages' }, callback)
  .subscribe();
```

## Postgres Performance Best Practices

### Priorite critique : Query Performance

```sql
-- TOUJOURS utiliser des index sur les colonnes filtrees
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Index partiel pour les requetes frequentes
CREATE INDEX idx_active_users ON profiles(id) WHERE is_active = true;

-- Index composite pour les requetes multi-colonnes
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- ANALYSER les requetes lentes
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 'xxx';
```

### Priorite critique : Connection Management

```typescript
// UTILISER le connection pooling de Supabase (Supavisor)
// En mode Transaction pour les serverless
const supabase = createClient(url, key, {
  db: { schema: 'public' },
  auth: { persistSession: true },
});

// EVITER les connexions directes en serverless
// Utiliser toujours le pooler (port 6543 au lieu de 5432)
```

### Priorite haute : Schema Design

```sql
-- Types de donnees corrects (pas de VARCHAR quand UUID suffit)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  total_cents INTEGER NOT NULL,  -- Pas FLOAT pour les montants
  status TEXT NOT NULL DEFAULT 'pending',
  metadata JSONB DEFAULT '{}',  -- JSONB pas JSON
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Eviter SELECT * en production
-- Specifier les colonnes necessaires
const { data } = await supabase
  .from('orders')
  .select('id, status, total_cents')  -- PAS '*'
  .eq('user_id', userId);
```

### Priorite moyenne : Security & RLS

```sql
-- RLS performant : eviter les subqueries dans les policies
-- BON : comparaison directe
CREATE POLICY "own_data" ON orders
  FOR ALL USING (user_id = auth.uid());

-- MAUVAIS : subquery dans la policy (lent)
CREATE POLICY "team_data" ON orders
  FOR ALL USING (
    user_id IN (SELECT member_id FROM team_members WHERE team_id = current_setting('app.team_id'))
  );

-- MIEUX : utiliser un JWT claim
CREATE POLICY "team_data" ON orders
  FOR ALL USING (
    team_id = (auth.jwt() -> 'app_metadata' ->> 'team_id')::uuid
  );
```

### Priorite moyenne : Data Access Patterns

```sql
-- Pagination avec curseur (pas OFFSET pour les grandes tables)
-- BON : cursor-based
const { data } = await supabase
  .from('orders')
  .select('*')
  .gt('created_at', lastSeenDate)
  .order('created_at', { ascending: true })
  .limit(20);

-- MAUVAIS : offset-based (lent sur grandes tables)
const { data } = await supabase
  .from('orders')
  .select('*')
  .range(1000, 1020);  // Scanne 1020 lignes
```

### Monitoring

```sql
-- Requetes les plus lentes
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Tables sans index utilise
SELECT relname, seq_scan, seq_tup_read
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY seq_tup_read DESC;

-- Index non utilises
SELECT indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux supabase..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


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

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
