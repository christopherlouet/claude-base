---
paths:
  - "**/next.config.*"
  - "**/app/**"
  - "**/pages/**"
  - "**/middleware.ts"
  - "**/middleware.js"
---

# Next.js Rules

## App Router (Next.js 13+)

- Use the App Router (`app/`) unless migrating from `pages/`
- Special files: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`

## Server vs Client Components

- By default: Server Component (RSC)
- `'use client'`: Client Component (interactivity) - push as low as possible
- `'use server'`: Server Action (mutations)
- RSCs CANNOT use hooks (useState, useEffect) or access the DOM
- Client Components CANNOT use `async/await` directly

## Data Fetching

| Pattern | When |
|---------|-------|
| Server Component fetch | Static/SSR data |
| Server Actions | Mutations (forms) |
| Route Handlers | API endpoints (`app/api/route.ts`) |
| Client fetch (SWR/Query) | Real-time data |

- Parallelize with `Promise.all()` (avoid sequential cascades)

## Caching and revalidation

| Method | Usage |
|---------|-------|
| `revalidatePath()` | Invalidate a page after a mutation |
| `revalidateTag()` | Invalidate by cache tag |
| `export const revalidate = 60` | ISR (periodic revalidation) |

## Performance

- `next/image` for all images, `next/font` for fonts, `next/link` for navigation
- `loading.tsx` for Suspense boundaries
- `dynamic()` with `ssr: false` for heavy components
- Static metadata (`export const metadata`) or dynamic (`generateMetadata`)

## Streaming and Suspense

- Use `loading.tsx` for automatic per-route Suspense boundaries
- Wrap async components in `<Suspense fallback={...}>` for granular streaming
- Progressive rendering pattern:

```tsx
// page.tsx - The layout displays immediately, data streams in
export default function Page() {
  return (
    <main>
      <Header />               {/* Rendered immediately */}
      <Suspense fallback={<Skeleton />}>
        <AsyncData />           {/* Streams when ready */}
      </Suspense>
    </main>
  );
}
```

- `loading.tsx` + `<Suspense>` = automatic streaming (no need for `export const dynamic`)
- Avoid cascades: parallelize fetches within the same Server Component

## Server Components - Strict constraints

| Allowed in RSC | FORBIDDEN in RSC |
|-------------------|-------------------|
| `async/await` | `useState`, `useEffect`, any hook |
| Direct DB access | Event handlers (`onClick`, `onChange`) |
| Filesystem access | Browser APIs (`window`, `document`) |
| Server-only imports | `createContext` |

- RSCs are always `async` when they fetch data
- Pass data as props to Client Components (not the other way around)
- Pattern: RSC fetch → interactive Client Component as a child

## React 19 / Next.js 15+

- `forwardRef` is no longer necessary: `ref` is a direct prop
- `useActionState` replaces `useFormState`
- `use()` to read promises/context in components
- `<form action={serverAction}>` for mutations

## URL State Management

- Prefer `nuqs` or `useSearchParams` for state in the URL
- Better for: filters, pagination, tabs, sorting
- Avoid `useState` for state that should be shareable via URL

## Anti-patterns

- DO NOT use `'use client'` on pages/layouts unless absolutely necessary
- DO NOT fetch in useEffect if a Server Component can provide the data
- DO NOT use `router.push()` when a `<Link>` is enough
- DO NOT use `getServerSideProps`/`getStaticProps` with App Router
- DO NOT forget Suspense boundaries (causes bad LCP/CLS)
- DO NOT use `forwardRef` in a React 19+ project
