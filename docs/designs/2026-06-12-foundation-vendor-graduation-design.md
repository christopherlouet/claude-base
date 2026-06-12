# Design: Foundation-maintained → vendor-pointer graduation

**Date**: 2026-06-12 · **Status**: direction note (not yet a spec)
**Builds on**: [`2026-06-09-core-plus-thematic-modules-design.md`](2026-06-09-core-plus-thematic-modules-design.md) (the minimal-core + composable-modules model this graduation rides on) · the **curator** role in the root `README.md`

## Thesis

The foundation's tool/framework **depth** (skills like `dev-prisma`, `dev-nextjs`,
`dev-shadcn`, `dev-flutter`, `dev-supabase`, `dev-graphql`, …) is a **stopgap**:
maintained in-house only *while the community has not yet published something
better*. As a trusted vendor skill matures for a given tool, the foundation skill
should **graduate** — its content stops being maintained here and the preset
**points** to the vendor via `recommendedVendorSkills` instead.

This is not a new direction; it is the explicit **"Workflow framework + curator"**
role stated in the README ("a 1-maintainer project can't out-update a 6,700+ skill
ecosystem refreshed daily"). This note makes the lifecycle explicit so future
preset/module decisions are deliberate rather than ad hoc.

## Two natures of foundation content (different destinies)

| Nature | Examples | Destiny |
|--------|----------|---------|
| **Tool/framework depth** (stopgap) | `dev-prisma`, `dev-nextjs`, `dev-shadcn`, `dev-flutter`, `dev-supabase`, `dev-graphql`, `dev-rag`, `dev-mcp`… | **Graduatable** → becomes a `recommendedVendorSkills` pointer when a trusted vendor matures. |
| **Durable workflow patterns** (the moat) | the Explore→Specify→Plan→TDD→Audit→Commit discipline, `qa-loop`, `deploy-safety`, anti-drift counters, hooks wiring, orchestration (`work-*`, `parallel-agents`, `agent-teams`, `git-worktrees`), `gitflow` (a workflow, not a tool) | **Permanent** — survives vendor churn; no vendor publishes these as a "skill". |
| **Curation itself** | the trusted-vendor list + the marketplace-audit methodology that decides *which* vendor to trust | **Permanent** — this is the curator's value, even above the vendors. |

The key insight: **the thematic-modules architecture (v4.0.0) already separates
these.** Tool depth lives in opt-in thematic modules (`api-data`, `frontend`,
`ai`, …); the durable patterns are the minimal universal core (+ the workflow
modules like `gitflow`). The reduction work pre-positioned the foundation for
graduation: the graduatable content is exactly the set already pushed out of core.

## The graduation path

```
1. skill foundation-maintained, inside a thematic module      (today — stopgap)
       │  a trusted vendor skill matures (marketplace-audit passes)
       ▼
2. preset gains a recommendedVendorSkills pointer;
   the foundation skill is marked for sunset                  (graduating)
       │  the foundation skill is removed; module shrinks
       ▼
3. the thematic module empties of that item                   (graduated)
       │  if the module had only that item
       ▼
4. the module disappears (or becomes pure-pointer)            (terminal)
```

Concretely: `api-data` / `frontend` / `ai` are the natural candidates to thin out
over time; the workflow core + `gitflow` are not.

## It is not monotone — the oscillation

"More vendor over time" is the *trend*, not a monotone decrease in foundation
content. Every emerging framework/tool arrives **before** the community covers it
well, so the foundation keeps minting **new stopgaps** at the frontier while
graduating old ones at the trailing edge:

```
new stack emerges, no good vendor  ──▶  foundation mints a stopgap skill/module
trusted vendor matures             ──▶  foundation graduates it to a pointer
```

So the **stock** of foundation-maintained depth may stay roughly stable; what
rises is the **ratio** graduated/stopgap, and the *average freshness* of what a
preset surfaces.

## Proposed mechanism (for a future spec)

1. **`canonicalVendor` metadata** on a graduatable skill — names the vendor skill
   that would replace it, so the catalog can *flag* graduation candidates and the
   docs can surface "this is a stopgap; canonical source: X". Absent on durable
   workflow skills (a positive signal of permanence).
2. **Graduation criteria** (gate for moving stopgap → pointer), e.g.: the vendor
   skill passes the existing marketplace-audit methodology; covers ≥ the
   foundation skill's surface; is actively maintained (recency threshold); the
   vendor is the canonical author or an audited community suite.
3. **Sunset procedure** reusing the shipped **crossing-migration**: removing a
   graduated skill from a module is exactly the "now-modularised item" path —
   stop refresh, never delete on-disk, report + pointer. No new mechanism needed.
4. **Preset note**: when a skill graduates, the preset swaps `defaultModules`
   membership for a `recommendedVendorSkills` entry (the `vendor-pointer` tier
   already models the all-pointer extreme — graduation moves a preset along the
   maintainer-vouched → vendor-pointer spectrum item by item).

## Non-goals / open questions

- **Not** a blanket "delete foundation skills" — only graduate where a *trusted*
  vendor exists; many niche stacks will never have one.
- Who owns the recency/trust threshold, and how often is it re-checked? (ties to
  the marketplace-audit cadence.)
- Does graduation belong to the preset (per-stack) or the module (global)? Likely
  the module owns the skill's presence; the preset owns the pointer. A skill can
  graduate globally yet still be pointed-to by several presets.
- Versioning: graduating a skill is a behaviour change for projects that had it —
  governed by the same MINOR-with-migration / crossing-report rules as module moves.

## Why capture this now

The v4.0.0 thematic-modules arc made the *structural* separation (core vs opt-in
depth). This note names the *temporal* direction that separation enables, so the
next questions ("should `dev-prisma` become a pointer?", "is there a trusted
Astro vendor yet?") are answered against a written model instead of re-derived
each time.
