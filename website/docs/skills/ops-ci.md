---
sidebar_position: 27
title: "ops-ci"
description: "Configuration de pipelines CI/CD. Declencher quand l'utilisateur veut configurer GitHub Actions, GitLab CI, ou automatiser les deployments."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-ci

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Configuration de pipelines CI/CD. Declencher quand l'utilisateur veut configurer GitHub Actions, GitLab CI, ou automatiser les deployments.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `ops` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux ops..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


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

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
