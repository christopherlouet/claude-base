---
sidebar_position: 9
title: "/qa:qa-loop"
description: "Boucle autonome audit → fix → test → re-audit avec criteres d'arret."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-LOOP

Boucle autonome audit → fix → test → re-audit avec criteres d'arret.

## Contexte
`&lt;arguments&gt;`

## Objectif

Executer une boucle continue d'amelioration qualite : auditer le projet,
corriger les problemes P0/P1, verifier les tests, et recommencer jusqu'a
atteindre le score cible ou les criteres d'arret.

## Parametres (extraire de `&lt;arguments&gt;`)

- **Score cible** : score minimum pour arreter (defaut: 90/100)
- **Max iterations** : nombre maximum de cycles (defaut: 5)
- **Domaines** : securite, a11y, perf, qualite, ux (defaut: tous)
- **Severite** : P0+P1 (defaut), ou P0 uniquement

## Workflow

```
AUDIT (lecture) → FIX (P0/P1 avec TDD) → VERIFY (tests) → CHECK (criteres)
  ↑                                                            │
  └──────────── score < cible ET iterations < max ─────────────┘
```

1. **AUDIT** : Score /100 par domaine, lister P0/P1/P2
2. **FIX** : Corriger P0 puis P1 (test d'abord, commit atomique)
3. **VERIFY** : Tests complets, lint, type-check — revert si regression
4. **CHECK** : Score &gt;= cible ET 0 P0/P1 → STOP, sinon → AUDIT

## Output attendu

1. **Par iteration** : tableau scores, delta, fixes appliques
2. **Rapport final** : score initial → final, fixes total, problemes restants
3. **Commits** : un par fix, format `fix(domaine): description`

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Audit complet initial |
| `/qa:qa-security` | Audit securite approfondi |
| `/qa:qa-perf` | Audit performance approfondi |
| `/qa:wcag-audit` | Audit accessibilite approfondi |
| `/dev:dev-tdd` | Cycle TDD pour les fixes |

## Exemples d'utilisation

```
/qa:qa-loop                           # Defaut: score 90, max 5 iterations
/qa:qa-loop "score 95"                # Score cible 95/100
/qa:qa-loop "securite+perf, max 3"    # 2 domaines, 3 iterations max
/qa:qa-loop "P0 uniquement"           # Ne corriger que les critiques
```

---

IMPORTANT: Separer clairement la phase AUDIT (lecture) de la phase FIX (ecriture).

IMPORTANT: Arreter immediatement si un fix introduit une regression.

YOU MUST produire un rapport avec scores a chaque iteration.

NEVER depasser le nombre maximum d'iterations.

NEVER corriger les P2/P3 — ils seront traites dans une prochaine boucle.

Think hard about l'ordre optimal des fixes pour maximiser l'impact et minimiser les risques de regression.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
