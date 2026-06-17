# Implementation Plan: stack-pivot re-detection

**Branch**: `feature/stack-pivot-redetect`
**Date**: 2026-06-16
**Spec**: [spec.md](spec.md)
**Status**: Draft

---

## Summary

Surface, at `claude-base update` time, that a project has outgrown its sticky recorded preset (CS-205), following the foundation's **observe-and-propose, never act silently** stance. The recorded preset and skill filter are left untouched; an additional `scan_presets` pass produces a **non-blocking notice** when the detected set diverges from the recorded preset, pointing the user at the explicit `--preset <name>` adoption path (which already exists). A single pure helper (`preset_pivot_notice`) backs both the auto-notice (P1) and an optional read-only report (P2), mirroring the shipped `recommendation_drift` pattern.

The decisive simplification: `update.sh` already exposes `ACTIVE_PRESET_SOURCE ∈ {manifest, --preset, detected}` — exactly the three discriminators the spec needs. Gating the notice on `ACTIVE_PRESET_SOURCE == "manifest"` covers FR-1, US-1 AC3 (legacy → `detected`), explicit `--preset` (→ adoption, no notice), and `--no-preset` (empty `ACTIVE_PRESET_FILE`) **for free**, with no new state.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language** | Bash (POSIX-ish, project style) | matches `scripts/lib/*.sh` |
| **Test framework** | `bats` | offline, `jq` available, synthetic presets via `PRESETS_DIR`/`PRESETS_DIR_OVERRIDE` |
| **Key deps** | `jq` (already a soft dep, gracefully skipped when absent) | no new dependency |
| **Reused machinery** | `scan_presets`, `resolve_preset_file` (`lib/preset-detect.sh`); `manifest_preset` (`lib/modules.sh`); `ACTIVE_PRESET_SOURCE/NAME` + recommendation block (`update.sh`) | no new detection logic |
| **Target** | the `claude-base` CLI (dispatcher → `scripts/update.sh`, `scripts/new-project.sh`) | |

### Constraints

- **Must not mutate** the manifest or skill filter on a notice-only run (CS-205 sticky guarantee).
- **Must be fail-safe**: any error in the pivot check degrades to "no notice", never aborts `update` (the script runs under `set -euo pipefail` — explicit `if`/`|| true`, never a trailing `&&` as a function's last command, per the US-9 gotcha).
- **Offline**: detection reads local files only; no network.
- **No counts change**: no new command/agent/skill artifact → `validate-counts.sh` stays green; website regen only if `docs/**` text changes.

### Expected performance

| Metric | Target |
|--------|--------|
| Added latency per `update` | ~one `scan_presets` pass (≤ #presets jq evals); negligible |

---

## Constitution/Conventions Check

*GATE — validate before implementation.*

- [x] Follows project conventions (bash lib + bats TDD, observe-never-act philosophy)
- [x] Consistent with existing architecture (mirrors `recommendation_drift` helper + call site)
- [x] No over-engineering (one pure helper; thin call sites; no new persisted state for MVP)
- [x] Tests planned (new `tests/stack-pivot.bats` unit suite + update-integration assertions)
- [x] TDD mandatory (RED before GREEN), per `.claude/rules/tdd-enforcement.md`

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `tests/stack-pivot.bats` | Unit + behavior tests for `preset_pivot_notice` and the divergence logic (RED first). |

### To modify

| File | Modification |
|------|--------------|
| `scripts/lib/preset-recommendations.sh` | Add pure helper `preset_pivot_notice <recorded_preset> <target_dir>` → echoes the notice block, empty when steady-state / legacy / detector empty-and-not-worth-noting. Depends on `scan_presets`. |
| `scripts/update.sh` | Call site in the recommendation region (~L1979): when `ACTIVE_PRESET_SOURCE == "manifest"`, compute `preset_pivot_notice`, print a `section` + block if non-empty, **before** the `recommendation_drift` block (one coherent "preset & recommendations status" group). Fail-safe `|| true`. |
| `scripts/update.sh` (P2) | Add a read-only `--detect-only` short-circuit (resolve recorded preset + `scan_presets` + print divergence, exit 0, no mutation) — reuse `preset_pivot_notice`. |
| `docs/guides/TROUBLESHOOTING-GUIDE.md` *(P3, optional)* | One short "my project changed stack — how do I re-point the preset?" entry. Triggers website regen. |
| `CHANGELOG.md` | `[Unreleased]` entry (English). |

### Tests to add

| File | Coverage |
|------|----------|
| `tests/stack-pivot.bats` | divergence detection, notice text + exact suggested command, steady-state silence, legacy silence, multi-match listing (no abort), manifest byte-identical after notice, `jq`-absent skip, fail-safe on bad detector. |
| `tests/update*.bats` (extend) | integration: an `update` run on a pivoted synthetic project prints the notice AND leaves `foundation.json` byte-identical (R-2 guard). |

---

## Chosen Approach

### Architecture

```
claude-base update <project>
        │
        ▼
resolve_active_preset()  ──▶ ACTIVE_PRESET_{NAME,FILE,SOURCE}
        │                         (SOURCE = manifest | --preset | detected)
        ▼
... update work (filter honored, UNCHANGED) ...
        │
        ▼
recommendation region (QUIET-gated, ACTIVE_PRESET_FILE set)
        │
        ├─ if SOURCE == "manifest":
        │       preset_pivot_notice(NAME, dir) ──▶ scan_presets(dir)
        │                                          compare vs {NAME}
        │                                          └─ non-empty? → section + block   (P1, US-1)
        │
        ├─ recommendation_drift(...)            ──▶ (US-9, unchanged)
        │
        └─ print_recommended_vendor_skills(...)  ──▶ (unchanged)
        │
        ▼
record snapshot / version  (UNCHANGED; pivot notice persists nothing)
```

`--preset <name>` adoption (US-2) needs **no new code** — it is the existing override path in `resolve_active_preset` (SOURCE becomes `--preset`, filter applied, manifest re-recorded, snapshot refreshed). The plan only verifies it end-to-end.

### Divergence rule (FR-3)

Let `D = scan_presets(dir)` (sorted set) and `R = recorded preset name`.
- **No notice** when `D == {R}` (steady state) or `R ∈ D` and `D` adds nothing actionable? → **Decision**: notice fires when `D != {R}` AND `D` is non-empty — i.e. `R ∉ D` (project no longer matches its preset) **or** `D` contains a preset other than `R` (project additionally/instead matches another). Listing includes the full `D`.
- **Empty `D`** (project matches nothing now): **silent** for MVP (open-question #2 resolved conservatively — avoids notice-fatigue when files were merely removed; revisit only if a real need appears). Documented in the helper.

### Rationale

- Reusing `ACTIVE_PRESET_SOURCE` as the discriminator avoids re-deriving "is there a recorded preset" and naturally excludes every no-notice case from the spec.
- A pure helper returning printable text (empty = nothing to say) is the exact shape of `recommendation_drift`, so the call site, the QUIET gating, and the test style are all already proven.
- Putting the helper in `preset-recommendations.sh` (the "surface changes at update" module) keeps `preset-detect.sh` pure detection; the helper *consumes* `scan_presets`, it doesn't redefine detection.

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Auto-switch the recorded preset on detection | Violates CS-205; silently rewrites the skill filter, can drop skills the user relies on. Explicit Non-Goal. |
| New top-level `claude-base sync` subcommand | Larger CLI surface for the same outcome; the notice + existing `--preset` + (P2) `--detect-only` cover the need. Deferred (spec open-q #1). |
| Put helper in `preset-detect.sh` | Mixes user-facing message formatting into the pure detection lib. Kept detection pure. |
| Reuse `resolve_active_preset`'s multi-match `error` for ambiguity | That path **aborts** the run; a recorded project must never be blocked by re-detection (US-4). The helper only lists. |

---

## Implementation Phases

### Phase 1: Foundation (blocking)

**Objective**: the pure helper, test-first.

- [ ] T001 - [US1] Write `tests/stack-pivot.bats` RED suite for `preset_pivot_notice` (divergence, steady-state, legacy/empty-recorded, multi-match, empty-detection, jq-absent, fail-safe). Assert they FAIL.
- [ ] T002 - [US1] Implement `preset_pivot_notice` in `scripts/lib/preset-recommendations.sh` (GREEN), pure/offline, fail-safe.

**Checkpoint**: helper unit-tested in isolation, no `update.sh` change yet.

### Phase 2: User Story 1 (P1 - MVP) 🎯

**Objective**: non-blocking pivot notice wired into `update`.

- [ ] T003 - [US1] Extend `tests/update*.bats`: pivoted synthetic project → notice appears + suggested command exact + manifest byte-identical + exit 0 (RED).
- [ ] T004 - [US1] Wire the call site in `scripts/update.sh` recommendation region, gated on `ACTIVE_PRESET_SOURCE == "manifest"`, before `recommendation_drift`, fail-safe (GREEN).
- [ ] T005 - [US1] Verify no-notice cases via integration: legacy (no manifest), steady-state, `--no-preset`, explicit `--preset`.

**Checkpoint**: US-1 + US-2 (adoption via existing `--preset`) demonstrably working; CS-205 byte-identical guard green.

### Phase 3: User Story 3 (P2 — read-only affordance)

**Objective**: scriptable pivot check without a full update.

- [ ] T006 - [US3] Tests for `update --detect-only` read-only report (prints recorded + detected + diverge yes/no, exit 0, mutates nothing) (RED).
- [ ] T007 - [US3] Add `--detect-only` short-circuit to `scripts/update.sh` reusing `preset_pivot_notice` / `scan_presets` (GREEN).

**Checkpoint**: read-only mode works; manifest untouched.

### Phase 4: User Story 4 (P3 — ambiguity surfacing)

**Objective**: multi-match stays informative and non-blocking.

- [ ] T008 - [US4] Test: project matching ≥2 presets → all listed, `--preset` hint, update still completes on recorded preset (the legacy multi-match `error` is NOT triggered). (Largely covered by T001/T003 multi-match cases — confirm/strengthen here.)

**Checkpoint**: ambiguity never aborts a recorded-project update.

### Phase 5: Polish & Quality

- [ ] T009 - [P] CHANGELOG `[Unreleased]` entry (English).
- [ ] T010 - [P] *(optional)* TROUBLESHOOTING-GUIDE entry + `npm --prefix website run generate` if `docs/**` changed; `validate-counts.sh` green.
- [ ] T011 - Run full `scripts/test.sh` (bats parallel) + `shellcheck` on changed scripts.
- [ ] T012 - Parallel adversarial review (general-purpose finder agents) on the diff; fix findings.
- [ ] T013 - `/qa:qa-loop "score 90"` then 1 PR.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| R-1 Notice fatigue (over-firing) | Medium | Medium | Fire only on genuine divergence (FR-3); empty-detection silent; one concise block; steady-state test. |
| R-2 Breaking CS-205 sticky | High | Low | FR-4 + dedicated test asserting `foundation.json` byte-identical (`cmp -s`) after a notice-only run. |
| R-3 `set -e` abort from helper's last command | High | Medium | Explicit `if`/`|| true` at call site; no trailing `&&`; fail-safe `return 0`. (Known US-9 gotcha.) |
| R-4 Detector accuracy bounds the notice | Low | Medium | Out of scope to fix detect rules; PLAN/TDD to note any obviously-wrong rule found. |
| R-5 `jq` absent on user box | Low | Low | Whole check skipped (consistent with `scan_presets`/`resolve_active_preset`). |

---

## Dependencies and Execution Order

```
Phase 1 (helper, TDD) ──▶ Phase 2 (US1 wire-in, MVP)
                       ├──▶ Phase 3 (US3 read-only)  [after Phase 1 helper]
                       └──▶ Phase 4 (US4 ambiguity)  [mostly Phase 1 tests]
Phases 2-4 ───────────────▶ Phase 5 (Polish, review, PR)
```

- **MVP = Phase 1 + Phase 2.** Ship-able alone (US-1 + US-2). Phases 3-4 are additive, each independently testable.
- `[P]` parallelizable: T009/T010 (docs) are independent of each other.

---

## Validation Criteria

### Gate 1 — before starting
- [x] Spec approved (this plan derives from `spec.md`)
- [ ] Plan reviewed by maintainer
- [ ] On a fresh `feature/stack-pivot-redetect` branch (rename the auto-branch)

### Gate 2 — before merge
- [ ] All new bats green; full `scripts/test.sh` green (incl. macOS portability — **no `timeout` in bats**)
- [ ] `shellcheck` clean on changed scripts
- [ ] `validate-counts.sh` green; `validate-presets.sh` green
- [ ] CS-205 byte-identical guard test present and green
- [ ] Adversarial review findings resolved

### Gate 3 — before PR/release
- [ ] All spec acceptance criteria (US-1..US-4) verified
- [ ] CHANGELOG `[Unreleased]` updated; website mirror regenerated iff `docs/**` changed
- [ ] PR title uses an allowed type (`feat(...)`, not `ci:`) per `[[pr-title-allowed-types]]`

---

## Notes

- Closes `specs/foundation-positioning-review/phase-6-curator-bindings.md` **open-question #3** — update that doc's status when merged.
- Sibling of US-9 recommendation-drift (foundation-side); this is the project-side counterpart. Consider cross-linking in both specs.
- Estimated effort: **Medium**, ~1 session for MVP (Phases 1-2), +~½ session for P2/P3.

---

**Version**: 1.0 | **Created**: 2026-06-16 | **Last modified**: 2026-06-16
