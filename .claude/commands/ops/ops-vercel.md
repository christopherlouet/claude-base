# Agent OPS-VERCEL

Deploiement et configuration sur Vercel.

## Contexte
$ARGUMENTS

## Vue d'ensemble Vercel

```
┌─────────────────────────────────────────────────────────────────┐
│                      VERCEL PLATFORM                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Frontend   │  │ Serverless   │  │    Edge      │          │
│  │   (Static)   │  │  Functions   │  │   Runtime    │          │
│  │              │  │              │  │              │          │
│  │  Next.js     │  │  /api/*      │  │  Middleware  │          │
│  │  React       │  │  Functions   │  │  Edge Funcs  │          │
│  │  Vue         │  │              │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Edge Network (CDN)                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration projet

### vercel.json

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "installCommand": "npm ci",
  "devCommand": "npm run dev",

  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 30,
      "memory": 1024
    },
    "app/api/heavy/**/*.ts": {
      "maxDuration": 60,
      "memory": 3008
    }
  },

  "crons": [
    {
      "path": "/api/cron/daily-cleanup",
      "schedule": "0 0 * * *"
    },
    {
      "path": "/api/cron/hourly-sync",
      "schedule": "0 * * * *"
    }
  ],

  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" },
        { "key": "Cache-Control", "value": "no-cache" }
      ]
    },
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ],

  "redirects": [
    {
      "source": "/old-path",
      "destination": "/new-path",
      "permanent": true
    }
  ],

  "rewrites": [
    {
      "source": "/api/v1/:path*",
      "destination": "https://api.example.com/:path*"
    }
  ]
}
```

## Environnements

### Variables d'environnement

```bash
# Via CLI
vercel env add DATABASE_URL production
vercel env add DATABASE_URL preview
vercel env add DATABASE_URL development

# Lister
vercel env ls

# Pull en local
vercel env pull .env.local
```

### Configuration par environnement

```json
// vercel.json
{
  "env": {
    "NEXT_PUBLIC_API_URL": "https://api.example.com"
  },
  "build": {
    "env": {
      "NODE_ENV": "production"
    }
  }
}
```

## Edge Functions & Middleware

### Middleware

```typescript
// middleware.ts (racine du projet)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Authentication check
  const token = request.cookies.get('auth-token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add headers
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');

  return response;
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/protected/:path*',
  ],
};
```

### Edge Function

```typescript
// app/api/edge/route.ts
export const runtime = 'edge';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const country = request.headers.get('x-vercel-ip-country') || 'unknown';

  return Response.json({
    country,
    timestamp: Date.now(),
  });
}
```

## API Routes

### Route Handler (App Router)

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get('page') || '1');

  // Logic here
  return NextResponse.json({ data: [], page });
}

export async function POST(request: Request) {
  const body = await request.json();

  // Validation
  if (!body.email) {
    return NextResponse.json(
      { error: 'Email required' },
      { status: 400 }
    );
  }

  // Create
  return NextResponse.json({ data: body }, { status: 201 });
}
```

### Route dynamique

```typescript
// app/api/users/[id]/route.ts
import { NextResponse } from 'next/server';

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const { id } = params;

  // Fetch user
  return NextResponse.json({ id });
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  const { id } = params;

  // Delete user
  return new NextResponse(null, { status: 204 });
}
```

## Cron Jobs

```typescript
// app/api/cron/daily-cleanup/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  // Verify cron secret
  const authHeader = request.headers.get('authorization');
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Run cleanup logic
  console.log('Running daily cleanup...');

  return NextResponse.json({ success: true });
}
```

## Deploiement

### CLI Commands

```bash
# Login
vercel login

# Deploy preview
vercel

# Deploy production
vercel --prod

# Lier un projet existant
vercel link

# Logs en temps reel
vercel logs [deployment-url] --follow

# Inspecter un deploiement
vercel inspect [deployment-url]

# Rollback
vercel rollback [deployment-url]
```

### GitHub Integration

```yaml
# .github/workflows/preview.yml (optionnel - Vercel le fait auto)
name: Preview Deployment

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

## Domaines & DNS

```bash
# Ajouter un domaine
vercel domains add example.com

# Lister les domaines
vercel domains ls

# Configurer DNS
vercel dns add example.com @ A 76.76.21.21
vercel dns add example.com www CNAME cname.vercel-dns.com
```

## Monitoring & Analytics

### Web Vitals

```typescript
// app/layout.tsx
import { SpeedInsights } from '@vercel/speed-insights/next';
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        {children}
        <SpeedInsights />
        <Analytics />
      </body>
    </html>
  );
}
```

### Logs structurés

```typescript
// lib/logger.ts
export function log(level: 'info' | 'warn' | 'error', message: string, data?: object) {
  const logEntry = {
    level,
    message,
    timestamp: new Date().toISOString(),
    ...data,
  };

  console.log(JSON.stringify(logEntry));
}
```

## Optimisations

### Image Optimization

```typescript
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.example.com',
      },
    ],
    formats: ['image/avif', 'image/webp'],
  },
};
```

### ISR (Incremental Static Regeneration)

```typescript
// app/posts/[id]/page.tsx
export const revalidate = 60; // Revalidate every 60 seconds

export async function generateStaticParams() {
  const posts = await getPosts();
  return posts.map((post) => ({ id: post.id }));
}
```

## Output attendu

### Configuration Vercel

```markdown
## Configuration Vercel

### Projet
- Framework: [Next.js / React / Vue]
- Node version: [20.x]
- Region: [iad1 / cdg1 / ...]

### Environnements
| Variable | Production | Preview | Dev |
|----------|------------|---------|-----|
| DATABASE_URL | xxx | xxx | xxx |

### Functions
| Path | Duration | Memory |
|------|----------|--------|
| /api/* | 10s | 1024MB |

### Crons
| Job | Schedule | Path |
|-----|----------|------|
| Cleanup | 0 0 * * * | /api/cron/cleanup |
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops-ci` | CI/CD |
| `/ops-monitoring` | Observabilite |
| `/qa-perf` | Performance |
| `/ops-env` | Gestion environnements |

---

IMPORTANT: Utiliser Edge Functions pour les operations rapides (< 25ms).

IMPORTANT: Configurer les headers de securite.

YOU MUST proteger les endpoints cron avec un secret.

NEVER commiter les variables d'environnement.
