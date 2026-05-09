# Tasks: preset-aware updates

**Input**: design documents from `specs/presets-update-aware/`
**Prerequisites**: `plan.md` (required), `spec.md` (required, all clarifications resolved)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** — can be executed in parallel (different files, no dependencies)
- **[US?]** — associated user story (traceability)
- File paths absolute from repo root

---

## Phase 1 — Setup

**Goal**: branch ready, skeleton tests file, suite still green.

- [ ] T001 — Rename branch from `feature/auto-20260509-164232` to `feature/presets-update-aware` via `git branch -m`. Working tree is clean.
- [ ] T002 — Create `tests/update-presets.bats` with bats boilerplate (`load 'test_helper'`, setup/teardown, no test cases yet beyond a sanity check that update.sh exists and is executable).

**Checkpoint**: skeleton present; `bash scripts/test.sh` still green.

---

## Phase 2 — Foundation (blocking) — argument parsing + preset resolution

**Goal**: `update` learns `--preset NAME` and `--no-preset`, resolves the active preset, fails fast on bad input. No filter applied yet.

⚠️ **CRITICAL**: do not start US-1 implementation until this phase is finished.

### Tests for foundation (TDD — write first, must FAIL before implementation)

- [ ] T003 — [P] [US-2] `tests/update-presets.bats`: `update --preset bogus_xyz <path>` exits non-zero with a message naming the missing preset. Assert no file change in the target via mtime/diff.
- [ ] T004 — [P] [US-3] `tests/update-presets.bats`: `update --preset nextjs --no-preset <path>` exits non-zero with `mutually exclusive` message.
- [ ] T005 — [P] [US-7] `tests/update-presets.bats`: synthetic project where 2+ presets match (e.g. drop both `next.config.js` and `astro.config.mjs` into the same dir). Run `update --all <path>` without flag. Exits non-zero; message lists each matching preset; instruction `--preset <name>` or `--no-preset` appears.
- [ ] T006 — [P] [US-2] `tests/update-presets.bats`: `update --preset nextjs <path>` resolves successfully (exit 0, no error). No skill-filter assertion at this phase.
- [ ] T007 — [P] [US-3 / CS-006] `tests/update-presets.bats`: a project that does NOT match any preset, run `update --all` without flag. Output does NOT contain `Active preset:` (silence preserved).

### Foundation implementation

- [ ] T008 — Source `scripts/lib/preset-detect.sh` from `scripts/update.sh` (add the `source ... preset-detect.sh` line after the existing `lib/common.sh` line in the head of the file).
- [ ] T009 — Add globals to `scripts/update.sh` near the other globals (around line 40):
  - `UPDATE_PRESET_NAME=""`
  - `UPDATE_NO_PRESET=false`
  - `ACTIVE_PRESET_FILE=""`
  - `ACTIVE_PRESET_NAME=""`
  - `ACTIVE_PRESET_SOURCE=""` (one of `""`, `"detected"`, `"--preset"`)
  - `ACTIVE_PRESET_DROP_LIST=()`
- [ ] T010 — Extend `parse_args()` in `scripts/update.sh`:
  - case `--preset)` → `UPDATE_PRESET_NAME="$2"; shift 2` (with required-arg guard).
  - case `--no-preset)` → `UPDATE_NO_PRESET=true; shift`.
  - At end of parse, if both `UPDATE_PRESET_NAME` and `UPDATE_NO_PRESET` are set, call `error "--preset and --no-preset are mutually exclusive"`.
- [ ] T011 — Implement `resolve_active_preset()` in `scripts/update.sh`:
  - If `UPDATE_NO_PRESET` true → leave globals empty, return 0.
  - Else if `UPDATE_PRESET_NAME` non-empty:
    - Search `BASE_DIR/.claude/presets/$UPDATE_PRESET_NAME.json`, fall back to `community/$UPDATE_PRESET_NAME.json`.
    - If not found → `error "preset not found: $UPDATE_PRESET_NAME"`.
    - Else set `ACTIVE_PRESET_NAME=$UPDATE_PRESET_NAME`, `ACTIVE_PRESET_FILE=<path>`, `ACTIVE_PRESET_SOURCE="--preset"`.
  - Else (auto-detect path):
    - `local matches=$(scan_presets "$TARGET_DIR")`
    - Count newlines: 0 → leave empty; 1 → resolve that name to FILE and set SOURCE="detected"; 2+ → `error` with the list and the disambiguation instruction.
  - On success with active preset, call `load_active_drop_list`.
- [ ] T012 — Implement `load_active_drop_list()`:
  - `[[ -z "$ACTIVE_PRESET_FILE" ]] && return 0`
  - `mapfile -t ACTIVE_PRESET_DROP_LIST < <(jq -r '.foundation.skills.drop[]? // empty' "$ACTIVE_PRESET_FILE" 2>/dev/null)`
  - Filter empty strings out.
- [ ] T013 — Update `show_help()` in `scripts/update.sh`:
  - Document `--preset NAME` and `--no-preset` under OPTIONS.
  - Add a worked example: `update --preset nextjs --all ./my-app`.
  - Add a sentence explaining auto-detection in the DESCRIPTION section.

**Checkpoint**: T003–T007 green; existing `tests/update.bats` still green (no behavior change yet for non-flag callers).

---

## Phase 3 — User Story 1 + 2 + 3 (P1) — filter applied to skill copy 🎯 MVP

**Goal**: when an active preset is set, skills the preset drops are skipped during copy. Override and opt-out paths work.

**Independent test**: `update --all` on a Next.js project ends up with the same skill set as a fresh `init --preset nextjs`.

### Tests for US-1+US-2+US-3 (TDD — write first, must FAIL before implementation)

- [ ] T014 — [P] [US-1] `tests/update-presets.bats`: bootstrap with `init --preset nextjs $TEST_DIR/proj`. Confirm `dev-flutter` skill is absent. Run `update --skills $TEST_DIR/proj` (auto-detect, no flag). Assert `dev-flutter` is still absent post-update (filter blocks the re-add).
- [ ] T015 — [P] [US-1] Same scenario but assert detection picked `nextjs` (output contains `Active preset: nextjs`). Splits visibility expectations from filter expectations.
- [ ] T016 — [P] [US-2] `tests/update-presets.bats`: bootstrap with `init --simple $TEST_DIR/proj` (no preset, all skills installed). Confirm `dev-shadcn` IS present. Run `update --preset homelab-proxmox --skills $TEST_DIR/proj`. Assert `dev-shadcn` is REMOVED... wait, it's already on disk so the COPY-only filter doesn't delete (EF-011). Re-think: assert `dev-shadcn` REMAINS (filter is COPY-only) but a NEW dropped skill (e.g. one only in foundation post-update) would not be added. Simplify: this case verifies that an explicit `--preset` resolves correctly and the filter is parsed; no behavioral change for skills already on disk. Keep the test focused on resolution + status line.
- [ ] T017 — [P] [US-3] `tests/update-presets.bats`: bootstrap with `init --preset nextjs $TEST_DIR/proj` (so `dev-flutter` is absent). Manually delete a foundation skill from the project (e.g. `dev-tdd`) to force `update` to re-add. Run `update --no-preset --skills $TEST_DIR/proj`. Assert `dev-tdd` is back AND `dev-flutter` is NOW present (no filter, today's behavior).
- [ ] T018 — [P] [US-1 / CS-006] `tests/update-presets.bats`: bootstrap with `init --simple $TEST_DIR/proj` (no preset). Run `update --all $TEST_DIR/proj` without flag. Assert every foundation skill is present (today's behavior, regression check).
- [ ] T019 — [P] [US-1] `tests/update-presets.bats`: nested-skill-file test. Bootstrap `init --preset nextjs $TEST_DIR/proj`. Manually create `$TEST_DIR/proj/.claude/skills/dev-flutter/extra.txt`. Run `update --skills`. Assert `dev-flutter/extra.txt` is left untouched (EF-011, filter is COPY-only). Then assert no NEW files arrive under `dev-flutter/` from the foundation (filter blocks copy).

### US-1+US-2+US-3 implementation

- [ ] T020 — [US-1] Implement `is_skill_dropped(rel_path)` in `scripts/update.sh`:
  - Extract leading dir component: `local skill_name="${rel_path%%/*}"`.
  - Iterate `ACTIVE_PRESET_DROP_LIST`; if `$skill_name` matches one entry, return 0 (dropped).
  - Else return 1.
  - Short-circuit return 1 when `ACTIVE_PRESET_DROP_LIST` is empty (no filter).
- [ ] T021 — [US-1] Patch `update_directory()` in `scripts/update.sh` (line 633 area):
  - When `name == "skills"` AND `is_skill_dropped "$rel_path"`, `continue` the loop before the existence/diff branch (effectively skipping copy).
  - Same guard inside the post-loop "non-md files for skills" sweep (line 757 area).
- [ ] T022 — [US-1/US-2/US-3] Wire `main()` in `scripts/update.sh`:
  - After `TARGET_DIR` is finalized but before any update step, call `resolve_active_preset` (which itself populates globals or fails fast).
  - On non-zero return, propagate the exit so the caller sees the error.

**Checkpoint**: T014–T019 green; `tests/update.bats` still green; `validate-counts.sh` may flag drift (handled in Phase 8).

---

## Phase 4 — User Story 4 (P2) — visibility line at start of update

**Goal**: when an active preset is set, print one info line announcing it; otherwise stay silent.

### Tests for US-4

- [ ] T023 — [P] [US-4] `tests/update-presets.bats`: auto-match scenario, output contains `Active preset: nextjs (detected)`.
- [ ] T024 — [P] [US-4] `tests/update-presets.bats`: explicit `--preset fastapi`, output contains `Active preset: fastapi (via --preset)`.
- [ ] T025 — [P] [US-4 / CS-006] `tests/update-presets.bats`: no preset active, output does NOT contain the substring `Active preset:` anywhere (silence preserved).

### US-4 implementation

- [ ] T026 — [US-4] In `main()` after `resolve_active_preset` succeeds and BEFORE the first `section`/update step:
  - If `ACTIVE_PRESET_NAME` non-empty, `info "Active preset: $ACTIVE_PRESET_NAME ($ACTIVE_PRESET_SOURCE) — skill filter applied"`.
  - Otherwise no print.

**Checkpoint**: visibility line correct in three scenarios; existing tests still green.

---

## Phase 5 — User Story 5 (P2) — dry-run reports skipped skills

**Goal**: `--dry-run` output explicitly lists the skills the active preset's filter will skip.

### Tests for US-5

- [ ] T027 — [P] [US-5] `tests/update-presets.bats`: `update --preset nextjs --skills --dry-run $TEST_DIR/proj`. Output contains `[DRY-RUN] Skip (preset filter): dev-flutter` (and other dropped skills). Skills NOT in the drop list do not appear under "Skip (preset filter)".

### US-5 implementation

- [ ] T028 — [US-5] In `update_directory()` skill loop, when `is_skill_dropped` matches AND `DRY_RUN=true`:
  - Print `[DRY-RUN] Skip (preset filter): <skill_name>` once per skill (use a small "already printed" set to dedupe).

**Checkpoint**: dry-run output explicitly shows the filter's effect for every dropped skill.

---

## Phase 6 — User Story 6 (P2) — orphan detection respects active preset

**Goal**: skills the active preset drops are not flagged as orphans.

### Tests for US-6

- [ ] T029 — [P] [US-6] `tests/update-presets.bats`: bootstrap `init --preset nextjs $TEST_DIR/proj`. Run `update --detect-orphans $TEST_DIR/proj`. Assert `dev-flutter` does NOT appear in the orphan list.
- [ ] T030 — [P] [US-6] `tests/update-presets.bats`: same scenario with `--no-preset`. Assert dropped skills DO appear in the orphan list (no filter, today's behavior).

### US-6 implementation

- [ ] T031 — [US-6] Identify the orphan-detection function (around `detect_orphan_files` line 1032 / `detect_all_orphans` line 1105). When iterating skills, exclude entries in `ACTIVE_PRESET_DROP_LIST` from the comparison.

**Checkpoint**: orphan detection no longer false-positives on intentionally-dropped skills.

---

## Phase 7 — User Story 7 (P3) — multi-match disambiguation

Already covered by EF-004 + T005 in Phase 2. No additional implementation here.

---

## Phase 8 — Polish & validation

- [ ] T032 — Run `bash scripts/test.sh` parallel; record runtime delta vs baseline. Must stay under the CS-006 budget (<30s overhead).
- [ ] T033 — Run `bash scripts/validate-presets.sh` — must still pass (no preset manifest changed).
- [ ] T034 — Run `bash scripts/validate-counts.sh` — bump README test counter as needed; run `npm --prefix website run generate` to refresh `counts.json` + placeholders if drift detected.
- [ ] T035 — [P] Update `CHANGELOG.md` `[Unreleased]` Added/Changed sections.
- [ ] T036 — [P] Mark `specs/presets-update-aware/spec.md` status: Draft → Validated.
- [ ] T037 — Run `/qa:qa-loop "score 90"`.
- [ ] T038 — Open PR (commit + push + `gh pr create`); surveille la CI (anticiper ShellCheck SC1010/SC2034 et un éventuel issue macOS, comme sur PRs #160/#161).

---

## Dependencies and Execution Order

```
Phase 1 (Setup)
   │
   ▼
Phase 2 (Foundation: parse + resolve)  ◄──── BLOCKS user stories
   │
   ├──▶ Phase 3 (US-1 + US-2 + US-3 — filter applied) 🎯 MVP
   │       │
   │       ├──▶ Phase 4 (US-4 — visibility)
   │       │
   │       ├──▶ Phase 5 (US-5 — dry-run)
   │       │
   │       └──▶ Phase 6 (US-6 — orphans)
   │
   └──▶ Phase 7 (US-7 — already in Phase 2)

All ──▶ Phase 8 (Polish + Gate 3 + PR)
```

### Dependencies between user stories

| Story | Can start after | Independent test |
|-------|-----------------|------------------|
| US-1 (P1) | Phase 2 (resolve) | `update --skills` on `init --preset nextjs` project doesn't re-add `dev-flutter` |
| US-2 (P1) | Phase 2 | `update --preset bogus` fails before any file change |
| US-3 (P1) | Phase 2 | `update --no-preset` on a preset project copies every foundation skill |
| US-4 (P2) | Phase 3 (needs ACTIVE_PRESET_*) | Output line correct in 3 scenarios |
| US-5 (P2) | Phase 3 | `--dry-run` output lists skipped skills |
| US-6 (P2) | Phase 3 | `--detect-orphans` excludes dropped skills |
| US-7 (P3) | Phase 2 | Multi-match exits non-zero with disambiguation message |

### MVP cut

If scope tightens: ship Phases 1+2+3 only (US-1+US-2+US-3, the entire P1 set). The filter actually works; visibility/dry-run/orphan-aware can ship in a follow-up. In practice the cost of US-4/5/6 is small (one PR covers everything realistic).

---

## Parallelization opportunities

- T003–T007 — Phase 2 tests, all in same bats file (sequential within file, parallel at file level via `scripts/test.sh`).
- T014–T019 — Phase 3 tests, all in same bats file (same idiom).
- T023–T025 — Phase 4 tests (same).
- T020 (impl `is_skill_dropped`) and T021 (patch `update_directory`) are sequential.
- T028 (US-5 dry-run) is independent of US-4 once Phase 3 lands.
- T031 (US-6 orphan) is independent of US-4/US-5.

---

## Implementation Strategy

### MVP first (US-1 + US-2 + US-3)

1. Phase 1 (skeletons) — ~10 min
2. Phase 2 (parse + resolve + tests) — ~1 h
3. Phase 3 (filter applied + tests) — ~1.5 h
4. Stop. Validate independently. Commit.
5. Optionally continue Phases 4-6 in same PR or follow-up.

### Single-PR strategy (recommended given small scope of P2 phases)

Ship everything (Phases 1-8) in one PR but with sub-commits aligned to phases. Commit cadence:
- chore(presets): branch + skeleton (Phase 1)
- feat(presets): update.sh learns --preset/--no-preset (Phases 2-3)
- feat(presets): update visibility line + dry-run filter listing (Phases 4-5)
- feat(presets): update orphan detection respects active preset (Phase 6)
- docs(presets): changelog + spec validated (Phase 8)
- (CI fix commits as needed)

---

## Notes

- This work continues the preset story from PR #160 + #161. After merge, the spec joins the family `specs/presets/` + `specs/presets-detection-and-e2e/` + `specs/presets-update-aware/`.
- Memory write deferred until merged.
- Run tests via `bash scripts/test.sh` (parallel ~1m), not `bats tests/*.bats` directly (memory `feedback_release_flow_test_sh.md`).
- Avoid `local fi` (ShellCheck SC1010 — bit us in PR #160).
- For cross-file globals set by lib and read by caller, use inline `# shellcheck disable=SC2034` (bit us in PR #161).
- Don't use `timeout` in bats tests (not native on macOS BSD — bit us in PR #161).

**To avoid**:
- Mutating `scripts/new-project.sh` or `scripts/lib/preset-detect.sh` (just shipped, low-risk-aversion to keep them untouched here).
- Persisting preset name to disk (out of scope).
- Filtering commands/agents/rules by preset (out of scope).
- Tests that depend on actual `claude plugin install` (existing graceful skip path applies).

---

**Version**: 1.0 | **Created**: 2026-05-09
