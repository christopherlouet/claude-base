---
sidebar_position: 1
title: Workflows
description: Workflows recommandes pour claude-socle
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflows

> Guides pas-a-pas pour les scenarios courants de developpement

## Workflow principal

<WorkflowDiagram steps={MAIN_WORKFLOW} title="Explore → Specify → Plan → TDD → Commit" />

Le workflow principal de claude-socle suit 5 etapes obligatoires :

1. **Explore** - Comprendre le code existant avant de modifier
2. **Specify** - Creer une specification fonctionnelle (User Stories, criteres)
3. **Plan** - Planifier les changements avant d'implementer
4. **TDD** - Developper en ecrivant les tests AVANT le code (obligatoire)
5. **Commit** - Creer des commits propres et descriptifs

## Workflows disponibles

| Workflow | Description | Commandes |
|----------|-------------|-----------|
| [Explore → Specify → Plan → TDD → Commit](/docs/workflow/explore-plan-code-commit) | Workflow principal (TDD obligatoire) | `/work:work-explore`, `/work:work-specify`, `/work:work-plan`, `/dev:dev-tdd`, `/work:work-commit` |
| [Nouvelle Feature](/docs/workflow/feature) | Ajouter une fonctionnalite | `/work:work-flow-feature` |
| [Correction de Bug](/docs/workflow/bugfix) | Corriger un probleme | `/work:work-flow-bugfix` |
| [Release](/docs/workflow/release) | Preparer une version | `/work:work-flow-release` |
| [Lancement Produit](/docs/workflow/launch) | Lancer un produit | `/work:work-flow-launch` |
| [TDD](/docs/workflow/tdd) | Developpement guide par les tests | `/dev:dev-tdd` |

## Choisir le bon workflow

```mermaid
graph TD
    A[Nouvelle tache] --> B{Type ?}
    B -->|Feature| C[/work:work-flow-feature]
    B -->|Bug| D[/work:work-flow-bugfix]
    B -->|Release| E[/work:work-flow-release]
    B -->|Lancement| F[/work:work-flow-launch]
    B -->|Autre| G[Workflow principal]
```

## Voir aussi

- [Guide de choix](/docs/workflow/choosing-workflow) - Arbre de decision complet
- [Commands](/docs/commands) - Toutes les commandes disponibles
