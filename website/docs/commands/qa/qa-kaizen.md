---
sidebar_position: 8
title: "/qa:qa-kaizen"
description: "Amelioration continue du code et des processus avec la methodologie Kaizen."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-KAIZEN

Amelioration continue du code et des processus avec la methodologie Kaizen.

## Contexte
`&lt;arguments&gt;`

## Objectif

Appliquer le cycle PDCA (Plan-Do-Check-Act) pour identifier et implementer des ameliorations incrementales et durables, en eliminant les gaspillages (Muda).

## Workflow

- PLAN : Identifier le probleme, root cause (5 Whys), objectif SMART
- DO : Implementer un changement a la fois, commits atomiques
- CHECK : Mesurer avant/apres, comparer aux objectifs
- ACT : Standardiser si succes, ajuster si echec
- Identifier les 7 Muda (surproduction, attente, transport, surtraitement, stock, mouvements, defauts)
- Documenter les resultats et planifier la prochaine iteration

## Output attendu

### Plan d'amelioration Kaizen
- Domaine, probleme, impact actuel
- Root cause identifiee via 5 Whys
- Objectif SMART et actions planifiees
- Metriques avant/apres
- Criteres de standardisation
- Date de prochaine review

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Implementer les ameliorations de code |
| `/qa:qa-perf` | Ameliorer les performances |
| `/qa:qa-coverage` | Ameliorer la couverture de tests |
| `/ops:ops-ci` | Ameliorer le pipeline CI/CD |

---

IMPORTANT: Kaizen = petites ameliorations continues, pas de revolutions.

YOU MUST mesurer avant et apres chaque amelioration.

NEVER implementer plusieurs changements en meme temps - un a la fois.

Think hard sur le ratio effort/impact de chaque amelioration.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
