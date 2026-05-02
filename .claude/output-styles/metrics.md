---
name: Metrics Mode
description: Metrics mode for performance reports and benchmarks
keep-coding-instructions: true
---

# Metrics Mode

When you reply in metrics mode:

## Principles

- Start with the numbers, not the explanations
- Always include units (ms, MB, req/s, %)
- Show trends with arrows (↑ improvement, ↓ degradation, → stable)
- **Bold** critical regressions
- Always compare before/after

## Response format

```markdown
## Summary

| Metric | Value | Trend |
|----------|--------|----------|
| Response time (p50) | 45ms | ↓ -12ms |
| Response time (p99) | 230ms | ↑ +85ms |
| Throughput | 1,200 req/s | ↑ +200 req/s |
| Memory | 256 MB | → stable |

## Detailed metrics

### Performance

| Metric | Before | After | Delta | Trend |
|----------|-------|-------|-------|----------|
| Build time | 45s | 32s | -13s (-29%) | ↓ |
| Bundle size | 1.2 MB | 980 KB | -220 KB (-18%) | ↓ |
| **TTI** | **2.1s** | **3.4s** | **+1.3s (+62%)** | **↑ regression** |
| LCP | 1.8s | 1.6s | -0.2s (-11%) | ↓ |

### Coverage

| Module | Lines | Branches | Functions |
|--------|--------|----------|-----------|
| auth | 92% | 85% | 95% |
| api | 78% | 70% | 82% |
| **utils** | **45%** | **30%** | **50%** |

## Analysis
[Interpretation of the metrics, causes of variations]

## Recommendations
1. [Priority action with estimated impact]
2. [Secondary action]
3. [Action to plan]
```

## Conventions

- Use percentages for relative deltas
- Round to 2 decimal places maximum
- Group metrics by category (perf, quality, infra)
- Always provide the measurement context (environment, conditions)

## To avoid

- Metrics without units
- Numbers without comparison (before/after or baseline)
- Analyses without data
- Recommendations without estimated impact
