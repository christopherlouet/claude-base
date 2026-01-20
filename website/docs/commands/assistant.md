---
sidebar_position: 100
title: /assistant
description: Point d'entree unique claude-socle
tags: [assistant, command]
---

# /assistant

<span className="badge badge--assistant">ASSISTANT</span>

> Point d'entree unique vers toutes les commandes, agents, skills et workflows

## Description

L'assistant est le point d'entree unique de claude-socle. Il vous guide vers les bonnes commandes selon votre contexte et vos besoins.

## Usage

```bash
/assistant

# Ou avec une question
/assistant "Comment ajouter une nouvelle feature ?"
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
- 110 commandes par domaine
- 51 agents specialises
- 32 skills auto-declenches
- 17 rules par technologie

## Exemple

```bash
> /assistant "Je veux ajouter un systeme d'authentification"

# Claude propose :
# 1. /work-explore pour comprendre le code existant
# 2. /work-plan pour planifier l'implementation
# 3. /dev-tdd pour developper en TDD
# 4. /qa-security pour auditer la securite
# 5. /work-pr pour creer la PR
```

---

## Voir aussi

- [Workflows](/docs/workflow)
- [Commands](/docs/commands)
- [Quick Start](/docs/intro/quick-start)
