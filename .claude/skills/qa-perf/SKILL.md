---
name: qa-perf
description: Application performance optimization. Trigger when the user wants to improve speed, reduce latency, or optimize resources.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[page-or-endpoint]"
---

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
