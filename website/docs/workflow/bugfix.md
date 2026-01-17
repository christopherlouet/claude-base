---
sidebar_position: 4
title: Correction de Bug
description: Workflow pour corriger un bug
---

import WorkflowDiagram, { BUGFIX_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflow : Correction de Bug

Guide pour diagnostiquer et corriger un bug efficacement.

<WorkflowDiagram steps={BUGFIX_WORKFLOW} />

## Commande rapide

```bash
/work-flow-bugfix "Description du bug"
```

## Etapes detaillees

### 1. Debug

```bash
/dev-debug "Description du probleme"
```

Diagnostiquer le bug :
- Reproduire le probleme
- Identifier la cause racine
- Tracer l'execution

### 2. Fix

```bash
/dev-tdd "Corriger le bug"
```

Corriger en TDD :
1. Ecrire un test qui echoue (reproduit le bug)
2. Corriger le code
3. Verifier que le test passe

### 3. Review

```bash
/qa-review
```

Verifier la correction :
- Le bug est corrige
- Pas de regression
- Tests de non-regression ajoutes

### 4. Commit

```bash
/work-commit
```

Format recommande :
```
fix(scope): description courte

- Detail de la correction
- Cause racine identifiee

Fixes #issue-number
```

## Exemple concret

```bash
# Bug : "Le login echoue avec des emails en majuscules"

> /work-flow-bugfix "Le login echoue avec des emails en majuscules"

# Claude :
# 1. Analyse le flux de login
# 2. Identifie la comparaison case-sensitive
# 3. Ecrit un test reproduisant le bug
# 4. Corrige en normalisant les emails
# 5. Verifie la non-regression
# 6. Cree le commit
```

## Bug urgent en production

Pour les bugs critiques :

```bash
# Hotfix avec GitFlow
/ops-gitflow-hotfix start "critical-login-bug"

# Corriger...

/ops-gitflow-hotfix finish "critical-login-bug"
```

Cela merge automatiquement dans `main` ET `develop`.

## Bonnes pratiques

### DO
- ✅ Reproduire le bug avant de corriger
- ✅ Ecrire un test de regression
- ✅ Identifier la cause racine
- ✅ Documenter la correction

### DON'T
- ❌ Corriger sans comprendre la cause
- ❌ Oublier les tests de regression
- ❌ Faire des modifications non liees
- ❌ Corriger plusieurs bugs en un commit

## Templates de commit

### Bug simple
```
fix(auth): normalize email before comparison

Fixes case-sensitive email login issue

Fixes #456
```

### Bug avec impact
```
fix(api): handle null response from external service

- Add null check before processing
- Add fallback default value
- Add error logging

Root cause: External API changed response format

Fixes #789
```

---

## Voir aussi

- [Debug](/docs/commands/dev/dev-debug)
- [Hotfix](/docs/commands/ops/ops-hotfix)
- [GitFlow Hotfix](/docs/commands/ops/ops-gitflow-hotfix)
