# Agent DEV-TESTING-SETUP

Configure l'infrastructure de tests pour un projet.

## Contexte
$ARGUMENTS

## Objectif

Mettre en place une stratégie de tests complète : frameworks, configuration,
couverture, CI/CD et bonnes pratiques.

## Pyramide de tests

```
                    /\
                   /  \
                  / E2E\        ← Peu, lents, fragiles
                 /──────\
                /        \
               /Integration\    ← Modérés
              /──────────────\
             /                \
            /    Unit Tests    \  ← Beaucoup, rapides, stables
           /────────────────────\
```

## Étape 1 : Choix du framework

### Comparatif des frameworks

| Framework | Langages | Forces | Faiblesses |
|-----------|----------|--------|------------|
| **Jest** | JS/TS | Tout-en-un, snapshots, mocks | Lent sur gros projets |
| **Vitest** | JS/TS | Rapide, compatible Jest | Plus récent |
| **Mocha** | JS/TS | Flexible, mature | Config manuelle |
| **Pytest** | Python | Fixtures, plugins | Python only |
| **JUnit** | Java | Standard, IDE support | Verbeux |
| **Go test** | Go | Built-in, rapide | Basique |

### Recommandations par stack

| Stack | Framework recommandé |
|-------|---------------------|
| React/Next.js | Vitest + Testing Library |
| Vue/Nuxt | Vitest + Vue Test Utils |
| Node.js API | Jest ou Vitest |
| Python | Pytest |
| Go | Go test + Testify |
| Java/Spring | JUnit 5 + Mockito |

## Étape 2 : Installation et configuration

### JavaScript/TypeScript (Vitest)

```bash
# Installation
npm install -D vitest @vitest/coverage-v8 @vitest/ui

# Pour React
npm install -D @testing-library/react @testing-library/jest-dom

# Pour Vue
npm install -D @vue/test-utils
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom', // ou 'node' pour backend
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/index.ts',
      ],
      thresholds: {
        lines: 80,
        branches: 80,
        functions: 80,
        statements: 80,
      },
    },
    include: ['src/**/*.{test,spec}.{js,ts,jsx,tsx}'],
    setupFiles: ['./src/test/setup.ts'],
  },
});
```

### Python (Pytest)

```bash
pip install pytest pytest-cov pytest-asyncio
```

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts = -v --cov=src --cov-report=html --cov-fail-under=80
asyncio_mode = auto
```

### Go

```go
// Pas d'installation nécessaire, go test est built-in
// Optionnel : testify pour assertions
go get github.com/stretchr/testify
```

## Étape 3 : Structure des tests

### Organisation recommandée

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx      ← Tests co-localisés
│   │   └── Button.stories.tsx
│   └── ...
├── services/
│   ├── auth.ts
│   └── auth.test.ts
├── utils/
│   ├── validation.ts
│   └── validation.test.ts
└── test/
    ├── setup.ts                  ← Setup global
    ├── mocks/                    ← Mocks partagés
    │   └── handlers.ts
    └── fixtures/                 ← Données de test
        └── users.ts
```

### Alternative : dossier __tests__

```
src/
├── components/
│   └── Button.tsx
├── __tests__/
│   ├── components/
│   │   └── Button.test.tsx
│   └── services/
│       └── auth.test.ts
└── ...
```

## Étape 4 : Configuration de la couverture

### Seuils recommandés

| Type de code | Couverture min |
|--------------|----------------|
| Nouveau code | 80% |
| Code critique (auth, paiement) | 90% |
| Utils/Helpers | 100% |
| UI Components | 70% |

### Configuration CI

```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: npm run test:coverage

- name: Check coverage thresholds
  run: |
    COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage is below 80%: $COVERAGE%"
      exit 1
    fi
```

## Étape 5 : Mocking

### Stratégies de mocking

| Quoi mocker | Comment |
|-------------|---------|
| API externes | MSW (Mock Service Worker) |
| Base de données | Fixtures / In-memory DB |
| Filesystem | memfs ou mocks manuels |
| Date/Time | Fake timers |
| Modules | vi.mock() / jest.mock() |

### MSW pour les API

```typescript
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' },
    ]);
  }),

  http.post('/api/login', async ({ request }) => {
    const body = await request.json();
    if (body.email === 'test@test.com') {
      return HttpResponse.json({ token: 'fake-token' });
    }
    return HttpResponse.json({ error: 'Invalid credentials' }, { status: 401 });
  }),
];
```

```typescript
// src/test/setup.ts
import { setupServer } from 'msw/node';
import { handlers } from './mocks/handlers';

export const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Étape 6 : Scripts npm

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "test:ci": "vitest run --coverage --reporter=junit --outputFile=test-results.xml"
  }
}
```

## Étape 7 : Intégration CI/CD

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run test:ci

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Étape 8 : Bonnes pratiques

### Structure d'un test

```typescript
describe('UserService', () => {
  // Setup commun
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
  });

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { name: 'John', email: 'john@test.com' };

      // Act
      const user = await service.createUser(userData);

      // Assert
      expect(user.id).toBeDefined();
      expect(user.name).toBe('John');
    });

    it('should throw when email is invalid', async () => {
      // Arrange
      const userData = { name: 'John', email: 'invalid' };

      // Act & Assert
      await expect(service.createUser(userData))
        .rejects
        .toThrow('Invalid email');
    });
  });
});
```

### Anti-patterns à éviter

| ❌ Anti-pattern | ✅ Alternative |
|-----------------|----------------|
| Tests interdépendants | Tests isolés |
| Assertions multiples non liées | Une assertion par concept |
| Mocks excessifs | Mocks uniquement pour I/O |
| Tests de l'implémentation | Tests du comportement |
| Données magiques | Fixtures explicites |

## Output attendu

### Fichiers générés

```
project/
├── vitest.config.ts        # Configuration Vitest
├── src/
│   └── test/
│       ├── setup.ts        # Setup global
│       ├── mocks/
│       │   └── handlers.ts # MSW handlers
│       └── fixtures/
│           └── index.ts    # Données de test
├── .github/
│   └── workflows/
│       └── test.yml        # CI workflow
└── package.json            # Scripts mis à jour
```

### Checklist

- [ ] Framework de test installé et configuré
- [ ] Couverture de code configurée (seuil 80%)
- [ ] MSW configuré pour les API mocks
- [ ] Scripts npm ajoutés
- [ ] CI/CD configuré
- [ ] Documentation des conventions de test

## Agents liés

| Agent | Usage |
|-------|-------|
| `/dev-tdd` | Développer en TDD |
| `/dev-test` | Générer des tests |
| `/ops-ci` | Configuration CI/CD |
| `/qa-automation` | Automatisation des tests |

---

IMPORTANT: Toujours configurer des seuils de couverture pour le nouveau code.

YOU MUST utiliser MSW plutôt que des mocks manuels pour les API.

NEVER mocker ce qui peut être testé en réel (pure functions, utils).

Think hard sur la stratégie de test avant de configurer.
