---
name: qa-e2e
description: End-to-end tests with Playwright or Cypress. Trigger when the user wants to create user journey tests, UI integration tests, or browser automation.
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
