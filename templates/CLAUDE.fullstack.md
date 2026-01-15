# Projet Fullstack (Monorepo)

## Commandes Essentielles
- `npm install` - Installer toutes les dépendances
- `npm run dev` - Démarrer frontend + backend
- `npm run dev:frontend` - Frontend uniquement
- `npm run dev:backend` - Backend uniquement
- `npm test` - Tous les tests
- `npm run test:frontend` - Tests frontend
- `npm run test:backend` - Tests backend
- `npm run build` - Build complet
- `npm run lint` - Lint tout le projet

## Structure Monorepo
```
/
├── packages/
│   ├── frontend/          # Application React/Vue/Angular
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── backend/           # API Node.js
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── shared/            # Code partagé (types, utils)
│       ├── src/
│       └── package.json
├── package.json           # Workspaces root
└── turbo.json            # Config Turborepo (si utilisé)
```

## Conventions Monorepo
- IMPORTANT: Types partagés dans `packages/shared`
- IMPORTANT: Ne pas dupliquer de code entre frontend et backend
- YOU MUST maintenir la cohérence des versions de dépendances
- Utiliser les workspaces npm/yarn/pnpm

## Communication Frontend ↔ Backend

### Types partagés (packages/shared)
```typescript
// packages/shared/src/types/api.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: { code: string; message: string };
}
```

### Contrats d'API
- Définir les types de requête/réponse dans shared
- Frontend et backend importent les mêmes types
- Validation côté backend, typage côté frontend

## Tests
- Tests unitaires dans chaque package
- Tests E2E au niveau root (Playwright/Cypress)
- Tests d'intégration API dans backend

## Base de données
- Migrations dans backend
- Prisma/TypeORM avec types exportés vers shared

## Variables d'environnement
- `.env` à la racine pour variables globales
- `.env` dans chaque package pour variables spécifiques
- IMPORTANT: Ne jamais commiter les `.env`

## Git & Commits
- Format: `type(scope): description`
- Scopes: `frontend`, `backend`, `shared`, `infra`
- Un commit peut toucher plusieurs packages si cohérent

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Prettier sur les fichiers TS/JS modifiés |
| Type check | PostToolUse | TypeScript après édition |
| ESLint check | PostToolUse | Validation ESLint après édition |
| Test avant commit | PreToolUse | Exécute `npm test` avant chaque commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyser un codebase existant |
| `planning-implementation` | Définir un plan avant de coder |
| `test-driven-development` | Cycle TDD Red-Green-Refactor |
| `reviewing-code` | Revue de code approfondie |
| `debugging-issues` | Diagnostic méthodique |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | PR complète et documentée |
