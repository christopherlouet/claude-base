---
sidebar_position: 5
title: "/ops:ops-database"
description: "Design de schema, migrations et optimisation de base de donnees."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent DATABASE

Design de schema, migrations et optimisation de base de donnees.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Concevoir ou optimiser un schema de base de donnees avec les bonnes pratiques
de normalisation, indexation, migrations et securite.

## Workflow

- Identifier l'ORM/driver utilise et le schema existant
- Concevoir le schema (normalisation 3NF, types adaptes, contraintes)
- Definir les relations et les index de performance
- Creer les migrations atomiques et reversibles
- Optimiser les requetes (N+1, full table scan, joins lents)
- Appliquer les bonnes pratiques securite (requetes parametrees, moindre privilege)
- Documenter les patterns avances si necessaires (soft delete, audit trail, multi-tenancy)

## Output attendu

1. **Schema** : diagramme des entites avec champs, types et relations
2. **Migrations** a creer (ordonnees et decrites)
3. **Index** recommandes avec justification
4. **Checklist** (schema normalise, relations, index, migrations testees, backup)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-migrate` | Migrations de donnees |
| `/ops:ops-backup` | Strategie de backup |
| `/qa:qa-perf` | Performance des requetes |

---

IMPORTANT: Toujours tester les migrations sur une copie de production.

YOU MUST utiliser des requetes parametrees - jamais de concatenation SQL.

NEVER stocker de mots de passe en clair - utiliser bcrypt/argon2.

Think hard sur les patterns d'acces aux donnees avant de definir les index.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
