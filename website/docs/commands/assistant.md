---
sidebar_position: 100
title: /assistant
description: Point d'entree unique claude-socle (mode guide)
tags: [assistant, command, orchestrator]
---

# /assistant

<span className="badge badge--assistant">ASSISTANT</span>

> Point d'entree unique vers toutes les commandes, agents, skills et workflows (mode guide)

## Description

L'assistant est le point d'entree unique de claude-socle en **mode guide**. Il analyse votre demande, recommande un workflow adapte, et **attend votre confirmation** avant d'executer.

Pour une execution automatique sans confirmation, utilisez [`/assistant-auto`](/docs/commands/assistant-auto).

## Deux modes disponibles

| Commande | Mode | Comportement |
|----------|------|--------------|
| **`/assistant`** | Guide | Analyse → Recommande → **Attend confirmation** |
| `/assistant-auto` | Automatique | Analyse → Execute directement |

## Usage

```bash
/assistant

# Ou avec une demande
/assistant "Comment ajouter une nouvelle feature ?"

# Pour une execution directe (sans confirmation)
/assistant-auto "Ajouter une feature d'authentification"
```

## Fonctionnalites

### Detection automatique

L'assistant detecte automatiquement :
- Le type de projet (Web, Mobile, API, etc.)
- Les technologies utilisees
- Le contexte de la demande

### Guide de choix

Il propose les commandes adaptees selon :
- Votre situation (nouvelle feature, bug, release)
- Votre stack technologique
- Votre niveau d'experience

### Vue d'ensemble

Il donne acces a :
- 119 commandes par domaine
- 57 agents specialises
- 41 skills auto-declenches
- 21 rules par technologie

## Exemple

```bash
> /assistant "Je veux ajouter un systeme d'authentification"

# Claude propose :
# 1. /work:work-explore pour comprendre le code existant
# 2. /work:work-plan pour planifier l'implementation
# 3. /dev:dev-tdd pour developper en TDD
# 4. /qa:qa-security pour auditer la securite
# 5. /work:work-pr pour creer la PR
```

---

## Voir aussi

- [/assistant-auto](/docs/commands/assistant-auto) - Mode automatique (execution directe)
- [Orchestrateur (concept)](/docs/concepts/orchestrator) - Documentation complete
- [Workflows](/docs/workflow)
- [Commands](/docs/commands)
- [Quick Start](/docs/intro/quick-start)
