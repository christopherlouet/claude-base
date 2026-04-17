---
sidebar_position: 15
title: "/ops:ops-gitflow-init"
description: "Initialiser GitFlow sur le repository avec les branches et conventions appropriees."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent GITFLOW-INIT

Initialiser GitFlow sur le repository avec les branches et conventions appropriees.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Configurer le repository pour utiliser GitFlow avec les branches main/develop,
les prefixes de branches et les protections recommandees.

## Workflow

- Verifier les prerequis (repo git, branche actuelle, modifications non commitees)
- Creer la branche develop depuis main si elle n'existe pas
- Pousser develop vers le remote
- Afficher un resume des branches et commandes disponibles
- Recommander la protection des branches main et develop

## Output attendu

1. **Branches configurees** : main (production), develop (integration)
2. **Prefixes** : feature/, release/, hotfix/
3. **Tableau des commandes** gitflow disponibles
4. **Workflow recommande** (feature → develop → release → main)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-gitflow-feature` | Gerer les branches feature |
| `/ops:ops-gitflow-release` | Gerer les branches release |
| `/ops:ops-gitflow-hotfix` | Gerer les hotfixes |

---

IMPORTANT: Verifier que le repo est propre avant d'initialiser.

YOU MUST creer la branche develop si elle n'existe pas.

YOU MUST afficher un resume clair des branches et commandes disponibles.

NEVER forcer le push ou supprimer des branches sans confirmation.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
