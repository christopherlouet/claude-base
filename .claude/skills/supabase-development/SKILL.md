---
name: supabase-development
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
