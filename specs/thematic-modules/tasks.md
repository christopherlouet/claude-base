# Tasks: Thematic modules

**Input**: [`plan.md`](plan.md) · [`spec.md`](spec.md)
**Builds on**: shipped `horizontal-pure-modules` (#281-286). One phase = one PR (squash, per-PR merge go). TDD: RED test first.

---

## Phase 1 — Generalise filter exclusion to module-owned items (US-1) · S1

### Tests (RED first) ⚠️
- [ ] T001 [P] [US1] — `tests/catalog-filter.bats`: with an item-level exclusion set (cross-domain items whose domains are NOT modules), `catalog_list_items` / `catalog_removal_set` skip exactly those items; a `keep [domain:dev]` over a core that has a cross-domain module item still excludes that item; horizontal (domain-level) exclusion still works (no regression)
- [ ] T002 [P] [US1] — `tests/new-project-catalog-filter.bats` + `tests/update-presets-catalog.bats`: a `keep` install/update never removes a cross-domain module item

### Implementation
- [ ] T003 [US1] — `scripts/lib/catalog-filter.sh`: add an item-set exclusion (`CF_EXCLUDE_ITEMS`, item names) honored alongside `CF_EXCLUDE_DOMAINS` in `catalog_list_items`; document. Keep decoupled from `modules.sh`
- [ ] T004 [US1] — consumers (`new-project apply_catalog_filters`, `update _catalog_remove_set`) build the module-owned item set from all bundles (union) and pass it; shellcheck `-S warning` clean

**Checkpoint**: cross-domain modules are out of the filter's jurisdiction; horizontal unaffected.

---

## Phase 2 — Thematic module bundles + drift guard (US-2, US-5) · S2

### Tests (RED first) ⚠️
- [ ] T005 [P] [US5] — `tests/modules.bats`: the new modules are listed; **no item is owned by two modules**; every bundle path exists; bundles never include core workflow/orchestrators
- [ ] T006 [P] [US2] — `tests/new-project*.bats`: a default install excludes every thematic-module item; `claude-base add mobile` (etc.) installs exactly that module's items

### Implementation
- [ ] T007 [US2] — add bundles `scripts/lib/modules/{mobile,self-hosted,iac,data-eng,observability,editor,api-data,ai,frontend}.txt` with their command/agent/skill paths; finalise the `dev-*` split (api-data / ai / frontend) and the borderline items per spec
- [ ] T008 [US2] — update existing default-install test expectations to the new (smaller) core; shellcheck clean

**Checkpoint**: default install = minimal core; thematic items opt-in; no overlap.

---

## Phase 3 — Generalised validation + crossing migration + counts (US-3, US-4) · S3

### Tests (RED first) ⚠️
- [ ] T009 [P] [US4] — `tests/validate-presets.bats`: a preset filter naming ANY module-owned item (cross-domain, e.g. `dev-flutter`, `ops-proxmox`) is rejected pointing to module opt-in (not only `domain:biz`)
- [ ] T010 [P] [US3] — `tests/update-modules-migration.bats`: an existing project crossing the thematic change stops refreshing the now-modularised items (files kept), reports the themes + `add` hint, orphan nag suppressed for the crossing run; `add <module>` restores; idempotent
- [ ] T011 [P] [US5] — counts test: `counts.json.core` shrinks to full − union(all module-owned); gate validates it

### Implementation
- [ ] T012 [US4] — `scripts/validate-presets.sh`: reject filter entries that resolve to a module-owned item (lookup vs the union of bundle items), generalising the domain-only check
- [ ] T013 [US3] — `scripts/update.sh`: generalise the crossing migration to report newly-modularised themes (version-gated to the thematic release) + suppress the orphan nag that run; NO manifest rewrite needed (thematic items were core, never recorded); preserve horizontal behaviour
- [ ] T014 [US5] — regenerate `counts.json` (core shrinks); `validate-counts.sh` core check already generic (counts all bundles); README/docs core note updated; counts gate green

**Checkpoint**: validation + migration + counts all understand cross-domain modules.

---

## Phase 4 — Stack presets adopt the ergonomic keep (US-6) · S4

### Tests (RED first) ⚠️
- [ ] T015 [P] [US6] — per-preset install-reduction tests for `fastapi`, `astro`, `react-vite-spa`: each yields a measurably reduced, stack-scoped core; specific off-stack items absent; a kept core item present; `validate-presets` `[OK]`

### Implementation
- [ ] T016 [US6] — add a module-safe `keep` over the core + `defaultModules` (the themes each stack needs) to `.claude/presets/{fastapi,astro,react-vite-spa}.json`; no module-owned item referenced in the filter; minor bump each + CHANGELOG
- [ ] T017 [US6] — revisit `nextjs.json`: it may want `api-data`/`frontend` modules via `defaultModules` now that prisma/supabase/shadcn moved (avoid silently dropping what nextjs users expect)

**Checkpoint**: the three (four) stack presets are the worked examples; the original triggering task is closed.

---

## Phase 5 — Docs, version bump & CHANGELOG · S5

- [ ] T018 [P] — document the generalised "core + composable thematic modules" model (`.claude/presets/README.md`, `docs/`, the foundation-modules cross-reference)
- [ ] T019 — `VERSION` bump (proposed 4.0.0) + CHANGELOG breaking entry with the migration instruction; update the design/spec status to shipped
- [ ] T020 — counts gate after `npm --prefix website run generate`; audit-docs clean; final full `bats tests/` + shellcheck

**Checkpoint**: feature complete; model fully documented.

---

## Dependencies and Execution Order

```
S1 (filter→items) ─▶ S2 (bundles + drift) ─▶ S3 (validation + migration + counts)
                                                   ├─▶ S4 (preset adoption — the original task)
                                                   └─▶ S5 (docs + bump 4.0.0)
```

## Notes

- Reuse, don't reinvent: the opt-in default, absent-module skip, COPY-only, and counts split already exist from `horizontal-pure-modules`.
- Anti-fragmentation: theme-level modules only; the no-overlap drift guard (T005) is the gate.
- bash 3.2 empty-array idiom `${arr[@]+"${arr[@]}"}` everywhere (lesson #285).
- The `dev-*` split membership is the main open data decision — fix it in T007 with the no-overlap guard as backstop.

---

**Version**: 1.0 | **Created**: 2026-06-09
