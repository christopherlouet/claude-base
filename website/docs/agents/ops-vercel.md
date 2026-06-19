---
sidebar_position: 44
title: "ops-vercel"
description: "Deployment on Vercel."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-vercel

<span className="badge badge--haiku">Haiku</span>

> Deployment on Vercel.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent OPS-VERCEL

Deployment on Vercel.

## Objective

Configure and deploy projects on Vercel.

## Configuration

```json
{
  "framework": "nextjs",
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 30,
      "memory": 1024
    }
  },
  "crons": [
    {
      "path": "/api/cron/cleanup",
      "schedule": "0 0 * * *"
    }
  ]
}
```

## API Routes

```typescript
// app/api/users/route.ts
export async function GET(request: Request) {
  return NextResponse.json({ data: [] });
}
```

## Edge Functions

```typescript
export const runtime = 'edge';

export async function GET(request: Request) {
  const country = request.headers.get('x-vercel-ip-country');
  return Response.json({ country });
}
```

## Commands

```bash
vercel              # Deploy preview
vercel --prod       # Deploy production
vercel env pull     # Pull env vars
vercel logs --follow # Real-time logs
```

## Expected output

- vercel.json configured
- Environment variables
- Security headers
- Crons if needed

## Constraints

- Edge Functions for < 25ms
- Protect crons with a secret
- Do not commit env vars

## See also

For deeper, always-current Vercel coverage, pair this with [`vercel-labs/agent-skills`](https://github.com/vercel-labs/agent-skills) — install per [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md) §"Vercel — `vercel-labs/agent-skills`". Use the vendor toolkit for the deep execution layer; keep this agent for the foundation workflow orchestration (CI, monitoring, env).

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
