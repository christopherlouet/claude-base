---
sidebar_position: 12
title: "/ops:ops-gitflow-hotfix"
description: "Gerer les hotfixes urgents avec GitFlow (start, finish, list)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent GITFLOW-HOTFIX

Gerer les hotfixes urgents avec GitFlow (start, finish, list).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Corriger rapidement un bug critique en production avec merge bidirectionnel
(main + develop + release si existante) et tag de version PATCH.

## Workflow

- Detecter l'action dans les arguments (start/finish/list)
- **start** : creer hotfix/xxx depuis main, pousser la branche
- **finish** : merger dans main, creer le tag PATCH, merger dans develop (et release si existe), supprimer la branche
- **list** : lister les hotfixes en cours
- Le fix doit etre minimal et cible (uniquement le bug, rien d'autre)
- Bump de version PATCH automatique si non specifie

## Output attendu

1. **Branche hotfix** creee ou terminee
2. **Tag** de version PATCH cree (pour finish)
3. **Resume des actions** effectuees (merges, tags)
4. **Recommandation** post-mortem

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | Investiguer le bug |
| `/ops:ops-hotfix` | Correction urgente simplifiee |
| `/work:work-flow-bugfix` | Bug non critique |

---

IMPORTANT: Un hotfix part TOUJOURS de main, jamais de develop.

YOU MUST merger dans main ET develop (et release si existe).

YOU MUST creer un tag avec version PATCH.

NEVER inclure autre chose que le fix du bug.

NEVER retarder un hotfix - la production est impactee.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
