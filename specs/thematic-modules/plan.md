# Plan: Thematic modules

**Input**: [`spec.md`](spec.md) · **Design**: [`docs/designs/2026-06-09-core-plus-thematic-modules-design.md`](../../docs/designs/2026-06-09-core-plus-thematic-modules-design.md)
**Builds on**: shipped `horizontal-pure-modules` (#281-286) — reuses the module mechanism, opt-in default, counts split, crossing migration.
**Breaking**: existing projects stop refreshing newly-modularised items on update → MINOR-with-migration or MAJOR (decide in S5; proposed **4.0.0** as it changes the default install again).

---

## Technical context — what "module ≠ domain" touches

| Anchor | Today (domain-coupled) | Generalised |
|--------|------------------------|-------------|
| `scripts/lib/catalog-filter.sh` `_cf_domain_excluded` / `CF_EXCLUDE_DOMAINS` | excludes items whose **domain** is in the set | exclude items in a **module-owned item set** (cross-domain). Add `CF_EXCLUDE_ITEMS` (item names) honored alongside the domain set; consumers build it from all bundles |
| `scripts/lib/modules.sh` registry | `*.txt` bundle per module; `module_exists` = bundle file present | unchanged — bundles already list arbitrary paths (cross-domain works) |
| `scripts/validate-presets.sh` rejection | `module_exists "$edom"` (entry's domain is a module) | reject if the entry names an **item owned by any module** (lookup against the union of bundle items), not only a module *domain* |
| `scripts/update.sh` `migrate_horizontal_optin` | drops recorded `biz/legal/growth` from the manifest | thematic items were **core** (never manifest-recorded) → the existing absent-module filter skips them automatically; the migration step only **reports** the newly-modularised themes + **suppresses the orphan nag** for the crossing run (no manifest rewrite). Generalise the version-gated report |
| `website/scripts/generate-counts.ts` `countModuleOwned` | sums bundle paths by prefix | unchanged — already cross-domain; new bundles counted automatically |
| `scripts/lib/modules/*.txt` | biz/legal/growth | + new thematic bundles |

**Module set (resolved in spec)** — 3 horizontal + `mobile`, `self-hosted`, `iac`, `data-eng`, `observability`, `editor`, `api-data`, `ai`, `frontend` (≈ 12).

**`dev-*` split (proposed, finalise in S2 TDD):**
- `api-data`: dev-prisma, dev-supabase, dev-graphql, dev-trpc (+ their agents)
- `ai`: dev-rag, dev-mcp, dev-ai-integration
- `frontend`: dev-react-perf, dev-shadcn, dev-frontend-design (skill), dev-design-system? (decide), dev-component? (likely core)
- `editor`: dev-neovim, qa-neovim
- `mobile`: dev-flutter, ops-mobile-release, qa-mobile
- `self-hosted`: ops-proxmox, ops-opnsense, ops-vps
- `iac`: ops-infra-code, ops-k8s, ops-serverless
- `data-eng`: data-pipeline, data-modeling
- `observability`: ops-grafana-dashboard, ops-observability-stack, ops-load-testing

---

## Phases (one phase = one PR session)

### Phase 1 — Generalise the filter exclusion to module-owned items (US-1, EF-402) · S1 🎯
**Goal**: `catalog-filter` excludes any module-owned **item** (not just module domains); a `keep` whitelist over the core stays correct with cross-domain modules.
**Independent test**: a synthetic cross-domain module → its items excluded from the core enumeration / removal set though their domains are not modules; horizontal still works.
**Risk**: medium — core lib mechanism; must not regress horizontal.

### Phase 2 — Define the thematic module bundles + drift guard (US-2, US-5) · S2
**Goal**: add the new `*.txt` bundles (incl. the `dev-*` split); they are opt-in (default install excludes them); drift guard: every path exists, **no item owned by two modules**, core = full − union.
**Independent test**: `modules_list` shows the new modules; a default install excludes their items; `claude-base add mobile` installs exactly its items; no overlap.
**Risk**: medium — classification correctness; the no-overlap guard is the safety net.

### Phase 3 — Generalised validation + crossing migration + counts (US-3, US-4, EF-405/406/408) · S3
**Goal**: validation rejects a preset filter naming any module-owned item; the crossing update reports the newly-modularised themes (report-only + orphan-nag suppression, version-gated), files kept; `counts.json.core` shrinks.
**Independent test**: update matrix (existing project stops refreshing modularised items, files kept, report shown, `add` restores); validate rejects an item-naming filter; counts gate green with the smaller core.
**Risk**: high — migration semantics differ from horizontal (no manifest record to drop); version threshold.

### Phase 4 — Stack presets adopt the ergonomic keep (US-6) · S4
**Goal**: `fastapi`, `astro`, `react-vite-spa` express a module-safe `keep` over the core + `defaultModules` for the themes they need; measurably reduced; no module-owned item referenced in the filter.
**Independent test**: each preset install yields a reduced, stack-scoped core; `validate-presets` `[OK]`; per-preset reduction assertions.
**Risk**: low — per-preset, mirrors the nextjs precedent; the original triggering task.

### Phase 5 — Docs, version bump & CHANGELOG · S5
**Goal**: document the generalised model; bump VERSION (proposed 4.0.0); CHANGELOG breaking + migration note; counts gate after regen.
**Risk**: low — docs.

---

## Dependencies & sequence

```
S1 (generalise filter→items) ─▶ S2 (thematic bundles + drift) ─▶ S3 (validation + migration + counts)
                                                                       ├─▶ S4 (preset adoption)
                                                                       └─▶ S5 (docs + bump)
```
Order: S1 → S2 → S3 → S4 → S5.

## Risks & mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking again for existing projects (lose refresh of modularised items) | High | version bump + CHANGELOG + COPY-only (files kept); strict policy already owner-approved |
| Test churn (install-count expectations shrink again) | Medium | update deliberately in S2/S3; assert via specific items + dynamic counts |
| Over-fragmentation / fuzzy dev-* split | Medium | theme-level rule (EF-404); no-overlap drift guard; finalise membership in S2 |
| `dev-*` items some presets want (nextjs wants prisma/supabase/shadcn) | Medium | presets opt into the relevant modules via `defaultModules` (S4 + revisit nextjs) |
| bash 3.2 empty-array under set -u | High | apply the `${arr[@]+...}` idiom everywhere (lesson from horizontal #285) |
| module-owns-skills coupling (frontend may own a skill) | Medium | counts/drift guard count skills per bundle (precedent growth-cro) |

## Test strategy per phase

- S1: `tests/catalog-filter.bats` (item-level exclusion), `new-project-catalog-filter.bats` + `update-presets-catalog.bats` (keep module-safe with cross-domain module).
- S2: `tests/modules.bats` (new bundles, no-overlap, drift), `new-project*.bats` (default excludes thematic).
- S3: `tests/validate-presets.bats` (item rejection), `update-modules-migration.bats` (thematic crossing), counts gate test.
- S4: per-preset `new-project-*` reduction tests.
- S5: audit-docs + counts gate after regen.

Proven loop ([[session-workflow-modules-feature]]): RED→GREEN per phase, counts gate (badge + `npm --prefix website run generate`), `/code-review` high for code phases / inline for docs, PR per session, per-PR merge go. Re-run the macOS-sensitive paths mentally against bash 3.2 (the #285 lesson).

---

**Version**: 1.0 | **Created**: 2026-06-09
