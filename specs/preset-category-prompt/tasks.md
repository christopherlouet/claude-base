# Tasks: pre-detection category prompt (Option C1)

**Input**: `specs/preset-category-prompt/spec.md` + `specs/preset-category-prompt/plan.md`
**Prerequisites**: spec.md (8 US, 16 EF, 14 CS, 4 CP all resolved), plan.md (8 phases)
**Branch**: `feature/auto-20260519-095318` → rename to `feat/preset-category-prompt`

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** : runnable in parallel (different files, no dependencies)
- **[US1..US8]** : traceability to the spec's user stories
- Exact file paths required

---

## Phase 1 — Pre-verification + branch rename (BLOCKING)

**Goal**: Capture baseline; rename branch to descriptive name.

- [ ] **T001** Capture CI baseline (BEFORE any edit):
  - `./scripts/validate-presets.sh` → record exit code (expected `0`, 11 valid)
  - `./scripts/validate-counts.sh` → record exit code (expected `0`)
  - `bats tests/presets.bats` → record pass/fail count (expected `87/87`)
  - `jq '.tests, .presets' counts.json` → expected `633` tests / `11` presets (or whatever the current values are at session start)
- [ ] **T002** Verify bash version locally: `bash --version | head -1` ≥ 4. Confirm `declare -A` works by running `bash -c 'declare -A x=([a]=1); echo ${x[a]}'`.
- [ ] **T003** Rename branch: instruct user to run `/git-rename feat/preset-category-prompt` (slash command is user-invoked).

**Checkpoint**: Baseline known. Branch named.

---

## Phase 2 — TDD RED: failing bats tests (US-1, US-2, US-3, US-4, US-5, US-6, US-7)

**Goal**: Write tests that fail because the feature doesn't exist yet.

⚠️ DO NOT touch `validate-presets.sh`, `lib/category-map.sh`, or `new-project.sh` yet. Only `tests/presets.bats`.

- [ ] **T004** [US4] Append a negative bats test "validate-presets.sh rejects categories[] with out-of-enum value (EF-006)". Heredoc fixture: valid manifest + `"categories": ["mobile-native"]`. Assert exit 1 and output contains "categories" and "out-of-enum".
- [ ] **T005** [US6] Append positive bats test "validate-presets.sh accepts categories: [] empty array as field-absent (EF-006)". Heredoc fixture: valid manifest + `"categories": []`. Assert exit 0.
- [ ] **T006** [US4] Append positive bats test "validate-presets.sh accepts categories[] with 2 valid slugs (multi-category, EF-014)". Heredoc fixture: valid manifest + `"categories": ["web-frontend", "api-backend"]`. Assert exit 0.
- [ ] **T007** [US1] Append bats test "ask_category prompts and returns chosen category slug on TTY". Pattern:
  ```bash
  run env BASE_DIR="$BASE_DIR" bash -c "
      source '$BASE_DIR/scripts/lib/common.sh'
      source '$BASE_DIR/scripts/lib/category-map.sh'
      echo '4' | ask_category
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"game-interactive-media"* ]]
  ```
- [ ] **T008** [US3] Append bats test "ask_category skips silently when stdin is not a TTY". Run with redirected stdin (`< /dev/null`); assert no prompt text in output.
- [ ] **T009** [US2] Append bats test "get_project_type bypasses category prompt when PRESET_NAME is set (EF-010)". Source lib, set PRESET_NAME=phaser, call `get_project_type`, assert no category prompt printed.
- [ ] **T010** [US2] Append bats test "get_project_type bypasses category prompt when FORCE_TYPE is set (EF-010)". Same pattern with FORCE_TYPE=python.
- [ ] **T011** [US4] Append bats test "print_filtered_type_menu(game-interactive-media) shows only phaser". After Phase 4 retrofit, this fires correctly. Currently fails because lib doesn't exist.
- [ ] **T012** [US7] Append bats test "apply_category_choice for default (Enter without picking) maps to other-generic" (CP1 lock).
- [ ] **T013** Append drift-guard bats test "taxonomy slugs in lib/category-map.sh match roadmap.md exactly (CS-013)". Reads both sources, normalizes, compares.
- [ ] **T014** Run `bats tests/presets.bats`. Expected: **10 new tests fail** for the expected reasons (lib doesn't exist OR validator doesn't enforce enum). Record the failure reasons explicitly for each. **DO NOT** proceed if any test fails for unexpected reasons.

**Checkpoint**: 10 new bats tests RED. Baseline 87 still green.

---

## Phase 3 — TDD GREEN: implementation

### Phase 3a — Validator enum (US-4, US-6)

**Goal**: Flip T004, T005, T006 from RED to GREEN.

- [ ] **T015** In `scripts/validate-presets.sh`, add a constant near the existing `ALLOWED_STATUS` (line 77):
  ```bash
  ALLOWED_CATEGORIES='["web-frontend","api-backend","mobile-desktop","game-interactive-media","data-database","infra-devops","cli-automation","other-generic"]'
  ```
- [ ] **T016** In the same file, after the existing validation blocks (around line 270, before the final error report), add a `categories[]` validation block:
  ```bash
  # categories: optional; if present, MUST be an array of strings,
  # each from the locked enum (spec: preset-category-prompt EF-006).
  if jq -e '.categories' "$file" >/dev/null 2>&1; then
      cat_type=$(jq -r '.categories | type' "$file")
      if [ "$cat_type" != "array" ]; then
          errs+=("categories must be an array")
      else
          cat_n=$(jq -r '.categories | length' "$file")
          for ci in $(seq 0 $((cat_n - 1))); do
              cval=$(jq -r ".categories[$ci]" "$file")
              if ! echo "$ALLOWED_CATEGORIES" | jq -e "index(\"$cval\")" >/dev/null 2>&1; then
                  errs+=("categories[$ci] '$cval' not in $ALLOWED_CATEGORIES")
              fi
          done
      fi
  fi
  ```
- [ ] **T017** Run `bats tests/presets.bats`. Expected: T004 / T005 / T006 pass. Other Phase 2 tests still RED. Baseline 87 still green.

**Checkpoint**: Validator enum live, 3 tests flipped.

### Phase 3b — Prompt library (US-1, US-4, US-7)

**Goal**: Build the standalone library; flip T007 / T008 / T011 / T012 / T013.

- [ ] **T018** Create `scripts/lib/category-map.sh`. Header guard pattern from `lib/menu.sh:11-15`:
  ```bash
  #!/usr/bin/env bash
  # Claude-Base Category Map Library (lib/category-map.sh)
  # Spec: specs/preset-category-prompt/spec.md
  # Requires bash 4+ (associative arrays). Enforced by common.sh:177.

  if ! declare -f info >/dev/null 2>&1; then
      echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
      exit 1
  fi
  ```
- [ ] **T019** Declare the 3 data structures (constants):
  ```bash
  _CATEGORY_SLUGS=(web-frontend api-backend mobile-desktop game-interactive-media data-database infra-devops cli-automation other-generic)
  _CATEGORY_LABELS=("Web frontend" "API / Backend" "Mobile / Desktop" "Game / Interactive media" "Data / Database" "Infra / DevOps" "CLI / Automation" "Other / Generic")
  declare -A _CATEGORY_TYPES_MAP=(
      [web-frontend]="react vue fullstack generic"
      [api-backend]="node-api python go rust java generic"
      [mobile-desktop]="flutter generic"
      [game-interactive-media]="generic"
      [data-database]="python generic"
      [infra-devops]="generic"
      [cli-automation]="python go rust generic"
      [other-generic]="react vue node-api python go rust java fullstack flutter neovim generic"
  )
  ```
- [ ] **T020** Implement `print_category_menu()` mirroring `print_type_menu()` shape (loop over `_CATEGORY_LABELS`, mark entry 8 = `other-generic` with "← default").
- [ ] **T021** Implement `apply_category_choice(choice)` — parse numeric input ∈ [1,8] → set `SELECTED_CATEGORY_SLUG="${_CATEGORY_SLUGS[$((choice-1))]}"`. Empty / invalid input → `SELECTED_CATEGORY_SLUG="other-generic"` (CP1 lock).
- [ ] **T022** Implement `ask_category()` composite — guard `[ -t 0 ]` early-return; otherwise print prompt, `read -r choice`, call `apply_category_choice "$choice"`, echo `$SELECTED_CATEGORY_SLUG` to stdout.
- [ ] **T023** In `scripts/lib/menu.sh`, add `print_filtered_type_menu(category_slug)` and `apply_filtered_type_choice(choice, category_slug)`. When slug is `other-generic`, behaves identically to existing `print_type_menu` (regression-safe). Otherwise: filter `_MENU_STD_LABELS` to those whose corresponding `_MENU_STD_TYPES` entry is in `_CATEGORY_TYPES_MAP[$category_slug]`; filter presets by reading their `categories[]` field with `jq` lookup.
- [ ] **T024** Run `bats tests/presets.bats`. Expected: T007 / T008 / T011 / T012 / T013 pass. T009 / T010 still RED (no integration yet).

**Checkpoint**: Library complete, 5 more tests flipped.

### Phase 3c — `new-project.sh` integration (US-1, US-2, US-3)

**Goal**: Wire the library into the existing menu; flip T009 / T010.

- [ ] **T025** In `scripts/new-project.sh`, source `lib/category-map.sh` near the existing `source` block (around line 26-30).
- [ ] **T026** Modify `get_project_type()` (line 1411) to call the category prompt FIRST when all 5 guards hold:
  ```bash
  # 5 guards: interactive + TTY + no --preset + no --type + no detect hit
  local SELECTED_CATEGORY_SLUG="other-generic"  # default per CP1
  if $INTERACTIVE && [ -t 0 ] && [[ -z "$PRESET_NAME" ]] && [[ -z "$FORCE_TYPE" ]] && [[ ${#MATCHED_PRESETS[@]} -eq 0 ]]; then
      SELECTED_CATEGORY_SLUG=$(ask_category)
  fi
  # Then call print_filtered_type_menu(SELECTED_CATEGORY_SLUG) instead of print_type_menu
  ```
- [ ] **T027** Run `bats tests/presets.bats`. Expected: ALL 10 new tests PASS (T004-T013). Baseline 87 still green. Total 97+ passing.

**Checkpoint**: GREEN state. Integration live.

---

## Phase 4 — Retrofit 11 presets with `categories[]` (US-5)

**Goal**: Every shipped preset declares its category. Validator (Phase 3a) now exercises real data.

Each retrofit is a single JSON edit (add `"categories": [...]` line). Use Edit tool on each file, anchored on a unique line (e.g., the `relatedPresetsWanted` field or `outOfScope`).

- [ ] **T028** [US5] Add `"categories": ["web-frontend", "api-backend"]` to `.claude/presets/nextjs.json`. Rationale: Next.js is genuinely full-stack (SSR + API routes).
- [ ] **T029** [US5] Add `"categories": ["web-frontend"]` to `.claude/presets/astro.json`. Rationale: content/static-first.
- [ ] **T030** [US5] Add `"categories": ["web-frontend"]` to `.claude/presets/react-vite-spa.json`. Rationale: SPA only, no SSR.
- [ ] **T031** [US5] Add `"categories": ["api-backend"]` to `.claude/presets/fastapi.json`.
- [ ] **T032** [US5] Add `"categories": ["cli-automation"]` to `.claude/presets/cli-tools.json`.
- [ ] **T033** [US5] Add `"categories": ["infra-devops"]` to `.claude/presets/homelab-proxmox.json`.
- [ ] **T034** [US5] Add `"categories": ["game-interactive-media"]` to `.claude/presets/phaser.json`.
- [ ] **T035** [US5] Add `"categories": ["web-frontend", "api-backend"]` to `.claude/presets/playwright.json`. Rationale: cross-cutting test tool used in both contexts; plan tradeoff documented.
- [ ] **T036** [US5] Add `"categories": ["infra-devops"]` to `.claude/presets/pulumi.json`.
- [ ] **T037** [US5] Add `"categories": ["api-backend"]` to `.claude/presets/apollo.json`. Rationale: CP4 lock; backend depth of the vendor's skill suite.
- [ ] **T038** [US5] Add `"categories": ["data-database"]` to `.claude/presets/mongodb.json`.
- [ ] **T039** Run `./scripts/validate-presets.sh`. Expected: 11 valid, exit 0. The enum validator catches any typo immediately.

**Checkpoint**: 11 presets retrofitted, all valid.

---

## Phase 5 — Spec + roadmap + presets README amendments [P]

**Goal**: Documentation in sync with the new feature.

- [ ] **T040** [P] In `specs/presets/spec.md`, extend the "JSON schema" section: add the `categories[]` field documentation (optional, array of slugs, strict enum). Cross-reference `specs/preset-category-prompt/spec.md` as the binding source.
- [ ] **T041** [P] In `specs/presets/roadmap.md`, add a "## Category taxonomy" section listing the 8 slugs in the locked order, each with its display label + the roadmap row it mirrors. This file is the source-of-truth for the drift-guard bats test T013.
- [ ] **T042** [P] In `.claude/presets/README.md`, add a short paragraph after the "Available presets" table explaining: when the category prompt fires (1 sentence), how it filters (1 sentence), how to opt-in (1 sentence).

**Checkpoint**: Docs aligned.

---

## Phase 6 — Regen + audit gauntlet

**Goal**: Auto-regen; all foundation scripts green.

⚠️ DO NOT hand-edit `counts.json` or the README badge.

- [ ] **T043** From repo root: `npm --prefix website run generate`. Capture stdout (should print updated `tests:` count, presets stays 11).
- [ ] **T044** Verify: `jq '.tests, .presets' counts.json`. Tests should be ≥ baseline + 10. Presets MUST be 11 (unchanged).
- [ ] **T045** [P] Run `npm --prefix website run test:scripts`. Expected exit 0, ≥35 tests pass.
- [ ] **T046** [P] Run `./scripts/validate-presets.sh`. Expected exit 0; output lists 11 valid presets.
- [ ] **T047** [P] Run `./scripts/validate-counts.sh`. Expected exit 0, "No drift detected".
- [ ] **T048** [P] Run `./scripts/audit-base.sh`. Expected exit 0, no new issue.
- [ ] **T049** [P] Run `bats tests/presets.bats`. Expected exit 0, ≥97 tests pass.

**Checkpoint**: All gates green; counters consistent.

---

## Phase 7 — CHANGELOG + pre-commit guardrails

**Goal**: Diff clean and ready to commit.

- [ ] **T050** [P] In `CHANGELOG.md` under `[Unreleased] / ### Added`, prepend ONE bullet:
  ```
  - **Pre-detection category prompt + `categories[]` schema extension**.
    When a user runs the foundation install script on an empty
    directory (or a script-created directory) with no flags and no
    auto-detect hit, a new prompt asks "What are you building?"
    with an 8-entry taxonomy locked to the roadmap (Web frontend /
    API-Backend / Mobile-Desktop / Game-Interactive media /
    Data-Database / Infra-DevOps / CLI-Automation / Other-Generic).
    The chosen category filters the subsequent type-and-preset
    menu down to relevant entries. The preset manifest schema
    gains an optional `categories: [string]` field (strict enum,
    validated by `validate-presets.sh`); presets without it
    remain accessible via detect / flag / list (soft migration).
    All 11 shipped presets retrofitted with their category in
    the same delivery. The prompt is silently skipped on non-TTY,
    `--skip-prompts`, `--yes`, `--preset`, `--type`, or when
    auto-detect already produced a match. Counter `presets`
    unchanged at 11; `tests` grows by 10. Spec at
    [`specs/preset-category-prompt/`](./specs/preset-category-prompt/).
  ```
- [ ] **T051** [P] Run `git diff --name-only HEAD`. Expected file set:
  - `scripts/lib/category-map.sh` (new)
  - `scripts/lib/menu.sh`
  - `scripts/new-project.sh`
  - `scripts/validate-presets.sh`
  - `tests/presets.bats`
  - `.claude/presets/{nextjs,astro,react-vite-spa,fastapi,cli-tools,homelab-proxmox,phaser,playwright,pulumi,apollo,mongodb}.json` (×11)
  - `.claude/presets/README.md`
  - `specs/presets/spec.md`
  - `specs/presets/roadmap.md`
  - `CHANGELOG.md`
  - `counts.json` (auto-regenerated)
  - `README.md` (auto-regenerated badge)
  - `specs/preset-category-prompt/{spec.md, plan.md, tasks.md}` (this feature's design docs, untracked)
- [ ] **T052** [P] Grep for protected end-user project names over the diff: `git diff HEAD | grep -iE 'alloc-budget|escapade|<known-protected>'`. Expected: empty.

**Checkpoint**: Diff clean.

---

## Phase 8 — Commits + push + PR + watch + merge

**Goal**: Ship the feature on `main`.

- [ ] **T053** Two commits per `feedback_commit_splits` (same-domain test→feat split):
  - **Commit A** — design docs + RED tests :
    ```
    test(presets): RED tests for category prompt + categories[] schema
    ```
    Files: `specs/preset-category-prompt/{spec.md, plan.md, tasks.md}` + `tests/presets.bats` (Phase 2 additions only).
  - **Commit B** — GREEN implementation + retrofit + docs + CHANGELOG :
    ```
    feat(presets): pre-detection category prompt + 11-preset retrofit
    ```
    Files: everything else from T051.
- [ ] **T054** `git push -u origin HEAD`.
- [ ] **T055** Open PR via `gh pr create` with body covering: motivation (empty-dir UX gap), the 8-entry taxonomy, the 11-preset retrofit table, the test plan (10 new bats tests), the explicit Playwright tradeoff (multi-category).
- [ ] **T056** Watch CI via `gh pr checks <N> --watch --fail-fast` (with `sleep 10` first to let checks attach).
- [ ] **T057** On all-green: `gh pr merge <N> --squash --delete-branch`. Sync local: `git checkout main && git pull --ff-only`.

**Checkpoint**: Feature live on `main`, branch cleaned.

---

## Dependencies and Execution Order

```
Phase 1 (T001-T003) — Pre-verification ◄── BLOCKS everything
       │
       ▼
Phase 2 (T004-T014) — TDD RED — 10 failing tests
       │
       ▼
Phase 3a (T015-T017) — Validator GREEN ◄── unlocks Phase 4
       │
       ▼
Phase 3b (T018-T024) — Prompt lib GREEN
       │
       ▼
Phase 3c (T025-T027) — Integration GREEN ◄── all 10 new tests pass
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
| US-1 (new user discovers preset) | Phase 3c | Integration live |
| US-2 (`--preset/--type` bypass) | Phase 3c | Guard logic verified by T009/T010 |
| US-3 (CI/non-interactive skip) | Phase 3c | Guard logic verified by T008 |
| US-4 (filtered menu) | Phase 3b | Library available |
| US-5 (11 presets retrofitted) | Phase 4 | Mechanical step after validator GREEN |
| US-6 (soft migration optional field) | Phase 3a | Validator behavior tested by T005 |
| US-7 (Other/Generic full menu) | Phase 3b + Phase 3c | Library + integration |
| US-8 (empty-category banner) | Phase 3b | Implemented inside `print_filtered_type_menu` |

### Parallelization opportunities

- Phase 5 (T040, T041, T042) touch different files → parallel batch
- Phase 6 audit reads (T045-T049) are independent → parallel batch (T043-T044 must run first)
- Phase 7 (T051, T052) are independent grep ops on the same diff
- The 11 retrofits in Phase 4 (T028-T038) are independent file edits → could parallelize but the cost of opening 11 Edit tools simultaneously is similar to sequential

---

## Implementation Strategy

### Solo MVP path (~6-8h focused work)

1. Phase 1 (~15 min)
2. Phase 2 RED (~60-90 min — write 10 bats tests carefully, verify each fails for the expected reason)
3. Phase 3a + 3b + 3c GREEN (~3h — validator + new lib + integration)
4. Phase 4 retrofit (~30 min — 11 small JSON edits)
5. Phase 5 docs (~30 min in parallel)
6. Phase 6 gauntlet (~15 min)
7. Phase 7 pre-commit (~15 min)
8. Phase 8 commit + push + PR + merge (~30 min, half blocking on CI watch)

### What to NOT do

- Implement validator enum or `lib/category-map.sh` before writing failing tests (TDD violation)
- Retrofit a preset before validator is in place (defeats the safety net)
- Hand-edit `counts.json` (T043 overwrites)
- Skip the drift-guard test T013 (taxonomy/roadmap divergence is the foundation's classic anti-drift trap)
- Hardcode the category-to-types mapping in 2+ places (single source in `lib/category-map.sh`)
- Name any end-user project (T052 grep guard)
- Add new fixtures (the new bats tests are all heredoc-based — no need for `tests/presets-fixtures/<new>/`)

---

## Notes

- **TDD is mandatory** per `.claude/rules/workflow.md` — the validator logic + prompt parsing logic are both pure logic, perfectly TDDable.
- **No new bundled artifact outside `.claude/presets/`** : zero touch on `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`.
- **`counts.json#presets` stays at 11** : this is a schema extension, not a new preset.
- **Soft migration discipline** : community presets without `categories[]` still ship, just don't appear in the new prompt's filtered menu.
- **Playwright tradeoff** : declared `["web-frontend", "api-backend"]` because Q3 locked strict enum (no "any" slug). Future PR could add a 9th "tooling" slot if cross-cutting tools accumulate.

**Memory anchors actively used**:
- `feedback_verify_code_claims` — T001 (baseline), T002 (bash version), exercised at plan time
- `feedback_no_project_names` — T052 grep guard
- `feedback_counts_ci_gate` — T043 auto-regen before audit steps
- `feedback_anti_drift_badge` — README badge auto-bumped by T043
- `feedback_commit_splits` — same-domain test→feat split in T053

---

**Version**: 1.0 | **Created**: 2026-05-19
