# Tasks: react-vite-spa preset (6th maintainer-vouched)

**Input**: Design documents from `specs/preset-react-vite-spa/`
**Prerequisites**: `spec.md` (Validated after this work), `plan.md`

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: Can be executed in parallel (different files, no dependencies)
- **[Foundation]**: Phase 1 prerequisite, blocks every user story
- **[US?]**: Associated user story (for traceability)
- Include exact file paths in descriptions

---

## Phase 0 — Setup

**Goal**: branch ready, baseline noted.

- [ ] T001 — Create branch `feature/preset-react-vite-spa` from `main`. Working tree clean.
- [ ] T002 — Run `bash scripts/test.sh` to record baseline test count (currently 593). Note any pre-existing flake so we don't confuse it with a new failure.

---

## Phase 1 — Foundation: runtime `keep` filter (blocking) ⚠️

**Goal**: extend the runtime helpers + validator so that a preset can declare `foundation.skills.keep[]` instead of `drop[]`. The 5 existing presets continue to behave identically.

**⚠️ CRITICAL**: No user story can start before this phase is finished.

### 1.A — Validator XOR enforcement

Tests for the validator (TDD — write first, must FAIL before implementation):

- [ ] T003 — [P] [Foundation] `tests/presets.bats` — new @test asserting `scripts/validate-presets.sh` REJECTS a synthetic preset declaring BOTH `drop:` and `keep:` in `foundation.skills`. Assert exit code non-zero AND stderr names the conflict (e.g. "drop and keep are mutually exclusive").
- [ ] T004 — [P] [Foundation] `tests/presets.bats` — new @test asserting the validator ACCEPTS a synthetic preset with ONLY `keep: ["dev-tdd"]` (non-empty array). Exit code 0.
- [ ] T005 — [P] [Foundation] `tests/presets.bats` — new @test asserting the validator ACCEPTS a synthetic preset with ONLY `drop: ["dev-flutter"]` (regression check for the 5 existing presets).

Validator implementation:

- [ ] T006 — [Foundation] Modify `scripts/validate-presets.sh`:
  - For each preset, check `jq -e '.foundation.skills | (has("drop") and has("keep"))' <file>` returns true → fail with explicit error.
  - When only `keep:` is set, assert it is a non-empty array of strings (mirror the existing `drop:` check).
  - Update the script's help text to mention the new field.

### 1.B — Bootstrap: `apply_preset_filters` supports `keep`

Tests for bootstrap (TDD):

- [ ] T007 — [P] [Foundation] `tests/new-project-preset-filter.bats` (new file): bootstrap a project against a synthetic preset whose `keep: ["dev-tdd", "dev-refactor"]`. Assert AFTER install that `dev-tdd` and `dev-refactor` exist under `.claude/skills/`, and EVERY OTHER skill from the foundation is absent.
- [ ] T008 — [P] [Foundation] same file: bootstrap against a synthetic preset whose `drop: ["dev-flutter"]` (regression). Assert `dev-flutter` is absent; assert at least 3 other skills are present.

Bootstrap implementation:

- [ ] T009 — [Foundation] Modify `scripts/new-project.sh::apply_preset_filters` (around line 1163):
  - After the existing `drop` handling, add a `keep` branch: read `.foundation.skills.keep[]` into a local array `keep_list`. In the skill-copy loop, skip a skill whose top-level directory name is NOT in `keep_list`.
  - Document the XOR invariant in a `#` comment block above the function.
  - Do NOT touch the `drop` branch logic.

### 1.C — Update lifecycle: keep-filter persists

Tests for update (TDD):

- [ ] T010 — [P] [Foundation] `tests/update-presets.bats` — new @test: bootstrap with a synthetic `keep`-preset (e.g. created on the fly under `$TEST_DIR/presets-dir`), manually delete one of the kept skills from the project, run `update --skills $TEST_DIR/proj`, assert the kept skill is re-added AND non-kept skills are STILL absent.
- [ ] T011 — [P] [Foundation] same file: bootstrap with the `keep`-preset, run `update --no-preset $TEST_DIR/proj`, assert ALL foundation skills are now present (filter reverses).

Update implementation:

- [ ] T012 — [Foundation] Modify `scripts/update.sh`:
  - Add global `ACTIVE_PRESET_KEEP_LIST=()` next to `ACTIVE_PRESET_DROP_LIST=()` at line 69.
  - Add function `load_active_keep_list()` mirroring `load_active_drop_list()` (line 751), reading `.foundation.skills.keep[]?`.
  - Add function `is_skill_kept <rel_path>` mirroring `is_skill_dropped` (line 767). Returns 0 (true) if the relative path's top component IS in the keep list OR the keep list is empty (no-keep means no filter).
  - In `resolve_active_preset()` (line 701): after calling `load_active_drop_list`, also call `load_active_keep_list`. Both populate; only one is non-empty per preset (XOR enforced by validator).
  - In the skill-copy loop and `detect_orphan_files`/`detect_all_orphans` paths: branch based on which list is populated. If keep list is non-empty: skip when `! is_skill_kept`. Otherwise fall back to the existing `is_skill_dropped` behavior.

Refactor (optional):

- [ ] T013 — [Foundation] If T009 and T012 produce real duplication between `load_active_drop_list` and `load_active_keep_list`, factor a `_load_skill_field <jq_path> <out_array_name>` helper. KEEP the public function names for readability at call sites. If duplication is < 5 lines, SKIP this task.

### 1.D — Foundation phase boundary

- [ ] T014 — [Foundation] Run `bash scripts/test.sh` parallel. Expect new tests passing, no regression on the 593 existing tests. Note the delta.
- [ ] T015 — [Foundation] Run `bash scripts/lint.sh`. Anticipate ShellCheck SC1010 (loop var same as function name — rename the loop var like PR #160 did) and SC2034 (unused global warning on the new array — `# shellcheck disable=SC2034` if needed, next to the existing one).
- [ ] T016 — [Foundation] Bump README `tests-N passing` badge by the delta from T014. Run `scripts/validate-counts.sh` — must exit 0. Commit separately as `chore(readme): bump tests-N badge for keep-filter additions`.
- [ ] T017 — [Foundation] `CHANGELOG.md` `[Unreleased]` Added section: "Runtime support for `keep`-style skills filter in preset manifests (`foundation.skills.keep[]`), mutually exclusive with `drop[]`. The 5 shipped presets continue to use `drop` unchanged." Commit as `docs(changelog): add keep-filter runtime support entry`.

**Checkpoint Phase 1**: Runtime supports both filter forms. 5 existing presets unaffected. CHANGELOG entry in place. README badge in sync. ShellCheck clean.

---

## Phase 2 — User Story 1 (P1) 🎯 MVP — install with the right scope

**Goal**: a developer can install the foundation against a React Vite SPA target via `--preset react-vite-spa` and receive a filtered foundation honoring the keep list.

**Independent test**: `./scripts/new-project.sh --preset react-vite-spa --dry-run /tmp/test-spa` prints the filtered skill list with kept skills only.

### Tests for US-1 (TDD — write first, must FAIL before implementation)

- [ ] T018 — [P] [US-1] `tests/presets.bats` — @test "presets: react-vite-spa.json exists and is valid JSON".
- [ ] T019 — [P] [US-1] `tests/presets.bats` — @test "presets: react-vite-spa.json has required fields":
  - `name == "react-vite-spa"`
  - `status == "maintainer-vouched"`
  - `description` length ≥ 80 chars
  - `appliesToTypes | length >= 1`
  - `version == "1.0.0"`
- [ ] T020 — [P] [US-1] `tests/presets.bats` — @test "presets: react-vite-spa uses keep XOR drop":
  - `.foundation.skills.keep` exists AND is a non-empty array of strings
  - `.foundation.skills.drop` does NOT exist
- [ ] T021 — [P] [US-1] `tests/presets.bats` — @test "presets: react-vite-spa has honest outOfScope and relatedPresetsWanted":
  - `.outOfScope | length >= 4`
  - `.relatedPresetsWanted | length >= 3`
- [ ] T022 — [P] [US-1] `tests/presets.bats` — @test "presets: react-vite-spa bundles no marketplace plugins at v1 and 4 vendor recommendations":
  - `.marketplacePlugins == []`
  - `.recommendedVendorSkills | length == 4`
  - Two entries have `condition == "always"`
  - Two entries have a conditional `condition`
- [ ] T023 — [P] [US-1] `tests/preset-e2e.bats` — @test "preset-e2e: react-vite-spa bootstraps, validates, and ships every referenced hook":
  - `target=$(e2e_bootstrap react-vite-spa)`
  - Assert install exit 0
  - Assert `.claude/` exists in target
  - For each hook referenced in `<target>/.claude/settings.json`, assert the hook script file exists on disk (drift-guard from PR #160).
- [ ] T024 — [P] [US-1] `tests/new-project-preset-filter.bats` — @test "new-project-preset-filter: react-vite-spa applies keep filter":
  - Bootstrap with `--preset react-vite-spa` against a fresh dir.
  - Assert EACH skill in the keep list is present under `<target>/.claude/skills/<skill>/`.
  - Assert these are ABSENT: `dev-flutter`, `ops-mobile-release`, `ops-proxmox`, `ops-opnsense`, `ops-infra-code`, `data-pipeline`.

### US-1 implementation

- [ ] T025 — [US-1] Write `.claude/presets/react-vite-spa.json`:
  - `$schema`, `name`, `displayName`, `description`, `version: "1.0.0"`, `status: "maintainer-vouched"`, `author`
  - `appliesToTypes: ["react", "fullstack"]`
  - `detect`: `{"combinator": "allOf", "files": ["vite.config.*"], "depFiles": [{"path":"package.json","contains":"\"react-router-dom\""}]}` — single glob entry; each item in `files[]` is an independent signal under `allOf`, so listing the three explicit extensions would have required every variant to coexist (broken for real projects).
  - `foundation.skills.keep: [...]` — exhaustive list from T026
  - `marketplacePlugins: []`
  - `recommendedVendorSkills`:
    - `{"id":"vercel-labs/agent-skills","url":"https://github.com/vercel-labs/agent-skills","rationale":"Canonical React patterns from Vercel Engineering (valid outside Next.js for SPA work)","condition":"always"}`
    - `{"id":"frontend-design@claude-plugins-official","url":"https://claude.com/plugins/frontend-design","rationale":"Anthropic's official UI design plugin (avoid generic Inter+purple aesthetic)","condition":"always"}`
    - `{"id":"shadcn-ui/ui (skills/shadcn)","url":"https://github.com/shadcn-ui/ui/tree/main/skills/shadcn","rationale":"shadcn/ui CLI v4, Radix + Base UI primitives, theming patterns","condition":"if using shadcn/ui"}`
    - `{"id":"lingui/skills","url":"https://github.com/lingui/skills","rationale":"Lingui i18n patterns for React (sourced from specs/marketplace-audit/dev-skills-pilot)","condition":"if using Lingui for i18n"}`
  - `defaults: {"ci": true, "hooks": true, "mcp": false, "docker": false, "designStyle": "editorial"}`
  - `outOfScope` (≥4):
    - "Server-side rendering or React Server Components — use the `nextjs` preset"
    - "Static-content / blog / marketing sites — use the `astro` preset"
    - "Native mobile distribution beyond a Capacitor wrap — community contributions wanted for `flutter`, `swift`, `react-native`"
    - "Opinionated state management library choice (Redux/Zustand/Jotai) — the React community has not converged; preset stays neutral"
    - "Opinionated data-fetching library choice (TanStack Query/SWR/Apollo) — preset stays neutral"
    - "Build-tool alternatives (Rollup, esbuild, Rspack, Turbopack) — Vite is the explicit target"
  - `relatedPresetsWanted: ["sveltekit", "vue-nuxt", "remix", "react-native"]`
- [ ] T026 — [US-1] Determine the exhaustive keep list. List every entry under `.claude/skills/` (use `ls .claude/skills/`), then for each skill decide IN/OUT against the spec rationale:
  - **IN** (target ~25–35 skills): work-*, dev-tdd, dev-refactor, dev-component, dev-test, dev-testing-setup, dev-debug, dev-document, dev-ai-integration, dev-error-handling, dev-i18n, dev-graphql, dev-auth, dev-frontend-design, dev-shadcn, dev-react-perf, dev-prompt-engineering, dev-rag, qa-* (all UI-relevant), growth-* (most), doc-*, legal-*, biz-*, data-* (data-analytics ok, data-modeling marginal), ops-ci, ops-deploy, ops-monitoring, ops-docker, ops-deps, ops-env, ops-secrets-management, ops-database, ops-vercel, ops-vps, ops-rollback, ops-release, ops-health
  - **OUT** (the 6 non-applicable): dev-flutter, ops-mobile-release, ops-proxmox, ops-opnsense, ops-infra-code, data-pipeline
  - **Borderline** (decide explicitly): dev-nextjs (OUT — distinct framework), ops-k8s (decision: IN as ops-knowledge for advanced deploys, but borderline), dev-trpc/dev-graphql (IN — common with React SPA backends), dev-supabase (IN — common backend choice), dev-prisma (IN — common backend choice)
  - Validate the final list against the keep-filter test (T024): every kept skill must be present after install, every non-kept must be absent.

**Checkpoint Phase 2**: US-1 functional. The 7 US-1 tests (T018–T024) all pass. Preset installs end-to-end with the keep filter applied.

---

## Phase 3 — User Story 2 (P1) — detection works

**Goal**: a developer running `claude-base init` without `--preset` against a matching project sees `react-vite-spa` suggested.

**Independent test**: `./scripts/new-project.sh --detect-only /path/to/react-vite-spa-project` reports the match.

### Tests for US-2 (TDD)

- [ ] T027 — [P] [US-2] `tests/preset-detect.bats` — @test "preset-detect: react-vite-spa MATCHES its paired fixture":
  - Point `PRESETS_DIR` at the real `.claude/presets/`.
  - Run `scan_presets` against `tests/presets-fixtures/react-vite-spa/`.
  - Assert output contains `react-vite-spa`.
- [ ] T028 — [P] [US-2] `tests/preset-detect.bats` — @test "preset-detect: react-vite-spa does NOT match the astro fixture":
  - Run `scan_presets` against `tests/presets-fixtures/astro/`.
  - Assert output does NOT contain `react-vite-spa`.
- [ ] T029 — [P] [US-2] `tests/preset-detect.bats` — @test "preset-detect: react-vite-spa does NOT match the nextjs fixture":
  - Run `scan_presets` against `tests/presets-fixtures/nextjs/`.
  - Assert output does NOT contain `react-vite-spa`.
- [ ] T030 — [P] [US-2] `tests/preset-detect.bats` — @test "preset-detect: drift-guard — removing react-router-dom from fixture breaks detection":
  - Copy fixture to `$TEST_DIR/proj`, edit `package.json` to remove `react-router-dom`.
  - Run `scan_presets` against the modified copy.
  - Assert output does NOT contain `react-vite-spa` (depFiles signal is load-bearing).

### US-2 implementation

- [ ] T031 — [US-2] Create `tests/presets-fixtures/react-vite-spa/`:
  - `.gitkeep`
  - `vite.config.ts`:
    ```ts
    // Minimal Vite config — fixture for tests/preset-detect detection rules.
    import { defineConfig } from 'vite';
    export default defineConfig({});
    ```
  - `package.json`:
    ```json
    {
      "name": "fixture-react-vite-spa",
      "version": "0.0.0",
      "private": true,
      "dependencies": {
        "react": "^19.0.0",
        "react-dom": "^19.0.0",
        "react-router-dom": "^6.0.0",
        "vite": "^5.0.0"
      }
    }
    ```
- [ ] T032 — [US-2] Run `bats tests/preset-detect.bats`. All 4 new cases pass. No existing case regresses.

**Checkpoint Phase 3**: US-2 functional. Detection works on the paired fixture; rejects astro / nextjs / fixtures missing the router signal.

---

## Phase 4 — User Story 3 (P2) — filter persists across update lifecycle

**Goal**: an existing `react-vite-spa` project, when updated, retains its filter.

**Independent test**: bootstrap with `--preset react-vite-spa`, delete a kept skill, run `update --skills`, the kept skill comes back AND non-kept skills do not appear.

### Tests for US-3 (TDD)

- [ ] T033 — [P] [US-3] `tests/update-presets.bats` — @test "update-presets: react-vite-spa keep filter survives update":
  - Bootstrap `--preset react-vite-spa` into `$TEST_DIR/proj`.
  - `rm -rf $TEST_DIR/proj/.claude/skills/dev-tdd` (assuming dev-tdd is in the keep list).
  - Run `update --skills $TEST_DIR/proj`.
  - Assert `dev-tdd` is re-added.
  - Assert `dev-flutter` is STILL absent (filter held).
- [ ] T034 — [P] [US-3] `tests/update-presets.bats` — @test "update-presets: react-vite-spa --no-preset disables filter":
  - Bootstrap `--preset react-vite-spa` into `$TEST_DIR/proj`.
  - Run `update --no-preset --skills $TEST_DIR/proj`.
  - Assert `dev-flutter` is now present (filter reversed).
- [ ] T035 — [P] [US-3] `tests/update-presets.bats` — @test "update-presets: react-vite-spa dry-run lists skipped non-kept skills":
  - Bootstrap `--preset react-vite-spa` into `$TEST_DIR/proj`.
  - Run `update --preset react-vite-spa --dry-run --skills $TEST_DIR/proj`.
  - Assert output contains `[DRY-RUN] Skip (preset filter): dev-flutter` (or whatever the existing dry-run wording is from US-5 of `presets-update-aware`).

### US-3 implementation

- [ ] T036 — [US-3] No new code expected. Phase 1's `is_skill_kept` already drives this behavior. If a test fails, the bug is in Phase 1 — fix there.

**Checkpoint Phase 4**: US-3 functional. Tests T033–T035 green.

---

## Phase 5 — User Story 4 (P2) — vendor skills recommended at end of install

**Goal**: the install output names the 4 recommended vendor skills with the right conditions and indicator markers.

**Independent test**: bootstrap with `--preset react-vite-spa`, the install output ends with the 4 recommendations grouped by condition.

### Tests for US-4 (TDD)

- [ ] T037 — [P] [US-4] `tests/preset-recommendations.bats` — @test "preset-recommendations: react-vite-spa prints always-pair entries":
  - Mock or call the printer against the new manifest.
  - Assert output contains the section header "Always pair with this preset".
  - Assert output contains `vercel-labs/agent-skills` AND `frontend-design@claude-plugins-official`.
- [ ] T038 — [P] [US-4] `tests/preset-recommendations.bats` — @test "preset-recommendations: react-vite-spa prints conditional entries":
  - Same setup.
  - Assert output contains "Add if your project uses these tools".
  - Assert output contains `shadcn-ui/ui (skills/shadcn)` AND `lingui/skills`.

### US-4 implementation

- [ ] T039 — [US-4] No new code expected. Manifest from T025 drives the output. If format is wrong, fix the manifest, not the lib.

**Checkpoint Phase 5**: US-4 functional. Tests T037–T038 green.

---

## Phase 6 — User Story 5 (P2) — public docs reflect the new preset

**Goal**: README + roadmap + CHANGELOG acknowledge the 6th preset.

- [ ] T040 — [P] [US-5] `.claude/presets/README.md`:
  - Add row in "Available presets (this repo)" table:
    `| react-vite-spa | maintainer-vouched | React SPA on Vite + React Router (no SSR, no SSG) |`
  - Update the introductory sentence "The 5 maintainer-vouched presets cover the maintainer's actual production usage" → "The 6 maintainer-vouched presets cover the maintainer's actual production usage".
- [ ] T041 — [P] [US-5] `specs/presets/roadmap.md`:
  - Add row to "Shipped (maintainer-vouched)" table:
    `| react-vite-spa | React SPA on Vite + React Router + Tanstack Query + i18next (UI stack composable) | v1.39.0 (this PR) |`
  - Update "Quick reference (count)":
    - JS web frameworks row: `2 (nextjs, astro)` → `3 (nextjs, astro, react-vite-spa)`
    - Total: `5 shipped. 22+ named` → `6 shipped. 21+ named`
- [ ] T042 — [P] [US-5] `CHANGELOG.md` `[Unreleased]` Added section (note T017 already added the keep-filter entry; this adds the preset entry below it):
  `Added: 6th maintainer-vouched preset \`react-vite-spa\` — React Single-Page Apps built on Vite + React Router. Uses the new \`keep\`-style filter (whitelist) introduced earlier in this release. Bundles ZERO marketplace plugins at v1; ships with 4 audit-validated vendor-skill recommendations (vercel-labs, frontend-design, shadcn-ui, lingui).`

**Checkpoint Phase 6**: docs in sync.

---

## Phase 7 — User Story 6 (P3) — multi-match disambiguation

**Goal**: a project matching both `nextjs` and `react-vite-spa` triggers explicit disambiguation.

### Tests for US-6 (TDD)

- [ ] T043 — [P] [US-6] `tests/preset-detect.bats` — @test "preset-detect: hybrid project matches both nextjs and react-vite-spa":
  - Construct a hybrid fixture in `$TEST_DIR/proj`: `next.config.js`, `vite.config.ts`, `package.json` listing both `"next"` and `"react-router-dom"`.
  - Run `scan_presets`. Assert output contains BOTH `nextjs` AND `react-vite-spa`.
- [ ] T044 — [P] [US-6] `tests/new-project.bats` (or `tests/presets.bats` depending on where the multi-match prompt lives) — @test: non-interactive bootstrap against the hybrid fixture without `--preset` exits non-zero with a message instructing the user to pass `--preset <name>` or `--no-preset`.

### US-6 implementation

- [ ] T045 — [US-6] No new code expected. Existing multi-match flow (US-7 of `presets-detection-and-e2e`) handles this.

**Checkpoint Phase 7**: US-6 functional. Tests T043–T044 green.

---

## Phase 8 — Polish & validation

- [ ] T046 — [P] Run `bash scripts/test.sh` parallel. Record runtime; must stay within +5 s of the Phase 0 baseline.
- [ ] T047 — [P] Run `bash scripts/lint.sh` (ShellCheck). Anticipate SC1010 (loop var clash, rename `fi`/`i` if needed) and SC2034 (unused globals — `# shellcheck disable=SC2034` on the new array).
- [ ] T048 — [P] Run `bash scripts/validate-presets.sh`. Clean on all 6 manifests. Verify the XOR rule fires on a deliberately broken synthetic preset.
- [ ] T049 — Run `bash scripts/validate-counts.sh`. Must exit 0. If it fails, bump the README `tests-N passing` badge by the delta of new tests. Commit as `chore(readme): bump tests-N badge for react-vite-spa additions`.
- [ ] T050 — Final read: CHANGELOG `[Unreleased]` has BOTH entries (keep-filter runtime + new preset). Validate against this checklist.
- [ ] T051 — Mark `specs/preset-react-vite-spa/spec.md` Status: Draft → Validated. Commit as `docs(specs): mark preset-react-vite-spa as Validated`.
- [ ] T052 — Run `/qa:qa-loop "score 90"` over the diff. Address any P0/P1 finding before opening the PR.
- [ ] T053 — Commit + push + open PR. Title: `feat(presets): add react-vite-spa preset (6th maintainer-vouched) + runtime keep filter`. PR body summarizes both deliverables. Watch the CI: ubuntu-latest must be green; macos-latest currently skips but the tests must not break the suite if it re-enables. Anticipate ShellCheck SC1010/SC2034 (mitigated in T047).

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
   │       │
   │       ▼
   │     Phase 3 (US-2: detection) — depends on Phase 2 manifest
   │     Phase 4 (US-3: update lifecycle) — depends on Phase 2 manifest
   │     Phase 5 (US-4: vendor skills) — depends on Phase 2 manifest
   │     Phase 6 (US-5: docs) — depends on Phase 2 manifest
   │     Phase 7 (US-6: multi-match) — depends on Phase 2 manifest
   │
   ▼
Phase 8 (Polish & validation)
```

### Dependencies between user stories

| Story | Can start after | Dependencies |
|---|---|---|
| Foundation (Phase 1) | Phase 0 | None |
| US-1 (P1) | Phase 1 | Foundation runtime |
| US-2 (P1) | Phase 2 | Manifest from T025 |
| US-3 (P2) | Phase 2 | Manifest from T025 + Phase 1 helpers |
| US-4 (P2) | Phase 2 | Manifest from T025 |
| US-5 (P2) | Phase 2 | Manifest from T025 |
| US-6 (P3) | Phase 2 + Phase 3 | Manifest + detection rule |

### MVP cut

If time pressure forces a smaller deliverable, the irreducible scope is:
- **Phase 0 + Phase 1 + Phase 2 + Phase 8** (Setup + Foundation + US-1 + Polish)
- This ships: the runtime keep support, the new preset, the e2e bootstrap test, the docs entries.
- US-2 (detection), US-3/4/5/6 can ship in a follow-up PR if necessary.

### Parallelization opportunities

Within each phase, all tasks marked `[P]` operate on different files or different test cases and can run in parallel:
- Phase 1.A: T003, T004, T005 in parallel.
- Phase 1.B: T007, T008 in parallel.
- Phase 1.C: T010, T011 in parallel.
- Phase 2 tests: T018–T024 all in parallel.
- Phase 3 tests: T027–T030 in parallel.
- Phase 4 tests: T033–T035 in parallel.
- Phase 5 tests: T037–T038 in parallel.
- Phase 6 docs: T040, T041, T042 in parallel.
- Phase 7 tests: T043, T044 in parallel.
- Phase 8 validation: T046, T047, T048 in parallel.

---

## Parallelization example: Phase 1.B (bootstrap keep)

```bash
# Launch both RED tests together:
Task: "Write tests/new-project-preset-filter.bats T007 — keep-filter copy assertion"
Task: "Write tests/new-project-preset-filter.bats T008 — drop-filter regression assertion"

# After tests fail, implement T009 sequentially (single file, no parallel).
```

---

## Implementation Strategy

### MVP First

1. Phase 0 → Phase 1 → Phase 2 → Phase 8 (skip Phases 3–7 if time-constrained).
2. PR mergeable with: runtime keep support + preset manifest + e2e test + docs.

### Incremental Delivery (recommended)

1. Phase 0 + Phase 1 → commit boundary at T017 → could merge as its own PR (`feat(presets): support keep-style skills filter`) if the user wants to validate the runtime extension independently.
2. Phase 2 → MVP of the preset.
3. Phases 3–7 → adds detection, lifecycle, docs, multi-match.
4. Phase 8 → polish + PR.

### Single-PR strategy

Given small total scope (~17–19 commits) and tight coupling between the runtime extension and the new preset that depends on it, a **single PR is recommended**. Two-PR strategy only if review fatigue becomes an issue.

---

## Notes

- **No project names** anywhere in the deliverables (per `feedback_no_project_names` memory rule). Generic phrasing only: "the maintainer's React Vite SPA codebases", "production React Vite stack", etc.
- **No marketplace plugins at v1** — `marketplacePlugins: []` is intentional and consistent with the cautious posture of `astro`, `fastapi`, `cli-tools`, `homelab-proxmox`.
- **macOS portability**: avoid `timeout`, `grep -P`, BSD-incompatible flags. Stick to portable Bash + `jq`.
- **README badge anti-drift**: after each test-count change (T014 + T046), bump the badge in the SAME commit as the test additions OR in a separate `chore(readme)` commit, never leave a drift across commits.
- **ShellCheck**: anticipate SC1010 (rename loop var if it shadows a function name) and SC2034 (mark unused globals with `# shellcheck disable=SC2034`).

---

**Version**: 1.0 | **Created**: 2026-05-13
