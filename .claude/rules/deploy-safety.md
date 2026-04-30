---
paths:
  - "**/docker-compose*.yml"
  - "**/docker-compose*.yaml"
  - "**/Dockerfile*"
  - "**/deploy*"
  - "**/scripts/deploy*"
  - "**/.env*"
  - "**/nginx*"
  - "**/middleware.*"
  - "**/proxy.*"
  - "**/sw.js"
  - "**/service-worker*"
  - "**/layout.tsx"
  - "**/layout.jsx"
  - "**/+layout.svelte"
---

# Deploy Safety

## Principle

Every deployment must be validated before execution. Never deploy dev config to production.

## CRITICAL: High-risk files

These files can break production silently (no error in dev):

| File | Risk | Mandatory test |
|---------|--------|-----------------|
| `middleware.ts/proxy.ts` | CSP can block scripts → blank page | `npm run build && npm start`, check CSP headers with curl |
| `layout.tsx` | `headers()` breaks SSG → 500 on static pages | `npm run build` must pass without error |
| `sw.js` | HTML cache → broken hydration after deploy | Test in real browser with DevTools > Application > SW |
| `docker-compose.production.yml` | `read_only` breaks framework cache | `docker compose up` locally before deploy |
| `Dockerfile` | Corrupted image | Build + run locally before transfer |

IMPORTANT: Tests in dev mode (`npm run dev`, `next dev`, `vite dev`) do NOT detect production bugs (CSP, SSG, SW, Docker).

## Absolute rule: REVERT FIRST

If prod is broken, **REVERT to the last stable state BEFORE trying to understand**. Never chain cascading hotfixes.

```bash
# Quick revert
git checkout <last-known-good-tag> -- <broken-file>
./scripts/deploy.sh deploy
# THEN investigate in a separate branch
```

NEVER chain more than 2 hotfixes in prod. On the 2nd failure → REVERT.

## Mandatory pre-deployment checklist

| Check | Command | Blocking |
|--------------|----------|----------|
| Prod build succeeds | `npm run build` / `go build` / `docker build .` | Yes |
| Tests pass | `npm test` / `pytest` / `go test` | Yes |
| Types OK (if applicable) | `npx tsc --noEmit` / `mypy .` | Yes |
| Lint OK | `npm run lint` / `ruff check .` / `golangci-lint run` | Yes |
| No hardcoded secrets | `grep -rn "password\|secret\|api_key" docker-compose*.yml` | Yes |
| DB migrations up to date | `prisma migrate status` / equivalent | Yes |
| CSP headers verified | `curl -sI localhost:3000 \| grep csp` | If middleware modified |
| SW does not cache HTML | Check navigate handler in sw.js | If SW modified |
| Docker works | `docker compose -f docker-compose.production.yml up` locally | If Docker modified |
| DB backup done | Backup script | Yes |

## Red Flags — STOP immediately

| Signal | Reaction |
|--------|----------|
| `headers()` or `cookies()` in root layout | STOP — breaks SSG, use middleware |
| `read_only: true` in Docker without complete tmpfs | STOP — frameworks need writable cache |
| `strict-dynamic` CSP without nonce on inline scripts | STOP — blocks scripts, blank page |
| SW that caches `request.mode === "navigate"` | STOP — breaks hydration after deploy |
| Deploying without local prod build | STOP — dev bugs ≠ prod bugs |
| 2nd cascading hotfix that fails | STOP — REVERT and investigate |
| Copying docker-compose.yml (dev) to the server | STOP — use docker-compose.production.yml |
| Env variables with dev default values | STOP — check production values |
| DB migration with `--force` without backup | STOP — backup first |

## Environments

| Env | CSP | SW | Docker | Debug | Test method |
|-----|-----|-----|--------|-------|-------------|
| Dev | Permissive | Not active | No | Yes | `npm run dev` |
| Local build | Prod | Active if registered | No | No | `npm run build && npm start` |
| Staging | Prod | Active | Yes | No | Via deploy script |
| Prod | Strict | Active | Yes | No | Via deploy script |

## Rules

IMPORTANT: Always check that the docker-compose used is the PRODUCTION one before deploying.

IMPORTANT: NEVER deploy without having checked that all environment variables are configured for production.

NEVER copy a dev configuration file to production without explicit verification.

NEVER deploy with pending DB migrations without having run or checked them.

NEVER deploy a change to middleware, layout, sw.js, or Docker without testing in a local prod build.
