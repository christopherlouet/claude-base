# Implementation Plan: preset-aware updates

**Branch**: `feature/presets-update-aware` (rename current `feature/auto-20260509-164232`)
**Date**: 2026-05-09
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Make `claude-base update` (i.e. `scripts/update.sh`) respect the same preset filter as `claude-base init`. When the user runs `update --all` on a project that was bootstrapped with `--preset nextjs`, the skills the preset deliberately dropped (e.g. `dev-flutter`, `ops-mobile-release`) are no longer copied back from the foundation. The preset is determined at update time by the existing `scan_presets()` library shipped in PR #160 — no new state is persisted on disk. `--preset <name>` overrides detection, `--no-preset` opts out. When two or more presets match without an explicit override, update refuses to proceed and instructs the user to disambiguate.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language** | Bash 4+ (existing baseline) | Same as PR #160 / #161 |
| **JSON parsing** | `jq` (existing) | Already required by foundation |
| **Tests** | `bats` via `scripts/test.sh` (parallel) | New `tests/update-presets.bats` |
| **Reused libs** | `scripts/lib/preset-detect.sh::scan_presets` (PR #160) | Detection logic unchanged |
| **Target platform** | Linux + macOS | BSD vs GNU portability already a known constraint |

### Constraints

- Must not regress the 520 tests shipped in PR #160 + #161.
- No new persisted state (decided in spec — out of scope).
- Output byte-identical to today's `update --all` when no preset matches and no flag is passed (CS-006).
- Total parallel test runtime increase budget: < 30s.
- All written content in English (memory `feedback_repo_language_english_only.md`).
- Keep `scripts/new-project.sh` and `scripts/lib/preset-detect.sh` untouched if possible — risk-averse approach since both shipped 4 hours ago.

### Expected behavior

| Trigger | Expected output |
|---|---|
| `update --all <next.js-app>` (auto-match) | Info line "Active preset: nextjs (detected)"; skills.drop list filtered out of copy |
| `update --preset fastapi --all <any>` | Info line "Active preset: fastapi (via --preset)"; fastapi filter applied |
| `update --no-preset --all <next.js-app>` | No info line; every skill copied (today's behavior) |
| `update --all <next.js-app>` matching 2+ presets | Exit non-zero, message lists matches, instructs --preset/--no-preset |
| `update --preset bogus <any>` | Exit non-zero before any file change, names the missing preset |
| `update --all <plain-go-service>` (no match, no flag) | No info line; output byte-identical to today |

---

## Constitution / Conventions Check

- [x] Workflow followed: Explore → Specify → Clarify → Plan → TDD → Audit → Commit
- [x] Reuses existing infrastructure (scan_presets) instead of rebuilding
- [x] No persisted state (per spec out-of-scope)
- [x] Tests planned: bats unit (resolve_active_preset, load_active_drop_list, is_skill_dropped) + integration (update --preset/--no-preset on real fixtures)

---

## Project Structure

### Documentation (this feature)

```
specs/presets-update-aware/
├── spec.md           # Functional specification (resolved)
├── plan.md           # This file
└── tasks.md          # Task breakdown
```

### Source layout (target areas)

```
scripts/
├── update.sh                  # MODIFY — add --preset/--no-preset, resolve, filter
├── lib/
│   └── preset-detect.sh       # NO CHANGE (reuse scan_presets)
└── new-project.sh             # NO CHANGE (PR #160 shipped, untouched here)

tests/
└── update-presets.bats        # NEW — preset-aware update behavior
```

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `tests/update-presets.bats` | All preset-aware update tests: resolve, filter applied, override, opt-out, multi-match refuse, orphan-aware, dry-run lists skipped. |
| `specs/presets-update-aware/tasks.md` | Task breakdown |

### To modify

| File | Modification |
|------|--------------|
| `scripts/update.sh` | (1) source `lib/preset-detect.sh`; (2) add globals `UPDATE_PRESET_NAME`, `UPDATE_NO_PRESET`, `ACTIVE_PRESET_FILE`, `ACTIVE_PRESET_NAME`, `ACTIVE_PRESET_SOURCE`, `ACTIVE_PRESET_DROP_LIST`; (3) parse_args: handle `--preset NAME` and `--no-preset`, mutual exclusion; (4) new helpers: `resolve_active_preset`, `load_active_drop_list`, `is_skill_dropped`; (5) `update_directory` for `name=skills`: skip files whose top-level dir is in the drop list; (6) `detect_orphan_files` for `skills`: do not flag dropped skills as orphans; (7) main: call `resolve_active_preset` early, print one-line status if a preset is active, fail fast on multi-match. |
| `scripts/update.sh` show_help | Document `--preset NAME` and `--no-preset` flags, plus updated examples. |
| `CHANGELOG.md` | `[Unreleased]` entry under "Added" / "Changed". |
| `README.md` | Bump test counter (auto via Counts gate); maybe a one-line mention of preset-aware update — handled in Polish phase. |

### Tests to add

| File | Coverage |
|------|----------|
| `tests/update-presets.bats` | resolve_active_preset (0/1/2+ matches, --preset, --no-preset, mutual exclusion); skill copy filtered when active preset drops the skill; opt-out copies everything; explicit --preset overrides detection; unknown preset name fails before any file change; orphan detection respects active preset; dry-run names skipped skills; multi-match refusal exit code + message; backwards-compat (no preset, no flag) byte-identical |

---

## Chosen Approach

### Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  scripts/update.sh                                                   │
│    │                                                                 │
│    │  parse_args (NEW: --preset NAME, --no-preset, mutex check)      │
│    │                                                                 │
│    ▼                                                                 │
│  resolve_active_preset()  ◄──── reuses scripts/lib/preset-detect.sh  │
│    │                                                                 │
│    │  --no-preset?              → NONE                               │
│    │  --preset NAME?            → resolve to file or fail            │
│    │  else scan_presets count?  → 0:NONE, 1:auto, 2+:fail-with-list  │
│    │                                                                 │
│    ▼                                                                 │
│  ACTIVE_PRESET_NAME / FILE / SOURCE / DROP_LIST populated            │
│    │                                                                 │
│    ▼                                                                 │
│  Print one-line status (only if active)                              │
│    │                                                                 │
│    ▼                                                                 │
│  update_directory("skills", ...)  ◄── filter via is_skill_dropped()  │
│    │                                                                 │
│    │  for each src_file:                                             │
│    │    rel_path top-level dir in DROP_LIST? → skip                  │
│    │                                                                 │
│    ▼                                                                 │
│  detect_orphan_files()  ◄── skills in DROP_LIST excluded             │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Preset resolution rules (encoded by `resolve_active_preset`)

| Input | Output `ACTIVE_PRESET_*` | Exit |
|---|---|---|
| `--no-preset` | NAME="", FILE="", SOURCE="" | 0 (continue, no filter) |
| `--preset NAME` (resolved) | NAME=$NAME, FILE=path, SOURCE="--preset" | 0 |
| `--preset NAME` (not found) | (unset) | non-zero, error message |
| no flag, scan_presets returns 0 | NAME="", FILE="", SOURCE="" | 0 (continue, no filter) |
| no flag, scan_presets returns 1 | NAME=match, FILE=path, SOURCE="detected" | 0 |
| no flag, scan_presets returns 2+ | (unset) | non-zero, list + instruction |

### Status line format

```
[INFO] Active preset: nextjs (detected) — skill filter applied
[INFO] Active preset: fastapi (via --preset) — skill filter applied
```

When no preset is active: **print nothing** (silence preserves CS-006 byte-identity).

### Skill filter semantics (encoded by `is_skill_dropped`)

A skill rel_path is `<skill-name>/<file>` (e.g. `dev-flutter/SKILL.md`, `dev-flutter/examples/foo.py`). The filter takes the leading dir component and checks membership in `ACTIVE_PRESET_DROP_LIST`. If matched, the file is skipped during copy (and during the non-md sweep). Skills already on disk that are now in the drop list are left untouched (EF-011 — never delete).

### Rationale

- **Reuse over rebuild**: `scan_presets` is already battle-tested via 19 tests in PR #160. Plugging it into update.sh costs ~5 lines.
- **No persisted state**: matches the user's clarified preference (option A from the prior chat). The detection rule is the source of truth; if the project drifts, the filter follows.
- **Skill-only filter**: today's preset semantics filter only skills (matches new-project.sh::apply_preset_filter). No reason to expand scope here.
- **Silent on no-preset**: directly resolves the EF-012 vs CS-006 conflict surfaced during clarify. Non-preset users see zero new noise.
- **No churn on shipped code**: keeping `new-project.sh` and `lib/preset-detect.sh` untouched eliminates the regression risk on PRs #160/#161.

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Persist preset name in `settings.json` (`_claudeBase.preset`) | Adds non-standard key to a Claude Code config file; new schema to version. Out of scope per clarified spec. |
| Persist in `.claude/.preset` dotfile | Introduces a new on-disk artifact; redundant with detection-at-update-time. |
| Auto-pick first preset on multi-match | Silently changes which skills are filtered; never the safe default for destructive-ish ops. |
| Retroactively delete skills the preset would drop | Destroys user customizations silently; rejected in clarify (option (a)). |
| Filter commands/agents/rules too | Out of scope per spec — preset semantics filter only skills today. |
| Refactor `new-project.sh::apply_preset_filter` into shared lib | Touches just-shipped code; mechanical refactor not justified now (each file's logic is small and slightly different). |

---

## Implementation Phases

### Phase 1 — Setup (lightweight)

**Objective**: branch rename, skeleton tests file, no logic.

- T001 — Rename branch to `feature/presets-update-aware` via Bash `git branch -m` (working tree clean).
- T002 — Create `tests/update-presets.bats` with bats boilerplate (load test_helper, setup_test_dir, teardown).

**Checkpoint**: skeletons present, suite green.

### Phase 2 — Foundation (blocking) — argument parsing + resolution

**Objective**: parse new flags, resolve active preset, fail fast on bad input. No filter applied yet.

⚠️ **CRITICAL**: do not start US-1+ until this phase passes.

#### Tests for foundation (TDD)

- T003 — [P] [US-2] `tests/update-presets.bats`: `--preset bogus_xyz <path>` exits non-zero with a message naming the missing preset; no file changes (asserted via mtime/diff on the target).
- T004 — [P] [US-3] `tests/update-presets.bats`: `--preset nextjs --no-preset <path>` exits non-zero with mutual-exclusion message.
- T005 — [P] [US-7] `tests/update-presets.bats`: a synthetic project that matches 2+ presets, run without flag, exits non-zero and the message lists each matching preset.
- T006 — [P] [US-1] `tests/update-presets.bats`: `--preset nextjs <path>` resolves successfully (no error, no skill-filter assertion yet — that's Phase 3).
- T007 — [P] [US-3] `tests/update-presets.bats`: `--no-preset <empty-non-matching-path>` does NOT print the status line (silence preserves CS-006).

#### Foundation implementation

- T008 — Source `scripts/lib/preset-detect.sh` from `scripts/update.sh`.
- T009 — Add globals: `UPDATE_PRESET_NAME=""`, `UPDATE_NO_PRESET=false`, `ACTIVE_PRESET_FILE=""`, `ACTIVE_PRESET_NAME=""`, `ACTIVE_PRESET_SOURCE=""`, `ACTIVE_PRESET_DROP_LIST=()`.
- T010 — Extend `parse_args()`: handle `--preset NAME` (with required-arg check), `--no-preset`. Add mutual-exclusion check at end of parse.
- T011 — Implement `resolve_active_preset()`: encodes the table above. Returns 0 if active or none, non-zero on bogus name or multi-match.
- T012 — Implement `load_active_drop_list()`: jq-extract `.foundation.skills.drop[]?` from `ACTIVE_PRESET_FILE`, populate `ACTIVE_PRESET_DROP_LIST`.
- T013 — Update `show_help()`: document `--preset NAME` and `--no-preset` with examples.

**Checkpoint**: T003–T007 green; old tests still pass (no behavior change yet for non-flag callers).

### Phase 3 — US-1 + US-2 + US-3 (P1) — filter applied to skill copy

**Objective**: when an active preset is set, the skills the preset drops are skipped during the copy step.

**Independent test**: `update --all` on a Next.js project ends up with the same skill set as a fresh `init --preset nextjs`.

#### Tests (TDD — write first, must FAIL before implementation)

- T014 — [P] [US-1] `tests/update-presets.bats`: bootstrap a project with `init --preset nextjs`, manually copy a dropped skill into the project to simulate drift, run `update --all` (no flag), assert the dropped skill remains absent post-update (proves the filter blocks the re-add path).

  Wait — the dropped skill won't exist in the project. The test should be: bootstrap, manually delete settings to make project look "out of date", inject a marker file showing detection should trigger, run `update --skills`, assert dropped skills NOT re-introduced.

  Refined: bootstrap with `--preset nextjs`. Confirm `dev-flutter` is absent. Run `update --skills <project>`. Assert `dev-flutter` is still absent post-update.

- T015 — [P] [US-1] `tests/update-presets.bats`: same scenario but with auto-detection (no `--preset` on update). Assert detection picks `nextjs` and filter applies.
- T016 — [P] [US-2] `tests/update-presets.bats`: bootstrap with `--simple` (no preset), then `update --preset homelab-proxmox --skills`. Assert frontend skills (e.g. `dev-shadcn`) are NOT introduced. (Tests explicit override.)
- T017 — [P] [US-3] `tests/update-presets.bats`: bootstrap with `--preset nextjs`, then `update --no-preset --skills`. Assert `dev-flutter` IS introduced (no filter). Verifies opt-out path.
- T018 — [P] [US-1] `tests/update-presets.bats`: project not matching any preset, no flag, `update --all`: every foundation skill present (today's behavior, regression check).

#### Implementation

- T019 — [US-1] Implement `is_skill_dropped(rel_path)`: check whether the leading dir of `rel_path` is in `ACTIVE_PRESET_DROP_LIST`. Returns 0 if dropped (skip), 1 otherwise.
- T020 — [US-1] Patch `update_directory()`: when `name == "skills"` and the active preset has a non-empty drop list, call `is_skill_dropped` for each `rel_path`; skip the file (do not enter the diff/copy branch). Also apply to the post-loop "non-md files for skills" sweep (line 757 area).
- T021 — [US-1/US-2/US-3] Wire `main()` to call `resolve_active_preset` early (after path resolution, before any update step). Failure paths exit immediately.

**Checkpoint**: T014–T018 green. Existing `tests/update.bats` still green.

### Phase 4 — US-4 (P2) — visibility line at start of update

- T022 — [P] [US-4] `tests/update-presets.bats`: auto-match scenario, output contains `Active preset: nextjs (detected)`.
- T023 — [P] [US-4] `tests/update-presets.bats`: explicit `--preset fastapi`, output contains `Active preset: fastapi (via --preset)`.
- T024 — [P] [US-4] `tests/update-presets.bats`: no preset active, output does NOT contain "Active preset" anywhere (silence — CS-006).
- T025 — [US-4] In `main()` after `resolve_active_preset`, if `ACTIVE_PRESET_NAME` non-empty, print one info line: `Active preset: <name> (<source>) — skill filter applied`.

**Checkpoint**: status line correct in three scenarios.

### Phase 5 — US-5 (P2) — dry-run reports skipped skills

- T026 — [P] [US-5] `tests/update-presets.bats`: `update --preset nextjs --skills --dry-run`, output contains a list of skills skipped (each name from `nextjs.json::foundation.skills.drop`).
- T027 — [US-5] In `update_directory()` skill loop, when `is_skill_dropped` matches AND `DRY_RUN=true`, print `[DRY-RUN] Skip (preset filter): <skill-name>`. Print only once per skill (not per file under it).

**Checkpoint**: dry-run output explicitly shows the filter's effect.

### Phase 6 — US-6 (P2) — orphan detection respects the active preset

- T028 — [P] [US-6] `tests/update-presets.bats`: bootstrap with `--preset nextjs`, run `update --detect-orphans`. Assert dropped skills (e.g. `dev-flutter`) do NOT appear in the orphan list.
- T029 — [P] [US-6] `tests/update-presets.bats`: same scenario with `--no-preset`. Assert dropped skills DO appear (no filter, today's behavior).
- T030 — [US-6] In `detect_orphan_files()` (or wherever orphan detection lives, lines 1032+ / 1105+): when comparing the foundation skills directory to the project, exclude entries in `ACTIVE_PRESET_DROP_LIST`.

**Checkpoint**: orphan detection no longer false-positives on intentionally-dropped skills.

### Phase 7 — US-7 (P3) — multi-match disambiguation behavior

Already covered by EF-004 + T005 in Phase 2. No additional implementation here.

### Phase 8 — Polish & validation

- T031 — Run `bash scripts/test.sh` parallel; record runtime delta vs baseline (must stay < 30s overhead — CS-006 budget).
- T032 — Run `bash scripts/validate-presets.sh` — no preset manifest changed, must still pass.
- T033 — Run `bash scripts/validate-counts.sh` — bump README test counter as needed.
- T034 — [P] Update `CHANGELOG.md` `[Unreleased]` Added/Changed.
- T035 — [P] Mark `specs/presets-update-aware/spec.md` status: Draft → Validated.
- T036 — Run `npm --prefix website run generate` if Counts gate breaks (memory `feedback_website_docs_regen.md`).
- T037 — `/qa:qa-loop "score 90"`.
- T038 — Open PR; surveill CI (expect ShellCheck and macOS-specific issues, per recent PRs).

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Existing `tests/update.bats` asserts byte-identical output that the new "Active preset" line breaks for preset projects | Medium | Medium | Phase 4 tests verify the line appears only when active. Audit `update.bats` early; widen any byte-equality assertion to "contains expected substrings". |
| `is_skill_dropped` mishandles nested skill paths (e.g. `dev-flutter/examples/foo.py`) | Medium | Low | Test coverage in Phase 3 includes a non-md skill file, asserting it's skipped along with the SKILL.md. |
| `resolve_active_preset` runs `scan_presets` for every update call → noticeable runtime cost | Low | Low | scan_presets is fast (~50–200ms for 5 presets per the lib's tests); overall update budget unaffected. |
| Multi-match disambiguation message confuses users (which preset is "right" for me?) | Low | Medium | EF-004 message lists every match; docs in CHANGELOG explain the disambiguation flow. Rare situation in practice. |
| The existing `apply_preset_filter()` in new-project.sh is now subtly out of step with the new is_skill_dropped logic | Low | Low | They serve different purposes (init = post-copy delete, update = skip-during-copy). Document the divergence in plan notes; revisit if inconsistency surfaces. |
| BSD/macOS portability of `find`-based skill enumeration | Low | Medium | update.sh already runs on both today (ubuntu + macOS CI matrix); the additions reuse the same idioms. |
| Counts gate breaks because of new tests file (`tests/update-presets.bats`) | Low | High | T033 + T036 apply the same fix used in PR #160 / #161. Routine. |

---

## Dependencies and Execution Order

```
Phase 1 (Setup)
   │
   ▼
Phase 2 (Foundation: parse + resolve)  ◄──── BLOCKS US-1 onwards
   │
   ├──▶ Phase 3 (US-1+US-2+US-3 — filter applied)
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

### MVP cut

If scope tightens: Phases 1+2+3 only (US-1+US-2+US-3 = the entire P1 set). That's the bare-minimum behavior — the filter actually works. P2 stories (visibility, dry-run, orphan-aware) ship in a follow-up PR if needed. In practice the cost of US-4/5/6 is small; one PR covering everything is realistic.

---

## Validation Criteria

### Gate 1 — Before starting
- [x] Spec validated (clarifications resolved)
- [x] Plan reviewed
- [x] Working tree clean

### Gate 2 — Before each merge
- [ ] Tests pass (`bash scripts/test.sh`)
- [ ] No regression on `tests/update.bats`, `tests/presets.bats`, `tests/preset-detect.bats`, `tests/preset-e2e.bats`
- [ ] `validate-presets.sh` exits 0
- [ ] `validate-counts.sh` exits 0
- [ ] ShellCheck `-S warning` clean

### Gate 3 — Before release
- [ ] All P1 success criteria from spec verified (CS-001 through CS-007)
- [ ] CHANGELOG updated
- [ ] Spec status flipped to "Validated"

---

## Notes

- This work continues the preset story from PR #160 + #161. After merge, the spec `specs/presets-update-aware/` joins the family with `specs/presets/` and `specs/presets-detection-and-e2e/`.
- Memory write deferred until merged.
- Run tests via `bash scripts/test.sh` (parallel ~1m), not `bats tests/*.bats` directly (memory `feedback_release_flow_test_sh.md`).
- BSD `wc -l` whitespace gotcha: not used here directly, but if any new comparison hits it, strip with `tr -d '[:space:]'` (memory `feedback_bsd_wc_whitespace.md`).
- Avoid `local fi` (ShellCheck SC1010 — bit us in PR #160).
- For cross-file globals set by lib and read by caller, use inline `# shellcheck disable=SC2034` (bit us in PR #161).

---

**Version**: 1.0 | **Created**: 2026-05-09
