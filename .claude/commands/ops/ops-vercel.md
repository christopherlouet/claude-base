# OPS-VERCEL Agent

Deployment and configuration on Vercel.

## Request context
$ARGUMENTS

## Objective

Configure a project on Vercel with environment variables,
serverless functions, edge middleware, cron jobs and optimizations.

## Workflow

- Configure vercel.json (framework, build, functions, crons, headers, redirects)
- Manage environment variables by scope (production, preview, development)
- Implement Edge Functions and Middleware if needed
- Configure API Routes (App Router)
- Protect cron endpoints with a secret
- Add security headers and optimizations (ISR, images)
- Configure domains and DNS
- Integrate Speed Insights and Analytics

## Expected output

1. **vercel.json** configured
2. **Environment variables** by scope
3. **Functions and Crons** configured
4. **CLI commands** essentials (deploy, logs, rollback)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD |
| `/ops:ops-monitoring` | Observability |
| `/ops:ops-env` | Environment management |

---

IMPORTANT: Use Edge Functions for fast operations (< 25ms).

IMPORTANT: Configure security headers.

YOU MUST protect cron endpoints with a secret.

NEVER commit environment variables.
