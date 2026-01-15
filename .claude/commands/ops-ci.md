# Agent CI-CD

Configurer les pipelines CI/CD (GitHub Actions, GitLab CI, etc.).

## Contexte
$ARGUMENTS

## Processus de configuration

### 1. Analyser le projet

```bash
# Stack et configuration
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat go.mod 2>/dev/null
cat Dockerfile 2>/dev/null
cat docker-compose.yml 2>/dev/null

# CI existant
ls -la .github/workflows/ 2>/dev/null
ls -la .gitlab-ci.yml 2>/dev/null
cat Makefile 2>/dev/null | head -30
```

### 2. Identifier les besoins

#### Étapes typiques d'un pipeline

| Étape | Description | Obligatoire |
|-------|-------------|-------------|
| **Install** | Installer les dépendances | ✓ |
| **Lint** | Vérifier le style de code | ✓ |
| **Typecheck** | Vérifier les types (TS, mypy) | ✓ |
| **Test** | Tests unitaires et intégration | ✓ |
| **Build** | Compiler/bundler | ✓ |
| **Security** | Audit des dépendances | Recommandé |
| **E2E** | Tests end-to-end | Recommandé |
| **Deploy** | Déploiement | Selon projet |

### 3. Templates GitHub Actions

#### Node.js / TypeScript
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18, 20]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck

      - name: Test
        run: npm test -- --coverage

      - name: Build
        run: npm run build

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        if: matrix.node-version == 20
```

#### Python
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Lint with ruff
        run: ruff check .

      - name: Type check with mypy
        run: mypy .

      - name: Test with pytest
        run: pytest --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

#### Go
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.22'

      - name: Lint
        uses: golangci/golangci-lint-action@v4

      - name: Test
        run: go test -v -race -coverprofile=coverage.out ./...

      - name: Build
        run: go build -v ./...
```

### 4. Templates de déploiement

#### Deploy Vercel (automatique)
```yaml
# Vercel auto-déploie sur push
# Configuration dans vercel.json si nécessaire
```

#### Deploy Docker
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/app:latest
            ${{ secrets.DOCKER_USERNAME }}/app:${{ github.sha }}
```

#### Deploy AWS (ECS, Lambda, S3)
```yaml
# .github/workflows/deploy-aws.yml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-1

      # Pour S3 + CloudFront (frontend)
      - name: Deploy to S3
        run: |
          npm run build
          aws s3 sync dist/ s3://${{ secrets.S3_BUCKET }} --delete
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_DISTRIBUTION_ID }} --paths "/*"

      # Pour ECS (backend)
      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment
```

### 5. Workflows avancés

#### Pull Request Checks
```yaml
# .github/workflows/pr.yml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  # Vérifications rapides
  quick-checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck

  # Tests
  test:
    needs: quick-checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm test

  # Preview deployment (Vercel, Netlify)
  preview:
    needs: quick-checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Vercel déploie automatiquement les PR
```

#### Release Workflow
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build changelog
        id: changelog
        uses: mikepenz/release-changelog-builder-action@v4

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          body: ${{ steps.changelog.outputs.changelog }}
          draft: false
          prerelease: false
```

### 6. Sécurité CI/CD

#### Secrets
- IMPORTANT: Utiliser GitHub Secrets pour les credentials
- NEVER hardcoder de secrets dans les workflows
- Utiliser des tokens à durée limitée quand possible

#### Bonnes pratiques
- [ ] Limiter les permissions du GITHUB_TOKEN
- [ ] Utiliser `pull_request_target` avec précaution
- [ ] Scanner les dépendances avec Dependabot
- [ ] Activer la protection des branches

```yaml
# Permissions minimales
permissions:
  contents: read
  pull-requests: write
```

### 7. Optimisations

#### Cache
```yaml
# Cache npm
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}

# Cache pnpm
- uses: pnpm/action-setup@v2
  with:
    version: 8
- uses: actions/cache@v4
  with:
    path: ~/.pnpm-store
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
```

#### Parallélisation
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps: [...]

  test:
    runs-on: ubuntu-latest
    steps: [...]

  build:
    needs: [lint, test]  # Attend les deux
    runs-on: ubuntu-latest
    steps: [...]
```

### 8. GitLab CI (alternative)

```yaml
# .gitlab-ci.yml
stages:
  - install
  - test
  - build
  - deploy

variables:
  npm_config_cache: "$CI_PROJECT_DIR/.npm"

cache:
  paths:
    - .npm/
    - node_modules/

install:
  stage: install
  script:
    - npm ci

lint:
  stage: test
  script:
    - npm run lint

test:
  stage: test
  script:
    - npm test
  coverage: '/Lines\s*:\s*(\d+\.?\d*)%/'

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  script:
    - echo "Deploy to production"
  only:
    - main
  when: manual
```

## Output attendu

### Fichiers générés
```
.github/
└── workflows/
    ├── ci.yml          # Pipeline principal
    ├── pr.yml          # Checks PR
    ├── deploy.yml      # Déploiement
    └── release.yml     # Releases
```

### Configuration recommandée
```yaml
# Résumé de la configuration
Pipeline: [GitHub Actions / GitLab CI]
Triggers: [push main, PR]
Étapes: [lint, typecheck, test, build]
Deploy: [Vercel / AWS / Docker]
```

### Secrets à configurer
| Secret | Description | Où le créer |
|--------|-------------|-------------|
| `DOCKER_TOKEN` | Token Docker Hub | Docker Hub → Settings |
| `AWS_ACCESS_KEY_ID` | Clé AWS | AWS IAM |
| `CODECOV_TOKEN` | Token Codecov | codecov.io |

### Checklist de mise en place
- [ ] Workflows créés
- [ ] Secrets configurés
- [ ] Branch protection activée
- [ ] Dependabot activé
- [ ] Tests passent en CI

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/docker` | Build images Docker |
| `/test` | Configuration des tests |
| `/release` | Automatiser les releases |
| `/secrets-management` | Gestion des secrets CI |
| `/infra-code` | Déploiement infrastructure |

---

IMPORTANT: Tester le pipeline sur une branche de test avant de merger sur main.

YOU MUST utiliser des secrets pour tous les credentials - jamais en clair.

NEVER donner des permissions excessives au GITHUB_TOKEN.

Think hard sur les étapes vraiment nécessaires - un pipeline rapide est un pipeline utilisé.
