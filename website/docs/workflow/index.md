---
sidebar_position: 1
title: Workflows
description: Workflows recommandes pour claude-socle
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflows

> Guides pas-a-pas pour les scenarios courants de developpement

## Workflow principal

<WorkflowDiagram steps={MAIN_WORKFLOW} title="Explore → Plan → Code → Commit" />

Le workflow principal de claude-socle suit 4 etapes obligatoires :

1. **Explore** - Comprendre le code existant avant de modifier
2. **Plan** - Planifier les changements avant d'implementer
3. **Code** - Implementer en suivant le plan valide
4. **Commit** - Creer des commits propres et descriptifs

## Workflows disponibles

| Workflow | Description | Commandes |
|----------|-------------|-----------|
| [Explore → Plan → Code → Commit](/docs/workflow/explore-plan-code-commit) | Workflow principal | `/work-explore`, `/work-plan`, `/dev-tdd`, `/work-commit` |
| [Nouvelle Feature](/docs/workflow/feature) | Ajouter une fonctionnalite | `/work-flow-feature` |
| [Correction de Bug](/docs/workflow/bugfix) | Corriger un probleme | `/work-flow-bugfix` |
| [Release](/docs/workflow/release) | Preparer une version | `/work-flow-release` |
| [Lancement Produit](/docs/workflow/launch) | Lancer un produit | `/work-flow-launch` |
| [TDD](/docs/workflow/tdd) | Developpement guide par les tests | `/dev-tdd` |

## Choisir le bon workflow

```mermaid
graph TD
    A[Nouvelle tache] --> B{Type ?}
    B -->|Feature| C[/work-flow-feature]
    B -->|Bug| D[/work-flow-bugfix]
    B -->|Release| E[/work-flow-release]
    B -->|Lancement| F[/work-flow-launch]
    B -->|Autre| G[Workflow principal]
```

## Voir aussi

- [Guide de choix](/docs/workflow/choosing-workflow) - Arbre de decision complet
- [Commands](/docs/commands) - Toutes les commandes disponibles
