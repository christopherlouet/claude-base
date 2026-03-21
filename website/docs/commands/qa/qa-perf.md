---
sidebar_position: 12
title: "/qa:qa-perf"
description: "Analyse et optimisation des performances."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent PERF (Performance)

Analyse et optimisation des performances.

## Cible
`&lt;arguments&gt;`

## Objectif

Mesurer, identifier les bottlenecks et optimiser les performances en suivant une approche data-driven (profiling avant optimisation).

## Workflow

- Mesurer la baseline de performance (temps, memoire, CPU)
- Identifier les bottlenecks (code, frontend, backend)
- Profiler avec les outils adaptes (DevTools, Lighthouse, autocannon)
- Verifier les Core Web Vitals (LCP, FID, CLS, TTFB, INP)
- Proposer des optimisations par priorite (algorithme &gt; cache &gt; lazy loading)
- Mesurer apres optimisation pour valider l'impact

## Output attendu

### Baseline
- Metrique 1: [valeur initiale]
- Metrique 2: [valeur initiale]

### Bottlenecks identifies
| Localisation | Probleme | Impact estime |
|--------------|----------|---------------|

### Optimisations proposees
1. [Optimisation 1] - Gain estime: [X%]
2. [Optimisation 2] - Gain estime: [X%]

### Resultats apres optimisation
- Metrique 1: [avant] -&gt; [apres] ([X% amelioration])

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops:ops-monitoring` | Monitoring des perfs en prod |
| `/ops:ops-database` | Optimiser les requetes DB |
| `/qa:qa-audit` | Audit complet (inclut perf) |
| `/growth:growth-seo` | Core Web Vitals pour SEO |

---

IMPORTANT: "Premature optimization is the root of all evil" - Knuth. Optimise uniquement ce qui est mesure comme lent.

YOU MUST mesurer avant et apres chaque optimisation pour valider l'impact.

NEVER optimiser sans profiling prealable - identifier le vrai bottleneck.

Think hard sur le rapport cout/benefice de chaque optimisation.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
