# Marketplace audit pilot — `growth-*` skills (11 skills)

**Date**: 2026-05-21
**Status**: Pilot complete — 4 vendor sources added to `docs/recipes/recommended-vendor-skills.md`; foundation reductions tracked separately in [`specs/foundation-positioning-review/spec.md`](../foundation-positioning-review/spec.md).
**Scope**: Fifth domain audited under [`specs/marketplace-audit/spec.md`](spec.md). Follows cli-tools (PR #133), dev-* (PR #141), qa-* (PR #144), ops-* (PR #160).

## Context

This pilot runs under the new "community-is-baseline" framing introduced in [`specs/foundation-positioning-review/spec.md`](../foundation-positioning-review/spec.md). The triage extends the standard `{KEEP-OURS, POINT-TO-VENDOR, GAP}` with a fourth verdict `{REDUCE-TO-POINTER}` for cases where the vendor is materially superior. This pilot doc records the POINT-TO-VENDOR additions; the foundation reductions land in subsequent PRs per the positioning review's wave plan.

The growth domain was selected because it is the only domain without a prior audit pilot where the maintainer's foundation content was suspected to overlap heavily with vendor-published or community-adopted skills.

## Scope

11 `growth-*` commands + 1 `growth-cro` skill at `.claude/commands/growth/*.md` and `.claude/skills/growth-cro/SKILL.md`:

1. growth-ab-test
2. growth-analytics
3. growth-app-store-analytics
4. growth-cro (+ skill)
5. growth-email
6. growth-funnel
7. growth-landing
8. growth-localization
9. growth-onboarding
10. growth-retention
11. growth-seo

## Findings

| Foundation skill | Verdict | Source / reason |
|---|---|---|
| growth-analytics | **POINT-TO-VENDOR** | `PostHog/skills` (40★ vendor, MIT, push 2026-05-21). `instrument-product-analytics` covers PostHog-specific setup + 50+ framework refs + event planning heuristics. Foundation keeps N* + AARRR + GDPR layer. |
| growth-email | **POINT-TO-VENDOR** | `resend/resend-skills` (121★ vendor, MIT, push 2026-05-04). `email-best-practices` covers deliverability + double opt-in + suppression + idempotent + webhooks + list mgmt. Foundation keeps D0/D1/D3/D7 sequence design. |
| growth-cro (skill) | **POINT-TO-VENDOR** | `coreyhaines31/marketingskills/cro` (29,800+★ community, push 2026-05-19). Page-type frameworks + cross-skill orchestration. Foundation keeps quantified impact numbers + paywall strategies + mobile HTML specifics + anti-patterns lists (genuine complementary angles). |
| growth-seo | **POINT-TO-VENDOR + REDUCE planned** | `AgriciDaniel/claude-seo` (6,800+★ community, 28 SKILL.md, push 2026-05-18). Auto-detect business type + 7-cat scoring + DataForSEO/Firecrawl integrations. Foundation reduces to 10-20 LOC pointer per positioning review Wave 1 — vendor is materially superior across every axis our foundation command covered. |
| growth-ab-test | **POINT-TO-VENDOR + REDUCE planned** | `coreyhaines31/marketingskills/ab-testing`. Hypothesis templates + sample-size calc + segmentation playbook. Foundation reduce. |
| growth-funnel | **POINT-TO-VENDOR + REDUCE planned** | `coreyhaines31/marketingskills/cro+analytics` overlap; nothing not in corey + PostHog. Foundation reduce. |
| growth-landing | **POINT-TO-VENDOR + REDUCE planned** | `coreyhaines31/marketingskills/copywriting+cro+marketing-psychology` trio. Foundation reduce. |
| growth-onboarding | **POINT-TO-VENDOR + REDUCE planned** | `coreyhaines31/marketingskills/onboarding`. Aha + activation + segmentation deeper. Foundation reduce. |
| growth-retention | **POINT-TO-VENDOR + REDUCE planned** | `coreyhaines31/marketingskills/churn-prevention`. Cohort/RFM depth. Foundation reduce. |
| growth-localization | **KEEP-OURS** | No `coreyhaines31` equivalent. Foundation angle: market-prio matrix + GTM (distinct from translation pipes, which are covered by `dev-i18n` skill). |
| growth-app-store-analytics | **KEEP-OURS** | `coreyhaines31/marketingskills/aso` is keyword/listing-side only. Foundation angle: concrete Prom/Grafana pipeline (store-API analytics). Complementary niche. |

**4 vendor sources added, 6 REDUCE planned, 2 KEEP-OURS, 0 GAP.**

## Vendor-neutrality assessment

| Vendor | Verdict | Reason |
|---|---|---|
| PostHog | ACCEPT | Independent, MIT-licensed, not acquired |
| Resend | ACCEPT | Independent (Series A 2024), MIT-licensed, not acquired |
| AgriciDaniel/claude-seo | ACCEPT | Community-authored. Mass adoption (6,800+★) passes the methodology's "≥3 prod repos" lower bar by orders of magnitude. Single-maintainer caveat noted in recipe entry. |
| coreyhaines31/marketingskills | ACCEPT | Community-authored. Mass adoption (29,800+★) passes the lower bar. Single-maintainer caveat noted in recipe entry. |

No CASE-BY-CASE vendor-neutrality decisions in this audit.

## Methodology lessons after 5 audits

Cumulative results:

| Domain | Skills evaluated | KEEP-OURS | POINT-TO-VENDOR/COMMUNITY | GAP |
|--------|------------------|-----------|---------------------------|-----|
| cli-tools (plugins) | 4 | n/a | 0 (all 4 rejected) | n/a |
| dev-* | 17 | 9 | 6 | 2 |
| qa-* | 7 | 1 | 5 | 1 |
| ops-* | 10 | 7 | 3 | 0 |
| **growth-* (this pilot)** | **11** | **2** | **9 (incl. 6 REDUCE planned)** | **0** |
| **Total** | **49** | **19** | **23** | **3** |

The `growth-*` domain has the largest vendor-coverage ratio (9/11 = 82%) of any pilot — confirming the assumption that growth/marketing has an unusually mature community skill ecosystem in 2026. Two factors contribute: (a) marketing professionals adopt AI tools early and ship opinionated playbooks; (b) the 2026 SKILL.md standard adoption pulled cross-LLM marketing content into the Claude Code ecosystem.

The new verdict `REDUCE-TO-POINTER` is formalized here for the first time, but applies retroactively to the prior 4 pilots — several `KEEP-OURS` verdicts in `dev-*` and `ops-*` may shift to `REDUCE` under the community-is-baseline framing. Tracking that re-evaluation in [`specs/foundation-positioning-review/spec.md`](../foundation-positioning-review/spec.md).

## Related

- [`specs/foundation-positioning-review/spec.md`](../foundation-positioning-review/spec.md) — strategic baseline that introduced the REDUCE verdict and the wave-based reduction plan.
- [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md) — 4 new entries added in the same PR as this pilot.
