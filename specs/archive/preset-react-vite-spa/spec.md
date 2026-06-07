# Spec: react-vite-spa — 6th maintainer-vouched preset

> **Status: ✅ Shipped** — PR #178 (2026-05-13).

**Status**: Validated — all 6 user stories shipped on `feature/preset-react-vite-spa` (2026-05-13). Tests 593 → 620 (+27). Runtime `keep` filter + 6th maintainer-vouched preset + paired fixture + e2e drift-guard + multi-match disambiguation.
**Date**: 2026-05-13
**Owner**: Chris
**Builds on**: `specs/presets/spec.md` (Validated), `specs/presets-detection-and-e2e/` (Validated)
**Requires**: Runtime support for `keep`-style skills filter (not yet implemented as of 2026-05-13 — all 5 existing presets use `drop`). This spec's plan ships the runtime support as a blocking Phase 0 prerequisite before the preset itself.

---

## Summary

Today a user bootstrapping a React Single-Page App built on Vite + React Router (no Next.js, no Astro) has no honest match in the preset catalog. They either pick `nextjs` (wrong: drags in App Router, RSC, Server Actions assumptions and skills) or skip presets entirely and inherit the full foundation including Flutter, Proxmox, and other irrelevancies. This spec adds a 6th maintainer-vouched preset, `react-vite-spa`, anchored on the maintainer's two production projects in this exact stack. The preset filters out non-applicable skills, sets defensible defaults, ships with a detection rule, and names what it does NOT cover so users don't mistake it for a Next.js replacement, an SSR framework, or a mobile native solution.

## User Stories

### P1 — MVP

#### US-1 — User installs the foundation with the right scope for a React Vite SPA

> **As** a developer starting a new React Vite SPA project,
> **I want** to pick a preset that matches my stack honestly,
> **so that** I get the curated foundation without skills for stacks I don't use (Flutter, Next.js framework code, Proxmox, mobile release pipelines).

**Acceptance criteria**

- **Given** the preset catalog,
  **when** I list available presets,
  **then** `react-vite-spa` appears in the list alongside the 5 existing maintainer-vouched entries with a clear `displayName` and stack description.

- **Given** I run the bootstrap with `--preset react-vite-spa <target>`,
  **when** the install completes,
  **then** the target directory contains the foundation rules and commands, the skill set is filtered (non-applicable skills not copied), and a summary line names the preset that governed the install.

- **Given** the preset's filter omits a non-applicable skill (e.g. `dev-nextjs` is not in the keep list),
  **when** I inspect the target directory,
  **then** that skill is absent from `.claude/skills/` and re-running the bootstrap with `--no-preset` would re-add it (filter is reversible by intent).

- **Given** the preset names what it does NOT cover,
  **when** I read its description and `outOfScope` field,
  **then** at least four scope exclusions are listed (server-side rendering / React Server Components, native mobile, static-content sites, opinionated state management library choice) with a pointer to an alternative preset where applicable.

#### US-2 — Preset auto-detected on a matching project

> **As** a developer running the bootstrap or update flow on an existing project,
> **I want** the foundation to detect that `react-vite-spa` matches my codebase,
> **so that** I don't have to know the preset name in advance.

**Acceptance criteria**

- **Given** a project containing a Vite configuration file (any extension) AND a React Router dependency declared in its package manifest,
  **when** I run the bootstrap interactively without `--preset`,
  **then** the in-menu surface includes `react-vite-spa` as a suggested match.

- **Given** the same project,
  **when** I run the bootstrap non-interactively (`--detect-only` or auto-confirm),
  **then** the detection banner reports `react-vite-spa` as a match with its rule label.

- **Given** an Astro project (which uses Vite internally but does not depend on React Router),
  **when** I run detection,
  **then** `react-vite-spa` does NOT match. (Disambiguation via the dependency signal.)

- **Given** a Next.js project (which depends on React but not on Vite and not on React Router),
  **when** I run detection,
  **then** `react-vite-spa` does NOT match.

- **Given** a Vite + Vue project (no React),
  **when** I run detection,
  **then** `react-vite-spa` does NOT match.

- **Given** a paired fixture exists for the preset,
  **when** the test suite runs,
  **then** the detection rule asserts itself against the fixture (drift-guard: if upstream renames a marker, the test fails loudly).

#### US-3 — Preset filter persists across project lifecycle

> **As** a developer maintaining a project bootstrapped with `react-vite-spa`,
> **I want** subsequent foundation updates to honor the same filter,
> **so that** I don't see Flutter or Next.js skills silently reappear on every update.

**Acceptance criteria**

- **Given** a project bootstrapped with `--preset react-vite-spa`,
  **when** I run the update flow with auto-detection,
  **then** the preset's drop list is applied during the copy step (no dropped skill is re-added).

- **Given** the same project,
  **when** I run the update with `--no-preset`,
  **then** every foundation skill is re-added (filter explicitly disabled).

- **Given** the update completes successfully,
  **when** I read the end-of-run output,
  **then** the active preset name is surfaced and the curated vendor-skill recommendations are re-printed (consistent with the lifecycle visibility behavior shipped in v1.38.0).

### P2 — Important

#### US-4 — Vendor skills recommended at end of install

> **As** a developer who just installed the foundation with `react-vite-spa`,
> **I want** to see a curated list of community / vendor skills that pair well with this stack,
> **so that** I know what to install next without having to research the marketplace.

**Acceptance criteria**

- **Given** the install completes,
  **when** I read the end-of-run output,
  **then** at least one vendor-skill recommendation is printed under the "Always pair with this preset" heading, sourced from the marketplace audit pilots.

- **Given** at least one conditional recommendation exists (e.g. shadcn-related skill if the project uses shadcn/ui patterns),
  **when** I read the output,
  **then** conditional entries print under the "Add if your project uses these tools" heading with a clear condition string.

- **Given** the install-status helper detects whether the recommended skill is already installed,
  **when** the recommendation prints,
  **then** an indicator marker is prefixed to each item (installed / not installed / unknown) consistent with the behavior shipped in v1.38.0.

#### US-5 — README and roadmap reflect the new preset

> **As** a foundation visitor (or future maintainer),
> **I want** the public documentation to acknowledge the 6th preset,
> **so that** the project's honest claim "5 shipped, 22+ wanted" is updated to "6 shipped, 21+ wanted" without drift.

**Acceptance criteria**

- **Given** the preset README,
  **when** I read the "Available presets" table,
  **then** `react-vite-spa` is listed with its status and stack.

- **Given** the roadmap,
  **when** I read the "Shipped" table,
  **then** `react-vite-spa` is listed with the shipping version and PR reference.

- **Given** the roadmap "Quick reference" footer,
  **when** I read the counters,
  **then** the JS web frameworks line moves from "2" to "3" and the totals line moves from "5 shipped" to "6 shipped".

- **Given** the foundation's CHANGELOG,
  **when** I read the `[Unreleased]` section,
  **then** an Added entry names the preset and links to its location.

### P3 — Nice-to-have

#### US-6 — Multi-match disambiguation when a project lives between stacks

> **As** a developer with a project that legitimately matches two presets (e.g. a Next.js codebase that has been partially ported to a Vite SPA shell, or a hybrid),
> **I want** the foundation to ask me which preset to apply,
> **so that** I make the decision explicitly instead of silently inheriting the wrong filter.

**Acceptance criteria**

- **Given** a project whose files trigger both `nextjs` and `react-vite-spa` detection,
  **when** I run the bootstrap without `--preset`,
  **then** the foundation surfaces both matches and asks me to pick one (or pass `--preset <name>` / `--no-preset`).

- **Given** I pass `--preset react-vite-spa` explicitly,
  **when** the bootstrap runs,
  **then** detection is short-circuited and only the chosen preset's filter applies.

## Functional Requirements

| ID | Requirement | Test target |
|---|---|---|
| EF-001 | The preset name is `react-vite-spa` (lowercase, hyphenated, stack-specific — not `react`, not `spa`, not `react-app`). | Manifest validation, README entry, roadmap entry |
| EF-002 | The preset's `description` field is 2–3 lines and names: (a) what's IN (React + Vite + React Router as the core trio), (b) what's OUT (no SSR, no RSC, no native mobile, no opinionated state library). | Manifest validation, manual read |
| EF-003 | The preset's `status` field is `maintainer-vouched` (matches the quality bar: maintainer uses the stack in production for ≥3 months). | Manifest validation |
| EF-004 | The preset declares an `appliesToTypes` value that composes with the existing project-type system (without inventing a new type). | Manifest validation, install flow test |
| EF-005 | The preset's foundation filter uses a `keep`-style list (whitelist) — consistent with the existing `nextjs` preset, the other frontend React preset. The keep list names every skill that is explicitly applicable to a React Vite SPA. The exact list is finalized in the plan phase. | Install test asserts every listed skill is present |
| EF-006 | The keep list does NOT include skills that are clearly non-applicable to a React Vite SPA: Flutter, Next.js framework skill, mobile release pipeline, homelab infra skills, generic infra-as-code, data pipelines. Their absence from the keep list means the install does not copy them. | Install test asserts each non-applicable skill is absent |
| EF-007 | The preset includes a `detect` block whose combinator requires BOTH a Vite config file AND a React Router dependency declaration to match. | Detection test against paired fixture |
| EF-008 | A paired fixture under `tests/presets-fixtures/react-vite-spa/` exists and triggers the detection rule. | Detection test |
| EF-009 | The detection rule does NOT match: Astro projects, Next.js projects, Vite + Vue projects, Vite + Svelte projects, CRA / Webpack React projects. | Per-non-match fixture test |
| EF-010 | The preset's `outOfScope` field lists at least 4 explicit exclusions and points to alternative presets where applicable (`nextjs` for SSR/RSC, `astro` for content/static, "community contributions wanted" for mobile). | Manifest validation, manual read |
| EF-011 | The preset's `relatedPresetsWanted` field lists at least 3 adjacent stacks that the foundation does not yet cover (e.g. SvelteKit, Vue/Nuxt, Remix). | Manifest validation |
| EF-012 | The preset bundles ZERO marketplace plugins at v1 (consistent with the cautious posture of fastapi, cli-tools, homelab-proxmox, astro). | Manifest validation |
| EF-013 | The preset declares 4 `recommendedVendorSkills` entries, each sourced from a marketplace audit pilot: (1) `vercel-labs/agent-skills` condition `always` — React canonical patterns valid outside Next.js, (2) `frontend-design@claude-plugins-official` condition `always` — Anthropic's official UI design plugin, (3) `shadcn-ui/ui (skills/shadcn)` condition `if using shadcn/ui`, (4) `lingui/skills` condition `if using Lingui for i18n`. | Manifest validation, install output test asserts each entry is printed with the expected condition |
| EF-014 | The preset's `defaults` are explicit (CI, hooks, MCP, Docker, design style) and chosen for the stack (e.g. design style consistent with a SaaS / app UI, not "terminal" or "cockpit"). | Manifest validation, install test |
| EF-015 | The test suite contains ≥6 cases dedicated to this preset (detection match, detection non-match × ≥2, install filter, install does NOT drop kept skills, dry-run output). | Test count assertion |
| EF-016 | The README badge `tests-N passing` is bumped by the count of new tests added. | `scripts/validate-counts.sh` exits 0 |
| EF-017 | `scripts/validate-presets.sh` passes for the new manifest (no schema regression). | CI gate |
| EF-018 | The CHANGELOG `[Unreleased]` section gains an Added entry naming the preset and its stack. | Manual read |

## Edge Cases

| Case | Expected behavior |
|---|---|
| Project has BOTH `next.config.*` AND `vite.config.*` (rare hybrid) | Both presets match; multi-match disambiguation prompts the user (US-6). |
| Project uses Vite internally via Astro (Astro depends on Vite) | `react-vite-spa` does NOT match (combinator requires React Router dependency, not just Vite). Astro preset is the correct match. |
| Project has Vite + React but NO React Router (custom routing or zero routing) | `react-vite-spa` does NOT match. User can still pass `--preset react-vite-spa` explicitly to override; the preset accepts that as an honest override. |
| Project uses Vite + Vue (no React) | `react-vite-spa` does NOT match. No false positive. |
| Project uses Create-React-App (CRA, Webpack-based) | `react-vite-spa` does NOT match (no `vite.config.*`). The roadmap will name CRA / Webpack-React as a separate community-wanted stack or explicitly out of scope. |
| Project wraps the React SPA with Capacitor for mobile distribution | The preset accepts this pattern. Capacitor is mentioned in the description (compatible add-on) but does NOT change the preset's foundation filter. Mobile-release skills remain dropped (Capacitor publishing uses different tooling). |
| Project uses an alternative React Router (e.g. TanStack Router, Wouter) | First version: does NOT auto-detect (the detection rule is specific to React Router). User can pass `--preset react-vite-spa` explicitly. Future iteration may broaden the rule. |
| User runs `--preset react-vite-spa --no-preset` simultaneously | The bootstrap exits with a clear "mutually exclusive" message (consistent with the existing flag conflict behavior). |
| User runs `--preset react-vite-spa` against a project that already has a different active preset | Same behavior as for any other preset: explicit flag wins over auto-detection; the previous preset filter is replaced. |
| User runs the update flow on a `react-vite-spa` project and the preset has been removed from the foundation (e.g. downgrade) | Update flow degrades gracefully: warns that the preset is unknown and falls back to no-filter behavior. (This is the existing fallback behavior for any unknown preset.) |

## Entities

| Entity | Description | Fields used |
|---|---|---|
| Preset manifest | The JSON file declaring the new preset | `name`, `displayName`, `description`, `status`, `appliesToTypes`, `detect`, `foundation.skills.drop` (or `keep`), `marketplacePlugins`, `recommendedVendorSkills`, `defaults`, `outOfScope`, `relatedPresetsWanted` |
| Detection fixture | A minimal project tree that triggers the detection rule | A Vite config file + a manifest declaring React Router |
| Non-match fixtures | Existing fixtures (Astro, FastAPI, Next.js, etc.) re-used as negative tests | Filesystem only |
| Roadmap entry | The row in `specs/presets/roadmap.md` Shipped table | Preset name, stack, shipping version |

## Success Criteria

| ID | Criterion | Measurement |
|---|---|---|
| CS-001 | The preset can be installed end-to-end via the bootstrap on a clean target directory with the expected filter applied. | E2E install test asserts dropped skills are absent and kept skills are present. |
| CS-002 | Detection on the maintainer's production projects in this stack reports `react-vite-spa` as a match. | Manual smoke + automated test with paired fixture. |
| CS-003 | Detection on every existing non-matching fixture (Astro, FastAPI, Next.js, homelab-proxmox, cli-tools) reports NO match for `react-vite-spa`. | Regression test in the existing detection suite. |
| CS-004 | All new tests pass on `ubuntu-latest`; `macos-latest` is exercised at minimum for portability. | CI green. |
| CS-005 | `scripts/validate-presets.sh` passes; ShellCheck clean across any touched scripts. | CI green. |
| CS-006 | The README `tests-N passing` badge is correct after the PR lands (`scripts/validate-counts.sh` exits 0). | Anti-drift script. |
| CS-007 | The CHANGELOG `[Unreleased]` section names the preset before the PR merges. | Manual read. |
| CS-008 | The roadmap counter moves from "5 shipped, 22+ wanted" to "6 shipped, 21+ wanted" (the new stack is no longer in the wanted list, or is explicitly moved to shipped). | Manual read. |
| CS-009 | The preset overhead on the install path is < 100ms (no perceptible slowdown vs other presets). | Smoke timing — informational, not gated. |

## Out of Scope

- **Marketplace plugins at v1**: zero plugins shipped, consistent with the cautious posture adopted by `fastapi`, `cli-tools`, `homelab-proxmox`, `astro`. Plugins land incrementally only after maintainer validation.
- **Capacitor / native mobile wrap**: the preset is compatible with a Capacitor add-on (the maintainer ships one project that way) but does NOT bundle Capacitor-specific skills, defaults, or scripts. A future `capacitor` preset (or community contribution) is the right home for that.
- **Server-side rendering or React Server Components**: explicit redirect to the `nextjs` preset.
- **Static-content / blog / marketing sites**: explicit redirect to the `astro` preset.
- **State management library opinion** (Redux / Zustand / Jotai / Recoil / Context-only): the React community has not converged; the preset stays neutral.
- **Data-fetching library opinion** (TanStack Query / SWR / Apollo / RTK Query): the preset stays neutral. The maintainer uses TanStack Query in both production projects but does not bundle a skill for it at v1.
- **Build-tool alternatives** (Rollup standalone, esbuild standalone, Turbopack, Rspack): Vite is the explicit and only build target. If demand emerges for Rspack or similar, a separate preset or a broader `react-modern-spa` preset can be proposed.
- **Testing library opinion** (Vitest vs Jest vs Playwright vs Cypress): the foundation already ships the relevant QA skills; the preset does not pre-pick.
- **Internationalization library opinion** (i18next vs react-intl vs Lingui): the foundation does not pre-pick at the preset level.
- **CSS framework opinion** (Tailwind vs CSS Modules vs vanilla-extract vs CSS-in-JS): the maintainer uses Tailwind in both prod projects but the preset does not enforce.
- **Per-preset CI matrix**: the preset is a config, not a runtime; no separate CI per preset.

## Clarification Points

1. **Naming**: ~~`react-vite-spa` vs `vite-react-spa` vs `react-spa-vite`~~ → **Resolved 2026-05-13: `react-vite-spa`**. Leads with the dominant stack component (React), Vite + SPA qualify. Consistent with the existing convention (`nextjs`, `homelab-proxmox`).

2. **Capacitor mention**: ~~description informational vs `outOfScope`-only vs silence~~ → **Resolved 2026-05-13: informational mention in the `description`**. The preset's `description` will note that the stack is compatible with a Capacitor wrap for mobile distribution, while clarifying that no Capacitor-specific tooling, skills, or scripts are bundled (mobile distribution remains in `outOfScope`). Pre-empts the "how do I add mobile?" question.

3. **Detection combinator strictness**: ~~`allOf` vs `anyOf` vs `allOf` widened with TanStack Router~~ → **Resolved 2026-05-13: `allOf` strict** — Vite config file AND `react-router-dom` dependency. Avoids false positives on Astro / Vue+Vite / Svelte+Vite. Trade-off: projects using `@tanstack/react-router` or no router at all require an explicit `--preset react-vite-spa` flag (acceptable for v1; broadening can come later).

4. **Foundation filter style**: ~~`drop` (blacklist) vs `keep` (whitelist)~~ → **Resolved 2026-05-13: `keep`** — with an explicit scope expansion. As of 2026-05-13, every shipped preset (including `nextjs`) uses `drop`; the runtime helpers (`scripts/new-project.sh::apply_preset_filters`, `scripts/update.sh::load_active_drop_list`) only read `.foundation.skills.drop[]`. The agreed path: extend the runtime to support BOTH `drop` and `keep` (mutually exclusive per preset), then this preset is the first to use `keep`. The 5 existing presets keep their `drop` form; migrating them is OUT of scope (handled by a future review if a maintenance need surfaces).
