# Tasks: foundation modules — installable horizontal domains

**Input**: Design documents from `specs/foundation-modules/`
**Prerequisites**: plan.md (validated), spec.md (Clarified)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: Can be executed in parallel (different files, no dependencies)
- **[US1..US5]**: Associated user story (traceability)
- Exact file paths in every description

---

## Phase 1: Setup (bundle data + registry)

**Goal**: Module bundles exist as reviewable data; registry lib can enumerate and parse them.

- [x] T001 - CI baseline: run `bats tests/` + shellcheck, record pre-existing failures (workflow rule: never confuse them with new ones)
- [x] T002 - [P] Create `scripts/lib/modules/biz.txt` — all `.claude/commands/biz/*.md` (11) + `.claude/agents/biz-*.md` (4), minimal-manifest syntax
- [x] T003 - [P] Create `scripts/lib/modules/legal.txt` — `.claude/commands/legal/*.md` (5) + `.claude/agents/legal-*.md` (4)
- [x] T004 - [P] Create `scripts/lib/modules/growth.txt` — `.claude/commands/growth/*.md` (11) + `.claude/agents/growth-*.md` (6) + `.claude/skills/growth-cro/`
- [x] T005 - Write failing tests in `tests/modules.bats`: registry lists exactly {biz, legal, growth}; bundle parse returns the expected path sets; bundle paths all exist in the repo (drift guard)
- [x] T006 - Implement registry half of `scripts/lib/modules.sh`: `modules_list()`, `module_bundle_paths(name)`, `module_exists(name)` — make T005 green

**Checkpoint**: `bats tests/modules.bats` green; bundles reviewed as data.

---

## Phase 2: Foundation — project manifest (⚠️ blocks all user stories)

**Goal**: `.claude/foundation.json` read/write/migrate helpers, single source of truth.

- [x] T007 - Write failing tests in `tests/modules.bats`: manifest write→read roundtrip; missing manifest detection; corrupted JSON → loud error with path + repair hint; unknown module names inside manifest → warning, ignored
- [x] T008 - Implement manifest half of `scripts/lib/modules.sh`: `write_foundation_manifest(dir, version, preset, modules...)`, `read_foundation_manifest(dir)`, `manifest_preset(dir)`, `manifest_modules(dir)`, `manifest_has_module(dir, name)`, `migrate_legacy_marker(dir)` — make T007 green
- [x] T009 - Inventory every internal reader of `.claude/.foundation-version`: `grep -rn "foundation-version\|foundation_marker" scripts/ tests/ .claude/` — exhaustive list in PR description (breaking-change control, EF-205)
- [x] T010 - Update `scripts/lib/common.sh`: `write_foundation_marker()` (:530) delegates to manifest writer; `read_foundation_version()` (:543) reads manifest first, falls back to legacy marker (migration trigger only); update every reader from T009

**Checkpoint**: manifest helpers green; no existing suite broken (`bats tests/`).

---

## Phase 3: User Story 1 — Project manifest at init & update (P1) 🎯

**Goal**: init records {version, preset, modules}; update migrates legacy and uses the recorded preset.

**Independent test**: init a tmp project with `--preset nextjs`, read `.claude/foundation.json` → preset recorded; run update → no auto-detection, no marker file.

### Tests first (RED)

- [x] T011 [US1] Extend `tests/new-project.bats`: bare init writes manifest {version, preset:null, modules:[biz,legal,growth]}; `--preset nextjs` init records the preset; legacy marker file absent after init
- [x] T012 [P] [US1] Extend `tests/update.bats`: legacy project (marker only) → update creates manifest (full module set assumed), removes marker, reports the migration; `validate.sh` passes after migration
- [x] T013 [P] [US1] Extend `tests/update-presets.bats`: manifest-recorded preset used without detection; `--preset NAME` overrides manifest; `--no-preset` still disables filtering; multi-match refusal unreachable when manifest present (CS-205)

### Implementation (GREEN)

- [x] T014 [US1] `scripts/new-project.sh`: replace marker write (:1196 + simple-mode path) with `write_foundation_manifest` (preset name when used, full module list v1)
- [x] T015 [US1] `scripts/update.sh`: `resolve_active_preset()` (:730) resolution order — explicit flag > `--no-preset` > manifest > legacy auto-detect (+ trigger `migrate_legacy_marker`, report line); `print_summary()` (:1433) migration notice
- [x] T016 [US1] `scripts/validate.sh`: read manifest when present; report recorded-but-missing module items; never flag absent unrecorded modules (EF-211) — extend `tests/validate.bats` first

**Checkpoint US-1**: legacy fixture migrates cleanly; recorded preset drives update.

---

## Phase 4: User Story 2 — `add <module>` (P1) 🎯 MVP = US-1 + US-2

**Goal**: one command installs a module, recorded and update-tracked.

**Independent test**: init lean tmp project → `claude-base add legal` → 5 commands + 4 agents present, manifest records `legal` (CS-201).

### Tests first (RED)

- [ ] T017 [US2] Extend `tests/modules.bats`: add fresh (files + manifest + summary); add idempotent (re-add refreshes, single manifest entry); unknown module → fail with available list (exit code distinct); dry-run lists files, writes nothing; non-foundation target → refused; partial manual copy → converged and owned (heals staleness, CS-202 precondition); user-modified file → update-style conflict behavior (backup, prompt/non-interactive listing)
- [ ] T018 [P] [US2] Extend `tests/dispatcher.bats`: `claude-base add|remove|modules` routed to `scripts/module.sh`; help text lists the verbs

### Implementation (GREEN)

- [ ] T019 [US2] Create `scripts/module.sh`: arg parsing (add/remove/list, `--dry-run`, target dir), `cmd_add()` using `module_bundle_paths` + the `update_directory()` conflict path from `scripts/update.sh` (sourced or extracted helper — decide at implementation, prefer extraction to `scripts/lib/modules.sh` if sourcing update.sh is too heavy), manifest record, summary
- [ ] T020 [US2] `bin/claude-base`: route `add`, `remove`, `modules` verbs + `show_help()` entries

**Checkpoint MVP**: `init` → `add legal` → `validate` green end-to-end on a tmp project.

---

## Phase 5: User Story 3 — module-aware update (P2)

**Goal**: update maintains recorded modules, skips absent ones, reports both.

**Independent test**: project with `legal` only → bump foundation → update: legal items refreshed, zero biz/growth items added, report shows "biz, growth: not installed (skipped)" (CS-202/CS-203).

### Tests first (RED)

- [ ] T021 [US3] Extend `tests/update.bats`: installed module updated like core; absent module items NOT copied (`update --all`); report lines distinct (updated vs module-skipped); dry-run shows module names on module items

### Implementation (GREEN)

- [ ] T022 [US3] `scripts/update.sh`: in `update_commands()` (:533) and `update_directory()` (:863), consult `manifest_has_module` via a path→module predicate in `scripts/lib/modules.sh` (`path_module(path)` returns module name or empty=core); skip + count when module absent; `print_summary()` module section

**Checkpoint US-3**: staleness scenario from the filtering spec is now a passing test.

---

## Phase 6: User Story 4 — `remove <module>` (P2)

**Goal**: clean module removal, user files never silently destroyed.

**Independent test**: add growth, modify one file, remove growth → foundation-owned files gone, modified file preserved with notice, manifest unrecorded (CS-206).

### Tests first (RED)

- [ ] T023 [US4] Extend `tests/modules.bats`: clean remove (files + manifest + summary); user-modified file preserved with explicit notice; remove not-installed → clean message, no error spiral; remove with zero foundation-owned files left → unrecord + notice; dry-run

### Implementation (GREEN)

- [ ] T024 [US4] `scripts/module.sh`: `cmd_remove()` — ownership check (file identical to foundation copy → remove; differs → preserve + notice), manifest unrecord, summary

**Checkpoint US-4**: removal matrix green, 0 silent deletions.

---

## Phase 7: User Story 5 — preset `defaultModules` (P3)

**Goal**: presets declare their default module set; init summary advertises the rest.

**Independent test**: synthetic preset with `defaultModules: ["legal"]` → init installs legal only; summary prints `claude-base add biz|growth` hints.

### Tests first (RED)

- [ ] T025 [US5] Extend `tests/validate-presets.bats`: `defaultModules` optional, array of known module names; unknown name → error; forbidden on vendor-pointer tier (EF-210)
- [ ] T026 [P] [US5] Extend `tests/new-project.bats`: preset with `defaultModules` → exact set installed + recorded; preset without → all modules (backward compat); init summary names available-not-installed modules with the add command

### Implementation (GREEN)

- [ ] T027 [US5] `scripts/validate-presets.sh`: `defaultModules` validation + vendor-pointer interdiction; `scripts/new-project.sh`: honor `defaultModules` at install + manifest record + summary block

**Checkpoint US-5**: synthetic-preset fixture green.

---

## Phase 8: Polish & delivery

- [ ] T028 [P] Docs: `docs/reference/commands.md` (add/remove/modules verbs), `.claude/presets/README.md` (`defaultModules`), CHANGELOG entry with **breaking-change note** (marker → manifest)
- [ ] T029 [P] Regenerate website mirror: `cd website && npm run generate` (never hand-edit `website/docs`)
- [ ] T030 - Full gate: `bats tests/` (all suites incl. the 97 preset tests), shellcheck, `scripts/validate-presets.sh`; then `/qa:qa-loop "score 90"` before PR

---

## Dependencies

```
T001 ─▶ T002/T003/T004 [P] ─▶ T005 ─▶ T006 ─▶ T007 ─▶ T008 ─▶ T009 ─▶ T010
                                                                    │
                              ┌─────────────────────────────────────┘
                              ▼
                T011/T012/T013 [P] ─▶ T014 ─▶ T015 ─▶ T016   (US-1)
                              ▼
                T017/T018 [P] ─▶ T019 ─▶ T020                (US-2, MVP)
                              ▼
                T021 ─▶ T022                                  (US-3)
                              ▼
                T023 ─▶ T024                                  (US-4)
                              ▼
                T025/T026 [P] ─▶ T027                        (US-5)
                              ▼
                T028/T029 [P] ─▶ T030                        (Polish)
```

Session split (scope-management rule, 28 tasks total): S1 = Phases 1-3, S2 = Phase 4 (MVP), S3 = Phases 5-6, S4 = Phases 7-8. One commit per phase minimum.
