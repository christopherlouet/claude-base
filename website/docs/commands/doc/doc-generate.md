---
sidebar_position: 7
title: "/doc:doc-generate"
description: "Generation de documentation pour le code."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent DOC

Generation de documentation pour le code.

## Cible
`&lt;arguments&gt;`

## Objectif

Generer la documentation appropriee (inline JSDoc/TSDoc, README de module, documentation API, ADR) en documentant le "pourquoi" et non le "quoi".

## Workflow

- Identifier le type de documentation necessaire (inline, README, API, ADR)
- Analyser les fonctions publiques/exportees et interfaces complexes
- Documenter les comportements non evidents et decisions d'architecture
- Ajouter des exemples d'utilisation
- Ne pas documenter le code auto-explicatif

## Output attendu

### Documentation generee
- Type: [inline/README/API/ADR]
- Fichiers crees/modifies: [liste]
- Contenu genere

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-api-spec` | Documentation OpenAPI |
| `/doc:doc-readme` | README du projet |
| `/doc:doc-architecture` | Documentation d'architecture |
| `/doc:doc-explain` | Expliquer du code complexe |

---

IMPORTANT: La meilleure documentation est un code lisible.

YOU MUST documenter le "pourquoi", pas le "quoi".

NEVER documenter ce qui est evident dans le code.

Think hard sur ce qui manque pour comprendre le code.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
