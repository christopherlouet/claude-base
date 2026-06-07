# Implementation Plan: `vendor-pointer` preset tier + first instance

**Branch**: `feature/auto-20260518-155721` (rename to `feat/presets-vendor-pointer-tier` via `/git-rename`)
**Date**: 2026-05-18
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Add a third preset tier `vendor-pointer` to the foundation's preset system. The tier is for thin pointer-only manifests whose authority comes from the vendor (already validated in `docs/recipes/recommended-vendor-skills.md`), not from maintainer prod use. Implement the validation rules, ship the first instance (`phaser.json`), update spec/roadmap, regenerate counters. TDD-driven: write failing bats tests first, then implement validation, then verify.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Primary edits** | Bash (`validate-presets.sh`), JSON (`phaser.json`), Markdown (`spec.md`, `roadmap.md`, `CHANGELOG.md`), Bats (`presets.bats`) | No new language, no new tooling |
| **Auto-regenerated** | `counts.json#presets` (auto-counted via `countJsonFiles(.claude/presets)` in `website/scripts/generate-counts.ts:147`) | Drop `phaser.json` → run `npm --prefix website run generate` → automatic increment 6 → 7 |
| **US-6 (P3)** | Free — `list_presets()` at `scripts/new-project.sh:632-651` already prints the `status` column | No script change needed |
| **Verification scripts** | `bats tests/presets.bats`, `./scripts/validate-presets.sh`, `./scripts/validate-counts.sh`, `./scripts/audit-base.sh`, `npm --prefix website run test:scripts` | Same gate stack as PRs #183/184 |
| **TDD discipline** | Mandatory — Phase 2 writes failing bats tests BEFORE Phase 3 implements validation rules | Red → Green → Refactor cycle |
| **External validation** | `gh api repos/phaserjs/phaser` re-check on the day of merge (per `feedback_verify_code_claims`) | Numbers already captured 2026-05-18 in PR #183; if merge happens within 7 days the cached numbers can be reused |
| **LOC estimate** | ~250 LOC across 6 hand-edited files + 1 new fixture + 1 new preset | Bigger than #183/#184; full workflow warranted |

### Constraint: `defaults` is currently required

`validate-presets.sh:106` enforces `[ "$(jq -r '.defaults // empty | type' "$file")" = "object" ]` — i.e., `defaults` MUST be present as an object today. EF-004 of the spec says vendor-pointer presets MUST NOT declare `defaults`. Two ways to reconcile:

- **Option A (chosen)**: Tier-conditional required-fields logic. When `status == vendor-pointer`, skip the `defaults`-required check; instead enforce `defaults` is **absent OR equal to foundation defaults** (no overrides).
- Option B (rejected): Spec amendment to "MUST equal foundation defaults" without forbidding presence. Rejected because it weakens the spec's clarity ("forbidden" is clearer than "must equal").

Option A keeps the spec wording intact and adds ~10 lines of tier-conditional logic.

### Other tier-conditional rules required

| Field | Currently | Under `vendor-pointer` |
|---|---|---|
| `defaults` | Required (object) | MUST be absent (EF-004) |
| `outOfScope` | Required (array) | Recommended (kept as required for now — vendor-pointer presets simply ship a small `outOfScope` listing) |
| `appliesToTypes` | Required (non-empty array) | Required (`["generic"]` is the neutral choice) |
| `foundation.skills.keep` / `.drop` | Optional, XOR | MUST be absent OR empty (EF-004) |
| `marketplacePlugins` | Optional, validated shape | MUST be absent OR empty (EF-004) |
| `recommendedVendorSkills` | Optional | MUST be present, ≥1 entry (EF-003) |
| `detect` | Optional, complex allowed | MUST be present, exactly 1 signal entry (EF-005) |

### Memory anchors

- `feedback_verify_code_claims` — exercised during this planning (verified `defaults` requirement, US-6 freeness, counts.json auto-derivation)
- `feedback_no_project_names` — EF-016, enforced in pre-commit grep guard
- `feedback_counts_ci_gate` — counts auto-regen via `npm --prefix website run generate`
- `feedback_anti_drift_badge` — README badges auto-bumped by same generator (presets count surfaces in README markers if any exist)

---

## Constitution / Conventions Check

GATE — validate before starting:

- [ ] All 3 clarification points resolved (see `spec.md` §"Locked decisions (resolved during /work:work-clarify)").
- [ ] CI baseline captured: current `validate-presets.sh` exit code recorded.
- [ ] Phaser repo state still green per PR #183 verification (5-day cache acceptable, re-check via `gh api` otherwise).
- [ ] No memory-flagged anti-pattern (`feedback_no_project_names`, etc.) violated by the planned changes.
- [ ] TDD cycle respected: failing tests committed BEFORE passing implementation.

---

## Project Structure (this feature)

```
specs/presets-vendor-pointer-tier/
├── spec.md     # Functional spec (6 US, 16 EF, 12 CS, 3 CP all resolved)
├── plan.md     # This file
└── tasks.md    # Task breakdown (generated alongside this plan)
```

No source-code scaffolding needed beyond hand-edits below.

---

## Impacted Files

### To create

| File | Responsibility | Approx LOC |
|------|----------------|-----------|
| `.claude/presets/phaser.json` | First `vendor-pointer` preset manifest | ~40 |
| `tests/presets-fixtures/phaser/package.json` | Fixture for detect-rule drift-guard test | ~10 |

### To modify

| File | Modification | Approx LOC |
|------|--------------|-----------|
| `scripts/validate-presets.sh` | (a) Extend `ALLOWED_STATUS` (line 77) to include `vendor-pointer`. (b) Extend `case` block (line 114-116) for the new value. (c) Add tier-conditional rules block (~30 lines): when `status == vendor-pointer`, enforce EF-003 (recommendedVendorSkills ≥1), EF-004 (forbidden fields), EF-005 (simple detect rule). | +50 |
| `specs/presets/spec.md` | Add `vendor-pointer` row to "Status tiers" table; add sub-section "Field rules under `vendor-pointer`" capturing EF-003/004/005 | +30 |
| `specs/presets/roadmap.md` | Add section "## Vendor-pointer presets" listing candidates (Apollo, Pulumi, MongoDB, Grafana, Playwright); bump "Quick reference (count)" if game-dev row needs adjustment | +25 |
| `tests/presets.bats` | Add ≥4 new tests: (1) phaser.json accepted positive, (2) reject vendor-pointer missing recommendedVendorSkills (EF-003), (3) reject vendor-pointer with marketplacePlugins (EF-004), (4) reject vendor-pointer with complex detect (EF-005). Plus 1 fixture-pairing test for phaser per existing US-5 pattern | +80 |
| `CHANGELOG.md` | One bullet under `[Unreleased] / ### Added` describing tier + phaser instance | +8 |
| `.claude/presets/README.md` | Reference the new tier in the "Available presets (this repo)" table; note that the 6 maintainer-vouched + 1 vendor-pointer = 7 total | +5 |

### Auto-regenerated (DO NOT hand-edit)

| File | Trigger | Mechanism |
|------|---------|-----------|
| `counts.json#presets` | `phaser.json` dropped under `.claude/presets/` | `npm --prefix website run generate` runs `countJsonFiles(.claude/presets)` |
| `README.md` `<!-- count:presets -->` badge (if present) | Same as above | Same generator updates count markers |

### Files NOT touched (explicit non-modifications)

- `.claude/presets/community/` (no community-curated change)
- `.claude/skills/` (no new bundled skill — same discipline as PR #183)
- `.claude/settings.json` (no command/agent/skill count changed)
- Other shipped preset manifests (`nextjs.json`, etc.) — they stay `maintainer-vouched` per EF-013
- Already-shipped specs (`specs/archive/preset-react-vite-spa/`, `specs/archive/vendor-skills-game-dev/`, etc.) — historical docs

---

## Chosen Approach

### Sequencing (TDD-driven)

```
Phase 1: Pre-verification (gh api re-check, baseline scripts, branch rename)
         │
         ▼
Phase 2: TDD RED — write failing bats tests for EF-003/004/005 + phaser positive
         │
         ▼
Phase 3: TDD GREEN — implement validation rules in validate-presets.sh
         │           (tier-conditional logic block)
         │
         ▼
Phase 4: Ship phaser.json + fixture (paired drift-guard test passes)
         │
         ▼
Phase 5: Spec amendment (specs/presets/spec.md — status tiers table + field rules)
         │
         ▼
Phase 6: Roadmap amendment (specs/presets/roadmap.md — new tier section + candidates)
         │
         ▼
Phase 7: README.md (.claude/presets/) reference update
         │
         ▼
Phase 8: Auto-regen + audit gauntlet (validate-counts.sh, audit-base.sh, npm test:scripts)
         │
         ▼
Phase 9: CHANGELOG + pre-commit guardrails (grep protected names, diff review)
         │
         ▼
Phase 10: Commits + push + PR + watch CI + merge (same pattern as PRs #183, #184)
```

### Rationale

- **TDD mandatory** per `.claude/rules/workflow.md` §4: validation rules are pure logic, perfectly TDD-able. Negative fixtures are the ideal red-green driver.
- **Validation rules before preset**: the script must reject vendor-pointer presets with forbidden fields BEFORE we ship the first one — otherwise we'd be unable to verify the rules work.
- **Spec amendment after impl**: the spec amendment documents what already works in code, avoiding doc-code drift.
- **Roadmap after spec**: roadmap references the new tier's spec section.
- **Counters last**: auto-regen happens AFTER all hand-edits stabilize.

### Alternatives considered

| Alternative | Why rejected |
|---|---|
| Implement validation first, write tests after | Violates the foundation's TDD rule |
| Pin `vendor-pointer` presets behind `--include-draft` (like draft tier) | Defeats US-1 (install-time discovery for matching stacks) |
| Edit `counts.json#presets` by hand to 7 | Generator overwrites; same anti-pattern as in #183 |
| Make `defaults`/`outOfScope`/`appliesToTypes` optional under vendor-pointer (broader relaxation) | Erodes spec's clarity for other tiers; tier-conditional logic suffices for the one truly-forbidden field |
| Use `appliesToTypes: ["react"]` for phaser | Phaser projects vary (vanilla TS, Vue UI, etc.); `["generic"]` is the honest neutral |
| Combine vendor-pointer + spec amendment into one commit | Bigger blast radius for review; split is safer |

---

## Implementation Phases

### Phase 1 — Pre-verification + branch rename (BLOCKING)

**Objective**: Capture baseline, confirm Phaser state, set up branch name.

- T001 — Re-verify Phaser repo state (cache from PR #183 is 0 days old; quick `gh api repos/phaserjs/phaser --jq .archived` sanity check).
- T002 — Run `./scripts/validate-presets.sh`, `./scripts/validate-counts.sh`, `bats tests/presets.bats` on the current `main` snapshot to capture baseline (expected: all exit 0, bats 72/72).
- T003 — Rename branch via `/git-rename feat/presets-vendor-pointer-tier` (current `feature/auto-20260518-155721` is auto-generated).

**Checkpoint**: Baseline known; branch named; ready to write failing tests.

### Phase 2 — TDD RED: failing bats tests (US-4, US-2)

**Objective**: Write tests that MUST fail because the validation rules don't exist yet.

- T004 — [US4] Add negative bats test "presets: validate-presets.sh rejects a vendor-pointer preset declaring marketplacePlugins (EF-004)".
- T005 — [US4] Add negative bats test "presets: validate-presets.sh rejects a vendor-pointer preset declaring foundation.skills.keep (EF-004)".
- T006 — [US4] Add negative bats test "presets: validate-presets.sh rejects a vendor-pointer preset missing recommendedVendorSkills (EF-003)".
- T007 — [US4] Add negative bats test "presets: validate-presets.sh rejects a vendor-pointer preset with a multi-entry detect.depFiles (EF-005)".
- T008 — [US4] Add negative bats test "presets: validate-presets.sh rejects a vendor-pointer preset declaring both files[1] AND depFiles[1] (EF-005 XOR)".
- T009 — [US2] Add positive bats test "presets: phaser.json (vendor-pointer) is accepted by validate-presets.sh" — will fail because phaser.json doesn't exist yet AND the new status enum value doesn't exist yet.
- T010 — Run `bats tests/presets.bats` → expected: 6 new tests FAIL (status enum rejects `vendor-pointer`, or rules not yet implemented). Confirm RED state.

**Checkpoint**: Tests written, all 6 fail for the expected reasons.

### Phase 3 — TDD GREEN: implement validation (US-4)

**Objective**: Make all 6 new tests pass with the minimum implementation.

- T011 — [US4] Extend `validate-presets.sh:77` `ALLOWED_STATUS` to include `vendor-pointer`.
- T012 — [US4] Extend `validate-presets.sh:114-116` case to accept `vendor-pointer`.
- T013 — [US4] Add a tier-conditional block in `validate-presets.sh` (after the existing field validations, before final exit) implementing EF-003 / EF-004 / EF-005. Block structure:
  ```bash
  if [ "$status" = "vendor-pointer" ]; then
      # EF-003: recommendedVendorSkills MUST be non-empty
      # EF-004: marketplacePlugins, foundation.skills.{keep,drop}, defaults MUST be absent or empty
      # EF-005: detect MUST be exactly 1 signal entry (files[1] XOR depFiles[1])
  fi
  ```
- T014 — [US4] Reconcile EF-004 vs the existing required-`defaults` check (line 106): wrap the `defaults` requirement in `if [ "$status" != "vendor-pointer" ]` so vendor-pointer manifests can legally omit `defaults`.
- T015 — Run `bats tests/presets.bats` → expected: the 5 negative tests from Phase 2 now PASS. Positive test T009 still fails (phaser.json missing). Confirm GREEN-for-validation-rules state.

**Checkpoint**: Validation logic in place, 5/6 new tests green.

### Phase 4 — Ship phaser.json + fixture (US-2)

**Objective**: First vendor-pointer instance shipped, paired fixture in place.

- T016 — [US2] Create `.claude/presets/phaser.json`. Shape:
  ```json
  {
    "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
    "name": "phaser",
    "displayName": "Phaser (vendor-pointer)",
    "description": "Pointer-only preset for the Phaser 2D web game framework. Surfaces the vendor's canonical skill suite (`phaserjs/phaser/skills/`, 28 SKILL.md files, MIT) at install time. No foundation skill filtering, no opinionated defaults — see `docs/recipes/recommended-vendor-skills.md` §Phaser for the vendor entry, and `specs/presets-vendor-pointer-tier/spec.md` for the tier semantics.",
    "version": "1.0.0",
    "status": "vendor-pointer",
    "author": { "name": "Chris", "github": "christopherlouet" },
    "appliesToTypes": ["generic"],
    "detect": {
      "combinator": "anyOf",
      "depFiles": [
        {"path": "package.json", "contains": "\"phaser\":"}
      ]
    },
    "recommendedVendorSkills": [
      {
        "id": "phaserjs/phaser/skills",
        "url": "https://github.com/phaserjs/phaser/tree/master/skills",
        "rationale": "Canonical Phaser skill suite published by the vendor (28 SKILL.md files including v3-to-v4 migration). Verified 2026-05-18.",
        "condition": "always"
      }
    ],
    "outOfScope": [
      "Foundation skill curation — this preset deliberately ships no `foundation.skills.keep/drop` filter (vendor-pointer tier)",
      "Marketplace plugins — none bundled (vendor-pointer tier)",
      "Renderer-only stacks — see `docs/recipes/recommended-vendor-skills.md` adjacent options for PixiJS",
      "Native mobile / desktop wrappers — out of foundation scope generally"
    ],
    "relatedPresetsWanted": []
  }
  ```
  Note: `"phaser":` (with trailing colon) disambiguates from packages like `phaser-extras` (EF-006).
- T017 — [US2] Create `tests/presets-fixtures/phaser/package.json`. Shape:
  ```json
  {
    "name": "fixture-phaser",
    "version": "0.0.0",
    "private": true,
    "dependencies": {
      "phaser": "^4.0.0"
    }
  }
  ```
- T018 — [US2] Add bats test "presets: phaser detect rule matches its fixture (US-5)" following the existing pattern at `presets.bats:688`.
- T019 — Run `bats tests/presets.bats` → expected: ALL tests pass, including T009 positive and T018 fixture-pairing.

**Checkpoint**: First vendor-pointer preset shipped; detection works on its fixture.

### Phase 5 — Spec amendment (US-3)

**Objective**: `specs/presets/spec.md` formally documents the new tier.

- T020 — [US3] In `specs/presets/spec.md`, locate the "Status tiers" table (search "Status" + "Quality bar" headers). Add a row for `vendor-pointer` with bar "Vendor source already validated in `docs/recipes/recommended-vendor-skills.md`" and file location ".claude/presets/" and visibility "Default-visible".
- T021 — [US3] Add a sub-section "Field rules under `vendor-pointer`" naming EF-003/004/005 in narrative form. Reference `specs/presets-vendor-pointer-tier/spec.md` for the binding source.
- T022 — [US3] Update the top-of-spec status line if it claims a specific preset count (currently "6 maintainer-vouched presets live") — leave as-is since the count of maintainer-vouched stays at 6; the new preset is a different tier.

**Checkpoint**: Spec doc reflects the new tier.

### Phase 6 — Roadmap amendment (US-5)

**Objective**: `specs/presets/roadmap.md` signals candidates.

- T023 — [US5] In `specs/presets/roadmap.md`, add a section between "## Shipped (maintainer-vouched)" and "## What is NOT covered" titled "## Shipped (vendor-pointer)". List `phaser` with link to its manifest.
- T024 — [US5] In the same file, add a section "## Vendor-pointer candidates" (placed after "## How to contribute a preset"). List ≥3 candidate vendors from the recipe (Apollo, Pulumi, MongoDB, Grafana, Playwright) with one-line rationale each.
- T025 — [US5] Update "## Quick reference (count)" table: add a row "Vendor-pointer presets" with shipped = 1, community-wanted = "5+" (the candidates above).
- T026 — [US5] Update the bottom-line tally "**6 shipped. 23+ named as community-wanted.**" → "**6 maintainer-vouched + 1 vendor-pointer = 7 shipped. 28+ named as community-wanted.**" (or equivalent honest framing).

**Checkpoint**: Roadmap visibly carries the new tier and signals its growth path.

### Phase 7 — README.md (.claude/presets/) reference (anti-drift)

**Objective**: The presets README stays accurate.

- T027 — In `.claude/presets/README.md`, update the "Available presets (this repo)" table to include `phaser` (status: `vendor-pointer`, stack: Phaser 2D web game framework).
- T028 — Update the paragraph "The 6 maintainer-vouched presets cover..." to read "The 6 maintainer-vouched + 1 vendor-pointer = 7 presets cover..." or similar; preserve the spirit (≥3 mo prod use ≠ vendor-pointer).

**Checkpoint**: Presets README accurate.

### Phase 8 — Regen + audit gauntlet (US-2, anti-drift)

**Objective**: Auto-regen + all foundation scripts green.

- T029 — Run `npm --prefix website run generate`. Capture the printed count line (should now show `presets: 7`).
- T030 — Verify `jq '.presets' counts.json` returns `7`.
- T031 — Run `npm --prefix website run test:scripts` (covers `generate-counts.test.ts`). Expected exit 0, all 35+ tests pass.
- T032 — Run `./scripts/validate-presets.sh`. Expected exit 0; output mentions `phaser.json`.
- T033 — Run `./scripts/validate-counts.sh`. Expected exit 0, "No drift detected".
- T034 — Run `./scripts/audit-base.sh`. Expected exit 0, no issues.
- T035 — Run `bats tests/presets.bats`. Expected exit 0, ≥77 tests pass (72 baseline + 6 new from Phase 2 + 1 from Phase 4 fixture-pairing; minus T009 which is now the same as Phase 4 positive — recount during execution).

**Checkpoint**: All gates green; counters consistent.

### Phase 9 — CHANGELOG + pre-commit guardrails

**Objective**: Diff is clean and named.

- T036 — [P] In `CHANGELOG.md` under `## [Unreleased] / ### Added`, add one bullet describing tier + phaser instance.
- T037 — [P] Run `git diff --name-only HEAD`. Expected files: `.claude/presets/phaser.json`, `.claude/presets/README.md`, `scripts/validate-presets.sh`, `specs/presets/spec.md`, `specs/presets/roadmap.md`, `tests/presets.bats`, `tests/presets-fixtures/phaser/package.json`, `CHANGELOG.md`, `counts.json` (auto). Spec/plan/tasks also if not yet committed.
- T038 — [P] Grep for protected end-user project names over the diff (per `feedback_no_project_names`). Expected: zero matches.

**Checkpoint**: Diff clean, ready to commit.

### Phase 10 — Commits + push + PR + merge

**Objective**: Ship.

- T039 — Two commits per the same pattern as PR #183:
  - Commit A: `docs(specs): plan vendor-pointer preset tier + first instance` — spec.md, plan.md, tasks.md
  - Commit B: `feat(presets): add vendor-pointer tier + ship phaser (1st instance)` — everything else
- T040 — `git push -u origin HEAD`.
- T041 — `gh pr create` with PR body referencing spec, methodology, candidates, and the test plan.
- T042 — Watch CI: `gh pr checks <N> --watch --fail-fast`.
- T043 — On green: `gh pr merge <N> --squash --delete-branch`.
- T044 — Sync local main: `git checkout main && git pull --ff-only`.

**Checkpoint**: Tier shipped on `main`.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Phaser repo state changed between PR #183 verification and this merge | Medium | Low | T001 re-check; if archived, abort and re-evaluate |
| `validate-presets.sh` refactor breaks existing presets validation | High | Medium | TDD discipline: existing 6 presets MUST keep passing through every T011-T014 change. Phase 2 includes implicit regression coverage. |
| Generator parser doesn't recognize `phaser.json` shape | Low | Low | `countJsonFiles` only counts files, not parses; format-agnostic |
| Tier-conditional logic in bash gets hard to read | Medium | Medium | Keep block contiguous, comment with EF-XXX references, ≤30 LOC |
| `appliesToTypes: ["generic"]` clashes with detection logic that assumes specific types | Medium | Low | All 6 existing presets use various types; `generic` is already in use by cli-tools, fastapi, homelab-proxmox — no novel ground |
| Phaser detect substring `"phaser":` produces false positives on `"phaser3-extras":` (extra prefix matches) | Medium | Low | The colon after the quote anchors as a key terminator, but a package literally named `phaser` is what matches. Edge case: `"@somescope/phaser":` would match the substring. Acceptable: still indicates Phaser-adjacent stack. Document as known limit in the preset's `outOfScope` if needed. |
| Roadmap "Quick reference" count math becomes confusing (6 vs 7 vs 6+1) | Low | Medium | Use the explicit form "6 maintainer-vouched + 1 vendor-pointer = 7 total" to avoid ambiguity |
| Forgetting auto-regen → 6/7 drift | High | Medium | T029 listed before all validation steps in Phase 8 |
| Mentioning a specific end-user project in commit/PR/spec by mistake | High | Low | T038 explicit grep |
| TDD test that should fail accidentally passes (false GREEN) | High | Low | T010 explicitly inspects WHY each test fails (status enum vs rule) |

---

## Dependencies and Execution Order

```
Phase 1 (Pre-verification + branch rename) ──▶ Phase 2 (TDD RED)
                                                       │
                                                       ▼
                                                Phase 3 (TDD GREEN - validation rules)
                                                       │
                                                       ▼
                                                Phase 4 (Ship phaser.json + fixture)
                                                       │
                          ┌──────────────────────┬─────┴─────┬──────────────────────┐
                          ▼                      ▼           ▼                      ▼
                   Phase 5 (Spec)        Phase 6 (Roadmap)  Phase 7 (Presets README)
                          │                      │           │
                          └──────────────────────┴───────────┘
                                                 │
                                                 ▼
                                          Phase 8 (Regen + audits)
                                                 │
                                                 ▼
                                          Phase 9 (CHANGELOG + guards)
                                                 │
                                                 ▼
                                          Phase 10 (Commits + PR + merge)
```

Phases 5/6/7 are parallelizable (different files). All others sequential.

---

## Validation Criteria

### Gate 1 — Before starting
- [ ] All 3 clarifications resolved (spec §"Locked decisions").
- [ ] Branch renamed or T003 queued.
- [ ] CI baseline captured (T002).

### Gate 2 — Mid-implementation (after Phase 3)
- [ ] 5/6 new bats tests pass (validation rules in place).
- [ ] Existing 72 bats tests still pass (no regression on existing presets).

### Gate 3 — Mid-implementation (after Phase 4)
- [ ] 7/7 new bats tests pass (including phaser positive + fixture-pairing).
- [ ] `validate-presets.sh` exits 0 on the 7 presets (6 maintainer-vouched + 1 vendor-pointer).

### Gate 4 — Before commit (after Phase 9)
- [ ] All 44 tasks T001-T044 minus those queued for user (T003 rename, T043 merge) completed.
- [ ] `counts.json#presets == 7`.
- [ ] `./scripts/validate-counts.sh` exit 0.
- [ ] `./scripts/audit-base.sh` exit 0.
- [ ] `bats tests/presets.bats` exit 0 (~79 tests pass).
- [ ] Grep on protected names returns empty.

### Gate 5 — Before merge (after Phase 10 push)
- [ ] CI all green (CodeQL, Lint & Test ubuntu+macos, Security Scan, Validate PR).
- [ ] PR review pass (self-review at minimum).

---

## Notes

- **Workflow scale**: this is medium-complexity. Bigger than PRs #183/#184 (docs-only) but smaller than the original v1.39.0 preset PR #178 (~600 LOC). The TDD step is genuine (real validation logic), not skippable.
- **Why not /work:work-quick?**: more than 3 files modified, touches the foundation's tier system, requires spec amendment. Full workflow is the right cost level.
- **Bash testing**: bats is the established test runner for shell logic (`tests/presets.bats`). No new test framework introduced.
- **Future-proofing**: the 5 candidate vendors (Apollo, Pulumi, MongoDB, Grafana, Playwright) are intentionally NOT shipped in this PR. Each is its own future PR following the pattern this PR establishes — keeps blast radius small and lets each vendor's `detect` substring be reviewed individually.

---

**Version**: 1.0 | **Created**: 2026-05-18 | **Last modified**: 2026-05-18
