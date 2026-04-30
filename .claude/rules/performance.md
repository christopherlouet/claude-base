---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.ts"
  - "**/pages/**"
  - "**/app/**"
  - "**/api/**"
---

# Performance Rules

## Core Web Vitals

| Metric | Target | Description |
|----------|-------|-------------|
| **LCP** | < 2.5s | Largest Contentful Paint |
| **INP** | < 200ms | Interaction to Next Paint |
| **CLS** | < 0.1 | Cumulative Layout Shift |

## Images
- Use `next/image` with explicit `width`/`height`
- `priority` for above-the-fold images, `loading="lazy"` for the rest
- Modern formats: AVIF/WebP with fallback

## JavaScript
- Code splitting with `dynamic()` or `React.lazy()` for heavy components
- `React.memo` for expensive components, `useMemo`/`useCallback` for computations/functions
- Debounce (search: 300ms) and throttle (scroll: 100ms)

## CSS
- Reserve space with `aspect-ratio` to avoid CLS
- Preload fonts (`rel="preload"`, `as="font"`)

## Data fetching
- Cache with SWR/React Query (`staleTime`, `dedupingInterval`)
- Pagination or infinite scroll (never load all the data)

## Bundle
- Specific imports (`import { debounce } from 'lodash-es'`, not `import _ from 'lodash'`)
- Analyze with `ANALYZE=true npm run build`

## Preloading
- `rel="prefetch"` for likely routes
- `rel="dns-prefetch"` for external domains
- `rel="preload"` for critical resources of the initial render
- PRPL pattern: Push (critical) / Render (initial route) / Pre-cache (others) / Lazy-load (rest)

## Advanced lazy loading
- By visibility: `IntersectionObserver` or `loading="lazy"` for off-screen components/media
- By interaction: load on hover/focus before the click (preconnect + import())
- Virtual lists for lists > 100 items (`react-window`, `@tanstack/react-virtual`)

## Bundle (continued)
- Tree-shaking: ESM only, `sideEffects: false` in `package.json`, named imports
- Vite: `build.rollupOptions.output.manualChunks` to split vendors, analyze via `rollup-plugin-visualizer`
- Third-party scripts: `<Script strategy="lazyOnload">` (Next.js) or defer/async + Partytown to offload to a worker

## Modern rendering patterns
- Islands Architecture: hydrate only interactive zones (Astro, Fresh)
- View Transitions API: `document.startViewTransition()` for SPA-like transitions without a framework
- Streaming SSR + Suspense: send the shell early, stream content as it's ready
- Progressive/Selective Hydration: React 18+ hydrates by interaction priority
- ISR (Incremental Static Regeneration): `revalidate` for semi-static pages

## IMPORTANT Rules

IMPORTANT: LCP < 2.5s - Optimize above-the-fold images.
IMPORTANT: INP < 200ms - Avoid blocking operations.
IMPORTANT: CLS < 0.1 - Always specify media dimensions.
YOU MUST use code splitting for large components.
YOU MUST memoize expensive components (React.memo, useMemo).
NEVER load entire libraries (lodash, moment).
NEVER block the main thread with heavy computations.
