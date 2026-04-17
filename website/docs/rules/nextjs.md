---
sidebar_position: 14
title: "nextjs"
description: "Next.js Rules"
tags:
  - "rule"
  - "nextjs"
---

# Regles: nextjs

> Next.js Rules

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/next.config.*`
- `**/app/**`
- `**/pages/**`
- `**/middleware.ts`
- `**/middleware.js`

## Regles detaillees

# Next.js Rules

## App Router (Next.js 13+)

- Utiliser le App Router (`app/`) sauf migration depuis `pages/`
- Fichiers speciaux : `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`

## Server vs Client Components

- Par defaut : Server Component (RSC)
- `'use client'` : Client Component (interactivite) - pousser le plus bas possible
- `'use server'` : Server Action (mutations)
- RSC ne peuvent PAS utiliser hooks (useState, useEffect) ni acceder au DOM
- Client Components ne peuvent PAS utiliser `async/await` directement

## Data Fetching

| Pattern | Quand |
|---------|-------|
| Server Component fetch | Donnees statiques/SSR |
| Server Actions | Mutations (forms) |
| Route Handlers | API endpoints (`app/api/route.ts`) |
| Client fetch (SWR/Query) | Donnees temps reel |

- Paralleliser avec `Promise.all()` (eviter les cascades sequentielles)

## Caching et revalidation

| Methode | Usage |
|---------|-------|
| `revalidatePath()` | Invalider une page apres mutation |
| `revalidateTag()` | Invalider par tag de cache |
| `export const revalidate = 60` | ISR (revalidation periodique) |

## Performance

- `next/image` pour toutes les images, `next/font` pour les polices, `next/link` pour la navigation
- `loading.tsx` pour les Suspense boundaries
- `dynamic()` avec `ssr: false` pour composants lourds
- Metadata statique (`export const metadata`) ou dynamique (`generateMetadata`)

## Streaming et Suspense

- Utiliser `loading.tsx` pour les Suspense boundaries automatiques par route
- Wrapper les composants async dans `&lt;Suspense fallback=\{...\}&gt;` pour du streaming granulaire
- Pattern de rendering progressif :

```tsx
// page.tsx - Le layout s'affiche immediatement, les donnees streament
export default function Page() {
  return (
    <main>
      <Header />               {/* Rendu immediat */}
      <Suspense fallback={<Skeleton />}>
        <AsyncData />           {/* Streame quand pret */}
      </Suspense>
    </main>
  );
}
```

- `loading.tsx` + `&lt;Suspense&gt;` = streaming automatique (pas besoin de `export const dynamic`)
- Eviter les cascades : paralleliser les fetches dans un meme Server Component

## Server Components - Contraintes strictes

| Autorise dans RSC | INTERDIT dans RSC |
|-------------------|-------------------|
| `async/await` | `useState`, `useEffect`, tout hook |
| Acces DB direct | Event handlers (`onClick`, `onChange`) |
| Acces filesystem | APIs navigateur (`window`, `document`) |
| Import serveur only | `createContext` |

- RSC toujours `async` quand ils fetchent des donnees
- Passer les donnees en props aux Client Components (pas l'inverse)
- Pattern : RSC fetch → Client Component interactif en enfant

## React 19 / Next.js 15+

- `forwardRef` n'est plus necessaire : `ref` est une prop directe
- `useActionState` remplace `useFormState`
- `use()` pour lire les promises/context dans les composants
- `&lt;form action=\{serverAction\}&gt;` pour les mutations

## URL State Management

- Preferer `nuqs` ou `useSearchParams` pour l'etat dans l'URL
- Meilleur pour : filtres, pagination, onglets, tri
- Eviter `useState` pour de l'etat qui devrait etre partageable par URL

## Anti-patterns

- NE PAS utiliser `'use client'` sur les pages/layouts sauf necessite absolue
- NE PAS fetch dans useEffect si un Server Component peut fournir les donnees
- NE PAS utiliser `router.push()` quand un `&lt;Link&gt;` suffit
- NE PAS utiliser `getServerSideProps`/`getStaticProps` avec App Router
- NE PAS oublier les Suspense boundaries (cause de mauvais LCP/CLS)
- NE PAS utiliser `forwardRef` dans un projet React 19+

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
