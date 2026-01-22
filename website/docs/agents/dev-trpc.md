---
sidebar_position: 20
title: "dev-trpc"
description: "APIs type-safe avec tRPC."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-trpc

<span className="badge badge--haiku">Haiku</span>

> APIs type-safe avec tRPC.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DEV-TRPC

APIs type-safe avec tRPC.

## Objectif

Creer des APIs avec inference de types automatique.

## Architecture

```
server/
├── trpc.ts          # Config
├── context.ts       # Context
└── routers/
    ├── index.ts     # App router
    └── user.ts      # Procedures
```

## Server

### Procedure publique

```typescript
export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return ctx.prisma.user.findUnique({ where: { id: input.id } });
    }),
});
```

### Procedure protegee

```typescript
me: protectedProcedure.query(async ({ ctx }) => {
  return ctx.prisma.user.findUnique({ where: { id: ctx.user.id } });
}),
```

## Client

```typescript
const { data, isLoading } = trpc.user.getById.useQuery({ id: userId });

const mutation = trpc.user.update.useMutation({
  onSuccess: () => utils.user.getById.invalidate({ id: userId }),
});
```

## Output attendu

- Structure routers
- Procedures avec validation Zod
- Configuration client
- Integration React Query

## Contraintes

- Valider tous les inputs avec Zod
- Utiliser protectedProcedure pour auth
- Gerer les erreurs proprement

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
