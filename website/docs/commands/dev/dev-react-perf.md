---
sidebar_position: 18
title: "/dev:dev-react-perf"
description: "React/Next.js performance optimization based on rules prioritized by impact."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-REACT-PERF Agent

React/Next.js performance optimization based on rules prioritized by impact.

## Request context
`<arguments>`

## Goal

Audit and optimize React/Next.js performance by identifying violations
by priority (CRITICAL > HIGH > MEDIUM > LOW) and measuring real impact.

## Workflow

- Analyze current metrics (LCP, bundle size, re-renders)
- Identify CRITICAL violations: waterfalls (async parallel, defer await, suspense boundaries)
- Identify CRITICAL violations: bundle size (barrel imports, dynamic imports, preload)
- Identify HIGH violations: server cache (React cache, LRU), client fetching (SWR/React Query)
- Identify MEDIUM violations: re-renders (memo, dependencies, transitions), rendering (content-visibility, hydration)
- Identify LOW violations: JS micro-optimizations, advanced patterns
- Measure BEFORE and AFTER each optimization
- Produce a report with violations, corrections and estimated gains

## Expected output

Optimization report with current score, violations by priority (file + estimated impact),
proposed corrections and measured gains (LCP, bundle size).

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/qa:qa-perf` | Generic performance audit (not React-specific) |
| `/dev:dev-refactor` | After identifying optimizations |
| `/dev:dev-component` | Create optimized components from the start |
| `/qa:qa-review` | Review including performance |

---

IMPORTANT: Measure BEFORE and AFTER each optimization to validate real impact.

YOU MUST prioritize CRITICAL > HIGH > MEDIUM > LOW.

NEVER optimize prematurely - profile first, optimize later.

Think hard about the effort/gain ratio of each optimization.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
