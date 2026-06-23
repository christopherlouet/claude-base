# Claude Code Rules

Modular rules applied automatically based on the modified files (path-specific rules).

## Available rules (32)

| Rule | Target paths | Description |
|------|-------------|-------------|
| `accessibility` | `**/*.tsx`, `**/*.jsx`, `**/components/**`, `**/pages/**` | WCAG 2.1 AA, aria, semantic HTML |
| `api` | `**/api/**`, `**/routes/**`, `**/controllers/**` | REST conventions, validation, status codes |
| `astro` | `**/*.astro`, `**/astro.config.*`, `**/content/**` | Islands architecture, client directives, Content Collections |
| `csharp` | `**/*.cs`, `**/*.csproj` | Nullable, async/await, .NET patterns |
| `deploy-safety` | `**/docker-compose*`, `**/Dockerfile*`, `**/deploy*`, `**/.env*`, `**/middleware.*`, `**/sw.js`, `**/layout.tsx` | Pre-deploy checklist, REVERT FIRST, high-risk files |
| `design-style` | `**/*.tsx`, `**/*.jsx`, `**/components/**`, `**/pages/**`, `**/app/**` | UI art direction (terminal, cockpit, vitality, editorial, glass, signal) |
| `flutter` | `**/*.dart`, `**/lib/**`, `**/test/**` | Clean Architecture, BLoC, widgets |
| `git` | _(global)_ | Conventional commits, branches, safety rules |
| `go` | `**/*.go`, `**/go.mod` | Error handling, interfaces, concurrency |
| `java` | `**/*.java`, `**/pom.xml`, `**/build.gradle` | Optional, Streams, Spring Boot |
| `lsp` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, `**/*.rs`, `**/*.java`, `**/*.cs`, `**/*.rb`, `**/*.php`, `**/*.kt`, `**/*.dart` | LSP vs Grep, semantic navigation, activation |
| `migration-safety` | `**/package.json`, `**/tsconfig.json`, `**/next.config.*`, `**/.eslintrc*`, `**/eslint.config.*`, `**/pyproject.toml`, `**/go.mod` | Framework migration checklist, caches |
| `nextjs` | `**/next.config.*`, `**/app/**`, `**/pages/**` | RSC, data fetching, caching, App Router |
| `performance` | `**/*.tsx`, `**/*.ts`, `**/pages/**` | Core Web Vitals, lazy loading, memoization |
| `php` | `**/*.php`, `**/composer.json` | PSR-12, Laravel, type declarations |
| `python` | `**/*.py`, `**/pyproject.toml` | Type hints, PEP 8, async patterns |
| `react` | `**/*.tsx`, `**/components/**`, `**/hooks/**` | Components, hooks, performance |
| `research` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, `**/*.dart`, `**/*.rs` | Minimal-code ladder (YAGNI → reuse → stdlib → native) before custom |
| `ruby` | `**/*.rb`, `**/Gemfile` | Rails conventions, RSpec |
| `rust` | `**/*.rs`, `**/Cargo.toml` | Ownership, error handling, traits |
| `security` | `**/auth/**`, `**/api/**`, `**/middleware/**` | XSS, SQL injection, CSRF, auth |
| `self-improvement` | _(global)_ | Personal cross-project lessons referential — human-gated capture + sanitize, stored in `~/.claude/rules/lessons.md` |
| `service-worker` | `**/sw.js`, `**/service-worker*` | NEVER cache HTML navigations, bump cache version |
| `base-maintenance` | `.claude/skills/**`, `.claude/agents/**`, `.claude/commands/**`, `.claude/rules/**`, `.claude/settings.json`, `scripts/hooks/**` | Sync counters, catalog, hook message when modifying the foundation |
| `svelte` | `**/*.svelte`, `**/*.svelte.ts`, `**/svelte.config.*` | Runes (Svelte 5), SvelteKit, form actions |
| `tdd-enforcement` | `**/*.ts`, `**/*.tsx`, `**/*.dart`, `**/*.py`, `**/*.go`, ... | Proactive TDD mandatory for all code |
| `testing` | `**/*.test.ts`, `**/*.spec.ts`, `**/tests/**` | 80% coverage, mocks, edge cases |
| `typescript` | `**/*.ts`, `**/*.tsx`, `**/*.mts` | Strict mode, no any, interfaces |
| `vendor-precedence` | _(global)_ | Foundation-vs-vendor & vendor-vs-vendor advice precedence (security/workflow = foundation; tool API = vendor) |
| `verification` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, ... | 4-phase verification before completion |
| `vue` | `**/*.vue`, `**/composables/**`, `**/stores/**`, `**/nuxt.config.*` | Composition API, Pinia, Nuxt 3+ |
| `workflow` | _(global)_ | Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit |

## Rule priority order

When a file matches several rules (e.g., `.tsx` activates typescript + react + accessibility + performance + verification + tdd-enforcement), all apply simultaneously. In case of conflict:

| Priority | Rule | Reason |
|----------|------|--------|
| 1 (max) | `security` | Security trumps everything |
| 2 | `verification` | Mandatory verification before completion |
| 3 | `tdd-enforcement` | TDD mandatory for all code |
| 4 | Language rules (`typescript`, `python`, `go`...) | Language-specific conventions |
| 5 | Framework rules (`react`, `nextjs`, `flutter`...) | Framework-specific conventions |
| 6 | `testing` | Test standards |
| 7 | `performance`, `accessibility`, `design-style` | Optimizations and best practices |
| 8 | `api`, `lsp` | Interface conventions |
| 9 | `research`, `deploy-safety`, `base-maintenance`, `vendor-precedence`, `self-improvement` | Process guardrails |

### Example: modifying `src/components/Button.tsx`

Activated rules: `typescript` + `react` + `accessibility` + `performance` + `design-style` + `verification` + `tdd-enforcement`

Resolution: security first, then verification, then TDD, then TypeScript conventions, then React, then accessibility, performance and design direction.

## How it works

Rules are activated automatically when a file matching the `paths` is modified. Global rules (without paths) always apply.

```yaml
---
paths:
  - "**/*.tsx"
  - "**/components/**"
---
# Rule content applied to these files
```
