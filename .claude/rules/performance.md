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

## Regles IMPORTANTES

IMPORTANT: LCP < 2.5s - Optimiser les images above-the-fold.
IMPORTANT: INP < 200ms - Eviter les operations bloquantes.
IMPORTANT: CLS < 0.1 - Toujours specifier les dimensions des medias.
YOU MUST utiliser le code splitting pour les gros composants.
YOU MUST memoizer les composants couteux (React.memo, useMemo).
NEVER charger de bibliotheques entieres (lodash, moment).
NEVER bloquer le thread principal avec des calculs lourds.
