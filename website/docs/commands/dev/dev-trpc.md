---
sidebar_position: 24
title: "/dev:dev-trpc"
description: "Creation d'APIs type-safe avec tRPC."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TRPC

Creation d'APIs type-safe avec tRPC.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Concevoir et implementer une API tRPC type-safe pour un monorepo TypeScript full-stack
avec validation Zod, authentification et client React.

## Workflow

- Configurer le serveur tRPC (initTRPC, transformer superjson, error formatter Zod)
- Creer le contexte (prisma, session, user)
- Implementer le middleware d'authentification (protectedProcedure)
- Creer les routers par domaine (queries publiques, queries protegees, mutations)
- Implementer la pagination cursor-based
- Configurer le API handler (Next.js ou standalone)
- Configurer le client (httpBatchLink, transformer, provider)
- Utiliser les hooks cote client (useQuery, useMutation, useInfiniteQuery, useUtils)

## Output attendu

Architecture tRPC avec routers, procedures (type, auth), schemas de validation Zod,
configuration serveur et client.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-prisma` | Base de donnees |
| `/dev:dev-api` | Documentation API |
| `/qa:qa-security` | Securite |

---

IMPORTANT: tRPC est ideal pour monorepos TypeScript full-stack.

IMPORTANT: Toujours valider les inputs avec Zod.

YOU MUST utiliser protectedProcedure pour les operations authentifiees.

NEVER exposer de donnees sensibles dans les queries publiques.

Think hard sur la structure des routers et la separation des responsabilites.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
