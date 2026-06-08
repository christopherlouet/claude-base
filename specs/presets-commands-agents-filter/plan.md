# Implementation Plan: preset command & agent filtering

**Branch**: `feature/preset-cmd-agent-filter` (per-session children `…-s1`, `…-s2`, …)
**Date**: 2026-06-08
**Spec**: [`spec.md`](spec.md)
**Status**: Validated — R1 resolved 2026-06-08 (keep-mode = whitelist); ready for S1

---

## Summary

A preset can already drop/keep **skills** at install and update; every project still receives the full
catalog of 128 commands and 61 agents. This plan extends the existing skill-filter mechanism to the
**commands** and **agents** catalogs, reusing the modules feature's single-source-of-truth pattern: a new
shared library `scripts/lib/catalog-filter.sh` owns domain resolution, entry matching, the protected floor
(EF-111) and catalog enumeration; the three existing call sites (`new-project.sh` install,
`update.sh` update, `validate-presets.sh` validation) consume it. List entries gain a `domain:<name>`
form on top of exact item names (EF-102/103). Horizontal domains (`biz`/`legal`/`growth`) are out of
scope — they are owned by the shipped foundation-modules feature, and validation rejects any attempt to
target them here (reconciles the stale clarification-1 example with the 2026-06-06 amendment).

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language** | Bash (POSIX-leaning, macOS bash 3.2 floor) | No associative arrays, no `readarray`, parallel arrays — same discipline as `lib/modules.sh` |
| **Data format** | JSON manifests under `.claude/presets/*.json`, parsed with `jq` | `foundation.commands` + `foundation.agents` mirror `foundation.skills` |
| **Tests** | `bats` (`tests/*.bats`) + `shellcheck` | New `tests/catalog-filter.bats`; additions to install/update/validate suites |
| **Target** | The foundation's own install/update/validate scripts | No application runtime |

### Constraints

- **macOS bash 3.2 portability** — mirror the patterns already in `lib/modules.sh` (parallel arrays, `while read`, no `readarray`).
- **Backward compatibility (EF-106)** — a preset with no command/agent filter must install **byte-identical** to today. The new code paths must be inert when the fields are absent.
- **Simple-install untouched (EF-109)** — foundation filters are not applied in simple mode; do not touch that path.
- **Independent catalogs (Edge: cross-catalog divergence)** — commands and agents are filtered only by their own declarations; no `skill dropped ⇒ agent dropped` derivation (explicit Out of Scope).
- **Counts gate** — the repo still ships the full catalog (filtering only affects *installed projects*), so `validate-counts` / the website regen should be unaffected; verify, don't assume.

### Expected behaviour (success measures from spec)

| Measure | Target |
|--------|--------|
| CS-101 | `nextjs` install: ≥ 6 fewer commands, ≥ 5 fewer agents than unfiltered |
| CS-102 | Update on a filtered project re-introduces **0** excluded items |
| CS-103 | All existing preset tests (97) + minimal-install tests pass unchanged; no-filter preset installs byte-identical |
| CS-104 | ≥ 6 new tests per touched area (install, update, validation) |
| CS-105 | Parent spec `specs/presets/spec.md` amended in the same change — zero undocumented divergence |

---

## Constitution / Conventions Check

- [x] Follows project conventions (CLAUDE.md, `.claude/rules/git.md`, bash discipline of `lib/modules.sh`)
- [x] Consistent with existing architecture — extends the skill-filter mechanism, does not replace it
- [x] No over-engineering — one shared lib, three thin consumers; no new manifest schema concepts beyond `domain:`
- [x] Tests planned — TDD per phase, RED before GREEN, per-PR session

---

## Project Structure (this feature)

```
specs/presets-commands-agents-filter/
├── spec.md       # Functional specification (clarified)
├── plan.md       # This file
└── tasks.md      # Task breakdown
```

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `scripts/lib/catalog-filter.sh` | **SSOT** for command/agent filtering: domain resolution per catalog, entry matching (`domain:<name>` + exact item), removal-set computation, protected floor (EF-111), catalog enumeration (list domains/items) and unknown-name detection |
| `tests/catalog-filter.bats` | Unit tests for the lib — domain resolution per catalog, matching, floor protection, refinement semantics, enumeration |

### To modify

| File | Modification |
|------|--------------|
| `scripts/new-project.sh` | `load_preset()` reads `foundation.commands`/`foundation.agents`; new `apply_catalog_filters()` (commands+agents) called next to `apply_preset_filter`/`apply_modules_filter` (lines ~1330); dry-run lines for each removed item |
| `scripts/update.sh` | Read active preset's command/agent filters (extend `_load_skill_field` pattern); per-file skip inside `update_directory("commands")` and `update_directory("agents")`; report skipped-by-filter distinctly in summary + dry-run |
| `scripts/validate-presets.sh` | Validate `foundation.commands`/`foundation.agents`: drop XOR keep, vendor-pointer tier ban, EF-111 core-protection **rejection**, horizontal-domain **rejection** (biz/legal/growth → point to `defaultModules`), unknown-name **warning** via catalog enumeration |
| `.claude/presets/nextjs.json` | US-4 adoption — add `foundation.commands`/`foundation.agents` stack-mirror drop lists; update `description` to name what is excluded; bump version (minor) |
| `specs/presets/spec.md` | CS-105 — amend the parent spec: command/agent filtering now implemented as announced; correct the stale `domains`/`excludes` example to the shipped `drop`/`keep` + `domain:` vocabulary |
| `.claude/presets/README.md` (+ relevant `docs/`) | Document the new manifest fields and `domain:<name>` form |
| `CHANGELOG.md` | Minor-version entry for the format extension + nextjs adoption (per parent spec versioning rule) |

### Tests to add (per area, CS-104 ≥ 6 each)

| File | Coverage |
|------|----------|
| `tests/catalog-filter.bats` | lib unit: domain resolution, matching, floor, enumeration, refinement |
| install suite (`tests/new-project*.bats` / existing preset install tests) | filtered install removes correct items, dry-run lists them, no-filter = byte-identical, validation passes on filtered install |
| update suite (`tests/update*.bats`) | update skips excluded commands/agents, reports them, disabling filter restores full catalog, dry-run distinct listing |
| validate suite (`tests/validate-presets*.bats`) | XOR rejection, vendor-pointer ban, EF-111 rejection, horizontal-domain rejection, unknown-name warning |

> Exact existing test filenames to be confirmed at each session start (`ls tests/`); the modules feature added to existing suites rather than always creating new files.

---

## Chosen Approach

### Architecture — one shared lib, three thin consumers

```
                       scripts/lib/catalog-filter.sh   ← SSOT
                        (domain resolve · match · floor · enumerate)
                          ▲              ▲              ▲
            ┌─────────────┘              │              └─────────────┐
   new-project.sh                   update.sh                 validate-presets.sh
  apply_catalog_filters()      per-file skip in            validate foundation.commands
  (bulk remove after copy)     update_directory()          /agents (XOR · tier · floor ·
                               (copy-only, never deletes)   horizontal-ban · unknown-warn)
```

This mirrors part 1, where `lib/modules.sh` became the SSOT for `new-project.sh` (`apply_modules_filter`),
`update.sh` (`_load_module_filter` / `path_module`) and `validate-presets.sh` (`module_exists` in the
`defaultModules` skeleton). We reuse that exact shape so the three consumers cannot drift.

### Catalog model (the one non-obvious part)

Domain membership is resolved **per catalog**, because the two catalogs are laid out differently on disk:

| Catalog | Disk layout | Domain of an item | Domainless items |
|---------|-------------|-------------------|------------------|
| commands | `.claude/commands/<domain>/<name>.md` (subdirs) | first path segment after `commands/` | top-level `.md`: `assistant`, `assistant-auto`, `git-rename`, `lessons` |
| agents | `.claude/agents/<domain>-<name>.md` (flat) | filename stem prefix before the first `-` | (none — every agent is prefixed) |

`catalog-filter.sh` exposes (names indicative, finalised in TDD):

- `catalog_item_domain <catalog> <relpath>` → prints the item's domain (empty for domainless commands).
- `catalog_list_domains <catalog>` / `catalog_list_items <catalog>` → enumeration for validation & unknown-name warnings.
- `catalog_entry_matches <catalog> <entry> <relpath>` → true if `entry` (`domain:X` or exact item) matches the item.
- `catalog_removal_set <catalog> <mode> <entries…>` → the set of items to remove, **floor subtracted**.
- `catalog_floor_violations <catalog> <mode> <entries…>` → entries that try to remove a protected item (for validation rejection).

### Filter resolution semantics (per catalog)

Mode is `drop` **XOR** `keep` (validator-enforced, identical to skills). Let `M` = items matching any entry
(by `domain:` or exact name):

- **drop**: removal set `R = M \ floor`
- **keep**: removal set `R = (allItems \ M) \ floor`

The **protected floor** (EF-111) is force-kept in both modes: the `work` command/agent domain + the
`assistant` and `assistant-auto` command entry points. Floor items are *never* in `R`, even in keep mode
when omitted from the keep list.

### Reconciling the two contradictory spec passages on horizontal domains

- Clarification 1 (line 129) shows `"drop": ["domain:biz", "domain:legal", "ops-proxmox"]`.
- The 2026-06-06 amendment (lines 9, 123) says these filters **MUST NOT** target `biz`/`legal`/`growth`
  ("validation may enforce this once both ship") — they are now opt-in **modules** (part 1, shipped).

Both specs have now shipped, so we take the amendment as authoritative: **validation rejects** a command/agent
filter naming a module-owned domain (`domain:biz|legal|growth`) or a module-owned item, with a message
pointing the author to `defaultModules`. The clarification-1 example is stale and is corrected in the spec as
part of CS-105. This prevents two mechanisms (preset filter vs. modules) fighting over the same files.

### Rationale

Extracting the lib first (Phase 1) is what made part 1's three consumers stay consistent and is what lets US-1
and US-2 be built test-first against a stable contract. The alternative — copy-pasting the skill-filter logic
into commands/agents in each of the three scripts — was rejected: it triples the surface for drift (the skill
filter is *already* duplicated across install bulk-remove vs. update per-file-skip; we do not want to triple
*that* too) and makes `domain:` semantics impossible to keep identical across call sites.

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Inline the filter in each of the 3 scripts (no shared lib) | Drift risk; `domain:` + floor logic would diverge between install/update/validate |
| One generic filter over *all* catalogs incl. skills (refactor skills onto the new lib too) | Larger blast radius, risks CS-103 byte-identity regression on skills; defer — keep skills on their proven path, only *commands/agents* on the new lib |
| Allow `domain:biz/legal/growth` (honour clarification-1 example) | Contradicts the authoritative amendment; would let preset filters and modules fight over the same files |

---

## Implementation Phases

> Each phase = one TDD session = one PR (squash-merge, `type(scope): … (Sx) (#NNN)`), matching the
> proven foundation-modules cadence. Merge on per-PR go once CI is green.

### Phase 1 — Catalog-filter library (blocking) · S1

**Objective**: SSOT every consumer depends on. EF-102/103/104/111 core logic, no consumer wired yet.

- [ ] T001 [P] — RED: `tests/catalog-filter.bats` covering domain resolution (both catalogs, domainless commands), `domain:`+exact matching, drop/keep removal sets, floor protection, enumeration, unknown-name detection
- [ ] T002 — GREEN: `scripts/lib/catalog-filter.sh` implementing the helpers above (bash 3.2 discipline)
- [ ] T003 — shellcheck clean (`-S warning`, no `-x`); REFACTOR

**Checkpoint**: lib green in isolation, no behaviour change to install/update/validate.

### Phase 2 — US-1 (P1) Filtered install · S2

**Objective**: a preset's command/agent filter is applied at init.

- [ ] T004 [P] [US1] — RED: install tests — filtered install removes the declared commands/agents; dry-run lists every removed item; no-filter preset = byte-identical (CS-103); project validation passes on filtered install (EF-110)
- [ ] T005 [US1] — GREEN: `load_preset()` reads `foundation.commands`/`foundation.agents`; `apply_catalog_filters()` via `catalog-filter.sh`, wired next to `apply_modules_filter` (~`new-project.sh:1330`)
- [ ] T006 [US1] — dry-run output lines for each removed command/agent; verify EF-106 inert path

**Checkpoint**: `nextjs`-shaped manual filter reduces a real install; full suite green.

### Phase 3 — US-2 (P1) Validation · S3

**Objective**: preset author's filter is validated and core/horizontal protections enforced.

- [ ] T007 [P] [US2] — RED: validate-presets tests — drop XOR keep rejection; vendor-pointer tier ban; EF-111 floor rejection (`domain:work`, `assistant`, `assistant-auto`); horizontal-domain rejection (biz/legal/growth → defaultModules hint); unknown-name warning
- [ ] T008 [US2] — GREEN: extend `validate-presets.sh` reusing the `defaultModules` skeleton shape + `catalog_*` enumeration
- [ ] T009 [US2] — confirm messages are explicit (name the offending entry); shellcheck clean

**Checkpoint**: a malformed filter is caught with an actionable message; good filters pass.

### Phase 4 — US-3 (P2) Update respects the filter · S4

**Objective**: update skips excluded commands/agents, reports them, escape hatch restores full catalog.

- [ ] T010 [P] [US3] — RED: update tests — excluded commands/agents not re-added (CS-102); skipped items reported distinctly; `--no-preset-filter` (existing escape hatch) restores full catalog; dry-run lists skipped-by-filter distinctly from updated/added
- [ ] T011 [US3] — GREEN: load command/agent filters from active preset (extend `_load_skill_field`); per-file skip in `update_directory("commands")` / `("agents")` (copy-only, EF-011); summary reporting
- [ ] T012 [US3] — verify interaction with the modules skip (both filters can fire on the same run); shellcheck clean

**Checkpoint**: full update matrix green; 0 excluded items re-introduced.

### Phase 5 — US-4 (P3) nextjs adoption · S5

**Objective**: ship the filter in a real preset (conservative stack mirror only).

- [ ] T013 [P] [US4] — RED: test that `nextjs` install yields ≥ 6 fewer commands and ≥ 5 fewer agents (CS-101), counterparts of its already-dropped skills
- [ ] T014 [US4] — GREEN: add `foundation.commands`/`foundation.agents` drop lists to `.claude/presets/nextjs.json` (dev-flutter, ops-mobile-release, ops-opnsense, ops-proxmox, ops-infra-code, data-pipeline); update `description`; bump minor version
- [ ] T015 [US4] — CHANGELOG entry (minor, behaviour-change note for existing nextjs users)

**Checkpoint**: `nextjs` is the worked example; one preset = one reviewed change.

### Phase 6 — Polish, docs & spec reconciliation · S6

- [ ] T016 [P] — CS-105: amend `specs/presets/spec.md` (announced filtering now implemented; correct stale example)
- [ ] T017 [P] — document new fields + `domain:<name>` in `.claude/presets/README.md` and relevant `docs/`
- [ ] T018 — counts gate: run `npm --prefix website run generate`, confirm no catalog-count drift; update any doc that claims "every project gets 128/61"
- [ ] T019 — `/code-review high` per session + adversarial verify; final full `bats tests/` + shellcheck with CI options

---

## Risks and Mitigations

| Risk | Impact | Prob. | Mitigation |
|------|--------|-------|------------|
| **R1 — `domain:`+item refinement / "retention wins" semantics.** ✅ **RESOLVED 2026-06-08 (Chris):** keep-mode = whitelist. Within one catalog list all entries share a single polarity (drop XOR keep, as for skills). To keep one item of an otherwise-excluded domain, use **keep mode** (e.g. `keep: ["domain:work", "ops-deploy"]`). Cross-mode refinement (inline `!item` rescue inside a drop list) is **deferred** — no new syntax in v1. "Retention wins" is implemented as: an exact item entry overrides a same-list `domain:` entry idempotently. S3 builds against this. | High (shaped US-2 data model) | — | Decided. |
| R2 — Byte-identity regression on no-filter installs (CS-103) | High | Low | EF-106 test in S2 asserts byte-identity; keep new code paths inert when fields absent; do **not** touch the skills path |
| R3 — Spec self-contradiction (horizontal domains) misread | Medium | Low | Plan §"Reconciling…" resolves it (amendment authoritative); validation rejects biz/legal/growth; spec corrected in S6 |
| R4 — Agent prefix ≠ real domain (e.g. `wcag-audit` → prefix `wcag`) | Low | Medium | Enumeration derives valid domains from disk; `domain:wcag` either matches what's there or triggers the unknown-name warning — no crash |
| R5 — macOS bash 3.2 portability | Medium | Medium | Mirror `lib/modules.sh` (parallel arrays, `while read`); shellcheck `-S warning` without `-x` (the `-x` masked an SC2034 that broke CI in part 1) |
| R6 — Modules filter + preset filter interaction on update | Medium | Low | S4 test exercises both firing in one run; they target disjoint domains (modules = biz/legal/growth, preset = stack), so no overlap by construction |

---

## Dependencies and Execution Order

```
Phase 1 (lib) ──┬──▶ Phase 2 (US-1 install, P1)
                ├──▶ Phase 3 (US-2 validation, P1)   [needs R1 decision]
                └──▶ Phase 4 (US-3 update, P2)
Phases 2–4 ─────────▶ Phase 5 (US-4 nextjs, P3) ─────▶ Phase 6 (docs/spec/polish)
```

US-1, US-2, US-3 each depend only on Phase 1 and are independently testable. US-4 needs install (US-1) and
ideally update (US-3) to prove CS-101/CS-102 on a real preset. Validation (US-2) gates *authoring* and so is
sequenced early, but does not block install mechanics.

---

## Validation Criteria

### Gate 1 — before starting
- [x] Spec approved & clarified
- [ ] Plan reviewed by Chris
- [x] **R1 resolved** (keep-mode = whitelist, 2026-06-08)

### Gate 2 — before each merge (per session)
- [ ] Tests RED→GREEN, ≥ 6 new tests for the touched area (CS-104)
- [ ] Full `bats tests/` + shellcheck (CI options) green
- [ ] `/code-review high` confirmed findings fixed, false positives refuted
- [ ] tasks.md checkboxes ticked; counts gate run if docs touched

### Gate 3 — before final
- [ ] CS-101…CS-105 all verified
- [ ] Parent spec amended (CS-105); README/docs updated
- [ ] CHANGELOG minor entry

---

## Notes

- Per-session PR cadence and the dev-tdd → code-review → PR loop are the proven pattern from
  foundation-modules (see memory `session-workflow-modules-feature`). Reuse it verbatim.
- The escape hatch for US-3 ("disable preset filtering, restore full catalog") already exists for skills as a
  flag in `update.sh` — extend its scope to commands/agents rather than inventing a new flag.

---

**Version**: 1.0 | **Created**: 2026-06-08
