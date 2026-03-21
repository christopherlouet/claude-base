---
sidebar_position: 11
title: "/dev:dev-graphql"
description: "Concevoir et implementer des APIs GraphQL avec client Flutter."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-GRAPHQL

Concevoir et implementer des APIs GraphQL avec client Flutter.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Definir un schema GraphQL complet (types, inputs, queries, mutations, subscriptions)
et implementer le client Flutter avec gestion du cache et des erreurs.

## Workflow

- Definir les types de base avec scalaires custom (DateTime, UUID)
- Creer les input types pour creation/modification et filtrage/pagination
- Implementer les queries avec pagination (offset ou cursor-based Relay-style)
- Implementer les mutations avec auth payload
- Ajouter les subscriptions pour le temps reel
- Configurer le client Flutter (graphql_flutter ou ferry avec codegen)
- Implementer la gestion des erreurs (NetworkFailure, AuthFailure, ValidationFailure, ServerFailure)
- Configurer le cache avec politique appropriee (cacheFirst, cacheAndNetwork, networkOnly)

## Output attendu

Schema GraphQL complet, client Flutter configure avec auth et WebSocket,
gestion des erreurs, politique de cache et tests.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-flutter` | Widgets et screens |
| `/dev:dev-supabase` | Alternative/complement Supabase |
| `/dev:dev-api` | Design d'API REST |
| `/doc:doc-api-spec` | Documentation OpenAPI |

---

IMPORTANT: Toujours utiliser des variables GraphQL - jamais de string interpolation.

YOU MUST implementer la gestion des erreurs GraphQL (network + business).

NEVER exposer de donnees sensibles dans les queries cote client.

Think hard sur le schema avant d'implementer - c'est le contrat d'API.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
