---
name: dev-prisma
description: Developpement avec Prisma ORM (schema, migrations, queries type-safe, Accelerate, transactions). Declencher quand l'utilisateur veut ajouter un modele, creer une migration, optimiser des queries Prisma, ou quand on detecte schema.prisma dans le projet.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Prisma ORM

## Setup

```bash
npm install prisma --save-dev
npm install @prisma/client

npx prisma init
```

Produit :
- `prisma/schema.prisma` : schema declaratif
- `.env` : `DATABASE_URL` (ne PAS commiter)

## Schema : conventions

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
  // Ou prisma-client (nouveau, tree-shakable, v6+)
  // provider = "prisma-client"
  // output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  posts     Post[]

  @@index([email])
  @@map("users")  // Table en snake_case en DB
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?  @db.Text
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())

  @@index([authorId])
  @@index([published, createdAt])
  @@map("posts")
}
```

### Regles naming

- **Models** : PascalCase singulier (`User`, `Post`)
- **Fields** : camelCase (`createdAt`, `authorId`)
- **Table en DB** : snake_case plural via `@@map("users")`
- **IDs** : cuid() par defaut (URL-safe, ordered), uuid() pour inter-systemes, autoincrement() pour ID numeriques

## Migrations

### Workflow dev

```bash
# Creer une migration (questionne le nom)
npx prisma migrate dev --name add_user_email_index

# Regenerer le client apres modif schema
npx prisma generate

# Reset complet (WIPE toutes les donnees)
npx prisma migrate reset
```

IMPORTANT: `prisma migrate dev` modifie la DB locale. **NE JAMAIS** l'utiliser en production.

### Workflow production

```bash
# Applique les migrations PENDING sur la DB cible (production)
npx prisma migrate deploy

# Verifier l'etat
npx prisma migrate status
```

### Migrations dangereuses

| Operation | Risque | Solution |
|-----------|--------|----------|
| Renommer un champ | Perte de donnees (Prisma dropera le champ et creera le nouveau) | 2 etapes : ajouter nouveau, backfill, retirer ancien |
| Changer type d'un champ | Conversion impossible selon le cas | ALTER TYPE manuel ou migration custom |
| Supprimer un modele avec FK | Cascade delete | Verifier toutes les relations, plan de backup |
| Ajouter NOT NULL | Casse si existing rows sont null | Default value OU migration en 2 temps (nullable → backfill → NOT NULL) |

## Queries type-safe

### Read

```ts
// findUnique : 1 ligne par PK ou unique
const user = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
});

// findFirst : premiere ligne match
const post = await prisma.post.findFirst({
  where: { published: true },
  orderBy: { createdAt: "desc" },
});

// findMany : liste
const posts = await prisma.post.findMany({
  where: { published: true, authorId: userId },
  orderBy: { createdAt: "desc" },
  take: 10,
  skip: page * 10,
});
```

### Include / select

```ts
// include : relations jointes
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: { where: { published: true }, take: 5 },
  },
});

// select : champs specifiques (plus efficace si besoin partiel)
const user = await prisma.user.findUnique({
  where: { id },
  select: { id: true, email: true, posts: { select: { id: true, title: true } } },
});
```

IMPORTANT: `include` recupere TOUS les champs. Preferer `select` si tu sais ce que tu veux (evite d'exposer des champs sensibles comme `passwordHash`).

### Write

```ts
// Create
const user = await prisma.user.create({
  data: { email: "alice@example.com", name: "Alice" },
});

// Create avec relations
const post = await prisma.post.create({
  data: {
    title: "Hello",
    author: { connect: { id: userId } },
    // Ou connectOrCreate si tu veux creer si inexistant
  },
});

// Update
const user = await prisma.user.update({
  where: { id },
  data: { name: "New Name" },
});

// Upsert (create OR update)
const user = await prisma.user.upsert({
  where: { email },
  create: { email, name },
  update: { name },
});

// Delete
await prisma.post.delete({ where: { id } });
```

## Transactions

### Interactive transaction (recommandee)

```ts
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email } });
  await tx.post.create({ data: { authorId: user.id, title: "..." } });
  // Si throw → rollback automatique
});
```

### Sequential transaction

```ts
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email } }),
  prisma.post.create({ data: { authorId: "...", title: "..." } }),
]);
```

IMPORTANT: Les transactions Prisma ont un timeout (5s par defaut). Pour long-running, passer `{ timeout: 30000 }`.

## N+1 — le piege classique

```ts
// N+1 : 1 query pour users, puis 1 query par user pour posts
const users = await prisma.user.findMany();
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { authorId: user.id } });  // N queries
}

// SOLUTION : include
const users = await prisma.user.findMany({ include: { posts: true } });  // 2 queries
```

### Detecter N+1

```ts
// Activer les logs SQL en dev
const prisma = new PrismaClient({
  log: ["query"],  // Loggue chaque query SQL
});
```

Pattern : voir le meme SELECT repete N fois → N+1.

## Pagination

### Offset pagination (simple, lent sur grands volumes)

```ts
const posts = await prisma.post.findMany({
  take: 20,
  skip: page * 20,
  orderBy: { createdAt: "desc" },
});
```

### Cursor pagination (rapide, recommande > 10K rows)

```ts
const posts = await prisma.post.findMany({
  take: 20,
  cursor: lastId ? { id: lastId } : undefined,
  skip: lastId ? 1 : 0,
  orderBy: { id: "desc" },
});
```

## Indexes et performance

Ajouter des indexes sur :
- **Foreign keys** : toujours (Prisma ne les cree pas auto dans certains providers)
- **Colonnes dans WHERE** frequents
- **Colonnes dans ORDER BY** + WHERE

```prisma
model Post {
  // Composite index pour WHERE published + ORDER BY createdAt
  @@index([published, createdAt])
}
```

Verifier les queries lentes :

```sql
EXPLAIN ANALYZE SELECT * FROM posts WHERE published = true ORDER BY created_at DESC LIMIT 20;
```

## Prisma Accelerate (cache + pooling)

Pour les apps serverless/edge avec connection pool :

```bash
npm install @prisma/extension-accelerate
```

```ts
import { PrismaClient } from "@prisma/client";
import { withAccelerate } from "@prisma/extension-accelerate";

const prisma = new PrismaClient().$extends(withAccelerate());

// Activer le cache sur une query
const users = await prisma.user.findMany({
  cacheStrategy: { swr: 60, ttl: 300 },  // serve stale 60s, TTL 5min
});
```

Sans Accelerate, utiliser un pgBouncer ou pool manuel.

## Seed

```ts
// prisma/seed.ts
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { email: "admin@example.com" },
    create: { email: "admin@example.com", name: "Admin" },
    update: {},
  });
}

main().finally(() => prisma.$disconnect());
```

```json
// package.json
"prisma": {
  "seed": "tsx prisma/seed.ts"
}
```

Lancer : `npx prisma db seed`

## Tests avec Prisma

### Option 1 : test DB reelle (recommande)

```bash
# .env.test
DATABASE_URL=postgresql://user:pass@localhost:5432/test_db

# Setup
npx prisma migrate deploy --schema=./prisma/schema.prisma
```

Reset entre tests :

```ts
beforeEach(async () => {
  await prisma.$executeRaw`TRUNCATE "users", "posts" CASCADE`;
});
```

### Option 2 : mock (attention aux divergences)

Utiliser `prisma-mock` ou `vitest-mock-extended`. Garde cela pour les tests unitaires purs, les tests d'integration doivent utiliser une vraie DB.

## Pieges courants

| Piege | Prevention |
|-------|-----------|
| `prisma migrate dev` en prod | Utiliser UNIQUEMENT `prisma migrate deploy` |
| Schema modifie sans `prisma generate` | CI step : `prisma generate` avant build |
| Connection leak | `await prisma.$disconnect()` en fin de script, ou singleton en app |
| Query $queryRaw non type-safe | Utiliser `$queryRawUnsafe` seulement si vraiment necessaire, preferer les builders |
| Multiple PrismaClient instances | Singleton via globalThis en dev (HMR-safe) |

### Singleton HMR-safe

```ts
// lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = global as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## Complement avec le socle

- Agent `dev-prisma` : creation de schema, migrations complexes
- Rule `.claude/rules/security.md` : ne pas exposer `select: { passwordHash: true }`
- Skill `dev-supabase` : si stack Supabase (Supabase utilise aussi Postgres, interop possible)
- Skill `dev-tdd` : tests avec vraie DB

## Output attendu

1. **Schema** structure correctement (PascalCase models, camelCase fields, indexes explicites)
2. **Queries type-safe** avec `select` plutot qu'`include` quand possible
3. **Transactions** pour mutations multi-tables
4. **Singleton Prisma client** (jamais d'instance ad-hoc)
5. **Migrations nommees** explicitement (pas de nom auto-genere)

## Regles

IMPORTANT: NEVER utiliser `prisma migrate dev` en production. Toujours `prisma migrate deploy`.

IMPORTANT: `prisma generate` apres chaque modif schema. Ajouter au build CI.

IMPORTANT: Singleton PrismaClient (eviter les leaks de connexion).

YOU MUST ajouter un index sur chaque foreign key et chaque colonne dans WHERE frequent.

YOU MUST utiliser `select` au lieu d'`include` quand tu connais les champs (securite + perf).

NEVER commiter `.env` avec DATABASE_URL. Toujours `.env.example` avec placeholders.

NEVER renommer un champ directement : 2-etapes (ajouter nouveau → backfill → retirer ancien).
