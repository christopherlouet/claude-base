# Implementation Plan: foundation modules — installable horizontal domains

**Branch**: `feature/foundation-modules` (implementation; specs land via `feature/specs-modules-and-filters`)
**Date**: 2026-06-06
**Spec**: [`specs/foundation-modules/spec.md`](./spec.md) (status: Clarified — 3/3 points resolved)
**Status**: Validated (2026-06-06) — ready for TDD, session split S1-S4

---

## Summary

Make the horizontal activity domains (`biz`, `legal`, `growth`) installable **modules**: `claude-base add legal`, `remove`, `modules list`, recorded in a per-project manifest `.claude/foundation.json` that replaces the legacy `.claude/.foundation-version` marker and also records the active preset (eliminating update-time re-detection). Updates maintain core + recorded modules and never impose absent ones.

Approach: pure extension of the existing bash/jq/bats machinery — module bundles reuse the proven manifest-file pattern (`scripts/lib/minimal-manifest.txt`), the `add` conflict behavior reuses the shipped update flow (`update_directory()`/backup), and the new verbs plug into the thin dispatcher (`bin/claude-base`).

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language** | Bash (portable: Linux + macOS bash 3.2) | CI runs `Lint & Test` on ubuntu AND macos — no bash-4-only features (no associative arrays) |
| **Data/parsing** | JSON + `jq` | `jq` is already a hard dependency (presets, hooks, settings) |
| **Tests** | bats | Existing suites: `tests/{new-project,update,update-presets,validate,dispatcher,presets}.bats` |
| **Lint** | shellcheck | Existing CI gate |
| **Target** | CLI (`claude-base` dispatcher + `scripts/`) | |

### Constraints

- **Backward compatibility (CS-204)**: bare init = same catalog as today + manifest; legacy projects migrate on first update contact; all existing bats suites pass unchanged.
- **Breaking change controlled (EF-205)**: `.foundation-version` removed at migration — CHANGELOG + release-notes flag; every internal reader updated in the same change.
- **Core never modular (EF-203)**: `work`/`dev`/`qa`/`ops`/`doc`/orchestrators are not modules.
- **base-maintenance rule**: docs under `docs/` only; `website/docs` regenerated via `npm run generate`; catalog counters unaffected (modules are `scripts/lib/` data files, no new `.claude` catalog items).

---

## Constitution/Conventions Check

- [x] Follows project conventions (bash + jq + bats, manifest-file pattern, dispatcher thin-router)
- [x] Consistent with existing architecture (presets spec lineage; `add` ≈ module-scoped update)
- [x] No over-engineering (no plugin system in v1 — named phase-2; no item-level granularity)
- [x] Tests planned (TDD, ≥6 tests per US, per the presets discipline)

---

## Project Structure

### Documentation (this feature)

```
specs/foundation-modules/
├── spec.md     # Functional specification (Clarified)
├── plan.md     # This file
└── tasks.md    # Task breakdown
```

### Source Code (delta)

```
bin/claude-base                      # +3 verb routes: add, remove, modules
scripts/
├── module.sh                        # NEW — add/remove/list orchestration (~250 LOC)
├── lib/
│   ├── modules.sh                   # NEW — bundle registry + project-manifest helpers (~180 LOC)
│   └── modules/                     # NEW — one bundle manifest per module (minimal-manifest.txt pattern)
│       ├── biz.txt                  # 11 commands, 4 agents, 0 skills
│       ├── legal.txt                # 5 commands, 4 agents, 0 skills
│       └── growth.txt               # 11 commands, 6 agents, 1 skill (growth-cro)
├── new-project.sh                   # manifest write, preset defaultModules, init summary
├── update.sh                        # manifest-first preset resolution, module-aware copy, legacy migration
├── validate.sh                      # manifest-aware checks
└── validate-presets.sh              # defaultModules validation (+ vendor-pointer interdiction)
tests/
├── modules.bats                     # NEW — add/remove/list/manifest/migration
└── (extended) dispatcher.bats, new-project.bats, update.bats, update-presets.bats, validate.bats, validate-presets.bats
```

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `scripts/lib/modules/biz.txt` | Bundle definition: biz domain paths (commands/biz/, agents biz-*.md) |
| `scripts/lib/modules/legal.txt` | Bundle definition: legal domain paths |
| `scripts/lib/modules/growth.txt` | Bundle definition: growth domain paths incl. `skills/growth-cro/` |
| `scripts/lib/modules.sh` | Registry (list bundles, parse bundle file) + project manifest helpers (`read_foundation_manifest`, `write_foundation_manifest`, `manifest_modules`, `manifest_preset`, `migrate_legacy_marker`) |
| `scripts/module.sh` | `add <name>` / `remove <name>` / `list` against a target project: bundle copy with update-style conflict handling, manifest record/unrecord, dry-run, summaries |
| `tests/modules.bats` | Full behavior matrix for the above |

### To modify

| File | Modification |
|------|--------------|
| `bin/claude-base` | Route `add` / `remove` / `modules` verbs to `scripts/module.sh` (+ help text) |
| `scripts/lib/common.sh` | `write_foundation_marker()` (:530) superseded by manifest writer; `read_foundation_version()` reads manifest first, legacy marker as migration trigger only |
| `scripts/new-project.sh` | Replace marker write (:1196) with manifest write `{version, preset, modules}`; honor preset `defaultModules` (absent = all); init summary lists not-installed modules + add command |
| `scripts/update.sh` | `resolve_active_preset()` (:730) reads manifest first (flags still override); `update_directory()` (:863) + `update_commands()` (:533) skip unrecorded-module paths with distinct report line; legacy migration (manifest created, marker removed, reported); `print_summary()` (:1433) module section |
| `scripts/validate.sh` | Read manifest; recorded-module items present → OK, recorded-but-missing → defect, absence of unrecorded modules never a defect (EF-211) |
| `scripts/validate-presets.sh` | Optional `defaultModules[]`: array of known module names; forbidden on `vendor-pointer` tier (EF-210) |
| `.claude/presets/README.md` | Document `defaultModules` |
| `docs/reference/commands.md` | `claude-base add/remove/modules` in the CLI table |
| `CHANGELOG.md` | Feature entry + breaking-change note (marker replacement) |

### Tests to add (per existing suite discipline: ≥6/US)

| File | Coverage |
|------|----------|
| `tests/modules.bats` (new) | US-2/US-4: add (fresh, idempotent, unknown, dry-run, conflict, non-foundation target), remove (clean, user-modified preserved, not-installed, zero-files), list |
| `tests/new-project.bats` (extend) | US-1/US-5: manifest written at init (bare + preset), defaultModules honored, absent field = all modules, init summary |
| `tests/update.bats` (extend) | US-1/US-3: legacy migration (manifest created, marker gone, validate OK), recorded preset used (no re-detection), modules updated, absent modules skipped + reported |
| `tests/update-presets.bats` (extend) | Manifest-recorded preset vs `--preset`/`--no-preset` precedence |
| `tests/validate.bats` (extend) | EF-211 matrix |
| `tests/validate-presets.bats` (extend) | defaultModules validation incl. vendor-pointer interdiction |
| `tests/dispatcher.bats` (extend) | New verbs routed, help text |

---

## Chosen Approach

### Architecture

```
bin/claude-base ──add/remove/modules──▶ scripts/module.sh
                                            │
                              ┌─────────────┴─────────────┐
                              ▼                           ▼
                    scripts/lib/modules.sh        scripts/lib/modules/*.txt
                    (registry + manifest IO)      (bundle definitions, data)
                              ▲                           ▲
        ┌─────────────────────┼───────────────────────────┘
        │                     │
  new-project.sh         update.sh ◀── reads .claude/foundation.json (preset + modules)
  (writes manifest)      (migrates legacy, maintains core+modules)
```

**Project manifest** (`.claude/foundation.json`):

```json
{ "version": "2.1.0", "preset": "nextjs", "modules": ["legal"] }
```

### Key decisions

1. **Bundle = manifest data file** (not prefix-derivation): explicit, reviewable, testable; tolerates naming irregularities (e.g. `growth-cro` skill); same parser as `minimal-manifest.txt`.
2. **`add` = module-scoped update** (clarification 3): conflict handling delegated to the existing `update_directory()` path — no third conflict behavior.
3. **Manifest-first preset resolution** (clarification 2): `resolve_active_preset()` order becomes — explicit flag > `--no-preset` > **manifest** > auto-detect (legacy only, triggers migration). The multi-match refusal path becomes unreachable for migrated projects (CS-205).
4. **Module paths derived from bundle files everywhere**: update.sh asks `modules.sh` "is this path part of a non-installed module?" — single source of truth, no duplicated domain lists.

### Alternatives considered

| Alternative | Rejected because |
|-------------|------------------|
| Prefix-derived bundles (no data files) | Naming traps (exploration: `ops-migrate`/`ops-migration`, `growth-cro` lone skill); implicit > explicit fails review |
| Native Claude Code plugins now | Phase-2 target (spec Out of Scope): marketplace packaging/CI is a separate chantier; manifest + verbs survive the transition |
| Keep legacy marker alongside manifest | Clarification 2 decided direct replacement; dual-write = permanent sync risk |

---

## Phases Overview

| Phase | Content | Blocking |
|-------|---------|----------|
| 1. Setup | Bundle data files + registry lib + CI baseline | — |
| 2. Foundation | Project-manifest helpers + marker call-site migration | ⚠️ blocks all US |
| 3. US-1 (P1) | Manifest at init + manifest-first update + legacy migration | — |
| 4. US-2 (P1) | `add` end-to-end 🎯 **MVP checkpoint = US-1 + US-2** | — |
| 5. US-3 (P2) | Module-aware update (skip + report) | — |
| 6. US-4 (P2) | `remove` | — |
| 7. US-5 (P3) | Preset `defaultModules` + init summary | — |
| 8. Polish | Docs, CHANGELOG, website regenerate, full matrix + shellcheck | — |

Detailed tasks: [`tasks.md`](./tasks.md).

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `update.sh` is 1,604 LOC with many interacting flags (`--force`, `--restore`, backups, preset filters) — regression surface | **High** | TDD on `tests/update.bats` extensions BEFORE touching it; module skipping isolated in `modules.sh` predicates; full existing suite is the gate (CS-204) |
| macOS bash 3.2 portability (CI macos job) | Medium | No associative arrays / `readarray`; reuse the portable idioms already in `common.sh`; macos CI is the verifier |
| Legacy migration on real-world projects (hand-customized `.claude/`) | Medium | Conservative EF-205 (undetectable → full module set = today's catalog, zero functional change); migration test fixtures incl. customized projects |
| External readers of `.foundation-version` break | Medium | Accepted (clarification 2); CHANGELOG + release notes; grep the repo for every internal reader (T010 exhaustive) |
| Interplay with the filter spec (same manifest, same update paths) | Medium | This chantier ships first (sequencing decided); manifest schema includes `preset` from day one so the filter spec consumes it without migration |
| Scope creep toward plugins/marketplace | Low | Spec Out of Scope is explicit; US-5 is P3 and detachable |

**Complexity: Complex** — 2 new scripts + 4 sensitive modified scripts + 7 test suites. Estimated 28 tasks across 8 phases; recommend 3-4 sessions (Setup+Foundation+US-1 / US-2 MVP / US-3+US-4 / US-5+Polish) with one commit per phase minimum, per the scope-management rule.

---

## Validation

- [x] Plan reviewed and validated by Chris (2026-06-06)
- [ ] Then: `/dev:dev-tdd` phase by phase (tests first)
- [ ] `/qa:qa-loop "score 90"` before each phase commit
- [ ] One PR per US-group or per phase if reviewable size demands it
