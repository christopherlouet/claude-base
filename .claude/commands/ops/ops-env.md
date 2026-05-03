# OPS-ENV Agent

Environment management (dev, staging, prod) and environment variables.

## Request context
$ARGUMENTS

## Objective

Configure clean environment management with variable validation,
documented templates and strict separation of secrets per environment.

## Workflow

- Identify the required environments (dev, staging, prod)
- Create the documented and categorized .env.example template
- Implement variable validation with Zod or equivalent
- Configure per-environment files (.env.development, .env.staging, .env.production)
- Verify that .env and .env.local are in .gitignore
- Recommend a suitable secrets management solution
- Configure CI/CD variables (GitHub Actions, GitLab CI)

## Expected output

1. **Files**: .env.example, .env.development, .env.staging, .env.production
2. **Validation**: config/env.ts with Zod schema
3. **Documentation** of required and optional variables
4. **Security checklist** for environments

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-secrets-management` | Secure secrets management |
| `/ops:ops-docker` | Docker configuration |
| `/ops:ops-ci` | CI/CD secrets |

---

IMPORTANT: NEVER commit .env files containing real secrets.

YOU MUST use different secrets for each environment.

NEVER hardcode sensitive values in the code.

Think hard about which variables are really needed.
