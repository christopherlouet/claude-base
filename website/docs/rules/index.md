---
sidebar_position: 1
title: "Rules"
description: "Catalog of 30 rules by technology"
---

import Stats from '@site/src/components/Stats';

# Rules Catalog

> **30 rules** automatically applied by file path

<Stats items={[
  { number: 30, label: 'Rules' },
  { number: 156, label: 'Patterns' },
]} />

## What is a Rule?

**Rules** are conventions applied automatically:

- **Apply by path**: Activated according to the file path
- **Code conventions**: TypeScript, React, Flutter, etc.
- **Best practices**: Security, tests, API
- **Transparency**: Always visible in suggestions

## List of rules

| Rule | Description | Paths |
|------|-------------|-------|
| [`accessibility`](/docs/rules/accessibility) | IMPORTANT: Every image must have an alt attribute.... | `**/*.tsx`, `**/*.jsx`... |
| [`api`](/docs/rules/api) | // Error \{ "success": false, "error": \{ "code": "V... | `**/api/**`, `**/routes/**`... |
| [`astro`](/docs/rules/astro) | Astro renders **zero JS by default**. Components a... | `**/*.astro`, `**/astro.config.*`... |
| [`base-maintenance`](/docs/rules/base-maintenance) | Any addition, removal or rename in `.claude/` sile... | `.claude/skills/**`, `.claude/agents/**`... |
| [`csharp`](/docs/rules/csharp) | // 2. Private readonly fields private readonly IUs... | `**/*.cs`, `**/*.csproj`... |
| [`deploy-safety`](/docs/rules/deploy-safety) | Every deployment must be validated before executio... | `**/docker-compose*.yml`, `**/docker-compose*.yaml`... |
| [`design-style`](/docs/rules/design-style) | The project's design direction is defined in CLAUD... | `**/*.tsx`, `**/*.jsx`... |
| [`flutter`](/docs/rules/flutter) | // State abstract class AuthState \{\} class AuthIni... | `**/*.dart`, `**/lib/**`... |
| [`git`](/docs/rules/git) | [optional body - details on the "what" and "why"] | - |
| [`go`](/docs/rules/go) | // Custom errors var ErrUserNotFound = errors.New(... | `**/*.go`, `**/go.mod`... |
| [`java`](/docs/rules/java) | // 2. Static fields private static final Logger lo... | `**/*.java`, `**/pom.xml`... |
| [`lsp`](/docs/rules/lsp) | LSP available via `ENABLE_LSP_TOOL=1` or LSP plugi... | `**/*.ts`, `**/*.tsx`... |
| [`migration-safety`](/docs/rules/migration-safety) | Major framework or dependency migrations are risky... | `**/package.json`, `**/tsconfig.json`... |
| [`nextjs`](/docs/rules/nextjs) | Next.js Rules | `**/next.config.*`, `**/app/**`... |
| [`performance`](/docs/rules/performance) | IMPORTANT: LCP &lt; 2.5s - Optimize above-the-fold im... | `**/*.tsx`, `**/*.jsx`... |
| [`php`](/docs/rules/php) | declare(strict_types=1); | `**/*.php`, `**/composer.json` |
| [`python`](/docs/rules/python) | import requests from pydantic import BaseModel | `**/*.py`, `**/requirements*.txt`... |
| [`react`](/docs/rules/react) | export function MyComponent(\{ title, onAction \}: P... | `**/*.tsx`, `**/components/**`... |
| [`research`](/docs/rules/research) | Before implementing a custom solution, check wheth... | `**/*.ts`, `**/*.tsx`... |
| [`ruby`](/docs/rules/ruby) | users.each do |user| puts user.name puts user.emai... | `**/*.rb`, `**/Gemfile`... |
| [`rust`](/docs/rules/rust) | // 2. Constants const MAX_CONNECTIONS: usize = 100... | `**/*.rs`, `**/Cargo.toml` |
| [`security`](/docs/rules/security) | 3 attack vectors identified (Feb. 2026) when cloni... | `**/auth/**`, `**/api/**`... |
| [`service-worker`](/docs/rules/service-worker) | The SW must NEVER cache `request.mode === "navigat... | `**/sw.js`, `**/service-worker*`... |
| [`svelte`](/docs/rules/svelte) | Svelte 5+ uses **runes**: `$state`, `$derived`, `$... | `**/*.svelte`, `**/*.svelte.ts`... |
| [`tdd-enforcement`](/docs/rules/tdd-enforcement) | IMPORTANT: When the user asks to implement, add, c... | `**/*.ts`, `**/*.tsx`... |
| [`testing`](/docs/rules/testing) | // Act - Execute the action const result = functio... | `**/*.test.ts`, `**/*.test.tsx`... |
| [`typescript`](/docs/rules/typescript) | TypeScript Rules | `**/*.ts`, `**/*.tsx`... |
| [`verification`](/docs/rules/verification) | Any implementation must be verified BEFORE being c... | `**/*.ts`, `**/*.tsx`... |
| [`vue`](/docs/rules/vue) | const count = ref(0) const double = computed(() =>... | `**/*.vue`, `**/composables/**`... |
| [`workflow`](/docs/rules/workflow) | Before starting work on an existing project: | - |

## Categories

### Languages

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

### Practices

- [api](/docs/rules/api)
- [git](/docs/rules/git)
- [security](/docs/rules/security)
- [testing](/docs/rules/testing)
- [workflow](/docs/rules/workflow)

## How to add a custom rule

Create a file `.claude/rules/my-rule.md`:

```markdown
---
paths:
  - "**/my-folder/**"
  - "**/*.custom"
---

# My custom rules

- Rule 1
- Rule 2
```

---

## See also

- [Architecture](/docs/intro/architecture) - Understand the components
- [Commands](/docs/commands) - Manual commands
- [Skills](/docs/skills) - Auto-triggered skills
