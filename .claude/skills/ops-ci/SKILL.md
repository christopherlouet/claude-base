---
name: ops-ci
description: CI/CD pipeline configuration. Trigger when the user wants to configure GitHub Actions, GitLab CI, or automate deployments.
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

# Least privilege by default; a job asks for more only where it needs it.
permissions:
  contents: read

# Major tags keep the example readable. In a real pipeline, pin each action to a
# full commit SHA (`uses: actions/checkout@<40-char sha> # v7.0.1`): a tag can be moved.
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: '24'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: '24'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v7
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write   # push to ghcr.io
    steps:
      - uses: actions/checkout@v7
      - uses: docker/login-action@v4
        if: github.ref == 'refs/heads/main'
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v7
        with:
          push: ${{ github.ref == 'refs/heads/main' }}
          # ghcr.io wants a lowercase name: lowercase it if the owner or repo has capitals
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy
        env:
          DEPLOY_WEBHOOK: ${{ secrets.DEPLOY_WEBHOOK }}
        run: curl --fail -X POST "$DEPLOY_WEBHOOK"
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

## See also

GitHub's own [`github-actions-hardening`](https://github.com/github/awesome-copilot/tree/main/skills/github-actions-hardening) skill (`github/awesome-copilot`, MIT, pin `143a3d97`) goes deeper on workflow security: token permissions, pinning actions by SHA, untrusted input in `run:`, `pull_request_target`. It does not generate pipelines and does not cover GitLab — authoring stays here.
