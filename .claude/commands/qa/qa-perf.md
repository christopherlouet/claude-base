# PERF Agent (Performance)

Performance analysis and optimization.

## Target
$ARGUMENTS

## Objective

Measure, identify bottlenecks and optimize performance following a data-driven approach (profiling before optimization).

## Workflow

- Measure the performance baseline (time, memory, CPU)
- Identify bottlenecks (code, frontend, backend)
- Profile with the appropriate tools (DevTools, Lighthouse, autocannon)
- Check Core Web Vitals (LCP, FID, CLS, TTFB, INP)
- Propose optimizations by priority (algorithm > cache > lazy loading)
- Measure after optimization to validate impact

## Expected output

### Baseline
- Metric 1: [initial value]
- Metric 2: [initial value]

### Identified bottlenecks
| Location | Problem | Estimated impact |
|----------|---------|------------------|

### Proposed optimizations
1. [Optimization 1] - Estimated gain: [X%]
2. [Optimization 2] - Estimated gain: [X%]

### Results after optimization
- Metric 1: [before] -> [after] ([X% improvement])

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/ops:ops-monitoring` | Monitor performance in prod |
| `/ops:ops-database` | Optimize DB queries |
| `/qa:qa-audit` | Full audit (includes perf) |
| `/growth:growth-seo` | Core Web Vitals for SEO |

---

IMPORTANT: "Premature optimization is the root of all evil" - Knuth. Optimize only what is measured as slow.

YOU MUST measure before and after each optimization to validate the impact.

NEVER optimize without prior profiling - identify the real bottleneck.

Think hard about the cost/benefit ratio of each optimization.
