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
