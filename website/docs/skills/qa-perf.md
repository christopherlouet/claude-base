---
sidebar_position: 33
title: "qa-perf"
description: "Optimisation des performances d'applications. Declencher quand l'utilisateur veut ameliorer la vitesse, reduire la latence, ou optimiser les ressources."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-perf

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Optimisation des performances d'applications. Declencher quand l'utilisateur veut ameliorer la vitesse, reduire la latence, ou optimiser les ressources.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `perf`, `/photo.jpg` |

## Description detaillee

# Performance Optimization

## Metriques cles

| Metrique | Cible | Outil |
|----------|-------|-------|
| TTFB | < 200ms | DevTools |
| LCP | < 2.5s | Lighthouse |
| FID | < 100ms | Web Vitals |
| CLS | < 0.1 | Lighthouse |

## Backend

### Database
```sql
-- Index sur colonnes frequemment filtrees
CREATE INDEX idx_users_email ON users(email);

-- EXPLAIN pour analyser
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Eviter N+1 avec JOIN
SELECT u.*, p.* FROM users u
LEFT JOIN posts p ON p.user_id = u.id;
```

### Caching
```typescript
// Redis cache
async function getUser(id: string) {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  const user = await db.user.findUnique({ where: { id } });
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  return user;
}
```

### Connection pooling
```typescript
const pool = new Pool({
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

## Frontend

### Code splitting
```tsx
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

### Image optimization
```tsx
<Image src="/photo.jpg" width={800} height={600} priority />
```

### Memoization
```tsx
const value = useMemo(() => expensive(data), [data]);
const handler = useCallback(() => action(id), [id]);
```

## Outils

```bash
# Lighthouse
npx lighthouse https://example.com --view

# Bundle analyzer
npm run build -- --analyze

# Profiling Node.js
node --prof app.js
```

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux perf..."_
- _"Je veux /photo.jpg..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Performance Audit Report

# Example: Performance Audit Report

## Scenario
Audit a Next.js e-commerce site with poor Core Web Vitals scores.

## Lighthouse Results (Before)

| Metric | Score | Value | Target |
|--------|-------|-------|--------|
| Performance | 42 | - | > 90 |
| LCP | Poor | 4.8s | < 2.5s |
| FID/INP | Needs Improvement | 280ms | < 200ms |
| CLS | Poor | 0.35 | < 0.1 |
| FCP | Needs Improvement | 2.1s | < 1.8s |
| TTFB | Poor | 1.2s | < 0.8s |

## Issues Identified

### 1. LCP: Unoptimized hero image (4.8s)
```
- Hero image: 2.4MB PNG, no lazy loading, no srcset
- Fix: next/image with priority, WebP format, responsive sizes
```

### 2. CLS: Layout shifts from web fonts + images (0.35)
```
- No width/height on images causing reflow
- FOUT from Google Fonts loaded client-side
- Fix: font-display: swap + preload, explicit image dimensions
```

### 3. INP: Heavy JS on product grid (280ms)
```
- 450KB unminified JS bundle on initial load
- Synchronous filtering on 500+ products
- Fix: dynamic import, virtualized list, debounced filters
```

### 4. TTFB: No caching strategy (1.2s)
```
- Every page request hits database
- Fix: ISR with revalidate: 60, CDN caching headers
```

## Recommended Fixes

```typescript
// 1. Optimized hero image
<Image src="/hero.webp" alt="Sale" width={1200} height={600} priority
  sizes="(max-width: 768px) 100vw, 1200px" />

// 2. Font optimization in next.config
import { Inter } from 'next/font/google';
const inter = Inter({ subsets: ['latin'], display: 'swap' });

// 3. Dynamic import for heavy component
const ProductFilters = dynamic(() => import('./ProductFilters'), {
  loading: () => <FilterSkeleton />,
});

// 4. ISR caching
export async function getStaticProps() {
  const products = await getProducts();
  return { props: { products }, revalidate: 60 };
}
```

## Results (After)

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Performance | 42 | 94 | +52 points |
| LCP | 4.8s | 1.8s | -62% |
| INP | 280ms | 120ms | -57% |
| CLS | 0.35 | 0.04 | -89% |
| TTFB | 1.2s | 0.3s | -75% |

## Key Decisions

- **next/image with priority**: Preloads LCP image, auto-optimizes format and size
- **ISR over SSR**: Static generation with revalidation eliminates per-request DB hits
- **Dynamic imports**: Code-split heavy components, load on interaction
- **Font subsetting**: `next/font` self-hosts and subsets, eliminates external request



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
