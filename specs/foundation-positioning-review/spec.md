# Spec: Foundation positioning review (2026-05-21)

**Status**: Strategic review — informs phased reduction work tracked in this folder. No code changes are made by this doc itself; it is the north star for subsequent PRs.
**Date**: 2026-05-21
**Owner**: Chris

---

## Premise (the framing shift)

`claude-base` is maintained by 1 person. The Claude Code skill ecosystem is now indexed at ~6,700+ skills across aggregators (2026 figures), updated daily by hundreds of contributors. **Working assumption**: 1-maintainer foundation content cannot systematically be deeper or fresher than community content. The burden of proof shifts onto each foundation resource to justify its existence under one of the four verdicts below.

The honest moat of `claude-base` is **framework + workflow + curation**, not content depth.

## 4-tier scoring rubric

| Verdict | Criterion | Action |
|---|---|---|
| **KEEP-AS-IS** | Foundation-conventions, meta-process, workflow orchestration — community doesn't compete here (no equivalent ships the cross-skill orchestration / anti-drift discipline / hooks integration / project setup) | None |
| **KEEP+POINT-TO-VENDOR** | Methodology/framework with a genuine unique angle vs community (e.g. quantified impact numbers, anti-patterns lists, GDPR/security wrap, multi-artifact bundling). Both layers add value | Recipe entry; no content reduction |
| **REDUCE-TO-POINTER** | Vendor materially superior (star-validated equivalent ships substantially deeper content); our content's unique angle is too thin to justify maintenance burden | Reduce to 10-20 LOC pointer; recipe entry mandatory |
| **DEPRECATE/REMOVE** | Community covers fully; our content adds nothing OR overlaps another foundation resource internally | Remove; add pointer if external alternative exists |

## Analysis method

Three research agents scored ~150 foundation resources (commands + skills, deduplicated) under the rubric on 2026-05-21:

- **Agent 1** — foundation-heavy domains: `biz/` (11) + `legal/` (5) + `work/` (15) + `doc/` (9) = 40 commands.
- **Agent 2** — technical-massive domains: `dev/` (23) + `qa/` (16) + `ops/` (34) = 73 commands.
- **Agent 3** — strategy/content + cross-cutting: `growth/` (11) + `data/` (3) commands + all 53 skills.

For each foundation resource: sample-read the foundation file + identify top community equivalent (star-validated or vendor-published) + compare angles. Verdicts generalized to domain when sampling was consistent; specific exceptions flagged.

GitHub code search rate-limited in 2 of 3 agent runs; affected verdicts are marked provisional in §Unknowns.

## Verdict tables

### KEEP-AS-IS — foundation moat (~30 resources)

| Category | Resources | Why |
|---|---|---|
| QA orchestration | `qa-loop`, `qa-audit`, `qa-kaizen`, `qa-review`, `qa-coverage`, `qa-automation` | Fan-out parallel-subagent pattern with anti-drift hooks, audit→validate→fix cycle. Foundation-signature. |
| Workflow & TDD | `dev-tdd` + skill, all `work-*` (explore/specify/plan/pr/commit/commit-push-pr/flow-*/quick/batch/clarify/brainstorm/team) | Foundation workflow wiring. The Explore→Specify→Plan→TDD→Audit→Commit cycle IS the foundation. |
| Incident & Git workflow | `ops-gitflow-{init,feature,hotfix,release}`, `ops-hotfix`, `ops-rollback`, `ops-ci-fix`, `ops-release`, `ops-deploy` | Branching conventions + incident-response orchestration tied to foundation hooks. |
| Cross-repo aggregation | `ops-health`, `ops-standup` | `gh` + git log + sub-repo loops. Foundation glue. |
| Safety cross-cutting | `ops-env`, `ops-secrets-management`, `ops-deps`, `ops-backup`, `ops-disaster-recovery`, `ops-migrate` | Cross-cutting checklists wired to `deploy-safety` rule. |
| Foundation infra skills | `agent-teams`, `parallel-agents`, `session-handoff`, `writing-skills`, `dev-mcp`, `dev-hook`, `dev-document` | Foundation extension authoring; orchestration patterns; meta-process. |
| Uncontested niches | `data-modeling`, `data-pipeline`, `qa-mobile`, `qa-neovim`, `ops-proxmox`, `ops-opnsense`, `ops-vps`, `dev-flutter`, `dev-neovim` | No star-validated community equivalent at comparable depth. |
| Meta orchestrators | `biz-launch`, `legal-docs`, `doc-generate`, `doc-fix-issue` | Cross-skill orchestration; no community equivalent bundles the stack. |

### KEEP+POINT-TO-VENDOR — complementary (~25 resources)

| Resource | Vendor pairing | Unique angle (why we keep) |
|---|---|---|
| `growth-cro` skill (216 L) | `coreyhaines31/marketingskills/cro` (29.8k★) | Quantified impact numbers, anti-patterns lists, paywall strategies, mobile HTML specifics — corey covers value-prop framing + page-type frameworks, distinct. |
| `growth-analytics` | `PostHog/skills` | Foundation: North Star + AARRR taxonomy + GDPR consent. Vendor: PostHog-specific instrumentation. |
| `growth-email` | `resend/resend-skills` | Foundation: D0/D1/D3/D7 sequence design + re-engagement. Vendor: deliverability + double opt-in + webhooks. |
| `growth-app-store-analytics` | (corey `aso` partial) | Foundation: concrete Prom/Grafana pipeline. Vendor covers keyword/listing side only. |
| `growth-localization` | (no corey equivalent) | Foundation: market-prio matrix + GTM, not just translation. |
| `legal-rgpd` | ICTRecht/Legal-GenAI-Resources | Foundation: code-audit angle (scan code for PII flows + Art. 30 register draft). Vendor audits documents only. |
| `legal-payment` | (thin community) | Stripe/PCI/SCA wrap with security overlap. |
| `legal-terms-of-service` | (no validated equivalent) | Foundation template + jurisdiction guidance. |
| `legal-privacy-policy` | majiayu privacy-policy-generate, paperclipai | Provisional — verify depth before downgrade. |
| `doc-architecture` | majiayu/adr | Multi-artifact wrap (C4 + ADR + ext integrations + flows). |
| `doc-readme` | (no dominant equivalent) | Quick-start + adoption checklist with foundation conventions. |
| `doc-onboard` | (no validated equivalent) | Devex / onboarding doc niche. |
| `doc-explain` | (weak community) | Diátaxis "Explanation" wrap. |
| `biz-market`, `biz-model`, `biz-research` | Fragmented community | KEEP+POINT pending deeper verification (Agent 1 sampling thin). |
| `dev-graphql` | `apollographql/skills` | Vendor is Apollo-only; foundation covers Yoga/Pothos/Mercurius/Strawberry/gqlgen. |
| `qa-e2e` | `microsoft/playwright-cli` | Vendor = API surface. Foundation = anti-fragility rules (no-wait-then-click, role-based selectors, deterministic data). |
| `qa-security` | agamm OWASP + Semgrep | Foundation: threat-model-by-category + `qa-loop` orchestration. Vendor: scanner + reference. |
| `ops-database` | `mongodb/agent-skills` | Vendor Mongo-only; foundation stack-neutral (naming, soft-delete, audit, migration safety). |
| `ops-infra-code` | antonbabenko/terraform + Pulumi | Foundation wraps both engines with module hierarchy + naming + link to `ops-deploy`. |
| `ops-monitoring` | `grafana/skills` | Foundation: three-pillar overview + OTEL skeleton (vendor-neutral). Vendor: LGTM specifics. |
| `ops-mobile-release` | (Callstack RN covers code, not pipelines) | Fastlane orchestration unique. |
| `web-scraping` skill | Firecrawl official | Foundation: Firecrawl→Playwright→curl fallback curation. |

### REDUCE-TO-POINTER — vendor materially superior (~30 resources)

| # | Resource | Vendor canonical | Why reduce |
|---|---|---|---|
| 1 | `growth-seo` (53 L) | `AgriciDaniel/claude-seo` 6.8k★ | 28 SKILL.md, business-type detect, 7-category scoring, DataForSEO/Firecrawl integrations. Our 53 L genuinely thinner across every axis. |
| 2 | `dev-supabase` skill (223 L) | `supabase/agent-skills` | Vendor ships Auth/DB/Edge/RT/Storage + 30-rule Postgres skill. Our content duplicates RLS basics. |
| 3 | `dev-prisma` skill (419 L) | `prisma/skills` | Vendor authoritative on v7 (ESM, driver adapters). Our content drifts on each release. |
| 4 | `dev-shadcn` skill (258 L) | shadcn-ui canonical registry | Vendor always in sync with the library; our skill mirrors. |
| 5 | `qa-chrome` skill (97 L) | `chrome-devtools-mcp` | The MCP IS the capability; our skill is a checklist around it. |
| 6 | `qa-perf` skill (101 L) | Addy Osmani `web-quality-skills` | Canonical LCP/INP/CLS coverage. |
| 7 | `ops-grafana-dashboard` | `grafana/skills` | Pure Grafana surface; no foundation-specific angle. |
| 8 | `ops-vercel` (47 L) | Vercel docs + `vercel-labs/agent-skills` | Vendor docs materially deeper. |
| 9 | `biz-pricing` | `coreyhaines31/marketingskills/pricing` | Van Westendorp + Good-Better-Best + value-metric axes; our 50 L can't match. |
| 10 | `biz-competitor` | corey/competitor + langchain GTM agent | Generic SWOT vs corey playbook. |
| 11 | `biz-personas` | UX persona suites (a11y-personas) | Generic checklist; community deeper. |
| 12 | `biz-pitch` | kai-slide-creator (Research-Claw) | Deck-building skills star-validated. |
| 13 | `biz-okr` | orchestkit/okr-design | North Star + KPI tree depth. |
| 14 | `biz-roadmap` | memstack/roadmap-builder, majiayu/roadmap | Multiple star-validated alternatives. |
| 15 | `biz-mvp` | slavingia + easychen + gsd:mvp-phase | 3 star-validated alternatives. |
| 16 | `growth-ab-test` | corey/ab-testing | Hypothesis templates + sample-size calc + segmentation playbook. |
| 17 | `growth-funnel` | corey/cro + analytics | Generic step-mapping + ICE; covered. |
| 18 | `growth-landing` | corey/copywriting + cro + marketing-psychology | Generic hero/social-proof; fully redundant. |
| 19 | `growth-onboarding` | corey/onboarding | Aha + activation + segmentation deeper. |
| 20 | `growth-retention` | corey/churn-prevention | Cohort/RFM depth. |
| 21 | `data-analytics` | growth-analytics + corey/analytics | SQL-cohort/RFM angle too thin alone — merge into growth-analytics or kill. |
| 22 | `legal-privacy-policy` | majiayu privacy-policy-generate, paperclipai | Template generators with star validation. |
| 23 | `doc-api-spec` | finom/vovk:openapi | OpenAPI 3.x decorators + Scalar/Redoc + x-codeSamples. |
| 24 | `doc-changelog` | majiayu git-cliff + devops-skills MR check | Tool-integrated automation. |
| 25 | `state-management` skill (278 L) | Zustand/Redux/Jotai + React 19 docs | No foundation-specific angle. |
| 26 | `feature-flags` skill (190 L) | PostHog/LaunchDarkly + community | No workflow integration. |
| 27 | `api-mocking` skill (202 L) | MSW docs + qaskills | MSW canonical. |
| 28 | `ops-k8s` | helm/kustomize community | Stack-specific. |
| 29 | `ops-docker` | docker-official + snyk hardening | Stack-specific. |
| 30 | `ops-observability-stack` | LGTM/OTEL vendor skills | Implicitly paired already; reduce to pointer. |
| 31 | `git-worktrees` skill (302 L) | Davila7/claude-code-templates + multiple registries | Worktree mechanics aren't workflow-distinctive. Trim. |

### DEPRECATE/REMOVE (3 resources)

| Resource | Why |
|---|---|
| `doc-i18n` | Duplicates the foundation's own `dev-i18n` skill (internal redundancy, not vendor competition). |
| `dev-prompt-engineering` (command + skill) | Entire community ecosystem of prompt-engineering skills competes; no unique foundation angle. |
| `data-analytics` | Mergeable into `growth-analytics` (already a REDUCE candidate). |

## Phased roadmap (compressed B→C, no multi-week pause)

Per maintainer guidance 2026-05-21: foundation user IS the maintainer; no need to wait for telemetry between waves. Each PR remains atomic (anti-pattern: giant multi-feature commits), but waves chain immediately.

**Order is deliberately Recipe-first → REDUCE → DEPRECATE → Repositioning** to avoid broken pointer windows.

| Phase | Scope | PRs | Est. effort |
|---|---|---|---|
| **0 — Strategic memo** | THIS spec — committed as the north star. | 1 | done in this PR |
| **1 — Recipe enrichment** | Add `coreyhaines31/marketingskills` + `PostHog/skills` + `resend/resend-skills` + `AgriciDaniel/claude-seo` to `docs/recipes/recommended-vendor-skills.md`. Ship `specs/marketplace-audit/growth-skills-pilot-2026-05-21.md`. Bump `marketplaceAuditPilots` 4 → 5. | 1 | ~45 min |
| **2 — Wave 1 REDUCE** | `growth-seo` REDUCE. `biz/` batch (pricing/mvp/okr). `dev/` skills batch (shadcn/prisma/supabase). | 3-4 | ~2-3 sessions |
| **3 — Wave 2 DEPRECATE** | `doc-i18n` removal. `dev-prompt-engineering` removal. `data-analytics` merge into `growth-analytics`. | 1-2 | ~1 session |
| **4 — Wave 3 expansion (entering C)** | Rest of REDUCE: `qa-chrome/perf` skills, `ops-grafana-dashboard/vercel/k8s/docker/observability-stack`, biz-* remaining, `state-management/feature-flags/api-mocking/git-worktrees` skills, growth-* remaining. | 5-8 | ~2-3 sessions |
| **5 — Repositioning + v2.0.0** | README pivots to "workflow framework + curator" framing. CHANGELOG migration guide. Major version bump. Recipe TOC restructure. | 1 (atomic) | ~1 session |
| **6 — Curator bindings** | Operationalise the "curator" claim: bind detected stacks to validated vendor skills via preset `vendorSkills.*[]` arrays, surface them in `claude-base init`. Vision capture: [`phase-6-curator-bindings.md`](phase-6-curator-bindings.md). Lands post-v2.0.0. | 4-6 | ~5-6 sessions |

## Pre-locked KEEP-AS-IS (NOT for review under this spec)

Foundation infrastructure that is NOT subject to the rubric (it is the rubric's runtime):

- `.claude/rules/` (30 rules, all path-specific)
- `.claude/settings.json` + `scripts/hooks/`
- `.claude/presets/` (11 manifests + presets infrastructure)
- `docs/recipes/recommended-vendor-skills.md` (the recipe itself is the curation surface)
- `scripts/validate-counts.sh`, `scripts/validate-presets.sh`, `scripts/audit-base.sh`
- `website/scripts/generate-*.ts` + `counts.json` infrastructure
- `CLAUDE.md`, `AGENTS.md`, foundation governance docs

## Unknowns / provisional verdicts

GitHub code-search rate-limited mid-run for 2 of 3 agents. Provisional verdicts (re-confirm before action in the relevant wave):

- `dev-rag`, `dev-ai-integration`, `dev-trpc`, `dev-component`, `dev-design-system` — REDUCE inferred, not directly verified.
- `ops-cost`, `ops-cost-optimization`, `ops-serverless`, `ops-load-testing` — REDUCE suspected, not confirmed.
- `legal-terms-of-service`, `legal-payment`, `biz-research`, `doc-explain` — KEEP+POINT provisional (absence-of-signal, not confirmed absence of community equivalent).
- `coreyhaines31/marketingskills` 29.8k★ — only `cro` and `pricing` sampled. Other 28 sub-skills assumed of comparable depth; verify before each REDUCE in Wave 2.
- `dev-shadcn` (258 L) vs official shadcn registry — overlap probable but unmeasured.
- Adoption telemetry of vendor skills in the wild — unknown; if low, REDUCE may hurt UX for users who haven't paired yet. Mitigation: each REDUCE keeps a 10-20 LOC pointer with clear install instruction.

## Out of scope

- Modifying the foundation's workflow (Explore→Specify→Plan→TDD→Audit→Commit).
- Modifying rules (`.claude/rules/`) or hooks.
- Modifying `.claude/presets/` (separate spec line).
- Changing the marketplace-audit methodology (`specs/marketplace-audit/spec.md`).
- Editing CHANGELOG entries prior to 2026-05-21 (historical).

## Related memories

- `feedback_plugin_curation_vendor_neutrality` — governs vendor acceptance.
- `feedback_commit_splits` — same-domain change: test→feat split convention.
- `feedback_no_project_names` — never name specific user projects in commits/specs/docs.
- `feedback_website_docs_mirror_sync` — `npm --prefix website run generate` after `docs/**/*.md` edits.
- `feedback_counts_ci_gate` — badge + counts.json regen + commit both.
- `[[project-vendor-pointer-backlog]]` — vendor-pointer queue closed 5/5.
