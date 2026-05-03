---
name: dev-supabase
description: Backend development with Supabase. Trigger when the user wants to configure auth, the database, or Supabase storage.
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

## Database with RLS

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

### Critical priority: Query Performance

```sql
-- ALWAYS use indexes on filtered columns
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Partial index for frequent queries
CREATE INDEX idx_active_users ON profiles(id) WHERE is_active = true;

-- Composite index for multi-column queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- ANALYZE slow queries
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 'xxx';
```

### Critical priority: Connection Management

```typescript
// USE Supabase's connection pooling (Supavisor)
// In Transaction mode for serverless
const supabase = createClient(url, key, {
  db: { schema: 'public' },
  auth: { persistSession: true },
});

// AVOID direct connections in serverless
// Always use the pooler (port 6543 instead of 5432)
```

### High priority: Schema Design

```sql
-- Correct data types (no VARCHAR when UUID is enough)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  total_cents INTEGER NOT NULL,  -- Not FLOAT for amounts
  status TEXT NOT NULL DEFAULT 'pending',
  metadata JSONB DEFAULT '{}',  -- JSONB not JSON
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Avoid SELECT * in production
-- Specify the necessary columns
const { data } = await supabase
  .from('orders')
  .select('id, status, total_cents')  -- NOT '*'
  .eq('user_id', userId);
```

### Medium priority: Security & RLS

```sql
-- Performant RLS: avoid subqueries in policies
-- GOOD: direct comparison
CREATE POLICY "own_data" ON orders
  FOR ALL USING (user_id = auth.uid());

-- BAD: subquery in the policy (slow)
CREATE POLICY "team_data" ON orders
  FOR ALL USING (
    user_id IN (SELECT member_id FROM team_members WHERE team_id = current_setting('app.team_id'))
  );

-- BETTER: use a JWT claim
CREATE POLICY "team_data" ON orders
  FOR ALL USING (
    team_id = (auth.jwt() -> 'app_metadata' ->> 'team_id')::uuid
  );
```

### Medium priority: Data Access Patterns

```sql
-- Cursor-based pagination (not OFFSET for large tables)
-- GOOD: cursor-based
const { data } = await supabase
  .from('orders')
  .select('*')
  .gt('created_at', lastSeenDate)
  .order('created_at', { ascending: true })
  .limit(20);

-- BAD: offset-based (slow on large tables)
const { data } = await supabase
  .from('orders')
  .select('*')
  .range(1000, 1020);  // Scans 1020 rows
```

### Monitoring

```sql
-- Slowest queries
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Tables without index used
SELECT relname, seq_scan, seq_tup_read
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY seq_tup_read DESC;

-- Unused indexes
SELECT indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```
