---
sidebar_position: 16
title: "/dev:dev-prompt-engineering"
description: "Optimisation systematique de prompts pour applications LLM."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-PROMPT-ENGINEERING

Optimisation systematique de prompts pour applications LLM.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Ameliorer les prompts pour obtenir des reponses plus precises, coherentes et utiles.
Auditer le prompt actuel et appliquer les techniques d'optimisation.

## Workflow

- Auditer le prompt (clarte, structure, contexte, exemples, contraintes, format output - score 1-5 chacun)
- Appliquer les techniques : few-shot, chain-of-thought, role prompting, structured output, negative prompting, delimiter clarity
- Structurer le prompt optimise : Role &gt; Contexte &gt; Tache &gt; Instructions &gt; Contraintes &gt; Exemples &gt; Format de sortie
- Utiliser les patterns avances si necessaire (self-consistency, ReAct)
- Evaluer avec metriques : precision, coherence, pertinence, format, tokens
- A/B tester le prompt original vs optimise
- Eviter les anti-patterns : prompt vague, trop long, sans exemples, sans contraintes, instructions contradictoires

## Output attendu

Analyse du prompt (score global, points forts, points a ameliorer),
prompt optimise complet et tableau des changements avec impact.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-rag` | Systemes de retrieval |
| `/dev:dev-api` | Integration API LLM |
| `/qa:qa-perf` | Performance des prompts |

---

IMPORTANT: Un bon prompt est reproductible et donne des resultats coherents.

IMPORTANT: Toujours tester avec plusieurs inputs avant de valider.

YOU MUST inclure des exemples (few-shot) pour les taches complexes.

NEVER ecrire de prompts ambigus ou trop generiques.

Think hard sur la clarte et la specificite du prompt.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
