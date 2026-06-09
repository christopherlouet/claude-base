# Tasks: Horizontal domains as pure opt-in modules

**Input**: [`plan.md`](plan.md) · [`spec.md`](spec.md)
**Breaking**: MAJOR bump `2.0.0 → 3.0.0` · **Resolved**: CP1 strict · CP2 core-headline · CP3 presets core-only

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: parallelizable (different files, no dependency)
- **[US1…US7]**: traceability to the user story
- TDD: write the RED test first and watch it fail before GREEN
- One phase = one session = one PR (squash-merge `(Sx) (#NNN)`), merge on per-PR go when CI is green

---

## Phase 1 — Filter governs the core only (US-4) · S1

**Goal**: the preset `keep`/`drop` filter only ever sees core items; module domains are out of its jurisdiction (EF-309/EF-310).

### Tests (RED first) ⚠️
- [x] T001 [P] [US4] — `tests/catalog-filter.bats`: catalog enumeration with module-domain exclusion returns core only (no biz/legal/growth); `keep [domain:dev]` removal set contains zero module items; floor still protected
- [x] T002 [P] [US4] — `tests/new-project-catalog-filter.bats` + `tests/update-presets-catalog.bats`: a `keep` whitelist install/update never removes a module item; `tests/validate-presets.bats`: filter naming a module domain/item still rejected with the module-opt-in message

### Implementation
- [x] T003 [US4] — `scripts/lib/catalog-filter.sh`: `catalog_list_items` (or a wrapper) accepts an exclusion set of module domains so the removal-set computation operates on the core only; keep the lib decoupled from `modules.sh` (consumer passes `modules_list`)
- [x] T004 [US4] — wire the exclusion set at the 3 consumers (install `apply_catalog_filters`, update `_catalog_remove_set`, validate `_catalog_filter_findings`); shellcheck `-S warning` clean

**Checkpoint**: keep is module-safe; no default-install change yet.

---

## Phase 2 — Default flip to opt-in core-only (US-1, US-2) · S2 🎯 MVP

**Goal**: default install / no-`defaultModules` preset → core only; explicit opt-in preserved. The breaking change.

### Tests (RED first) ⚠️
- [x] T005 [P] [US1] — `tests/new-project*.bats`: fresh install (no preset) = core only (101 commands / 47 agents), zero biz/legal/growth; summary advertises modules + add command
- [x] T006 [P] [US2] — `tests/modules.bats` + `tests/new-project*.bats`: `claude-base add biz` → +11 commands / +4 agents recorded; `--preset X` (no defaultModules) → core-only; unknown module name rejected (EF-305)

### Implementation
- [x] T007 [US1] — `scripts/lib/modules.sh::modules_default_set` → empty (opt-in); update the function comment (no longer "full catalog at v1")
- [x] T008 [US1] — `scripts/new-project.sh::preset_default_modules`: absent `defaultModules` → empty set; init summary lists available modules + `claude-base add` hints
- [x] T009 [US2] — verify/adjust `add`/`remove`/`modules` verbs record the post-flip choice durably; `VERSION` → `3.0.0`; start CHANGELOG breaking entry
- [x] T010 [US1] — update existing install-count test expectations to core-only (deliberate byte-identity churn); shellcheck clean

**Checkpoint**: a fresh project is core-only; opt-in restores horizontal.

---

## Phase 3 — Strict update migration (US-3) · S3

**Goal**: the crossing update resets pre-flip horizontal to opt-in, never deletes, reports clearly (EF-306/307/308).

### Tests (RED first) ⚠️
- [x] T011 [P] [US3] — new `tests/update-modules-migration.bats`: legacy manifest (version `< 3.0.0`, all 3 modules) → horizontal NOT refreshed, on-disk files retained, distinct report + `add` instruction; re-`add biz` → refreshed; post-flip manifest unaffected; manifest-less/unparseable treated as pre-flip (strict)
- [x] T012 [P] [US3] — idempotency: a second update produces no duplicate report, no re-deletion

### Implementation
- [x] T013 [US3] — `scripts/update.sh`: detect crossing via manifest foundation version; on pre-flip, drop horizontal from the refresh set (COPY-only — no on-disk delete) and emit the migration report + restore hint
- [x] T014 [US3] — ensure post-flip recorded modules (add/preset) still refresh (EF-306); shellcheck clean

**Checkpoint**: full update matrix green; no surprise deletions.

---

## Phase 4 — Counts split + drift gate (US-5) · S4

### Tests (RED first) ⚠️
- [x] T015 [P] [US5] — counts-gate test: `counts.json` carries core + full-foundation totals; `validate-counts.sh` validates both and fails on drift; a doc claiming a default project gets the full catalog fails the gate

### Implementation
- [x] T016 [US5] — `counts.json`: add core totals (commands/agents) beside the full-foundation totals
- [x] T017 [US5] — `scripts/validate-counts.sh`: compute + validate core vs full; `README.md` badges = core headline + full-foundation noted beside (CP2); `npm --prefix website run generate`

**Checkpoint**: counts gate green with both totals.

---

## Phase 5 — Docs, model & migration note (US-6) · S5

- [x] T018 [P] [US6] — `.claude/presets/README.md` `defaultModules` section rewritten (absent → no modules / opt-in; `claude-base add` restore path; v3 supersession note). Root `README.md` core-vs-full note shipped in S4.
- [x] T019 [P] [US6] — `CHANGELOG.md` MAJOR `3.0.0` breaking entry (shipped S2) covers the migration instruction; `specs/foundation-modules/` EF-210 + US-5 acceptance criteria marked SUPERSEDED with a cross-reference to `specs/horizontal-pure-modules/`
- [x] T020 [US6] — counts gate green after `npm --prefix website run generate`; audit-docs clean

**Checkpoint**: model & migration fully documented.

---

## Phase 6 — Stack presets adopt a module-safe core filter (US-7) · S6 — DEFERRED

> **Deferred to the `thematic-modules` spec** (2026-06-09). Ergonomic `keep`-by-domain
> (owner's preferred polarity) needs the scattered off-stack items pulled into
> thematic modules first — see `docs/designs/2026-06-09-core-plus-thematic-modules-design.md`.

- [ ] ~~T021 / T022~~ → moved to `thematic-modules` (preset adoption via ergonomic `keep`)

---

## Dependencies and Execution Order

```
S1 (filter→core) ──┐
                   ├──▶ S6 (preset adoption)
S2 (default flip) ─┘
   ├──▶ S3 (strict migration)
   ├──▶ S4 (counts split)
   └──▶ S5 (docs + MAJOR note)
```

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US4 (S1) | now | Safe boundary; enables S6 |
| US1/US2 (S2) | S1 | Headline breaking change |
| US3 (S3) | S2 | Needs the flip version |
| US5 (S4) | S2 | Numbers change at the flip |
| US6 (S5) | S2–S4 | Docs reflect the new model |
| US7 (S6) | S1 + S2 | Worked examples |

---

## Notes

- TDD: RED commit → GREEN commit per session, like parts 1 & 2.
- Post-session checks ([[session-workflow-modules-feature]]): branch name, commit split, tasks.md ticked, counts gate (badge + `npm --prefix website run generate`), e2e sanity of the shipped behaviour.
- `/code-review` high for code phases (S1–S4), inline for docs (S5/S6) — per per-session review-cost guidance.
- `bats tests/` runs 6–10 min — run in background, never block.
- This supersedes `foundation-modules` EF-210; keep the cross-reference accurate.

---

**Version**: 1.0 | **Created**: 2026-06-09
