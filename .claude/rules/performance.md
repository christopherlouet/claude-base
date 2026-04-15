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

| Metrique | Cible | Description |
|----------|-------|-------------|
| **LCP** | < 2.5s | Largest Contentful Paint |
| **INP** | < 200ms | Interaction to Next Paint |
| **CLS** | < 0.1 | Cumulative Layout Shift |

## Images
- Utiliser `next/image` avec `width`/`height` explicites
- `priority` pour images above-the-fold, `loading="lazy"` pour le reste
- Formats modernes : AVIF/WebP avec fallback

## JavaScript
- Code splitting avec `dynamic()` ou `React.lazy()` pour composants lourds
- `React.memo` pour composants couteux, `useMemo`/`useCallback` pour calculs/fonctions
- Debounce (recherche: 300ms) et throttle (scroll: 100ms)

## CSS
- Reserver l'espace avec `aspect-ratio` pour eviter CLS
- Preload des fonts (`rel="preload"`, `as="font"`)

## Data fetching
- Cache avec SWR/React Query (`staleTime`, `dedupingInterval`)
- Pagination ou infinite scroll (jamais charger toutes les donnees)

## Bundle
- Imports specifiques (`import { debounce } from 'lodash-es'`, pas `import _ from 'lodash'`)
- Analyser avec `ANALYZE=true npm run build`

## Preloading
- `rel="prefetch"` pour routes probables
- `rel="dns-prefetch"` pour domaines externes
- `rel="preload"` pour ressources critiques du rendu initial
- Pattern PRPL : Push (critique) / Render (initial route) / Pre-cache (autres) / Lazy-load (reste)

## Lazy loading avance
- Par visibilite : `IntersectionObserver` ou `loading="lazy"` pour composants/media hors ecran
- Par interaction : charger au hover/focus avant le click (preconnect + import())
- Virtual lists pour listes > 100 items (`react-window`, `@tanstack/react-virtual`)

## Bundle (suite)
- Tree-shaking : ESM only, `sideEffects: false` dans `package.json`, imports nommes
- Vite : `build.rollupOptions.output.manualChunks` pour separer vendors, analyze via `rollup-plugin-visualizer`
- Scripts tiers : `<Script strategy="lazyOnload">` (Next.js) ou defer/async + Partytown pour offload worker

## Rendering patterns modernes
- Islands Architecture : hydrater uniquement les zones interactives (Astro, Fresh)
- View Transitions API : `document.startViewTransition()` pour transitions SPA-like sans framework
- Streaming SSR + Suspense : envoyer le shell tot, streamer le contenu pret
- Progressive/Selective Hydration : React 18+ hydrate par priorite d'interaction
- ISR (Incremental Static Regeneration) : `revalidate` pour pages semi-statiques

## Regles IMPORTANTES

IMPORTANT: LCP < 2.5s - Optimiser les images above-the-fold.
IMPORTANT: INP < 200ms - Eviter les operations bloquantes.
IMPORTANT: CLS < 0.1 - Toujours specifier les dimensions des medias.
YOU MUST utiliser le code splitting pour les gros composants.
YOU MUST memoizer les composants couteux (React.memo, useMemo).
NEVER charger de bibliotheques entieres (lodash, moment).
NEVER bloquer le thread principal avec des calculs lourds.
