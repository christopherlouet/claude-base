---
sidebar_position: 5
title: "/doc:doc-explain"
description: "Expliquer du code complexe en detail."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent EXPLAIN

Expliquer du code complexe en detail.

## Code a expliquer
`&lt;arguments&gt;`

## Objectif

Fournir une explication multi-niveaux (vue d'ensemble, structure, details) adaptee au public cible, avec analogies, diagrammes ASCII et exemples concrets.

## Workflow

- Lire et comprendre le code dans son contexte
- Niveau 1 : Vue d'ensemble (but, entrees/sorties, contexte d'usage)
- Niveau 2 : Structure (organisation, parties principales, interactions)
- Niveau 3 : Details (ligne par ligne si necessaire, choix d'implementation, edge cases)
- Fournir la complexite algorithmique si pertinent
- Illustrer avec des analogies et diagrammes ASCII
- Accompagner d'exemples concrets avec valeurs reelles

## Output attendu

### Resume en une phrase
### Explication detaillee (selon le niveau demande)
### Points cles a retenir
### Questions frequentes anticipees

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-onboard` | Decouvrir un codebase complet |
| `/work:work-explore` | Explorer avant d'expliquer |
| `/doc:doc-generate` | Documenter apres explication |
| `/qa:qa-review` | Reviewer du code explique |

---

IMPORTANT: Adapter le niveau de detail au public cible.

YOU MUST expliquer le "pourquoi", pas seulement le "quoi".

NEVER supposer que le lecteur connait le contexte.

Think hard sur les analogies qui peuvent clarifier les concepts.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
