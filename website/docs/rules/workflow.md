---
sidebar_position: 16
title: "workflow"
description: "Workflow Rules"
tags:
  - "rule"
  - "workflow"
---

# Regles: workflow

> Workflow Rules

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

_Toutes les fichiers_

## Regles detaillees

# Workflow Rules

## Cycle Obligatoire: Explore -&gt; Plan -&gt; Code -&gt; Commit

### 1. EXPLORE (obligatoire)

- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir explore
- Utiliser `/work-explore` ou l'agent `work-explore`

### 2. PLAN (obligatoire pour features complexes)

- Proposer une architecture AVANT d'implementer
- Lister les fichiers a creer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder
- Utiliser `/work-plan`

### 3. CODE

- Implementer en suivant le plan valide
- Tests first si applicable (TDD avec `/dev-tdd`)
- Commits atomiques et frequents
- Respecter les conventions du projet

### 4. COMMIT

- Message de commit descriptif (Conventional Commits)
- Referencer les issues si applicable
- PR avec description complete
- Utiliser `/work-commit` ou `/work-pr`

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- `any` partout en TypeScript
- Copier-coller sans adapter
- Optimiser prematurement
- Ignorer les warnings de lint/types

## Workflows Recommandes

### Nouvelle feature
```
/work-flow-feature "description"
# ou manuellement:
/work-explore -> /work-plan -> /dev-tdd -> /work-pr
```

### Correction de bug
```
/work-flow-bugfix "description du bug"
```

### Nouvelle release
```
/work-flow-release "v2.0.0"
```

### Audit complet
```
/qa-audit  # Securite + RGPD + A11y + Perf
```

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
