---
sidebar_position: 29
title: "ops-database"
description: "Database schema design. Trigger when the user wants to create tables, migrations, or optimize queries."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-database

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Database schema design. Trigger when the user wants to create tables, migrations, or optimize queries.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops`, `database` |

## Detailed description

# Database Design

## Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | snake_case plural | users, order_items |
| Columns | snake_case | created_at, user_id |
| Primary key | id | id UUID |
| Foreign key | table_id | user_id |
| Index | idx_table_columns | idx_users_email |

## PostgreSQL Schema

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

## Relations

```sql
-- One-to-Many
CREATE TABLE posts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL
);

-- Many-to-Many
CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id),
    role_id UUID REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);
```

## Indexes

| Type | Usage |
|------|-------|
| B-tree | Equality, range (default) |
| GIN | JSONB, arrays, full-text |
| GiST | Geospatial |

## Optimization

```sql
-- Analyze a query
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Missing indexes
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;
```

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_
- _"I want to database..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: Database Migration (Schema + Data)

# Example: Database Migration (Schema + Data)

## Scenario
Add a `teams` table and migrate existing users from a `team_name` string column to a proper foreign key relationship.

## Schema Migration

```sql
-- migrations/20240115_001_create_teams.sql

-- Up
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE users
  ADD COLUMN team_id UUID REFERENCES teams(id);

CREATE INDEX idx_users_team_id ON users(team_id);

-- Down
DROP INDEX IF EXISTS idx_users_team_id;
ALTER TABLE users DROP COLUMN IF EXISTS team_id;
DROP TABLE IF EXISTS teams;
```

## Data Migration

```sql
-- migrations/20240115_002_migrate_team_data.sql

-- Up: Extract distinct team names into teams table, link users
INSERT INTO teams (name)
SELECT DISTINCT team_name FROM users
WHERE team_name IS NOT NULL
ON CONFLICT (name) DO NOTHING;

UPDATE users u
SET team_id = t.id
FROM teams t
WHERE u.team_name = t.name;

-- Verify before removing old column
-- SELECT count(*) FROM users WHERE team_name IS NOT NULL AND team_id IS NULL;

ALTER TABLE users DROP COLUMN team_name;

-- Down
ALTER TABLE users ADD COLUMN team_name VARCHAR(100);

UPDATE users u
SET team_name = t.name
FROM teams t
WHERE u.team_id = t.id;
```

## Migration Runner (TypeScript)

```typescript
// src/db/migrate.ts
import { pool } from './connection';
import { readdirSync, readFileSync } from 'fs';

async function migrate(direction: 'up' | 'down') {
  const files = readdirSync('./migrations').filter(f => f.endsWith('.sql')).sort();
  if (direction === 'down') files.reverse();

  for (const file of files) {
    const sql = readFileSync(`./migrations/${file}`, 'utf-8');
    const section = sql.split(`-- ${direction === 'up' ? 'Up': 'Down'}`)[1]?.split('-- ')[0];
    if (section) {
      await pool.query(section);
      console.log(`Applied ${direction}: ${file}`);
    }
  }
}
```

## Key Decisions

- **Separate schema and data migrations**: Schema first, then data, allows independent rollback
- **UUID primary keys**: Avoids sequential ID guessing, safe for distributed systems
- **Verification step**: Comment reminds to check data integrity before dropping columns
- **Reversible**: Both up and down directions for safe rollback
- **Index on FK**: `idx_users_team_id` prevents slow joins on the foreign key



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
