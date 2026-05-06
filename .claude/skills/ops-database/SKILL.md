---
name: ops-database
description: Database schema design. Trigger when the user wants to create tables, migrations, or optimize queries.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
disable-model-invocation: true
---

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

## See also

MongoDB publishes their own official agent skills at [`mongodb/agent-skills`](https://github.com/mongodb/agent-skills) (102★, last commit 2026-05-04). The repo covers schema design heuristics, indexing strategies, query patterns, and operational safeguards specific to MongoDB.

For PostgreSQL, the `dev-supabase` skill already points to [`supabase/agent-skills`](https://github.com/supabase/agent-skills) which includes a `supabase-postgres-best-practices` skill (30 rules across 8 categories) — useful for any Postgres project, not just Supabase-managed.

When working on a project using one of these databases, install the relevant vendor skill alongside this one. This skill captures the **stack-neutral conventions** (naming, soft-delete patterns, `updated_at` triggers, partitioning strategy); the vendor skills capture the **canonical operational patterns** specific to MongoDB or Postgres.

**Vendor-neutrality**: MongoDB Inc. is independent. Supabase is independent. Both pass the vendor-neutrality filter.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/ops-skills-pilot-2026-05-06.md`.
