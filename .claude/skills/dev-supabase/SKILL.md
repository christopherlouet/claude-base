---
name: dev-supabase
description: Developpement backend avec Supabase. Declencher quand l'utilisateur veut configurer l'auth, la base de donnees, ou le storage Supabase.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

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
