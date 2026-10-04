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
| `/ops:ops-cost` | Cloud cost optimization (FinOps) |

---

IMPORTANT: Optimize for cold starts - avoid heavy imports.

IMPORTANT: Use pooled database connections.

YOU MUST configure timeouts and memory according to the use case.

NEVER store state in memory - functions are ephemeral.

## See also

Vendor skills for depth, by platform (recipe: `docs/recipes/recommended-vendor-skills.md` §"Stack-specific"):

- **AWS Lambda** — [`awslabs/agent-plugins`](https://github.com/awslabs/agent-plugins) `plugins/aws-serverless/skills/*` (Apache-2.0, plugin `1.3.0` at pin `e32b05b5`): Lambda, SAM/CDK deployment, API Gateway, Step Functions, durable functions. Choose between: the **plugin** adds a hook after every Edit/Write (it runs `sam validate --lint` on SAM templates) and an MCP server run as `uvx awslabs.aws-serverless-mcp-server@latest --allow-write` (unpinned, write access); the **skill folders alone** avoid both, and the skills then ask before working without their MCP tools.
- **Cloudflare Workers** — [`cloudflare/skills`](https://github.com/cloudflare/skills) `skills/workers-best-practices` and `skills/wrangler` (Apache-2.0, pin `41e0d198`).

The platform choice stays with this command.
