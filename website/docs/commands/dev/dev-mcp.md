---
sidebar_position: 13
title: "/dev:dev-mcp"
description: "Guide pour creer des serveurs MCP (Model Context Protocol) de qualite."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-MCP

Guide pour creer des serveurs MCP (Model Context Protocol) de qualite.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Creer des serveurs MCP permettant aux LLMs d'interagir avec des services externes
via des tools bien concus. Support Python (FastMCP) et TypeScript (MCP SDK).

## Workflow

- **Research** : Etudier l'API cible (auth, rate limiting, pagination, schemas, erreurs)
- **Planning** : Definir les tools par priorite, concevoir pour les workflows (pas les endpoints)
- **Implementation** : Setup projet (FastMCP ou MCP SDK), validation inputs (Pydantic/Zod), erreurs actionnables
- **Review** : Verifier structure (pas de code duplique), types et validation, documentation par tool
- **Test** : Verifier syntaxe, build, tester avec timeout
- **Evaluation** : Creer 10 questions de test (independantes, lecture seule, complexes, verifiables)

## Principes de design

- Workflows, pas endpoints (consolider les operations)
- Retourner des infos high-signal, pas des dumps exhaustifs
- Noms naturels (tache humaine, pas nom d'API)
- Erreurs actionnables qui guident vers la correction

## Output attendu

Serveur MCP avec configuration (transport, langage, API cible), tools implementes
avec annotations, instructions d'installation et resultats d'evaluation.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | Si creation d'API REST en parallele |
| `/dev:dev-test` | Tests du serveur MCP |
| `/doc:doc-api-spec` | Documentation OpenAPI de l'API cible |

---

IMPORTANT: Concevoir pour les workflows, pas pour wrapper des endpoints.

YOU MUST valider tous les inputs avec Pydantic (Python) ou Zod (TypeScript).

YOU MUST retourner des erreurs actionnables qui guident l'utilisateur.

NEVER exposer de details techniques internes dans les messages d'erreur.

Think hard sur les cas d'usage reels avant de definir les tools.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
