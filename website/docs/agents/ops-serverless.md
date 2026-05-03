---
sidebar_position: 48
title: "ops-serverless"
description: "Deployment of serverless applications."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-serverless

<span className="badge badge--haiku">Haiku</span>

> Deployment of serverless applications.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent SERVERLESS

Deployment of serverless applications.

## Goal

Configure and deploy serverless functions.

## Platforms

| Platform | Cold start | Use case |
|----------|------------|----------|
| AWS Lambda | 100-500ms | Full backend |
| Vercel | ~50ms | Frontend + API |
| Cloudflare Workers | ~5ms | Edge computing |

## AWS Lambda (Serverless Framework)

```yaml
service: my-api
provider:
  name: aws
  runtime: nodejs20.x
  region: eu-west-1

functions:
  getUsers:
    handler: src/handlers/users.list
    events:
      - http:
          path: /users
          method: get
```

## Handler

```typescript
export const list: APIGatewayProxyHandler = async (event) => {
  const users = await prisma.user.findMany();
  return {
    statusCode: 200,
    body: JSON.stringify({ data: users }),
  };
};
```

## Commands

```bash
npx serverless offline      # Local dev
npx serverless deploy       # Deploy
npx serverless logs -f name # Logs
```

## Expected output

- serverless.yml configuration
- Optimized handlers
- CI/CD configuration
- Cost estimation

## Constraints

- Optimize for cold starts
- Use pooled connections
- Configure adequate timeouts
- No in-memory state

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
