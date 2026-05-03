# SERVERLESS Agent

Deployment of serverless applications (AWS Lambda, Vercel, Cloudflare Workers).

## Request context
$ARGUMENTS

## Objective

Design and deploy a serverless architecture suited to the project,
with cold start optimization and CI/CD integration.

## Workflow

- Analyze the needs and choose the platform (AWS Lambda, Vercel, Cloudflare Workers)
- Structure the project (handlers, lib, types)
- Configure the framework (Serverless Framework, Vercel, Wrangler)
- Implement the handlers with error handling
- Optimize for cold starts (pooled connections, bundling, provisioned concurrency)
- Configure the deployment (local dev, staging, production)
- Estimate costs

## Expected output

1. **Architecture** serverless with platform justification
2. **Configuration** (serverless.yml, vercel.json, wrangler.toml)
3. **Handlers** implemented with suitable patterns
4. **Cost estimate** monthly

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | Serverless CI/CD |
| `/ops:ops-monitoring` | Observability |
| `/ops:ops-cost-optimization` | Cost optimization |

---

IMPORTANT: Optimize for cold starts - avoid heavy imports.

IMPORTANT: Use pooled database connections.

YOU MUST configure timeouts and memory according to the use case.

NEVER store state in memory - functions are ephemeral.
