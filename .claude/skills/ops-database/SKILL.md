---
name: ops-database
description: Conception de schemas de base de donnees. Declencher quand l'utilisateur veut creer des tables, migrations, ou optimiser des requetes.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Database Design

## Conventions

| Element | Convention | Exemple |
|---------|------------|---------|
| Tables | snake_case pluriel | users, order_items |
| Colonnes | snake_case | created_at, user_id |
| Primary key | id | id UUID |
| Foreign key | table_id | user_id |
| Index | idx_table_columns | idx_users_email |

## Schema PostgreSQL

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
| B-tree | Egalite, range (defaut) |
| GIN | JSONB, arrays, full-text |
| GiST | Geospatial |

## Optimisation

```sql
-- Analyser une requete
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Index manquants
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;
```
