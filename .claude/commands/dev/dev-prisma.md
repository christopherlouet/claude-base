# Agent DEV-PRISMA

Configuration et utilisation de Prisma ORM.

## Contexte
$ARGUMENTS

## Setup Prisma

### Installation

```bash
# Installation
npm install prisma --save-dev
npm install @prisma/client

# Initialisation
npx prisma init
```

### Structure

```
prisma/
├── schema.prisma      # Schema principal
├── migrations/        # Historique migrations
└── seed.ts           # Donnees de test
```

## Schema Prisma

### Configuration

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql" // ou mysql, sqlite, mongodb
  url      = env("DATABASE_URL")
}
```

### Modeles

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  password  String
  role      Role     @default(USER)
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

model Post {
  id          String     @id @default(cuid())
  title       String
  content     String?
  published   Boolean    @default(false)
  author      User       @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId    String
  categories  Category[]
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  @@index([authorId])
  @@map("posts")
}

model Profile {
  id     String  @id @default(cuid())
  bio    String?
  avatar String?
  user   User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String  @unique

  @@map("profiles")
}

model Category {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]

  @@map("categories")
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

### Relations

| Type | Exemple | Description |
|------|---------|-------------|
| 1:1 | User-Profile | Un user a un profile |
| 1:n | User-Posts | Un user a plusieurs posts |
| n:m | Post-Categories | Posts et categories |

## Migrations

### Commandes

```bash
# Creer une migration
npx prisma migrate dev --name init

# Appliquer en production
npx prisma migrate deploy

# Reset (dev only)
npx prisma migrate reset

# Voir le status
npx prisma migrate status
```

### Migration SQL generee

```sql
-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "password" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE INDEX "users_email_idx" ON "users"("email");
```

## Client Prisma

### Singleton

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development'
      ? ['query', 'error', 'warn']
      : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

### Queries CRUD

```typescript
// Create
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe',
    password: hashedPassword,
    profile: {
      create: {
        bio: 'Hello world',
      },
    },
  },
  include: {
    profile: true,
  },
});

// Read
const users = await prisma.user.findMany({
  where: {
    email: { contains: '@example.com' },
    role: 'USER',
  },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
  orderBy: { createdAt: 'desc' },
  skip: 0,
  take: 10,
});

// Update
const updated = await prisma.user.update({
  where: { id: userId },
  data: {
    name: 'Jane Doe',
    profile: {
      update: {
        bio: 'Updated bio',
      },
    },
  },
});

// Delete
await prisma.user.delete({
  where: { id: userId },
});

// Upsert
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Updated Name' },
  create: {
    email: 'user@example.com',
    name: 'New User',
    password: hashedPassword,
  },
});
```

### Transactions

```typescript
// Transaction interactive
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: 'user@example.com', password: hash },
  });

  const profile = await tx.profile.create({
    data: { userId: user.id, bio: 'Hello' },
  });

  return { user, profile };
});

// Transaction batch
const [users, posts] = await prisma.$transaction([
  prisma.user.findMany(),
  prisma.post.findMany({ where: { published: true } }),
]);
```

### Aggregations

```typescript
// Count
const count = await prisma.user.count({
  where: { role: 'USER' },
});

// Group by
const groupedPosts = await prisma.post.groupBy({
  by: ['authorId'],
  _count: { id: true },
  _avg: { views: true },
  having: {
    id: { _count: { gt: 5 } },
  },
});

// Aggregate
const stats = await prisma.post.aggregate({
  _count: true,
  _avg: { views: true },
  _max: { views: true },
  _min: { views: true },
});
```

## Patterns avances

### Soft delete middleware

```typescript
// Middleware pour soft delete
prisma.$use(async (params, next) => {
  if (params.model === 'Post') {
    if (params.action === 'delete') {
      params.action = 'update';
      params.args.data = { deletedAt: new Date() };
    }
    if (params.action === 'deleteMany') {
      params.action = 'updateMany';
      params.args.data = { deletedAt: new Date() };
    }
  }
  return next(params);
});
```

### Extension client

```typescript
// Extension pour soft delete
const prismaWithSoftDelete = prisma.$extends({
  model: {
    post: {
      async softDelete(id: string) {
        return prisma.post.update({
          where: { id },
          data: { deletedAt: new Date() },
        });
      },
      async restore(id: string) {
        return prisma.post.update({
          where: { id },
          data: { deletedAt: null },
        });
      },
    },
  },
});
```

### Raw queries

```typescript
// SQL brut
const users = await prisma.$queryRaw`
  SELECT * FROM users
  WHERE email LIKE ${`%${search}%`}
  ORDER BY created_at DESC
  LIMIT ${limit}
`;

// Execute (INSERT, UPDATE, DELETE)
await prisma.$executeRaw`
  UPDATE users
  SET last_login = NOW()
  WHERE id = ${userId}
`;
```

## Seeding

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
import { hash } from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // Clean
  await prisma.post.deleteMany();
  await prisma.user.deleteMany();

  // Create admin
  const admin = await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin',
      password: await hash('admin123', 10),
      role: 'ADMIN',
    },
  });

  // Create users with posts
  await prisma.user.create({
    data: {
      email: 'user@example.com',
      name: 'User',
      password: await hash('user123', 10),
      posts: {
        create: [
          { title: 'First Post', content: 'Hello World', published: true },
          { title: 'Draft', content: 'Work in progress' },
        ],
      },
    },
  });

  console.log('Seed completed');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

## Output attendu

### Schema propose

```markdown
## Schema Prisma

### Modeles
[Liste des modeles avec relations]

### Diagramme
[Diagramme ER]

### Migrations a creer
1. [Migration 1]
2. [Migration 2]
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops-database` | Migrations, optimisations |
| `/dev-api` | Endpoints CRUD |
| `/qa-security` | Securite des queries |

---

IMPORTANT: Toujours utiliser le singleton en dev pour eviter les connexions multiples.

IMPORTANT: Indexer les colonnes utilisees dans WHERE et ORDER BY.

YOU MUST utiliser les transactions pour les operations multiples.

NEVER exposer les erreurs Prisma directement a l'utilisateur.
