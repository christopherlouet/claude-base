# Tasks: preset command & agent filtering

**Input**: [`plan.md`](plan.md) · [`spec.md`](spec.md)
**Prerequisites**: plan reviewed; R1 resolved 2026-06-08 (keep-mode = whitelist, single polarity per list)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: parallelizable (different files, no dependency)
- **[US1…US4]**: traceability to the user story
- TDD: write the RED test first and watch it fail before GREEN
- One phase = one session = one PR (squash-merge `(Sx) (#NNN)`), merge on per-PR go when CI is green

---

## Phase 1 — Catalog-filter library (blocking) · S1

**Goal**: SSOT for command/agent filtering (`scripts/lib/catalog-filter.sh`). EF-102/103/104/111 core logic.
**Independent test**: lib helpers green via `tests/catalog-filter.bats`; no consumer wired, zero behaviour change elsewhere.

- [x] T001 [P] — RED: `tests/catalog-filter.bats` — domain resolution for commands (`commands/<domain>/x.md`) and agents (`<domain>-x.md`), domainless commands (`assistant`, `git-rename`, `lessons`), `domain:<name>` + exact-item matching, drop & keep removal sets, floor protection (work + assistant/assistant-auto), enumeration (`catalog_list_domains`/`catalog_list_items`), unknown-name detection — 36 tests, 34 RED before impl
- [x] T002 — GREEN: `scripts/lib/catalog-filter.sh` — `catalog_item_domain`, `catalog_item_name`, `catalog_list_domains`, `catalog_list_items`, `catalog_entry_matches`, `catalog_removal_set`, `catalog_floor_violations`, `catalog_unknown_entries` (bash 3.2: single `_resolve` → `_CF_DOMAIN`/`_CF_NAME`, no per-item subshell) — 36/36 green
- [x] T003 — REFACTOR: shellcheck `-S warning` clean (CI-equivalent, no `-x`); idioms mirror `lib/modules.sh`

**Checkpoint**: lib green in isolation.

---

## Phase 2 — User Story 1 — Filtered install (P1) 🎯 MVP · S2

**Goal**: commands/agents outside the preset's scope are excluded at init.
**Independent test**: init with a manifest declaring `foundation.commands.drop` / `foundation.agents.drop` → those items absent; `--dry-run` lists them; a no-filter preset installs byte-identical.

### Tests (RED first) ⚠️
- [x] T004 [P] [US1] — install tests (`tests/new-project-catalog-filter.bats`, 8): drop domain+item, keep/whitelist+floor, dry-run lists removals (EF-107), no-filter = byte-identical full catalog (CS-103/EF-106), EF-111 floor survives, EF-110 validation passes, +2 malformed-preset robustness guards

### Implementation
- [x] T005 [US1] — `load_preset()` reads `foundation.commands`/`foundation.agents` via `_load_catalog_filter` into `PRESET_{COMMANDS,AGENTS}_{MODE,ENTRIES}`; `common.sh` sources `catalog-filter.sh`
- [x] T006 [US1] — `apply_catalog_filters()` via `catalog_removal_set` + shared `remove_bundle_file`; wired right after `apply_preset_filter` in `run_simple_mode` (identical path coverage to the skill filter → EF-106/EF-109 by construction)
- [x] T007 [US1] — dry-run enumerates the source catalog, prints `catalog filter: would remove …`, installs nothing; no-field path inert (EF-106); malformed filter tolerated (review fix)

**Checkpoint**: a real manifest reduces a real install; full suite green.

---

## Phase 3 — User Story 2 — Author declares & validation enforces (P1) · S3

**Goal**: `foundation.commands`/`foundation.agents` declarations are validated; core + horizontal protections enforced.
**Independent test**: `validate-presets.sh` rejects malformed filters with explicit messages; warns on unknown names; passes good filters.

### Tests (RED first) ⚠️
- [x] T008 [P] [US2] — validate-presets tests (15 new): drop XOR keep rejection (EF-104); drop-array/keep-non-empty types; vendor-pointer tier ban (EF-105); EF-111 floor rejection of `domain:work`, `assistant`/`assistant-auto`, exact work items; horizontal-domain rejection of `domain:biz|legal|growth` + exact module items (+ defaultModules hint), drop AND keep mode; unknown-name `[WARN]` (non-fatal); keep-mode floor-omission accepted; clean stack filter `[OK]`; real-presets regression

### Implementation
- [x] T009 [US2] — `scripts/validate-presets.sh`: sources `catalog-filter.sh`; new non-fatal `[WARN]` channel; `_catalog_filter_findings()` helper (E:/W: routing) doing per-catalog XOR/types, `catalog_floor_violations` (EF-111), module-domain rejection (`module_exists`), `catalog_unknown_entries` warnings; vendor-pointer tier ban extended to commands/agents; fail-loud default on unexpected output
- [x] T010 [US2] — mirrors the `foundation.skills` block shape; shellcheck `-S warning` clean

**Checkpoint**: malformed filter caught with actionable message; good filter passes.

---

## Phase 4 — User Story 3 — Update respects the filter (P2) · S4

**Goal**: update skips excluded commands/agents, reports them; escape hatch restores full catalog.
**Independent test**: update on a filtered project adds 0 excluded items; report lists them; `--no-preset-filter` restores full catalog; dry-run lists skipped-by-filter distinctly.

### Tests (RED first) ⚠️
- [x] T011 [P] [US3] — update tests (`tests/update-presets-catalog.bats`, 5): excluded command+agent not re-added (CS-102); distinct `Filtered by preset` summary line (EF-108); `--no-preset` restores full catalog; EF-111 floor (`domain:work`) restored not skipped; dry-run lists preset-skipped items, no writes (EF-107)

### Implementation
- [x] T012 [US3] — `_catalog_remove_set` reads the active preset's `foundation.commands/agents` (tolerant jq) and precomputes per-catalog removal sets via `catalog_removal_set`; precomputed once after `resolve_active_preset` (empty under `--no-preset` → escape hatch reused)
- [x] T013 [US3] — `is_catalog_item_filtered` per-file skip in `update_command_file` (commands) and the `update_directory` agents block, COPY-only (EF-011); distinct `print_summary` line (separate from module skip)
- [x] T014 [US3] — `--no-preset` escape hatch reused (no new flag); shellcheck `-S warning` clean

**Checkpoint**: full update matrix green; 0 excluded items re-introduced.

---

## Phase 5 — User Story 4 — nextjs adoption (P3) · S5

**Goal**: ship the filter in the `nextjs` preset (conservative stack mirror only; horizontal domains stay with modules).
**Independent test**: `nextjs` install → ≥ 6 fewer commands and ≥ 5 fewer agents than unfiltered (CS-101).

### Tests (RED first) ⚠️
- [x] T015 [P] [US4] — `tests/new-project-catalog-filter.bats`: real `nextjs` install yields ≥ 6 fewer commands and ≥ 5 fewer agents vs full catalog (count diff + the 6 command / 5 agent counterparts asserted absent + a kept item present). `defaultModules:null` keeps all modules, so the reduction is purely the stack-mirror filter (CS-101 isolated from horizontal-domain reduction)

### Implementation
- [x] T016 [US4] — added `foundation.commands` (6) / `foundation.agents` (5 — `ops-mobile-release` has no agent counterpart, omitted to avoid an unknown-name `[WARN]`) drop lists to `.claude/presets/nextjs.json`; `description` updated to name command/agent exclusions; `validate-presets.sh` passes `[OK]`
- [x] T017 [US4] — bumped `nextjs` `1.0.0` → `1.1.0` (minor); CHANGELOG `Added` (feature + adoption) + `Changed` (behaviour-change note: existing nextjs projects lose 6 cmds / 5 agents on update, `--no-preset` restores)

**Checkpoint**: nextjs is the worked example; one preset = one reviewed change.

---

## Phase 6 — Polish, docs & spec reconciliation · S6

- [ ] T018 [P] — CS-105: amend `specs/presets/spec.md` (announced command/agent filtering now implemented; correct the stale `domains`/`excludes` example to `drop`/`keep` + `domain:`)
- [ ] T019 [P] — document new fields + `domain:<name>` form in `.claude/presets/README.md` and relevant `docs/`
- [ ] T020 — counts gate: `npm --prefix website run generate`; confirm no catalog-count drift; reword any doc claiming "every project gets 128 commands / 61 agents"
- [ ] T021 — final: full `bats tests/` + shellcheck (CI options), `/code-review high` per session with adversarial verify

---

## Dependencies and Execution Order

```
Phase 1 (lib)
   │
   ├──▶ Phase 2 (US-1 install, P1)
   ├──▶ Phase 3 (US-2 validation, P1)   [gate: R1 decided]
   └──▶ Phase 4 (US-3 update, P2)
Phases 2–4 ──▶ Phase 5 (US-4 nextjs, P3) ──▶ Phase 6 (docs/spec/polish)
```

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US1 (P1) | Phase 1 | Headline value; independently testable |
| US2 (P1) | Phase 1 + R1 decision | Gates safe authoring; doesn't block install mechanics |
| US3 (P2) | Phase 1 | Independently testable on the update path |
| US4 (P3) | US1 (+ US3 to prove CS-102) | One preset = one change |

---

## Notes

- TDD: RED commit (failing test) → GREEN commit (impl) per session, like part 1.
- Post-session checks (from memory `session-workflow-modules-feature`): branch name, commit split, tasks.md ticked, counts gate if docs touched, e2e sanity run of the shipped behaviour.
- `bats tests/` runs 6–10 min — run in background, never block.
- Do **not** refactor the existing skills filter onto the new lib in this feature (CS-103 byte-identity risk) — commands/agents only.

---

**Version**: 1.0 | **Created**: 2026-06-08
