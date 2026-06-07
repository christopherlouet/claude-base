# Spec: per-domain audit vs Claude Code marketplace

> **Status: ♻️ Living document** — gatekeeper for vendor-skill curation; updated with each audit pilot.

**Status**: Validated — Living document. Methodology in use; 4 audit pilots shipped (cli-tools, dev-skills, qa-skills, ops-skills 2026-05-05/06); the methodology is the gatekeeper for [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md) (17 vendor entries validated as of 2026-05-19).
**Date**: 2026-05-04
**Owner**: Chris

---

## Summary

The Claude Code plugin marketplace ecosystem (≈4200 skills, ≈770 MCP servers, ≈101 official plugins as of May 2026) is large and growing. For many verticals (legal/GRC, SEO, dev-stack helpers, cloud integrations) it almost certainly contains plugins that go deeper than the equivalent packs bundled in claude-base.

This is not a flaw of claude-base per se — its value lies in workflow integration, not vertical depth — but **without an honest comparison, the foundation risks becoming a local maximum**: well-integrated yet sub-optimal at every individual task.

This spec plans a **per-domain audit** that decides, evidence in hand, which packs to keep, reduce to a pointer, or remove from the foundation. It is the largest scoped change envisioned since the public release: it touches potentially 30-50% of the bundled `commands/`, `agents/` and `skills/`.

## Goals

- **Honest evaluation per domain**: for each of the 9 domains (`biz`, `data`, `dev`, `doc`, `growth`, `legal`, `ops`, `qa`, `work`), compare what claude-base ships against the top 1-3 marketplace alternatives.
- **Decision matrix**: each pack ends up in one of four buckets — `Keep`, `Reduce-to-pointer`, `Move-to-preset-recommendation`, `Remove`.
- **Feed the preset roadmap**: packs that land in `Move-to-preset-recommendation` become curated entries in the relevant preset's `marketplace_plugins` list — the audit and the preset roadmap are coupled deliverables.
- **No silent breakage**: every removal goes through a deprecation period (one minor release) with clear migration guidance.
- **Documented final positioning**: post-audit, the README + EXTENDING-GUIDE communicate where claude-base's depth genuinely lives and where users should look to the marketplace.

## Non-goals

- Replicating the marketplace inside claude-base (we are not a curated index).
- Auto-installation of marketplace plugins via `new-project.sh` (out of scope; depends on plugin system maturing per `docs/guides/EXTENDING-GUIDE.md` § 7).
- Per-pack absolute ranking (numeric scores). Qualitative rationale is enough.
- Audit of `work/` (the workflow orchestration commands are claude-base's defining feature; not in scope for removal).

## Methodology

### Per-pack evaluation rubric

Each pack (defined as a `commands/<domain>/<name>.md` plus its associated agent/skill if any) gets evaluated on 4 axes:

| Axis | Question | Score (1-3) |
|---|---|---|
| **Integration value** | Does the pack rely on or contribute to the foundation's workflow (Explore → Specify → Plan → TDD → Audit, qa-loop, anti-drift)? | 1 = standalone, 3 = deeply integrated |
| **Marketplace alternative depth** | What's the best marketplace alternative? How much deeper is it? | 1 = much deeper, 3 = comparable or no clear alternative |
| **Maintenance cost** | How often does this pack require updates (framework drift, tool API changes)? | 1 = high (yearly+), 3 = low (rarely) |
| **Usage signal** | Is the pack discoverable / used? (proxy: mentions in our own docs, examples, recipes) | 1 = isolated, 3 = central |

**Total range 4-12.** Bucket assignment:

| Total | Bucket | Action |
|---|---|---|
| 10-12 | **Keep** | Document the integration story explicitly. |
| 7-9 | **Reduce-to-pointer** | Replace pack content with a one-paragraph entry pointing to the marketplace alternative + a quick "how to combine with claude-base workflow" note. |
| 7-9, fits a preset stack | **Move-to-preset-recommendation** | Drop the pack from the foundation and instead recommend the marketplace alternative inside a relevant preset's `marketplace_plugins` list (see `specs/presets/spec.md`). The preset becomes the curated path for that pack's users. |
| 4-6 | **Remove** | Deprecate in next minor release. README pointer to marketplace alternatives. |

### Marketplace alternative search protocol

For each pack, search at minimum:

1. [Official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) (Anthropic-curated)
2. [claudemarketplaces.com](https://claudemarketplaces.com/) (community index)
3. [awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins) (curated list)
4. GitHub topic search: `claude-code-plugin <domain>`

Capture top 1-3 alternatives per pack with: link, brief description, what makes it deeper than ours.

## Domains in scope (8 of 9)

| Domain | Files (commands+agents+skills approx) | Audit priority |
|---|---|---|
| `legal` | 5 + 5 + 0 = 10 | **High** — known case (Sushegaad GRC, Claude Cowork Legal far deeper) |
| `growth` | 11 + 11 + 0 = 22 | **High** — SEO/CRO/email/ads each have specialized markets |
| `dev` | 23 + 23 + ~25 = ~70 | **High** — many vertical alternatives (dev-supabase, dev-prisma, dev-graphql, dev-nextjs, dev-flutter all likely have native plugins) |
| `ops` | 34 + 27 + ~10 = ~70 | Medium — cloud verticals (vercel, k8s, proxmox) likely covered, but workflow ops (gitflow, release, deploy) is integrated |
| `qa` | 16 + 16 + ~5 = ~35 | Medium — qa-loop is unique, individual qa-* checkers may have alternatives |
| `data` | 3 + 3 + 1 = 7 | Low — small surface, niche |
| `doc` | 9 + 11 + 0 = 20 | Low — doc generation is a commodity but well-integrated with our workflow |
| `biz` | 11 + 11 + 0 = 22 | Low — strategic/MVP/personas, less likely to have deep marketplace alternatives (yet) |
| ~~`work`~~ | (out of scope — workflow core) | — |

## Out of scope

- `work/` (the foundation's defining workflow orchestration).
- The `qa-loop` skill specifically (unique value, no clear marketplace alternative).
- Output rewriter hooks (just shipped, distinct value).
- Anti-drift counters infrastructure.

## Phasing (high level)

The audit itself takes time but does not produce code changes. It produces a `decision.md` per domain. Implementation (deletions, pointer replacements) is a separate, follow-up effort.

| Phase | Scope | Estimated |
|---|---|---|
| **Phase 1** — High-priority domains | `legal`, `growth`, `dev` | 2-3 days |
| **Phase 2** — Medium-priority | `ops`, `qa` | 2 days |
| **Phase 3** — Low-priority | `data`, `doc`, `biz` | 1-2 days |
| **Phase 4** — Decision consolidation | Per-domain `decision.md` aggregated into one strategic doc | 0.5 day |
| **Phase 5** — Implementation (deprecation in minor release) | Remove `Remove` bucket, replace `Reduce-to-pointer` content, migration guide | 2-3 days |

**Total estimated**: 8-11 days spread over 2-4 weeks calendar.

## Risks

| Risk | Mitigation |
|---|---|
| Audit becomes opinion-heavy without real marketplace use | Always cite at least 2 alternative plugins with links. No "remove" without evidence. |
| User backlash on removed packs | Deprecation period (one minor release) + migration doc + bumping major version (v2.0) for the eventual cleanup |
| Marketplace alternatives die or change | Snapshot links + version refs in the audit (date the comparison) |
| Scope creep (audit `work/` after all) | Stick to non-`work/` domains. `work/` is sacred to the project's identity. |
| Self-bias toward keeping our own work | Use the rubric mechanically. If total score is ≤ 6, remove regardless of attachment. |
| Audit takes longer than planned and never ships | Box-time per domain (4 hours max). If a domain takes longer, ship `decision.md` with what you have, mark unclear cases as "needs more research". |

## Success criteria

- All 8 in-scope domains have a `decision.md` with explicit rubric scores and marketplace links.
- Aggregate decision document at `specs/marketplace-audit/decision.md` summarizing the buckets.
- README and EXTENDING-GUIDE updated to reflect the post-audit positioning.
- A measurable reduction OR validation in foundation surface: either (a) at least 20% of audited packs move to `Reduce-to-pointer` or `Remove`, or (b) the audit confirms ≥80% are `Keep` and the README claims that explicitly.
- Deprecation entries in CHANGELOG for any removed packs.
- No `validate-counts.sh` regression, no `audit-base.sh` regression after implementation.

## Clarification points

1. **Major version bump?** Removing packs is a breaking change for users who rely on them. Do we ship the cleanup as v2.0.0 (clear major) or as v1.32.0 with deprecation warnings first? **Default proposal**: deprecation in v1.32.0, removal in v2.0.0.
2. **Scope of "Reduce-to-pointer"**: should reduced packs be entirely a pointer (1 line), or keep a thin wrapper that combines with our workflow (3-5 lines)? **Default proposal**: thin wrapper that says "for X, install <plugin> + here's how to call it inside the foundation's workflow".
3. **Audit responsibility**: solo (Chris) or community-driven (open issues per domain, accept PRs)? **Default proposal**: solo for Phase 1 to set the tone, then open up for Phase 2-3 if appetite exists.
