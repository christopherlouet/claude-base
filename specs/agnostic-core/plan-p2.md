# Implementation Plan — P2: Installer Seam (select-then-emit)

**Branch**: `feature/installer-seam` (stacked on P1 until #489 merges, then rebased on main)
**Date**: 2026-07-18
**Spec**: [spec.md](./spec.md) US-4 / EF-007
**Status**: In progress

## Summary

Invert the installer's "copy-everything-then-delete" into "select-then-emit": the existing pure selection layer (`catalog_removal_set`, `module_bundle_paths`, `get_rules_for_type`, `cf_filter_*`, `SELECTED_MODULES`) feeds a **generated `SRC[:DST]` manifest** (same grammar as `scripts/lib/minimal-manifest.txt`), consumed by a generalized **export-minimal-style emitter**. Dry-run prints the manifest; the real run copies it — dry-run ≡ real **by construction**. Zero behavior change on the installed tree; the only intended visible change is that dry-run stops under-reporting (today the module filter returns early in dry-run and the skill keep-filter previews zero removals against a not-yet-populated tree).

## Scope

- **In**: `new-project.sh` full/simple paths (`create_project`, `run_simple_mode`) for the manifest-driven artifacts: six `.claude/` categories, filtered rules, docs relocations, `settings.json`, `scripts/hooks/*.sh`, `scripts/substance-check.sh`, `.mcp.env.example`.
- **Out (stay as post-emit transform steps, unchanged)**: CLAUDE.md rewrite/imports, `.gitignore` append, `.mcp.json`/CI/husky flag-driven installers, `foundation.json`, git init, marketplace plugins.
- **Out (later PR)**: `update.sh` (duplicates the emit logic today; shares the selection libs already).

## Architecture

```
selection (pure, existing libs)          NEW seam                     emit
type/preset/modules/tier  ──▶  compute_selected_set()  ──▶  manifest ──▶  emit_manifest() ──▶ tree
                               (scripts/lib/selected-set.sh)  (SRC[:DST])  (scripts/lib/emit.sh,
                                                                            extracted from export-minimal.sh)
                                        │
                                dry-run: print manifest (≡ what real emits)
```

## Slices (TDD each, same discipline as P1)

- **S1** `scripts/lib/selected-set.sh` — `compute_selected_set` prints the manifest: positive enumeration = full catalog (`catalog_list_items`) − `catalog_removal_set` (commands/agents) − skipped-module bundle paths − non-kept skills; rules = `get_rules_for_type` whitelist (function moves here from `new-project.sh:552`); docs relocations as `SRC:DST` lines; hooks/settings/substance-check entries. Direct bats vs expectations derived from the pure libs (both polarities pinned — gotcha #1/#5: floor + `CF_EXCLUDE_*` equivalence).
- **S2** `scripts/lib/emit.sh` — extract export-minimal's validated copy loop (`validate_manifest_entry`, `assert_within_repo`, dir/file/remap semantics) into `emit_manifest <manifest-file> <dest-root>` + an **exec-bit post-pass** (gotcha #3: `cp` mode preservation is not guaranteed through remaps); `export-minimal.sh` refactored onto it — its 26 tests stay green unchanged.
- **S3** wire `new-project.sh`: `install_claude_files` + `apply_preset_filter`/`apply_catalog_filters`/`apply_modules_filter` replaced by compute→emit on both orchestrators (`create_project`, `run_simple_mode`); dry-run prints the manifest instead of the 51 scattered `[DRY-RUN]` echoes for manifest-driven artifacts. Oracle: the ~300 existing init/preset/e2e/catalog tests pass unchanged.
- **S4** EF-007 test: for representative configs (no preset; preset keep-mode; preset drop-mode; modules subset; each stack type), assert `dry-run manifest DST set` ≡ `real installed tree` (minus the documented transform artifacts) — plus a negative probe (a planted divergence fails).

## Riskiest equivalence gotchas (from exploration, rank-ordered)

1. Rules are a positive whitelist while commands/agents/skills are subtractive — one manifest must encode both without changing the result.
2. Docs relocation remaps must fit the manifest grammar (one `:`, no `..`, dir-remap `cp -RP src/.` semantics).
3. Exec bit on hooks: emitter needs an explicit exec post-pass.
4. Transforms are NOT manifest entries — the seam defines the manifest-driven vs transform-driven boundary explicitly (documented above).
5. Keep-filter floor (`work` domain, `assistant*`) and `CF_EXCLUDE_DOMAINS/ITEMS` must apply identically in positive enumeration vs today's removal path.

## Validation gates

- Full suite green, zero existing test edited (S1-S3) — same bar as P1.
- S4 equivalence suite green incl. negative probe.
- shellcheck -S warning clean; bash-3.2 idioms; new lib files added to the install manifest closure if shipped (they are installer-side, NOT shipped to targets — verify manifest-hooks-coverage stays green).
