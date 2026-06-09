# Brainstorm: Minimal universal core + composable thematic modules

**Date**: 2026-06-09 · **Status**: model approved, classification + spec pending
**Builds on**: [`2026-06-09-horizontal-domains-as-pure-modules-design.md`](2026-06-09-horizontal-domains-as-pure-modules-design.md) (generalises it)

## Context

The horizontal-pure-modules design moved `biz`/`legal`/`growth` out of the base
catalog into opt-in modules. Adopting the owner's **keep-over-drop** preference
for preset filters then hit an ergonomic wall: a `keep` at `domain:` granularity
keeps a whole domain and **cannot subtract an individual item** inside it. The
off-stack items for web/backend presets are scattered *inside core domains*:

- `dev`: `dev-flutter` (mobile), plus stack-specific `dev-prisma/supabase/graphql/trpc/rag/mcp/ai-integration/neovim`
- `qa`: `qa-chrome`, `qa-mobile`, `qa-neovim`, `qa-e2e`, `qa-design`
- `ops` (34!): `ops-proxmox`/`opnsense` (homelab), `ops-mobile-release`, `ops-infra-code`/`k8s` (IaC), `ops-vercel`/`serverless`/`vps`, `ops-grafana-dashboard`/`observability-stack`/`load-testing`, …
- `data`: `data-pipeline`, `data-modeling` (data-eng)

The **domain axis** (work/dev/qa/ops/doc/data) is orthogonal to the
**stack/platform axis** (mobile, homelab, k8s, data-eng, frontend, …). Niche
items cluster on the second but are filed by the first — which is exactly why
keep-by-domain doesn't reduce them.

## Decision

**One opt-in primitive — generalise "module" to *any* composable opt-in bundle**
(horizontal **and** thematic/platform). The mental model becomes uniform:

> **Minimal universal core** (installed by default) **+ composable modules**
> (opt-in, `claude-base add/remove`, update-tracked, several can stack).
> **Presets** stay stack *profiles* that declare which modules they want
> (`defaultModules`) and scope the core via a `keep` filter.

- **Core** = strictly universal commands/agents every stack wants
  (work + doc + the universal dev/qa/ops/data essentials).
- **Module** = a thematic/platform bundle (cross-domain, arbitrary path list —
  the existing bundle format already allows this). Examples: `biz`, `legal`,
  `growth` (existing) + candidates `mobile`, `self-hosted`, `iac`, `data-eng`,
  `observability`, `editor`, …
- With off-stack items pulled into modules, the **reduced core makes
  keep-by-domain ergonomic** — a web preset keeps the core domains it wants and
  simply doesn't opt into mobile/homelab/etc.

**Owner's choices this session**: ambition = **moderate** (core strictly
universal; many ops/dev/qa platform items become thematic modules — not the
radical "tiny core", not the minimal "few clusters"). Primitive = **modules**
(rejected: presets-as-extras — not composable today; mixed modules+presets — two
concepts; composable-presets refactor — YAGNI).

## Approaches explored

| Approach | Idea | Strengths | Weaknesses | Complexity |
|----------|------|-----------|------------|------------|
| **Modules generalised** ✅ | One opt-in primitive; core + thematic modules; presets declare modules | Uniform single model; reuses module mechanism; makes keep-by-domain ergonomic | Re-classify a large catalog; module ≠ domain now (touches the S1 filter exclusion + validation) | Medium–High |
| Mixed (capabilities=modules, identities=presets) | Two primitives by nature | Matches intuition for "my project *is* a homelab" | Two mechanisms; fuzzy boundary | High |
| Composable presets | Everything is a preset; presets compose | Closest to "extras as presets" | Composition/conflict/order — large refactor | Very high (YAGNI) |

## Relationship to the in-flight `horizontal-pure-modules` spec

`horizontal-pure-modules` (S1–S6, already specced/planned) delivers the **mechanism**:
default-flip to opt-in, filter-governs-core, strict migration, counts split — with
`biz`/`legal`/`growth` as the first three modules. **It stays valid and ships first.**
This generalisation is the **next spec on top**: it (a) re-classifies scattered
platform items into new thematic modules, (b) generalises the S1 filter exclusion
from "module *domains*" to "items owned by *any* module" (module ≠ domain), and
(c) refines the core/full counts. No rework of horizontal-pure-modules — it is the
foundation; this extends it.

## Grouping principle & candidate modules (to finalise in `/work:work-specify`)

- **Group by stack/platform theme, coarse** — aim ~5–8 total modules incl. the 3
  horizontal; **do not over-fragment** (owner's YAGNI). One command can belong to
  at most one module (no overlaps) to keep ownership unambiguous.
- **Candidate new thematic modules** (starting point, refine in spec):
  - `mobile` — `dev-flutter`, `ops-mobile-release`, `qa-mobile`
  - `self-hosted` — `ops-proxmox`, `ops-opnsense`, `ops-vps`
  - `iac` — `ops-infra-code`, `ops-k8s` (± `ops-serverless`)
  - `data-eng` — `data-pipeline`, `data-modeling`
  - `observability` — `ops-grafana-dashboard`, `ops-observability-stack`, `ops-load-testing` (± `ops-monitoring`?)
  - `editor` — `dev-neovim`, `qa-neovim`
- **Judgment calls for spec** (flagged, not decided): the stack-specific `dev-*`
  tools (`prisma`, `supabase`, `graphql`, `trpc`, `rag`, `mcp`, `ai-integration`,
  `react-perf`, `shadcn`) — core-dev or a `backend-data`/`api-stack` module? And
  whether borderline ops (`vercel`, `database`, `backup`, `disaster-recovery`,
  `monitoring`) are core or modular. These decide the final core size.

## Implications (for spec/plan)

- **Module ≠ domain**: the bundle registry gains thematic `.txt` files; the
  catalog-filter "module exclusion" (horizontal S1) generalises to "any
  module-owned item"; validation's horizontal-rejection generalises to
  "any module-owned item can't be drop/keep-targeted by a preset filter".
- **Counts**: core shrinks further; the core-vs-full split (horizontal S4)
  must enumerate all modules.
- **Migration**: same strict policy — items newly modularised leave the default
  install; existing projects keep on-disk files, stop refreshing, re-`add` to
  resume (one coherent breaking story, ideally bundled in the same MAJOR line).
- **Presets**: stack presets keep the core they want by domain (now ergonomic)
  and `defaultModules` the few they need; no `drop` needed.

## Next steps

1. Ship `horizontal-pure-modules` (mechanism + first 3 modules) as planned.
2. `/work:work-specify` a `thematic-modules` spec: finalise the core/module
   classification, generalise module≠domain in the filter/validation, extend
   counts, define the migration for the newly-modularised items, and adopt the
   ergonomic keep in the stack presets (folds in the old US-7).
