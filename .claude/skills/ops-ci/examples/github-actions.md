# Example: GitHub Actions CI/CD Pipeline

## Scenario
A Node.js API needs a complete CI/CD pipeline: lint, test, build, and deploy to staging/production.

## Pipeline Configuration

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test -- --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/lcov.info

  build:
    needs: lint-and-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
      - run: echo "Deploy to staging environment"
        # Replace with actual deploy command

  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
      - run: echo "Deploy to production environment"
        # Replace with actual deploy command
```

## Key Decisions

- **Cache npm**: `actions/setup-node` with `cache: 'npm'` speeds up installs
- **Job dependencies**: `build` waits for `lint-and-test` to pass
- **Environment gates**: `environment: production` enables manual approval
- **Artifacts**: Build output shared between jobs via `upload-artifact`
- **Branch strategy**: PRs trigger tests only, merges trigger deploy
