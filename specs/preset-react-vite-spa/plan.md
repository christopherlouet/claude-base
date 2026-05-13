# Implementation Plan: react-vite-spa preset (6th maintainer-vouched)

**Branch**: `feature/preset-react-vite-spa`
**Date**: 2026-05-13
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Add a 6th maintainer-vouched preset, `react-vite-spa`, targeting React Single-Page Apps built on Vite + React Router. Two strict prerequisites must land first as Phase 0 inside this same plan: (1) extend the runtime helpers to support a `keep`-style skills filter (whitelist), in addition to the existing `drop`-style filter (blacklist), and (2) extend the manifest validator and existing test suite to assert `drop` XOR `keep` (mutually exclusive). The preset itself ships in Phase 2–3, ships with paired fixture and per-preset E2E tests consistent with the data-driven detection pattern (PR #160/#161).

---

## Technical Context

| Aspect | Choice | Notes |
|---|---|---|
| **Language** | Bash 4+ (foundation runtime), JSON (manifest), Bats (tests) | No Node/Python introduced |
| **Manifest schema** | Existing JSON schema in `specs/presets/spec.md` + `scripts/validate-presets.sh` | Extension: `foundation.skills` may carry `drop` XOR `keep`, never both |
| **Runtime hooks impacted** | `scripts/new-project.sh::apply_preset_filters`, `scripts/update.sh::load_active_drop_list` + skill-copy loops | Symmetric handling of `keep`: a skill not listed is omitted from copy |
| **Detection** | `scripts/lib/preset-detect.sh` data-driven (no change needed — detect block already supported) | New preset declares a `detect` block with `allOf` combinator |
| **Tests** | Bats (`tests/*.bats`) + jq schema (`scripts/validate-presets.sh`) | Test runtime: `bash scripts/test.sh` |
| **Coverage targets** | New keep-filter behavior covered by ≥6 cases; preset covered by ≥6 cases | Anti-drift: `scripts/validate-counts.sh` |
| **Target platform** | Linux + macOS (Bats on both) | macOS is currently `skipping` in CI but must remain runnable locally |

### Constraints

- Backward compatibility: every existing preset (5) MUST continue to behave identically. `drop` semantics unchanged.
- No third-party install: the preset bundles ZERO marketplace plugins at v1 (consistent with the cautious posture of fastapi/cli-tools/homelab-proxmox/astro).
- Anti-drift: README badge `tests-N passing` MUST be bumped at every test-count change. `scripts/validate-counts.sh` must exit 0 at every commit.
- Commit pattern: `test → feat → badge` for same-domain changes; `test+feat` together for refactors; separate commits per phase boundary (per existing repo conventions).
- No project names in any artifact landing in the repo (specs, docs, commits, PR, code) — generic phrasing only.
- No Node/Python helper added. Existing `jq` + Bash toolchain.

### Expected performance

| Metric | Target |
|---|---|
| Preset overhead on install (full bootstrap) | < 100 ms |
| `--detect-only` on a directory with no detect-match | < 50 ms |
| Bats suite end-to-end (foundation) | < +5 s vs current baseline |

---

## Constitution / Conventions Check

- [x] Follows project conventions (CLAUDE.md, `.claude/rules/workflow.md`)
- [x] Consistent with existing architecture (preset manifest, data-driven detect, install/update lifecycle)
- [x] No over-engineering — `keep` support is the minimum surface change; the preset itself follows the existing pattern
- [x] Tests planned BEFORE code (TDD per `.claude/rules/tdd-enforcement.md`)
- [x] No bypass of CI gates (lint, validate-counts, validate-presets)

---

## Project Structure

### Documentation (this feature)

```
specs/preset-react-vite-spa/
├── spec.md           # Functional specification (Validated after this plan lands)
├── plan.md           # This file
├── tasks.md          # Task breakdown
```

### Source code touched

```
scripts/
├── new-project.sh           # apply_preset_filters: support keep semantics
├── update.sh                # load_active_keep_list + is_skill_kept (symmetric to drop)
├── validate-presets.sh      # Enforce drop XOR keep mutual exclusion
└── lib/
    └── preset-detect.sh     # No change expected (detect block already handled)

.claude/presets/
├── react-vite-spa.json      # NEW manifest
└── README.md                # Add row to "Available presets" table

tests/
├── presets.bats                                  # New cases: validator accepts keep, rejects drop+keep together
├── preset-detect.bats                            # No change expected
├── preset-e2e.bats                               # New @test: e2e bootstrap of react-vite-spa
├── presets-fixtures/
│   └── react-vite-spa/                           # NEW fixture dir
│       ├── .gitkeep
│       ├── vite.config.ts                        # Trigger files signal
│       └── package.json                          # Trigger depFiles signal (react-router-dom)
├── new-project-preset-filter.bats                # NEW: keep-filter integration on bootstrap
└── update-presets.bats                           # New cases: keep semantics on update

specs/presets/roadmap.md     # Shipped row + counter footer
README.md                    # tests-N badge bump
CHANGELOG.md                 # [Unreleased] Added entry
```

---

## Chosen Approach

### Architecture (filter semantics)

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│   Preset manifest (.claude/presets/<name>.json)                      │
│           │                                                          │
│           ▼ (jq)                                                     │
│   foundation.skills                                                  │
│     ├── drop[]  (used by 5 existing presets)                         │
│     OR                                                               │
│     └── keep[]  (new — used by react-vite-spa)                       │
│           │                                                          │
│           ▼                                                          │
│   Runtime helper                                                     │
│     ├── load_active_drop_list  → ACTIVE_PRESET_DROP_LIST[]           │
│     └── load_active_keep_list  → ACTIVE_PRESET_KEEP_LIST[]           │
│           │                                                          │
│           ▼                                                          │
│   Skill copy loop (new-project.sh + update.sh)                       │
│     ├── is_skill_dropped <rel>  → true ⇒ SKIP                        │
│     └── is_skill_kept    <rel>  → false ⇒ SKIP                       │
│           │                                                          │
│           ▼                                                          │
│   Target project .claude/skills/                                     │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Rationale

- **`keep` is symmetric to `drop`**, not an overhaul. Add `load_active_keep_list` + `is_skill_kept` alongside the existing helpers; the copy loop becomes `if drop_active && is_skill_dropped; SKIP; elif keep_active && ! is_skill_kept; SKIP; else COPY;`.
- **Validator enforces XOR** so a single preset cannot ship both filters and create ambiguity.
- **5 existing presets unchanged**: zero migration debt; the runtime supports both forever (cheap and explicit).
- **No new file or new global concept**: the additions sit in already-known seams (`apply_preset_filters`, `load_active_drop_list`).

### Alternatives considered

| Alternative | Why rejected |
|---|---|
| Use `drop` for the new preset (consistent with the 5 existing) | User explicitly chose `keep` after surfacing the runtime gap. Scope expansion accepted. |
| Migrate the 5 existing presets to `keep` for full consistency | Out of scope: large refactor with no behavior gain, the 5 presets already work correctly with `drop`. |
| Use `appliesToSkills` field as a different name | Adds a third concept; `drop`/`keep` is the natural binary. |
| Compute `keep` as the complement of `drop` at runtime | Loses intent: a curator's "I explicitly endorse these N skills" is not the same statement as "I exclude these M skills". |

---

## Implementation Phases

### Phase 0 — Setup

**Objective**: branch ready, baseline CI noted, no skipped pre-existing failures confused with new ones.

- [ ] T001 — Create branch `feature/preset-react-vite-spa` from `main`.
- [ ] T002 — Run `bash scripts/test.sh` to record baseline test count (currently `tests-593-passing`). Note any pre-existing flake to avoid confusion later.

**Checkpoint**: clean branch + known baseline.

### Phase 1 — Foundation: runtime `keep` filter (blocking) ⚠️

**Objective**: extend the runtime helpers to read `.foundation.skills.keep[]` symmetrically to `drop`, with validator XOR enforcement. NO new preset uses `keep` yet at this phase — the change is purely additive on the runtime + validator side.

**This phase MUST be complete before any react-vite-spa work begins.**

Sub-phases (TDD per Red-Green-Refactor):

#### 1.A — Validator: XOR enforcement

- [ ] T003 — [P] [Foundation] RED: `tests/presets.bats` — add @test asserting `validate-presets.sh` REJECTS a synthetic preset that declares BOTH `drop:` and `keep:` in `foundation.skills`. Message names the conflict.
- [ ] T004 — [P] [Foundation] RED: `tests/presets.bats` — add @test asserting `validate-presets.sh` ACCEPTS a synthetic preset with ONLY `keep:` (non-empty array).
- [ ] T005 — [P] [Foundation] RED: `tests/presets.bats` — add @test asserting `validate-presets.sh` ACCEPTS a synthetic preset with ONLY `drop:` (regression check for the 5 existing presets).
- [ ] T006 — [Foundation] GREEN: extend `scripts/validate-presets.sh` to check `(.foundation.skills.drop and .foundation.skills.keep)` is FALSE; the file pass when either is set (or neither). Update the script's help/echo text.

#### 1.B — Bootstrap: `apply_preset_filters` supports `keep`

- [ ] T007 — [P] [Foundation] RED: `tests/new-project-preset-filter.bats` (new file) — bootstrap a project against a synthetic preset whose `keep:` lists 2 skills. Assert ONLY those 2 skills are copied; every other skill is absent.
- [ ] T008 — [P] [Foundation] RED: same file — bootstrap against a synthetic preset whose `drop:` lists 2 skills (regression). Assert the 2 are absent; every other skill is present.
- [ ] T009 — [Foundation] GREEN: extend `scripts/new-project.sh::apply_preset_filters` to handle the `keep` branch. Read `.foundation.skills.keep[]` into a local array; in the skill-copy loop, skip a skill whose relative path's top component is NOT in the keep list. Maintain the `drop` branch unchanged.

#### 1.C — Update lifecycle: keep-filter persists

- [ ] T010 — [P] [Foundation] RED: `tests/update-presets.bats` — bootstrap with a synthetic `keep`-preset, then run `update --skills` and assert the keep filter still applies (no out-of-keep skill is re-added).
- [ ] T011 — [P] [Foundation] RED: same file — bootstrap with the `keep`-preset, then run `update --no-preset` and assert ALL foundation skills are re-added (filter reverses).
- [ ] T012 — [Foundation] GREEN: extend `scripts/update.sh`. Add `ACTIVE_PRESET_KEEP_LIST=()` global next to the existing `ACTIVE_PRESET_DROP_LIST=()` (`scripts/update.sh:69`). Add `load_active_keep_list` mirroring `load_active_drop_list` (`scripts/update.sh:751`). Add `is_skill_kept` mirroring `is_skill_dropped` (`scripts/update.sh:767`). In the skill-copy loop and orphan-detection paths, branch on which filter is populated. Document the XOR invariant in a header comment.
- [ ] T013 — [Foundation] REFACTOR: factor out the duplicate code between `load_active_drop_list` and `load_active_keep_list` into a single `_load_skill_list <field>` helper if (and only if) the duplication is real. Keep the public function names for readability in call sites.

#### 1.D — Foundation phase boundary commit

- [ ] T014 — [Foundation] Run `bash scripts/test.sh` parallel — expect new tests passing, no regression. Note the new test count.
- [ ] T015 — [Foundation] Run `bash scripts/lint.sh` (ShellCheck) — must be clean. Anticipate SC1010 (the same loop-var rename trick used in PR #160) and SC2034 (unused-var warnings on the new globals — `# shellcheck disable=SC2034` if needed).
- [ ] T016 — [Foundation] Bump README `tests-N` badge by the count delta from T002 baseline. Run `scripts/validate-counts.sh` — must exit 0.
- [ ] T017 — [Foundation] CHANGELOG `[Unreleased]` — Added entry: "Runtime support for `keep`-style skills filter in preset manifests (`foundation.skills.keep[]`), mutually exclusive with the existing `drop[]` form. The 5 shipped presets continue to use `drop` unchanged."

**Checkpoint**: runtime supports both filter forms. 5 existing presets unaffected. Test suite green. Validator enforces XOR.

### Phase 2 — User Story 1 (P1) 🎯 — install with the right scope

**Objective**: a developer can install the foundation against a React Vite SPA target via `--preset react-vite-spa` and receive a filtered foundation honoring the keep list.

#### Tests for US-1 (TDD — write first, must FAIL before implementation)

- [ ] T018 — [P] [US-1] RED: `tests/presets.bats` — new @test: `react-vite-spa.json` exists and is valid JSON.
- [ ] T019 — [P] [US-1] RED: same file — @test asserting required fields: `name = react-vite-spa`, `status = maintainer-vouched`, non-empty `description`, non-empty `appliesToTypes`.
- [ ] T020 — [P] [US-1] RED: same file — @test asserting `foundation.skills.keep[]` is a non-empty array AND `foundation.skills.drop` is absent (preset uses the new keep form, XOR honored).
- [ ] T021 — [P] [US-1] RED: same file — @test asserting `outOfScope[]` has ≥4 entries and `relatedPresetsWanted[]` has ≥3 entries.
- [ ] T022 — [P] [US-1] RED: same file — @test asserting `marketplacePlugins == []` and `recommendedVendorSkills | length == 4`.
- [ ] T023 — [P] [US-1] RED: `tests/preset-e2e.bats` — new @test: `e2e_bootstrap react-vite-spa` succeeds; produces `.claude/`; every hook referenced in `settings.json` exists on disk (drift-guard pattern from PR #160).
- [ ] T024 — [P] [US-1] RED: `tests/new-project-preset-filter.bats` — bootstrap with `--preset react-vite-spa` against a fresh dir; assert each skill in the keep list is present AND `dev-flutter`, `ops-mobile-release`, `ops-proxmox`, `ops-opnsense`, `ops-infra-code`, `data-pipeline` are absent.

#### US-1 implementation

- [ ] T025 — [US-1] GREEN: write `.claude/presets/react-vite-spa.json` with the manifest:
  - `name: "react-vite-spa"`, `displayName: "React Vite SPA"`, `status: "maintainer-vouched"`, `version: "1.0.0"`
  - `description` (2–3 lines): names IN (React + Vite + React Router + i18next + Tanstack Query + Tailwind as the typical add-on stack) and OUT (no SSR/RSC, no SSG-first, no opinionated state lib). Includes the Capacitor informational note (compatible mobile wrap pattern, no Capacitor-specific tooling bundled). NO project names referenced.
  - `appliesToTypes: ["react", "fullstack"]`
  - `detect: {combinator: "allOf", files: ["vite.config.ts","vite.config.js","vite.config.mjs"], depFiles: [{path: "package.json", contains: "\"react-router-dom\""}]}`
  - `foundation.skills.keep: [...]` — the curated keep list (see T026 for content)
  - `marketplacePlugins: []`
  - `recommendedVendorSkills`: the 4 audit-validated entries (vercel-labs/agent-skills always, frontend-design always, shadcn-ui conditional, lingui conditional)
  - `defaults`: `ci: true, hooks: true, mcp: false, docker: false, designStyle: "editorial"`
  - `outOfScope`: ≥4 items aligned with spec
  - `relatedPresetsWanted: ["sveltekit", "vue-nuxt", "remix", "react-native"]`
- [ ] T026 — [US-1] Determine the exact keep list (read every foundation skill under `.claude/skills/`, mark in/out per the spec rationale). Expected ~25–35 kept skills out of the foundation total. Document the rationale in a comment at the top of the manifest if useful.

**Checkpoint**: US-1 functional. The preset installs end-to-end with the keep filter applied. All US-1 tests pass.

### Phase 3 — User Story 2 (P1) — detection works

**Objective**: a developer running `claude-base init` without `--preset` against a matching project sees `react-vite-spa` suggested.

#### Tests for US-2 (TDD)

- [ ] T027 — [P] [US-2] RED: `tests/preset-detect.bats` — @test: against the paired fixture `tests/presets-fixtures/react-vite-spa/`, the detection rule MATCHES.
- [ ] T028 — [P] [US-2] RED: same file — @test: against the `astro` fixture, `react-vite-spa` does NOT match (Vite present but no React Router).
- [ ] T029 — [P] [US-2] RED: same file — @test: against the `nextjs` fixture, `react-vite-spa` does NOT match (no Vite config).
- [ ] T030 — [P] [US-2] RED: same file — @test: drift-guard: if `react-router-dom` is removed from the fixture's `package.json`, detection fails (the rule's depFiles signal is load-bearing).

#### US-2 implementation

- [ ] T031 — [US-2] Create `tests/presets-fixtures/react-vite-spa/` with:
  - `.gitkeep`
  - `vite.config.ts` — minimal valid Vite config (single line export of `defineConfig({})`), enough to trip the `files` signal.
  - `package.json` — `name: "fixture-react-vite-spa"`, `private: true`, `dependencies: {"react": "^19.0.0", "react-dom": "^19.0.0", "react-router-dom": "^6.x"}`.
- [ ] T032 — [US-2] Re-run `tests/preset-detect.bats` — all 4 new cases pass. No existing case regresses.

**Checkpoint**: US-2 functional. Detection works on the paired fixture; rejection works on adjacent stacks.

### Phase 4 — User Story 3 (P2) — filter persists across update lifecycle

**Objective**: an existing react-vite-spa project, when updated, retains its filter.

This phase mostly EXERCISES Phase 1's foundation work against the new preset. The mechanism is already implemented in Phase 1; here we add the integration tests.

#### Tests for US-3

- [ ] T033 — [P] [US-3] RED: `tests/update-presets.bats` — bootstrap with `--preset react-vite-spa`, delete a kept skill manually, run `update --skills`, assert the kept skill is re-added AND no non-kept skill is added.
- [ ] T034 — [P] [US-3] RED: same file — bootstrap with `--preset react-vite-spa`, run `update --no-preset`, assert every foundation skill is present (filter reversed).
- [ ] T035 — [P] [US-3] RED: same file — bootstrap with `--preset react-vite-spa`, run `update --dry-run --skills`, assert dry-run output reports the skills that WOULD be skipped under "Skip (preset filter)".

#### US-3 implementation

- [ ] T036 — [US-3] GREEN: no new code expected — Phase 1's `is_skill_kept` and `load_active_keep_list` already drive the behavior. If a test fails, fix Phase 1's helpers (this is a Phase 1 gap, not a Phase 4 task).

**Checkpoint**: US-3 functional. The keep filter survives the full project lifecycle (init → update).

### Phase 5 — User Story 4 (P2) — vendor skills recommended at end of install

**Objective**: the install output names the 4 recommended vendor skills with the right conditions and indicator markers.

This phase mostly EXERCISES the existing `print_recommended_vendor_skills` lib (shipped in PR #166).

#### Tests for US-4

- [ ] T037 — [P] [US-4] RED: `tests/preset-recommendations.bats` — given the new preset, the output contains "Always pair with this preset" followed by `vercel-labs/agent-skills` AND `frontend-design@claude-plugins-official`.
- [ ] T038 — [P] [US-4] RED: same file — output contains "Add if your project uses these tools" followed by `shadcn-ui/ui (skills/shadcn)` AND `lingui/skills`.

#### US-4 implementation

- [ ] T039 — [US-4] GREEN: no new code expected — manifest entries from T025 already drive the output. If the format is wrong, fix the manifest, not the lib.

**Checkpoint**: US-4 functional.

### Phase 6 — User Story 5 (P2) — README + roadmap reflect the new preset

**Objective**: public docs acknowledge the 6th preset.

- [ ] T040 — [P] [US-5] Update `.claude/presets/README.md`: add a row for `react-vite-spa` in the "Available presets" table.
- [ ] T041 — [P] [US-5] Update `specs/presets/roadmap.md`:
  - Add a row to the "Shipped (maintainer-vouched)" table.
  - Bump the "Quick reference (count)" footer: JS web frameworks `2` → `3`; total `5 shipped` → `6 shipped`; `22+ named` → `21+ named`.
  - Move `react-vite-spa` out of any implicit "wanted" list if it appears.
- [ ] T042 — [P] [US-5] Update `CHANGELOG.md` `[Unreleased]`:
  - Added: "6th maintainer-vouched preset `react-vite-spa` — React Single-Page Apps on Vite + React Router."
  - Added: "Runtime support for `keep`-style skills filter (see Phase 1)."

**Checkpoint**: docs reflect reality. `validate-counts.sh` still green.

### Phase 7 — User Story 6 (P3) — multi-match disambiguation

**Objective**: a project matching both `nextjs` and `react-vite-spa` triggers the existing multi-match flow.

This phase mostly EXERCISES existing US-7 logic from `presets-detection-and-e2e/` against the new preset.

- [ ] T043 — [P] [US-6] RED: `tests/preset-detect.bats` — construct a fixture with both `next.config.js` AND `vite.config.ts` AND a `package.json` containing both `"next"` and `"react-router-dom"`. Assert `scan_presets` returns BOTH `nextjs` and `react-vite-spa`.
- [ ] T044 — [P] [US-6] RED: `tests/new-project.bats` (or wherever the multi-match prompt lives) — when running non-interactive bootstrap with no `--preset` against the hybrid fixture, the exit is non-zero with a message instructing the user to pass `--preset` or `--no-preset`.
- [ ] T045 — [US-6] GREEN: no new code expected — existing multi-match flow handles this. If a test fails, fix the multi-match path.

**Checkpoint**: US-6 functional. Hybrid projects trigger explicit disambiguation.

### Phase 8 — Polish & validation

- [ ] T046 — [P] Run `bash scripts/test.sh` parallel; record runtime vs baseline. Must stay under the project's overhead budget (< +5 s).
- [ ] T047 — [P] Run `bash scripts/lint.sh` (ShellCheck) — clean. Anticipate SC1010/SC2034 from new globals.
- [ ] T048 — [P] Run `bash scripts/validate-presets.sh` — clean on all 6 manifests + the new XOR rule.
- [ ] T049 — Run `bash scripts/validate-counts.sh` — must exit 0 (README badge in sync with `tests-N`).
- [ ] T050 — Final CHANGELOG read — both entries (preset + keep filter) present and accurate.
- [ ] T051 — Mark `specs/preset-react-vite-spa/spec.md` Status: Draft → Validated.
- [ ] T052 — Run `/qa:qa-loop "score 90"` to confirm no quality gap.
- [ ] T053 — Open PR. Anticipate macOS portability concerns (the e2e test that boots the bootstrap runs on macos-latest in CI; ensure no `timeout`/`grep -P` regressions). Commit shape: see "Commit strategy" below.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| `keep` runtime extension breaks one of the 5 existing presets (regression) | High | Medium | Phase 1.B/1.C tests explicitly include `drop`-preset regression cases (T008, T011). E2E test in PR #160 covers all 5 presets — re-run it after Phase 1. |
| ShellCheck SC1010 / SC2034 on new globals (already seen on PR #160) | Low | High | Anticipated. Either rename loop vars (`fi` → `idx` as PR #160 did) or `# shellcheck disable=SC2034` on the new global next to the existing one. |
| Detection rule mis-fires on hybrid projects (Next.js + Vite legacy) | Medium | Low | T043 covers exactly this. Existing US-7 multi-match flow surfaces it explicitly. |
| Keep list omits a skill that should have been kept (or includes a skill that should not be there) | Medium | Medium | T026 forces an exhaustive review of `.claude/skills/`. Cross-check against the 2 production stacks the maintainer knows by heart. Test asserts both presence (kept) and absence (not kept). |
| macOS-specific test failure (BSD vs GNU coreutils) | Medium | Medium | Avoid `timeout` and `grep -P` in new tests; rely on portable Bash + `jq` only. Per the lesson from PR #161 (`1a2210a fix(tests): drop timeout in interactive menu test for macOS portability`). |
| Vendor-skill URL or marketplace ID drift (e.g. shadcn-ui repo rename) | Low | Low | The audit pilot date-stamps the snapshot; URL drift is handled by the existing quarterly review pattern. |
| Scope creep: temptation to migrate the 5 existing presets to `keep` for consistency | Medium | Medium | Hard scope line in Phase 1: migration is OUT. The 5 presets keep `drop` forever; the runtime supports both. Stated explicitly in `outOfScope` of the spec. |
| Phase 1 (keep runtime) takes longer than expected and bleeds into Phase 2 | Low | Medium | The phases are decomposable: Phase 1 can ship as its own PR if Phase 2 stalls. Coordinate commit boundary at T017 (Phase 1 end). |

---

## Dependencies and Execution Order

### Dependencies between phases

```
Phase 0 (Setup)
   │
   ▼
Phase 1 (Foundation: keep runtime)  ◄──── BLOCKS Phases 2-7
   │
   ├──▶ Phase 2 (US-1: install with right scope)  🎯 MVP
   │
   ├──▶ Phase 3 (US-2: detection)  [can start after Phase 1]
   │
   ├──▶ Phase 4 (US-3: filter across lifecycle)  [needs Phase 2's manifest]
   │
   ├──▶ Phase 5 (US-4: vendor skills printed)  [needs Phase 2's manifest]
   │
   ├──▶ Phase 6 (US-5: README + roadmap)  [needs Phase 2's manifest]
   │
   └──▶ Phase 7 (US-6: multi-match)  [needs Phase 2's manifest]

All ──▶ Phase 8 (Polish & validation)
```

### Parallelizable tasks

- Within Phase 1.A: T003, T004, T005 in parallel (different @tests, same file — Bats handles concurrent additions fine).
- Within Phase 1.B: T007 and T008 in parallel.
- Within Phase 2: T018–T024 all `[P]` (different @tests).
- Phases 3, 4, 5, 6 in parallel after Phase 2 completes.

---

## Commit Strategy

Atomic commits following the repo pattern (test → feat → badge):

**Phase 1.A — Validator XOR**
1. `test(presets): assert validator rejects drop+keep mutual exclusion (T003-T005)`
2. `feat(presets): enforce drop XOR keep in validate-presets.sh (T006)`

**Phase 1.B — Bootstrap keep**
3. `test(new-project): cover keep-filter on bootstrap (T007-T008)`
4. `feat(new-project): apply keep-style preset filter symmetrically to drop (T009)`

**Phase 1.C — Update keep**
5. `test(update): cover keep-filter on update + reversal (T010-T011)`
6. `feat(update): support keep-style preset filter across the update lifecycle (T012)`
7. _(optional refactor commit if T013 yields real dedup)_ `refactor(update): factor skill-list loader for drop/keep symmetry (T013)`

**Phase 1.D — Foundation badge + CHANGELOG**
8. `chore(readme): bump tests-N badge for keep-filter additions (T016)`
9. `docs(changelog): add keep-filter runtime support entry (T017)`

**Phase 2 — Preset manifest**
10. `test(presets): assert react-vite-spa manifest shape + e2e (T018-T024)`
11. `feat(presets): add react-vite-spa preset (6th maintainer-vouched) (T025-T026)`

**Phase 3 — Detection**
12. `test(presets): assert react-vite-spa detection rule + non-match (T027-T030)`
13. `feat(presets): add react-vite-spa fixture for detect drift-guard (T031)`

**Phase 4 — Update lifecycle (exerciser)**
14. `test(update-presets): cover react-vite-spa keep filter across lifecycle (T033-T035)`

**Phase 5 — Vendor skills (exerciser)**
15. `test(preset-recommendations): cover react-vite-spa vendor skill output (T037-T038)`

**Phase 6 — Docs**
16. `docs(presets): add react-vite-spa to README + roadmap + changelog (T040-T042)`

**Phase 7 — Multi-match (exerciser)**
17. `test(presets): cover react-vite-spa multi-match disambiguation (T043-T044)`

**Phase 8 — Polish**
18. `chore(readme): bump tests-N badge for react-vite-spa additions (T049)`
19. `docs(specs): mark preset-react-vite-spa spec as Validated (T051)`

Total: ~17–19 atomic commits.

---

## Validation Criteria

### Gate 1 — Before starting implementation
- [x] Spec approved (see clarification resolutions)
- [x] Plan reviewed by user
- [ ] Branch `feature/preset-react-vite-spa` ready

### Gate 2 — Before each merge / phase boundary
- [ ] All new tests pass
- [ ] No existing test regressed
- [ ] ShellCheck clean on touched scripts
- [ ] README badge in sync (`scripts/validate-counts.sh` exits 0)

### Gate 3 — Before PR
- [ ] All 9 success criteria from spec verified (CS-001 to CS-009)
- [ ] `bash scripts/validate-presets.sh` clean on all 6 manifests
- [ ] CHANGELOG entries for BOTH keep-filter runtime AND the new preset
- [ ] Spec status flipped to Validated
- [ ] `/qa:qa-loop "score 90"` passed

---

## Notes

- The user picked `keep` over `drop` knowing the runtime gap. The plan honors that decision by treating the runtime extension as a phase 0/1 prerequisite of the preset itself, shipped in the same branch.
- Migration of the 5 existing presets to `keep` is explicitly OUT of scope. The runtime supports both forms indefinitely.
- The detection rule uses `allOf` strict (Vite config AND react-router-dom). Projects using TanStack Router or similar must pass `--preset react-vite-spa` explicitly; broadening the detection is a future iteration.
- No project names appear in any artifact landing in the repo (per `feedback_no_project_names` memory rule).

---

**Version**: 1.0 | **Created**: 2026-05-13
