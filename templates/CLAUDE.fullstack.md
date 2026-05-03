# Fullstack Project (Monorepo)

## Essential Commands
- `npm install` - Install all dependencies
- `npm run dev` - Start frontend + backend
- `npm run dev:frontend` - Frontend only
- `npm run dev:backend` - Backend only
- `npm test` - All tests
- `npm run test:frontend` - Frontend tests
- `npm run test:backend` - Backend tests
- `npm run build` - Full build
- `npm run lint` - Lint the entire project

## Monorepo Structure
```
/
├── packages/
│   ├── frontend/          # React/Vue/Angular application
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── backend/           # Node.js API
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── shared/            # Shared code (types, utils)
│       ├── src/
│       └── package.json
├── package.json           # Workspaces root
└── turbo.json            # Turborepo config (if used)
```

## Monorepo Conventions
- IMPORTANT: Shared types in `packages/shared`
- IMPORTANT: Do not duplicate code between frontend and backend
- YOU MUST keep dependency versions consistent
- Use npm/yarn/pnpm workspaces

## Frontend ↔ Backend Communication

### Shared types (packages/shared)
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

### API contracts
- Define request/response types in shared
- Frontend and backend import the same types
- Backend-side validation, frontend-side typing

## Tests
- Unit tests in each package
- E2E tests at the root level (Playwright/Cypress)
- API integration tests in backend

## Database
- Migrations in backend
- Prisma/TypeORM with types exported to shared

## Environment variables
- `.env` at the root for global variables
- `.env` in each package for specific variables
- IMPORTANT: Never commit `.env` files

## Git & Commits
- Format: `type(scope): description`
- Scopes: `frontend`, `backend`, `shared`, `infra`
- A commit can touch multiple packages if consistent

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Prettier on modified TS/JS files |
| Type check | PostToolUse | TypeScript after edit |
| ESLint check | PostToolUse | ESLint validation after edit |
| Test before commit | PreToolUse | Runs `npm test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available Skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | TDD Red-Green-Refactor cycle |
| `reviewing-code` | In-depth code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |
