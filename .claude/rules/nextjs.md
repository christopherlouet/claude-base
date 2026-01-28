---
paths:
  - "**/next.config.*"
  - "**/app/**"
  - "**/pages/**"
  - "**/middleware.ts"
  - "**/middleware.js"
---

# Next.js Rules

## Architecture

### App Router (Next.js 13+)

- Utiliser le App Router (`app/`) sauf si migration depuis `pages/`
- Chaque route est un dossier avec `page.tsx`
- Fichiers speciaux : `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`

### Server vs Client Components

```
Par defaut : Server Component (RSC)
'use client' : Client Component (interactivite)
'use server' : Server Action (mutations)
```

**Regles RSC :**
- Les Server Components ne peuvent PAS utiliser hooks (useState, useEffect)
- Les Server Components ne peuvent PAS acceder au DOM ou browser APIs
- Les Client Components ne peuvent PAS utiliser `async/await` directement
- Pousser `'use client'` le plus bas possible dans l'arbre

### Patterns de composition

```typescript
// BON : Server Component parent, Client Component enfant
// app/page.tsx (Server)
export default async function Page() {
  const data = await fetchData(); // Fetch cote serveur
  return <ClientComponent data={data} />;
}

// MAUVAIS : Client Component en haut qui englobe tout
'use client'
export default function Page() {
  const [data, setData] = useState(null);
  useEffect(() => { fetch('/api/data')... }, []);
  return <div>{/* tout est client */}</div>;
}
```

## Data Fetching

### Patterns recommandes

| Pattern | Quand | Comment |
|---------|-------|---------|
| **Server Component fetch** | Donnees statiques/SSR | `async function Page() { const data = await fetch(...) }` |
| **Server Actions** | Mutations (forms) | `'use server'` + `action={serverAction}` |
| **Route Handlers** | API endpoints | `app/api/route.ts` |
| **Client fetch** | Donnees temps reel | `useSWR` ou `useQuery` |

### Eviter les cascades de requetes

```typescript
// MAUVAIS : Sequential (cascade)
const user = await getUser(id);
const posts = await getPosts(user.id);
const comments = await getComments(posts[0].id);

// BON : Parallel
const [user, posts] = await Promise.all([
  getUser(id),
  getPosts(id),
]);
```

## Caching et revalidation

### Strategies

| Methode | Usage |
|---------|-------|
| `revalidatePath()` | Invalider une page apres mutation |
| `revalidateTag()` | Invalider par tag de cache |
| `unstable_cache()` | Cache de fonctions avec tags |
| `export const revalidate = 60` | ISR (revalidation periodique) |

## Performance

### Optimisations essentielles

- Utiliser `next/image` pour toutes les images (optimisation auto)
- Utiliser `next/font` pour les polices (elimination du layout shift)
- Utiliser `next/link` pour la navigation (prefetch auto)
- Utiliser `loading.tsx` pour les Suspense boundaries
- Lazy load les composants lourds avec `dynamic()`

```typescript
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(() => import('./Chart'), {
  loading: () => <Skeleton />,
  ssr: false, // Si le composant necessite window/document
});
```

### Metadata et SEO

```typescript
// Metadata statique
export const metadata: Metadata = {
  title: 'Page Title',
  description: 'Description',
};

// Metadata dynamique
export async function generateMetadata({ params }): Promise<Metadata> {
  const product = await getProduct(params.id);
  return { title: product.name };
}
```

## Anti-patterns

- NE PAS utiliser `'use client'` sur les pages/layouts sauf necessite absolue
- NE PAS fetch des donnees dans useEffect si un Server Component peut les fournir
- NE PAS utiliser `router.push()` quand un `<Link>` suffit
- NE PAS ignorer les erreurs de build avec `// @ts-ignore` ou `any`
- NE PAS utiliser `getServerSideProps` / `getStaticProps` avec App Router

## Middleware

```typescript
// middleware.ts (racine du projet)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Auth check, redirect, headers...
  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```
