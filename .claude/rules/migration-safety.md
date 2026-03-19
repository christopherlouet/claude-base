---
paths:
  - "**/package.json"
  - "**/tsconfig.json"
  - "**/next.config.*"
  - "**/.eslintrc*"
  - "**/eslint.config.*"
  - "**/pyproject.toml"
  - "**/go.mod"
  - "**/pubspec.yaml"
  - "**/Cargo.toml"
  - "**/Gemfile"
---

# Migration Safety

## Principe

Les migrations majeures de framework ou dependances sont risquees. Toujours suivre un processus structure pour eviter les cascades de CI failures.

## Checklist migration obligatoire

| Etape | Action | Bloquant |
|-------|--------|----------|
| 1 | Lire le guide de migration officiel du framework | Oui |
| 2 | Lister les breaking changes qui impactent le projet | Oui |
| 3 | Creer une branche dediee (`refactor/migrate-xxx`) | Oui |
| 4 | Sauvegarder l'etat CI actuel (noter les erreurs pre-existantes) | Oui |
| 5 | Migrer une dependance a la fois, pas tout d'un coup | Oui |
| 6 | Lancer lint + type-check + tests apres chaque changement | Oui |
| 7 | Vider les caches si necessaire | Oui |
| 8 | Commit atomique par etape de migration | Oui |

## Migrations courantes et pieges

| Migration | Piege connu | Solution |
|-----------|------------|----------|
| ESLint 8 → 9 | Flat config incompatible avec ancien format | Convertir `.eslintrc` → `eslint.config.js` |
| Next.js 14 → 15/16 | Turbopack cache corruption | Supprimer `.next/` apres migration |
| Prisma upgrade | Migrations en conflit | `prisma migrate status` avant `prisma migrate deploy` |
| React 18 → 19 | APIs deprecated | Verifier `StrictMode` et hooks |
| TypeScript 4 → 5 | Nouveaux checks strict | Activer les checks un par un |
| Python 3.x → 3.y | Syntax/API changes | Verifier `pyproject.toml` python-requires |

## Caches a vider apres migration

| Stack | Commande |
|-------|----------|
| Next.js / Turbopack | `rm -rf .next/` |
| Webpack | `rm -rf node_modules/.cache/` |
| TypeScript | `rm -rf tsconfig.tsbuildinfo` |
| Prisma | `npx prisma generate` |
| Python | `find . -type d -name __pycache__ -exec rm -rf {} +` |
| Go | `go clean -cache` |
| Rust | `cargo clean` |
| Flutter | `flutter clean` |

## Regles

IMPORTANT: Ne JAMAIS migrer plusieurs dependances majeures en meme temps. Une migration a la fois.

IMPORTANT: Toujours lire le guide de migration officiel AVANT de commencer.

IMPORTANT: Vider les caches du bundler/compiler apres chaque migration majeure.

NEVER ignorer les breaking changes listes dans le changelog de la nouvelle version.

NEVER migrer sans branche dediee — toujours pouvoir revenir en arriere.
