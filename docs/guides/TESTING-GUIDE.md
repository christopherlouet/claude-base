# Guide Strategie de Tests

> Couverture complete, tests maintenables, confiance maximale dans le code

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Unit / Integration (JS/TS) | Jest, Vitest |
| Unit / Integration (Python) | pytest |
| Unit / Integration (Go) | testing, testify |
| E2E | Playwright, Cypress |
| Composants React | React Testing Library |
| Property-based | fast-check (TS), Hypothesis (Python) |
| Contract | Pact |
| Mutation | Stryker |

## Workflow Recommande

```
/work:work-explore → /dev:dev-tdd → /qa:qa-coverage → /qa:qa-loop "score 90"
```

---

## La Pyramide des Tests

```
                    /\
                   /  \
                  / E2E \          10%  Lents, couteux, fragiles
                 /--------\
                /          \
               / Integration \     20%  Moderement rapides
              /--------------\
             /                \
            /   Tests Unitaires \  70%  Rapides, precis, stables
           /____________________\
```

### Proprietes par niveau

| Niveau | Portee | Vitesse | Cout | Quand l'utiliser |
|--------|--------|---------|------|-----------------|
| **Unit** | Une fonction, une classe | < 10ms | Tres faible | Logique metier, transformations, calculs, edge cases |
| **Integration** | Module + dependances reelles | 100ms - 2s | Modere | Endpoints API, requetes DB, interactions entre couches |
| **E2E** | Parcours utilisateur complet | 5s - 30s | Eleve | Tunnels critiques (inscription, paiement, core flow) |

### Matrice de decision : que tester a quel niveau

| Ce que vous testez | Niveau recommande |
|-------------------|------------------|
| Algorithme, calcul, transformation | Unit |
| Validation d'entree / regles metier | Unit |
| Interaction entre service et repository | Integration |
| Endpoint HTTP avec base de donnees | Integration |
| Composant UI isole | Component test |
| Parcours utilisateur de bout en bout | E2E |
| Service externe (API tierce) | Contract test |
| Donnees aleatoires / proprietes invariantes | Property-based |

---

## Quand Tester Quoi

| Type de code | Type de test | Justification |
|-------------|-------------|---------------|
| Fonctions pures | Unit | Deterministe, rapide, zero setup |
| Endpoints API | Integration | Valide routing, validation, persistance |
| Flux utilisateur | E2E | Valide l'experience complete |
| Transformations de donnees | Property-based | Verifie les invariants sur un grand nombre de cas |
| Services externes | Contract | Garantit la compatibilite sans appel reseau |
| Composants UI | Component + snapshot | Verifie le rendu et le comportement |
| Logique d'autorisation | Unit + Integration | Securite critique, multi-niveaux |
| Migrations de base de donnees | Integration | Verifie les effets sur le schema et les donnees |

---

## Tests Unitaires

### Pattern AAA (Arrange-Act-Assert)

Chaque test unitaire suit trois phases distinctes et toujours dans cet ordre.

```typescript
describe('calculateDiscount', () => {
  describe('when applying percentage discount', () => {
    it('should return discounted price for valid percentage', () => {
      // Arrange
      const price = 100;
      const discountPercent = 20;

      // Act
      const result = calculateDiscount(price, discountPercent);

      // Assert
      expect(result).toBe(80);
    });

    it('should return original price when discount is zero', () => {
      // Arrange
      const price = 50;

      // Act
      const result = calculateDiscount(price, 0);

      // Assert
      expect(result).toBe(50);
    });

    it('should throw when price is negative', () => {
      expect(() => calculateDiscount(-10, 20)).toThrow('Price must be positive');
    });

    it('should throw when discount exceeds 100%', () => {
      expect(() => calculateDiscount(100, 110)).toThrow('Discount cannot exceed 100%');
    });
  });
});
```

### Nommage des tests

Le nom d'un test doit etre lisible comme une phrase :

```
should [comportement attendu] when [condition]
```

Exemples :
- `should return empty array when input is null`
- `should throw AuthError when token is expired`
- `should trim whitespace when parsing username`

### Quand mocker ou non

| Situation | Approche | Pourquoi |
|-----------|----------|----------|
| Dependance externe (API HTTP) | Mocker | Lenteur, indisponibilite, cout |
| Dependance externe (base de donnees) | Mocker (unit) ou reelle (integration) | Vitesse en unit, fidelite en integration |
| Module interne du projet | Ne pas mocker | Tester le comportement reel |
| Service metier isole | Ne pas mocker | Le test serait vide de sens |
| Horloge systeme (`Date.now`) | Mocker | Determinisme |
| Generateur aleatoire | Mocker avec seed | Determinisme |

### Strategies de mocking

**1. Mock manuel (simple, explicite)**

```typescript
const mockEmailService = {
  send: jest.fn().mockResolvedValue({ success: true }),
};
```

**2. jest.mock (automatique)**

```typescript
jest.mock('../services/email', () => ({
  sendEmail: jest.fn().mockResolvedValue({ sent: true }),
}));
```

**3. Injection de dependances (prefere pour la maintenabilite)**

```typescript
// Production
class OrderService {
  constructor(private readonly notifier: Notifier) {}

  async create(order: OrderInput): Promise<Order> {
    const saved = await this.repo.save(order);
    await this.notifier.notify(saved);
    return saved;
  }
}

// Test : injection d'un stub
const stubNotifier: Notifier = { notify: jest.fn() };
const service = new OrderService(stubNotifier);
```

---

## Tests d'Integration

### Principes d'isolation

Chaque test d'integration doit laisser la base de donnees dans un etat propre. Trois strategies :

| Strategie | Outil | Quand l'utiliser |
|-----------|-------|-----------------|
| Rollback de transaction | Prisma, Sequelize, SQLAlchemy | Tests rapides, schema stable |
| Base SQLite en memoire | SQLite `:memory:` | Schemas simples, pas de specifiques DB |
| Conteneur isole | Testcontainers | Tests fideles au moteur de production |

### Test d'endpoint API avec base de donnees

```typescript
import { app } from '../app';
import request from 'supertest';
import { db } from '../db';

beforeEach(async () => {
  await db.migrate.latest();
  await db.seed.run();
});

afterEach(async () => {
  await db.migrate.rollback();
});

describe('POST /api/orders', () => {
  it('should create order and return 201', async () => {
    const payload = {
      items: [{ productId: 'prod-1', quantity: 2 }],
      shippingAddress: { city: 'Paris', zip: '75001' },
    };

    const response = await request(app)
      .post('/api/orders')
      .set('Authorization', 'Bearer valid-token')
      .send(payload);

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      status: 'pending',
      items: expect.arrayContaining([
        expect.objectContaining({ productId: 'prod-1' }),
      ]),
    });

    // Verifier la persistance
    const saved = await db('orders').where({ id: response.body.data.id }).first();
    expect(saved).toBeDefined();
  });

  it('should return 400 when items array is empty', async () => {
    const response = await request(app)
      .post('/api/orders')
      .set('Authorization', 'Bearer valid-token')
      .send({ items: [] });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('should return 401 when no token provided', async () => {
    const response = await request(app).post('/api/orders').send({});
    expect(response.status).toBe(401);
  });
});
```

### Testcontainers (PostgreSQL reel)

```typescript
import { PostgreSqlContainer } from '@testcontainers/postgresql';

let container: StartedPostgreSqlContainer;

beforeAll(async () => {
  container = await new PostgreSqlContainer().start();
  process.env.DATABASE_URL = container.getConnectionUri();
  await runMigrations();
}, 30_000);

afterAll(async () => {
  await container.stop();
});
```

---

## Tests E2E

Les tests E2E sont reserves aux parcours critiques. Ils sont lents et fragiles : ne pas les multiplier.

### Reference : skill qa-e2e

Le skill `/qa:qa-e2e` fournit la structure complete : fixtures Playwright, Page Object Model, selecteurs accessibles. Consulter `.claude/skills/qa-e2e/SKILL.md`.

### Que tester en E2E

Tester uniquement les parcours ou une regression serait catastrophique pour le business.

| Parcours critique | Pourquoi |
|------------------|----------|
| Inscription + verification email | Point d'entree de tous les utilisateurs |
| Connexion + 2FA | Securite et acces a l'application |
| Tunnel d'achat complet | Revenu direct |
| Recuperation de mot de passe | Acces critique, souvent casse |
| Onboarding premiere connexion | Retention et activation |

### Ce qu'on ne teste pas en E2E

- Les cas d'erreur de formulaire (test en composant)
- La logique de calcul (test unitaire)
- Les droits d'acces fins (test d'integration)
- Les variantes visuelles (test de regression visuelle)

---

## Tests de Composants React

### Philosophie React Testing Library

Tester le comportement visible par l'utilisateur, pas l'implementation interne. Un test ne doit pas casser si on renomme une variable interne du composant.

```typescript
import { render, screen, userEvent } from '@testing-library/react';
import { ContactForm } from './ContactForm';

describe('ContactForm', () => {
  it('should submit form with valid data', async () => {
    const onSubmit = jest.fn();
    render(<ContactForm onSubmit={onSubmit} />);

    await userEvent.type(screen.getByLabelText('Nom'), 'Alice Dupont');
    await userEvent.type(screen.getByLabelText('Email'), 'alice@example.com');
    await userEvent.type(screen.getByLabelText('Message'), 'Bonjour');
    await userEvent.click(screen.getByRole('button', { name: 'Envoyer' }));

    expect(onSubmit).toHaveBeenCalledWith({
      name: 'Alice Dupont',
      email: 'alice@example.com',
      message: 'Bonjour',
    });
  });

  it('should display error when email is invalid', async () => {
    render(<ContactForm onSubmit={jest.fn()} />);

    await userEvent.type(screen.getByLabelText('Email'), 'pas-un-email');
    await userEvent.click(screen.getByRole('button', { name: 'Envoyer' }));

    expect(screen.getByRole('alert')).toHaveTextContent('Email invalide');
    expect(screen.getByLabelText('Email')).toHaveAttribute('aria-invalid', 'true');
  });

  it('should disable submit button while loading', async () => {
    const slowSubmit = jest.fn(() => new Promise((resolve) => setTimeout(resolve, 500)));
    render(<ContactForm onSubmit={slowSubmit} />);

    await userEvent.type(screen.getByLabelText('Nom'), 'Alice');
    await userEvent.click(screen.getByRole('button', { name: 'Envoyer' }));

    expect(screen.getByRole('button', { name: 'Envoi en cours...' })).toBeDisabled();
  });
});
```

### Snapshots : quand les utiliser

| Situation | Approche |
|-----------|----------|
| Composant purement presentationnel (badge, icone) | Snapshot acceptable |
| Composant avec logique ou interactions | Tests comportementaux |
| Mise en page globale (header, footer) | Snapshot + test d'accessibilite |
| Composant dynamique (donnees variables) | Eviter les snapshots |

Regle : si un snapshot echoue trop souvent sans regression reelle, le supprimer et ecrire un test comportemental.

---

## Infrastructure de Tests

### Configuration Jest (TypeScript)

```typescript
// jest.config.ts
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.test.ts', '**/*.spec.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/main.ts',
  ],
  coverageThresholds: {
    global: {
      lines: 70,
      branches: 65,
      functions: 70,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.ts'],
};

export default config;
```

### Configuration Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      thresholds: { lines: 70, branches: 65 },
    },
    pool: 'forks',
    maxConcurrency: 4,
  },
});
```

### Configuration pytest

```python
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=70"

# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope="session")
def engine():
    return create_engine("sqlite:///:memory:")

@pytest.fixture(scope="function")
def db_session(engine):
    connection = engine.connect()
    transaction = connection.begin()
    session = sessionmaker(bind=connection)()
    yield session
    session.close()
    transaction.rollback()
    connection.close()
```

### Cibles de couverture

| Perimetre | Cible lignes | Cible branches | Justification |
|-----------|-------------|----------------|---------------|
| Nouveau code (feature) | 80% | 75% | Obligation TDD |
| Chemins critiques (auth, paiement) | 90% | 85% | Zero tolerance |
| Code legacy existant | 70% | 60% | Amelioration progressive |
| Utilitaires / helpers | 85% | 80% | Logique pure, facile a tester |
| Global du projet | 70% | 65% | Seuil minimum CI |

### Integration CI

```yaml
# .github/workflows/test.yml (extrait)
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]   # parallelisation
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run test -- --shard=${{ matrix.shard }}/4 --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-shard-${{ matrix.shard }}
          path: coverage/

  coverage-merge:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
      - run: npx nyc merge coverage/ && npx nyc report --check-coverage
```

### Tests flaky : gestion et resolution

| Etape | Action |
|-------|--------|
| Detection | Activer `--retry 2` en CI, surveiller les echecs intermittents |
| Quarantaine | Marquer avec `test.skip` + issue GitHub, ne pas bloquer la CI |
| Investigation | Chercher : dependance au timing, etat partage, donnees non deterministees |
| Resolution | Extraire dans un test isole, utiliser de vrais waits, nettoyer l'etat |
| Validation | Lancer 50 fois en local avant de retirer de la quarantaine |

---

## Patterns de Tests Avances

### Property-based testing (fast-check)

Tester des invariants sur des milliers de valeurs generees automatiquement.

```typescript
import * as fc from 'fast-check';
import { sanitizeUsername } from './sanitize';

describe('sanitizeUsername', () => {
  it('should always return a string no longer than 30 chars', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        const result = sanitizeUsername(input);
        return result.length <= 30;
      })
    );
  });

  it('should never contain special characters', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        const result = sanitizeUsername(input);
        return /^[a-z0-9_-]*$/.test(result);
      })
    );
  });

  it('should be idempotent', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        const once = sanitizeUsername(input);
        const twice = sanitizeUsername(once);
        return once === twice;
      })
    );
  });
});
```

### Contract testing (Pact)

Garantir la compatibilite entre un consommateur et un fournisseur d'API sans appel reseau.

```typescript
// consumer.pact.test.ts
import { Pact } from '@pact-foundation/pact';

const provider = new Pact({ consumer: 'frontend', provider: 'users-api' });

describe('Users API contract', () => {
  before(() => provider.setup());
  after(() => provider.finalize());

  it('should return user by ID', async () => {
    await provider.addInteraction({
      state: 'user 42 exists',
      uponReceiving: 'a GET request for user 42',
      withRequest: { method: 'GET', path: '/users/42' },
      willRespondWith: {
        status: 200,
        body: { id: 42, name: like('Alice'), email: like('alice@example.com') },
      },
    });

    const user = await fetchUser(42);
    expect(user.id).toBe(42);
  });
});
```

### Mutation testing (Stryker)

Le mutation testing mesure la qualite reelle des assertions. Il modifie le code et verifie que les tests echouent.

```bash
# Installation
npm install --save-dev @stryker-mutator/core @stryker-mutator/jest-runner

# stryker.config.json
{
  "testRunner": "jest",
  "mutate": ["src/**/*.ts", "!src/**/*.test.ts"],
  "thresholds": { "high": 80, "low": 60, "break": 50 }
}

# Lancer
npx stryker run
```

Un score de mutation superieur a 75% signifie que les assertions sont solides.

### Regression visuelle (Playwright)

```typescript
// e2e/tests/visual/dashboard.spec.ts
import { test, expect } from '@playwright/test';

test('dashboard should match visual baseline', async ({ page }) => {
  await page.goto('/dashboard');
  await page.waitForLoadState('networkidle');

  // Screenshot de la page entiere
  await expect(page).toHaveScreenshot('dashboard-full.png', {
    fullPage: true,
    threshold: 0.02,  // 2% de pixels differents autorises
  });

  // Screenshot d'un composant specifique
  const chart = page.getByTestId('revenue-chart');
  await expect(chart).toHaveScreenshot('revenue-chart.png');
});
```

---

## Commandes Socle

### TDD cycle complet

```bash
/dev:dev-tdd "description de la feature a implementer"
```

### Ecrire des tests sur code existant

```bash
/dev:dev-test "ajouter tests pour le service de facturation"
```

### Tests E2E Playwright

```bash
/qa:qa-e2e "parcours inscription et premiere connexion"
```

### Mesurer la couverture

```bash
/qa:qa-coverage
```

### Audit qualite + correction en boucle

```bash
/qa:qa-loop "score 90"
```

### Commandes manuelles utiles

```bash
# Jest - run avec couverture
npm run test:coverage

# Jest - watch mode (TDD)
npm run test:watch

# Vitest - mode UI
npx vitest --ui

# Playwright - mode debug
npx playwright test --debug

# pytest - verbose avec couverture
pytest -v --cov=src --cov-report=html

# Stryker - mutation testing
npx stryker run
```

---

## Anti-patterns a Eviter

| Anti-pattern | Pourquoi ca echoue | Meilleure approche |
|-------------|-------------------|-------------------|
| Tester l'implementation interne | Casse au refactoring, pas de valeur | Tester le comportement observable (entree/sortie) |
| Mocks excessifs | Les tests ne testent plus rien de reel | Mocker uniquement les services externes |
| Aucun edge case | Les bugs sont toujours aux limites | Tester null, vide, 0, MAX, erreurs reseau |
| Tests lents en unit | Ralentit le cycle TDD, decourage les tests | Chaque test unitaire < 100ms, pas d'I/O |
| Tester getters/setters | Aucune logique, valeur nulle | Tester la logique metier, pas les accesseurs |
| Snapshots partout | Snapshots trop larges cassent sans raison | Snapshots limites aux composants statiques |
| Tester le framework | Express, React, Prisma sont deja testes | Tester votre code, pas les bibliotheques |
| Tests avec ordre impose | Casse en parallelisation | Chaque test est autonome, setup/teardown isole |
| Donnees de test en dur dans les assertions | Fragile, dependant du seed | Factories + assertions sur structure, pas valeurs fixes |
| Coverage comme objectif final | Encourage les tests vides | Coverage = indicateur, pas objectif ; viser la qualite des assertions |

---

## Ressources

- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [fast-check (property-based)](https://fast-check.io)
- [Pact Contract Testing](https://docs.pact.io)
- [Stryker Mutation Testing](https://stryker-mutator.io)
- [Testcontainers](https://testcontainers.com)
