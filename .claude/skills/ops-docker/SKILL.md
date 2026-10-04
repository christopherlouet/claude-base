---
name: ops-docker
description: Docker and Docker Compose containerization. Trigger when the user wants to dockerize an application or create containers.
disable-model-invocation: true
---

# Docker Containerization (pointer)

Docker Inc. publishes its own agent skills at [`docker/skills`](https://github.com/docker/skills) (Apache-2.0, pin `v0.3.1`). Four of them cover what this skill used to teach — multi-stage builds, non-root users, `.dockerignore`, `HEALTHCHECK`, BuildKit secrets and cache mounts, Compose healthchecks and `depends_on: service_healthy`:

| Skill | Use it when |
|-------|-------------|
| `docker-project-foundations` | Dockerizing a project, local dev with containers |
| `docker-build-strategies` | Writing, slimming or hardening a Dockerfile |
| `docker-compose-patterns` | Wiring services, adding a database, Compose debugging |
| `docker-destructive-guardrails` | Before any `docker` command that deletes or resets state |

```bash
# pinned release (Docker's README documents the tree/<tag> form)
npx skills add https://github.com/docker/skills/tree/v0.3.1 --skill docker-project-foundations --yes
npx skills add https://github.com/docker/skills/tree/v0.3.1 --skill docker-build-strategies --yes
npx skills add https://github.com/docker/skills/tree/v0.3.1 --skill docker-compose-patterns --yes
npx skills add https://github.com/docker/skills/tree/v0.3.1 --skill docker-destructive-guardrails --yes
```

The repo's other seven skills (Docker Agent, Docker Sandboxes) are product-specific; install them only if you use those products. The three skills that ship a `scripts/verify-*.sh` only build the image and validate the Compose file.

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Docker".

## Foundation discipline the vendor skills leave out

- **Scan the image before it ships**: none of the four mentions vulnerability scanning. Gate the push on `trivy image <image>` (or Docker Scout, Grype) failing on HIGH/CRITICAL — the `ops-ci` skill wires it; `qa-security` owns the policy.
- **Lint the Dockerfile in CI**: `hadolint Dockerfile` as a blocking step, also absent from the vendor skills.
- **Never bake secrets**: no `COPY .env`, no credentials in `ENV` or build args — BuildKit `--mount=type=secret` at build time, orchestrator-injected env at run time (`.claude/rules/security.md`).

## See also

- `/ops:ops-deploy` — deployment checklist consumes the built image
- `/ops:ops-database` — Compose patterns for DB services
- `qa-security` — image scanning gate before push
- `ops-ci` — Hadolint + image scan as CI steps
