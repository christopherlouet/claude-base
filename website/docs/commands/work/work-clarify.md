---
sidebar_position: 4
title: "/work:work-clarify"
description: "Pose des questions ciblees pour reduire l'ambiguite dans une specification."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-CLARIFY

Pose des questions ciblees pour reduire l'ambiguite dans une specification.

## Contexte
`&lt;arguments&gt;`

## Objectif

Identifier et resoudre les zones d'ambiguite dans la specification actuelle.
La clarification reduit le risque de retravail en aval.
Charger la spec depuis `specs/[feature]/spec.md` ou le fichier specifie.

## Workflow

- Charger et lire la specification
- Scanner les ambiguites par categorie : scope fonctionnel, modele de donnees, flux UX, qualite non-fonctionnelle, integrations, cas limites
- Marquer chaque categorie : **Clair** | **Partiel** | **Manquant**
- Generer max 5 questions priorisees par impact (scope &gt; securite &gt; UX &gt; technique)
- Poser UNE question a la fois, attendre la reponse
- Chaque question : choix multiple (2-5 options) OU reponse courte (5 mots max)
- Toujours proposer une recommandation basee sur les bonnes pratiques
- Apres chaque reponse acceptee, mettre a jour la spec
- Generer le rapport de fin de session avec couverture par categorie

## Output attendu

1. **Questions** : Max 5, une a la fois, avec contexte + recommandation
2. **Spec mise a jour** : Sections modifiees apres chaque reponse
3. **Rapport** : Questions posees, sections modifiees, couverture par categorie, recommandation suite

## Agents lies

| Avant | Usage |
|-------|-------|
| `/work:work-specify` | Creer la specification |

| Apres | Usage |
|-------|-------|
| `/work:work-plan` | Planifier l'implementation |

---

IMPORTANT: Maximum 5 questions par session - prioriser par impact.

YOU MUST poser UNE question a la fois et attendre la reponse.

YOU MUST mettre a jour la spec apres CHAQUE reponse acceptee.

NEVER reveler les questions suivantes a l'avance.

Think hard sur l'impact de chaque clarification avant de poser la question.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
