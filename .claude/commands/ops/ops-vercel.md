# OPS-VERCEL Agent (pointer)

Deployment and configuration on Vercel.

## Context
$ARGUMENTS

## Delegate to the vendor toolkit

`claude-base`'s prior `ops-vercel` content (47-line config checklist) is **superseded** by [`vercel-labs/agent-skills`](https://github.com/vercel-labs/agent-skills) — Vercel's own toolkit stays in sync with the platform (vercel.json, Edge/serverless functions, cron protection, ISR, env scopes, Speed Insights) at depth a hand-maintained checklist cannot match.

Install:

```bash
git clone --depth 1 https://github.com/vercel-labs/agent-skills ~/dev/vendor-skills/vercel-agent-skills
ln -s ~/dev/vendor-skills/vercel-agent-skills/skills/<sub> ./.claude/skills/<sub>
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Vercel — `vercel-labs/agent-skills`". Reduction rationale: [`specs/command-vendor-graduation/spec.md`](../../../specs/command-vendor-graduation/spec.md).

For the CI/CD pipeline delegate to `/ops:ops-ci`; for observability to `/ops:ops-monitoring`; for environment management to `/ops:ops-env`.

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD |
| `/ops:ops-monitoring` | Observability |
| `/ops:ops-env` | Environment management |

---

YOU MUST protect cron endpoints with a secret, and NEVER commit environment variables.
