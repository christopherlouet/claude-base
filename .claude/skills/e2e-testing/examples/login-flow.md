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
