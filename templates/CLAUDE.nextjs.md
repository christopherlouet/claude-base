# Projet Next.js App Router

## Commandes Essentielles
- `npm install` - Installer les dépendances
- `npm run dev` - Serveur dev avec Turbopack (http://localhost:3000)
- `npm run build` - Build production
- `npm start` - Démarrer la build production
- `npm test` - Tests (Vitest/Jest selon config)
- `npm run lint` - ESLint + next lint
- `npm run typecheck` - tsc --noEmit
- `npx prisma studio` - Explorer la DB (si Prisma)
- `npx prisma migrate dev` - Créer une migration (dev)

## Structure du Projet
```
/app                    # App Router (Next.js 13+)
  /api                  # Route Handlers (ex-API routes)
  /(auth)               # Route groups (layouts partagés)
  /[locale]             # Routes dynamiques (i18n)
  layout.tsx            # Root layout
  page.tsx              # Home page
  loading.tsx           # UI de chargement
  error.tsx             # UI d'erreur
/components             # Composants React réutilisables
  /ui                   # shadcn/ui (copy-paste)
/lib                    # Utils partagés
  prisma.ts             # Singleton Prisma client
  auth.ts               # Config auth
  utils.ts              # cn() helper
/hooks                  # Custom hooks (client components)
/stores                 # Zustand stores si global state
/types                  # Types TypeScript globaux
/public                 # Assets statiques
middleware.ts           # Edge middleware (auth, i18n, redirects)
```

## Conventions Next.js App Router

### Server vs Client Components
- IMPORTANT: **Server Components par défaut** (zero JS client)
- `"use client"` uniquement si : useState, useEffect, onClick, onChange, hooks browser
- Server Components peuvent importer Client Components, l'inverse via `children` props uniquement

### Data Fetching
- IMPORTANT: Next 15+ : `fetch()` n'est **plus cache par défaut**
- Toujours spécifier : `{ cache: "force-cache" }` / `{ next: { revalidate: 60 } }` / `{ next: { tags: [...] } }`
- `Promise.all()` pour parallel fetching (éviter les waterfalls)
- `loading.tsx` + `<Suspense>` pour streaming

### Server Actions
- Valider les inputs avec **Zod** (jamais de FormData non validée)
- Vérifier l'auth dans l'action (pas seulement middleware)
- `revalidatePath()` ou `revalidateTag()` après mutation
- Errors : return un objet `{ success: false, error: "..." }` vs throw

### Route Handlers
- `app/api/*/route.ts` (GET/POST/PUT/DELETE/PATCH exports)
- Return `NextResponse.json(data, { status })`
- Pas de logique métier sans vérification d'auth

## Sécurité
- IMPORTANT: NEVER exposer `DATABASE_URL` ou secrets côté client
- IMPORTANT: Variables `NEXT_PUBLIC_*` = publiques (visibles dans le bundle)
- YOU MUST vérifier la session dans chaque Server Action
- YOU MUST valider tous les inputs (Server Actions, Route Handlers) avec Zod
- Cookies de session : `httpOnly: true, secure: true, sameSite: "lax"`
- Content-Security-Policy dans `next.config.ts` ou middleware
- Middleware tourne sur Edge : pas de `fs`, `crypto.createHash`, `node:*` sans polyfill

## Performance (Core Web Vitals)
- IMPORTANT: LCP < 2.5s, INP < 200ms, CLS < 0.1
- `next/image` avec `priority` pour above-the-fold
- `next/font` (Google Fonts self-hosted) pour éviter FOIT/FOUT
- Code splitting via `dynamic()` pour composants lourds
- `export const dynamic = "force-static"` si la page est vraiment statique
- Analyser le bundle : `ANALYZE=true npm run build` (avec `@next/bundle-analyzer`)

## Stack typique recommandée
- **TypeScript** strict
- **Tailwind CSS** + **shadcn/ui** (composants)
- **Prisma** ou **Drizzle** (ORM)
- **better-auth** / **Lucia v3** / **NextAuth v5** (auth)
- **next-intl** (i18n)
- **Zod** (validation)
- **React Hook Form** (formulaires complexes)
- **SWR** ou **React Query** (si state serveur côté client)
- **Zustand** (si state global client)

## Tests
- **Vitest** (recommandé 2026, Jest compatible)
- **React Testing Library** pour composants
- **Playwright** pour E2E
- Tester le comportement, pas l'implémentation
- Mock uniquement les boundaries externes (API, DB)

## Pièges courants
| Piège | Prévention |
|-------|-----------|
| `"use client"` partout | Server Component par défaut, client uniquement si hooks/events |
| Data refetch intempestif | Spécifier cache explicite sur chaque `fetch` |
| Build error `ERR_DYNAMIC` | `export const dynamic = "force-dynamic"` sur la page |
| Middleware lent | Matcher restrictif, éviter les fetch |
| Hydration mismatch | Pas de `Date.now()` / `Math.random()` dans le SSR |
| PrismaClient multi-instanciation | Singleton via `globalThis` HMR-safe dans `lib/prisma.ts` |

## Déploiement
- **Vercel** : zero-config, preview deploys sur PR, analytics natifs
- **Self-host** : `next build && next start`, Node 20+, process manager (PM2, systemd)
- **Docker** : standalone output (`output: "standalone"` dans `next.config.ts`)

## Git & Commits
- Format Conventional Commits : `feat(scope): description`
- Scopes : `api`, `ui`, `db`, `auth`, `i18n`, etc.
- Preview Vercel sur chaque PR pour review visuelle

## Skills auto-activés sur ce projet

| Skill | Déclenchement |
|-------|---------------|
| `dev-nextjs` | Fichiers `app/**`, `next.config.*`, termes RSC/Server Actions |
| `dev-react-perf` | Optimisation re-renders, Core Web Vitals |
| `dev-shadcn` | Composants shadcn/ui |
| `dev-frontend-design` | Design UI (avec direction artistique) |
| `dev-tdd` | Tout code nouveau |
| `dev-prisma` | Si `schema.prisma` présent |
| `dev-auth` | Implémentation auth |
| `dev-i18n` | Multi-langue |
| `qa-security` | Audit OWASP |
| `qa-perf` | Audit performance |

## Direction Design (optionnel)
Ajouter dans ce CLAUDE.md une section `## Design Direction` avec `Style: <direction>` pour activer la rule `design-style`.

Directions disponibles : `terminal`, `cockpit`, `vitality`, `editorial`, `glass`, `signal`.

Exemple :
```markdown
## Design Direction
Style: glass
```
