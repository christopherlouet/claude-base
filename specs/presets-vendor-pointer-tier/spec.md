# Spec: `vendor-pointer` preset tier + first instance

> **Status: ✅ Shipped** — PR #185 (2026-05-18); 5 vendor-pointer presets live.

**Status**: Validated — tier introduced in PR #185 (2026-05-18); 5 instances live (`phaser` #185, `playwright` #188, `pulumi` #189, `apollo` #190, `mongodb` #191). Validation enforced by `scripts/validate-presets.sh` (EF-003/004/005); roadmap section "Shipped (vendor-pointer)" in [`specs/presets/roadmap.md`](../presets/roadmap.md).
**Date**: 2026-05-18
**Owner**: Chris

---

## Summary

Introduce a third preset tier, `vendor-pointer`, alongside the existing `maintainer-vouched` and `community-curated`. A `vendor-pointer` preset is a deliberately scoped-down manifest whose authority comes from the vendor (validated via the marketplace-audit methodology) rather than from production use claimed by the shipper. This unlocks install-time surfacing of validated vendor sources for stacks the maintainer does not (and may never) use in production. Ship the first instance (`phaser`) wrapping the recipe entry shipped in PR #183, so that a user creating a project where the stack matches receives the vendor pointer at install time.

## Locked decisions (from prior conversational exploration)

| Decision | Resolution |
|---|---|
| Tier name | `vendor-pointer` |
| First instance | `phaser` (wrapping `phaserjs/phaser/skills/`, recipe entry shipped in PR #183) |
| Bar to ship a vendor-pointer preset | The vendor source it points to MUST already pass the marketplace-audit methodology and MUST already be listed in `docs/recipes/recommended-vendor-skills.md`. No production-use claim required from the shipper. |
| Authority source | The vendor's authorship of the pointed-to skill (verified via `gh api`), NOT the maintainer's prod use |

## Locked decisions (resolved during /work:work-clarify)

| Decision | Resolution | Resolved on |
|---|---|---|
| File location | **`.claude/presets/` top-level** — same dir as `maintainer-vouched`. The tier is disambiguated by the `status` field, not by the path. No new subdirectory, no resolver change. | 2026-05-18 |
| Naming convention | **`<vendor>.json`** (e.g., `phaser.json`) — matches existing `nextjs.json`/`astro.json`/`fastapi.json` style. Tier disambiguated via `status` field. Trade-off accepted: if a future `maintainer-vouched` Phaser preset materializes after ≥3 months prod use, a rename or replace will be needed. | 2026-05-18 |
| Detect strictness | **Strict: exactly 1 entry** — either `files: [<1 glob>]` or `depFiles: [{path, contains}]` (XOR). Forces the tier to stay visibly minimalist; multi-signal detection signals opinionated stack knowledge that belongs to `maintainer-vouched`. Apollo-like cases (split package names) pick the dominant package or defer to a future maintainer-vouched preset. | 2026-05-18 |

## User Stories

### P1 — MVP

**US-1 — Vendor surfaced at install time for matching stacks**
- **As a** foundation user creating a project on a stack covered by a validated vendor source
- **I want** the install script to surface the vendor pointer at install time
- **So that** I discover the vendor source without having to read the recipe documentation

Acceptance criteria:
- Given a project directory containing the marker that a `vendor-pointer` preset's detect rule targets
- When I run the foundation install script against that directory (interactive or with `--preset <name>`)
- Then the install output prints the preset's vendor pointer(s) in the same format as existing maintainer-vouched presets do

**US-2 — First vendor-pointer preset shipped (Phaser)**
- **As the** foundation maintainer
- **I want** to ship a Phaser vendor-pointer preset wrapping the existing recipe entry
- **So that** the Phaser pointer reaches install-time surface coverage (not just doc discovery)

Acceptance criteria:
- Given the foundation contains a Phaser preset manifest at the canonical preset location
- When the install script lists presets or auto-detects against a project that depends on Phaser
- Then the Phaser preset is offered and, on selection, surfaces the vendor pointer

### P2 — Important

**US-3 — Tier formally documented in the presets spec**
- **As a** future contributor considering a vendor-pointer preset for another vendor
- **I want** the presets spec to formally describe the `vendor-pointer` tier, its bar, its mandatory and forbidden fields
- **So that** I know what to bring to a PR without reverse-engineering the convention from a single example

Acceptance criteria:
- Given I open `specs/presets/spec.md`
- When I read the "Status tiers" section
- Then `vendor-pointer` appears with a one-row entry naming bar / file location / visibility, identical in shape to the existing `maintainer-vouched` and `community-curated` rows
- And a sub-section spells out the field rules (mandatory `recommendedVendorSkills[]` ≥1, forbidden `foundation.skills.*` / `marketplacePlugins[]` non-empty / `defaults` overrides, simple `detect` rule)

**US-4 — Validation rejects ill-formed vendor-pointer presets**
- **As a** contributor about to PR a vendor-pointer preset
- **I want** the preset validation script to reject my manifest when it violates the tier's constraints
- **So that** ill-formed manifests cannot reach `main`

Acceptance criteria:
- Given a manifest with `status: vendor-pointer` declaring a forbidden field
- When the preset validation script runs against it
- Then the script exits non-zero and prints a clear error message naming the offending field and the tier rule

**US-5 — Roadmap signals additional candidates**
- **As a** reader scanning the presets roadmap
- **I want** the roadmap to name at least three other vendors already validated in the recipe that could follow the same pattern
- **So that** the tier is visibly understood as a class, not a one-off

Acceptance criteria:
- Given I open `specs/presets/roadmap.md`
- When I read the section that documents the new tier
- Then I find at least three named candidate vendors with a one-line rationale each (sourced from `docs/recipes/recommended-vendor-skills.md`)

### P3 — Nice-to-have

**US-6 — Tier visible in `--list-presets`**
- **As a** user listing available presets
- **I want** each preset's tier to be visible in the listing output
- **So that** I can tell at a glance whether a preset is maintainer-vouched, community-curated, or vendor-pointer

Acceptance criteria:
- Given the install script supports listing presets
- When I run it in list mode
- Then each line shows the preset name + its status tier

## Functional Requirements

| ID | Requirement |
|---|---|
| **EF-001** | The presets spec MUST be amended to include a third tier `vendor-pointer` in its "Status tiers" table, with the bar "vendor source already validated in `docs/recipes/recommended-vendor-skills.md`". |
| **EF-002** | The preset validation script MUST accept `vendor-pointer` as a valid value of the `status` field. |
| **EF-003** | The preset validation script MUST require, for any preset whose `status` is `vendor-pointer`, that `recommendedVendorSkills[]` exists and contains at least one entry. |
| **EF-004** | The preset validation script MUST reject any preset whose `status` is `vendor-pointer` that declares any of: `foundation.skills.keep[]` non-empty, `foundation.skills.drop[]` non-empty, `marketplacePlugins[]` non-empty, `defaults` field present. The error message MUST name the offending field. |
| **EF-005** | The preset validation script MUST require, for any preset whose `status` is `vendor-pointer`, that the `detect` rule contain exactly one signal: either a `files[]` array of length 1, or a `depFiles[]` array of length 1 (mutually exclusive). |
| **EF-006** | The first `vendor-pointer` preset (`phaser`) MUST be shipped at the canonical preset location with a `depFiles` detect signal targeting `package.json` and disambiguating Phaser from packages whose name contains "phaser" as a substring (e.g., third-party Phaser helpers). |
| **EF-007** | The `phaser` preset's `recommendedVendorSkills[]` MUST contain at least one entry whose `id` references `phaserjs/phaser/skills/` (the source validated in PR #183). |
| **EF-008** | When the install script's existing vendor-pointer print mechanism is invoked on a `vendor-pointer` preset, it MUST print the preset's `recommendedVendorSkills[]` in the same shape as for `maintainer-vouched` presets — no special-case formatting required for the new tier. |
| **EF-009** | The preset auto-detection mechanism MUST evaluate `vendor-pointer` presets equally to other tiers. They MUST NOT be hidden by default and MUST NOT require a special flag to appear. |
| **EF-010** | The presets roadmap MUST gain a section documenting the new tier and naming at least three candidate vendors already validated in the recipe that could become vendor-pointer presets later (chosen from: Apollo GraphQL, Microsoft Playwright, Pulumi, MongoDB, Grafana Labs). |
| **EF-011** | The CHANGELOG MUST receive one bullet under `[Unreleased]` describing both the tier addition and the first `phaser` instance, with a link to this spec. |
| **EF-012** | `counts.json#presets` MUST be incremented from `6` to `7`. The anti-drift validation script and the foundation audit script MUST exit `0` after the change. |
| **EF-013** | The change MUST NOT modify the bar of existing tiers. `maintainer-vouched` MUST continue to require ≥3 months production use; `community-curated` MUST continue to require a signed maintenance commitment from a contributor. |
| **EF-014** | The change MUST NOT add any new install-time output channel. The new tier reuses the existing vendor-pointer print pipeline. |
| **EF-015** | At least one new fixture and bats test MUST exist per validation rule introduced (EF-003, EF-004, EF-005), and at least one positive bats test MUST exist for the shipped `phaser` preset. |
| **EF-016** | The change MUST NOT name any end-user project (per the durable foundation rule about project-name confidentiality in specs and docs). Stack and vendor names only. |

## Edge Cases

| Case | Expected handling |
|---|---|
| A `vendor-pointer` preset declares both `foundation.skills.keep[]` and `foundation.skills.drop[]` empty arrays | Allowed (treated as "filter absent"); the rejection is only for non-empty arrays per EF-004. Alternatively, the manifest may omit `foundation` entirely. |
| A `vendor-pointer` preset declares `recommendedVendorSkills: []` (empty array) | Rejected per EF-003 (must have ≥1 entry). |
| A `vendor-pointer` preset declares `recommendedVendorSkills[i].condition: "always"` for every entry vs a mix of `always` and `if using X` | Both allowed. The condition semantics from the existing field shape carry over unchanged. |
| A `vendor-pointer` preset declares a `detect` rule with `files[]` of length 2+ or `depFiles[]` of length 2+ | Rejected per EF-005. The rule kept simple to keep the tier's "minimal judgment" character. |
| A `vendor-pointer` preset declares both `files[]` of length 1 AND `depFiles[]` of length 1 | Rejected per EF-005 (mutually exclusive). |
| A `vendor-pointer` preset's vendor source becomes archived between the recipe verification and the preset PR merge | The preset PR MUST be held until the recipe entry is either re-verified or moved to "Vendors evaluated and NOT recommended". No shipping a preset whose pointed-to source is dead. |
| A user has both a `vendor-pointer` preset signal AND a `maintainer-vouched` preset signal in their project | The existing detection mechanism surfaces both matched presets in the interactive menu; no change required by this spec. |
| Two `vendor-pointer` presets match the same project independently | Allowed; both appear in the menu. The user picks. |
| A contributor proposes a `vendor-pointer` preset pointing to a vendor NOT in the recipe | Rejected at PR review per EF-001 (the bar requires the vendor be already validated in the recipe). The PR is asked to add the recipe entry first (separate PR following the existing PR #183 pattern). |
| The detection substring chosen for Phaser matches false positives (other packages whose name contains "phaser") | The shipped `phaser` preset MUST disambiguate per EF-006 (e.g., a substring shape like `"phaser":` rather than bare `phaser`). |
| The install script is run with `--simple` flag and a `vendor-pointer` preset selected | The vendor-pointer print MUST still fire (the `--simple` flag affects foundation-skills filtering, not vendor pointer surfacing). |

## Entities

### Preset manifest, extended

The existing preset JSON shape is unchanged in field set but gains a new allowed `status` value and tier-conditional validation rules.

| Field | Behavior under `status: vendor-pointer` |
|---|---|
| `status` | MUST be `vendor-pointer` |
| `name` | Stack name (e.g., `phaser`); same convention as existing tiers |
| `recommendedVendorSkills[]` | MANDATORY, ≥1 entry |
| `detect` | MANDATORY, simple shape (1 file OR 1 depFile, XOR) |
| `foundation.skills.keep[]` / `foundation.skills.drop[]` | FORBIDDEN if non-empty |
| `marketplacePlugins[]` | FORBIDDEN if non-empty |
| `defaults` | FORBIDDEN (omit; foundation defaults are inherited) |
| `outOfScope[]` | Recommended but not mandatory; same shape as existing tiers |
| `relatedPresetsWanted[]` | Recommended but not mandatory |

### Tier (conceptual)

| Tier | Authority | Bar | File location | Visibility |
|---|---|---|---|---|
| `maintainer-vouched` | Maintainer's prod use | ≥3 months prod + monthly review | `.claude/presets/` | Default-visible |
| `community-curated` | Contributor's prod use | Signed maintenance commitment ≥1 year | `.claude/presets/community/` | Default-visible |
| `vendor-pointer` (new) | Vendor's authorship of pointed-to skill | Vendor source already validated in the recipe | (to be locked in clarification — see CP-1) | Default-visible |
| `draft` | None | Skeleton, vendor not yet verified | `.claude/presets/` | Hidden behind `--include-draft` |

## Success Criteria

| ID | Metric | Target |
|---|---|---|
| **CS-001** | `./scripts/validate-presets.sh` exit code over all shipped presets including the new `phaser` | `0` |
| **CS-002** | Negative fixtures count covering EF-003, EF-004, EF-005 | `≥ 3` (at least one per rule), all rejected with a clear field-naming error |
| **CS-003** | Running the install script against a project whose `package.json` depends on Phaser prints the `phaserjs/phaser/skills/` pointer | Pointer string appears in install output |
| **CS-004** | `--list-presets` shows `phaser` with its `vendor-pointer` tier visible (US-6 if accepted) | Tier appears on the listing line for `phaser` |
| **CS-005** | `./scripts/validate-counts.sh` exit code | `0` |
| **CS-006** | `./scripts/audit-base.sh` exit code | `0` |
| **CS-007** | `counts.json#presets` | `7` (was `6`) |
| **CS-008** | New bats tests added | `≥ 4` (3 negative for EF-003/004/005 + 1 positive for `phaser`) |
| **CS-009** | `specs/presets/spec.md` "Status tiers" section | Contains a row for `vendor-pointer` matching the existing row shape |
| **CS-010** | `specs/presets/roadmap.md` | Names ≥3 candidate vendors for future vendor-pointer presets |
| **CS-011** | End-user project names in diff | `0` (verified by grep over the diff before commit) |
| **CS-012** | New install-time output channels added | `0` (existing print pipeline reused per EF-014) |

## Out of Scope

- Shipping vendor-pointer presets for the other named candidates (Apollo, Pulumi, MongoDB, Grafana, Playwright). Each one ships as its own PR after this spec is implemented and the tier is in `main`.
- Modifying the bar or definition of `maintainer-vouched` or `community-curated`.
- Changing the install script's general flow (no new menu state, no new flags beyond what already exists for tiers).
- Reorganizing the install output of `print_recommended_vendor_skills` for grouping by tier.
- Migrating any existing preset to the new tier. The 6 shipped presets stay `maintainer-vouched`.
- Bundling any new third-party plugin (no new `marketplacePlugins[]` content anywhere).
- Editing website source files (`website/src/...`, `website/docs/...`) beyond what the auto-regen pipeline updates.
- Adding documentation about how to combine vendor-pointer with other workflows (recipe + roadmap + install help are sufficient).
- Changing the Phaser recipe entry shipped in PR #183 (treated as the upstream of this spec; if it needs editing, that is a separate change).
- Building a "no preset matched → recipe pointer footer" fallback in the install script. That was an alternative considered (Option 2 in conversation) and remains a future spec if appetite.

## Clarification Points

_All 3 clarifications resolved during `/work:work-clarify` on 2026-05-18. See "Locked decisions" at the top of this spec for the binding answers. Original questions kept below for traceability._

1. **File location for vendor-pointer presets** — resolved: top-level `.claude/presets/`.
2. **Naming convention** — resolved: bare `<vendor>.json` (e.g., `phaser.json`).
3. **Detect rule strictness** — resolved: strict 1 entry exactly (XOR between `files[]` and `depFiles[]`).

---

## Cross-references

- Methodology that gives the tier its authority: `specs/marketplace-audit/spec.md` (vendor-neutrality filter, search protocol, decision rubric).
- Recipe entry that this spec's first instance wraps: `docs/recipes/recommended-vendor-skills.md` §"Phaser — `phaserjs/phaser/skills/`" (shipped in PR #183).
- Existing tier semantics being extended: `specs/presets/spec.md` §"Status tiers".
- Roadmap to be amended: `specs/presets/roadmap.md` §"What is NOT covered" and §"Quick reference (count)".
- Memory rules consulted: `feedback_verify_code_claims` (will be exercised at plan time when touching `validate-presets.sh`), `feedback_counts_ci_gate` (counters reconciled via `npm --prefix website run generate`), `feedback_no_project_names` (EF-016).
