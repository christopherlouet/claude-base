---
name: feature-flags
description: Feature flags and toggles management. Trigger when the user wants to implement feature flagging, A/B testing, or progressive deployment.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
user-invocable: false
---

# Feature Flags (pointer)

SDK code, targeting rules syntax and dashboard integration drift on each vendor release and are canonical at:

- **LaunchDarkly** — [launchdarkly.com/docs](https://launchdarkly.com/docs) (SaaS, advanced targeting + experimentation)
- **Unleash** — [docs.getunleash.io](https://docs.getunleash.io) (self-hosted open source)
- **ConfigCat** — [configcat.com/docs](https://configcat.com/docs) (SaaS, generous free tier)
- **PostHog Feature Flags** — [posthog.com/docs/feature-flags](https://posthog.com/docs/feature-flags) (paired with product analytics; see also recipe)
- **OpenFeature** — [openfeature.dev](https://openfeature.dev) (vendor-neutral SDK standard — use to avoid lock-in)

## Use-case taxonomy (version-agnostic)

| Type | Purpose | Lifetime |
|---|---|---|
| **Release toggle** | Deploy inactive code; flip on after smoke test | Short (days/weeks) |
| **Experiment toggle** | A/B test; emits exposure events for analysis | Bounded by experiment duration |
| **Ops toggle** | Circuit breakers, kill switches, degraded modes | Long-lived |
| **Permission toggle** | Feature gating by role/plan/cohort | Permanent (treat like config) |

Choose by lifetime: short → cheap implementation, long-lived → invest in observability + naming discipline.

## Foundation discipline (keep across releases)

- **Default OFF**: every flag defaults to its conservative value (usually off). A flag that ships defaulting to ON is a hidden behaviour change.
- **2-sprint rule**: remove release toggles within 2 sprints of full rollout. Stale flags accrue as tech debt — surface them via `qa-tech-debt`.
- **Log every evaluation**: missing evaluation logs make debugging "why did user X see variant Y" impossible. Vendor SDKs offer this; if rolling custom, log it.
- **No business logic in flag values**: a flag is a boolean (or enum); complex conditions belong in code paths the flag selects, not inside the flag service.
- **Naming convention**: `<scope>_<feature>_<variant>` (e.g. `checkout_express_enabled`). Scope-first sorts/filters cleanly in dashboards.

## See also

- `growth-ab-test` skill — experiment design, sample-size, exposure analysis (consumes experiment toggles)
- `qa-tech-debt` — flag-debt scan surfaces stale flags past the 2-sprint window
- `dev-tdd` — flag-gated code paths must be tested in BOTH states (on/off), not just the new path
