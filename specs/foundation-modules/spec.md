# Spec: foundation modules — installable horizontal domains

> **Status: ✅ Shipped** — PRs #265–#269 (S1–S4 + polish, 2026-06-07). 28/28 tasks delivered.

**Status**: Clarified — all 3 clarification points resolved (2026-06-06), ready for planning
**Date**: 2026-06-06
**Owner**: Chris
**Related specs**: [`specs/presets/spec.md`](../presets/spec.md) (stack presets — vertical axis), [`specs/presets-commands-agents-filter/spec.md`](../presets-commands-agents-filter/spec.md) (catalog filtering — amended by this spec to stay stack-scoped)

---

## Summary

The foundation's catalog mixes a coding core (workflow, dev, qa, ops, doc) with **horizontal activity domains** — business strategy, legal compliance, growth — that are orthogonal to any stack: a Next.js SaaS may need all three, a homelab none. Today these domains are either installed wholesale or (per the filtering spec's first draft) dropped wholesale, with no clean way back. This spec makes them **modules**: installable on any project with one command, removable, recorded in a project manifest, and kept up to date by routine updates. The same manifest finally records which preset a project was installed with, removing the fragile re-detection at update time.

## User Stories

### US-1 (P1) — Project manifest

**As a** developer with a foundation-installed project,
**I want** my project to record its foundation state (version, preset, installed modules),
**so that** updates know exactly what to maintain without guessing, and what I added on purpose survives them.

Acceptance criteria:

- **Given** a fresh init (with or without a preset), **When** the install completes, **Then** the project contains a manifest recording the foundation version, the preset used (if any), and the installed modules.
- **Given** a project installed before this feature (legacy version marker only), **When** I run an update, **Then** the manifest is created from what is detectable and the legacy marker is removed in the same operation (decided: clarification 2 — direct replacement), with the migration stated in the update report.
- **Given** a project with a manifest naming its preset, **When** I run an update without flags, **Then** the recorded preset is used directly — no auto-detection, no ambiguity refusal.

### US-2 (P1) — Add a module

**As a** developer whose project gained a new activity (e.g. the product now needs legal compliance),
**I want** to install a domain module with a single command,
**so that** the matching capabilities (commands, agents, skills of that domain) land in my project cleanly and stay maintained.

Acceptance criteria:

- **Given** a project without the `legal` module, **When** I run the add command for `legal`, **Then** every catalog item of the legal domain is installed, the manifest records the module, and a summary lists what was added.
- **Given** a project that already has the module, **When** I add it again, **Then** the operation is idempotent (files refreshed to the foundation's current version, no duplicate manifest entry).
- **Given** an unknown module name, **When** I try to add it, **Then** the command fails with the list of available modules.
- **Given** the add command in simulation mode (dry-run), **Then** the plan lists every file that would be installed and nothing is written.

### US-3 (P2) — Updates maintain modules

**As a** developer updating a project,
**I want** the update to cover the core AND my installed modules, and only those,
**so that** added modules never go stale and absent modules are never imposed.

Acceptance criteria:

- **Given** a project with the `legal` module installed, **When** I run a full update, **Then** legal items are updated like core items.
- **Given** a project without the `biz` module, **When** I run a full update, **Then** no `biz` item is added, and the report shows the module as "not installed (skipped)".
- **Given** an update in simulation mode, **Then** module items appear in the plan with their module name, distinct from core items.

### US-4 (P2) — Remove a module

**As a** developer whose project no longer needs an activity domain,
**I want** to remove a module cleanly,
**so that** my catalog stays curated without manual file deletion.

Acceptance criteria:

- **Given** a project with the `growth` module, **When** I run the remove command, **Then** foundation-owned growth items are removed, the manifest no longer lists the module, and a summary lists what was removed.
- **Given** a module file the user modified locally, **When** the module is removed, **Then** the modified file is preserved with an explicit notice (never silently destroyed).
- **Given** a module that is not installed, **When** I try to remove it, **Then** the command says so and exits cleanly (no error spiral).

### US-5 (P3) — Presets declare their default modules

**As a** preset author,
**I want** to declare which modules my preset installs by default,
**so that** a stack init produces a catalog honest to its audience (a homelab init has no use for growth) while staying one `add` away from any module.

Acceptance criteria:

- **Given** a preset declaring an explicit default module set, **When** I init with it, **Then** exactly those modules are installed and recorded, and the init summary names the available-but-not-installed modules with the add command to get them.
- **Given** a preset with no module declaration, **When** I init with it, **Then** all modules are installed (today's behavior — backward compatible).
- **Given** a bare init without preset, **Then** all modules are installed and recorded (no behavior change beyond the manifest).

## Functional Requirements

| ID | Requirement |
|----|-------------|
| EF-201 | A **module** is a named, foundation-shipped bundle of catalog items (commands, agents, skills) for one horizontal activity domain. |
| EF-202 | Initial module set: `biz`, `legal`, `growth`. Adding a future module is a data change (new domain bundle), not a mechanism change. |
| EF-203 | Modules are strictly horizontal: the coding core (`work`, `dev`, `qa`, `ops`, `doc`, orchestrators) is not modularizable and always installed. |
| EF-204 | The **project manifest** records foundation version, preset name (if any), and installed modules. It is created at init, maintained by add/remove/update, and human-readable. |
| EF-205 | Legacy projects (version marker only) are upgraded to a manifest on first contact (update), conservatively: detectable state recorded, full module set assumed when undetectable. The legacy marker is removed during migration (direct replacement); all foundation tooling reads the manifest first and falls back to the marker only to trigger migration. The replacement is a breaking change for external marker readers: flagged in the CHANGELOG and release notes. |
| EF-206 | `add <module>` installs the bundle, records it, is idempotent, and supports dry-run. On a locally modified file, it applies the exact conflict behavior of the existing update flow (interactive prompt, backup before overwrite, conflicts listed without overwriting in non-interactive mode) — add behaves as a module-scoped update (decided: clarification 3). |
| EF-207 | `remove <module>` removes foundation-owned bundle files, preserves user-modified files with notice, unrecords the module, supports dry-run. |
| EF-208 | Update maintains core + recorded modules; unrecorded modules are skipped and reported as such. |
| EF-209 | When a manifest records the preset, update uses it directly; explicit flags still override; the no-preset escape hatch remains. |
| EF-210 | A preset MAY declare its default module set; absence means "all modules" (backward compatible). Vendor-pointer presets MUST NOT declare one (tier inheritance rule). |
| EF-211 | Project validation understands the manifest: recorded modules present → OK; absence of unrecorded modules is never a defect; recorded-but-missing items are reported. |
| EF-212 | Module discovery: a list command shows available modules, their content summary (item counts), and installed status per project. |

## Edge Cases

- **Unknown module name** (add/remove): fail with the available list; exit code distinguishes "unknown" from "not installed".
- **Corrupted or hand-edited manifest**: malformed manifest → loud failure with the file path and a repair hint (re-running update regenerates what is regenerable); unknown module names inside the manifest → warning, ignored, never fatal.
- **Manifest deleted by user**: treated as legacy project (EF-205) on next update.
- **Add on a non-foundation project**: refused with a clear message (init first).
- **Module item colliding with a user-created file of the same name**: add never overwrites a file it does not own — conflict reported, file skipped, summary flags it.
- **Partial module state** (some legal files present after a manual copy): add converges the project to the complete, current bundle; manual copies become owned and maintained from then on (this retroactively heals the "manual re-add goes stale" case of the filtering spec).
- **Preset + module interplay**: preset filters (stack axis) and module sets (activity axis) are disjoint by construction (EF-203 vs stack-specific items); validation rejects a module bundle referencing core or stack-filtered items.
- **Remove with zero foundation-owned files left** (user deleted them manually): unrecord the module, note that nothing remained to remove.

## Entities

| Entity | Description | Key attributes |
|--------|-------------|----------------|
| Module | Foundation-shipped horizontal domain bundle | name, item list (commands/agents/skills), content summary |
| Project manifest | Per-project foundation state record | foundation version, preset name, installed modules |
| Domain bundle definition | Foundation-side declaration of a module's content | module name, item paths |
| Preset (extended) | Stack bundle, now module-aware | existing fields + optional default module set |

## Success Criteria

| ID | Criterion | Measure |
|----|-----------|---------|
| CS-201 | One-command module install | On a project initialized with a lean preset, `add legal` results in all 5 legal commands + 4 legal agents present and recorded, in one command. |
| CS-202 | No staleness | After `add legal` then a full update against a newer foundation, legal items carry the newer content (test matrix case). |
| CS-203 | Update never imposes | Full update on a project without `biz` adds 0 biz items, across the test matrix. |
| CS-204 | Backward compatibility | Bare init produces the same catalog as today (plus the manifest); legacy projects update without behavior change; all existing bats suites pass. |
| CS-205 | Preset re-detection eliminated | A project with a recorded preset never triggers the multi-match refusal path on update. |
| CS-206 | Removal safety | Remove on a project with one user-modified module file preserves that file and says so; 0 silent deletions in the test matrix. |

## Out of Scope

- **Native Claude Code plugin distribution** — the phase-2 target (modules become plugins, the manifest and `add` verb remain the interface). Tracked for a future spec; nothing here may contradict it.
- **Item-level granularity** — add/remove operates on whole modules, not individual commands.
- **Third-party or project-local modules** — modules ship with the foundation only.
- **Modularizing the coding core** — `work`/`dev`/`qa`/`ops`/`doc` stay non-modular (EF-203); slimming those is the separate filtering spec's job.
- **Module dependencies** — no module requires another; the initial three are independent by construction.
- **Retroactive default changes for shipped presets** — which preset adopts which default module set ships preset-by-preset (same discipline as the filtering spec's US-4).

## Clarification Points

1. ~~**Module set v1**~~ — **RESOLVED (2026-06-06)**: `biz`, `legal`, `growth` only. `data` stays in the core: `data-pipeline` is already handled by the stack-axis skill filter of shipped presets (e.g. `nextjs` drops it), evidence that it behaves as a vertical item, not a horizontal activity. Future extraction remains a data change per EF-202.
2. ~~**Manifest vs legacy marker**~~ — **RESOLVED (2026-06-06)**: direct replacement. The manifest is the single source of truth from day one; migration happens on first update contact (EF-205) and removes the marker. Breaking change for external marker readers, flagged in CHANGELOG/release notes. One state file, zero long-term sync risk.
3. ~~**Remove semantics for user-modified files**~~ — **RESOLVED (2026-06-06)**: `add` reuses the existing update conflict handling (prompt, backup, non-interactive conflict listing) — one behavior for the user, no new code path, add ≈ module-scoped update. `remove` keeps its own stricter rule (preserve-with-notice, US-4): removing is the only destructive direction, so it stays conservative.
