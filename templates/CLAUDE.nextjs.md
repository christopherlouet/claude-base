# Next.js App Router Project

## Essential Commands
- `npm install` - Install dependencies
- `npm run dev` - Dev server with Turbopack (http://localhost:3000)
- `npm run build` - Production build
- `npm start` - Start the production build
- `npm test` - Tests (Vitest/Jest based on config)
- `npm run lint` - ESLint + next lint
- `npm run typecheck` - tsc --noEmit
- `npx prisma studio` - Explore the DB (if Prisma)
- `npx prisma migrate dev` - Create a migration (dev)

## Project Structure
```
/app                    # App Router (Next.js 13+)
  /api                  # Route Handlers (formerly API routes)
  /(auth)               # Route groups (shared layouts)
  /[locale]             # Dynamic routes (i18n)
  layout.tsx            # Root layout
  page.tsx              # Home page
  loading.tsx           # Loading UI
  error.tsx             # Error UI
/components             # Reusable React components
  /ui                   # shadcn/ui (copy-paste)
/lib                    # Shared utils
  prisma.ts             # Prisma client singleton
  auth.ts               # Auth config
  utils.ts              # cn() helper
/hooks                  # Custom hooks (client components)
/stores                 # Zustand stores if global state
/types                  # Global TypeScript types
/public                 # Static assets
middleware.ts           # Edge middleware (auth, i18n, redirects)
```

## Next.js App Router Conventions

### Server vs Client Components
- IMPORTANT: **Server Components by default** (zero client JS)
- `"use client"` only if: useState, useEffect, onClick, onChange, browser hooks
- Server Components can import Client Components, the reverse only via `children` props

### Data Fetching
- IMPORTANT: Next 15+: `fetch()` is **no longer cached by default**
- Always specify: `{ cache: "force-cache" }` / `{ next: { revalidate: 60 } }` / `{ next: { tags: [...] } }`
- `Promise.all()` for parallel fetching (avoid waterfalls)
- `loading.tsx` + `<Suspense>` for streaming

### Server Actions
- Validate inputs with **Zod** (never unvalidated FormData)
- Verify auth in the action (not only middleware)
- `revalidatePath()` or `revalidateTag()` after mutation
- Errors: return an object `{ success: false, error: "..." }` vs throw

### Route Handlers
- `app/api/*/route.ts` (GET/POST/PUT/DELETE/PATCH exports)
- Return `NextResponse.json(data, { status })`
- No business logic without auth verification

## Security
- IMPORTANT: NEVER expose `DATABASE_URL` or secrets on the client side
- IMPORTANT: `NEXT_PUBLIC_*` variables = public (visible in the bundle)
- YOU MUST verify the session in every Server Action
- YOU MUST validate all inputs (Server Actions, Route Handlers) with Zod
- Session cookies: `httpOnly: true, secure: true, sameSite: "lax"`
- Content-Security-Policy in `next.config.ts` or middleware
- Middleware runs on Edge: no `fs`, `crypto.createHash`, `node:*` without polyfill

## Performance (Core Web Vitals)
- IMPORTANT: LCP < 2.5s, INP < 200ms, CLS < 0.1
- `next/image` with `priority` for above-the-fold
- `next/font` (Google Fonts self-hosted) to avoid FOIT/FOUT
- Code splitting via `dynamic()` for heavy components
- `export const dynamic = "force-static"` if the page is truly static
- Analyze the bundle: `ANALYZE=true npm run build` (with `@next/bundle-analyzer`)

## Typical recommended stack
- **TypeScript** strict
- **Tailwind CSS** + **shadcn/ui** (components)
- **Prisma** or **Drizzle** (ORM)
- **better-auth** / **Lucia v3** / **NextAuth v5** (auth)
- **next-intl** (i18n)
- **Zod** (validation)
- **React Hook Form** (complex forms)
- **SWR** or **React Query** (if server state on the client)
- **Zustand** (if global client state)

## Tests
- **Vitest** (recommended 2026, Jest compatible)
- **React Testing Library** for components
- **Playwright** for E2E
- Test behavior, not implementation
- Mock only external boundaries (API, DB)

## Common pitfalls
| Pitfall | Prevention |
|---------|------------|
| `"use client"` everywhere | Server Component by default, client only if hooks/events |
| Untimely data refetch | Specify explicit cache on every `fetch` |
| Build error `ERR_DYNAMIC` | `export const dynamic = "force-dynamic"` on the page |
| Slow middleware | Restrictive matcher, avoid fetches |
| Hydration mismatch | No `Date.now()` / `Math.random()` in SSR |
| PrismaClient multi-instantiation | Singleton via HMR-safe `globalThis` in `lib/prisma.ts` |

## Deployment
- **Vercel**: zero-config, preview deploys on PR, native analytics
- **Self-host**: `next build && next start`, Node 20+, process manager (PM2, systemd)
- **Docker**: standalone output (`output: "standalone"` in `next.config.ts`)

## Git & Commits
- Conventional Commits format: `feat(scope): description`
- Scopes: `api`, `ui`, `db`, `auth`, `i18n`, etc.
- Vercel preview on every PR for visual review

## Skills auto-activated on this project

| Skill | Trigger |
|-------|---------|
| `dev-nextjs` | Files `app/**`, `next.config.*`, RSC/Server Actions terms |
| `dev-react-perf` | Re-render optimization, Core Web Vitals |
| `dev-shadcn` | shadcn/ui components |
| `dev-frontend-design` | UI design (with art direction) |
| `dev-tdd` | All new code |
| `dev-prisma` | If `schema.prisma` present |
| `dev-auth` | Auth implementation |
| `dev-i18n` | Multi-language |
| `qa-security` | OWASP audit |
| `qa-perf` | Performance audit |

## Design Direction (optional)
Add a `## Design Direction` section in this CLAUDE.md with `Style: <direction>` to activate the `design-style` rule.

Available directions: `terminal`, `cockpit`, `vitality`, `editorial`, `glass`, `signal`.

Example:
```markdown
## Design Direction
Style: glass
```
