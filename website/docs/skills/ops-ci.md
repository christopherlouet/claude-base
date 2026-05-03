---
sidebar_position: 27
title: "ops-ci"
description: "CI/CD pipeline configuration. Trigger when the user wants to configure GitHub Actions, GitLab CI, or automate deployments."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-ci

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> CI/CD pipeline configuration. Trigger when the user wants to configure GitHub Actions, GitLab CI, or automate deployments.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops` |

## Detailed description

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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: GitHub Actions CI/CD Pipeline

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



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
