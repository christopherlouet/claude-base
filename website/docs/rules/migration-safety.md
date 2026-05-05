---
sidebar_position: 14
title: "migration-safety"
description: "Major framework or dependency migrations are risky. Always follow a structured process to avoid cascades of CI failures."
tags:
  - "rule"
  - "migration-safety"
---

# Rules: migration-safety

> Major framework or dependency migrations are risky. Always follow a structured process to avoid cascades of CI failures.

## Affected files

These rules apply to files matching the following patterns:

- `**/package.json`
- `**/tsconfig.json`
- `**/next.config.*`
- `**/.eslintrc*`
- `**/eslint.config.*`
- `**/pyproject.toml`
- `**/go.mod`
- `**/pubspec.yaml`
- `**/Cargo.toml`
- `**/Gemfile`

## Detailed rules

# Migration Safety

## Principle

Major framework or dependency migrations are risky. Always follow a structured process to avoid cascades of CI failures.

## Mandatory migration checklist

| Step | Action | Blocking |
|-------|--------|----------|
| 1 | Read the framework's official migration guide | Yes |
| 2 | List the breaking changes that impact the project | Yes |
| 3 | Create a dedicated branch (`refactor/migrate-xxx`) | Yes |
| 4 | Save the current CI state (note pre-existing errors) | Yes |
| 5 | Migrate one dependency at a time, not all at once | Yes |
| 6 | Run lint + type-check + tests after each change | Yes |
| 7 | Clear caches if necessary | Yes |
| 8 | Atomic commit per migration step | Yes |

## Common migrations and pitfalls

| Migration | Known pitfall | Solution |
|-----------|------------|----------|
| ESLint 8 → 9 | Flat config incompatible with old format | Convert `.eslintrc` → `eslint.config.js` |
| Next.js 14 → 15/16 | Turbopack cache corruption | Delete `.next/` after migration |
| Prisma upgrade | Conflicting migrations | `prisma migrate status` before `prisma migrate deploy` |
| React 18 → 19 | Deprecated APIs | Check `StrictMode` and hooks |
| TypeScript 4 → 5 | New strict checks | Enable checks one by one |
| Python 3.x → 3.y | Syntax/API changes | Check `pyproject.toml` python-requires |

## Caches to clear after migration

| Stack | Command |
|-------|----------|
| Next.js / Turbopack | `rm -rf .next/` |
| Webpack | `rm -rf node_modules/.cache/` |
| TypeScript | `rm -rf tsconfig.tsbuildinfo` |
| Prisma | `npx prisma generate` |
| Python | `find . -type d -name __pycache__ -exec rm -rf {} +` |
| Go | `go clean -cache` |
| Rust | `cargo clean` |
| Flutter | `flutter clean` |

## Rules

IMPORTANT: NEVER migrate multiple major dependencies at the same time. One migration at a time.

IMPORTANT: Always read the official migration guide BEFORE starting.

IMPORTANT: Clear bundler/compiler caches after each major migration.

NEVER ignore the breaking changes listed in the new version's changelog.

NEVER migrate without a dedicated branch — always be able to roll back.

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
