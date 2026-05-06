---
sidebar_position: 40
title: "qa-e2e"
description: "End-to-end tests with Playwright or Cypress. Trigger when the user wants to create user journey tests, UI integration tests, or browser automation."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-e2e

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> End-to-end tests with Playwright or Cypress. Trigger when the user wants to create user journey tests, UI integration tests, or browser automation.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `e2e`, `end-to-end`, `end-to-end test`, `playwright`, `cypress` |

## Detailed description

# E2E Testing Skill

## Triggers

This skill activates when the user mentions:
- "E2E", "end-to-end", "end-to-end test"
- "Playwright", "Cypress", "Puppeteer"
- "integration test", "user journey"
- "browser automation", "UI test"

## Recommended framework

| Framework | Advantages | Use case |
|-----------|-----------|----------|
| **Playwright** | Multi-browser, fast, auto-wait | Modern apps |
| **Cypress** | Excellent DX, easy debugging | Prototyping |

**Default recommendation**: Playwright

## Project structure

```
e2e/
├── fixtures/           # Custom fixtures
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

## Critical journeys

| Journey | Test points |
|----------|----------------|
| **Signup** | Form validation, email, success |
| **Login** | Valid/invalid, remember me, forgot |
| **Navigation** | Menu, breadcrumbs, deep links |
| **Search** | Query, filters, pagination |
| **Checkout** | Cart, payment, confirmation |

## Recommended selectors

| Priority | Selector | Example |
|----------|-----------|---------|
| 1 | Role | `getByRole('button', { name: 'Submit' })` |
| 2 | Label | `getByLabel('Email')` |
| 3 | Text | `getByText('Welcome')` |
| 4 | Test ID | `getByTestId('submit-btn')` |
| 5 | CSS | `.btn-primary` (avoid) |

## Useful commands

```bash
# Run the tests
npx playwright test

# Interactive UI mode
npx playwright test --ui

# Headed mode (see the browser)
npx playwright test --headed

# Debug
npx playwright test --debug

# Generate code
npx playwright codegen http://localhost:3000

# Report
npx playwright show-report
```

## Custom fixtures

Playwright fixtures centralize the setup and inject the Page Objects into the tests:

```typescript
// e2e/fixtures/index.ts
import { test as base } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { DashboardPage } from '../pages/dashboard.page';

type Fixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
};

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },
});

export { expect } from '@playwright/test';
```

```typescript
// e2e/tests/auth/login.spec.ts (with fixtures)
import { test, expect } from '../../fixtures';

test('should login with valid credentials', async ({ loginPage, page }) => {
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

## Reusable authentication fixture

```typescript
// e2e/fixtures/auth.ts
import { test as base } from '@playwright/test';

export const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password');
    await page.getByRole('button', { name: 'Login' }).click();
    await page.waitForURL('/dashboard');
    await use(page);
  },
});
```

## Playwright best practices

| Practice | Description |
|----------|-------------|
| **Fresh context** | Each test starts in an isolated browser context (no shared state) |
| **Auto-waiting** | Don't add `waitForTimeout` - Playwright waits automatically |
| **Web-first assertions** | Use `expect(locator)` which retries automatically, not `expect(await locator.textContent())` |
| **Parallelism** | `fullyParallel: true` in the config for parallel execution |
| **Traces** | `trace: 'on-first-retry'` to debug flaky tests |

## Anti-patterns

| Anti-pattern | Alternative |
|-------------|-------------|
| `page.waitForTimeout(3000)` | `await expect(locator).toBeVisible()` |
| `page.$('.my-class')` | `page.getByRole('button', { name: '...' })` |
| XPath selectors | role/label/text selectors |
| Tests dependent on each other | Each test is independent |
| `page.evaluate()` for assertions | Web-first assertions with `expect` |
| Page Objects with business logic | Page Objects = actions + locators only |

## Rules

IMPORTANT: E2E tests are slow - reserve them for critical journeys (10% of the pyramid).

IMPORTANT: Always use accessible selectors (role, label).

IMPORTANT: Use Playwright fixtures to inject the Page Objects - no `new Page()` in each test.

YOU MUST implement the Page Object Model for maintainability.

NEVER test implementation details - test user behavior.

NEVER use fragile CSS selectors (classes, dynamic IDs).

NEVER use `waitForTimeout` - use web-first assertions which retry automatically.

## See also

The Microsoft Playwright team publishes their own SKILL.md at [`microsoft/playwright-cli/skills/playwright-cli`](https://github.com/microsoft/playwright-cli/tree/main/skills/playwright-cli) (9,978★, last commit 2026-05-04). Authoritative on Playwright API patterns, kept in sync with each Playwright release.

When working on a Playwright project, install the vendor skill alongside this one. This skill captures the **opinionated workflow patterns** the foundation imposes (TDD, anti-fragility rules, don't-do lists); the vendor skill captures the **canonical API patterns** that evolve with each Playwright release. Both together is the recommended setup for Playwright users.

**Vendor-neutrality disclosure**: Microsoft owns Playwright. Per the foundation's vendor curation policy, Microsoft tools that **predate the company's deepening OpenAI commercial relationship** (e.g. VSCode, GitHub, Playwright created in 2020) are evaluated case-by-case rather than auto-rejected. Playwright remains MIT-licensed and the de-facto standard for E2E testing. We point to the vendor skill because no equivalent vendor-neutral source maintains the API canonically and the community alternative `lackeyjb/playwright-skill` was 5 months stale at audit time. Re-evaluate this pointer if Microsoft's commercial alignment with OpenAI changes the project's roadmap visibly (e.g. direct OpenAI product integration).

For Cypress users (the other framework this skill covers), no vendor-published Cypress skill was identified at the time of the audit; the framework-agnostic guidance in this skill remains the primary reference.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to e2e..."_
- _"I want to end-to-end..."_
- _"I want to end-to-end test..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. E2E Example: Login flow test

# E2E Example: Login flow test

## User request
> "Create an E2E test for the login flow with Playwright"

---

## Flow analysis

### User steps
1. Access the login page
2. Fill in email and password
3. Click "Sign in"
4. Verify the redirect to the dashboard
5. Verify that the user is logged in

### Cases to test
- Successful login
- Invalid email
- Wrong password
- Empty fields

---

## Playwright implementation

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

## Playwright configuration

```typescript
// playwright.config.ts

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2: 0,
  workers: process.env.CI ? 1: undefined,
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

## Page Object Pattern (optional)

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
# Run all E2E tests
npx playwright test

# Interactive UI mode
npx playwright test --ui

# Generate the report
npx playwright show-report

# Specific tests
npx playwright test login.spec.ts

# Debug mode
npx playwright test --debug
```

---

## Best practices

1. **data-testid**: Use test attributes rather than CSS selectors
2. **Page Objects**: Encapsulate page logic for reusability
3. **Explicit assertions**: Always verify the expected state
4. **Isolation**: Each test must be independent
5. **CI/CD**: Configure retries and screenshots in CI



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
