# DOCKER Agent

Dockerization and containerization of projects.

## Request context
$ARGUMENTS

## Objective

Generate optimized Dockerfiles, docker-compose and .dockerignore
tailored to the project's technical stack, with multi-stage builds and security.

## Workflow

- Detect the project's technical stack (Node.js, Python, Go, React, etc.)
- Generate an optimized multi-stage Dockerfile (build + production)
- Create a docker-compose.yml with services, volumes and networks
- Configure the .dockerignore
- Apply security best practices (non-root user, no secrets in the image)
- Configure healthchecks
- Optimize the layer order for caching

## Expected output

1. **Dockerfile**: optimized production image
2. **docker-compose.yml**: multi-container orchestration
3. **.dockerignore**: configured exclusions
4. **Information**: estimated size, build/run commands

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD with Docker |
| `/ops:ops-env` | Environment management |
| `/ops:ops-monitoring` | Container monitoring |

---

IMPORTANT: Always use specific tags for base images (not latest).

YOU MUST scan the image for vulnerabilities before deployment.

NEVER include secrets or credentials in the Docker image.

NEVER use root in production.
