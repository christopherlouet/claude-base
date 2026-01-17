---
sidebar_position: 1
title: Agents
description: Catalogue des 37 sub-agents
---

import Stats from '@site/src/components/Stats';

# Catalogue des Agents

> **37 sub-agents** avec contexte isole pour des taches autonomes

<Stats items={[
  { number: 33, label: 'Agents Haiku' },
  { number: 4, label: 'Agents Sonnet' },
  { number: 37, label: 'Total' },
]} />

## Qu'est-ce qu'un Agent ?

Les **agents** sont des sub-agents autonomes avec un contexte isole :

- **Declenchement automatique** : Claude delegue selon le contexte
- **Contexte isole** : Ne pollue pas la conversation principale
- **Outils restreints** : Acces limite selon la tache
- **Modele specifique** : Haiku (rapide) ou Sonnet (complexe)

## Agents Sonnet (complexes)

| Agent | Description | Outils |
|-------|-------------|--------|
| `qa-security` | Audit securite OWASP | Read, Grep, Glob |
| `qa-audit` | Audit complet | Read, Grep, Glob, Bash |
| `qa-perf` | Audit performance | Read, Grep, Glob, Bash |
| `dev-debug` | Investigation bugs | Read, Grep, Glob, Bash |

## Agents Haiku (rapides)

| Agent | Description |
|-------|-------------|
| `work-explore` | Explorer un codebase |
| `doc-onboard` | Onboarding developpeur |
| `ops-deps` | Audit dependances |
| `ops-health` | Health check |
| `biz-model` | Business model |
| `growth-seo` | Audit SEO |
| ... et 27 autres | |

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
