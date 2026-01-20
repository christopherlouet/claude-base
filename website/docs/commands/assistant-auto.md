---
sidebar_position: 101
title: /assistant-auto
description: Orchestrateur en mode automatique (execution directe)
tags: [assistant, command, orchestrator, auto]
---

# /assistant-auto

<span className="badge badge--assistant">ASSISTANT-AUTO</span>

> Orchestrateur en mode automatique : analyse et execute directement le workflow

## Description

`/assistant-auto` est le mode **automatique** de l'orchestrateur. Il analyse votre demande et **execute immediatement** le workflow approprie sans demander de confirmation.

Pour un mode guide avec confirmation, utilisez [`/assistant`](/docs/commands/assistant).

## Deux modes disponibles

| Commande | Mode | Comportement |
|----------|------|--------------|
| `/assistant` | Guide | Analyse → Recommande → Attend confirmation |
| **`/assistant-auto`** | Automatique | Analyse → **Execute directement** |

## Usage

```bash
# Execution automatique d'une feature
/assistant-auto "Ajouter une feature d'authentification"
# → Detecte: nouvelle feature
# → Execute: /work-flow-feature "Ajouter une feature d'authentification"

# Correction de bug automatique
/assistant-auto "Fix le bug de login"
# → Detecte: correction de bug
# → Execute: /work-flow-bugfix "Fix le bug de login"

# Audit automatique
/assistant-auto "Audit de securite"
# → Detecte: audit securite
# → Execute: /qa-security
```

## Mapping automatique

| Votre demande contient... | Workflow execute |
|---------------------------|------------------|
| feature, ajouter, creer | `/work-flow-feature` |
| bug, fix, corriger, erreur | `/work-flow-bugfix` |
| release, version, tag | `/work-flow-release` |
| lancement, MVP, produit | `/work-flow-launch` |
| audit securite, OWASP | `/qa-security` |
| audit complet, qualite | `/qa-audit` |
| explorer, comprendre | `/work-explore` |
| commit | `/work-commit` |
| PR, pull request | `/work-pr` |

## Quand utiliser `/assistant-auto` ?

### Recommande pour :

- Utilisateurs **familiers** avec claude-socle
- Taches **repetitives** (features, bugfixes)
- Quand vous voulez de la **rapidite**
- Workflows **bien definis** (feature, bugfix, release)

### Preferez `/assistant` pour :

- **Nouveaux** utilisateurs
- Demandes **ambigues**
- Quand vous voulez **valider** avant execution
- **Decouverte** des commandes disponibles

## Exemple complet

```bash
> /assistant-auto "Ajouter un bouton de deconnexion dans le header"

## Execution automatique

**Demande**: Ajouter un bouton de deconnexion dans le header
**Workflow**: /work-flow-feature

Lancement...

# Le workflow /work-flow-feature s'execute avec les etapes :
# 1. /work-explore - Comprendre le code existant
# 2. /work-specify - Creer la specification
# 3. /work-plan - Planifier l'implementation
# 4. Implementation du code
# 5. /qa-review - Revue de code
# 6. /work-pr - Creer la PR
```

---

## Voir aussi

- [/assistant](/docs/commands/assistant) - Mode guide (avec confirmation)
- [Orchestrateur (concept)](/docs/concepts/orchestrator) - Documentation complete
- [Workflows](/docs/workflow)
- [Commands](/docs/commands)
