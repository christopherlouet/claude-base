# Spec — Command-side vendor graduation (Wave: biz/growth/ops/doc/legal commands)

> Status: 🔵 Ready for planning · 2026-06-15 · Owner: Chris
> Strategic north star: `specs/foundation-positioning-review/spec.md` (4-tier rubric)
> Reconciles: `specs/foundation-positioning-review/spec.md` (REDUCE verdicts) ×
> `specs/marketplace-audit/batch-2-plan-2026-05-18.md` (pointer-only, mostly KEEP-OURS)
> Curation data: `.claude/curation/registry.json`, `docs/recipes/recommended-vendor-skills.md`
> Precedent: `biz-pricing` / `growth-seo` (commands already reduced to pointer-commands)

## 1. Summary

The **skill-side** of foundation→vendor graduation is done (REDUCE-target skills are all
~45–56 LOC pointer-skills; the 3 DEPRECATE skills are removed). The **command-side** is
half-done: of the ~18 commands the positioning review flagged REDUCE-TO-POINTER, only
`biz-pricing` and `growth-seo` were converted. This spec closes the command-side wave with
**evidence-based per-pack verdicts** that reconcile the two conflicting source specs, and
fixes the precedent's blind spot — **graduated commands whose sibling agent still ships the
full duplicated content with no vendor pointer** (e.g. `growth-seo` command is a pointer but
`growth-seo` agent is untouched).

The audit (2026-06-15, EXPLORE phase) produced: **2 REDUCE · 11 POINT · 4 KEEP.**

### Reconciliation logic (why these verdicts, not the raw positioning-spec list)

- positioning-spec said REDUCE, but was written **before** biz/growth became pure opt-in
  modules — its core argument was *maintenance burden on the core*. In opt-in modules that
  argument collapses, so a blanket REDUCE is too aggressive.
- batch-2-plan said KEEP-OURS / pointer-only, but compared only against **Anthropic's
  catalog** (which ships no marketing/legal), missing `coreyhaines31/marketingskills`
  (29.8k★) which is genuinely deeper.
- New structural fact: these are **orchestrators** (~50 LOC prompt + guardrails + workflow
  cross-links), not content packs. The `biz-pricing` precedent shows a command can be
  reduced to a pointer **while remaining a workflow entry-point**.

**Rule applied (one line, audit-defensible):**

> **REDUCE ⟺ an _authority_ vendor owns the underlying tool** (the command is a thin checklist
> wrapping a tool the vendor documents far better). **POINT ⟺ everything else** (a _community_
> vendor goes deeper on a *methodology*, but the foundation's orchestration / workflow
> cross-links still carry value). **KEEP ⟺ no canonical vendor of comparable breadth.**

This rule deliberately downgrades the positioning-spec's community-vendor REDUCEs
(`growth-ab-test`, `growth-landing` included) to POINT: their vendor (corey) is community,
not authority; the "fully redundant" claim was overstated (no single skill covers the
methodology end-to-end); and POINT is reversible whereas a content delete is not. Only the
two **authority tool-wrappers** (`ops-vercel` → vercel-labs, `ops-grafana-dashboard` →
grafana) truly graduate.

### Command vs agent policy (the precedent's blind spot)

| Resource type | How it graduates | Why |
|---|---|---|
| **Command** | May become a pure **pointer-command** (≈20–25 LOC, `biz-pricing` model): user reads it, installs the vendor skill, uses it in their session. | A command is a prompt the user runs in the main session; they can act on the pointer immediately. |
| **Agent** | Gets a `## See also` block but **keeps functional instructions** — never a bare pointer. | An agent runs autonomously (restricted tools, `permissionMode: plan`); it cannot install/invoke a vendor skill mid-run, so it must stay executable. |

## 2. Verdict table (audit output — the scope of this spec)

| Pack | Vendor canonical | Track | Module | Verdict | Has agent? |
|---|---|---|---|---|---|
| `ops-vercel` | vercel-labs/agent-skills | **authority** | iac | **REDUCE** | yes |
| `ops-grafana-dashboard` | grafana/skills | **authority** | observability | **REDUCE** | no |
| `growth-ab-test` | coreyhaines31/marketingskills/ab-testing | community | growth | **POINT** | no |
| `growth-landing` | corey copywriting+cro+marketing-psychology | community | growth | **POINT** | yes |
| `biz-mvp` | gsd:mvp-phase / slavingia (×3) | community | biz | **POINT** | yes |
| `biz-okr` | orchestkit/okr-design | community | biz | **POINT** | no |
| `biz-roadmap` | memstack / majiayu roadmap | community | biz | **POINT** | no |
| `biz-personas` | UX persona suites | community | biz | **POINT** | yes |
| `biz-pitch` | kai-slide-creator | community | biz | **POINT** | no |
| `growth-funnel` | coreyhaines31/marketingskills/cro | community | growth | **POINT** | yes |
| `growth-onboarding` | coreyhaines31/marketingskills/onboarding | community | growth | **POINT** | no |
| `growth-retention` | coreyhaines31/marketingskills/churn-prevention | community | growth | **POINT** | no |
| `ops-observability-stack` | grafana/skills + LGTM (multi-tool wiring) | community | observability | **POINT** | no |
| `ops-k8s` | helm/kustomize (fragmented) | — | iac | **KEEP** | no |
| `doc-api-spec` | finom/vovk (framework-specific) | — | core | **KEEP** | no |
| `doc-changelog` | git-cliff (tool) | — | core | **KEEP** | yes |
| `legal-privacy-policy` | majiayu / paperclipai | — | legal | **KEEP** | yes |

**Why only 2 REDUCE:** the rule keys REDUCE off *authority ownership of the tool*, which only
`ops-vercel` and `ops-grafana-dashboard` satisfy. Every community-vendor / methodology pack is
POINT — including `growth-ab-test` and `growth-landing`, which the positioning-spec listed as
REDUCE. POINT→REDUCE is a cheap, isolated future move if the owner ever wants it; the reverse
(restoring deleted content) is not. `ops-observability-stack` stays POINT because it *wires
multiple tools* (Prometheus+Grafana+Loki+Alertmanager) — no single vendor skill replaces the
orchestration.

## 3. User Stories (prioritized)

### P1 — REDUCE the 2 authority tool-wrappers to pointer-commands

**US-1 — Convert the 2 REDUCE commands to pointer-commands**
As the foundation maintainer,
I want `ops-vercel` and `ops-grafana-dashboard` (the two authority-vendor tool-wrappers)
reduced to pointer-commands following the `biz-pricing` model,
So that the foundation stops shipping a thin checklist around a tool its authority vendor
documents far better.

- **Given** a REDUCE command, **When** converted, **Then** it follows the `biz-pricing`
  shape: title `... (pointer)`, a "Delegate to the vendor toolkit" section naming the prior
  content as *superseded by* the vendor (with a one-line depth rationale), an **install**
  snippet, a link to the recipe entry, a link to this spec's rationale, and the foundation
  **workflow cross-links** preserved (`## Related agents`).
- **Given** a REDUCE command, **When** converted, **Then** its length is ≈20–25 LOC (the
  generic checklist content is removed, not merely annotated).
- **Given** the vendor named in the pointer, **When** it is an **authority** vendor, **Then**
  it already exists in `.claude/curation/registry.json` and/or a preset
  `recommendedVendorSkills[]` — the pointer must not introduce an un-curated vendor.

**US-2 — Treat the sibling agent of a REDUCE pack**
As the maintainer,
I want the one REDUCE pack that **has an agent** (`ops-vercel`) to get a `## See also` vendor
block on the agent **without** losing executability,
So that the autonomous path is consistent with the reduced command and no longer ships
silently-inferior content.

- **Given** the `ops-vercel` agent, **When** updated, **Then** it gains a `## See also` block
  naming the same vendor as its command, **and** keeps its functional instructions,
  frontmatter (tools, `model`, `permissionMode`), and workflow role intact.
- **Given** `ops-grafana-dashboard` (no agent), **When** P1 completes, **Then** no agent file
  is created or touched.

### P2 — POINT the 11 commands (additive, low-risk)

**US-3 — Add vendor `## See also` to the 11 POINT commands**
As the maintainer,
I want `biz-mvp/okr/roadmap/personas/pitch`, `growth-ab-test/funnel/landing/onboarding/retention`,
`ops-observability-stack` to gain a `## See also` block pointing to the deeper vendor,
So that users discover the canonical depth while keeping the foundation orchestration.

- **Given** a POINT command, **When** updated, **Then** it **keeps** its full workflow body
  and gains a `## See also` block naming the vendor + a one-line "pair it with the
  foundation workflow" note; the command's length grows by only the pointer block.
- **Given** a POINT pack that **has an agent** (`biz-mvp`, `biz-personas`, `growth-funnel`,
  `growth-landing`), **When** updated, **Then** the agent gains the same `## See also` block
  (functional instructions kept), per the command-vs-agent policy.

**US-4 — Backfill the precedent's blind spot**
As the maintainer,
I want already-graduated packs whose agent still lacks a pointer to be backfilled,
So that the command-side wave leaves no half-graduated pack behind.

- **Given** `growth-seo` (command already a pointer) whose **agent** has no vendor pointer,
  **When** P2 completes, **Then** the `growth-seo` agent carries a `## See also` to
  `AgriciDaniel/claude-seo` consistent with its command.
- **Given** `biz-pricing` (already graduated, **no** agent), **When** P2 completes, **Then**
  no agent work is required for it.

**US-5 — Recipe coverage for every newly-pointed community vendor**
As the maintainer / curator,
I want every vendor newly referenced by a REDUCE/POINT pack to have a recipe entry,
So that pointers never dangle and the recipe stays the single curation surface.

- **Given** a vendor newly named by US-1/US-3, **When** P2 completes, **Then**
  `docs/recipes/recommended-vendor-skills.md` has an entry for it (or it already exists),
  with provenance + advice-neutrality disclosure per the curation methodology.
- **Given** the corey marketing skills referenced by multiple growth/biz packs, **When**
  added, **Then** they appear once under the existing Corey Haines section (no duplication).

### P3 — Record the KEEP verdicts + close the wave

**US-6 — Document the reconciled verdicts as the durable record**
As the maintainer,
I want the 4 KEEP verdicts and the reconciliation logic recorded in the positioning spec,
So that a future audit doesn't re-litigate the biz/growth REDUCE-vs-KEEP tension.

- **Given** the positioning-spec REDUCE list, **When** P3 completes, **Then** it carries a
  dated note pointing to this spec's reconciled table (REDUCE→4, POINT→9, KEEP→4) and the
  rationale that opt-in-module status + orchestration value downgraded most REDUCEs to POINT/KEEP.
- **Given** the 4 KEEP packs (`ops-k8s`, `doc-api-spec`, `doc-changelog`, `legal-privacy-policy`),
  **When** P3 completes, **Then** each has a one-line recorded reason they were **not**
  graduated (no canonical authority of comparable breadth / stack-neutral / foundation
  workflow-bound / GDPR code-audit angle).

**US-7 — Curation registry reflects the new command-side candidates**
As the curator,
I want the REDUCE/POINT vendors that aren't yet tracked added to `registry.json` as candidates,
So that the rot-watch covers the command-side graduations too (not just skill-side).

- **Given** a vendor newly pointed-to that is **not** in `registry.json`, **When** P3
  completes, **Then** it is added with the standard record fields (vendorId, pinnedRef,
  trustTrack, provenance, adviceNeutrality, lastVerified, status) and passes
  `scripts/validate-presets.sh --registry` (no floating refs).

## 4. Acceptance criteria (wave-level)

- Both REDUCE commands (`ops-vercel`, `ops-grafana-dashboard`) are ≈20–25 LOC pointer-commands
  matching the `biz-pricing` shape; the `ops-vercel` agent carries a `## See also`.
- All 11 POINT commands + the relevant agents (`biz-mvp`, `biz-personas`, `growth-funnel`,
  `growth-landing`, plus the `growth-seo` agent backfill) carry a `## See also` vendor block.
- No dangling pointer: every vendor named has a recipe entry **and** (if community-track) a
  registry record.
- `scripts/validate-counts.sh` is green and `npm --prefix website run generate` produces no
  diff (per-command/agent pages regenerated and committed).
- `scripts/validate-presets.sh` (+ `--registry`) green; `scripts/audit-base.sh` clean.
- The positioning-spec carries the reconciliation note; this spec's status updated on ship.

## 5. Out of scope

- The 4 **KEEP** packs receive no content change (only the recorded reason in US-6).
- **Removal/DEPRECATE** of any command (this wave is pointer-only, per batch-2-plan).
- Skill-side graduation (already done) and module/preset structure (separate spec line).
- Modifying the foundation workflow, rules, hooks, or `.claude/settings.json`.
- Re-auditing vendor depth from scratch — verdicts are this spec's input, not re-derived.
- A version bump / release decision (a separate step after merge).

## 6. Risks & mitigations

- **Broken-pointer window**: a REDUCE removes content before the recipe entry exists →
  mitigate by ordering recipe entry (US-5) **before/with** the command reduction in the plan.
- **Agent reduced too far**: an agent stripped to a bare pointer becomes non-executable →
  US-2/US-3 mandate functional instructions are kept; agents only gain `## See also`.
- **Counts gate drift**: command/agent pages are generated → regen + commit the mirror; no
  count *number* changes (no add/remove), but the per-resource page bodies change.
- **Borderline regret**: if the owner later wants any community-vendor POINT pack
  (`growth-ab-test/landing/funnel/onboarding/retention`, `biz-pitch`) as REDUCE, the
  POINT→REDUCE step is cheap and isolated (the rule + rationale are recorded in §2).

## 7. Suggested PR slicing (for the PLAN phase)

1. **PR-A (P1)** — 2 REDUCE pointer-commands + the `ops-vercel` agent `## See also` + recipe
   entries for the 2 authority vendors (already present → verify, don't duplicate).
   Behaviour-visible.
2. **PR-B (P2)** — 11 POINT `## See also` (commands + 4 agents) + `growth-seo` agent
   backfill + recipe entries for any community vendor not yet listed. Additive.
3. **PR-C (P3)** — positioning-spec reconciliation note + KEEP reasons + registry records.
   Docs/data only.

Atomic per the workflow's anti-pattern against giant multi-feature commits.
