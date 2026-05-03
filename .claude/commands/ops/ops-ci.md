# CI-CD Agent

Configure CI/CD pipelines (GitHub Actions, GitLab CI, etc.).

## Request context
$ARGUMENTS

## Objective

Generate complete CI/CD pipelines adapted to the project's technical stack,
with lint, test, build, security, and deployment steps.

## Workflow

- Analyze the technical stack and existing configuration
- Identify the needs (lint, typecheck, test, build, security, e2e, deploy)
- Generate the appropriate GitHub Actions or GitLab CI workflows
- Configure caching and parallelization for performance
- Add PR checks and release workflows
- Document the secrets to configure
- Verify that permissions are minimal

## Expected output

1. **Workflows**: ci.yml, pr.yml, deploy.yml, release.yml
2. **Secrets** to configure with instructions
3. **Checklist** for setup (workflows, secrets, branch protection, dependabot)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Build Docker images |
| `/ops:ops-release` | Automate releases |
| `/ops:ops-secrets-management` | CI secrets management |

---

IMPORTANT: Test the pipeline on a test branch before merging to main.

YOU MUST use secrets for all credentials - never in clear text.

NEVER grant excessive permissions to the GITHUB_TOKEN.

Think hard about the steps that are truly necessary - a fast pipeline is a used pipeline.
