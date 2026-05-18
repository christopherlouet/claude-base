# Tasks: `vendor-pointer` preset tier + first instance

**Input**: `specs/presets-vendor-pointer-tier/spec.md` + `specs/presets-vendor-pointer-tier/plan.md`
**Prerequisites**: spec.md (6 US, 16 EF, 12 CS, 3 CP all resolved), plan.md (10 phases)
**Branch**: `feature/auto-20260518-155721` → rename to `feat/presets-vendor-pointer-tier`

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** : runnable in parallel (different files, no dependencies)
- **[US1..US6]** : traceability to the spec's user stories
- Exact file paths required

---

## Phase 1 — Pre-verification + branch rename (BLOCKING)

**Goal**: Capture baseline, confirm Phaser still healthy, set descriptive branch name.

- [ ] **T001** Sanity-check Phaser repo state: `gh api repos/phaserjs/phaser --jq '{archived, pushed_at}'`. Confirm `archived == false` and `pushed_at` ≤ 30 days old. If archived or dead, STOP.
- [ ] **T002** Capture CI baseline (BEFORE any edit):
  - `./scripts/validate-presets.sh` → record exit code (expected `0`)
  - `./scripts/validate-counts.sh` → record exit code (expected `0`)
  - `bats tests/presets.bats` → record pass/fail count (expected `72/72`)
  - `jq '.presets' counts.json` → expected `6`
- [ ] **T003** Rename branch: instruct user to run `/git-rename feat/presets-vendor-pointer-tier` (slash command is user-invoked, not Bash).

**Checkpoint**: Baseline known. Branch named. Ready for TDD RED.

---

## Phase 2 — TDD RED: failing bats tests (US-4, US-2)

**Goal**: Write tests that fail because the rules don't exist yet.

⚠️ DO NOT touch `validate-presets.sh` yet. Only `tests/presets.bats`.

- [ ] **T004** [US4] In `tests/presets.bats`, append a test block:
  ```
  @test "presets: validate-presets.sh rejects a vendor-pointer preset declaring marketplacePlugins (EF-004)"
  ```
  Heredoc body: minimal valid vendor-pointer manifest + non-empty `marketplacePlugins`. Assert exit 1 and output contains the field name.
- [ ] **T005** [US4] Similar test: `"presets: validate-presets.sh rejects a vendor-pointer preset declaring foundation.skills.keep (EF-004)"`.
- [ ] **T006** [US4] Similar test: `"presets: validate-presets.sh rejects a vendor-pointer preset missing recommendedVendorSkills (EF-003)"`.
- [ ] **T007** [US4] Similar test: `"presets: validate-presets.sh rejects a vendor-pointer preset with a multi-entry detect.depFiles (EF-005)"`.
- [ ] **T008** [US4] Similar test: `"presets: validate-presets.sh rejects a vendor-pointer preset declaring both files[1] AND depFiles[1] (EF-005 XOR)"`.
- [ ] **T009** [US2] Positive test: `"presets: phaser.json (vendor-pointer) is accepted by validate-presets.sh (T009)"`. Asserts exit 0 and output contains `phaser.json`. Will fail initially: `vendor-pointer` not in enum AND `phaser.json` doesn't exist yet.
- [ ] **T010** Run `bats tests/presets.bats`. Expected: 5 negative tests fail with `status '<x>' not in <enum>` (because `vendor-pointer` not yet allowed); positive T009 fails for the same reason + missing file. Record the failure reasons explicitly for each test. **DO NOT** proceed to Phase 3 if any test fails for an unexpected reason.

**Checkpoint**: 6 new tests, all failing for the expected reason. RED state confirmed.

---

## Phase 3 — TDD GREEN: implement validation rules (US-4)

**Goal**: Minimum impl to flip 5/6 tests from RED to GREEN.

- [ ] **T011** [US4] In `scripts/validate-presets.sh`, edit line 77:
  ```diff
  - ALLOWED_STATUS='["maintainer-vouched","community-curated","draft"]'
  + ALLOWED_STATUS='["maintainer-vouched","community-curated","vendor-pointer","draft"]'
  ```
- [ ] **T012** [US4] In the same file, edit the `case` at line 114-116:
  ```diff
  - maintainer-vouched|community-curated|draft) ;;
  + maintainer-vouched|community-curated|vendor-pointer|draft) ;;
  ```
- [ ] **T013** [US4] Reconcile EF-004 vs the existing required-`defaults` check. Wrap line 106 in a tier-condition:
  ```bash
  # defaults is required for all tiers EXCEPT vendor-pointer
  if [ "$status" != "vendor-pointer" ]; then
      [ "$(jq -r '.defaults // empty | type' "$file")" = "object" ] || errs+=("defaults must be an object")
  fi
  ```
- [ ] **T014** [US4] After the existing field validations (around line ~270, before `if [ ${#errs[@]} -gt 0 ]`), add a tier-conditional block. Implement EF-003, EF-004, EF-005:
  ```bash
  # ------------------------------------------------------------------
  # vendor-pointer tier rules (spec: presets-vendor-pointer-tier)
  # ------------------------------------------------------------------
  if [ "$status" = "vendor-pointer" ]; then
      # EF-003: recommendedVendorSkills MUST be present, non-empty array
      n=$(jq -r '.recommendedVendorSkills // [] | length' "$file")
      [ "$n" -ge 1 ] || errs+=("vendor-pointer preset requires recommendedVendorSkills[] with ≥1 entry (EF-003)")

      # EF-004: forbidden fields (or must be absent/empty)
      mp_n=$(jq -r '.marketplacePlugins // [] | length' "$file")
      [ "$mp_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare marketplacePlugins (EF-004)")

      keep_n=$(jq -r '.foundation.skills.keep // [] | length' "$file")
      [ "$keep_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare foundation.skills.keep (EF-004)")

      drop_n=$(jq -r '.foundation.skills.drop // [] | length' "$file")
      [ "$drop_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare foundation.skills.drop (EF-004)")

      has_defaults=$(jq -r 'if has("defaults") then "yes" else "no" end' "$file")
      [ "$has_defaults" = "no" ] || errs+=("vendor-pointer preset MUST NOT declare defaults (EF-004)")

      # EF-005: detect MUST contain exactly 1 signal (files[1] XOR depFiles[1])
      files_n=$(jq -r '.detect.files // [] | length' "$file")
      deps_n=$(jq -r '.detect.depFiles // [] | length' "$file")
      total=$((files_n + deps_n))
      [ "$total" -eq 1 ] || errs+=("vendor-pointer preset detect MUST contain exactly 1 signal entry (got $total) (EF-005)")
  fi
  ```
- [ ] **T015** Run `bats tests/presets.bats`. Expected: 5 negative tests (T004-T008) now PASS; positive T009 still fails (file missing). Record the new state.

**Checkpoint**: Validation logic implemented. Existing 72 tests still pass (regression check). 5/6 new tests GREEN.

---

## Phase 4 — Ship phaser.json + fixture (US-2)

**Goal**: First vendor-pointer preset shipped; detection works on paired fixture.

- [ ] **T016** [US2] Create `.claude/presets/phaser.json` with the shape documented in `plan.md` §"Phase 4". Key fields:
  - `status: "vendor-pointer"`
  - `appliesToTypes: ["generic"]`
  - `detect.combinator: "anyOf"`, `depFiles: [{path: "package.json", contains: "\"phaser\":"}]`
  - `recommendedVendorSkills: [{id, url, rationale, condition: "always"}]` pointing to `phaserjs/phaser/skills`
  - No `defaults`, no `marketplacePlugins`, no `foundation.skills`
- [ ] **T017** [US2] Create `tests/presets-fixtures/phaser/package.json`:
  ```json
  {
    "name": "fixture-phaser",
    "version": "0.0.0",
    "private": true,
    "dependencies": { "phaser": "^4.0.0" }
  }
  ```
- [ ] **T018** [US2] In `tests/presets.bats`, append a fixture-pairing test following the existing pattern at line 688:
  ```
  @test "presets: phaser detect rule matches its fixture (US-5)"
  ```
  Body uses `scan_presets '$BASE_DIR/tests/presets-fixtures/phaser'` and asserts the output contains `phaser`.
- [ ] **T019** Run `bats tests/presets.bats`. Expected: ALL tests pass (≥79 total: 72 baseline + 6 from Phase 2 + 1 fixture pairing). T009 now GREEN.

**Checkpoint**: Phaser preset live, detection verified.

---

## Phase 5 — Spec amendment (US-3) [P]

**Goal**: `specs/presets/spec.md` formally documents the new tier.

- [ ] **T020** [P] [US3] Open `specs/presets/spec.md`. Locate the "Status tiers" table (search markers: `| Status | Quality bar | Visible to default users |`). Insert a new row between `community-curated` and `draft`:
  ```
  | `vendor-pointer` | Vendor source already validated in `docs/recipes/recommended-vendor-skills.md` (no maintainer prod-use claim required) | Yes, in `.claude/presets/` |
  ```
- [ ] **T021** [P] [US3] After the Status tiers table, add a new subsection:
  ```
  ### Field rules under `status: vendor-pointer`

  - `recommendedVendorSkills[]` MUST be present with ≥1 entry (EF-003).
  - `marketplacePlugins[]`, `foundation.skills.keep[]`, `foundation.skills.drop[]`, `defaults` MUST be absent or empty (EF-004).
  - `detect` MUST contain exactly 1 signal entry: either `files[]` of length 1 OR `depFiles[]` of length 1 (XOR, EF-005).
  - Bar to ship: the pointed-to vendor source MUST already pass the marketplace-audit methodology and be listed in `docs/recipes/recommended-vendor-skills.md`.
  - Full spec: `specs/presets-vendor-pointer-tier/spec.md`.
  ```
- [ ] **T022** [P] [US3] Update the top-of-spec status line if it claims a specific preset count. Currently reads `6 maintainer-vouched presets live`. Update to `6 maintainer-vouched presets + 1 vendor-pointer preset live`.

**Checkpoint**: Spec doc reflects the new tier.

---

## Phase 6 — Roadmap amendment (US-5) [P]

**Goal**: `specs/presets/roadmap.md` carries the new tier visibly.

- [ ] **T023** [P] [US5] In `specs/presets/roadmap.md`, after the existing `## Shipped (maintainer-vouched)` table, add a new H2:
  ```
  ## Shipped (vendor-pointer)

  | Preset | Stack | Shipped in |
  |---|---|---|
  | `phaser` | Phaser 2D web game framework — vendor-pointer | v1.40.0 (this PR) |

  Each shipped vendor-pointer preset has:
  - `.json` manifest under `.claude/presets/`
  - `tests/presets.bats` test entries (positive + fixture-pairing)
  - Entry in `.claude/presets/README.md`
  - Entry in `CHANGELOG.md`
  - Vendor source already validated in `docs/recipes/recommended-vendor-skills.md`
  ```
- [ ] **T024** [P] [US5] Add a section at end of file (after "## Quick reference (count)"):
  ```
  ## Vendor-pointer candidates

  These vendors already have validated entries in `docs/recipes/recommended-vendor-skills.md` and could become vendor-pointer presets in future PRs following the same pattern as `phaser`. Each is its own PR; this list is acknowledgment, not commitment.

  | Vendor | Source | Detect-rule shape |
  |---|---|---|
  | **Apollo GraphQL** | `apollographql/skills` | `package.json contains "@apollo/client"` |
  | **Microsoft Playwright** | `microsoft/playwright-cli` | `package.json contains "@playwright/test"` |
  | **Pulumi** | `pulumi/agent-skills` | `Pulumi.yaml` present |
  | **MongoDB** | `mongodb/agent-skills` | `package.json contains "mongodb"` or `"mongoose"` — pick one per the strict-detect rule |
  | **Grafana Labs** | `grafana/skills` | TBD — depends on project shape; likely a config file pattern |
  ```
- [ ] **T025** [P] [US5] In the "## Quick reference (count)" table, add a row:
  ```
  | Vendor-pointer presets | 1 (`phaser`) | 5+ |
  ```
- [ ] **T026** [P] [US5] Update the bottom-line tally line `**6 shipped. 23+ named as community-wanted.**` to:
  ```
  **6 maintainer-vouched + 1 vendor-pointer = 7 shipped. 28+ named as community-wanted (23+ maintainer-vouched candidates + 5+ vendor-pointer candidates).** That ratio is the foundation's honest position.
  ```

**Checkpoint**: Roadmap visibly carries the new tier and its growth path.

---

## Phase 7 — Presets README sync (anti-drift) [P]

**Goal**: `.claude/presets/README.md` stays accurate.

- [ ] **T027** [P] In `.claude/presets/README.md`, in the "## Available presets (this repo)" table, add a row for phaser:
  ```
  | `phaser` | vendor-pointer | Phaser 2D web game framework — pointer to `phaserjs/phaser/skills/` |
  ```
- [ ] **T028** [P] Update the paragraph below the table:
  ```
  The 6 maintainer-vouched presets cover the maintainer's actual production usage. The 1 vendor-pointer preset (`phaser`) surfaces a vendor-published skill at install time without a maintainer prod-use claim (see `specs/presets-vendor-pointer-tier/spec.md`). For other stacks (Django, Rails, Laravel, SvelteKit, Vue/Nuxt, Spring Boot, Phoenix, Go-Gin, Rust-Axum, Flutter, etc.), community contributions are welcomed — see `specs/presets/roadmap.md`.
  ```

**Checkpoint**: Presets README accurate.

---

## Phase 8 — Regen + audit gauntlet (US-2, anti-drift)

**Goal**: Auto-regen, all foundation scripts green.

⚠️ DO NOT hand-edit `counts.json`. Run the generator.

- [ ] **T029** From repo root: `npm --prefix website run generate`. Capture the stdout count line (should print `presets: 7`).
- [ ] **T030** Verify: `jq '.presets' counts.json` returns `7`.
- [ ] **T031** [P] Run `npm --prefix website run test:scripts`. Expected exit `0`, ≥35 tests pass.
- [ ] **T032** [P] Run `./scripts/validate-presets.sh`. Expected exit `0`; output mentions `phaser.json`.
- [ ] **T033** [P] Run `./scripts/validate-counts.sh`. Expected exit `0`, "No drift detected".
- [ ] **T034** [P] Run `./scripts/audit-base.sh`. Expected exit `0`, no issues.
- [ ] **T035** [P] Run `bats tests/presets.bats`. Expected exit `0`, ≥79 tests pass.

**Checkpoint**: All gates green; counters consistent.

---

## Phase 9 — CHANGELOG + pre-commit guardrails

**Goal**: Diff is clean and named.

- [ ] **T036** [P] In `CHANGELOG.md` under the existing `## [Unreleased] / ### Added` group (created in PR #183), add ONE bullet:
  ```
  - **Third preset tier `vendor-pointer`** + first instance `phaser`.
    The `vendor-pointer` tier is for thin pointer-only presets whose
    authority comes from the vendor (validated via the marketplace-audit
    methodology) rather than from maintainer production use. Forbids
    `foundation.skills` filters, `marketplacePlugins`, and `defaults`
    overrides; requires `recommendedVendorSkills[]` ≥1 and a simple
    `detect` rule (1 signal entry). First instance `phaser` wraps the
    `phaserjs/phaser/skills/` entry shipped in PR #183. Counter
    `presets` 6 → 7 (auto-regenerated). Spec at
    [`specs/presets-vendor-pointer-tier/`](./specs/presets-vendor-pointer-tier/).
  ```
- [ ] **T037** [P] Run `git diff --name-only HEAD`. Expected file set (ignoring this feature's design docs which land in their own commit):
  - `.claude/presets/phaser.json`
  - `.claude/presets/README.md`
  - `scripts/validate-presets.sh`
  - `specs/presets/spec.md`
  - `specs/presets/roadmap.md`
  - `tests/presets.bats`
  - `tests/presets-fixtures/phaser/package.json`
  - `CHANGELOG.md`
  - `counts.json` (auto-regenerated)
  - `README.md` (auto-regenerated badge if any)
  Any extra file → investigate before commit.
- [ ] **T038** [P] Grep for protected end-user project names over the diff (per `feedback_no_project_names`): `git diff HEAD | grep -Ei 'alloc-budget|escapade|<other-known-names>'`. Expected: empty.

**Checkpoint**: Diff clean, ready to commit.

---

## Phase 10 — Commits + push + PR + merge

**Goal**: Ship the tier on `main`.

- [ ] **T039** Commit A — design docs:
  ```
  docs(specs): plan vendor-pointer preset tier + first instance
  ```
  Files: `specs/presets-vendor-pointer-tier/{spec.md, plan.md, tasks.md}`.
- [ ] **T040** Commit B — implementation:
  ```
  feat(presets): add vendor-pointer tier + ship phaser (1st instance)
  ```
  Files: all from T037.
- [ ] **T041** `git push -u origin HEAD`.
- [ ] **T042** Open PR via `gh pr create` with body covering: summary, methodology, candidates list, test plan (≥6 new bats tests + 1 fixture pairing).
- [ ] **T043** Watch CI via `gh pr checks <N> --watch --fail-fast`.
- [ ] **T044** On all-green CI: `gh pr merge <N> --squash --delete-branch`. Sync local: `git checkout main && git pull --ff-only`.

**Checkpoint**: Tier shipped, Phaser preset live, branch cleaned up.

---

## Dependencies and Execution Order

```
Phase 1 (Pre-verification, T001-T003)  ◄── BLOCKS everything
       │
       ▼
Phase 2 (TDD RED, T004-T010)  ─── Tests committed BEFORE any impl
       │
       ▼
Phase 3 (TDD GREEN — validation, T011-T015) ─── Existing 72 tests MUST stay green
       │
       ▼
Phase 4 (Ship phaser.json + fixture, T016-T019)
       │
       ├──▶ Phase 5 (Spec, T020-T022) [P]
       │
       ├──▶ Phase 6 (Roadmap, T023-T026) [P]
       │
       └──▶ Phase 7 (Presets README, T027-T028) [P]
       │
       ▼
Phase 8 (Regen + audits, T029-T035)
       │
       ▼
Phase 9 (CHANGELOG + guards, T036-T038)
       │
       ▼
Phase 10 (Commits + PR + merge, T039-T044)
```

### Story dependencies

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US-1 (install-time surfacing) | Phase 4 | Verified implicitly via the existing `print_recommended_vendor_skills` pipeline; no new test added (covered by manual smoke or by future `--preset phaser --dry-run` invocation) |
| US-2 (first instance phaser) | Phase 4 | T016-T019 |
| US-3 (spec doc) | Phase 5 | T020-T022 |
| US-4 (validation) | Phase 3 | T011-T015 |
| US-5 (roadmap signals candidates) | Phase 6 | T023-T026 |
| US-6 (tier visible in --list-presets) | Phase 4 | Free — existing code already prints status |

### Parallelization opportunities

- Phases 5, 6, 7 touch different files → can run in parallel.
- T031-T035 (audit scripts) are independent reads → can run in parallel.
- T036-T038 (CHANGELOG + diff checks) are independent → can run in parallel.

---

## Implementation Strategy

### MVP path (US-2 + US-4, ~2-3h focused work)

1. Phase 1 (~10 min)
2. Phase 2 RED (~30 min — write 6 bats tests carefully)
3. Phase 3 GREEN (~30 min — wire up validation, iterate until green without regression)
4. Phase 4 (~20 min — phaser.json + fixture + pairing test)
5. Phase 5/6/7 in parallel (~30 min total)
6. Phase 8 (~10 min — regen + scripts)
7. Phase 9 (~10 min — CHANGELOG + grep)
8. Phase 10 (~10 min — 2 commits + PR + CI watch + merge)

### Solo strategy (1-developer change)

Linear walk through phases 1 → 10. Parallelization markers refer to batched shell commands in one Bash call, not multi-dev split.

---

## Notes

- **TDD is mandatory** here per `.claude/rules/workflow.md` — validation rules are pure logic, the discipline applies in full.
- **No new bundled artifact outside `.claude/presets/`**: zero touch on `.claude/skills/`, `.claude/agents/`, `.claude/settings.json` (per spec EF-014).
- **Auto-regenerated files in the same impl commit** is intentional — keeps the diff atomic and reviewable.
- **5 candidate vendors** named in T024 are intentionally NOT shipped here — each is its own follow-up PR. This is the foundation's standard "1 PR per stack" pattern (cf. PR #178 for react-vite-spa).
- **Memory anchors active**: `feedback_no_project_names` (T038), `feedback_verify_code_claims` (T001 + plan-time verifications), `feedback_counts_ci_gate` (T029), `feedback_anti_drift_badge` (auto-regen handles it).

**To avoid**:
- Implementing validation rules BEFORE writing failing tests (TDD violation).
- Hand-editing `counts.json` (T029 overwrites it).
- Skipping the existing 72-test regression check after Phase 3 (a refactor in `validate-presets.sh` could silently break maintainer-vouched validation).
- Naming any end-user project in CHANGELOG, spec, or commit (T038 grep guard).
- Adding more than the 1 candidate `phaser` in this PR — others are future PRs (per plan §"Notes").

---

**Version**: 1.0 | **Created**: 2026-05-18
