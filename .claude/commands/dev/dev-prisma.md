# Agent DEV-PRISMA

Configuration et utilisation de Prisma ORM.

## Contexte de la demande
$ARGUMENTS

## Objectif

Configurer Prisma ORM et implementer le schema, les migrations, les queries CRUD,
les transactions et les patterns avances (soft delete, extensions, raw queries).

## Workflow

- Initialiser Prisma (`npx prisma init`) et configurer le datasource
- Definir les modeles avec relations (1:1, 1:n, n:m), index et conventions de nommage
- Creer les migrations (`npx prisma migrate dev`)
- Configurer le singleton PrismaClient (eviter connexions multiples en dev)
- Implementer les queries CRUD (create, findMany, update, delete, upsert)
- Ajouter les transactions pour operations multiples
- Implementer les aggregations (count, groupBy, aggregate)
- Ajouter les patterns avances si necessaire (soft delete, extensions, raw queries)
- Creer le seed pour les donnees de test

## Output attendu

Schema Prisma avec modeles et relations, migrations, singleton client,
queries CRUD et seed.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-database` | Migrations, optimisations |
| `/dev:dev-api` | Endpoints CRUD |
| `/qa:qa-security` | Securite des queries |

---

IMPORTANT: Toujours utiliser le singleton en dev pour eviter les connexions multiples.

IMPORTANT: Indexer les colonnes utilisees dans WHERE et ORDER BY.

YOU MUST utiliser les transactions pour les operations multiples.

NEVER exposer les erreurs Prisma directement a l'utilisateur.

Think hard sur le schema et les relations avant de creer les migrations.
