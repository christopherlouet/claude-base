# Spec: Horizontal domains as pure opt-in modules

**Status**: draft · **Created**: 2026-06-09 · **Design**: [`docs/designs/2026-06-09-horizontal-domains-as-pure-modules-design.md`](../../docs/designs/2026-06-09-horizontal-domains-as-pure-modules-design.md)
**Supersedes**: `specs/foundation-modules/` EF-210 ("absence means all modules")

## Summary

The horizontal domains `biz`, `legal` and `growth` leave the default catalog and
become **pure opt-in modules**. A fresh project gets the **core** only; the
business/legal/growth toolsets are installed only when explicitly requested. This
gives the foundation a single mental model — one extension mechanism (modules) —
and removes the overlap where a preset's catalog filter and the module system
both governed the same items.

## Context & vocabulary

- **Core catalog**: the cross-cutting commands/agents every stack uses (work,
  dev, qa, ops, doc, data, + the domainless entry points). ~101 commands / 47
  agents today.
- **Module**: an opt-in horizontal bundle — `biz`, `legal`, `growth` (~27
  commands / 14 agents combined).
- **Preset catalog filter**: a preset's `keep`/`drop` list scoping which *core*
  commands/agents a stack installs.
- Today (before this change): a default install ships **everything** (core +
  all three horizontal domains); modules are opt-*out*.

## User Stories

### US-1 — Core-only by default (P1 · MVP) 🎯

**As a** developer starting a new project,
**I want** a default install to contain only the cross-cutting core,
**So that** I am not handed business/legal/growth tooling I did not ask for.

- **Given** a fresh install with no preset and no module request,
  **When** it completes,
  **Then** no `biz`/`legal`/`growth` commands or agents are present, and every
  core command/agent is present.
- **Given** the same install,
  **When** the summary prints,
  **Then** it states the core was installed and advertises the available
  modules with how to add them.
- **Given** a preset that does not request modules,
  **When** it installs,
  **Then** the result is core-only plus the preset's own scoping — still no
  horizontal domains.

### US-2 — Explicit opt-in to a horizontal module (P1) 🎯

**As a** developer who wants the business toolset,
**I want** to opt into a module explicitly,
**So that** I get exactly the horizontal domains I choose, on demand.

- **Given** a project (fresh or existing),
  **When** I request a module by name,
  **Then** that module's commands/agents are installed and recorded as
  explicitly chosen.
- **Given** a preset that declares it wants a module,
  **When** it installs,
  **Then** that module is installed and the others are not.
- **Given** a request for an unknown module name,
  **When** it runs,
  **Then** it fails with a clear message naming the valid modules.

### US-3 — Predictable strict migration for existing projects (P1) 🎯

**As a** maintainer of an existing project,
**I want** the update that crosses this change to behave uniformly and be clearly
communicated,
**So that** I am never silently surprised by missing or deleted tooling.

> **Decision (2026-06-09): pure strict, no grandfathering.** The manifest records
> only the *set* of installed modules, not whether each was an explicit choice or
> a default. So the migration cannot — and deliberately does not — preserve
> "explicit" pre-change opt-ins: **all** horizontal modules carried from before
> the change become opt-in.

- **Given** an existing project carrying any horizontal module from before this
  change,
  **When** it updates for the first time after the change,
  **Then** those horizontal domains stop being refreshed, their on-disk files are
  **not deleted**, and the update reports the change with the `claude-base add`
  instruction to resume refresh.
- **Given** that same project,
  **When** I run the add command for a module afterwards,
  **Then** it is recorded under the new model and refreshed by future updates.
- **Given** any such crossing update,
  **When** it runs,
  **Then** the change is documented as a breaking change tied to a major version,
  with a one-line "how to restore" instruction.

### US-4 — The preset catalog filter governs the core only (P1) 🎯

**As a** preset author,
**I want** my `keep`/`drop` list to apply only to the core,
**So that** I can use a `keep` whitelist without accidentally stripping modules.

- **Given** a preset with a `keep` list of core items,
  **When** it installs,
  **Then** only the listed core items (plus the protected floor) are kept, and
  **no** horizontal module is affected by the filter.
- **Given** a preset filter that names a horizontal domain or item,
  **When** it is validated,
  **Then** it is rejected with a message pointing to module opt-in instead.
- **Given** any preset filter,
  **When** it runs at install and at update,
  **Then** the two behave identically with respect to the core/module boundary.

### US-5 — Honest counts for core vs full foundation (P2)

**As a** reader of the project,
**I want** the published counts to distinguish what a default project gets from
the full foundation,
**So that** the numbers are not misleading once horizontal is opt-in.

- **Given** the published counts,
  **When** I read them,
  **Then** I can tell the core total (default install) from the full-foundation
  total (core + modules).
- **Given** the counts drift gate,
  **When** it runs,
  **Then** it validates both totals and fails on any drift.

### US-6 — Migration & model documentation (P2)

**As a** user or contributor,
**I want** clear docs on the new model and the migration,
**So that** I understand "core + opt-in modules" and how to restore horizontal.

- **Given** the docs,
  **When** I look for the model,
  **Then** "core catalog vs opt-in modules" is explained, with the restore
  instruction, the breaking-change note, and the superseded prior rule called out.

### US-7 — Stack presets adopt a module-safe core filter (P3)

**As a** user of the `fastapi`, `astro` or `react-vite-spa` preset,
**I want** the preset to scope the core to its stack,
**So that** I get a tidy, stack-relevant core install.

- **Given** one of these presets,
  **When** it installs,
  **Then** it expresses its scope as a filter over the **core** only, no
  horizontal items referenced, and the install is measurably smaller than the
  unfiltered core where the stack excludes core items.

## Functional Requirements

- **EF-301** — With no explicit module request, a default install contains zero
  horizontal (`biz`/`legal`/`growth`) commands and agents.
- **EF-302** — Absence of a module declaration means **no** modules (opt-in);
  this replaces the prior "absence means all".
- **EF-303** — A core install contains every core command/agent (the floor —
  work domain + the assistant entry points — is always present).
- **EF-304** — A module can be requested by name (per-project) and by a preset
  declaration; both record the choice durably.
- **EF-305** — An unknown module name is rejected with a message naming valid
  modules.
- **EF-306** — On update, a module recorded as chosen **under the new model**
  (a post-change add, or a preset module declaration) is preserved and refreshed.
- **EF-307** — On the first update crossing this change, every horizontal module
  carried from before the change stops being refreshed; on-disk files are
  **never deleted**; the update reports the change and the `add` command.
- **EF-308** — The crossing update is identified by foundation version; pre-change
  horizontal module records are reset to opt-in **uniformly** (no explicit/implicit
  distinction — pure strict, the manifest cannot express it retroactively).
- **EF-309** — The preset `keep`/`drop` filter operates only over the core; a
  `keep` whitelist never removes a horizontal module item.
- **EF-310** — A preset filter naming a horizontal domain/item is rejected with
  an actionable message pointing to module opt-in.
- **EF-311** — Published counts expose a **core** total and a **full-foundation**
  total; the drift gate validates both.
- **EF-312** — The change ships as a **major** version bump with a CHANGELOG
  breaking-change entry and a one-line restore instruction.
- **EF-313** — Documentation explains the "core + opt-in modules" model and the
  migration, and marks the superseded prior rule.

## Edge Cases

- Project with **all three** modules previously installed-by-default → update
  stops refreshing all three (legacy path), files retained, single clear report.
- Project that had all three by default → the crossing update stops refreshing
  all three uniformly (pure strict); files retained; single clear report.
  (A pre-change `add` is indistinguishable in the manifest and is reset too —
  re-add to resume, EF-308.)
- Preset requesting a module **and** carrying a core `keep` filter → module
  installed in full; `keep` scopes only the core.
- A preset `keep` list that omits everything except the floor → core reduced to
  the floor, modules untouched.
- Empty/again-run install or update → idempotent; no duplicate reports, no
  re-deletion.
- A `keep` list naming an item that no longer exists in the core → non-fatal
  warning (existing behaviour preserved).
- Re-adding a module after the legacy path dropped it → restores it and records
  it as explicit.

## Entities

- **Core catalog** — the default-installed cross-cutting commands/agents.
- **Module** — a named opt-in horizontal bundle (`biz`, `legal`, `growth`).
- **Project module record** — durable per-project record of which modules were
  chosen, distinguishing explicit opt-in from legacy implicit-all.
- **Preset filter** — a preset's core-only `keep`/`drop` scoping.

## Success Criteria

- **CS-301** — A default (no-preset) install yields **101 commands / 47 agents**
  (core only), down from 128 / 61, with zero `biz`/`legal`/`growth` items.
- **CS-302** — Requesting a module restores its exact item count (e.g. `biz` →
  +11 commands / +4 agents) and records it as explicit.
- **CS-303** — An existing project carrying horizontal modules loses their
  refresh (not their files) on the crossing update, with a clear report; a
  subsequent `add` restores refresh — verified by an update-matrix test.
- **CS-304** — A preset `keep` whitelist over the core never removes a module
  item (verified by test), resolving the keep-vs-module conflict.
- **CS-305** — Counts gate passes with both core and full-foundation totals; no
  doc claims a default project gets the full catalog.
- **CS-306** — ≥ 6 new tests per touched area (default flip, filter-governs-core,
  migration matrix), per the existing per-feature bar.
- **CS-307** — `fastapi`, `astro`, `react-vite-spa` each install a measurably
  reduced, module-free core scoped to the stack.

## Out of Scope

- **Physical relocation** of horizontal files out of `.claude/commands/` /
  `.claude/agents/` (design Approach B). Files stay in place in the repo.
- **Unifying** the preset filter and the module system into a single concept
  (design Approach C).
- Creating **new** modules or splitting the core into finer modules.
- Changing skills filtering (`foundation.skills`) — unaffected by this change.
- Reworking detection, marketplace plugins, or vendor-pointer presets.

## Clarification Points

1. ~~**Legacy detection signal**~~ — **RESOLVED (2026-06-09): pure strict.** The
   manifest records only the module *set*, so the migration cannot distinguish
   explicit from implicit retroactively and deliberately does not try: the
   crossing update (identified by foundation version) resets all pre-change
   horizontal to opt-in uniformly; re-add to resume (EF-307/EF-308).
2. **Counts headline** — do the README badges show the **core** total, the
   **full-foundation** total, or both side by side (EF-311)? Affects wording only;
   default proposal: show core as the headline with full-foundation noted beside
   it.
3. **Module-wanting presets** — should any *shipped* preset opt into a horizontal
   module by default (e.g. a future "saas"/"startup" preset wanting `biz`), or do
   all current presets ship core-only (US-7)? Current presets declare none; default
   proposal: all ship core-only, module opt-in stays a user/edge decision.
