# Agent QA-AUTOMATION

Mettre en place une stratégie d'automatisation des tests complète.

## Contexte
$ARGUMENTS

## Objectif

Automatiser les tests à tous les niveaux (unitaires, intégration, E2E)
pour garantir la qualité et accélérer les cycles de release.

## Pyramide d'automatisation

```
┌─────────────────────────────────────────────────────────────┐
│                    TEST AUTOMATION PYRAMID                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                         /\                                  │
│                        /  \                                 │
│                       / E2E\        5-10% - Lents, fragiles │
│                      /──────\                               │
│                     /        \                              │
│                    /Integration\    15-25% - Modérés        │
│                   /──────────────\                          │
│                  /                \                         │
│                 /   Unit Tests     \  70-80% - Rapides      │
│                /────────────────────\                       │
│                                                             │
│  ANTI-PATTERN: "Ice Cream Cone" (trop d'E2E, peu d'unitaires)│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Stratégie par niveau

### Tests unitaires (70-80%)

| Framework | Langage | Usage recommandé |
|-----------|---------|------------------|
| **Vitest** | JS/TS | Nouveau projet |
| **Jest** | JS/TS | Projet existant |
| **Pytest** | Python | Tout projet Python |
| **JUnit 5** | Java | Tout projet Java |
| **Go test** | Go | Tout projet Go |

#### Configuration Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      thresholds: {
        lines: 80,
        branches: 80,
        functions: 80,
        statements: 80,
      },
      exclude: [
        'node_modules/**',
        '**/*.d.ts',
        '**/*.config.*',
        '**/index.ts',
      ],
    },
    include: ['src/**/*.{test,spec}.{js,ts}'],
  },
});
```

### Tests d'intégration (15-25%)

#### API Testing avec Supertest

```typescript
// tests/integration/api.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { setupTestDB, teardownTestDB } from '../helpers/db';

describe('Users API', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await teardownTestDB();
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'test@example.com',
          name: 'Test User',
        })
        .expect(201);

      expect(response.body).toMatchObject({
        email: 'test@example.com',
        name: 'Test User',
      });
      expect(response.body.id).toBeDefined();
    });

    it('should return 400 for invalid email', async () => {
      await request(app)
        .post('/api/users')
        .send({
          email: 'invalid',
          name: 'Test User',
        })
        .expect(400);
    });
  });
});
```

#### Database Testing

```typescript
// tests/integration/repositories/user.repository.test.ts
import { UserRepository } from '../../../src/repositories/user.repository';
import { TestDatabase } from '../../helpers/test-database';

describe('UserRepository', () => {
  let db: TestDatabase;
  let repository: UserRepository;

  beforeEach(async () => {
    db = new TestDatabase();
    await db.setup();
    repository = new UserRepository(db.connection);
  });

  afterEach(async () => {
    await db.teardown();
  });

  it('should find user by email', async () => {
    // Arrange
    await db.seed('users', [
      { id: '1', email: 'john@example.com', name: 'John' },
    ]);

    // Act
    const user = await repository.findByEmail('john@example.com');

    // Assert
    expect(user).toMatchObject({
      id: '1',
      email: 'john@example.com',
    });
  });
});
```

### Tests E2E (5-10%)

#### Playwright (recommandé)

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['junit', { outputFile: 'test-results/e2e-results.xml' }],
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 13'] },
    },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

#### Tests Playwright

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="submit"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome"]')).toContainText('Welcome');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email"]', 'wrong@example.com');
    await page.fill('[data-testid="password"]', 'wrongpassword');
    await page.click('[data-testid="submit"]');

    await expect(page.locator('[data-testid="error"]')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

## Mocking et Test Doubles

### MSW (Mock Service Worker)

```typescript
// tests/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'John', email: 'john@example.com' },
      { id: '2', name: 'Jane', email: 'jane@example.com' },
    ]);
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: '3', ...body },
      { status: 201 }
    );
  }),

  http.get('/api/users/:id', ({ params }) => {
    const { id } = params;
    if (id === '404') {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }
    return HttpResponse.json({ id, name: 'User', email: 'user@example.com' });
  }),
];
```

```typescript
// tests/setup.ts
import { setupServer } from 'msw/node';
import { handlers } from './mocks/handlers';

export const server = setupServer(...handlers);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Test Containers

```typescript
// tests/helpers/test-database.ts
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';

let container: StartedPostgreSqlContainer;

export async function setupTestDB() {
  container = await new PostgreSqlContainer()
    .withDatabase('test')
    .withUsername('test')
    .withPassword('test')
    .start();

  process.env.DATABASE_URL = container.getConnectionUri();

  // Run migrations
  await runMigrations();
}

export async function teardownTestDB() {
  await container.stop();
}
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}  # Use GitHub Secrets in production
          POSTGRES_DB: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/test

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Parallel Test Execution

```yaml
# .github/workflows/parallel-e2e.yml
name: E2E Tests (Parallel)

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test --shard=${{ matrix.shard }}/4

      - uses: actions/upload-artifact@v4
        with:
          name: blob-report-${{ matrix.shard }}
          path: blob-report
          retention-days: 1

  merge-reports:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - uses: actions/download-artifact@v4
        with:
          pattern: blob-report-*
          merge-multiple: true
          path: all-blob-reports

      - run: npx playwright merge-reports --reporter html ./all-blob-reports

      - uses: actions/upload-artifact@v4
        with:
          name: html-report
          path: playwright-report
          retention-days: 14
```

## Visual Regression Testing

### Percy Integration

```typescript
// tests/e2e/visual.spec.ts
import { test } from '@playwright/test';
import percySnapshot from '@percy/playwright';

test.describe('Visual Regression', () => {
  test('homepage visual test', async ({ page }) => {
    await page.goto('/');
    await percySnapshot(page, 'Homepage');
  });

  test('dashboard visual test', async ({ page }) => {
    // Login first
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password');
    await page.click('[data-testid="submit"]');

    await page.waitForURL('/dashboard');
    await percySnapshot(page, 'Dashboard');
  });
});
```

## Métriques et Reporting

### Dashboard de tests

| Métrique | Cible | Fréquence |
|----------|-------|-----------|
| Couverture de code | > 80% | Chaque PR |
| Tests passants | 100% | Chaque PR |
| Temps d'exécution | < 10 min | Chaque PR |
| Flaky tests | 0 | Hebdomadaire |
| Tests E2E critiques | 100% pass | Quotidien |

### Configuration des rapports

```json
{
  "scripts": {
    "test": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:integration": "vitest run --config vitest.integration.config.ts",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:report": "playwright show-report"
  }
}
```

## Checklist d'automatisation

### Setup initial
- [ ] Framework de test unitaire configuré
- [ ] Couverture de code activée
- [ ] MSW configuré pour les mocks API
- [ ] Playwright configuré pour E2E

### CI/CD
- [ ] Tests unitaires dans le pipeline
- [ ] Tests d'intégration avec services
- [ ] Tests E2E avec artifacts
- [ ] Rapport de couverture publié

### Maintenance
- [ ] Flaky tests identifiés et corrigés
- [ ] Tests lents optimisés
- [ ] Mocks à jour avec l'API
- [ ] Data-testid cohérents

## Agents liés

| Agent | Usage |
|-------|-------|
| `/dev-testing-setup` | Configuration initiale |
| `/dev-tdd` | Développement TDD |
| `/ops-ci` | Pipeline CI/CD |
| `/perf` | Tests de performance |

---

IMPORTANT: Maintenir la pyramide de tests - plus de tests unitaires que d'E2E.

YOU MUST utiliser des data-testid stables pour les tests E2E.

NEVER avoir de tests interdépendants - chaque test doit être isolé.

NEVER ignorer les flaky tests - les corriger immédiatement.

Think hard sur le ratio effort/valeur avant d'automatiser un scénario.
