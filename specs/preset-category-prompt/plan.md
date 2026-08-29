# Implementation Plan: pre-detection category prompt (Option C1)

**Branch**: `feature/auto-20260519-095318` (rename to `feat/preset-category-prompt` via `/git-rename`)
**Date**: 2026-05-19
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Add an interactive "What are you building?" prompt to `scripts/new-project.sh` that fires only on empty-target / no-flag / no-detect scenarios. Introduce a strict 8-entry category taxonomy locked to the roadmap. Add an optional `categories[]` field to the preset manifest schema (validated as a strict enum). Retrofit all 11 currently-shipped presets with their category declaration. TDD-driven: write failing bats tests first, then build the validator extension, the prompt library, and the integration into `new-project.sh`.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Primary edits** | Bash (`menu.sh`, `validate-presets.sh`, `new-project.sh`), JSON (11 preset manifests), Markdown (spec, roadmap, README, CHANGELOG), Bats (new tests) | No new tooling |
| **Bash compatibility** | Bash 4+ required (already enforced by `common.sh:177`) | `declare -A` for the category-to-types map is safe |
| **Auto-regenerated** | `counts.json#tests`, `README.md` tests badge | Via `npm --prefix website run generate` |
| **Test framework** | Bats (existing `tests/presets.bats`) | Interactive prompts simulated via piped stdin, following the pattern at `presets.bats:301` |
| **Schema source-of-truth** | `specs/presets/spec.md` (extended) | The new `categories[]` field documented there |
| **Taxonomy source-of-truth** | `specs/presets/roadmap.md` | Drift-guard via dedicated bats test (CS-013) |
| **LOC estimate** | ~400 LOC across 18 hand-edited files (3 scripts + 11 manifests + 4 docs) | Bigger than vendor-pointer PRs ; real foundation feature |

### Constraint: `counts.json#presets` unchanged

The 11 presets stay 11. Only their content (added `categories[]` field) changes. Tests count grows by ≥6.

### Constraint: 4 simultaneous guards on the new prompt

EF-001 + EF-009 + EF-010 combine: the prompt fires ONLY when **all** of these hold simultaneously:
1. Interactive mode is active (existing `$INTERACTIVE` variable in `new-project.sh`)
2. `[ -t 0 ]` (stdin is a TTY)
3. `--preset` flag was NOT passed (no `$PRESET_NAME` set)
4. `--type` flag was NOT passed (no `$FORCE_TYPE` set)
5. `MATCHED_PRESETS[]` is empty (no auto-detect hit)

Implementation must short-circuit cleanly on the first false condition — no side effects, no output.

### Constraint: backward compatibility of the existing flow

Every non-interactive code path (`SKIP_PROMPTS`, `--yes`, `--preset`, `--type`) MUST behave EXACTLY as it does today. Regression check : the 72 baseline bats tests (now 87 after vendor-pointer batch) must all still pass.

### Playwright placement (plan-level decision)

The spec's EF-008 mandates retrofitting all 11 presets with `categories[]`, but the spec body also mentions `["any"]` opt-out for cross-cutting tools. Since Q3 (clarify) locked a strict enum on the 8 taxonomy slugs, "any" is not available. Plan resolution: **declare `playwright` as `["web-frontend", "api-backend"]`** — both contexts where Playwright tests run in practice. Documented as a known tradeoff: a future PR could add a 9th "tooling" category (taxonomy expansion = spec amendment) if cross-cutting tools accumulate. Phaser and Pulumi are NOT cross-cutting — they have single primary categories.

### Memory anchors

- `feedback_verify_code_claims` — bash 4+ confirmed (`common.sh:177`), bats interactive pattern verified (`presets.bats:301`), `_MENU_STD_TYPES` slugs verified
- `feedback_no_project_names` — EF-016, enforced in pre-commit grep guard
- `feedback_counts_ci_gate` — auto-regen via `npm --prefix website run generate`
- `feedback_anti_drift_badge` — README badges auto-bumped by the same generator

---

## Constitution / Conventions Check

GATE — validate before starting:

- [ ] All 4 clarifications resolved (default, mapping placement, enum strictness, apollo placement) — see `spec.md` §"Locked decisions".
- [ ] CI baseline captured: current `validate-presets.sh`, `bats tests/presets.bats`, `validate-counts.sh` exit codes recorded.
- [ ] No memory-flagged anti-pattern violated.
- [ ] TDD cycle respected: failing tests committed BEFORE passing implementation.
- [ ] Playwright placement decision noted (`["web-frontend", "api-backend"]`).

---

## Project Structure (this feature)

```
specs/preset-category-prompt/
├── spec.md     # Functional spec (8 US, 16 EF, 14 CS, 4 CP all resolved)
├── plan.md     # This file
└── tasks.md    # Task breakdown (generated alongside this plan)
```

---

## Impacted Files

### To create

| File | Responsibility | Approx LOC |
|------|----------------|-----------|
| `scripts/lib/category-map.sh` | New bash library with `_CATEGORY_SLUGS`, `_CATEGORY_LABELS`, `_CATEGORY_TYPES_MAP` (associative array), plus `print_category_menu()`, `apply_category_choice()`, `ask_category()` composite | ~120 |

### To modify

| File | Modification | Approx LOC delta |
|------|--------------|-----------|
| `scripts/lib/menu.sh` | Sources `category-map.sh`; gain `print_filtered_type_menu(category)` + `apply_filtered_type_choice()` (filtered variants of existing functions); add `_TYPE_TO_PRESETS_MAP` computed lazily | +60 |
| `scripts/new-project.sh` | Modify `get_project_type()`: when all 5 guards hold (interactive + TTY + no `--preset` + no `--type` + empty `MATCHED_PRESETS`), call `ask_category` first, then route to filtered menu OR fallback to full menu based on category result | +30 |
| `scripts/validate-presets.sh` | Add `categories[]` enum validation: if field present, each entry MUST be in the 8-slug enum; entries MUST be strings; empty array allowed (treated as field absent) | +25 |
| `specs/presets/spec.md` | Schema amendment: add `categories[]` field to the JSON schema section; reference `specs/preset-category-prompt/spec.md` for the taxonomy | +20 |
| `specs/presets/roadmap.md` | Add a "Category taxonomy alignment" section noting the 8 categories that mirror the menu prompt; act as drift anchor for CS-013 | +15 |
| `.claude/presets/README.md` | Mention the category-based pre-prompt and how presets opt-in via `categories[]` | +8 |
| `.claude/presets/nextjs.json` | Add `"categories": ["web-frontend", "api-backend"]` | +1 |
| `.claude/presets/astro.json` | Add `"categories": ["web-frontend"]` | +1 |
| `.claude/presets/react-vite-spa.json` | Add `"categories": ["web-frontend"]` | +1 |
| `.claude/presets/fastapi.json` | Add `"categories": ["api-backend"]` | +1 |
| `.claude/presets/cli-tools.json` | Add `"categories": ["cli-automation"]` | +1 |
| `.claude/presets/homelab-proxmox.json` | Add `"categories": ["infra-devops"]` | +1 |
| `.claude/presets/phaser.json` | Add `"categories": ["game-interactive-media"]` | +1 |
| `.claude/presets/playwright.json` | Add `"categories": ["web-frontend", "api-backend"]` (cross-cutting tool, declared in both contexts) | +1 |
| `.claude/presets/pulumi.json` | Add `"categories": ["infra-devops"]` | +1 |
| `.claude/presets/apollo.json` | Add `"categories": ["api-backend"]` (per CP4 lock) | +1 |
| `.claude/presets/mongodb.json` | Add `"categories": ["data-database"]` | +1 |
| `tests/presets.bats` | Add ≥6 new bats tests covering EF-001/005/006/007/009/010 + drift-guard for taxonomy/roadmap alignment | +180 |
| `CHANGELOG.md` | One bullet under `[Unreleased] / ### Added` | +10 |

### Auto-regenerated (DO NOT hand-edit)

| File | Trigger | Mechanism |
|------|---------|-----------|
| `counts.json#tests` | New bats tests added | `npm --prefix website run generate` re-counts |
| `README.md` `<!-- count:tests -->` badge | Same trigger | Same generator updates the marker |

### Files NOT touched (explicit non-modifications)

- `.claude/skills/*`, `.claude/agents/*`, `.claude/settings.json` (no new bundled artifact)
- `tests/presets-fixtures/*` (no new fixture — new tests use heredocs)
- `counts.json#presets` (unchanged at 11)

---

## Chosen Approach

### Sequencing (TDD-driven)

```
Phase 1: Pre-verification + branch rename
         │
         ▼
Phase 2: TDD RED — 8+ failing bats tests for EF-001/005/006/007/009/010 + drift-guard
         │
         ▼
Phase 3: TDD GREEN — implementation in 3 sub-phases
         3a) validator enum (validate-presets.sh)
         3b) prompt library (lib/category-map.sh)
         3c) integration (new-project.sh::get_project_type)
         │
         ▼
Phase 4: Retrofit 11 presets with categories[]
         │
         ▼
Phase 5: Spec + roadmap + presets README amendments (parallel)
         │
         ▼
Phase 6: Regen + audit gauntlet (validate-counts, validate-presets, audit-base, bats, npm test:scripts)
         │
         ▼
Phase 7: CHANGELOG + pre-commit guards (grep protected names, diff review)
         │
         ▼
Phase 8: Commits + push + PR + watch CI + merge
```

### Rationale

- **TDD mandatory** per `.claude/rules/workflow.md`. Validator logic is pure jq-driven; bats tests can drive every branch.
- **Library separation** (`lib/category-map.sh`) instead of stuffing menu.sh — keeps the new code reviewable in isolation, makes the bats test pattern (source lib + call function) cleaner.
- **Retrofit AFTER GREEN**: the validator must enforce the enum BEFORE we retrofit, otherwise we could ship invalid categories without catching them.
- **Static category-to-types map** in bash associative array (bash 4+ available per `common.sh:177`). Plain readable for review, modifiable in one PR if the taxonomy evolves.

### Alternatives considered

| Alternative | Why rejected |
|---|---|
| Stuff everything into `lib/menu.sh` | File would exceed 200 LOC, mixing pre-prompt logic with current menu. Split is cleaner. |
| Use case statement instead of bash associative array | Bash 4+ is already required ; associative array reads cleaner for the 8-entry map. |
| Make `categories[]` mandatory (hard migration) | Breaks any community-curated preset that hasn't migrated. Soft migration per spec EF-007. |
| Run end-to-end `new-project.sh` in bats tests | Heavy + flaky (multiple prompts to feed). Cleaner: source `lib/category-map.sh` + call functions in isolation, mirroring the existing `scan_presets` test pattern. |
| Add `"any"` to the enum for cross-cutting tools (Playwright) | Spec Q3 locked strict 8-entry enum. Plan resolution for Playwright: declare in both `["web-frontend", "api-backend"]` (where it's actually used). |
| Defer retrofit of the 11 presets to follow-up PRs | EF-008 mandates same-delivery retrofit ; deferring would ship a feature that doesn't yet work for the live preset catalog. |

---

## Implementation Phases

### Phase 1 — Pre-verification + branch rename (BLOCKING)

- T001 — Capture CI baseline (`validate-presets.sh`, `validate-counts.sh`, `audit-base.sh`, `bats tests/presets.bats`).
- T002 — Sanity-check bash version locally (`bash --version` ≥ 4) and verify `declare -A` works.
- T003 — Rename branch: instruct user to run `/git-rename feat/preset-category-prompt` (slash command is user-invoked).

**Checkpoint**: Baseline known. Branch named.

### Phase 2 — TDD RED (US-1, US-2, US-3, US-4, US-5, US-6)

**Objective**: Write tests that MUST fail because the feature doesn't exist yet.

⚠️ DO NOT touch `validate-presets.sh` or create `lib/category-map.sh` yet. Only edit `tests/presets.bats`.

- T004 — [US4] Negative bats test: `validate-presets.sh rejects a preset with categories[] containing an out-of-enum value (EF-006)`.
- T005 — [US4] Positive bats test: `validate-presets.sh accepts a preset with categories[] empty` (EF-006, "empty array allowed").
- T006 — [US4] Positive bats test: `validate-presets.sh accepts a preset with categories[] containing 2 valid slugs (multi-category, EF-014)`.
- T007 — [US1] Bats test: `ask_category prompts and returns the chosen category slug on TTY`. Uses sourcing pattern with piped stdin (`echo "4" | ask_category`).
- T008 — [US3] Bats test: `ask_category skips silently when stdin is not a TTY`. Uses `[ -t 0 ]` simulation via redirection.
- T009 — [US2] Bats test: `get_project_type bypasses category prompt when PRESET_NAME is set` (EF-010).
- T010 — [US2] Bats test: `get_project_type bypasses category prompt when FORCE_TYPE is set` (EF-010).
- T011 — [US4] Bats test: `print_filtered_type_menu(game-interactive-media) shows only phaser` (post-retrofit).
- T012 — [US7] Bats test: `apply_category_choice(other-generic) maps to the full unfiltered type menu` (EF-005).
- T013 — Drift-guard bats test: `taxonomy slugs in lib/category-map.sh match roadmap.md exactly` (CS-013).
- T014 — Run `bats tests/presets.bats` → expected: 10 new tests FAIL for the expected reasons. Confirm RED state.

**Checkpoint**: 10 new bats tests written, all failing. Baseline 87 tests still passing.

### Phase 3 — TDD GREEN: implementation (US-4, US-5, US-6, US-1)

#### Phase 3a — Validator enum (T013 → T015) (US-4)

- T015 — In `scripts/validate-presets.sh`, define a new constant `ALLOWED_CATEGORIES='["web-frontend","api-backend","mobile-desktop","game-interactive-media","data-database","infra-devops","cli-automation","other-generic"]'`.
- T016 — Add a validation block: if `categories` field present, MUST be an array, each entry MUST be a string in the enum. Empty array allowed (treated as absent). Multi-entry allowed.
- T017 — Run `bats tests/presets.bats` → expected: T004/T005/T006 PASS. Other tests still RED. No regression on existing 87.

#### Phase 3b — Prompt library (T018 → T024) (US-1, US-4, US-7)

- T018 — Create `scripts/lib/category-map.sh`. Header guard + sourced-from-common.sh check (pattern from `lib/menu.sh:11-15`).
- T019 — Declare 3 bash structures :
  - `_CATEGORY_SLUGS=(web-frontend api-backend mobile-desktop game-interactive-media data-database infra-devops cli-automation other-generic)` (indexed array, 8 entries)
  - `_CATEGORY_LABELS=("Web frontend" "API / Backend" "Mobile / Desktop" "Game / Interactive media" "Data / Database" "Infra / DevOps" "CLI / Automation" "Other / Generic")`
  - `declare -A _CATEGORY_TYPES_MAP=([web-frontend]="react vue fullstack generic" [api-backend]="node-api python go rust java generic" [mobile-desktop]="flutter generic" [game-interactive-media]="generic" [data-database]="python generic" [infra-devops]="generic" [cli-automation]="python go rust generic" [other-generic]="react vue node-api python go rust java fullstack flutter neovim generic")`
- T020 — Implement `print_category_menu()` mirroring `print_type_menu()` shape: render the 8 numbered entries with "← default" marker on entry 8 (Other / Generic per CP1 lock).
- T021 — Implement `apply_category_choice(choice)` — parse numeric input, set `SELECTED_CATEGORY_SLUG` from `_CATEGORY_SLUGS[N-1]`. Default to `other-generic` if input is empty or invalid.
- T022 — Implement `ask_category()` composite — guard `[ -t 0 ]` + return silently if stdin not TTY ; otherwise print prompt, read choice, apply, return slug on stdout.
- T023 — In `lib/menu.sh`, add `print_filtered_type_menu(category_slug)` — when slug is `other-generic`, behaves identically to existing `print_type_menu`; otherwise filters `_MENU_STD_LABELS` to only those whose slug appears in `_CATEGORY_TYPES_MAP[category_slug]`, and filters `MATCHED_PRESETS[]` (or a freshly-computed preset list with matching `categories[]`) similarly.
- T024 — Run `bats tests/presets.bats` → expected: T007, T008, T011, T012, T013 PASS. T009 and T010 still fail (no `new-project.sh` integration yet).

#### Phase 3c — `new-project.sh` integration (T025 → T027) (US-1, US-2)

- T025 — In `scripts/new-project.sh`, source `lib/category-map.sh` near the existing `source` block.
- T026 — Modify `get_project_type()` to call `ask_category` first when all 5 guards hold (interactive + TTY + no `--preset` + no `--type` + empty `MATCHED_PRESETS`). Route to `print_filtered_type_menu(SELECTED_CATEGORY_SLUG)` instead of `print_type_menu`. Wire `apply_filtered_type_choice` accordingly.
- T027 — Run `bats tests/presets.bats` → expected: ALL 10 new tests PASS + 87 baseline still passing.

**Checkpoint**: GREEN state. Tests count ≥ 97 passing.

### Phase 4 — Retrofit 11 presets with `categories[]` (US-5)

Each retrofit is a single `jq` insertion or manual edit (a single line per manifest).

- T028 — Add `"categories": ["web-frontend", "api-backend"]` to `.claude/presets/nextjs.json`.
- T029 — Add `"categories": ["web-frontend"]` to `.claude/presets/astro.json`.
- T030 — Add `"categories": ["web-frontend"]` to `.claude/presets/react-vite-spa.json`.
- T031 — Add `"categories": ["api-backend"]` to `.claude/presets/fastapi.json`.
- T032 — Add `"categories": ["cli-automation"]` to `.claude/presets/cli-tools.json`.
- T033 — Add `"categories": ["infra-devops"]` to `.claude/presets/homelab-proxmox.json`.
- T034 — Add `"categories": ["game-interactive-media"]` to `.claude/presets/phaser.json`.
- T035 — Add `"categories": ["web-frontend", "api-backend"]` to `.claude/presets/playwright.json` (cross-cutting tool, both contexts).
- T036 — Add `"categories": ["infra-devops"]` to `.claude/presets/pulumi.json`.
- T037 — Add `"categories": ["api-backend"]` to `.claude/presets/apollo.json` (per CP4 lock).
- T038 — Add `"categories": ["data-database"]` to `.claude/presets/mongodb.json`.
- T039 — Run `./scripts/validate-presets.sh` → expected: 11 valid, exit 0. The new validator block (Phase 3a) now exercises real data.

**Checkpoint**: 11 presets retrofitted, all valid.

### Phase 5 — Spec + roadmap + README amendments (US-3, anti-drift) [P]

These edit different files and can run in parallel.

- T040 — [P] In `specs/presets/spec.md`, extend the JSON schema section with the new `categories[]` field (optional, array of slugs, enum-validated). Cross-reference `specs/preset-category-prompt/spec.md`.
- T041 — [P] In `specs/presets/roadmap.md`, add a "Category taxonomy" section listing the 8 slugs and their roadmap-row mapping. Acts as drift anchor for CS-013 (the bats test T013 reads from this file).
- T042 — [P] In `.claude/presets/README.md`, add a paragraph after the existing "Available presets" table explaining the category-based pre-prompt (1 sentence per concept: when it fires, how it filters, opt-in via `categories[]`).

**Checkpoint**: Docs aligned.

### Phase 6 — Regen + audit gauntlet (US-3, anti-drift)

- T043 — Run `npm --prefix website run generate`. Capture stdout (should print `tests: 97+`).
- T044 — Verify `jq '.tests' counts.json` matches the expected new total.
- T045 — Run `npm --prefix website run test:scripts`. Expected exit 0.
- T046 — Run `./scripts/validate-presets.sh`. Expected exit 0; 11 presets valid.
- T047 — Run `./scripts/validate-counts.sh`. Expected exit 0, "No drift detected".
- T048 — Run `./scripts/audit-base.sh`. Expected exit 0, no new issue.
- T049 — Run `bats tests/presets.bats`. Expected exit 0, ≥97 tests pass.

**Checkpoint**: All gates green.

### Phase 7 — CHANGELOG + pre-commit guardrails

- T050 — [P] In `CHANGELOG.md` under `[Unreleased] / ### Added`, add ONE bullet describing both the prompt and the schema extension.
- T051 — [P] Run `git diff --name-only HEAD`. Expected file set (≥17 entries: 3 scripts + 1 new lib + 11 manifests + 4 docs + tests + auto-regen). Investigate any extra.
- T052 — [P] Run `bash scripts/private-names-check.sh` over the staged diff (per `feedback_no_project_names`). Expected: exit 0.

**Checkpoint**: Diff clean, ready to commit.

### Phase 8 — Commits + push + PR + watch + merge

- T053 — Two commits per `feedback_commit_splits` pattern (same-domain test→feat):
  - Commit A: `test(presets): add RED tests for category prompt + categories[] validation`
  - Commit B: `feat(presets): pre-detection category prompt + categories[] schema + 11-preset retrofit`
- T054 — `git push -u origin HEAD`.
- T055 — Open PR via `gh pr create` with body covering: motivation, taxonomy, retrofit table, test plan.
- T056 — Watch CI via `gh pr checks <N> --watch --fail-fast`.
- T057 — On all-green: `gh pr merge <N> --squash --delete-branch`. Sync local main.

**Checkpoint**: Feature live, branch cleaned.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Bats interactive test simulation breaks under macOS bash 3.2 → 4 upgrade differences | Medium | Low | Use the existing pattern from `presets.bats:301` (verified working) ; avoid `set -e` in tests |
| `declare -A` bash 4 syntax breaks on some user systems | High | Low | `common.sh:177` already enforces bash 4+ ; document the requirement in `category-map.sh` header |
| `_CATEGORY_TYPES_MAP` initial values disagree with what users expect | Medium | Medium | Mapping locked in this plan after exploration ; future evolution = 1-PR amendment with bats test update |
| Retrofit of `categories[]` triggers `validate-presets.sh` rejection if enum slug typo | High | Medium | Phase 3a (validator) ships BEFORE Phase 4 (retrofit) ; typos caught immediately |
| Playwright multi-category creates double-listing confusion in the menu | Medium | Low | Documented in plan as known tradeoff ; if real UX feedback emerges, future PR adds a "tooling" category |
| Drift between taxonomy in `lib/category-map.sh` and `specs/presets/roadmap.md` | High | Medium | Drift-guard bats test (T013) compares both sources at every CI run |
| Modifying `get_project_type()` breaks one of the existing interactive paths | High | Medium | All 5 guards short-circuit cleanly ; the existing flow is preserved when any guard fails. Phase 2 includes US-2/US-3 regression tests. |
| Tests count rises but auto-regen forgotten → counts drift | High | Medium | T043 listed before audit steps in Phase 6 ; same pattern as PR #185 |
| Forgetting one of the 11 retrofits | Medium | Low | T039 runs `validate-presets.sh` over all 11 ; a missing category isn't an error (soft migration) but `bats` test T011 would fail if `phaser` isn't categorized |

---

## Dependencies and Execution Order

```
Phase 1 (T001-T003) — Pre-verification
       │
       ▼
Phase 2 (T004-T014) — TDD RED
       │
       ▼
Phase 3a (T015-T017) — Validator GREEN ◄── unlocks Phase 4
       │
       ▼
Phase 3b (T018-T024) — Prompt lib GREEN
       │
       ▼
Phase 3c (T025-T027) — Integration GREEN ◄── all new tests pass
       │
       ▼
Phase 4 (T028-T039) — Retrofit 11 presets
       │
       ├──▶ Phase 5a (T040) — Spec [P]
       │
       ├──▶ Phase 5b (T041) — Roadmap [P]
       │
       └──▶ Phase 5c (T042) — Presets README [P]
                                  │
                                  ▼
                          Phase 6 (T043-T049) — Regen + audits
                                  │
                                  ▼
                          Phase 7 (T050-T052) — CHANGELOG + guards
                                  │
                                  ▼
                          Phase 8 (T053-T057) — Commits + PR + merge
```

### Story dependencies

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US-1 (new user discovers preset) | Phase 3c | Integration test live |
| US-2 (`--preset/--type` bypass) | Phase 3c | Same integration |
| US-3 (CI/non-interactive skip) | Phase 3c | Guard logic verified |
| US-4 (filtered menu) | Phase 3b | Library available |
| US-5 (11 presets retrofitted) | Phase 4 | Mechanical step |
| US-6 (soft migration optional field) | Phase 3a | Validator behavior |
| US-7 (Other/Generic full menu) | Phase 3b + Phase 3c | Library + integration |
| US-8 (empty-category banner) | Phase 3b | Banner in `print_filtered_type_menu` |

### Parallelization opportunities

- Phase 5 (T040, T041, T042) touch different files → parallel batch
- Phase 6 (T043 sequential, then T045-T049) — T045-T049 are independent reads
- Phase 7 (T051, T052) are independent grep ops on the same diff

---

## Validation Criteria

### Gate 1 — Before starting
- [ ] All 4 clarifications resolved (spec §"Locked decisions")
- [ ] Branch renamed or T003 queued
- [ ] CI baseline captured

### Gate 2 — Mid-implementation (after Phase 3a)
- [ ] Validator enum tests pass (T004, T005, T006)
- [ ] Existing 87 bats tests still pass (no regression)

### Gate 3 — Mid-implementation (after Phase 3c)
- [ ] All 10 new bats tests pass (T004-T013)
- [ ] Existing 87 bats tests still pass

### Gate 4 — Before commit (after Phase 7)
- [ ] All 57 tasks T001-T057 minus those queued for user (T003 rename, T056-T057 merge) completed
- [ ] `counts.json#tests` matches the expected new total
- [ ] `counts.json#presets == 11` (unchanged)
- [ ] `./scripts/validate-counts.sh` exit 0
- [ ] `./scripts/audit-base.sh` exit 0
- [ ] `bats tests/presets.bats` exit 0 (≥97 tests pass)
- [ ] Grep on protected names returns empty

### Gate 5 — Before merge
- [ ] CI all green (CodeQL, Lint & Test ubuntu+macos, Security Scan, Validate PR)
- [ ] PR description references spec + lists the taxonomy + the 11-preset retrofit table

---

## Notes

- **Workflow scale**: medium-large. Larger than PRs #185/#188/#189/#190/#191 (each ~30 min mechanical), smaller than the v1.39.0 react-vite-spa PR (~600 LOC). Real foundation feature touching 3 scripts, 11 manifests, 4 docs.
- **TDD genuine**: validation rules + prompt logic = pure logic, perfectly TDDable. The bats interactive pattern is the lever.
- **Backward compat is the watchword**: every existing path (skip-prompts, --preset, --type) MUST behave identically. Phase 2 includes US-2/US-3 regression tests as the safety net.
- **Memory anchors**:
  - `feedback_verify_code_claims` — bash 4+ confirmed, bats interactive pattern verified, `_MENU_STD_TYPES` slugs verified
  - `feedback_no_project_names` — T052 grep guard
  - `feedback_counts_ci_gate` — T043 auto-regen before audit steps
  - `feedback_anti_drift_badge` — README badge auto-bumped by T043
  - `feedback_commit_splits` — same-domain test→feat split applied in T053

**To avoid**:
- Implementing validator enum before writing failing tests (TDD violation)
- Retrofitting presets before validator is in place (would catch typos too late)
- Hand-editing `counts.json` (T043 overwrites)
- Skipping the drift-guard test T013 (the foundation's "single source of truth" discipline)
- Hardcoding category-to-types mapping in multiple places (single source in `lib/category-map.sh`)
- Naming any end-user project (T052 grep guard)

---

**Version**: 1.0 | **Created**: 2026-05-19 | **Last modified**: 2026-05-19
