# Spec: presets — extend filtering to commands and agents

> **Status: 🔵 Ready for planning** — clarified in the #264 design review; not implemented yet.

**Status**: Clarified — all 3 clarification points resolved (2026-06-06), ready for planning
**Date**: 2026-06-06
**Owner**: Chris
**Parent spec**: [`specs/presets/spec.md`](../presets/spec.md) — the original format already announces command/agent filtering (manifest example + install step 3c) but only the skill filter shipped. This spec closes that gap.
**Amended 2026-06-06**: horizontal activity domains (`biz`, `legal`, `growth`) are now handled as installable **modules** by [`specs/foundation-modules/spec.md`](../foundation-modules/spec.md), not as preset exclusions. This spec is therefore **stack-scoped**: its filters target stack-specific items (e.g. `ops-proxmox` on a web project), never the horizontal domains.

---

## Summary

A preset can already exclude out-of-stack skills at install time, but every project still receives the full catalog of 128 commands and 61 agents — including stack-specific items irrelevant to it (infrastructure tooling on a web project, mobile tooling everywhere else). This spec extends preset filtering to commands and agents so an installed project only carries the capabilities relevant to its stack: less noise when discovering commands, a smaller catalog surface injected into every session, and a foundation that honors its own "install just what you need" promise. Horizontal activity domains (`biz`, `legal`, `growth`) are out of this spec's reach — they are opt-in **modules** specified in [`specs/foundation-modules/spec.md`](../foundation-modules/spec.md).

## User Stories

### US-1 (P1) — Filtered install

**As a** developer initializing a project with a preset,
**I want** commands and agents outside my stack's scope to be excluded at install,
**so that** my sessions only expose capabilities relevant to my project and waste less context on irrelevant catalog entries.

Acceptance criteria:

- **Given** a preset that excludes the `biz`, `legal` and `growth` domains, **When** I initialize a project with that preset, **Then** no command or agent from those domains is present in the installed project.
- **Given** the same preset, **When** I initialize with the simulation option (dry-run), **Then** the plan lists every command and agent that would be removed, and nothing is removed.
- **Given** a preset that declares no command or agent filter, **When** I initialize a project, **Then** the installed catalog is identical to today's behavior (full catalog).
- **Given** a filtered install, **When** I run the project validation, **Then** validation succeeds (no integrity complaint about absent items).

### US-2 (P1) — Preset author declares the filter

**As a** preset author,
**I want** to declare in the manifest which command and agent domains (or individual items) my preset keeps or drops,
**so that** my curation is explicit, reviewable, and verified automatically.

Acceptance criteria:

- **Given** a manifest declaring a command filter by domain, **When** the preset validation runs, **Then** it accepts the manifest.
- **Given** a manifest declaring both a keep list and a drop list for the same catalog, **When** the preset validation runs, **Then** it rejects the manifest with an explicit message (exclusive choice, same rule as skills).
- **Given** a manifest declaring a filter on a vendor-pointer preset, **When** the preset validation runs, **Then** it rejects the manifest (vendor-pointer presets inherit foundation defaults, consistent with the existing tier rule).
- **Given** a manifest naming a domain or item that does not exist in the foundation catalogs, **When** the preset validation runs, **Then** the author is warned with the unknown name spelled out.

### US-3 (P2) — Update respects the filter

**As a** developer updating a project installed with a filtering preset,
**I want** the update to skip the commands and agents my preset excludes,
**so that** routine updates do not silently reintroduce the catalog noise the install removed.

Acceptance criteria:

- **Given** a project installed with a preset excluding the `biz` domain, **When** I run a full update with that preset active (explicit flag or auto-detected), **Then** no `biz` command or agent is added, and the skipped items are visible in the update report.
- **Given** the same project, **When** I run the update with preset filtering explicitly disabled, **Then** the full catalog is restored (documented escape hatch, same as for skills).
- **Given** an update in simulation mode, **Then** skipped-by-filter items are listed distinctly from updated and added items.

### US-4 (P3) — Shipped presets adopt the filter

**As a** user of a shipped preset (e.g. Next.js, FastAPI, homelab),
**I want** the maintained presets to actually use the new filter,
**so that** I benefit from the reduced catalog without writing my own preset.

Acceptance criteria:

- **Given** the Next.js preset, **When** I initialize a project with it, **Then** the command/agent counterparts of its already-dropped skills are excluded (amended 2026-06-06 — stack mirror only; `biz`/`legal`/`growth` are handled as opt-in modules by the foundation-modules spec, never as preset exclusions), and the preset description names what is excluded.
- **Given** that existing `nextjs` users may see a behavior change, **Then** the adoption ships as a minor version with an explicit CHANGELOG entry, per the parent spec's preset-versioning rule.
- **Given** any shipped preset adoption, **Then** each adoption ships as its own reviewed change with its own tests (one preset = one change, mirroring how presets themselves shipped).

## Functional Requirements

| ID | Requirement |
|----|-------------|
| EF-101 | A preset manifest MAY declare a command filter and/or an agent filter, each independent of the skill filter. |
| EF-102 | Each filter reuses the shipped skill-filter vocabulary — `drop[]` XOR `keep[]` — extended so a list entry is either an exact item name or a whole domain via the `domain:<name>` form (decided: clarification 1). |
| EF-103 | Domain entries and item entries mix freely in the same list; an item entry refines a domain entry (e.g. keep one item of an otherwise dropped domain via the opposite-mode rules in Edge Cases). |
| EF-104 | For a given catalog, exclusion mode and retention mode are mutually exclusive (keep XOR drop), mirroring the existing skill rule. |
| EF-105 | Preset validation verifies the new declarations: types, exclusivity, tier restrictions (vendor-pointer presets MUST NOT declare them), and warns on names matching nothing in the foundation. |
| EF-106 | A preset with no command/agent filter produces an install bit-for-bit identical to current behavior. |
| EF-107 | The simulation mode (dry-run) of both install and update lists every item a filter would remove or skip, without removing anything. |
| EF-108 | A full update on a project with an active filtering preset skips excluded items and reports them distinctly; disabling preset filtering restores the full catalog. |
| EF-109 | The simple-install mode keeps its current contract: foundation filters are not applied. |
| EF-110 | Project validation passes on a filtered install (absence of excluded items is never reported as a defect). |
| EF-111 | Items belonging to the core workflow domain (`work`) and the orchestration entry points (`assistant`, `assistant-auto`) cannot be excluded; validation rejects a manifest that tries. |

## Edge Cases

- **Unknown name**: a filter names `bizz` (typo) or an item removed from the foundation since the preset was written → validation warning naming the unknown entry; install proceeds, nothing matches, nothing breaks.
- **Empty result**: a domain exclusion matches zero installed items (e.g. preset combined with simple mode, or domain already absent) → silent no-op, no error.
- **Double declaration**: the same item appears in both a domain exclusion and an item retention → retention wins (refinement semantics); validated, documented.
- **Cross-catalog divergence**: a preset drops the `ops-proxmox` skill but not the `ops-proxmox` agent/command (or vice versa) → allowed (catalogs are filtered independently), but the simulation output makes the per-catalog result visible so the author can spot unintended divergence.
- **Near-name traps**: item names do not align perfectly across catalogs (e.g. a command and an agent with different names for the same topic) → no automatic cross-catalog derivation; each catalog is filtered only by its own declarations.
- **Core protection**: a manifest excluding the `work` domain or the orchestration entry points → rejected at validation (EF-111), never discovered at install time.
- **Filter against an already-customized project**: update on a project where the user manually deleted or added commands → the filter only governs what the update would copy; user-added files are untouched.
- **Manually restored excluded items**: a user copies back an excluded item into a filtered project → subsequent updates with the preset active skip them (filter semantics), so they keep working but **stop receiving updates** (staleness). Amended 2026-06-06: for horizontal domains this is fully solved by the foundation-modules spec (`add <module>` is update-tracked, and its add command heals partial manual copies). The limitation only remains for **stack-specific** items a preset excludes — accepted, since re-adding a stack item a preset dropped is a signal the preset choice itself should be revisited.

## Entities

| Entity | Description | Key attributes |
|--------|-------------|----------------|
| Preset manifest | Curated bundle declaration for one stack | name, status tier, skill filter (existing), **command filter (new)**, **agent filter (new)** |
| Catalog filter | Per-catalog selection declaration | mode (keep XOR drop), domain list, item list |
| Catalog domain | Naming prefix grouping items by purpose | name (e.g. `ops`, `biz`, `qa`), member items |
| Installed project | Result of an init, target of updates | active preset, installed catalog subset |

## Success Criteria

| ID | Criterion | Measure |
|----|-----------|---------|
| CS-101 | Filtered install reduces the catalog | A project initialized with the `nextjs` preset (stack-mirror filter) contains ≥ 6 fewer commands and ≥ 5 fewer agents than an unfiltered install (counterparts of its dropped skills). Horizontal-domain reduction is measured by the foundation-modules spec (CS-201/CS-203), not here. |
| CS-102 | Updates never reintroduce excluded items | Full update on a filtered project adds 0 excluded items, across the whole test matrix. |
| CS-103 | No regression | All existing preset tests (97) and minimal-install tests pass unchanged; a preset without the new fields installs byte-identical to before. |
| CS-104 | Coverage of the new behavior | ≥ 6 new tests per touched area (install filter, update skip, validation rules), following the existing per-preset test bar. |
| CS-105 | Spec/implementation gap closed | The parent spec's announced command/agent filtering is either implemented as announced or the parent spec is amended in the same change — zero remaining undocumented divergence. |

## Out of Scope

- **Rule filtering** — rules are path-activated and inert when their paths don't match; filtering them brings no session benefit today.
- **Automatic cross-catalog derivation** — inferring "skill dropped ⇒ agent dropped" is explicitly excluded (naming divergences make it unsafe); authors declare each catalog.
- **Minimal-mode changes** — the minimal manifest whitelist remains a separate, untouched mechanism.
- **Marketplace plugins and vendor skill recommendations** — unchanged.
- **Re-filtering existing installs outside of update** — no dedicated "apply filter now" command; the update path is the vehicle.
- **Granular per-domain restore** — initially deferred (decided 2026-06-06 AM), then **superseded the same day**: the foundation-modules spec delivers it for horizontal domains via `add <module>` (update-tracked by design). For stack-specific exclusions, restoration remains all-or-nothing (preset filtering disabled) — accepted, see Edge Cases.
- **Horizontal activity domains** (`biz`, `legal`, `growth`) — moved entirely to [`specs/foundation-modules/spec.md`](../foundation-modules/spec.md). This spec's filters MUST NOT target them (validation may enforce this once both ship).
- **Session context measurement** — quantifying the token footprint reduction is a separate effort (footprint audit idea), not a deliverable here.
- **New presets** — this spec only extends the format and adopts it in already-shipped presets (US-4).

## Clarification Points

1. ~~**Manifest vocabulary**~~ — **RESOLVED (2026-06-06)**: align on `drop`/`keep` extended with `domain:<name>` entries, same XOR rule as skills; the parent spec's historical `domains`/`excludes` example is amended in the same change (CS-105). Example:
   ```json
   "commands": { "drop": ["domain:biz", "domain:legal", "ops-proxmox"] }
   ```
2. ~~**Core protection list (EF-111)**~~ — **RESOLVED (2026-06-06)**: the floor is the `work` domain + the `assistant`/`assistant-auto` orchestration entry points, exactly as EF-111 states. `qa`/`dev`/`doc` items remain excludable — a preset may legitimately drop them for its stack.
3. ~~**US-4 adoption scope for `nextjs`**~~ — **RESOLVED (2026-06-06), then AMENDED the same day**: the initial "ambitious" decision (also exclude `biz`/`legal`/`growth`) was superseded by the foundation-modules spec — horizontal domains become opt-in modules instead of preset exclusions, which answers the underlying concern (easy, update-tracked reinstallation, especially for `legal`) better than any exclusion mitigation. `nextjs` adoption is now the conservative stack mirror only.
