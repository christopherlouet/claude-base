---
sidebar_position: 12
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

## Anti-patterns

- NE PAS utiliser `'use client'` sur les pages/layouts sauf necessite absolue
- NE PAS fetch dans useEffect si un Server Component peut fournir les donnees
- NE PAS utiliser `router.push()` quand un `&lt;Link&gt;` suffit
- NE PAS utiliser `getServerSideProps`/`getStaticProps` avec App Router

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
