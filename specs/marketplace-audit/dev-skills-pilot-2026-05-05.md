# Marketplace audit pilot — `dev-*` skills (17 skills)

**Date**: 2026-05-05
**Status**: Pilot complete — verdict applied (selective `## See also` updates)
**Scope**: Second domain audited under the methodology in `specs/marketplace-audit/spec.md`. Follows the `cli-tools` plugin pilot from the same day.

---

## Why this pilot

The user asked the meta-question: *"is it possible to give a developer the best possible conditions and the best possible code?"* with claude-base.

The honest framing landed on: claude-base raises the floor (workflow rigor, default rules, anti-drift), it does not promise the ceiling. But where the **community has demonstrably better depth** on a specific skill — typically when the **tool vendor itself publishes their own skill** — claude-base should point to that source rather than competing with it.

This pilot tests the hypothesis empirically across the 17 `dev-*` skills (the largest skill domain in the foundation).

## Methodology applied

The methodology is the same as the cli-tools plugin pilot but adapted for skill-level evidence:

1. For each `dev-*` skill, search for community alternatives (web search + manual cross-reference)
2. **Prioritise tool-vendor skills** (e.g. Supabase publishes their own skill, Prisma publishes their own skill) over solo community efforts — they are authoritative by construction
3. Verify existence and maintenance signal via direct GitHub API checks (not just web search claims)
4. Apply the vendor-neutrality filter (per `feedback_plugin_curation_vendor_neutrality` memory)
5. Assign one verdict per skill from the matrix:

| Verdict | Meaning |
|---------|---------|
| `KEEP-OURS` | Our skill is good, no equivalent worth pointing to |
| `POINT-TO-VENDOR` | A tool-vendor publishes their own official skill; add `## See also` link in our SKILL.md |
| `POINT-TO-COMMUNITY` | A non-vendor community skill is well-adopted (≥3 real-product repos) and worth pointing to |
| `GAP-OUTSCOPE-POINTER` | Our skill is fine but covers narrowly; community has broader/deeper coverage worth mentioning in `outOfScope` |

## Findings — top-line numbers

- **9 KEEP-OURS** — no community alternative clears the bar
- **6 POINT-TO-VENDOR** — tool vendors publish their own skill, our skill becomes a complement with explicit pointer
- **2 GAP-OUTSCOPE-POINTER** — community has narrower or stack-specific coverage worth mentioning
- **0 POINT-TO-COMMUNITY** — no non-vendor community skill cleared the cross-reference bar

The marketplace has moved fast. Tool vendors that did not have skill repos at the time of the cli-tools pilot (mid-2025) now publish their own. Specifically:

- **Supabase**: `supabase/agent-skills` (2,041★, last commit 2026-04-30) ships `supabase` and `supabase-postgres-best-practices` skills
- **Prisma**: `prisma/skills` (34★, last commit 2026-04-02) covers Prisma v7 patterns
- **Apollo**: `apollographql/skills` (59★, last commit 2026-05-04) covers Apollo Client/Server/Federation
- **Vercel**: `vercel-labs/agent-skills` (26,144★, last commit 2026-05-05) ships `react-best-practices` and Next.js patterns
- **shadcn/ui**: `shadcn-ui/ui/skills/shadcn` (in main repo, 113,604★) ships canonical skill
- **Anthropic**: `anthropics/claude-code/plugins/frontend-design` (in main repo, 120,612★) ships frontend-design plugin

All verified via `gh api repos/<owner>/<repo>` and direct browsing of the relevant `skills/` or `plugins/` directories.

## Per-skill verdicts

| Skill | Verdict | Source | Action |
|-------|---------|--------|--------|
| dev-api | KEEP-OURS | — | No action |
| dev-auth | KEEP-OURS | — | No action |
| dev-debug | KEEP-OURS | — | No action |
| dev-document | KEEP-OURS | — | No action |
| dev-error-handling | KEEP-OURS | — | No action |
| dev-flutter | KEEP-OURS | — | No action |
| dev-frontend-design | POINT-TO-VENDOR | `anthropics/claude-code/plugins/frontend-design` | Add `## See also` |
| dev-graphql | POINT-TO-VENDOR | `apollographql/skills` (Apollo-scoped) | Add `## See also` |
| dev-i18n | GAP-OUTSCOPE-POINTER | `lingui/skills` | Mention in outOfScope of relevant presets |
| dev-nextjs | POINT-TO-VENDOR | `vercel-labs/agent-skills` | Add `## See also` |
| dev-prisma | POINT-TO-VENDOR | `prisma/skills` | Add `## See also` (especially v7 coverage) |
| dev-prompt-engineering | KEEP-OURS | — | No action |
| dev-react-perf | GAP-OUTSCOPE-POINTER | `vercel-labs/agent-skills` (web), `callstackincubator/agent-skills` (RN) | Mention in outOfScope of nextjs preset |
| dev-refactor | KEEP-OURS | — | No action |
| dev-shadcn | POINT-TO-VENDOR | `shadcn-ui/ui/skills/shadcn` | Add `## See also` |
| dev-supabase | POINT-TO-VENDOR | `supabase/agent-skills` | Add `## See also` |
| dev-tdd | KEEP-OURS | — | No action |

## Vendor-neutrality filter applied

Per `feedback_plugin_curation_vendor_neutrality`, vendors acquired by direct Anthropic competitors (notably OpenAI) must be filtered out. None of the 6 vendors above have been acquired by such competitors as of 2026-05-05:

- Supabase: independent, $80M Series C
- Prisma: independent
- Apollo: independent (Apollo GraphQL Inc.)
- Vercel: independent (own AI product `v0` is competitor-adjacent but Vercel itself remains independent)
- shadcn/ui: open-source, individual maintainer (no vendor capture risk)
- Anthropic: by definition, this is the home ecosystem

If any vendor is later acquired by OpenAI / Microsoft (>50% economic ownership) / direct Claude Code competitor, the corresponding `## See also` entry must be reviewed.

## Outcome

**Documentation-only updates** (no code changes, no skill deletions, no counter changes):

1. Add `## See also` section to the 6 POINT-TO-VENDOR `SKILL.md` files
2. Update `outOfScope` of the `nextjs` preset to mention `vercel-labs/agent-skills`
3. Update `outOfScope` of the `astro` preset (where i18n is relevant for content sites) to mention `lingui/skills`
4. Document the methodology trace in this file for future audits
5. Update CHANGELOG `[Unreleased]` section

Our skills remain in place — they cover the framework-agnostic / opinionated angle that complements vendor-specific guidance. Users who pair claude-base with the relevant vendor's skill get the best of both worlds.

## Honest limits

1. **Real-product adoption count was not verified** for the KEEP-OURS verdicts. The threshold "≥3 real-product repos using a community skill" was checked via web search only. A `gh search code` follow-up could find community-only skills that web search missed. For the 6 POINT-TO-VENDOR verdicts, the source IS the vendor's own repo, so adoption is implicit.

2. **Skill content depth was not compared in detail** for all 6 vendor skills. We confirmed existence + maintenance + authority. For a deeper second pass, we could read each vendor's full SKILL.md and identify concrete sections where our skill goes broader (these would justify keeping ours alongside the pointer rather than reducing-to-pointer).

3. **The vendor-neutrality filter was applied conservatively**. If a vendor is acquired between this pilot and the next audit, the relevant pointer must be reviewed. Memory `feedback_plugin_curation_vendor_neutrality` is the canonical source for this rule.

## Re-evaluation criteria

- Re-run this pilot every 6 months (or when a major vendor publishes a new skill)
- Specific re-trigger if any of the 6 source vendors changes ownership
- Specific re-trigger if a community-only (non-vendor) skill gains 3+ real-product repo adoption

## Methodology lessons for the next domain (qa-*, ops-*)

- The biz-competitor + general-purpose subagent pattern works well for the wide scout (web search + initial classification)
- Manual `gh api repos/<owner>/<repo>` verification is essential — agents can hallucinate but verifiable claims can be confirmed in seconds
- The KEEP-OURS verdict is the most common outcome and that's fine — it confirms our skills are not redundant with the marketplace
- The vendor-neutrality filter is decisive when applied; document explicitly per skill
