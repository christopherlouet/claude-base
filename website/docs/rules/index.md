---
sidebar_position: 1
title: Rules
description: Catalogue des 15 regles par technologie
---

import Stats from '@site/src/components/Stats';

# Catalogue des Regles

> **15 regles** appliquees automatiquement par chemin de fichier

<Stats items={[
  { number: 15, label: 'Regles' },
  { number: 50, label: 'Patterns' },
]} />

## Qu'est-ce qu'une Rule ?

Les **rules** sont des conventions appliquees automatiquement :

- **Application par path** : Actives selon le chemin du fichier
- **Conventions de code** : TypeScript, React, Flutter, etc.
- **Bonnes pratiques** : Securite, tests, API
- **Transparence** : Toujours visibles dans les suggestions

## Liste des regles

| Regle | Paths |
|-------|-------|
| `typescript` | `**/*.ts`, `**/*.tsx` |
| `react` | `**/*.tsx`, `**/components/**` |
| `flutter` | `**/*.dart`, `**/lib/**` |
| `testing` | `**/*.test.ts`, `**/__tests__/**` |
| `security` | `**/auth/**`, `**/api/**` |
| `api` | `**/api/**`, `**/routes/**` |
| `git` | - |
| `workflow` | - |
| `python` | `**/*.py` |
| `go` | `**/*.go` |
| `rust` | `**/*.rs` |
| `java` | `**/*.java` |
| `php` | `**/*.php` |
| `ruby` | `**/*.rb` |
| `csharp` | `**/*.cs` |

## Application

Les regles s'appliquent automatiquement lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre les composants
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
