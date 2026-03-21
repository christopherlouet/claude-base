---
sidebar_position: 4
title: "/dev:dev-api-versioning"
description: "Mettre en place une strategie de versioning d'API robuste."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-API-VERSIONING

Mettre en place une strategie de versioning d'API robuste.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Definir et implementer une strategie de versioning d'API qui permet l'evolution
tout en maintenant la compatibilite avec les clients existants.
URL Path versioning recommande pour la plupart des cas.

## Workflow

- Choisir la strategie (URL Path, Query Param, Header, Content Negotiation)
- Structurer le code : couche API versionnee, couche Service non versionnee
- Identifier les types de changements (additive = safe, breaking = nouvelle version)
- Implementer le routage par version
- Definir la timeline de depreciation (Active &gt; Deprecated &gt; Sunset &gt; Off)
- Ajouter les headers de depreciation (Deprecation, Sunset, Link successor-version)
- Documenter les breaking changes et le guide de migration
- Configurer le monitoring par version (requests, clients, erreurs, latence)

## Output attendu

Architecture de versioning, guide de migration, documentation OpenAPI par version,
timeline de depreciation et monitoring configure.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | Creer des endpoints |
| `/doc:doc-api-spec` | Documenter l'API |
| `/doc:doc-changelog` | Changelog des versions |

---

IMPORTANT: Ne jamais supprimer une version sans periode de depreciation.

YOU MUST documenter tous les breaking changes.

YOU MUST fournir un guide de migration pour chaque nouvelle version majeure.

NEVER faire de breaking changes dans une version mineure.

Think hard sur l'impact des changements avant de creer une nouvelle version.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
