---
name: qa-e2e
description: Tests End-to-End avec Playwright ou Cypress. Declencher quand l'utilisateur veut creer des tests de parcours utilisateur, tests d'integration UI, ou automatisation navigateur.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# E2E Testing Skill

## Declencheurs

Ce skill s'active quand l'utilisateur mentionne:
- "E2E", "end-to-end", "test de bout en bout"
- "Playwright", "Cypress", "Puppeteer"
- "test d'integration", "parcours utilisateur"
- "automatisation navigateur", "test UI"

## Framework recommande

| Framework | Avantages | Use case |
|-----------|-----------|----------|
| **Playwright** | Multi-browser, rapide, auto-wait | Apps modernes |
| **Cypress** | DX excellente, debug facile | Prototypage |

**Recommandation par defaut**: Playwright

## Structure projet

```
e2e/
├── fixtures/           # Fixtures personnalisees
├── pages/              # Page Objects
│   ├── login.page.ts
│   └── dashboard.page.ts
├── tests/
│   ├── auth/
│   │   └── login.spec.ts
│   └── checkout/
│       └── purchase.spec.ts
├── utils/              # Helpers
└── playwright.config.ts
```

## Page Object Model

```typescript
// e2e/pages/login.page.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Login' });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

## Tests

```typescript
// e2e/tests/auth/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/login.page';

test.describe('Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('should login with valid credentials', async ({ page }) => {
    await loginPage.login('user@example.com', 'password');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await loginPage.login('user@example.com', 'wrong');
    await expect(page.getByRole('alert')).toContainText('Invalid');
  });
});
```

## Parcours critiques

| Parcours | Points de test |
|----------|----------------|
| **Inscription** | Validation form, email, success |
| **Connexion** | Valid/invalid, remember me, forgot |
| **Navigation** | Menu, breadcrumbs, deep links |
| **Recherche** | Query, filtres, pagination |
| **Checkout** | Cart, payment, confirmation |

## Selecteurs recommandes

| Priorite | Selecteur | Exemple |
|----------|-----------|---------|
| 1 | Role | `getByRole('button', { name: 'Submit' })` |
| 2 | Label | `getByLabel('Email')` |
| 3 | Text | `getByText('Welcome')` |
| 4 | Test ID | `getByTestId('submit-btn')` |
| 5 | CSS | `.btn-primary` (eviter) |

## Commandes utiles

```bash
# Lancer les tests
npx playwright test

# Mode UI interactif
npx playwright test --ui

# Mode headed (voir le navigateur)
npx playwright test --headed

# Debug
npx playwright test --debug

# Generer du code
npx playwright codegen http://localhost:3000

# Rapport
npx playwright show-report
```

## Regles

IMPORTANT: Les tests E2E sont lents - les reserver aux parcours critiques (10% de la pyramide).

IMPORTANT: Toujours utiliser des selecteurs accessibles (role, label).

YOU MUST implementer le Page Object Model pour la maintenabilite.

NEVER tester les details d'implementation - tester le comportement utilisateur.

NEVER utiliser de selecteurs CSS fragiles (classes, IDs dynamiques).
