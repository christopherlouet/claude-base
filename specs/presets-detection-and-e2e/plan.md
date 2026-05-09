# Implementation Plan: preset detection (data-driven) + per-preset end-to-end

**Branch**: `feature/presets-detection-and-e2e` (rename current `feature/auto-20260508-101622`)
**Date**: 2026-05-09
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Add a `detect` block to the preset manifest schema so each preset self-describes how to recognize its target stack, and let `new-project.sh` surface the matching preset(s) when run on an existing project — as additional menu entries in interactive mode (US-4 resolved 2026-05-09), as an info line in non-interactive mode. In parallel, add a generic per-preset end-to-end test that bootstraps a target, runs `validate.sh` + `doctor.sh`, and asserts every hook referenced by the bootstrapped `settings.json` exists on disk (drift-guard against the v1.36.1 regression class). Adding a new preset (e.g. `django.json`) only requires the manifest, a fixture, and a one-line registration — no edits to detection scripts or to the E2E orchestration.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language** | Bash 4+ (with BSD/GNU portability) | Existing scripts target the same baseline |
| **JSON parsing** | `jq` (already required by foundation) | No new dependency |
| **Tests** | `bats` (existing suite, parallelized via `scripts/test.sh`) | Add 2 new bats files + fixture dirs |
| **Validation** | `scripts/validate-presets.sh` (extend) | jq schema check |
| **Target platform** | Linux + macOS | BSD `wc`/`grep`/`find` differences known |

### Constraints

- Must work on macOS (BSD core utilities) and Linux (GNU). Known gotchas: `wc -l` whitespace padding (memory `feedback_bsd_wc_whitespace.md`), `seq 0 -1` differences, `find -path` portability.
- Must not break the existing 30+ tests in `tests/presets.bats`.
- Total parallel test runtime increase < 30s (CS-006).
- No new external dependency. `jq` is already a hard requirement.
- All written content in English (memory `feedback_repo_language_english_only.md`).
- `--preset` explicit short-circuits detection entirely (EF-016 from clarification).

### Expected behavior

| Trigger | Expected output |
|---|---|
| `new-project.sh ./existing-nextjs-app` | Info line "Detected Next.js — preset `nextjs` matches" before the type prompt |
| `new-project.sh` (interactive, in a Next.js dir) | Menu shows "Use preset: nextjs (detected)" as the first option, above the standard 11 types |
| `new-project.sh --preset nextjs ./any-dir` | Detection skipped, no message about other matches |
| `bash scripts/test.sh` | Adds <30s vs current; 5 preset E2E pass |

---

## Constitution / Conventions Check

- [x] Follows project conventions (CLAUDE.md): Explore → Specify → Clarify → Plan → TDD → Audit → Commit
- [x] Consistent with existing architecture: extends `.claude/presets/` schema and `scripts/lib/` library pattern
- [x] No over-engineering: data-driven from day 1, no negative-signal logic, no telemetry
- [x] Tests planned: bats unit (rule matching) + bats E2E (per preset) + drift-guards (rule↔fixture, hooks)

---

## Project Structure

### Documentation (this feature)

```
specs/presets-detection-and-e2e/
├── spec.md           # Functional specification (resolved)
├── plan.md           # This file
├── tasks.md          # Task breakdown
└── notes.md          # (optional, created if research notes accumulate)
```

### Source layout (target areas)

```
.claude/presets/
├── astro.json              # add detect block
├── cli-tools.json          # add detect block (or leave none — see EF-009)
├── fastapi.json            # add detect block
├── homelab-proxmox.json    # add detect block
├── nextjs.json             # add detect block
└── README.md               # add format reference for detect block

scripts/
├── lib/
│   └── preset-detect.sh    # NEW — pure library: scan dir → matching preset names
├── new-project.sh          # MODIFY — call detection, render suggestion
└── validate-presets.sh     # MODIFY — validate detect block schema

tests/
├── preset-detect.bats      # NEW — unit tests for preset-detect.sh
├── preset-e2e.bats         # NEW — generic per-preset bootstrap + validate + doctor + hooks
├── presets.bats            # MODIFY — add tests for detect blocks on existing presets
└── presets-fixtures/       # NEW — one subdir per preset with detection-triggering files
    ├── astro/
    ├── fastapi/
    ├── homelab-proxmox/
    └── nextjs/
```

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `scripts/lib/preset-detect.sh` | Pure library. Function `scan_presets(target_dir)` — iterates `.claude/presets/*.json` recursively, evaluates each `detect` block, prints matching preset names (one per line) on stdout. No side effects. |
| `tests/preset-detect.bats` | Unit tests: rule schema parsing, file-presence match, dep-file content match, allOf/anyOf combinator, missing-jq fallback, malformed rule rejection. |
| `tests/preset-e2e.bats` | Generic loop: for each preset under `.claude/presets/*.json`, bootstrap into `TEST_DIR`, run validate.sh + doctor.sh, assert every `scripts/hooks/*.sh` referenced by bootstrapped `settings.json` exists on disk. |
| `tests/presets-fixtures/<preset>/` | Minimal directory per preset (marker files only) that triggers its detection rule. Used by US-5 drift-guard tests. |
| `specs/presets-detection-and-e2e/tasks.md` | Task breakdown for this work |

### To modify

| File | Modification |
|------|--------------|
| `.claude/presets/{nextjs,fastapi,astro,homelab-proxmox}.json` | Add a `detect` block (cli-tools left without one — too generic to detect reliably; covered by EF-009). |
| `.claude/presets/README.md` | Document the `detect` block in the format quick reference, with two worked examples. |
| `scripts/new-project.sh` | Source `lib/preset-detect.sh`. Call detection in two places: (a) before the type prompt in interactive mode, prepend matching presets as additional menu options; (b) after `detect_stack` in non-interactive mode, print info line. Skip detection entirely when `--preset` was explicitly passed (EF-016). |
| `scripts/validate-presets.sh` | Add validation of the optional `detect` block: structure of `files`/`depFiles`, combinator enum, at least one of files/depFiles non-empty. |
| `tests/presets.bats` | Add per-preset assertions: detect block exists (where applicable), schema valid, matches the paired fixture. |
| `CHANGELOG.md` | Add unreleased entry under Added/Changed once the feature is ready. |
| `docs/reference/commands.md` (if `--detect-only` shipped) | Document the new flag (P3 only). |

### Tests to add

| File | Coverage |
|------|----------|
| `tests/preset-detect.bats` | scan_presets returns expected names on synthetic dirs; combinator semantics; absent-jq path; malformed rule fallthrough |
| `tests/preset-e2e.bats` | per-preset bootstrap + validate + doctor + hook-presence drift-guard |
| `tests/presets.bats` (additions) | each preset's detect block matches its paired fixture (US-5) |

---

## Chosen Approach

### Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  scripts/new-project.sh                                              │
│    │                                                                 │
│    │  --preset X explicit?  ──── yes ──▶ skip detection (EF-016)     │
│    │                                                                 │
│    │  no                                                             │
│    ▼                                                                 │
│  detect_stack (existing — sets DETECTED_TYPE)                        │
│    │                                                                 │
│    ▼                                                                 │
│  scripts/lib/preset-detect.sh :: scan_presets(target_dir)            │
│    │                                                                 │
│    │  for each .claude/presets/*.json (incl. community/):            │
│    │    read .detect block via jq                                    │
│    │    evaluate files[] (existence + glob)                          │
│    │    evaluate depFiles[] (file exists + grep -qi contains)        │
│    │    apply combinator (allOf | anyOf, default anyOf)              │
│    │    matched? → emit preset name to stdout                        │
│    ▼                                                                 │
│  matching presets array                                              │
│    │                                                                 │
│    ├── interactive: prepend as menu options (US-4)                   │
│    └── non-interactive: info line "Detected X — preset Y matches"    │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│  tests/preset-e2e.bats                                               │
│    │                                                                 │
│    │  for each preset .json:                                         │
│    │    bootstrap into $TEST_DIR via new-project.sh --preset X       │
│    │    run validate.sh + doctor.sh                                  │
│    │    parse bootstrapped .claude/settings.json hooks               │
│    │    assert each referenced scripts/hooks/*.sh exists             │
│    ▼                                                                 │
│  pass / fail with precise message                                    │
└──────────────────────────────────────────────────────────────────────┘
```

### Detection rule schema

```jsonc
"detect": {
  "combinator": "anyOf",          // optional, enum: "allOf" | "anyOf", default "anyOf"
  "files": [                      // optional, list of names or globs
    "next.config.js",
    "next.config.mjs",
    "next.config.ts"
  ],
  "depFiles": [                   // optional, list of {path, contains}
    {"path": "package.json", "contains": "\"next\""}
  ]
}
```

Rules:
- At least one of `files` or `depFiles` MUST be non-empty (validator rejects empty rules).
- A signal "matches" when:
  - `files`: at least one of the listed names/globs resolves to an existing file in the target dir (glob via `find -name`, max-depth 2 for portability).
  - `depFiles`: the named file exists AND `grep -qi -- "<contains>"` succeeds.
- The combinator is applied to the **union** of all signals (each item in `files` is one signal; each item in `depFiles` is one signal). `anyOf` = at least one matches; `allOf` = all match.
- A preset without a `detect` block is silent (never auto-suggested) — EF-009.

### Rationale

- **Data-driven from day 1**: avoids the inevitable rewrite when adding the 6th, 7th, 8th preset (each new framework would otherwise mean a new code edit in `detection.sh`).
- **Pure library `preset-detect.sh`**: testable in isolation, no shared state with `new-project.sh`, can be reused by future tools (e.g. the `claude-base detect` standalone command if ever shipped).
- **Generic E2E loop**: one bats file, iterates over presets, no per-preset duplication. Adding `django.json` automatically gets a passing E2E once the fixture exists.
- **Hook drift-guard at bootstrap level**: the existing `tests/manifest-hooks-coverage.bats` checks the source `settings.json`; this new test checks the **bootstrapped** copy, which is what users actually run. Catches future divergence between source and per-preset settings overrides.

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Hardcode mapping `framework → preset` in `detection.sh` | Ships fast for 5 presets, accumulates dead code at 10+. Conflicts with the user's stated "we'll add more frameworks". |
| Auto-apply detected preset (no opt-in) | Surprising, irreversible side effect when running on someone else's project. Rejected explicitly in spec out-of-scope. |
| YAML for the detect block | Adds a YAML parser dep (`yq`) just for this one thing; JSON+jq is the existing convention. |
| Run E2E only on release branches | Catches regressions too late. The v1.36.1 regression was caught by a user, not by CI — exactly the failure mode we want to fix. |
| Negative signals (`notContains`, `notExists`) at MVP | YAGNI per clarification 2. Defer to v2 if a real conflict emerges. |

---

## Implementation Phases

### Phase 1 — Setup (lightweight)

**Objective**: Skeletons in place, no logic yet.

- T001 — Rename branch to `feature/presets-detection-and-e2e` (`/git-rename`).
- T002 — [P] Create `scripts/lib/preset-detect.sh` skeleton with public function `scan_presets()`, header doc, set -u guard.
- T003 — [P] Create empty fixture dirs `tests/presets-fixtures/{nextjs,fastapi,astro,homelab-proxmox}/`.
- T004 — Create `tests/preset-detect.bats` and `tests/preset-e2e.bats` with bats boilerplate (load test_helper, setup/teardown).

**Checkpoint**: skeletons present, suite still green.

### Phase 2 — Foundation (blocking)

**Objective**: schema + validator extension. Required before any US can ship.

- T005 — [P] Extend `scripts/validate-presets.sh` with `detect` block validation (jq queries, combinator enum, non-empty union).
- T006 — [P] Add tests in `tests/presets.bats` for validator's new behavior (accepts valid detect block, rejects empty/malformed).

**Checkpoint**: validator enforces the schema; existing presets still pass (no `detect` block yet = ignored).

### Phase 3 — US-1 + US-2 (P1 — data-driven detection MVP)

**Objective**: scan presets, return matches, render suggestion in non-interactive mode. The "zero-code-for-new-preset" property of US-2 is verified by adding a synthetic preset and asserting it's auto-discovered without any other change.

#### Tests (TDD, write first)

- T007 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `next.config.js` + `package.json` containing `"next"` ⇒ scan returns `nextjs`.
- T008 — [P] [US1] `tests/preset-detect.bats`: synthetic dir with `manage.py` + `requirements.txt` containing `django` ⇒ scan returns nothing today (no django preset), but combinator + files signal return as expected.
- T009 — [P] [US1] `tests/preset-detect.bats`: combinator `allOf` and `anyOf` semantics on a synthetic preset.
- T010 — [P] [US1] `tests/preset-detect.bats`: jq missing on PATH ⇒ graceful empty output, exit 0.
- T011 — [P] [US1] `tests/preset-detect.bats`: malformed detect block ⇒ skipped (warning), other presets still scanned.
- T012 — [P] [US2] `tests/preset-detect.bats`: drop a synthetic `tests/presets-fixtures/test-preset/.claude/presets/synthetic-preset.json` (or use an env override to point at a temp presets dir); verify it shows up without modifying any other code.

#### Implementation

- T013 — [US1] Implement `scan_presets()` in `scripts/lib/preset-detect.sh` (jq-driven, files+depFiles+combinator).
- T014 — [P] [US1] Add `detect` block to `nextjs.json`, `fastapi.json`, `astro.json`, `homelab-proxmox.json`. (cli-tools left without — too generic.)
- T015 — [US1] Source `lib/preset-detect.sh` from `new-project.sh`; call `scan_presets` after `detect_stack` in non-interactive flow; print info line.
- T016 — [US1] Skip detection entirely when `--preset` was explicitly passed (EF-016 — gate at the call site).
- T017 — [US1] Tests for the non-interactive info line in `tests/presets.bats`.

**Checkpoint**: running `new-project.sh -y existing-nextjs-app/` prints the suggestion. No regression on existing tests.

### Phase 4 — US-3 (P1 — per-preset E2E + hook drift-guard)

**Objective**: every preset has a passing E2E that bootstraps + validates + asserts hooks present.

#### Tests (these ARE the deliverable)

- T018 — [P] [US3] `tests/preset-e2e.bats`: generic loop over `.claude/presets/*.json`. For each, bootstrap into `TEST_DIR`, assert exit 0.
- T019 — [P] [US3] `tests/preset-e2e.bats`: post-bootstrap, run `validate.sh -q` and `doctor.sh` against the target.
- T020 — [P] [US3] `tests/preset-e2e.bats`: parse bootstrapped `.claude/settings.json` for hook script paths; assert each `scripts/hooks/*.sh` exists in the target.
- T021 — [P] [US3] `tests/preset-e2e.bats`: regression-mode assertion — given a deliberately deleted hook, the test fails with a precise message naming the missing file (sanity check that the assertion actually fires).

**Checkpoint**: test runtime measurement vs CS-006 budget. If breached, split into a parallel CI job per clarification 3 fallback.

### Phase 5 — US-4 (P2 — in-menu suggestion in interactive flow)

**Objective**: interactive `new-project.sh` prepends matching presets as additional menu options.

- T022 — [US4] Modify `get_project_type()` to read `MATCHED_PRESETS` (populated by Phase 3), prepend each as a numbered option above the standard 11 types.
- T023 — [US4] When user picks a preset entry: set `PRESET_NAME` and re-route through `load_preset()` path (do not show the standard type menu).
- T024 — [US4] When user picks a standard type: ignore matched presets, behave as today.
- T025 — [P] [US4] Update `tests/new-project.bats` if it asserted "Choice [1-11]" hardcoded — make it tolerant of the dynamic count.
- T026 — [P] [US4] New tests: simulated interactive run with a Next.js fixture in $TEST_DIR ⇒ menu output contains "Use preset: nextjs (detected)".

**Checkpoint**: interactive flow validated by test; no regression on existing menu tests.

### Phase 6 — US-5 (P2 — fixture drift-guard)

**Objective**: each preset's detect rule is asserted to match its paired fixture.

- T027 — [P] [US5] Populate `tests/presets-fixtures/nextjs/` with `next.config.js` + minimal `package.json` containing `"next"`.
- T028 — [P] [US5] Populate `tests/presets-fixtures/fastapi/` with `pyproject.toml` containing `fastapi`.
- T029 — [P] [US5] Populate `tests/presets-fixtures/astro/` with `astro.config.mjs`.
- T030 — [P] [US5] Populate `tests/presets-fixtures/homelab-proxmox/` with `*.tf` containing a Proxmox provider declaration.
- T031 — [US5] Add to `tests/presets.bats`: for each preset with a `detect` block, assert `scan_presets("tests/presets-fixtures/<preset>/")` returns the preset's own name.

**Checkpoint**: rule↔fixture pairing verified for all detect-bearing presets.

### Phase 7 — US-6 (P3 — `--detect-only` flag) [optional]

**Objective**: standalone audit mode.

- T032 — [US6] Add `--detect-only PATH` arg parsing in `new-project.sh`. Calls `scan_presets`, prints names + signal sources, exits 0.
- T033 — [P] [US6] Test: `--detect-only` prints expected output, writes nothing.
- T034 — [P] [US6] Document in `--help` output.

**Decision gate**: ship only if Phases 1–6 stayed in budget; skip otherwise.

### Phase 8 — US-7 (P3 — doc update)

- T035 — [P] [US7] Update `.claude/presets/README.md` with `detect` block format reference + two worked examples (file-presence + dep-file).
- T036 — [P] [US7] Cross-link from `specs/presets/spec.md` ("see specs/presets-detection-and-e2e/spec.md for detection extension").

### Phase 9 — Polish

- T037 — [P] Run `bash scripts/test.sh` in parallel mode, measure delta vs baseline; update CS-006 if needed.
- T038 — [P] Update `CHANGELOG.md` `[Unreleased]` section.
- T039 — Run `npm --prefix website run generate` if any of `docs/reference/`, `docs/guides/`, `docs/concepts/` were touched (memory `feedback_website_docs_regen.md`).
- T040 — Run `validate-counts.sh` to check no drift introduced.
- T041 — `/qa:qa-loop "score 90"`.
- T042 — Mark spec.md status from "Draft" to "Validated".

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| `find -name` glob differences BSD vs GNU | Medium | Medium | Use the most portable subset (single `*` glob, no `**`); test on macOS via CI matrix (already present per memory `project_socle_path_to_9.md` — multi-OS CI is live since v1.32.0). |
| Existing `tests/new-project.bats` hardcodes "Choice [1-11]" | Low | High | T025 widens the assertion or counts dynamic options. Sanity-check before T022. |
| Test runtime budget breach (CS-006) | Medium | Low | Phase 9 measures; fallback per clarification 3 is a parallel CI job (no blocking work needed at Phase 3 time). |
| `claude plugin install` skip leaves install incomplete in E2E | Low | High | Already handled by existing graceful skip in `install_marketplace_plugins`; E2E asserts only what's deterministic (foundation files + hooks). |
| Detection of `homelab-proxmox` produces false positives on any `*.tf` repo | Low | Medium | Detect rule scopes to "tf file containing telmate/proxmox or bpg/proxmox provider" via depFiles, not bare presence of *.tf. |
| Drift between bootstrapped `settings.json` and source if a preset ever overrides hooks | Low | Low | EF-013 explicitly checks the bootstrapped copy, not the source — discovers divergence by design. |
| jq missing on the user's host | Low | Low | EF-014 + already handled in similar code paths; degrades to "no suggestion" gracefully. |
| Branch rename mid-flight (T001) breaks open in-flight work | Very Low | Very Low | Working tree clean per repo context; no commits on this branch yet. Safe. |

---

## Dependencies and Execution Order

```
Phase 1 Setup
   │
   ▼
Phase 2 Foundation (validator extension)
   │
   ├─▶ Phase 3 (US1+US2)  ─────┐
   │                            ▼
   │                       Phase 5 (US4 — interactive)
   │                            │
   │                            ▼
   │                       Phase 6 (US5 — fixtures)
   │
   └─▶ Phase 4 (US3 — E2E)  [independent of Phase 3]

Phase 7 (US6) [optional]
Phase 8 (US7) [doc, anytime after Phase 3]
Phase 9 Polish [last]
```

### MVP cut

If time/scope tightens, MVP = Phases 1+2+3+4 (US1+US2+US3). That delivers:
- detection runs on existing projects, prints suggestion (US1)
- new presets need zero code (US2)
- E2E catches v1.36.1-style regressions (US3)

Phases 5–8 are P2/P3 polish, deferrable to a follow-up PR.

---

## Validation Criteria

### Gate 1 — Before starting
- [x] Spec approved (clarifications 1–3 resolved)
- [x] Plan reviewed
- [x] Working tree clean

### Gate 2 — Before each merge
- [ ] Tests pass (`bash scripts/test.sh`)
- [ ] No regression on `tests/presets.bats`, `tests/new-project.bats`, `tests/manifest-hooks-coverage.bats`
- [ ] `validate-presets.sh` exits 0 on all 5 presets
- [ ] `validate-counts.sh` exits 0
- [ ] `audit-base.sh` (if it runs in CI) exits 0

### Gate 3 — Before release
- [ ] All P1 success criteria from spec verified (CS-001 through CS-006)
- [ ] Changelog updated
- [ ] Spec status flipped to "Validated"

---

## Notes

- This work extends `specs/presets/spec.md` (the original preset system spec). That spec stays as historical record of v1 (introduction of presets); this new spec is v2 (data-driven + e2e).
- No memory write needed for now — too early in the work. A memory entry will be created at PR/release time summarising what shipped.
- The `cli-tools` preset is intentionally left without a `detect` block: its target (Python or Shell automation, GitHub helpers, headless scripts) is too generic to detect reliably without false positives. EF-009 covers this case.

---

**Version**: 1.0 | **Created**: 2026-05-09
