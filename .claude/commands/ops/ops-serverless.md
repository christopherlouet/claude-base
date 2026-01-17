# Agent SERVERLESS

Deploiement d'applications serverless (AWS Lambda, Vercel, Cloudflare Workers).

## Contexte
$ARGUMENTS

## Comparatif plateformes

| Plateforme | Cold start | Langages | Prix | Use case |
|------------|------------|----------|------|----------|
| **AWS Lambda** | 100-500ms | All | $0.20/1M req | Backend complet |
| **Vercel** | <50ms | Node, Edge | Free tier genereux | Frontend + API |
| **Cloudflare Workers** | <5ms | JS/Wasm | $5/10M req | Edge computing |
| **Google Cloud Functions** | 100-400ms | All | $0.40/1M req | GCP ecosystem |
| **Azure Functions** | 100-500ms | All | $0.20/1M req | Azure ecosystem |

## AWS Lambda

### Structure projet

```
lambda-project/
├── src/
│   ├── handlers/
│   │   ├── users.ts
│   │   └── posts.ts
│   ├── lib/
│   │   ├── prisma.ts
│   │   └── utils.ts
│   └── types/
├── serverless.yml
├── package.json
└── tsconfig.json
```

### Serverless Framework

```yaml
# serverless.yml
service: my-api

frameworkVersion: '3'

provider:
  name: aws
  runtime: nodejs20.x
  region: eu-west-1
  stage: ${opt:stage, 'dev'}
  memorySize: 256
  timeout: 10
  environment:
    DATABASE_URL: ${ssm:/my-app/${self:provider.stage}/database-url}
    NODE_ENV: ${self:provider.stage}
  iam:
    role:
      statements:
        - Effect: Allow
          Action:
            - ssm:GetParameter
          Resource: "arn:aws:ssm:${self:provider.region}:*:parameter/my-app/*"

functions:
  getUsers:
    handler: src/handlers/users.list
    events:
      - http:
          path: /users
          method: get
          cors: true

  createUser:
    handler: src/handlers/users.create
    events:
      - http:
          path: /users
          method: post
          cors: true

  getUserById:
    handler: src/handlers/users.getById
    events:
      - http:
          path: /users/{id}
          method: get
          cors: true

plugins:
  - serverless-esbuild
  - serverless-offline
  - serverless-domain-manager

custom:
  esbuild:
    bundle: true
    minify: true
    sourcemap: true
    target: 'node20'

  serverless-offline:
    httpPort: 3001

  customDomain:
    domainName: api.example.com
    basePath: ''
    stage: ${self:provider.stage}
    createRoute53Record: true
```

### Handler Lambda

```typescript
// src/handlers/users.ts
import { APIGatewayProxyHandler, APIGatewayProxyResult } from 'aws-lambda';
import { prisma } from '../lib/prisma';

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
};

const response = (
  statusCode: number,
  body: unknown
): APIGatewayProxyResult => ({
  statusCode,
  headers,
  body: JSON.stringify(body),
});

export const list: APIGatewayProxyHandler = async (event) => {
  try {
    const users = await prisma.user.findMany({
      take: 50,
      orderBy: { createdAt: 'desc' },
    });

    return response(200, { data: users });
  } catch (error) {
    console.error('Error fetching users:', error);
    return response(500, { error: 'Internal server error' });
  }
};

export const getById: APIGatewayProxyHandler = async (event) => {
  try {
    const { id } = event.pathParameters || {};

    if (!id) {
      return response(400, { error: 'User ID required' });
    }

    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      return response(404, { error: 'User not found' });
    }

    return response(200, { data: user });
  } catch (error) {
    console.error('Error fetching user:', error);
    return response(500, { error: 'Internal server error' });
  }
};

export const create: APIGatewayProxyHandler = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');

    const user = await prisma.user.create({
      data: {
        email: body.email,
        name: body.name,
      },
    });

    return response(201, { data: user });
  } catch (error) {
    console.error('Error creating user:', error);
    return response(500, { error: 'Internal server error' });
  }
};
```

### Deploiement

```bash
# Developement local
npx serverless offline

# Deploy dev
npx serverless deploy --stage dev

# Deploy prod
npx serverless deploy --stage prod

# Deploy une seule fonction
npx serverless deploy function -f getUsers

# Logs
npx serverless logs -f getUsers -t
```

## Vercel Serverless

### Structure Next.js API Routes

```
app/
├── api/
│   ├── users/
│   │   ├── route.ts          # GET, POST /api/users
│   │   └── [id]/
│   │       └── route.ts      # GET, PUT, DELETE /api/users/:id
│   └── health/
│       └── route.ts
└── ...
```

### API Route (App Router)

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '10');

    const users = await prisma.user.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
    });

    return NextResponse.json({ data: users });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();

    const user = await prisma.user.create({
      data: {
        email: body.email,
        name: body.name,
      },
    });

    return NextResponse.json({ data: user }, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

### Vercel Configuration

```json
// vercel.json
{
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 10,
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

## Cloudflare Workers

### Structure

```
worker/
├── src/
│   ├── index.ts
│   └── handlers/
├── wrangler.toml
└── package.json
```

### Configuration

```toml
# wrangler.toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[env.production]
vars = { ENVIRONMENT = "production" }

[[kv_namespaces]]
binding = "CACHE"
id = "xxx"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx"
```

### Worker

```typescript
// src/index.ts
export interface Env {
  CACHE: KVNamespace;
  DB: D1Database;
}

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> {
    const url = new URL(request.url);

    // Router simple
    if (url.pathname === '/api/users' && request.method === 'GET') {
      return handleGetUsers(env);
    }

    if (url.pathname === '/api/users' && request.method === 'POST') {
      return handleCreateUser(request, env);
    }

    return new Response('Not Found', { status: 404 });
  },
};

async function handleGetUsers(env: Env): Promise<Response> {
  // Check cache
  const cached = await env.CACHE.get('users', 'json');
  if (cached) {
    return Response.json({ data: cached, cached: true });
  }

  // Query D1
  const { results } = await env.DB.prepare(
    'SELECT * FROM users ORDER BY created_at DESC LIMIT 50'
  ).all();

  // Cache for 5 minutes
  await env.CACHE.put('users', JSON.stringify(results), {
    expirationTtl: 300,
  });

  return Response.json({ data: results });
}

async function handleCreateUser(
  request: Request,
  env: Env
): Promise<Response> {
  const body = await request.json();

  const result = await env.DB.prepare(
    'INSERT INTO users (email, name) VALUES (?, ?) RETURNING *'
  )
    .bind(body.email, body.name)
    .first();

  // Invalidate cache
  await env.CACHE.delete('users');

  return Response.json({ data: result }, { status: 201 });
}
```

### Deploiement

```bash
# Dev local
npx wrangler dev

# Deploy
npx wrangler deploy

# Logs
npx wrangler tail
```

## Optimisations

### Cold start mitigation

```typescript
// Garder les connexions actives
let prismaClient: PrismaClient | null = null;

function getPrisma(): PrismaClient {
  if (!prismaClient) {
    prismaClient = new PrismaClient();
  }
  return prismaClient;
}

// Provisioned concurrency (AWS)
// serverless.yml
functions:
  myFunction:
    handler: handler.main
    provisionedConcurrency: 5
```

### Bundling optimise

```javascript
// esbuild.config.js
const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['src/handlers/*.ts'],
  bundle: true,
  minify: true,
  sourcemap: true,
  platform: 'node',
  target: 'node20',
  outdir: 'dist',
  external: ['@prisma/client'], // Native modules
  treeShaking: true,
});
```

## Output attendu

### Architecture serverless

```markdown
## Architecture Serverless

### Plateforme choisie
[Plateforme] - [Justification]

### Functions
| Function | Trigger | Memory | Timeout |
|----------|---------|--------|---------|
| getUsers | HTTP GET | 256MB | 10s |
| createUser | HTTP POST | 512MB | 30s |

### Configuration
[serverless.yml ou equivalent]

### Couts estimes
- Requests/mois: [X]
- Cout estime: $[X]/mois
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops-ci` | CI/CD serverless |
| `/ops-monitoring` | Observabilite |
| `/qa-perf` | Performance |
| `/ops-cost-optimization` | Optimisation couts |

---

IMPORTANT: Optimiser pour les cold starts - eviter les imports lourds.

IMPORTANT: Utiliser des connexions de base de donnees poolees.

YOU MUST configurer les timeouts et memory selon le use case.

NEVER stocker d'etat en memoire - les fonctions sont ephemeres.
