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

### Optimisation

```tsx
// BON - Next.js Image avec dimensions
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // Pour images above-the-fold
  placeholder="blur"
  blurDataURL={blurData}
/>

// MAUVAIS - Image sans dimensions
<img src="/hero.jpg" alt="Hero" />
```

### Formats modernes

```tsx
// Utiliser AVIF/WebP avec fallback
<picture>
  <source srcSet="/image.avif" type="image/avif" />
  <source srcSet="/image.webp" type="image/webp" />
  <img src="/image.jpg" alt="Description" />
</picture>
```

### Lazy loading

```tsx
// BON - Lazy load images below-the-fold
<Image
  src="/image.jpg"
  alt="Description"
  loading="lazy"
  width={400}
  height={300}
/>

// Ne PAS lazy load les images above-the-fold
<Image
  src="/hero.jpg"
  priority
  // PAS de loading="lazy"
/>
```

## JavaScript

### Code splitting

```tsx
// BON - Import dynamique
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false,
});

// BON - React.lazy
const LazyComponent = React.lazy(() => import('./LazyComponent'));
```

### Eviter les re-renders

```tsx
// BON - Memoization
const ExpensiveComponent = React.memo(({ data }) => {
  return <div>{/* render */}</div>;
});

// BON - useMemo pour calculs couteux
const processedData = useMemo(() => {
  return heavyComputation(data);
}, [data]);

// BON - useCallback pour fonctions
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

### Debounce et throttle

```tsx
// BON - Debounce pour recherche
const debouncedSearch = useMemo(
  () => debounce((query: string) => search(query), 300),
  []
);

// BON - Throttle pour scroll
const throttledScroll = useMemo(
  () => throttle(() => handleScroll(), 100),
  []
);
```

## CSS

### Critical CSS

```tsx
// Inline critical CSS dans <head>
<style dangerouslySetInnerHTML={{ __html: criticalCSS }} />

// Preload des fonts
<link
  rel="preload"
  href="/fonts/inter.woff2"
  as="font"
  type="font/woff2"
  crossOrigin="anonymous"
/>
```

### Eviter les layout shifts

```css
/* BON - Reserver l'espace */
.image-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}

/* BON - Skeleton avec dimensions fixes */
.skeleton {
  width: 100%;
  height: 200px;
}
```

## API et data fetching

### Caching

```tsx
// BON - SWR avec cache
const { data } = useSWR('/api/users', fetcher, {
  revalidateOnFocus: false,
  dedupingInterval: 60000,
});

// BON - React Query avec staleTime
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 5 * 60 * 1000, // 5 minutes
});
```

### Pagination

```tsx
// BON - Pagination ou infinite scroll
const { data, fetchNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam = 0 }) => fetchPosts(pageParam),
  getNextPageParam: (lastPage) => lastPage.nextCursor,
});

// MAUVAIS - Charger toutes les donnees
const { data } = useQuery(['posts'], () => fetchAllPosts());
```

## Bundle size

### Imports specifiques

```tsx
// BON - Import specifique
import { debounce } from 'lodash-es';

// MAUVAIS - Import complet
import _ from 'lodash';
```

### Analyser le bundle

```bash
# Next.js
ANALYZE=true npm run build

# Webpack
npx webpack-bundle-analyzer stats.json
```

## Preloading

```tsx
// Preload des routes probables
<link rel="prefetch" href="/dashboard" />

// Preload des donnees
<link
  rel="preload"
  href="/api/user"
  as="fetch"
  crossOrigin="anonymous"
/>

// DNS prefetch pour domaines externes
<link rel="dns-prefetch" href="https://api.example.com" />
```

## Regles IMPORTANTES

IMPORTANT: LCP < 2.5s - Optimiser les images above-the-fold.

IMPORTANT: INP < 200ms - Eviter les operations bloquantes.

IMPORTANT: CLS < 0.1 - Toujours specifier les dimensions des medias.

YOU MUST utiliser le code splitting pour les gros composants.

YOU MUST memoizer les composants couteux (React.memo, useMemo).

NEVER charger de bibliotheques entieres (lodash, moment).

NEVER bloquer le thread principal avec des calculs lourds.
