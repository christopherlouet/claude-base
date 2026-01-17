# Agent QA-E2E

Tests End-to-End avec Playwright ou Cypress.

## Contexte
$ARGUMENTS

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    PYRAMIDE DES TESTS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                      /\      E2E (10%)                          │
│                     /  \     Parcours utilisateur complets      │
│                    /    \                                       │
│                   /──────\   Integration (20%)                  │
│                  /        \  Composants + API                   │
│                 /          \                                    │
│                /────────────\  Unit (70%)                       │
│               /              \ Fonctions isolees                │
│              /________________\                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Choix du framework

| Framework | Avantages | Inconvenients | Recommande pour |
|-----------|-----------|---------------|-----------------|
| **Playwright** | Multi-browser, rapide, auto-wait | API plus complexe | Apps modernes |
| **Cypress** | DX excellente, debug facile | Chrome-first | Prototypage |
| **Puppeteer** | Leger, Node natif | Chrome uniquement | Scraping, PDF |

## Setup Playwright

### Installation

```bash
# Installation
npm init playwright@latest

# Structure creee
e2e/
├── tests/
│   └── example.spec.ts
├── playwright.config.ts
└── package.json
```

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 12'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## Patterns de test E2E

### Page Object Model (POM)

```typescript
// e2e/pages/login.page.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Mot de passe');
    this.submitButton = page.getByRole('button', { name: 'Se connecter' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

### Tests avec POM

```typescript
// e2e/tests/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';

test.describe('Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should show error with invalid credentials', async () => {
    await loginPage.login('user@example.com', 'wrongpassword');
    await loginPage.expectError('Identifiants incorrects');
  });

  test('should redirect to login when accessing protected route', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/login?redirect=/dashboard');
  });
});
```

### Fixtures personnalisees

```typescript
// e2e/fixtures.ts
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { DashboardPage } from './pages/dashboard.page';

type Fixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  authenticatedPage: DashboardPage;
};

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },

  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },

  authenticatedPage: async ({ page }, use) => {
    // Setup: login
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');

    // Use the authenticated page
    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);

    // Teardown: logout (optional)
  },
});

export { expect } from '@playwright/test';
```

## Scenarios critiques a tester

### Checklist parcours utilisateur

| Parcours | Tests |
|----------|-------|
| **Inscription** | Form validation, email verification, success |
| **Connexion** | Valid/invalid credentials, remember me, forgot password |
| **Navigation** | Menu, breadcrumbs, deep links, back button |
| **Recherche** | Query, filters, pagination, no results |
| **Formulaires** | Validation, submit, error handling |
| **Checkout** | Cart, payment, confirmation |
| **Responsive** | Mobile, tablet, desktop |

### Tests de regression visuelle

```typescript
test('homepage should match snapshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixels: 100,
  });
});
```

## Gestion des donnees de test

### Strategies

| Strategie | Avantage | Inconvenient |
|-----------|----------|--------------|
| **Seed DB** | Donnees realistes | Setup complexe |
| **API mocking** | Rapide, isole | Moins realiste |
| **Fixtures** | Reproductible | Maintenance |

### Database seeding

```typescript
// e2e/setup/global-setup.ts
import { chromium } from '@playwright/test';

async function globalSetup() {
  // Seed database
  await seedTestData();

  // Create authenticated state
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto('http://localhost:3000/login');
  await page.fill('[name="email"]', 'admin@test.com');
  await page.fill('[name="password"]', 'testpass');
  await page.click('button[type="submit"]');
  await page.waitForURL('/dashboard');

  // Save auth state
  await page.context().storageState({ path: 'e2e/.auth/admin.json' });
  await browser.close();
}

export default globalSetup;
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npx playwright test

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## Debugging

### Commandes utiles

```bash
# Mode debug avec UI
npx playwright test --ui

# Mode headed (voir le navigateur)
npx playwright test --headed

# Debug un test specifique
npx playwright test auth.spec.ts --debug

# Generer du code en enregistrant
npx playwright codegen http://localhost:3000

# Voir le rapport HTML
npx playwright show-report
```

### Traces

```typescript
test('debug example', async ({ page }) => {
  // Pause pour inspecter
  await page.pause();

  // Screenshot manuel
  await page.screenshot({ path: 'debug.png' });

  // Log dans le rapport
  console.log('Current URL:', page.url());
});
```

## Output attendu

### Plan de tests E2E

```markdown
## Plan de tests E2E

### Parcours critiques identifies
1. [Parcours 1] - Priorite: Haute
2. [Parcours 2] - Priorite: Haute
3. [Parcours 3] - Priorite: Moyenne

### Structure proposee
```
e2e/
├── fixtures/           # Fixtures personnalisees
├── pages/              # Page Objects
├── tests/
│   ├── auth/          # Tests authentification
│   ├── checkout/      # Tests checkout
│   └── ...
├── utils/             # Helpers
└── playwright.config.ts
```

### Estimation
- Tests a ecrire: [X]
- Temps estime: [X]h
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa-automation` | Strategie d'automatisation |
| `/qa-coverage` | Couverture des tests |
| `/qa-a11y` | Accessibilite |
| `/ops-ci` | Integration CI/CD |

---

IMPORTANT: Les tests E2E sont lents - les reserver aux parcours critiques.

IMPORTANT: Toujours utiliser des selecteurs accessibles (role, label).

YOU MUST implementer le Page Object Model pour la maintenabilite.

NEVER tester les details d'implementation UI - tester le comportement utilisateur.
