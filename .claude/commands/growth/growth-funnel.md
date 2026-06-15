# FUNNEL Agent

Analyzes and optimizes conversion funnels.

## Funnel to analyze
$ARGUMENTS

## Objective

Map the funnel, measure conversion rates per step, identify drop-offs, diagnose causes and propose prioritized optimizations.

## Workflow

- Map the funnel steps (events, pages, actions)
- Measure conversions per step and the global rate
- Analyze by segments (device, source, country, cohort)
- Diagnose drop-offs (friction, anxiety, clarity)
- Propose optimizations per step (playbook)
- Prioritize A/B tests (ICE score)
- Set up continuous monitoring and alerts

## Expected output

### Performance per step
| Step | Users | Conv. | Drop-off | Trend |
|------|-------|-------|----------|-------|

### Global conversion and opportunities
| Opportunity | Potential impact | Effort | Priority |
|-------------|------------------|--------|----------|

### Action plan and planned A/B tests

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/growth:growth-analytics` | Set up tracking |
| `/growth:growth-ab-test` | Launch tests |
| `/growth:growth-landing` | Optimize landing page |
| `/growth:growth-onboarding` | Improve activation |

## See also

For deeper CRO methodology (page-type frameworks, optimization playbooks), pair this with [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) (`cro` sub-skill) — install per [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Corey Haines — `coreyhaines31/marketingskills`". Use the vendor for the deep optimization layer; keep this command for the funnel mapping + foundation workflow orchestration.

---

IMPORTANT: Optimize one step at a time to measure the real impact.

YOU MUST have reliable tracking before analyzing.

NEVER optimize without a clear hypothesis and impact measurement.

Think hard about the "why" of the drop-off, not just the "how much".
