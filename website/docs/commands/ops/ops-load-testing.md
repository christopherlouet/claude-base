---
sidebar_position: 20
title: "/ops:ops-load-testing"
description: "Mettre en place et executer des tests de charge et de stress."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-LOAD-TESTING

Mettre en place et executer des tests de charge et de stress.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Valider les performances et la resilience de l'application sous charge,
identifier les limites et les goulots d'etranglement.

## Workflow

- Identifier le type de test (load, stress, spike, soak, breakpoint)
- Choisir l'outil adapte (k6 recommande, Locust, Artillery, JMeter)
- Ecrire les scripts de test avec scenarios realistes
- Definir les seuils de performance acceptables (p95, p99, error rate)
- Executer les tests sur un environnement isole avec monitoring actif
- Analyser les resultats et identifier les bottlenecks
- Integrer dans le CI/CD si pertinent

## Output attendu

1. **Scripts de test** : load-test.js, stress-test.js, scenario-test.js
2. **Rapport** : p95/p99 latency, error rate, throughput, bottlenecks
3. **Recommandations** d'optimisation priorisees
4. **Integration CI/CD** si applicable

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-perf` | Optimisation performance |
| `/ops:ops-monitoring` | Monitoring en production |
| `/ops:ops-cost-optimization` | Optimiser les couts |

---

IMPORTANT: Toujours tester sur un environnement isole, jamais en production.

YOU MUST definir des seuils de performance acceptables avant les tests.

NEVER executer des tests de charge sans monitoring actif.

Think hard sur les scenarios realistes avant de creer les tests.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
