# Tasks: preset detection (data-driven) + per-preset end-to-end

**Input**: design documents from `specs/presets-detection-and-e2e/`
**Prerequisites**: `plan.md` (required), `spec.md` (required, clarifications 1–3 resolved)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** — can be executed in parallel (different files, no dependencies)
- **[US?]** — associated user story (traceability)
- File paths absolute from repo root

---

## Phase 1 — Setup (lightweight skeletons)

**Goal**: skeletons in place; suite stays green.

- [ ] T001 — Rename branch from `feature/auto-20260508-101622` to `feature/presets-detection-and-e2e` via `/git-rename` (no commits to migrate, working tree clean).
- [ ] T002 — [P] Create `scripts/lib/preset-detect.sh` skeleton: header comment, `set -u`, exposes empty function `scan_presets()`, no logic yet.
- [ ] T003 — [P] Create empty fixture dirs: `tests/presets-fixtures/nextjs/`, `tests/presets-fixtures/fastapi/`, `tests/presets-fixtures/astro/`, `tests/presets-fixtures/homelab-proxmox/` (with a `.gitkeep` each).
- [ ] T004 — [P] Create `tests/preset-detect.bats` with bats boilerplate (`load 'test_helper'`, `setup`, `teardown`, no test cases yet).
- [ ] T005 — [P] Create `tests/preset-e2e.bats` with bats boilerplate (`load 'test_helper'`, `setup`, `teardown`, no test cases yet).

**Checkpoint**: skeletons exist; `bash scripts/test.sh` still green.

---

## Phase 2 — Foundation (blocking) — schema validator

**Goal**: validator enforces the new `detect` schema. Required before any user story can ship.

⚠️ **CRITICAL**: do not start US1+ until this phase is finished.

### Tests for foundation (TDD)

- [ ] T006 — [P] Add to `tests/presets.bats`: `validate-presets.sh` accepts a synthetic preset with a valid `detect` block (anyOf, files, depFiles).
- [ ] T007 — [P] Add to `tests/presets.bats`: `validate-presets.sh` rejects a preset whose `detect` has empty files AND empty depFiles (must have at least one signal).
- [ ] T008 — [P] Add to `tests/presets.bats`: `validate-presets.sh` rejects a preset whose `detect.combinator` is not `allOf` or `anyOf`.
- [ ] T009 — [P] Add to `tests/presets.bats`: `validate-presets.sh` rejects a `depFiles` entry missing `path` or `contains`.

### Foundation implementation

- [ ] T010 — Extend `scripts/validate-presets.sh` `validate_one()`: parse optional `.detect` block, verify combinator enum (`allOf`|`anyOf`, default `anyOf`), verify `(files | length) + (depFiles | length) > 0`, verify each `depFiles[i]` has both `path` and `contains` strings.

**Checkpoint**: validator accepts existing 5 presets (none have `detect` yet) and tests T006–T009 pass.

---

## Phase 3 — User Story 1 + 2 (P1 — detection MVP) 🎯

**Goal**: scan presets, return matches, render suggestion in non-interactive mode. Adding a new preset (T015) requires zero code change.

**Independent test**: `new-project.sh -y existing-nextjs-app/` prints an info line referencing preset `nextjs`.

### Tests for US1+US2 (TDD — write first, must FAIL before implementation)

- [ ] T011 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `next.config.js` + `package.json` containing `"next"` ⇒ `scan_presets` stdout contains `nextjs`. Test must FAIL before T016.
- [ ] T012 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `pyproject.toml` containing `fastapi` ⇒ stdout contains `fastapi`.
- [ ] T013 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `astro.config.mjs` ⇒ stdout contains `astro`.
- [ ] T014 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `*.tf` containing `telmate/proxmox` or `bpg/proxmox` ⇒ stdout contains `homelab-proxmox`.
- [ ] T015 — [P] [US1] `tests/preset-detect.bats`: empty dir (no marker files) ⇒ `scan_presets` stdout empty, exit 0.
- [ ] T016 — [P] [US1] `tests/preset-detect.bats`: combinator `allOf` requires every signal to match; partial match returns nothing.
- [ ] T017 — [P] [US1] `tests/preset-detect.bats`: combinator `anyOf` (default) returns the preset on any single signal match.
- [ ] T018 — [P] [US1] `tests/preset-detect.bats`: jq missing on PATH (simulated by overriding) ⇒ `scan_presets` exits 0 with empty output (graceful).
- [ ] T019 — [P] [US1] `tests/preset-detect.bats`: malformed detect block in one preset ⇒ that preset skipped, others still scanned.
- [ ] T020 — [P] [US1] `tests/preset-detect.bats`: deterministic output order (alphabetical by preset name).
- [ ] T021 — [P] [US2] `tests/preset-detect.bats`: drop a synthetic preset JSON in a temp presets dir (via env var `PRESETS_DIR_OVERRIDE` or argument), verify it's discovered without modifying any production code. **This is the "zero-code-for-new-preset" assertion**.
- [ ] T022 — [P] [US1] `tests/presets.bats` addition: `new-project.sh -y` on a Next.js fixture prints info line containing both `Detected` and `nextjs`.
- [ ] T023 — [P] [US1] `tests/presets.bats` addition: `new-project.sh --preset nextjs ./other-dir` does NOT print any line about other matching presets (EF-016 guarantee).

### US1+US2 implementation

- [ ] T024 — [US1] Implement `scan_presets(target_dir)` in `scripts/lib/preset-detect.sh`:
  - Iterate `.claude/presets/*.json` (and `community/*.json`) sorted by name.
  - For each, jq-extract `.detect` block; skip if absent.
  - Evaluate each `files[]` signal: `find "$target_dir" -maxdepth 2 -name "<glob>" -print -quit | grep -q .`
  - Evaluate each `depFiles[]` signal: `[ -f "$target_dir/$path" ] && grep -qi -- "$contains" "$target_dir/$path"`
  - Apply combinator (`allOf` = all signals match, `anyOf` = at least one).
  - Print matching preset name to stdout.
- [ ] T025 — [US1] Add `detect` block to `.claude/presets/nextjs.json`:
  - `combinator: anyOf`
  - `files: ["next.config.js", "next.config.mjs", "next.config.ts"]`
  - `depFiles: [{path: "package.json", contains: "\"next\""}]`
- [ ] T026 — [US1] Add `detect` block to `.claude/presets/fastapi.json`:
  - `combinator: anyOf`
  - `depFiles: [{path: "requirements.txt", contains: "fastapi"}, {path: "pyproject.toml", contains: "fastapi"}]`
- [ ] T027 — [US1] Add `detect` block to `.claude/presets/astro.json`:
  - `combinator: anyOf`
  - `files: ["astro.config.mjs", "astro.config.ts", "astro.config.js"]`
  - `depFiles: [{path: "package.json", contains: "\"astro\""}]`
- [ ] T028 — [US1] Add `detect` block to `.claude/presets/homelab-proxmox.json`:
  - `combinator: anyOf`
  - `depFiles: [{path: "main.tf", contains: "telmate/proxmox"}, {path: "main.tf", contains: "bpg/proxmox"}, {path: "providers.tf", contains: "proxmox"}]`
  - (No `files: ["*.tf"]` to avoid generic Terraform false positive.)
- [ ] T029 — [US1] Source `lib/preset-detect.sh` from `scripts/new-project.sh`.
- [ ] T030 — [US1] In `new-project.sh`, after `detect_stack` and before any prompt: if `PRESET_NAME` empty (no explicit `--preset`), call `scan_presets` and store result in `MATCHED_PRESETS` array.
- [ ] T031 — [US1] In non-interactive flow: when `MATCHED_PRESETS` is non-empty, print info line(s) `Detected stack — preset(s) match: <names> (run with --preset <name> to use)`.
- [ ] T032 — [US1] Gate detection: if `--preset` was explicitly passed, do NOT call `scan_presets` (EF-016).

**Checkpoint**: T011–T023 pass. `bash scripts/test.sh` shows new test count + green.

---

## Phase 4 — User Story 3 (P1 — per-preset E2E) 🎯

**Goal**: each preset has a passing end-to-end test that bootstraps + validates + asserts hook drift-guard.

**Independent test**: deliberately delete a hook script after install ⇒ test fails with precise message.

### Tests for US3 (these ARE the deliverable)

- [ ] T033 — [P] [US3] `tests/preset-e2e.bats`: helper `bootstrap_preset(preset_name)` that runs `new-project.sh --preset <name> "$TEST_DIR/proj-<name>"` and returns the target path.
- [ ] T034 — [P] [US3] `tests/preset-e2e.bats`: per-preset case for `nextjs` — bootstrap, assert exit 0, assert `.claude/` exists.
- [ ] T035 — [P] [US3] `tests/preset-e2e.bats`: per-preset case for `fastapi` — bootstrap, assert exit 0.
- [ ] T036 — [P] [US3] `tests/preset-e2e.bats`: per-preset case for `astro` — bootstrap, assert exit 0.
- [ ] T037 — [P] [US3] `tests/preset-e2e.bats`: per-preset case for `homelab-proxmox` — bootstrap, assert exit 0.
- [ ] T038 — [P] [US3] `tests/preset-e2e.bats`: per-preset case for `cli-tools` — bootstrap, assert exit 0.
- [ ] T039 — [P] [US3] `tests/preset-e2e.bats`: post-bootstrap, run `bash scripts/validate.sh -q "$target"` and assert exit 0 (looped over all presets).
- [ ] T040 — [P] [US3] `tests/preset-e2e.bats`: post-bootstrap, run `bash scripts/doctor.sh "$target"` and assert exit 0/1/2 (current acceptable range, mirroring existing e2e.bats).
- [ ] T041 — [P] [US3] `tests/preset-e2e.bats`: hook drift-guard — for each bootstrap, jq-extract every hook script path from `$target/.claude/settings.json` (`PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SessionStart`, etc.), assert each resolves to an existing file under `$target/.claude/`. Failure message must name the missing file.
- [ ] T042 — [P] [US3] `tests/preset-e2e.bats`: regression-mode self-check — given an artificial scenario where a hook is removed post-bootstrap, the assertion fires with the expected message (so we know the test isn't silently passing).

**Checkpoint**: 5 preset E2E + drift-guard pass. Measure runtime delta — must be < 30s in parallel mode (CS-006).

---

## Phase 5 — User Story 4 (P2 — in-menu suggestion in interactive flow)

**Goal**: interactive `new-project.sh` prepends matching presets above the standard 11 type options.

**Independent test**: simulated interactive run on a Next.js fixture displays "Use preset: nextjs (detected)" as menu entry.

### Tests for US4

- [ ] T043 — [P] [US4] `tests/new-project.bats`: simulated interactive run with $TEST_DIR pre-populated as a Next.js fixture; menu output contains the preset entry "Use preset: nextjs".
- [ ] T044 — [P] [US4] `tests/new-project.bats`: same scenario, two presets match (synthetic) ⇒ both appear above the standard types.
- [ ] T045 — [P] [US4] `tests/new-project.bats`: when matched presets is empty, menu is identical to today (regression check).

### US4 implementation

- [ ] T046 — [US4] Modify `get_project_type()` in `scripts/new-project.sh`:
  - Read `MATCHED_PRESETS` array (set in Phase 3).
  - For each matched preset, prepend a numbered option labelled `Use preset: <name> (detected)` above option `1`.
  - Renumber accordingly: if 2 presets matched, the 11 standard types become options 3–13.
  - Update the `Choice [1-N]` prompt to reflect the dynamic count.
- [ ] T047 — [US4] When the user picks a preset entry: set `PRESET_NAME` to the corresponding preset name and route through `load_preset()`; do not show the standard type menu again.
- [ ] T048 — [US4] When the user picks a standard type: ignore matched presets, behave as today.
- [ ] T049 — [US4] Audit `tests/new-project.bats` for hardcoded "Choice [1-11]" assertions; widen to a regex tolerant of `Choice [1-N]`.

**Checkpoint**: interactive tests pass; existing `new-project.bats` still green.

---

## Phase 6 — User Story 5 (P2 — fixture drift-guard)

**Goal**: each preset's detect rule asserted to match its paired fixture in CI.

**Independent test**: rename a marker file in a fixture ⇒ paired test fails.

### Fixtures

- [ ] T050 — [P] [US5] Populate `tests/presets-fixtures/nextjs/` with `next.config.js` (one-line minimal) + `package.json` containing `"next": "^15"` in dependencies.
- [ ] T051 — [P] [US5] Populate `tests/presets-fixtures/fastapi/` with `pyproject.toml` containing `fastapi` in dependencies (minimal valid pyproject).
- [ ] T052 — [P] [US5] Populate `tests/presets-fixtures/astro/` with `astro.config.mjs` (one-line minimal export).
- [ ] T053 — [P] [US5] Populate `tests/presets-fixtures/homelab-proxmox/` with `main.tf` containing a `terraform { required_providers { proxmox = { source = "telmate/proxmox" } } }` block.

### Tests

- [ ] T054 — [P] [US5] Add to `tests/presets.bats`: for each preset with a `detect` block, assert `scan_presets("tests/presets-fixtures/<preset>/")` stdout contains exactly that preset's name.

**Checkpoint**: rule↔fixture pairing verified; 4 presets covered (cli-tools intentionally absent — EF-009).

---

## Phase 7 — User Story 6 (P3 — `--detect-only` flag) [optional]

**Decision gate**: ship only if Phases 1–6 stayed under the 30s budget; otherwise defer to follow-up PR.

- [ ] T055 — [US6] Add `--detect-only PATH` to `parse_args` in `scripts/new-project.sh`. Mode: call `scan_presets`, print matched names + (optional) signal source per match, exit 0. No file writes.
- [ ] T056 — [P] [US6] Add to `tests/presets.bats`: `--detect-only` on a Next.js fixture prints `nextjs`, exits 0, and writes nothing in the target dir.
- [ ] T057 — [P] [US6] Update `show_help()` in `new-project.sh` to document `--detect-only`.

---

## Phase 8 — User Story 7 (P3 — doc update)

- [ ] T058 — [P] [US7] Update `.claude/presets/README.md` "Format quick reference" section: add `detect` block schema with two worked examples (one file-presence, one dep-file).
- [ ] T059 — [P] [US7] Add a sentence in `specs/presets/spec.md` cross-linking to `specs/presets-detection-and-e2e/spec.md` for the detection extension.
- [ ] T060 — [P] [US7] If any of `docs/reference/`, `docs/guides/`, `docs/concepts/` got touched, regenerate website docs (memory `feedback_website_docs_regen.md`).

---

## Phase 9 — Polish & validation

- [ ] T061 — Run `bash scripts/test.sh` in parallel mode; measure total runtime delta vs baseline; record in plan notes.
- [ ] T062 — Run `bash scripts/validate-presets.sh` — all 5 presets must pass with their new `detect` blocks.
- [ ] T063 — Run `bash scripts/validate-counts.sh` — confirm no drift introduced (new files present in counts).
- [ ] T064 — [P] Update `CHANGELOG.md` `[Unreleased]` with `### Added` entries for detection + E2E.
- [ ] T065 — [P] Mark `specs/presets-detection-and-e2e/spec.md` status: Draft → Validated.
- [ ] T066 — Run `/qa:qa-loop "score 90"`.
- [ ] T067 — Save a memory entry summarising what shipped (only after PR merged — not now).

---

## Dependencies and Execution Order

```
Phase 1 (Setup)
   │
   ▼
Phase 2 (Foundation — validator)  ◄──── BLOCKS all user stories
   │
   ├──▶ Phase 3 (US1 + US2 — detection MVP)
   │       │
   │       ▼
   │    Phase 5 (US4 — interactive UX)
   │       │
   │       ▼
   │    Phase 6 (US5 — fixtures pairing)
   │
   └──▶ Phase 4 (US3 — E2E) [independent of Phase 3]

Phase 7 (US6) [optional, after Phase 3]
Phase 8 (US7) [doc, anytime after Phase 3]

All ──▶ Phase 9 (Polish + Gate 3)
```

### Dependencies between user stories

| Story | Can start after | Independent test |
|-------|-----------------|------------------|
| US1 (P1) | Phase 2 (validator) | `new-project.sh -y existing-app/` prints suggestion |
| US2 (P1) | Phase 2 (validator) | Drop new preset .json ⇒ discovered, no other change |
| US3 (P1) | Phase 2 | E2E loop passes for all 5 presets |
| US4 (P2) | Phase 3 (needs MATCHED_PRESETS) | Interactive menu shows preset entry |
| US5 (P2) | Phase 3 (needs `detect` blocks) | Fixture renamed ⇒ paired test fails |
| US6 (P3) | Phase 3 | `--detect-only` prints names |
| US7 (P3) | Phase 3 | README has format reference |

### MVP cut

If scope tightens: ship Phases 1+2+3+4 only (US1+US2+US3). That's the minimum that proves data-driven scaling and protects against v1.36.1-class regressions. US4–US7 can ship in a follow-up PR.

---

## Parallelization opportunities

- T002, T003, T004, T005 — Phase 1 skeletons (different files, parallel)
- T006–T009 — Phase 2 validator tests (same file, but independent test cases — `bats` runs them sequentially within a file by default; parallelism is at the file level via `scripts/test.sh`)
- T011–T023 — Phase 3 tests, all in `tests/preset-detect.bats` and `tests/presets.bats` — same files, sequential within bats but can be batch-edited
- T025–T028 — Phase 3 implementation: 4 different preset JSON files, fully parallel
- T034–T038 — Phase 4 E2E cases per preset: same file, sequential at bats level
- T050–T053 — Phase 6 fixtures: 4 different fixture dirs, fully parallel

---

## Implementation Strategy

### MVP first (US1 + US2 + US3)

1. Phase 1 (skeletons) — ~15 min
2. Phase 2 (validator extension + tests) — ~30 min
3. Phase 3 (detection MVP) — ~2 h
4. Phase 4 (E2E loop) — ~1 h
5. Stop. Validate independently. Commit a coherent unit.
6. Open PR. Review.

### Follow-ups (P2 + P3, separate PR)

1. Phase 5 (US4 interactive UX) — ~1 h
2. Phase 6 (US5 fixtures) — ~30 min
3. Phase 7 (US6 standalone flag) — ~30 min if budget permits
4. Phase 8 (US7 doc) — ~15 min
5. Phase 9 (polish) — ~30 min
6. Open second PR.

### Single-PR strategy (alternative)

If review cost is the concern over commit volume: ship everything in one PR but with sub-commits aligned to phases. Use commit messages like `feat(presets): add detect block schema validator` per task group.

---

## Notes

- Branch rename via `/git-rename` is T001. Working tree is clean per the repo context, no commits to migrate. Safe.
- The `cli-tools` preset stays without a `detect` block. Justified by EF-009 + plan rationale (target too generic).
- Memory write deferred until merged (per memory hygiene — don't write speculative project memories).
- All written content (specs, comments, docs, commits, PRs) in English (memory `feedback_repo_language_english_only.md`).
- Run tests via `bash scripts/test.sh` (parallel, ~1 min) rather than `bats tests/*.bats` directly (memory `feedback_release_flow_test_sh.md`).
- BSD `wc -l` whitespace gotcha: not used here directly, but if any new comparison hits it, strip via `tr -d '[:space:]'` (memory `feedback_bsd_wc_whitespace.md`).

**To avoid**:
- Editing `scripts/lib/detection.sh` to add per-preset mappings (defeats the data-driven design).
- Adding a preset's name to a hardcoded list in `new-project.sh` or in any test file.
- Cross-story dependencies that break US1/US2/US3 independence.
- Tests that run `claude plugin install` for real in CI (skipped by graceful fallback per existing code).

---

**Version**: 1.0 | **Created**: 2026-05-09
