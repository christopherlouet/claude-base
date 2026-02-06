---
sidebar_position: 1
title: "Rules"
description: "Catalogue des 21 regles par technologie"
---

import Stats from '@site/src/components/Stats';

# Catalogue des Regles

> **21 regles** appliquees automatiquement par chemin de fichier

<Stats items={[
  { number: 21, label: 'Regles' },
  { number: 98, label: 'Patterns' },
]} />

## Qu'est-ce qu'une Rule ?

Les **rules** sont des conventions appliquees automatiquement :

- **Application par path** : Actives selon le chemin du fichier
- **Conventions de code** : TypeScript, React, Flutter, etc.
- **Bonnes pratiques** : Securite, tests, API
- **Transparence** : Toujours visibles dans les suggestions

## Liste des regles

| Regle | Description | Paths |
|-------|-------------|-------|
| [`accessibility`](/docs/rules/accessibility) | // BON - Image decorative &lt;img src="decoration.png... | `**/*.tsx`, `**/*.jsx`... |
| [`api`](/docs/rules/api) | // Error \{ "success": false, "error": \{ "code": "V... | `**/api/**`, `**/routes/**`... |
| [`csharp`](/docs/rules/csharp) | // 2. Champs prives readonly private readonly IUse... | `**/*.cs`, `**/*.csproj`... |
| [`flutter`](/docs/rules/flutter) | // State abstract class AuthState \{\} class AuthIni... | `**/*.dart`, `**/lib/**`... |
| [`git`](/docs/rules/git) | [corps optionnel - details sur le "quoi" et "pourq... | - |
| [`go`](/docs/rules/go) | // Custom errors var ErrUserNotFound = errors.New(... | `**/*.go`, `**/go.mod`... |
| [`java`](/docs/rules/java) | // 2. Champs statiques private static final Logger... | `**/*.java`, `**/pom.xml`... |
| [`lsp`](/docs/rules/lsp) | LSP disponible via `ENABLE_LSP_TOOL=1` ou plugins ... | `**/*.ts`, `**/*.tsx`... |
| [`nextjs`](/docs/rules/nextjs) | **Regles RSC :** - Les Server Components ne peuven... | `**/next.config.*`, `**/app/**`... |
| [`performance`](/docs/rules/performance) | &lt;Image src="/hero.jpg" alt="Hero" width=\{1200\} hei... | `**/*.tsx`, `**/*.jsx`... |
| [`php`](/docs/rules/php) | declare(strict_types=1); | `**/*.php`, `**/composer.json` |
| [`python`](/docs/rules/python) | import requests from pydantic import BaseModel | `**/*.py`, `**/requirements*.txt`... |
| [`react`](/docs/rules/react) | export function MyComponent(\{ title, onAction \}: P... | `**/*.tsx`, `**/components/**`... |
| [`ruby`](/docs/rules/ruby) | users.each do |user| puts user.name puts user.emai... | `**/*.rb`, `**/Gemfile`... |
| [`rust`](/docs/rules/rust) | // 2. Constants const MAX_CONNECTIONS: usize = 100... | `**/*.rs`, `**/Cargo.toml` |
| [`security`](/docs/rules/security) | Security Rules | `**/auth/**`, `**/api/**`... |
| [`tdd-enforcement`](/docs/rules/tdd-enforcement) | IMPORTANT: Quand l'utilisateur demande d'implement... | `**/*.ts`, `**/*.tsx`... |
| [`testing`](/docs/rules/testing) | // Act - Executer l'action const result = function... | `**/*.test.ts`, `**/*.test.tsx`... |
| [`typescript`](/docs/rules/typescript) | TypeScript Rules | `**/*.ts`, `**/*.tsx`... |
| [`verification`](/docs/rules/verification) | Toute implementation doit etre verifiee AVANT d'et... | `**/*.ts`, `**/*.tsx`... |
| [`workflow`](/docs/rules/workflow) | Workflow Rules | - |

## Categories

### Langages

- [csharp](/docs/rules/csharp)
- [go](/docs/rules/go)
- [java](/docs/rules/java)
- [php](/docs/rules/php)
- [python](/docs/rules/python)
- [ruby](/docs/rules/ruby)
- [rust](/docs/rules/rust)
- [typescript](/docs/rules/typescript)

### Frameworks

- [flutter](/docs/rules/flutter)
- [react](/docs/rules/react)

### Pratiques

- [api](/docs/rules/api)
- [git](/docs/rules/git)
- [security](/docs/rules/security)
- [testing](/docs/rules/testing)
- [workflow](/docs/rules/workflow)

## Comment ajouter une regle personnalisee

Creez un fichier `.claude/rules/my-rule.md` :

```markdown
---
paths:
  - "**/my-folder/**"
  - "**/*.custom"
---

# Mes regles personnalisees

- Regle 1
- Regle 2
```

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre les composants
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
