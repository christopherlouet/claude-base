# Plan: Horizontal domains as pure opt-in modules

**Input**: [`spec.md`](spec.md) · **Design**: [`docs/designs/2026-06-09-horizontal-domains-as-pure-modules-design.md`](../../docs/designs/2026-06-09-horizontal-domains-as-pure-modules-design.md)
**Approach**: A (logical flip — no physical file move) · **Breaking**: yes, MAJOR bump `2.0.0 → 3.0.0`
**Resolved**: CP1 = pure strict migration · CP2 = core headline + full-foundation beside · CP3 = all presets core-only

---

## Technical context

| Anchor | Location | Change |
|--------|----------|--------|
| Default module set | `scripts/lib/modules.sh::modules_default_set()` (= `modules_list()` today) | Return **empty** (opt-in) instead of all |
| Module registry | `scripts/lib/modules/*.txt` (biz/legal/growth) | Source of "which domains are modules" — unchanged |
| Preset default modules | `scripts/new-project.sh::preset_default_modules()` | Absent `defaultModules` → empty set (inherits the flip) |
| Filter catalog enumeration | `scripts/lib/catalog-filter.sh::catalog_list_items()` | Exclude module-domain items so `keep`/`drop` see core only |
| Crossing-update detection | `scripts/update.sh` (reads/writes manifest version; `record_foundation_version`) | Manifest version `< 3.0.0` ⇒ reset pre-flip horizontal to opt-in |
| Counts | `counts.json`, `scripts/validate-counts.sh`, `README.md` badges | Split **core** (default install) vs **full foundation** |
| Version | `VERSION` (`2.0.0`) | → `3.0.0` |

**Module-domain knowledge for the filter**: `catalog-filter.sh` must not hard-depend on `modules.sh`. The consumer (install/update/validate) passes the module-domain exclusion set (from `modules_list`) into the enumeration, OR `catalog_list_items` gains an optional "exclude domains" argument. Keeps the lib decoupled (decide in S1 TDD).

---

## Phases (one phase = one PR session)

### Phase 1 — Filter governs the core only (US-4) · S1
**Goal**: `catalog-filter` enumeration excludes module domains; a preset `keep` whitelist never removes a module item (EF-309/EF-310). No default-install change yet.
**Independent test**: `catalog_list_items` with module-domain exclusion returns core only; `keep [domain:dev]` removal set contains **zero** biz/legal/growth; install/update/validate wired to pass the exclusion set.
**Risk**: low — pure scoping, no behaviour change to default install.

### Phase 2 — Default flip to opt-in core-only (US-1, US-2) · S2 🎯 MVP
**Goal**: `modules_default_set` → empty; a fresh install / a preset without `defaultModules` → core only (EF-301/302/303); explicit opt-in by name + by preset still works (EF-304/305). Bump `VERSION` → `3.0.0`; start the CHANGELOG breaking entry.
**Independent test**: fresh install = 101 commands / 47 agents, zero horizontal; `claude-base add biz` → +11/+4 recorded; `--preset X` without modules → core-only.
**Risk**: **high** — headline breaking change; rewrites many existing install-count test expectations (byte-identity churn).

### Phase 3 — Strict update migration (US-3) · S3
**Goal**: a crossing update (manifest version `< 3.0.0`) stops refreshing pre-flip horizontal, never deletes on-disk files, reports the change + `add` instruction (EF-307/EF-308). Post-flip `add`/preset modules refresh normally (EF-306).
**Independent test**: update matrix — legacy manifest (all 3) → horizontal not refreshed, files retained, report present; re-`add biz` → refreshed; post-flip project unaffected.
**Risk**: **high** — migration correctness; idempotency; manifest version comparison.

### Phase 4 — Counts split + drift gate (US-5) · S4
**Goal**: `counts.json` + `validate-counts.sh` expose core vs full-foundation totals; README badges show core headline with full beside (CP2) (EF-311).
**Independent test**: counts gate validates both totals and fails on drift; no doc claims a default project gets the full catalog.
**Risk**: medium — gate logic + doc anchors.

### Phase 5 — Docs, model & migration note (US-6) · S5
**Goal**: document "core + opt-in modules", the restore instruction, the breaking note; finalise the CHANGELOG MAJOR entry; mark `foundation-modules` EF-210 superseded; amend `.claude/presets/README.md` + relevant `docs/` + `specs/foundation-modules/` cross-reference (EF-312/313).
**Independent test**: audit-docs clean; counts gate clean after `npm --prefix website run generate`.
**Risk**: low — docs only.

### Phase 6 — Stack presets adopt a module-safe core filter (US-7) · S6 — **DEFERRED**
**Status (2026-06-09)**: deferred to the follow-on `thematic-modules` spec.
A complementary brainstorm ([`docs/designs/2026-06-09-core-plus-thematic-modules-design.md`](../../docs/designs/2026-06-09-core-plus-thematic-modules-design.md))
established that ergonomic `keep`-by-domain (owner's preferred polarity, see
[[prefer-keep-whitelist-over-drop]]) needs the scattered off-stack items
(dev-flutter, ops-proxmox/opnsense/mobile-release/infra-code, data-pipeline, …)
pulled into **thematic modules** first — otherwise a `domain:` keep can't subtract
them. So preset adoption moves into `thematic-modules` where the core is already
ergonomic. S1–S5 here ship unchanged (the mechanism).

---

## Dependencies & sequence

```
S1 (filter→core)  ─┐
                   ├─▶ S6 (preset adoption)
S2 (default flip) ─┘
   │
   ├─▶ S3 (strict migration)   [needs the flip version]
   ├─▶ S4 (counts split)       [numbers change at the flip]
   └─▶ S5 (docs + MAJOR note)
```

Recommended PR order: **S1 → S2 → S3 → S4 → S5 → S6**. S1 first (safe, sets the boundary, enables S6). S2 is the breaking core. S3/S4/S5 follow the flip. S6 last (worked examples).

---

## Risks & mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking change to all existing projects | High | MAJOR bump, explicit CHANGELOG + migration note, COPY-only never deletes; strict policy is owner-approved |
| Existing install-count tests assume full catalog | High (churn) | S2 updates them deliberately; assert core counts; keep module-add tests for restore |
| Migration version-comparison edge cases (manifest-less, unknown version) | High | Treat manifest-less / unparseable as pre-flip (strict); cover in S3 matrix |
| `catalog-filter` coupling to `modules.sh` | Medium | Pass exclusion set in (decouple); decide in S1 |
| Counts gate ambiguity (core vs full) | Medium | S4 defines both totals explicitly; CP2 wording fixed |
| Scope creep across 6 phases | Medium | One phase = one PR, merge on per-PR green; never combine |

## Test strategy per phase

- **S1**: `tests/catalog-filter.bats` (exclusion), `tests/new-project-catalog-filter.bats` + `tests/update-presets-catalog.bats` (keep module-safe end-to-end), `tests/validate-presets.bats`.
- **S2**: `tests/new-project*.bats` (core-only counts, add restores), `tests/presets*.bats`, `tests/modules.bats`.
- **S3**: `tests/update-presets*.bats` + a new `tests/update-modules-migration.bats` (crossing matrix).
- **S4**: `tests/` counts-gate test + `validate-counts.sh` self-check.
- **S5**: `audit-docs.sh`, counts gate after website regen.
- **S6**: per-preset install-reduction tests (mirror nextjs #277), `validate-presets.sh`.

Per the proven loop ([[session-workflow-modules-feature]]): RED→GREEN per phase, post-checks (counts gate: badge + `npm --prefix website run generate`), `/code-review` (high for code phases S1–S4, inline for docs S5/S6), PR per session, merge on per-PR go.

---

**Version**: 1.0 | **Created**: 2026-06-09
