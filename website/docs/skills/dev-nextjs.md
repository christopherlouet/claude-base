---
sidebar_position: 14
title: "dev-nextjs"
description: "Developpement Next.js (App Router, Server Components, caching, streaming). Declencher quand l'utilisateur travaille avec Next.js, modifie app/, pages/, next.config, ou parle de RSC, Server Actions, Route Handlers, middleware."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-nextjs

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Developpement Next.js (App Router, Server Components, caching, streaming). Declencher quand l'utilisateur travaille avec Next.js, modifie app/, pages/, next.config, ou parle de RSC, Server Actions, Route Handlers, middleware.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `nextjs`, `use client` |

## Description detaillee

# Next.js App Router

## App Router vs Pages Router

**App Router** (defaut depuis Next 13, stable) : dossier `app/`, Server Components par defaut, Server Actions, streaming. **Preferer** pour tout nouveau projet.

**Pages Router** : dossier `pages/`, getServerSideProps/getStaticProps. **Legacy**, ne plus ajouter de routes dedans.

Si le projet a les deux, coexister — les deux peuvent cohabiter, mais ne pas dupliquer une route.

## Server Components par defaut

Tout composant dans `app/` est **Server Component** par defaut. Il s'execute sur le serveur, zero JS client.

```tsx
// app/posts/page.tsx — Server Component (defaut)
export default async function PostsPage() {
  const posts = await db.posts.findMany();  // SQL direct OK
  return <PostList posts={posts} />;
}
```

### Passer en Client Component avec `"use client"`

```tsx
// app/components/SearchBox.tsx
"use client";  // Directive en haut du fichier

import { useState } from "react";

export function SearchBox() {
  const [query, setQuery] = useState("");
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

**Regle** : "use client" uniquement si besoin d'hooks (useState, useEffect) ou d'evenements browser (onClick, onChange). Sinon, rester Server Component.

### Composition Server/Client

Les Server Components peuvent importer des Client Components, mais **l'inverse non** (sauf via props `children`).

```tsx
// OK : Server Component utilise un Client Component
export default async function Page() {
  const data = await fetch(...);
  return <ClientChart data={data} />;  // ClientChart est "use client"
}

// OK : Client Component recoit un Server Component via children
"use client";
export function Layout({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;  // children peut etre un RSC
}
```

## Data Fetching

### fetch() natif avec cache Next.js

```tsx
// Cache force (SSG-like, revalidation manuelle)
const data = await fetch(url, { cache: "force-cache" });

// No cache (SSR a chaque requete)
const data = await fetch(url, { cache: "no-store" });

// Revalidation basee sur le temps (ISR)
const data = await fetch(url, { next: { revalidate: 60 } });

// Revalidation basee sur tag
const data = await fetch(url, { next: { tags: ["posts"] } });
// Puis dans un Server Action : revalidateTag("posts")
```

IMPORTANT (Next 15+) : `fetch` n'est plus cache par defaut. Il faut explicitement `force-cache` ou `next: { revalidate }`.

### Parallel data fetching

```tsx
// MAUVAIS — waterfall
const user = await getUser();
const posts = await getPosts();

// BON — parallele
const [user, posts] = await Promise.all([getUser(), getPosts()]);
```

## Server Actions

Fonctions executees sur le serveur, invoquees depuis le client sans API route manuelle.

```tsx
// app/actions.ts
"use server";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  await db.posts.create({ data: { title } });
  revalidatePath("/posts");
}

// app/posts/new/page.tsx
import { createPost } from "../actions";

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create</button>
    </form>
  );
}
```

**Pieges** :
- Toujours valider les inputs avec Zod (les Server Actions recoivent des donnees non validees)
- Toujours `revalidatePath` ou `revalidateTag` apres une mutation
- Ne PAS exposer de logique metier sans auth (verifier la session dans l'action)

## Route Handlers (API)

`app/api/*/route.ts` remplace `pages/api/`.

```tsx
// app/api/posts/route.ts
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const posts = await db.posts.findMany();
  return NextResponse.json(posts);
}

export async function POST(request: Request) {
  const body = await request.json();
  const post = await db.posts.create({ data: body });
  return NextResponse.json(post, { status: 201 });
}
```

## Streaming et Suspense

Afficher le shell de la page immediatement, streamer le contenu lent :

```tsx
import { Suspense } from "react";

export default function Page() {
  return (
    <div>
      <Header />  {/* Render immediatement */}
      <Suspense fallback={<PostsSkeleton />}>
        <SlowPosts />  {/* Stream quand pret */}
      </Suspense>
    </div>
  );
}
```

### loading.tsx

```tsx
// app/posts/loading.tsx — UI de chargement automatique
export default function Loading() {
  return <PostsSkeleton />;
}
```

## Middleware

```tsx
// middleware.ts (a la racine)
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token");
  if (!token && request.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
}

export const config = {
  matcher: ["/dashboard/:path*", "/api/protected/:path*"],
};
```

**Piege** : le middleware tourne sur Edge Runtime. Pas de Node APIs (fs, crypto.createHash...) sans polyfill.

## Metadata API

Remplace `<head>` manuel.

```tsx
// Metadata statique
export const metadata: Metadata = {
  title: "My App",
  description: "...",
};

// Metadata dynamique (async)
export async function generateMetadata({ params }): Promise<Metadata> {
  const post = await getPost(params.id);
  return { title: post.title };
}
```

## Images et Fonts

```tsx
import Image from "next/image";
import { Geist } from "next/font/google";

const geist = Geist({ subsets: ["latin"] });

<Image src="/hero.jpg" alt="" width={1200} height={600} priority />
```

Next charge et heberge les fonts localement (pas de requete Google), evite le FOIT/FOUT.

## Configuration

```ts
// next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    reactCompiler: true,       // Optimise auto-memoization
    ppr: "incremental",        // Partial Prerendering
    dynamicIO: true,           // Next 15+ cache granulaire
  },
  images: {
    remotePatterns: [{ protocol: "https", hostname: "cdn.example.com" }],
  },
};

export default nextConfig;
```

## Deploiement Vercel

- `vercel` — deploy preview
- `vercel --prod` — deploy production
- Build settings auto-detectes (npm, pnpm, bun)
- Variables d'env dans le dashboard

Alternative : self-host avec `next build && next start` (Node 18+).

## Pieges courants

| Probleme | Solution |
|----------|----------|
| "use client" partout | Ne l'ajouter qu'aux composants qui utilisent hooks/events |
| Data refetch intempestif | Verifier `cache` et `next.revalidate` sur les fetch |
| Build errors ERR_DYNAMIC | Marquer la page `export const dynamic = "force-dynamic"` ou fixer les appels dynamiques |
| Middleware lent | Reduire le matcher, eviter les fetch dans le middleware |
| Hydration mismatch | Aucun random/Date.now() dans le SSR sans suppressHydrationWarning |

## Verification

```bash
npm run build              # Verifier le build + taille bundle
npm run build -- --debug   # Log detaille
npx @next/bundle-analyzer  # Visualiser les chunks
```

## Complement avec le socle

- Rule `.claude/rules/nextjs.md` : rules path-specific (activation auto sur `app/**`)
- Rule `.claude/rules/performance.md` : Core Web Vitals
- Skill `dev-react-perf` : memoization, lazy loading React
- Skill `qa-chrome` : audit visuel de pages Next

## Output attendu

1. **App Router** par defaut (pas Pages Router sauf migration partielle)
2. **Server Components** par defaut, "use client" uniquement si necessaire
3. **Caching explicite** sur chaque fetch (force-cache, no-store, ou revalidate)
4. **Validation Zod** sur les Server Actions et Route Handlers
5. **Metadata API** pour SEO (jamais `<head>` manuel dans App Router)

## Regles

IMPORTANT: "use client" est l'exception, pas la regle. Par defaut, tout est Server Component.

IMPORTANT: Next 15+ : fetch n'est plus cache par defaut. Toujours specifier le comportement de cache.

IMPORTANT: Valider les inputs Server Action avec Zod avant mutation.

YOU MUST utiliser `revalidatePath` ou `revalidateTag` apres chaque mutation pour invalider le cache.

NEVER fetch dans le middleware (Edge, lent).

NEVER exposer de logique metier dans un Route Handler sans verifier l'auth.

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux nextjs..."_
- _"Je veux use client..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
