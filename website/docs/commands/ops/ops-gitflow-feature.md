---
sidebar_position: 13
title: "/ops:ops-gitflow-feature"
description: "Gerer les branches feature avec GitFlow (start, finish, list, publish, pull)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent GITFLOW-FEATURE

Gerer les branches feature avec GitFlow (start, finish, list, publish, pull).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Creer, developper et finaliser des branches feature selon le workflow GitFlow,
avec merge --no-ff dans develop pour preserver l'historique.

## Workflow

- Detecter l'action dans les arguments (start/finish/list/publish/pull)
- **start** : creer feature/xxx depuis develop a jour, pousser la branche
- **finish** : merger --no-ff dans develop, supprimer la branche locale et remote
- **list** : lister les branches feature en cours
- **publish** : pousser la branche feature vers le remote
- **pull** : recuperer une branche feature distante
- Verifier les prerequis (develop a jour, pas de modifications non commitees)
- Utiliser kebab-case pour le nommage des branches

## Output attendu

1. **Branche feature** creee, terminee ou listee
2. **Resume des commits** merges (pour finish)
3. **Prochaines etapes** suggerees

## Agents lies

| Avant | Usage |
|-------|-------|
| `/ops:ops-gitflow-init` | Initialiser GitFlow |

| Apres | Usage |
|-------|-------|
| `/ops:ops-gitflow-release` | Preparer une release |
| `/work:work-commit` | Commiter proprement |

---

IMPORTANT: Toujours partir de develop pour creer une feature.

YOU MUST utiliser --no-ff pour le merge afin de preserver l'historique.

NEVER supprimer une branche feature sans avoir merge les changements.

NEVER forcer le push sur develop.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
