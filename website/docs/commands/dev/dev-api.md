---
sidebar_position: 3
title: "/dev:dev-api"
description: "Créer ou documenter des endpoints REST/GraphQL."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent API

Créer ou documenter des endpoints REST/GraphQL.

## Endpoint ou API à traiter
`&lt;arguments&gt;`

## Objectif

Développer des APIs bien structurées, documentées et testables en suivant l'approche TDD.

Utilise le skill `dev-api` pour la méthodologie détaillée (structure RESTful, validation, documentation OpenAPI, tests).

## Pre-requis TDD

**Ordre de création obligatoire:**
1. Définir le contrat API (spec OpenAPI/types)
2. Écrire les tests d'intégration (RED)
3. Implémenter le handler (GREEN)
4. Refactorer si nécessaire (REFACTOR)
5. Documenter (Swagger/OpenAPI)

## Output attendu

### Spécification de l'endpoint
- Méthode et path
- Description
- Paramètres et body
- Réponses possibles (succès et erreurs)

### Code d'implémentation
- Route avec validation
- Handler
- Tests d'intégration

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-api-spec` | Générer spec OpenAPI/Swagger |
| `/dev:dev-test` | Tester les endpoints |
| `/qa:qa-security` | Audit sécurité de l'API |
| `/qa:qa-review` | Code review de l'API |

---

IMPORTANT: Une API est un contrat. Documenter avant d'implémenter.

IMPORTANT: Versionner l'API (/v1/, /v2/) pour éviter les breaking changes.

YOU MUST valider toutes les entrées utilisateur.

NEVER exposer de données sensibles dans les réponses API.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
