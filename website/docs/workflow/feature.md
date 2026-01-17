---
sidebar_position: 3
title: Nouvelle Feature
description: Workflow pour ajouter une nouvelle fonctionnalite
---

import WorkflowDiagram, { FEATURE_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflow : Nouvelle Feature

Guide complet pour ajouter une nouvelle fonctionnalite.

<WorkflowDiagram steps={FEATURE_WORKFLOW} />

## Commande rapide

```bash
/work-flow-feature "Description de la feature"
```

Cette commande lance automatiquement le workflow complet.

## Etapes detaillees

### 1. Explore

```bash
/work-explore
```

Comprendre le code existant et identifier :
- Ou ajouter la feature
- Les patterns a suivre
- Les impacts potentiels

### 2. Specify (optionnel)

```bash
/work-specify "Description de la feature"
```

Creer une specification formelle si la feature est complexe :
- User stories
- Criteres d'acceptation
- Cas limites

### 3. Plan

```bash
/work-plan
```

Planifier l'implementation :
- Fichiers a creer
- Fichiers a modifier
- Tests requis
- Risques identifies

### 4. Code

```bash
/dev-tdd "Implementer la feature"
```

Developper en TDD :
1. Ecrire les tests
2. Implementer le code
3. Refactorer si necessaire

### 5. Review

```bash
/qa-review
```

Verifier la qualite :
- Code propre
- Tests complets
- Documentation a jour

### 6. PR

```bash
/work-pr
```

Creer une Pull Request :
- Titre descriptif
- Description complete
- Checklist de tests

## Exemple concret

```bash
# Ajouter un systeme de notifications

> /work-flow-feature "Ajouter un systeme de notifications push"

# Claude enchaine automatiquement :
# 1. Explore le code existant
# 2. Propose une specification
# 3. Planifie l'implementation
# 4. Implemente en TDD
# 5. Review le code
# 6. Cree la PR
```

## Bonnes pratiques

### DO
- ✅ Toujours explorer avant de coder
- ✅ Valider le plan avant implementation
- ✅ Tests a chaque etape
- ✅ Commits atomiques

### DON'T
- ❌ Coder sans plan valide
- ❌ Commits geants multi-features
- ❌ Ignorer les tests
- ❌ Forcer la PR sans review

## GitFlow Integration

Avec GitFlow active :

```bash
# Creer la branche feature
/ops-gitflow-feature start "notification-system"

# Developper...

# Terminer la feature
/ops-gitflow-feature finish "notification-system"
```

---

## Voir aussi

- [Workflow principal](/docs/workflow/explore-plan-code-commit)
- [TDD](/docs/workflow/tdd)
- [GitFlow Feature](/docs/commands/ops/ops-gitflow-feature)
