# Claude Code Rules

Regles modulaires appliquees automatiquement selon les fichiers modifies (path-specific rules).

## Regles disponibles (30)

| Regle | Paths cibles | Description |
|-------|-------------|-------------|
| `accessibility` | `**/*.tsx`, `**/*.jsx`, `**/components/**`, `**/pages/**` | WCAG 2.1 AA, aria, semantic HTML |
| `api` | `**/api/**`, `**/routes/**`, `**/controllers/**` | REST conventions, validation, status codes |
| `astro` | `**/*.astro`, `**/astro.config.*`, `**/content/**` | Islands architecture, client directives, Content Collections |
| `csharp` | `**/*.cs`, `**/*.csproj` | Nullable, async/await, .NET patterns |
| `deploy-safety` | `**/docker-compose*`, `**/Dockerfile*`, `**/deploy*`, `**/.env*`, `**/middleware.*`, `**/sw.js`, `**/layout.tsx` | Checklist pre-deploy, REVERT FIRST, high-risk files |
| `design-style` | `**/*.tsx`, `**/*.jsx`, `**/components/**`, `**/pages/**`, `**/app/**` | Direction artistique UI (terminal, cockpit, vitality, editorial, glass, signal) |
| `flutter` | `**/*.dart`, `**/lib/**`, `**/test/**` | Clean Architecture, BLoC, widgets |
| `git` | _(global)_ | Conventional commits, branches, safety rules |
| `go` | `**/*.go`, `**/go.mod` | Error handling, interfaces, concurrency |
| `java` | `**/*.java`, `**/pom.xml`, `**/build.gradle` | Optional, Streams, Spring Boot |
| `lsp` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, `**/*.rs`, `**/*.java`, `**/*.cs`, `**/*.rb`, `**/*.php`, `**/*.kt`, `**/*.dart` | LSP vs Grep, navigation semantique, activation |
| `migration-safety` | `**/package.json`, `**/tsconfig.json`, `**/next.config.*`, `**/.eslintrc*`, `**/eslint.config.*`, `**/pyproject.toml`, `**/go.mod` | Checklist migration framework, caches |
| `nextjs` | `**/next.config.*`, `**/app/**`, `**/pages/**` | RSC, data fetching, caching, App Router |
| `performance` | `**/*.tsx`, `**/*.ts`, `**/pages/**` | Core Web Vitals, lazy loading, memoization |
| `php` | `**/*.php`, `**/composer.json` | PSR-12, Laravel, type declarations |
| `python` | `**/*.py`, `**/pyproject.toml` | Type hints, PEP 8, async patterns |
| `react` | `**/*.tsx`, `**/components/**`, `**/hooks/**` | Composants, hooks, performance |
| `research` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, `**/*.dart`, `**/*.rs` | Verifier natif avant build custom |
| `ruby` | `**/*.rb`, `**/Gemfile` | Rails conventions, RSpec |
| `rust` | `**/*.rs`, `**/Cargo.toml` | Ownership, error handling, traits |
| `security` | `**/auth/**`, `**/api/**`, `**/middleware/**` | XSS, SQL injection, CSRF, auth |
| `service-worker` | `**/sw.js`, `**/service-worker*` | NEVER cache HTML navigations, bump cache version |
| `socle-maintenance` | `.claude/skills/**`, `.claude/agents/**`, `.claude/commands/**`, `.claude/rules/**`, `.claude/settings.json`, `scripts/hooks/**` | Sync compteurs, catalog, hook message quand on modifie le socle |
| `svelte` | `**/*.svelte`, `**/*.svelte.ts`, `**/svelte.config.*` | Runes (Svelte 5), SvelteKit, form actions |
| `tdd-enforcement` | `**/*.ts`, `**/*.tsx`, `**/*.dart`, `**/*.py`, `**/*.go`, ... | TDD proactif obligatoire pour tout code |
| `testing` | `**/*.test.ts`, `**/*.spec.ts`, `**/tests/**` | Couverture 80%, mocks, edge cases |
| `typescript` | `**/*.ts`, `**/*.tsx`, `**/*.mts` | Strict mode, no any, interfaces |
| `verification` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, ... | Verification 4 phases avant completion |
| `vue` | `**/*.vue`, `**/composables/**`, `**/stores/**`, `**/nuxt.config.*` | Composition API, Pinia, Nuxt 3+ |
| `workflow` | _(global)_ | Explore → Plan → TDD → Commit |

## Ordre de priorité des rules

Quand un fichier correspond à plusieurs rules (ex: `.tsx` active typescript + react + accessibility + performance + verification + tdd-enforcement), toutes s'appliquent simultanément. En cas de conflit:

| Priorité | Rule | Raison |
|----------|------|--------|
| 1 (max) | `security` | La sécurité prime sur tout |
| 2 | `verification` | Vérification obligatoire avant completion |
| 3 | `tdd-enforcement` | TDD obligatoire pour tout code |
| 4 | Rules de langage (`typescript`, `python`, `go`...) | Conventions spécifiques au langage |
| 5 | Rules de framework (`react`, `nextjs`, `flutter`...) | Conventions spécifiques au framework |
| 6 | `testing` | Normes de tests |
| 7 | `performance`, `accessibility`, `design-style` | Optimisations et bonnes pratiques |
| 8 | `api`, `lsp` | Conventions d'interface |
| 9 | `research`, `deploy-safety`, `socle-maintenance` | Garde-fous process |

### Exemple: modification de `src/components/Button.tsx`

Rules activées: `typescript` + `react` + `accessibility` + `performance` + `design-style` + `verification` + `tdd-enforcement`

Résolution: sécurité d'abord, puis vérification, puis TDD, puis conventions TypeScript, puis React, puis accessibilité, performance et direction design.

## Fonctionnement

Les regles sont activees automatiquement quand un fichier correspondant aux `paths` est modifie. Les regles globales (sans paths) s'appliquent toujours.

```yaml
---
paths:
  - "**/*.tsx"
  - "**/components/**"
---
# Contenu de la regle applique a ces fichiers
```
