# Spec: Thematic modules (generalise "module" beyond horizontal domains)

**Status**: shipped (v4.0.0, S1–S5 — PRs #288–#291 + docs/release) · **Created**: 2026-06-09 · **Design**: [`docs/designs/2026-06-09-core-plus-thematic-modules-design.md`](../../docs/designs/2026-06-09-core-plus-thematic-modules-design.md)
**Builds on**: [`specs/horizontal-pure-modules/`](../horizontal-pure-modules/spec.md) (shipped — the opt-in module mechanism, core/full counts, strict crossing migration)

## Summary

Generalise the "module" from a *horizontal-domain* bundle (`biz`/`legal`/`growth`)
to **any composable opt-in bundle**. The scattered platform/stack-specific items
that today live inside core domains (mobile, self-hosted infra, IaC, data
engineering, observability, editor tooling…) move out of the default catalog into
**thematic modules**, so a default install is a genuinely **minimal universal
core** and a preset can scope it ergonomically by whole domain. One extension
mechanism (modules) for everything beyond the core.

## Context & vocabulary

- **Core**: the cross-cutting commands/agents/skills *every* stack wants (the
  workflow + universal dev/qa/ops/doc/data essentials).
- **Module**: a named, opt-in, composable bundle — **may span several domains**
  (e.g. a `mobile` module pulls items from `dev`, `ops` and `qa`). This is the
  generalisation: a module is no longer tied to one domain.
- **Horizontal modules** (`biz`/`legal`/`growth`): the already-shipped instance.
- The opt-in default, `claude-base add/remove`, the core/full counts split, and
  the strict crossing-update migration **already exist** and are reused as-is.

## User Stories

### US-1 — A module may span domains (generalise module ≠ domain) (P1) 🎯 MVP

**As a** foundation maintainer,
**I want** a module to be able to bundle items from several core domains,
**So that** I can group "everything mobile" or "everything self-hosted" even
though those items are filed under different domains.

- **Given** a module that lists items across `dev`/`ops`/`qa`,
  **When** it is installed or removed,
  **Then** exactly its listed items are affected, regardless of their domain.
- **Given** a preset's `keep`/`drop` filter,
  **When** it is applied,
  **Then** it operates only on the core — **every** module-owned item is out of
  its jurisdiction (not just items in a "module domain"), generalising the
  horizontal behaviour.

### US-2 — Platform/stack items are opt-in thematic modules (P1) 🎯

**As a** developer,
**I want** off-stack platform tooling to be opt-in,
**So that** a default install is a minimal universal core and I add only the
themes my project needs.

- **Given** a fresh default install,
  **When** it completes,
  **Then** it contains the core only — none of the thematic-module items are
  present — and the summary advertises the available modules.
- **Given** I request a thematic module by name,
  **When** it installs,
  **Then** exactly that module's items appear and are recorded.
- **Given** the shipped module set,
  **When** I list modules,
  **Then** each module names its theme and item count, and no item belongs to
  two modules (no overlap).

### US-3 — Strict migration for newly-modularised items (P1) 🎯

**As a** maintainer of an existing project,
**I want** the update that introduces thematic modules to behave like the
horizontal migration,
**So that** I am not surprised and never lose files.

- **Given** an existing project that has items now moved into a thematic module,
  **When** it updates across the change,
  **Then** those items stop being refreshed, their on-disk files are **not
  deleted**, and the update reports the change with the `claude-base add`
  instruction.
- **Given** that project,
  **When** I add the relevant module afterwards,
  **Then** those items are tracked and refreshed again.

### US-4 — Validation understands any module-owned item (P2)

**As a** preset author,
**I want** my filter rejected if it targets any module-owned item,
**So that** the core/module boundary is enforced regardless of domain.

- **Given** a preset `keep`/`drop` naming a module-owned item (or a whole module
  theme),
  **When** it is validated,
  **Then** it is rejected with a message pointing to module opt-in instead.

### US-5 — Bundles fully cover their items, no orphans/overlaps (P2)

**As a** maintainer,
**I want** a drift guard over the module bundles,
**So that** every modularised item is owned by exactly one module and the
published counts stay correct.

- **Given** the shipped bundles,
  **When** the drift guard runs,
  **Then** every listed path exists, no item is listed by two modules, and the
  core total = full − the union of module-owned items.

### US-6 — Stack presets adopt the now-ergonomic keep (P2)

**As a** user of `fastapi`, `astro` or `react-vite-spa`,
**I want** the preset to scope the core to its stack by domain,
**So that** I get a tidy stack-relevant install without listing items one by one.

- **Given** one of these presets,
  **When** it installs,
  **Then** it expresses its scope as a module-safe `keep` over the core (whole
  domains where possible) and opts into the thematic modules its stack needs;
  the result is measurably reduced and references no module-owned item in the
  filter.

## Functional Requirements

- **EF-401** — A module bundle MAY list items from more than one domain; install/
  remove/update operate on the listed items irrespective of domain.
- **EF-402** — The preset catalog filter excludes **every** module-owned item
  (commands, agents, skills) from the core it governs — generalising the
  horizontal-module exclusion from "module domains" to "module-owned items".
- **EF-403** — A default install contains zero items belonging to any module
  (horizontal or thematic); each is installed only via opt-in.
- **EF-404** — Modules are grouped at **theme level, never per-item** (each module
  owns a coherent theme); **no item belongs to two modules**. The shipped set is
  **15** incl. the 3 horizontal. A **mutually-exclusive choice** counts as a theme
  even when it currently owns one item, because a project picks exactly one — so it
  gets its own module rather than being bundled into the agnostic theme tooling.
  Two kinds: (a) **frameworks** — `nextjs` (Next.js) split from the framework-agnostic
  `frontend` module, `flutter` (Flutter) from the agnostic `mobile` lifecycle module;
  (b) **alternative workflows** — `gitflow` (the GitFlow branching model) split from
  the core, since it is incompatible with the foundation's default trunk-ish flow.
  The per-item ban still rules out splitting an **additive** library (e.g. shadcn,
  Prisma) into its own module. Separately, a vendor-specific item that lived in the
  core moves to the relevant module rather than staying universal — e.g. `ops-vercel`
  (the Vercel deploy target) joins `iac` alongside `serverless`.
- **EF-405** — The crossing-update migration applies to newly-modularised items
  exactly as to horizontal ones: stop refresh, never delete, report + `add` hint,
  idempotent.
- **EF-406** — Validation rejects a preset filter naming any module-owned item or
  module theme, pointing to module opt-in.
- **EF-407** — A drift guard asserts: every bundle path exists; no item is owned
  by two modules; core total = full − union(module-owned). Skill-owning modules
  (e.g. `growth`/`growth-cro`) are counted correctly.
- **EF-408** — Published counts: the `core` totals shrink to reflect the items
  moved into thematic modules; the full-foundation totals are unchanged.
- **EF-409** — Stack presets (`fastapi`, `astro`, `react-vite-spa`) express their
  scope with a module-safe `keep` and `defaultModules`, referencing no
  module-owned item in the filter.
- **EF-410** — Empty-set safety: all module/array handling stays safe under
  `set -u` on bash 3.2 (the empty-array lesson from horizontal-pure-modules).

## Edge Cases

- An item with a command but **no agent** (e.g. `ops-mobile-release`, `qa-mobile`)
  → the module lists only the catalogs that exist for it (asymmetric membership),
  no unknown-name warning.
- A module that owns a **skill** (precedent: `growth`/`growth-cro`) → counted in
  the core/full split.
- An existing project that had **some** of a module's items hand-removed → the
  crossing migration touches only what's present; no error on missing files.
- A preset that opts into a module **and** keep-scopes the core → module installed
  in full; keep applies only to the core.
- Re-running the migration / update → idempotent (no duplicate reports).

## Entities

- **Core catalog** — default-installed cross-cutting items.
- **Module** — a named, cross-domain-capable, opt-in bundle (horizontal or
  thematic), owning a disjoint set of catalog items.
- **Project module record** — the manifest's recorded modules (unchanged
  mechanism).
- **Preset filter** — core-only `keep`/`drop` + `defaultModules`.

## Success Criteria

- **CS-401** — After the change, a default install's `core` command total is
  reduced by the count of items moved into thematic modules (≥ ~12 commands
  across the proposed modules), with zero module-owned items present.
- **CS-402** — Adding a thematic module restores exactly its items (commands +
  agents + skills) and records it; removing reverses it.
- **CS-403** — No item is owned by two modules; the drift guard passes and the
  counts gate validates `core = full − union(module-owned)`.
- **CS-404** — An existing project crossing the change keeps its on-disk files,
  stops refreshing the modularised ones, and is told how to opt back in —
  verified by an update-matrix test.
- **CS-405** — `fastapi`, `astro`, `react-vite-spa` each install a measurably
  reduced, stack-scoped core with no module-owned item referenced in the filter.
- **CS-406** — ≥ 6 new tests per touched area (generalised exclusion, new module
  bundles, migration, preset adoption).

## Out of Scope

- **Physical relocation** of files out of `.claude/commands/` etc. (logical
  membership via bundles only).
- **Unifying** the preset filter and the module system into a single concept.
- Creating **new** commands/agents/skills (only reclassifying existing ones).
- Per-item or finer-than-theme modularisation (anti-fragmentation, EF-404).
- Changing the horizontal modules (`biz`/`legal`/`growth`) — unchanged.

## Clarification Points — RESOLVED (2026-06-09)

1. ~~Stack-specific `dev-*` tools~~ → **become modules.** `prisma`, `supabase`,
   `graphql`, `trpc`, `rag`, `mcp`, `ai-integration`, `react-perf`, `shadcn` leave
   the core. ⚠️ They are NOT one theme — planning must split them into a small set
   of coherent thematic modules (proposed: **`api-data`** = prisma/supabase/graphql/
   trpc; **`ai`** = rag/mcp/ai-integration; **`frontend`** = react-perf/shadcn,
   joined by the frontend skills). Finalise membership in planning.
2. ~~Borderline `ops` items~~ → **proposed default accepted**: `ops-monitoring`
   stays core; `ops-serverless` joins `iac`; `ops-database`/`backup`/
   `disaster-recovery` stay core.
3. ~~`editor` module~~ → **yes**, ship an `editor` module (`dev-neovim`,
   `qa-neovim`) despite the low item count.

### Consequence — module count vs anti-fragmentation (note for planning)

Modularising the `dev-*` tools (CP1) pushes the total beyond the original "~8"
target. Confirmed module set ≈ **11–12**: 3 horizontal (`biz`/`legal`/`growth`)
+ `mobile`, `self-hosted`, `iac`, `data-eng`, `observability`, `editor`,
`api-data`, `ai`, `frontend`. EF-404 is relaxed accordingly: the rule is
**theme-level grouping, never per-item modules** (each module owns a coherent,
multi-item theme), not a hard cap of 8. Planning resolves the exact `dev-*`
split + final membership.
