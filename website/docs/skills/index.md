---
sidebar_position: 1
title: Skills
description: Catalogue des 24 skills auto-declenches
---

import Stats from '@site/src/components/Stats';

# Catalogue des Skills

> **24 skills** auto-declenches par mots-cles

<Stats items={[
  { number: 24, label: 'Skills' },
  { number: 24, label: 'Fork context' },
]} />

## Qu'est-ce qu'un Skill ?

Les **skills** sont des comportements auto-declenches :

- **Declenchement automatique** : Active par mots-cles dans la conversation
- **Contexte configurable** : Fork (isole) ou Shared (partage)
- **Outils restreints** : Acces limite via `allowed-tools`
- **Transparence** : L'utilisateur voit quand un skill est active

## Liste des skills

| Skill | Description |
|-------|-------------|
| `test-driven-development` | Developpement TDD |
| `generating-commit-messages` | Messages de commit |
| `debugging-issues` | Debogage |
| `reviewing-code` | Code review |
| `security-audit` | Audit securite |
| `planning-implementation` | Planification |
| `exploring-codebase` | Exploration |
| `creating-pull-requests` | Pull Requests |
| `api-development` | APIs REST/GraphQL |
| ... et 15 autres | |

## Declenchement

Les skills sont declenches par des mots-cles :

| Mots-cles | Skill |
|-----------|-------|
| "TDD", "test first" | test-driven-development |
| "commit", "message" | generating-commit-messages |
| "bug", "debug" | debugging-issues |
| "review" | reviewing-code |
| "securite", "OWASP" | security-audit |

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Agents](/docs/agents) - Les sub-agents autonomes
