# QA-E2E Agent

End-to-End tests with Playwright or Cypress.

## Context
$ARGUMENTS

## Objective

Set up and execute E2E tests on critical user journeys, using the Page Object Model for maintainability.

## Workflow

- Choose the framework (Playwright recommended)
- Configure multi-browser and CI/CD
- Identify critical journeys (auth, checkout, navigation)
- Implement the Page Object Model
- Write tests with accessible selectors (role, label)
- Configure fixtures and test data
- Integrate into GitHub Actions with artifacts

## Expected output

### E2E test plan
- Critical journeys identified with priority
- Proposed structure (pages/, tests/, fixtures/)
- Estimate of the number of tests and time

### Configuration
- playwright.config.ts with multi-browser
- CI/CD pipeline with artifacts

### Implemented tests
- Page Objects for each main page
- Tests for critical journeys

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-automation` | Automation strategy |
| `/qa:qa-tech-debt` | Test coverage & debt |
| `/qa:wcag-audit` | Accessibility |
| `/ops:ops-ci` | CI/CD integration |

---

IMPORTANT: E2E tests are slow - reserve them for critical journeys.

YOU MUST implement the Page Object Model for maintainability.

NEVER test UI implementation details - test user behavior.

Think hard about the journeys with the highest business value.
