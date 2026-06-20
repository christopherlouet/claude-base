# QA-AUTOMATION Agent

Set up a comprehensive test automation strategy.

## Context
$ARGUMENTS

## Objective

Automate tests at all levels (unit, integration, E2E) to ensure quality and accelerate release cycles.

## Workflow

- Evaluate current coverage and test pyramid
- Configure unit test framework (Vitest/Jest/Pytest)
- Configure integration tests (Supertest, test containers)
- Configure E2E tests (Playwright recommended)
- Set up mocking (MSW)
- Integrate into CI/CD pipeline (GitHub Actions)
- Define quality metrics and thresholds

## Expected output

### Test pyramid
- Unit (70-80%): framework, coverage config
- Integration (15-25%): API, DB, services
- E2E (5-10%): critical user journeys

### CI/CD configuration
- Pipeline with parallelized tests
- Coverage reports and artifacts

### Metrics
| Metric | Target |
|--------|--------|
| Coverage | > 80% |
| Passing tests | 100% |
| Execution time | < 10 min |
| Flaky tests | 0 |

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-tdd` | TDD cycle + test infra setup |
| `/ops:ops-ci` | CI/CD pipeline |
| `/qa:qa-perf` | Performance tests |

---

IMPORTANT: Maintain the test pyramid - more unit tests than E2E.

YOU MUST use stable data-testid for E2E tests.

NEVER have interdependent tests - each test must be isolated.

Think hard about the effort/value ratio before automating a scenario.
