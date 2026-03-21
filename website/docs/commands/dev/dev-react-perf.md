---
sidebar_position: 18
title: "/dev:dev-react-perf"
description: "Optimisation performance React/Next.js basee sur des regles priorisees par impact."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-REACT-PERF

Optimisation performance React/Next.js basee sur des regles priorisees par impact.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Auditer et optimiser les performances React/Next.js en identifiant les violations
par priorite (CRITICAL &gt; HIGH &gt; MEDIUM &gt; LOW) et en mesurant l'impact reel.

## Workflow

- Analyser les metriques actuelles (LCP, bundle size, re-renders)
- Identifier les violations CRITICAL : waterfalls (async parallel, defer await, suspense boundaries)
- Identifier les violations CRITICAL : bundle size (barrel imports, dynamic imports, preload)
- Identifier les violations HIGH : cache serveur (React cache, LRU), fetching client (SWR/React Query)
- Identifier les violations MEDIUM : re-renders (memo, dependencies, transitions), rendering (content-visibility, hydration)
- Identifier les violations LOW : JS micro-optimizations, advanced patterns
- Mesurer AVANT et APRES chaque optimisation
- Produire un rapport avec violations, corrections et gains estimes

## Output attendu

Rapport d'optimisation avec score actuel, violations par priorite (fichier + impact estime),
corrections proposees et gains mesures (LCP, bundle size).

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-perf` | Audit performance generique (pas specifique React) |
| `/dev:dev-refactor` | Apres identification des optimisations |
| `/dev:dev-component` | Creer des composants optimises des le depart |
| `/qa:qa-review` | Review incluant la performance |

---

IMPORTANT: Mesurer AVANT et APRES chaque optimisation pour valider l'impact reel.

YOU MUST prioriser CRITICAL &gt; HIGH &gt; MEDIUM &gt; LOW.

NEVER optimiser prematurement - profiler d'abord, optimiser ensuite.

Think hard sur le ratio effort/gain de chaque optimisation.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
