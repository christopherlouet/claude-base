---
sidebar_position: 41
title: "qa-perf"
description: "Application performance optimization. Trigger when the user wants to improve speed, reduce latency, or optimize resources."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-perf

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Application performance optimization. Trigger when the user wants to improve speed, reduce latency, or optimize resources.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `perf` |

## Detailed description

# Performance Optimization

## Key metrics

| Metric | Target | Tool |
|--------|--------|------|
| TTFB | < 200ms | DevTools |
| LCP | < 2.5s | Lighthouse |
| FID | < 100ms | Web Vitals |
| CLS | < 0.1 | Lighthouse |

## Backend

### Database
```sql
-- Index on frequently filtered columns
CREATE INDEX idx_users_email ON users(email);

-- EXPLAIN to analyze
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Avoid N+1 with JOIN
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

## Tools

```bash
# Lighthouse
npx lighthouse https://example.com --view

# Bundle analyzer
npm run build -- --analyze

# Node.js profiling
node --prof app.js
```

## See also

[`addyosmani/web-quality-skills`](https://github.com/addyosmani/web-quality-skills) (1,862★, last commit 2026-05-03) is maintained by Addy Osmani — Chrome DevTools / Lighthouse engineering lead at Google for ~14 years. Covers Core Web Vitals (LCP, INP, CLS), perf, accessibility, and SEO. Independent personal repo, MIT.

When working on a project that targets Web Vitals optimisation, install this vendor skill alongside `qa-perf`. This skill captures the **measurement workflow** (profiling commands, when to invoke, foundation conventions); the vendor skill captures the **canonical thresholds and remediation patterns** that Chrome's performance team enforces. Both together is the recommended setup.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to perf..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


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

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
