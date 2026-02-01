---
sidebar_position: 2
title: Quick Start
description: Demarrer avec claude-socle en 5 minutes
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Quick Start

Soyez productif avec claude-socle en moins de 5 minutes.

## Prerequis

- [Claude Code](https://code.claude.com/docs/en/overview) installe et configure
- Un projet existant ou un nouveau repertoire

## Installation

### Option 1 : Script automatique (recommande)

```bash
# Dans le repertoire de votre projet
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash
```

Ce script :
- Clone le socle dans `.claude/`
- Configure les hooks et settings
- Verifie l'installation

### Option 2 : Installation manuelle

```bash
# Cloner le repository
git clone https://github.com/christopherlouet/claude-socle.git temp-socle

# Copier le dossier .claude
cp -r temp-socle/.claude .

# Nettoyer
rm -rf temp-socle
```

## Verification

Lancez Claude Code dans votre projet :

```bash
claude
```

Vous devriez voir au demarrage :
```
=== Claude Code Session ===
Version socle: 1.20.0
Commandes: 119
Agents: 57
===========================
```

## Premier workflow

<WorkflowDiagram steps={MAIN_WORKFLOW} title="Workflow principal : Explore → Plan → TDD → Commit" />

### Etape 1 : Explorer

Avant toute modification, comprenez le code existant :

```bash
/work-explore
```

Claude analysera :
- La structure du projet
- Les patterns et conventions
- Les dependances
- Les points d'attention

### Etape 2 : Planifier

Une fois le code compris, planifiez votre modification :

```bash
/work-plan "Ajouter une fonctionnalite d'authentification"
```

Claude proposera :
- L'architecture recommandee
- Les fichiers a creer/modifier
- Les risques identifies
- Les tests a ecrire

### Etape 3 : Coder

Implementez en suivant le plan :

```bash
# En TDD (recommande)
/dev-tdd "Implementer le service d'authentification"

# Ou implementation directe
# Claude suivra le plan valide
```

### Etape 4 : Commiter

Creez un commit propre :

```bash
/work-commit
```

Ou une Pull Request complete :

```bash
/work-pr
```

## Commandes essentielles

| Commande | Usage |
|----------|-------|
| `/assistant` | Point d'entree - guide vers les bonnes commandes (mode guide) |
| `/assistant-auto` | Execution automatique du workflow adapte (mode auto) |
| `/work-explore` | Explorer et comprendre le code |
| `/work-plan` | Planifier une modification |
| `/dev-tdd` | Developper en TDD |
| `/work-commit` | Creer un commit propre |
| `/work-pr` | Creer une Pull Request |

## Workflows pre-definis

Pour les taches courantes, utilisez les workflows complets :

```bash
# Nouvelle feature
/work-flow-feature "Description de la feature"

# Correction de bug
/work-flow-bugfix "Description du bug"

# Nouvelle release
/work-flow-release "v2.0.0"

# Lancement produit
/work-flow-launch "Mon nouveau SaaS"
```

## Obtenir de l'aide

```bash
# Guide complet des commandes (mode guide avec confirmation)
/assistant

# Aide sur une commande specifique
/assistant "Comment utiliser /dev-tdd ?"

# Execution automatique sans confirmation (utilisateurs avances)
/assistant-auto "Ajouter une feature d'authentification"
```

## Prochaines etapes

- [Comprendre l'architecture](/docs/intro/architecture) - Difference entre Commands, Agents et Skills
- [Voir les workflows](/docs/workflow) - Workflows detailles par type de tache
- [Explorer les commandes](/docs/commands) - Catalogue complet des 119 commandes
