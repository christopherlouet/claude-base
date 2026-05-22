---
name: ops-docker
description: Docker and Docker Compose containerization. Trigger when the user wants to dockerize an application or create containers.
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

# Docker Containerization (pointer)

Dockerfile syntax, Compose schema and image-publish flows drift on each release and are canonical at:

- **Docker official** — [docs.docker.com](https://docs.docker.com) (Engine + Compose + Buildx)
- **Dockerfile best practices** — [docs.docker.com/develop/develop-images/dockerfile_best-practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- **Snyk Container Security** — [snyk.io/learn/container-security](https://snyk.io/learn/container-security/) (vulnerability scanning, base-image hardening)
- **Hadolint** — [github.com/hadolint/hadolint](https://github.com/hadolint/hadolint) (Dockerfile linter, CI-integrable)
- **Dive** — [github.com/wagoodman/dive](https://github.com/wagoodman/dive) (image layer analysis)

## Foundation discipline (keep across releases)

- **Multi-stage builds**: always separate build deps from runtime image. The "node:20 with full npm" image weighs 1GB+; the runtime layer should be ~100MB. Build stage produces artifacts, runtime stage copies them in.
- **Non-root user**: `RUN addgroup -S app && adduser -S app -G app && USER app` — never run app code as root inside the container, even if "it's just a sandbox".
- **.dockerignore mandatory**: forgotten `.git/` or `node_modules/` in the build context bloats images by hundreds of MB and leaks secrets. The `.dockerignore` rules mirror your `.gitignore` plus build artifacts.
- **HEALTHCHECK at the Dockerfile level**: not just at the orchestrator level. Lets Docker/Compose detect unhealthy containers before the orchestrator does.
- **Pin base image major+minor** (`node:20-alpine`, not `node:latest` or bare `node:20`): floating tags break reproducibility; SHA pinning is overkill for most apps but worth it for security-critical builds.
- **Secret management**: never `COPY .env` or hardcode credentials in `ENV`. Use BuildKit secrets (`--mount=type=secret`) or runtime-injected env vars from the orchestrator.

## See also

- `/ops:ops-deploy` — deployment checklist consumes the built image
- `/ops:ops-database` — Compose patterns for DB services (`depends_on: { condition: service_healthy }`)
- `qa-security` — image scanning gate (Snyk/Trivy) before push
- `ops-ci` — Hadolint + image scan as CI steps
