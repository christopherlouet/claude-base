# Spec — Command-side vendor graduation (Wave: `dev-*` tool-wrapper commands)

> Status: ▶ In progress · 2026-06-21 · Owner: Chris
> Strategic north star: `specs/foundation-positioning-review/spec.md` (4-tier rubric)
> Precedent: `specs/command-vendor-graduation/spec.md` (biz/growth/ops/doc/legal wave, shipped
> 2026-06-15) — this spec closes the **`dev-*` blind spot** that wave explicitly left out of scope.
> Curation data: `.claude/curation/registry.json`, `docs/recipes/recommended-vendor-skills.md`
> Reduction model: `docs/designs/2026-06-12-foundation-vendor-graduation-design.md`

## 1. Summary

Foundation→vendor graduation is **half-done on the `dev-*` pack**. The *skills*
`dev-prisma`, `dev-supabase`, `dev-shadcn`, `dev-nextjs`, `dev-graphql` all graduated to
~45–56 LOC **pointer-skills** in the positioning-review Wave 1. But the **command-side** was
left out of the 2026-06-15 command wave (that wave scoped only biz/growth/ops/doc/legal).

Result: two commands still ship a full hand-maintained checklist around a tool whose
**authority vendor** documents it far better, while their sibling skill is already a pointer:

| Command | Sibling skill | Authority vendor | Registry record | Recipe entry |
|---|---|---|---|---|
| `dev-prisma` (full, 49 LOC) | pointer (47 LOC) | `prisma/skills` | ✅ candidate | ✅ §"Prisma" |
| `dev-supabase` (full, 48 LOC) | pointer (54 LOC) | `supabase/agent-skills` | ✅ candidate | ✅ §"Supabase" |

`dev-shadcn`, `dev-nextjs`, `dev-graphql` have **no command** (skill-only), so the command-side
graduation is exactly these **2 files**.

**Rule applied (inherited verbatim from the command-vendor-graduation spec §2):**

> **REDUCE ⟺ an _authority_ vendor owns the underlying tool** (the command is a thin checklist
> wrapping a tool the vendor documents far better). POINT ⟺ a community vendor goes deeper on a
> *methodology*. KEEP ⟺ no canonical vendor of comparable breadth.

`prisma/skills` and `supabase/agent-skills` are both **authority** (the tool maker's own org,
`trustVerdict: pass`), already pinned in the registry and the recipe. Both commands are pure
tool-wrappers ⟹ **REDUCE**, matching the `ops-grafana-dashboard` / `biz-pricing` precedent.

## 2. User Stories (prioritized)

### P1 — REDUCE the 2 authority tool-wrapper commands to pointer-commands

**US-1 — Convert `dev-prisma` and `dev-supabase` commands to pointer-commands**

- **Given** a REDUCE command, **When** converted, **Then** it follows the
  `ops-grafana-dashboard` shape: title `… (pointer)`, a "Delegate to the vendor toolkit"
  section naming the prior content as *superseded by* the vendor (one-line depth rationale),
  an **install** snippet, a link to the recipe entry, a link to this spec's rationale, the
  foundation **workflow cross-links** preserved (`## Related agents`), and the single most
  important **security one-liner** kept as a trailing guardrail.
- **Given** a REDUCE command, **When** converted, **Then** its length is ≈20–25 LOC (the
  generic checklist is removed, not annotated).
- **Given** the vendor named, **Then** it is **authority**, already in `registry.json` **and**
  the recipe — the pointer introduces no un-curated vendor.
- **Given** neither pack has a sibling **agent** (none exist under `.claude/agents/dev/`),
  **Then** no agent file is created or touched.

### P2 — Record the durable graduatable watch-list

**US-2 — Document `dev-*` graduatable-but-no-vendor commands as a watch-list**

So a future audit knows these are **stopgaps awaiting a qualified vendor**, not permanent
foundation content — without falsely implying a vendor exists today.

- **Given** the watch-list below, **When** recorded, **Then** each entry states the tech, why
  it stays full-impl now (no vendor cleared the curation bar), and what would trigger its
  graduation.

#### Graduatable watch-list (full-impl today — awaiting a qualified vendor)

| Pack | Tech | Why KEEP today | Graduation trigger |
|---|---|---|---|
| `dev-flutter` (command + skill + agent) | Flutter | No Flutter agent-skill has cleared the marketplace-audit bar (authority: none published by Flutter/Google; community: none ≥ the trust threshold). | A Flutter-team or ≥-bar community skill appears → registry candidate → REDUCE command, POINT agent. |
| `dev-auth` (skill) | auth frameworks | Deliberately **multi-stack** (better-auth, Lucia, NextAuth, Clerk, Supabase, Auth0) — no single vendor owns the surface; the value is the cross-framework decision layer. | A neutral auth meta-skill of comparable breadth appears (unlikely) — otherwise permanent. |
| `dev-i18n` (skill) | i18n libs | Spans next-intl/react-i18next/vue-i18n/formatjs/ARB; `lingui/skills` is curated but covers only Lingui (already a conditional preset recommendation). | A broad i18n vendor skill appears, or the pack narrows to Lingui-only → POINT. |
| `dev-react-perf` (skill) | React perf | Methodology pack (re-render/CWV), not a tool-wrapper; `vercel-labs/agent-skills` is adjacent but does not own "React perf" as a tool. | — likely permanent (methodology, foundation-owned). |

> **Niche, no-vendor, permanent** (recorded for completeness, *not* graduatable):
> `dev-neovim`, `dev-mcp`, `dev-ai-integration`, `dev-rag`, `ops-proxmox`, `ops-opnsense`,
> `ops-k8s` — too fragmented or niche for any vendor of comparable breadth to emerge.

### P3 — Curation traceability

**US-3 — Flag the registry records as command-side graduated**

- **Given** the `dev-prisma` / `dev-supabase` records, **When** P1 ships, **Then** each gains a
  `flags` note recording the command-side graduation date — **without** changing `status` or
  the vendor mapping (the registry's `status` enum stays `candidate|graduating|graduated`).

## 3. Registry-invariant decision (why no "awaiting-vendor" record)

The original brief suggested adding `dev-flutter` & co. to `registry.json` so the strategy is
legible. **Rejected:** the registry's documented invariant is *"durable/graduatable-without-
vendor skills carry NO record here — absence = permanence/awaiting signal (EF-001)"*, and its
`status` enum admits only `candidate|graduating|graduated` (enforced by
`scripts/validate-presets.sh --registry`). A record with no `vendorId`/`pinnedRef` would fail
validation and invert the invariant. The watch-list (§US-2) carries that legibility in
**markdown** instead, leaving the registry strictly a map of *real, pinned vendor candidates*.

## 4. Acceptance criteria

- `dev-prisma` and `dev-supabase` commands are ≈20–25 LOC pointer-commands matching the
  `ops-grafana-dashboard` shape; each keeps a security one-liner and `## Related agents`.
- No `.claude/agents/` change (no sibling agents exist for these packs).
- `scripts/validate-counts.sh` green (no count *number* changes — rewrite, not add/remove).
- `npm --prefix website run generate` produces no diff after commit (per-command pages
  regenerated and committed).
- `scripts/validate-presets.sh --registry` green (flag note adds no floating ref).
- Watch-list recorded here so the `dev-flutter`/`dev-auth`/`dev-i18n` KEEP verdicts are not
  re-litigated as "techno-coupled, should delete".

## 5. Out of scope

- The watch-list KEEP packs receive **no content change** (only the recorded reason here).
- Any **removal/DEPRECATE** of a command (this wave is pointer-only).
- The **dynamic / session-time** recommendation gap (auto-detect Prisma in `package.json` →
  surface the vendor) — a separate, heavier chantier, deliberately deferred.
- Skill-side graduation (already done in positioning-review Wave 1) and preset structure.
