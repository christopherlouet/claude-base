# Brainstorm: Horizontal domains as pure modules (opt-in base catalog)

**Date**: 2026-06-09 · **Status**: design approved, pending `/work:work-specify`

## Context

Two catalog-reduction mechanisms have grown side by side and now overlap on the
same physical catalog:

1. **Module filter** (`foundation-modules`, part 1): `defaultModules` governs the
   horizontal domains `biz` / `legal` / `growth`. The module bundles
   (`scripts/lib/modules/*.txt`) are just lists of paths that already live in
   `.claude/commands/<domain>/` and `.claude/agents/<domain>-*`. Today the
   default is **opt-out** — `defaultModules` absent ⇒ *all* modules installed
   (EF-210, "absence means all").
2. **Catalog filter** (`presets-commands-agents-filter`, part 2): a preset's
   `foundation.commands` / `foundation.agents` `drop`/`keep` filter scopes the
   rest of the catalog. `drop` is forbidden from targeting module domains
   (validation rejects it); `keep` would sweep them up implicitly.

The trigger: adopting the catalog filter in more presets surfaced that a `keep`
whitelist removes everything unlisted — **including the module-owned domains**
(verified: `keep [domain:dev,qa,work]` puts all 11 biz + 11 growth + 5 legal
commands in the removal set). So `keep` fights the module system, and the two
mechanisms only avoid collision via special-case rules. The owner's discomfort:
biz/legal/growth are *both* "in the default catalog" *and* "modules" — a
redundant, muddy mental model.

## Decision

**Horizontal domains (`biz`/`legal`/`growth`) leave the base catalog and become
pure, opt-in modules.** A default install (no preset) ships the **core only**.
There is **one** extension mechanism (modules); the preset catalog filter
governs **only the core**, so `keep` becomes module-safe by construction and the
overlap dissolves.

- **Default flips to opt-in** (supersedes part-1 EF-210): `defaultModules`
  absent ⇒ *no* horizontal modules. A preset/project opts in explicitly.
- **Strict / breaking** (owner's explicit choice): existing projects stop being
  offered horizontal on `update` (COPY-only — on-disk copies are not deleted,
  just no longer refreshed). Ships as a **major** version bump with a migration
  note ("run `claude-base add biz|legal|growth` to keep them").

### Selected implementation — Approach A (logical flip)

Files stay where they are in the repo (`.claude/commands/<domain>`,
`.claude/agents/<domain>-*`); the change is logical, not a physical move:

1. Default module set when `defaultModules` is absent → **empty** (was: all).
2. The catalog-filter lib's catalog enumeration (`catalog_list_items`) excludes
   module-owned domains, so a preset's `keep`/`drop` only ever sees the core.
3. Counts/docs distinguish **core catalog** (default install) from **full
   foundation** (core + modules).

## Approaches explored

| Approach | Idea | Strengths | Weaknesses | Complexity |
|----------|------|-----------|------------|------------|
| **A — logical flip** ✅ | Files stay; flip default to opt-in; filter excludes module domains; counts split core/modules | Smallest diff; reuses the module mechanism; achieves the observable target model | Repo layout still *shows* horizontal under `.claude/commands` (cosmetic) | Low–Med |
| **B — physical relocation** | Move biz/legal/growth to `.claude/modules/<name>/…`; `.claude/commands` = core physically | Repo layout matches the mental model exactly | Move 20 cmds + 14 agents; rewrite bundles, tests, website generator, docs referencing `.claude/commands/biz/…`; riskier migration | High |
| **C — unify filter + modules** | One "module/slice" concept for the whole catalog; presets declare slices | Conceptually purest single model | Full conceptual rewrite of both subsystems | Very high (YAGNI) |

**Why A**: it reaches the target the owner can actually observe (a default project
contains only the core; one opt-in mechanism for horizontal; `keep` is
module-safe) with the least churn and migration risk. File location in the repo
is an implementation detail; B pays large churn for mostly-cosmetic purity; C is
a rewrite nothing currently forces.

## Implications & open questions for `/work:work-specify`

- **Migration of legacy manifests** (trickiest): part 1 may have recorded
  "all modules installed" in `foundation.json`. Strict opt-in must distinguish a
  *legacy implicit-all* project (horizontal no longer refreshed) from an
  *explicit `claude-base add biz`* project (kept). Define the exact update
  behaviour and the manifest signal.
- **Counts semantics**: decide what the README badges and `counts.json` report —
  core-only (default install) vs full foundation (core + modules), and how
  `validate-counts.sh` gates both. Today's headline "128 commands / 61 agents"
  becomes "core N + modules M".
- **Lib change**: `catalog_list_items` (or a wrapper) must exclude module
  domains from the base catalog; existing `catalog-filter.bats` fixtures + new
  tests. Confirm `drop`/`keep` behave on the core-only set.
- **Validation**: the horizontal-rejection rule (`drop domain:biz` …) becomes
  redundant/clarified — module domains are simply not in the filter's universe.
- **Preset migration**: no preset currently declares `defaultModules` (all
  "absent"), so the flip affects every preset uniformly. A preset that *wants*
  horizontal (e.g. a "startup"/"saas" preset wanting `biz`) declares
  `defaultModules: ["biz"]`. `homelab-proxmox` is unaffected (proxmox/opnsense
  live in the `ops` **core** domain, not modules).
- **Supersedes**: revises `specs/foundation-modules/` EF-210 and simplifies
  `specs/presets-commands-agents-filter/` (the horizontal-rejection special
  cases). Spec should cross-reference and amend.
- **Folds in the original task**: "adopt the filter in fastapi/astro/
  react-vite-spa" becomes a clean downstream step — with horizontal out of the
  core, those presets express a `keep` of the core they need (now module-safe)
  or a `drop` of off-stack core items (flutter/proxmox/…), no special-casing.

## Next steps

1. `/work:work-specify` — user stories (default flip, filter-governs-core,
   migration/grandfathering, counts split) with prioritised P1/P2 and
   Given/When/Then acceptance criteria.
2. `/work:work-plan` — phased plan (lib core/module split → default flip →
   validation → counts/docs → preset adoption), with the major-bump + migration
   path called out.
