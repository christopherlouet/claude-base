---
name: ops-ci
description: Configuration de pipelines CI/CD. Declencher quand l'utilisateur veut configurer GitHub Actions, GitLab CI, ou automatiser les deployments.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
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

## Structure recommandee

1. **Lint** - Verification du code
2. **Test** - Tests unitaires et integration
3. **Build** - Construction de l'artefact
4. **Deploy** - Deploiement par environnement

## Bonnes pratiques

- Cache des dependances
- Jobs paralleles quand possible
- Environments pour la securite
- Secrets pour les credentials
- Branch protection rules
