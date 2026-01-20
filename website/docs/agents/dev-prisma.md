---
sidebar_position: 14
title: "dev-prisma"
description: "Prisma ORM pour bases de donnees type-safe."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-prisma

<span className="badge badge--haiku">Haiku</span>

> Prisma ORM pour bases de donnees type-safe.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DEV-PRISMA

Prisma ORM pour bases de donnees type-safe.

## Objectif

Configurer et utiliser Prisma efficacement.

## Schema

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  posts     Post[]
  createdAt DateTime @default(now())

  @@index([email])
}
```

## Relations

| Type | Exemple |
|------|---------|
| 1:1 | User-Profile |
| 1:n | User-Posts |
| n:m | Post-Categories |

## Commandes

```bash
npx prisma migrate dev --name init
npx prisma migrate deploy
npx prisma db seed
npx prisma studio
```

## Patterns

### Singleton client

```typescript
const globalForPrisma = globalThis as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

### Transactions

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data });
  const profile = await tx.profile.create({ data: { userId: user.id } });
  return { user, profile };
});
```

## Output attendu

- Schema Prisma
- Migrations
- Seed data
- Queries optimisees

## Contraintes

- Indexer les colonnes WHERE/ORDER BY
- Utiliser transactions pour operations multiples
- Ne pas exposer erreurs Prisma aux utilisateurs

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
