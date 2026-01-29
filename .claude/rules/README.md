# Claude Code Rules

Regles modulaires appliquees automatiquement selon les fichiers modifies (path-specific rules).

## Regles disponibles (20)

| Regle | Paths cibles | Description |
|-------|-------------|-------------|
| `accessibility` | `**/*.tsx`, `**/*.jsx`, `**/components/**`, `**/pages/**` | WCAG 2.1 AA, aria, semantic HTML |
| `api` | `**/api/**`, `**/routes/**`, `**/controllers/**` | REST conventions, validation, status codes |
| `csharp` | `**/*.cs`, `**/*.csproj` | Nullable, async/await, .NET patterns |
| `flutter` | `**/*.dart`, `**/lib/**`, `**/test/**` | Clean Architecture, BLoC, widgets |
| `git` | _(global)_ | Conventional commits, branches, safety rules |
| `go` | `**/*.go`, `**/go.mod` | Error handling, interfaces, concurrency |
| `java` | `**/*.java`, `**/pom.xml`, `**/build.gradle` | Optional, Streams, Spring Boot |
| `nextjs` | `**/next.config.*`, `**/app/**`, `**/pages/**` | RSC, data fetching, caching, App Router |
| `performance` | `**/*.tsx`, `**/*.ts`, `**/pages/**` | Core Web Vitals, lazy loading, memoization |
| `php` | `**/*.php`, `**/composer.json` | PSR-12, Laravel, type declarations |
| `python` | `**/*.py`, `**/pyproject.toml` | Type hints, PEP 8, async patterns |
| `react` | `**/*.tsx`, `**/components/**`, `**/hooks/**` | Composants, hooks, performance |
| `ruby` | `**/*.rb`, `**/Gemfile` | Rails conventions, RSpec |
| `rust` | `**/*.rs`, `**/Cargo.toml` | Ownership, error handling, traits |
| `security` | `**/auth/**`, `**/api/**`, `**/middleware/**` | XSS, SQL injection, CSRF, auth |
| `tdd-enforcement` | `**/*.ts`, `**/*.tsx`, `**/*.dart`, `**/*.py`, `**/*.go`, ... | TDD proactif obligatoire pour tout code |
| `testing` | `**/*.test.ts`, `**/*.spec.ts`, `**/tests/**` | Couverture 80%, mocks, edge cases |
| `typescript` | `**/*.ts`, `**/*.tsx`, `**/*.mts` | Strict mode, no any, interfaces |
| `verification` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, ... | Verification 4 phases avant completion |
| `workflow` | _(global)_ | Explore → Plan → TDD → Commit |

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
