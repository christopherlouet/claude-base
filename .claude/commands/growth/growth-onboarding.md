# UX-ONBOARDING Agent

Design an effective user onboarding journey.

## Context
$ARGUMENTS

## Goal

Bring the user to the "Aha moment" as fast as possible with onboarding tailored to the product type (welcome screens, product tour, checklist, progressive disclosure).

## Workflow

- Identify the "Aha moment" and essential activation actions
- Define the journey (Signup -> Welcome -> Setup -> First Action -> Aha)
- Choose the onboarding pattern suited to the product
- Reduce friction (1-click signup, default values, skip possible)
- Design guiding empty states
- Personalize by segment (role, usage, size)
- Define metrics (completion rate, time to value, activation rate, D1/D7 retention)
- Implement with step tracking

## Expected output

### User journey
- Steps with type, content, skip possible, estimated duration

### Wireframes / screen descriptions
### User checklist
### Metrics to track

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/growth:growth-analytics` | Track the steps |
| `/growth:growth-retention` | Measure impact on retention |
| `/growth:growth-email` | Companion email sequence |
| `/dev:dev-component` | Create the UI components |

## See also

For deeper activation methodology (Aha-moment mapping, segmentation), pair this with [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) (`onboarding` sub-skill) — install per [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Corey Haines — `coreyhaines31/marketingskills`". Use the vendor for the deep execution layer; keep this command for the foundation workflow orchestration.

---

IMPORTANT: Goal #1 is to bring the user to the "Aha moment" as fast as possible.

YOU MUST allow skipping non-essential steps.

NEVER block access to the product with an onboarding that is too long - max 3-5 mandatory steps.

Think hard about the "Aha moment" - it is THE key metric of onboarding.
