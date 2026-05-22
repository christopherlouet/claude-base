# Phase 6 — Curator Bindings (vision addendum)

> **Status**: planning · vision capture · post-v2.0.0 · non-blocking for Phases 3-5
> **Parent spec**: [`spec.md`](spec.md) (Phases 0-5)
> **Captured**: 2026-05-22

## Why this addendum exists

The parent spec stops the foundation-positioning work at **Phase 5 — Repositioning + v2.0.0** (README pivots to *"workflow framework + curator"* framing, recipe TOC restructure). That repositioning is honest *messaging* but does not close the loop *operationally*: after Phases 1-5 ship, the user still has cognitive load to figure out **which vendor skills to install for their stack**.

The strategic intent behind Waves 1-3 was always **delegate depth to the vendor ecosystem, keep workflow rigor in the foundation**. Phase 6 makes that intent actionable: the foundation *binds* detected stacks to validated vendor skills, so the user does not have to read the recipe and guess.

## Current gap (post-Phase 5 state)

After Phases 0-5 ship, the end-to-end user experience is:

1. `claude-base init` detects stack → applies matching preset → installs foundation skills.
2. README/recipe says *"for tool-specific depth, install vendor skills from `docs/recipes/recommended-vendor-skills.md`"*.
3. User opens recipe (currently organised by domain: analytics, email, SEO, security…).
4. User cross-references recipe entries against their detected stack mentally.
5. User installs vendor skills one-by-one via the Claude Code marketplace or git.

Steps 3-5 are pure cognitive load on the user. The foundation has *all the information* needed to skip those steps — it already detects the stack, it already has a curated recipe — it just doesn't wire them together.

## Vision

```
$ claude-base init ./my-app
[detected] Next.js 15 + Prisma + Tailwind
[preset]   applied: nextjs (15 foundation skills installed)
[curator]  3 validated vendor skills recommended for this stack:
             • posthog/posthog-skills        — product analytics, 1.2k★
             • prisma-driver-adapter-impl    — Prisma v7 driver work, vendor-published
             • vercel/turborepo-skills       — monorepo orchestration, 800★
           Install? [Y/n]
```

The user makes **one decision** (install vs. skip), not N decisions per skill. The recipe is still the source of truth, but the foundation surfaces only the relevant subset.

## Proposed architecture sketch

### 1. Preset schema extension

Add to each `.claude/presets/*.json`:

```json
{
  "foundation": { "skills": { "keep": [...] } },
  "vendorSkills": {
    "required":    [{ "source": "vendor/repo", "reason": "stack-critical" }],
    "recommended": [{ "source": "vendor/repo", "reason": "best practice" }],
    "optional":    [{ "source": "vendor/repo", "reason": "useful for X" }]
  }
}
```

Tiers map to install behaviour:
- **required**: prompted with default-yes
- **recommended**: prompted with default-yes, can be skipped en bloc
- **optional**: listed, default-no

### 2. Recipe restructure (additive)

The current per-domain organisation in [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md) stays — it's still the curated knowledge base. Add a **per-stack matrix** alongside:

```markdown
## By stack
| Stack | Required | Recommended | Optional |
|---|---|---|---|
| Next.js | … | … | … |
| FastAPI | … | … | … |
| Astro | … | … | … |
…
```

The matrix is generated from the preset JSON `vendorSkills.*[]` arrays — single source of truth, no drift.

### 3. CLI flow extension

`claude-base init` gains a post-preset step:

1. After preset detection + foundation install, read `presets/<detected>.json` `vendorSkills.*[]`.
2. Filter out already-installed vendor skills (idempotent).
3. Prompt the user (single Y/n, or interactive picker for `--interactive` mode).
4. Delegate install to the marketplace API (`claude plugin install <source>`) or git clone fallback.
5. Log installed vendor skills to `.claude/vendor-skills.lock.json` for traceability + uninstall reversibility.

### 4. Validation gate

Each preset fixture in `tests/presets-fixtures/<stack>/` gains a smoke test asserting the recommended vendor skills install cleanly and don't conflict with foundation skills (no duplicate slash commands, no rule-path collisions).

## Out of scope (deliberate)

- **Bundling vendor skill content into claude-base**: vendor skills stay distinct artifacts maintained by their authors. The foundation curates the *list*, not the *content*. This is the whole point of the Waves 1-3 REDUCE — claude-base does not chase vendor freshness.
- **Auto-updating installed vendor skills**: that's the Claude Code marketplace's job, not claude-base's. We surface the recommendation; the marketplace handles version drift.
- **Becoming a marketplace**: claude-base is a discipline foundation. The curator role is *trusted-list maintenance*, not *artifact distribution*.

## Open questions

1. **Version pinning** — should the preset pin to a `vendorSkills[*].minVersion`, or always pull `latest`? Pinning protects against breaking changes but ages quickly without active maintenance.
2. **Marketplace API vs. git fallback** — first iteration: marketplace-only. Git fallback for vendor skills not yet on the marketplace adds installer complexity.
3. **Stack pivot UX** — when a user adds Prisma to a Next.js app months after `init`, how does the curator re-prompt? Re-running `claude-base init` is the simplest path; an explicit `claude-base sync` subcommand is cleaner but adds CLI surface.
4. **Conflict detection** — if a vendor skill defines `/dev-prisma` and the foundation has `dev-prisma`, the foundation's slash-command takes precedence. Do we warn the user at install time?
5. **Telemetry trust** — should we rank vendor skills in the recipe by install count / GitHub stars / time-since-last-update? Today the recipe is curated manually with audit pilots; data-driven ranking is a separate spec.

## Roadmap position

| Phase | Status | Blocking for Phase 6? |
|---|---|---|
| 0 — Strategic memo | ✅ done (#226) | No |
| 1 — Recipe enrichment | ✅ done (#227) | No |
| 2 — Wave 1 REDUCE | ✅ done (5 PRs) | No |
| 3 — Wave 2 DEPRECATE | ✅ done (3 PRs) | No |
| 4 — Wave 3 expansion | 🔄 in flight (3/N) | No |
| 5 — Repositioning + v2.0.0 | ⏳ pending | **Yes — repositioning narrative is the conceptual hook for the curator framing** |
| **6 — Curator bindings** | ⏳ this doc | — |

Phase 6 should land **after** Phase 5 ships, so the messaging in the v2.0.0 README ("workflow framework + curator") has operational substance to back it up.

## Estimated effort

- Preset schema extension: ~1 session (add field, migrate 11 preset JSONs with empty arrays, update preset validation script).
- Recipe restructure + auto-gen of per-stack matrix: ~1 session.
- CLI flow extension: ~2 sessions (install logic, prompt UX, lock file, idempotency tests).
- Validation gate: ~1 session (extend `tests/presets.bats` with vendor-skill assertions per fixture).
- Documentation + migration guide for users on `< v2.0.0` presets: ~1 session.

**Total: 5-6 sessions, 4-6 PRs**, after Phase 5 ships.

## Success criteria

A new user running `claude-base init` on a Next.js + Prisma project gets a curated, validated set of vendor skills installed in one prompt, *without ever opening the recipe markdown file*. The recipe remains the source of truth for the curator (us), not a homework assignment for the user.

## Related memories

- [[project-foundation-positioning-review]] — the parent strategic work
- [[feedback-community-is-baseline]] — the framing that justifies delegating depth
- [[project-vendor-pointer-backlog]] — precursor work that established the curator pattern
