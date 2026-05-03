---
name: ops-ci
description: CI/CD pipeline configuration. Trigger when the user wants to configure GitHub Actions, GitLab CI, or automate deployments.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
disable-model-invocation: true
---

# CI/CD Pipeline

## GitHub Actions

```yaml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v5
        with:
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy
        run: curl -X POST ${{ secrets.DEPLOY_WEBHOOK }}
```

## Recommended structure

1. **Lint** - Code verification
2. **Test** - Unit and integration tests
3. **Build** - Artifact construction
4. **Deploy** - Deployment by environment

## Best practices

- Dependency caching
- Parallel jobs when possible
- Environments for security
- Secrets for credentials
- Branch protection rules
