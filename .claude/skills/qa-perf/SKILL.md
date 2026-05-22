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

# Performance Optimization (pointer)

Canonical thresholds, current Web Vitals (LCP/INP/CLS — note INP replaced FID in 2024), and Chrome perf-team remediation patterns are at:

- **`addyosmani/web-quality-skills`** — [github.com/addyosmani/web-quality-skills](https://github.com/addyosmani/web-quality-skills) (MIT, 1.8k★, maintained by Addy Osmani — Chrome DevTools / Lighthouse engineering lead). Covers Core Web Vitals, perf, a11y, SEO.
- **web.dev/vitals** — [web.dev/vitals](https://web.dev/vitals) (Google's canonical Web Vitals reference)
- **Vercel React best practices** — see `vercel-react-best-practices` skill (foundation-installed) for React-specific patterns

## Foundation workflow (when to invoke this skill)

`qa-perf` is dispatched by `qa-loop` during the AUDIT phase, in parallel with `qa-security` / `wcag-audit` / `qa-claudemd`. It's a **measurement workflow**, not an optimisation cookbook:

1. **Measure first**: run Lighthouse / WebPageTest / DevTools Performance against a *known scope* (the URL, page, or endpoint from `argument-hint`).
2. **Compare to canonical thresholds** (see table below).
3. **Identify the bottleneck axis**: render-blocking JS? N+1 DB query? Image weight? Bundle size? Each axis has a dedicated vendor remediation guide.
4. **Recommend with quantified impact** (e.g. "lazy-loading hero image saves ~400ms LCP per Lighthouse run #3").
5. **Re-measure after the fix** — a perf change without before/after numbers is theatre.

## Canonical Web Vitals thresholds (2024-2026)

| Metric | Good | Needs improvement | Poor | Tool |
|---|---|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | 2.5–4s | > 4s | Lighthouse, web-vitals |
| **INP** (Interaction to Next Paint, replaces FID) | < 200ms | 200–500ms | > 500ms | web-vitals |
| **CLS** (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 | Lighthouse, web-vitals |
| **TTFB** | < 200ms | 200–600ms | > 600ms | DevTools Network |

## Foundation discipline (keep across releases)

- **No optimisation without measurement**: profile before changing code. Guessed bottlenecks are wrong ~70% of the time.
- **Before/after numbers mandatory**: every perf PR must include the Lighthouse delta or equivalent. Without numbers, the work is unprovable.
- **Cache invalidation > caching**: adding a cache is easy; correctly invalidating it is the bug surface. Surface cache TTLs in code review.
- **N+1 is the #1 backend perf bug**: when an endpoint feels slow, instrument query count before optimising anything else.

## See also

- `qa-chrome` skill — DevTools manual review (paired layer)
- `dev-react-perf` skill — React-specific re-render audit + memoization patterns
- `ops-monitoring` — production perf instrumentation (OTEL, RUM)
- `vercel-react-best-practices` skill (foundation-installed)
- Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`
