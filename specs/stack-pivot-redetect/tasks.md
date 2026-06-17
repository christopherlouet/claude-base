# Tasks: stack-pivot re-detection

**Input**: `specs/stack-pivot-redetect/spec.md` + `plan.md`
**Prerequisites**: plan.md (✓), spec.md (✓)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: parallelizable (different files, no dependency)
- **[US1..US4]**: traceability to the spec's user stories
- Exact file paths included

---

## Phase 1: Foundation (helper, TDD) — BLOCKING

**Goal**: the pure `preset_pivot_notice` helper, test-first. No `update.sh` change yet.

**⚠️ RED before GREEN.**

- [ ] **T001** [US1] Write RED unit suite `tests/stack-pivot.bats` for `preset_pivot_notice <recorded_preset> <target_dir>`. Follow `tests/recommendation-drift.bats` conventions (synthetic presets via `PRESETS_DIR`/`PRESETS_DIR_OVERRIDE`, fixture project dirs, `jq`, offline, `load 'test_helper'`). Cases:
  - divergence: recorded `react-vite-spa`, dir matches `nextjs` → output non-empty, names recorded + detected, contains exact string `claude-base update --preset nextjs`.
  - steady-state: recorded `nextjs`, dir matches only `nextjs` → output empty.
  - `R ∉ D`: recorded `react-vite-spa`, dir matches only `nextjs` → non-empty (no-longer-matches wording).
  - multi-match: dir matches `nextjs` + `react-vite-spa` → lists both, suggests `--preset <name>`, exit 0.
  - empty-detection: dir matches nothing → output empty (silent, per FR-3 decision), exit 0.
  - `jq` absent (PATH shim) → output empty, exit 0.
  - fail-safe: detector/junk input never returns non-zero. Assert suite FAILS (helper absent).

- [ ] **T002** [US1] Implement `preset_pivot_notice` in `scripts/lib/preset-recommendations.sh` (GREEN):
  - signature `preset_pivot_notice <recorded_preset_name> <target_dir>`; echoes notice block or nothing.
  - `command -v jq || return 0`; `D="$(scan_presets "$target_dir")"`.
  - divergence rule (plan FR-3): empty `D` → silent; `D == {recorded}` → silent; else format a concise block (recorded name, detected list, `claude-base update --preset <name>` hint).
  - pure/offline, no writes, `return 0` always (fail-safe). Add a header comment referencing this spec + CS-205.
  - Run T001 → all GREEN.

**Checkpoint**: helper unit-tested in isolation.

---

## Phase 2: User Story 1 — Pivot notice at update (P1) 🎯 MVP

**Goal**: non-blocking notice wired into `claude-base update`.
**Independent test**: run `update` on a pivoted synthetic project → notice printed, manifest unchanged, exit 0.

- [ ] **T003** [US1] Extend `tests/update-presets.bats` (or `tests/update.bats`) RED: synthetic project recorded `react-vite-spa` + files matching `nextjs`, run `update` (via the harness used by existing update tests) → assert stdout contains the notice + exact suggested command; assert `foundation.json` is **byte-identical** before/after (`cmp -s`); assert exit 0.

- [ ] **T004** [US1] Wire call site in `scripts/update.sh` recommendation region (~L1979, inside the `[[ -n "$ACTIVE_PRESET_FILE" ]] && ! ${QUIET}` block), **before** the `recommendation_drift` block (GREEN):
  ```
  if [[ "$ACTIVE_PRESET_SOURCE" == "manifest" ]]; then
      _pivot="$(preset_pivot_notice "$ACTIVE_PRESET_NAME" "$TARGET_DIR" || true)"
      if [[ -n "$_pivot" ]]; then
          section "Your project may have changed stack"
          printf '%s\n\n' "$_pivot"
      fi
  fi
  ```
  Fail-safe (`|| true`, no trailing `&&`). Run T003 → GREEN.

- [ ] **T005** [US1] Integration no-notice assertions (RED→GREEN as needed): legacy project (no `foundation.json`, SOURCE=`detected`) → no notice; steady-state → no notice; `update --no-preset` → no notice; `update --preset nextjs` (SOURCE=`--preset`) → no notice (it IS the adoption). Confirms FR-1 + US-1 AC2/AC3 + US-2 path.

**Checkpoint**: MVP done (US-1 + US-2 via existing `--preset`); CS-205 byte-identical guard green.

---

## Phase 3: User Story 3 — Read-only detection (P2)

**Goal**: scriptable pivot check, no mutation.
**Independent test**: `claude-base update --detect-only <project>` prints status, exits 0, manifest untouched.

- [ ] **T006** [US3] RED tests in `tests/update*.bats`: `update --detect-only <dir>` on (a) pivoted project → prints recorded + detected + "diverges: yes"; (b) steady project → "diverges: no"; both exit 0 and leave `foundation.json` byte-identical. Verify mutual-exclusion errors mirror new-project's `--detect-only` (e.g. with `--preset`).

- [ ] **T007** [US3] Add `--detect-only` short-circuit to `scripts/update.sh` (flag parse + early read-only branch that resolves the recorded preset via `manifest_preset`, runs `preset_pivot_notice`/`scan_presets`, prints the report, `exit 0` before any mutation). Reuse the helper. Update `--help`/usage text. Run T006 → GREEN.

**Checkpoint**: read-only mode works; nothing persisted.

---

## Phase 4: User Story 4 — Ambiguity surfaced, not resolved (P3)

**Goal**: multi-match never aborts a recorded-project update.
**Independent test**: project matching ≥2 presets → all listed, update completes on recorded preset.

- [ ] **T008** [US4] Strengthen the multi-match case (from T001/T003) into an explicit assertion: an `update` on a project matching `nextjs` + `react-vite-spa` lists both, suggests `--preset`, **completes** using the recorded preset, and never triggers the legacy `error "multiple presets match"` abort path. (No new production code expected — the helper already only lists; this is a guard test.)

**Checkpoint**: ambiguity is informative, never blocking.

---

## Phase 5: Polish & Cross-cutting

- [ ] **T009** [P] Add `CHANGELOG.md` `[Unreleased]` entry (English, `[[english-for-versioned-artifacts]]`): "Added — `update` now flags when a project's stack diverges from its recorded preset (observe-and-propose; `--detect-only` for a read-only check)."
- [ ] **T010** [P] *(optional)* Add a TROUBLESHOOTING-GUIDE entry ("my project changed stack — re-point the preset with `claude-base update --preset <name>`"); if `docs/**` edited, run `npm --prefix website run generate` and verify `validate-counts.sh` green (`[[website-docs-is-generated]]`).
- [ ] **T011** Run `scripts/test.sh` (full bats, parallel) + `shellcheck` on `update.sh` + `preset-recommendations.sh`. **No `timeout` in bats** (macOS CI gate).
- [ ] **T012** Parallel adversarial review (general-purpose finder agents) on the diff: hunt for set-e aborts, byte-identity regressions, QUIET-gating leaks, false-positive notices. Fix findings.
- [ ] **T013** `/qa:qa-loop "score 90"`; then open 1 PR (`feat(presets): ...`, allowed type per `[[pr-title-allowed-types]]`). Update `phase-6-curator-bindings.md` open-q #3 status in the same PR.

---

## Dependencies and Execution Order

```
Phase 1 (T001→T002, helper TDD)   ◄──── BLOCKS everything
     │
     ├──▶ Phase 2 (T003→T004→T005, US1 MVP)
     │
     ├──▶ Phase 3 (T006→T007, US3)   [after Phase 1]
     │
     └──▶ Phase 4 (T008, US4)        [after Phase 1; mostly guard test]

Phases 2-4 ──▶ Phase 5 (T009..T013 polish/review/PR)
```

### Dependencies between user stories

| Story | Can start after | Dependencies |
|-------|-----------------|--------------|
| US1 (P1) | Phase 1 helper | none |
| US2 (P1) | — | **no new code**; existing `--preset` adoption path, verified in T005 |
| US3 (P2) | Phase 1 helper | reuses helper |
| US4 (P3) | Phase 1 tests | guard test, no new prod code expected |

### Within each story

1. RED test before GREEN code (TDD mandatory).
2. Helper (lib) before call sites (`update.sh`).
3. Each story independently testable; commit per logical group.

### Parallelization

- T009 / T010 are `[P]` (different files: CHANGELOG vs docs).
- Production code is serialized through two files (`preset-recommendations.sh`, `update.sh`) → keep call-site edits sequential to avoid conflicts.

---

## Implementation Strategy

### MVP first
1. Phase 1 (helper, TDD) → 2. Phase 2 (wire-in) → **STOP & VALIDATE** US-1 + US-2 on a pivoted fixture → ship-able.

### Incremental
- MVP (P1) → add `--detect-only` (P2) → harden ambiguity (P3) → polish + review + PR. Each adds value without breaking the prior.

---

## Notes

- **Never** auto-switch the recorded preset (CS-205). The notice proposes; `--preset` (user-initiated) disposes.
- Mirror the shipped `recommendation_drift` helper + call site for shape, gating, and test style.
- Watch the `set -euo pipefail` last-command gotcha (US-9): explicit `if`/`|| true`, no trailing `&&`.
- No counts change expected; regen website only if `docs/**` text changes.

---

**Version**: 1.0 | **Created**: 2026-06-16
