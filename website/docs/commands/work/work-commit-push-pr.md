---
sidebar_position: 4
title: "/work:work-commit-push-pr"
description: "Workflow complet: commit + push + PR en une seule commande."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-COMMIT-PUSH-PR

Workflow complet: commit + push + PR en une seule commande. Inspire par le workflow de Boris Cherny (createur de Claude Code).

## Contexte
`<arguments>`

## Objectif

Executer le cycle complet de livraison en une seule commande:
1. Verifier les tests et le lint
2. Creer un commit propre (Conventional Commits)
3. Push sur la branche distante
4. Creer une Pull Request documentee

> "This is the command I run dozens of times every day." - Boris Cherny

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMMIT → PUSH → PR                           │
├─────────────────────────────────────────────────────────────────┤
│  1. VERIFY     →  2. COMMIT    →  3. PUSH    →  4. PR          │
│  Tests + Lint     Conventional    Remote        Documentation   │
│                   Commits                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Phase 1: Verification

```bash
# Etat du repo
git status
git diff --stat

# Verifications qualite
npm test 2>&1 | tail -20 || echo "[WARN] Tests failed"
npm run lint 2>&1 | tail -10 || echo "[WARN] Lint failed"
npm run typecheck 2>&1 | tail -10 || echo "[WARN] Types failed"
```

## Phase 2: Commit

- Analyse les changements avec `git diff`
- Genere un message Conventional Commits
- Commit atomique avec les fichiers pertinents

## Phase 3: Push

```bash
# Push avec tracking
git push -u origin $(git branch --show-current)
```

## Phase 4: Pull Request

- Cree une PR avec `gh pr create`
- Titre court et descriptif
- Body avec resume et test plan

## Avantages

| Avantage | Description |
|----------|-------------|
| Rapidite | Une seule commande pour tout le cycle |
| Coherence | Format de commit et PR standardise |
| Securite | Verifications automatiques avant commit |
| Productivite | Recommande par Boris Cherny |

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-commit` | Commit seul sans push/PR |
| `/work:work-pr` | PR seule sans commit |
| `/qa:qa-review` | Review avant livraison |

---

IMPORTANT: Toujours verifier les tests et le lint avant de commiter.

YOU MUST creer des commits atomiques - un commit = une preoccupation.

NEVER commiter de fichiers sensibles (.env, credentials, secrets).

---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
