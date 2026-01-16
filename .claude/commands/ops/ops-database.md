# Agent DATABASE

Design de schéma, migrations et optimisation de base de données.

## Contexte
$ARGUMENTS

## Processus d'analyse

### 1. Comprendre le projet

```bash
# ORM/Driver utilisé
cat package.json 2>/dev/null | grep -E "prisma|drizzle|typeorm|sequelize|knex|pg|mysql|mongo"
cat requirements.txt 2>/dev/null | grep -E "sqlalchemy|django|prisma|psycopg|pymongo"

# Schéma existant
cat prisma/schema.prisma 2>/dev/null
ls -la migrations/ 2>/dev/null || ls -la prisma/migrations/ 2>/dev/null
cat src/models/*.ts 2>/dev/null | head -50
```

### 2. Design de schéma

#### Principes de modélisation

| Principe | Description |
|----------|-------------|
| **Normalisation** | Éviter la redondance (3NF minimum) |
| **Dénormalisation** | Accepter la redondance pour la perf (lectures) |
| **Intégrité** | Contraintes FK, unique, check |
| **Indexation** | Index sur les colonnes fréquemment requêtées |

#### Template de modèle

```
┌─────────────────────────────────────┐
│ Entity: [Nom]                       │
├─────────────────────────────────────┤
│ PK  id            UUID/SERIAL       │
│     field1        TYPE     NOT NULL │
│     field2        TYPE     NULLABLE │
│ FK  relation_id   UUID     NOT NULL │
│     created_at    TIMESTAMP         │
│     updated_at    TIMESTAMP         │
├─────────────────────────────────────┤
│ Indexes:                            │
│ - field1 (unique)                   │
│ - (field2, relation_id)             │
├─────────────────────────────────────┤
│ Relations:                          │
│ - belongs_to: Relation              │
│ - has_many: OtherEntity             │
└─────────────────────────────────────┘
```

### 3. Types de données recommandés

#### PostgreSQL
| Usage | Type recommandé | Éviter |
|-------|-----------------|--------|
| ID | `UUID` ou `BIGSERIAL` | `SERIAL` (limite 2B) |
| Texte court | `VARCHAR(n)` | `CHAR(n)` |
| Texte long | `TEXT` | `VARCHAR` sans limite |
| Booléen | `BOOLEAN` | `INTEGER` |
| Date/Heure | `TIMESTAMPTZ` | `TIMESTAMP` (sans TZ) |
| JSON | `JSONB` | `JSON` |
| Argent | `NUMERIC(19,4)` | `FLOAT`, `MONEY` |
| Enum | `ENUM` type | `VARCHAR` |

#### MySQL
| Usage | Type recommandé |
|-------|-----------------|
| ID | `BIGINT UNSIGNED AUTO_INCREMENT` |
| UUID | `BINARY(16)` ou `CHAR(36)` |
| Texte | `VARCHAR(n)` |
| Date/Heure | `DATETIME(6)` ou `TIMESTAMP` |
| JSON | `JSON` |

### 4. Prisma Schema (exemple)

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  password  String
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
  @@index([email])
}

model Post {
  id          String   @id @default(uuid())
  title       String
  content     String?
  published   Boolean  @default(false)
  author      User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId    String   @map("author_id")
  categories  Category[]
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  @@map("posts")
  @@index([authorId])
  @@index([published, createdAt])
}

model Category {
  id    String @id @default(uuid())
  name  String @unique
  posts Post[]

  @@map("categories")
}

enum Role {
  USER
  ADMIN
}
```

### 5. Migrations

#### Bonnes pratiques
- IMPORTANT: Une migration = un changement atomique
- IMPORTANT: Toujours réversible (up/down)
- YOU MUST tester les migrations sur une copie de prod
- Nommer clairement : `20240115_add_user_role`

#### Migration Prisma
```bash
# Créer une migration
npx prisma migrate dev --name add_user_role

# Appliquer en production
npx prisma migrate deploy

# Reset (dev uniquement)
npx prisma migrate reset
```

#### Migration SQL brute
```sql
-- migrations/20240115_add_user_role.up.sql
ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'user';
CREATE INDEX idx_users_role ON users(role);

-- migrations/20240115_add_user_role.down.sql
DROP INDEX idx_users_role;
ALTER TABLE users DROP COLUMN role;
```

### 6. Indexation

#### Quand créer un index
- [x] Colonnes dans WHERE fréquemment
- [x] Colonnes dans JOIN
- [x] Colonnes dans ORDER BY
- [x] Colonnes avec contrainte UNIQUE

#### Types d'index
| Type | Usage | PostgreSQL |
|------|-------|------------|
| B-tree | Égalité, range | Par défaut |
| Hash | Égalité uniquement | `USING hash` |
| GIN | JSON, arrays, full-text | `USING gin` |
| GiST | Géométrie, full-text | `USING gist` |

#### Exemples
```sql
-- Index simple
CREATE INDEX idx_users_email ON users(email);

-- Index composé (ordre important!)
CREATE INDEX idx_posts_author_date ON posts(author_id, created_at DESC);

-- Index partiel
CREATE INDEX idx_posts_published ON posts(created_at) WHERE published = true;

-- Index sur JSON
CREATE INDEX idx_users_metadata ON users USING gin(metadata);
```

### 7. Optimisation des requêtes

#### Identifier les requêtes lentes
```sql
-- PostgreSQL: requêtes lentes
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM posts WHERE author_id = '...' ORDER BY created_at DESC LIMIT 10;
```

#### Patterns d'optimisation

| Problème | Solution |
|----------|----------|
| N+1 queries | Eager loading (include/join) |
| Full table scan | Ajouter un index |
| Tri lent | Index sur colonnes ORDER BY |
| JOIN lent | Index sur FK |
| LIKE '%xxx%' | Full-text search |

#### Éviter N+1 (Prisma)
```typescript
// ❌ N+1
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ Eager loading
const users = await prisma.user.findMany({
  include: { posts: true }
});
```

### 8. Sécurité

#### Règles
- IMPORTANT: Requêtes paramétrées (jamais de concaténation)
- IMPORTANT: Principe du moindre privilège
- Chiffrer les données sensibles
- Backup réguliers testés

#### Requêtes paramétrées
```typescript
// ❌ Injection SQL possible
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ Paramétré
const user = await prisma.user.findUnique({ where: { email } });

// ✅ Raw paramétré
const users = await prisma.$queryRaw`SELECT * FROM users WHERE email = ${email}`;
```

### 9. Transactions

```typescript
// Prisma transaction
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  const post = await tx.post.create({
    data: { title, authorId: user.id }
  });
  return { user, post };
});

// Transaction avec isolation
const result = await prisma.$transaction(
  async (tx) => { /* ... */ },
  { isolationLevel: 'Serializable' }
);
```

### 10. Patterns avancés

#### Soft Delete
```prisma
model Post {
  id        String    @id
  deletedAt DateTime? @map("deleted_at")
  // ...
}
```

```typescript
// Middleware Prisma pour filtrer automatiquement
prisma.$use(async (params, next) => {
  if (params.model === 'Post' && params.action === 'findMany') {
    params.args.where = { ...params.args.where, deletedAt: null };
  }
  return next(params);
});
```

#### Audit Trail
```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(50),
  record_id UUID,
  action VARCHAR(10), -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Multi-tenancy
```prisma
model Tenant {
  id    String @id
  name  String
  users User[]
  posts Post[]
}

model User {
  id       String @id
  tenant   Tenant @relation(fields: [tenantId], references: [id])
  tenantId String
  // Toujours filtrer par tenantId!
}
```

## Output attendu

### Schéma proposé
```
┌─────────┐     ┌─────────┐     ┌──────────┐
│  User   │────<│  Post   │>────│ Category │
└─────────┘     └─────────┘     └──────────┘
```

### Modèles détaillés
[Diagramme de chaque entité avec champs, types, relations]

### Migrations à créer
| # | Migration | Description |
|---|-----------|-------------|
| 1 | `create_users` | Table users |
| 2 | `create_posts` | Table posts avec FK |
| 3 | `add_indexes` | Index de performance |

### Index recommandés
| Table | Colonnes | Type | Justification |
|-------|----------|------|---------------|
| users | email | unique | Lookup login |
| posts | author_id, created_at | btree | Liste posts par auteur |

### Requêtes à optimiser
| Requête | Problème | Solution |
|---------|----------|----------|
| | | |

### Checklist
- [ ] Schéma normalisé
- [ ] Relations définies
- [ ] Index créés
- [ ] Migrations testées
- [ ] Backup configuré

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/migrate` | Migrations de données |
| `/backup` | Stratégie de backup |
| `/perf` | Performance des requêtes |
| `/security` | Audit sécurité DB |
| `/infra-code` | Provisioning DB |

---

IMPORTANT: Toujours tester les migrations sur une copie de production avant de les appliquer.

YOU MUST utiliser des requêtes paramétrées - jamais de concaténation SQL.

NEVER stocker de mots de passe en clair - utiliser bcrypt/argon2.

Think hard sur les patterns d'accès aux données avant de définir les index.
