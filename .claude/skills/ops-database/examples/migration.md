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
