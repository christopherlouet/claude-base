---
sidebar_position: 32
title: "qa-e2e"
description: "Tests End-to-End avec Playwright ou Cypress. Declencher quand l'utilisateur veut creer des tests de parcours utilisateur, tests d'integration UI, ou automatisation navigateur."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-e2e

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Tests End-to-End avec Playwright ou Cypress. Declencher quand l'utilisateur veut creer des tests de parcours utilisateur, tests d'integration UI, ou automatisation navigateur.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `e2e`, `end-to-end`, `test de bout en bout`, `playwright`, `cypress` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux e2e..."_
- _"Je veux end-to-end..."_
- _"Je veux test de bout en bout..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple E2E : Test de parcours de connexion

# Exemple E2E : Test de parcours de connexion

## Demande utilisateur
> "Creer un test E2E pour le parcours de connexion avec Playwright"

---

## Analyse du parcours

### Etapes utilisateur
1. Acceder a la page de login
2. Remplir email et mot de passe
3. Cliquer sur "Se connecter"
4. Verifier la redirection vers le dashboard
5. Verifier que l'utilisateur est connecte

### Cas a tester
- Connexion reussie
- Email invalide
- Mot de passe incorrect
- Champs vides

---

## Implementation Playwright

```typescript
// tests/e2e/login.spec.ts

import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    // Arrange
    const validEmail = 'user@example.com';
    const validPassword = 'SecurePass123';

    // Act
    await page.fill('[data-testid="email-input"]', validEmail);
    await page.fill('[data-testid="password-input"]', validPassword);
    await page.click('[data-testid="login-button"]');

    // Assert
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should show error for invalid email format', async ({ page }) => {
    // Arrange
    const invalidEmail = 'not-an-email';

    // Act
    await page.fill('[data-testid="email-input"]', invalidEmail);
    await page.fill('[data-testid="password-input"]', 'anypassword');
    await page.click('[data-testid="login-button"]');

    // Assert
    await expect(page.locator('[data-testid="email-error"]')).toHaveText(
      'Email invalide'
    );
    await expect(page).toHaveURL('/login');
  });

  test('should show error for wrong password', async ({ page }) => {
    // Arrange
    const validEmail = 'user@example.com';
    const wrongPassword = 'WrongPassword';

    // Act
    await page.fill('[data-testid="email-input"]', validEmail);
    await page.fill('[data-testid="password-input"]', wrongPassword);
    await page.click('[data-testid="login-button"]');

    // Assert
    await expect(page.locator('[data-testid="auth-error"]')).toHaveText(
      'Email ou mot de passe incorrect'
    );
  });

  test('should disable button when fields are empty', async ({ page }) => {
    // Assert
    await expect(page.locator('[data-testid="login-button"]')).toBeDisabled();

    // Act - Fill only email
    await page.fill('[data-testid="email-input"]', 'user@example.com');

    // Assert - Still disabled
    await expect(page.locator('[data-testid="login-button"]')).toBeDisabled();

    // Act - Fill password too
    await page.fill('[data-testid="password-input"]', 'password');

    // Assert - Now enabled
    await expect(page.locator('[data-testid="login-button"]')).toBeEnabled();
  });
});
```

---

## Configuration Playwright

```typescript
// playwright.config.ts

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
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
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## Page Object Pattern (optionnel)

```typescript
// tests/e2e/pages/LoginPage.ts

import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly emailError: Locator;
  readonly authError: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.emailError = page.locator('[data-testid="email-error"]');
    this.authError = page.locator('[data-testid="auth-error"]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  async expectError(message: string) {
    await expect(this.authError).toHaveText(message);
  }
}
```

---

## Execution

```bash
# Lancer tous les tests E2E
npx playwright test

# Mode UI interactif
npx playwright test --ui

# Generer le rapport
npx playwright show-report

# Tests specifiques
npx playwright test login.spec.ts

# Mode debug
npx playwright test --debug
```

---

## Bonnes pratiques

1. **data-testid** : Utiliser des attributs de test plutot que des selecteurs CSS
2. **Page Objects** : Encapsuler la logique de page pour la reutilisabilite
3. **Assertions explicites** : Toujours verifier l'etat attendu
4. **Isolation** : Chaque test doit etre independant
5. **CI/CD** : Configurer les retries et screenshots en CI



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
