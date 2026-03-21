---
sidebar_position: 14
title: "/ops:ops-gitflow-release"
description: "Gerer les branches release avec GitFlow (start, finish, list)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent GITFLOW-RELEASE

Gerer les branches release avec GitFlow (start, finish, list).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Creer, preparer et finaliser des releases selon le workflow GitFlow
avec merge bidirectionnel (main + develop) et tag de version.

## Workflow

- Detecter l'action dans les arguments (start/finish/list)
- **start** : creer release/vX.X.X depuis develop, pousser la branche
- **finish** : merger dans main, creer le tag, merger dans develop, supprimer la branche
- **list** : lister les branches release et les tags existants
- Verifier les prerequis avant chaque action (repo propre, branches a jour)
- Respecter le versioning semantique (MAJOR.MINOR.PATCH)

## Output attendu

1. **Branche release** creee ou terminee
2. **Checklist** de preparation (bump version, changelog, tests)
3. **Resume des actions** effectuees
4. **Prochaines etapes** (deploiement, release notes GitHub)

## Agents lies

| Avant | Usage |
|-------|-------|
| `/ops:ops-gitflow-feature` | Features terminees |
| `/doc:doc-changelog` | Generer le changelog |

| Apres | Usage |
|-------|-------|
| `/qa:qa-audit` | Audit qualite avant release |

---

IMPORTANT: Une release DOIT etre mergee dans main ET develop.

YOU MUST creer un tag sur main apres le merge.

YOU MUST backporter les changements dans develop.

NEVER ajouter de nouvelles features sur une branche release.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
