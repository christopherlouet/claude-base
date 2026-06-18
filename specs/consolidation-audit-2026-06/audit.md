# Consolidation audit (P0) — 2026-06-18

Data-driven audit of the catalog (128 commands / 61 agents / 53 skills) to decide
the next reduction target. Method: structural overlap scan + four parallel
read-only cluster audits (ops · dev · qa+work · doc/data/biz/growth/legal),
each classifying every item with the rubric below.

## Headline finding

**The surface is mostly earned, not bloated.** The earlier "massive dilution"
hypothesis is only partly right. The catalog is NOT full of empty wrappers
(structural scan: only ~2 pointer agents, ~2 short commands). Most tri-modal
triads (command+agent+skill of one name) are justified by **distinct
tool/model/permission profiles** or an **autonomous-run / qa-loop-dispatch role**.

So the recommendation is **targeted consolidation, not an aggressive lean-to-20**.
The data does not support cutting the core to ~20 commands — roughly 70% of items
are genuinely distinct. Realistic outcome of acting on every finding below:

| catalog | now | after consolidation | delta |
|---|---|---|---|
| commands | 128 | ~108–110 | −18 to −20 |
| agents | 61 | ~48 | −13 |
| skills | 53 | 53 | 0 (content of record) |

## Rubric

- **SKILL** = content of record → KEEP.
- **AGENT** justified only if a distinct tools/model/permission profile OR an
  autonomous/dispatched role; a pure `skills:[x]`+default passthrough → **COLLAPSE-AGENT**.
- **COMMAND** justified only if it adds explicit-invocation orchestration; a restate
  of the agent/skill → **REDUCE-COMMAND** or **MERGE-WITH** a sibling.
- **GRADUATE** = an authority vendor owns the tool. **KILL** = redundant/misfiled.

## What earns its keep (do NOT touch)

- The **work-*** workflow floor (explore/specify/plan/quick/batch/brainstorm/commit/pr,
  flow-* orchestrators) — conservative by mandate; only one internal overlap (below).
- The **qa-loop spine** + its dispatched sub-agents (qa-loop, qa-audit, qa-security,
  qa-perf, wcag-audit, qa-claudemd) and the write/browser-distinct qa-e2e, qa-chrome.
- ops c·a·s triads with distinct write/model profiles (ci, database, docker,
  infra-code, opnsense, proxmox); the cheap-haiku read-only agents (cost, deps, health).
- Already-graduated vendor skills (dev-prisma/-supabase/-shadcn skill = pointers — KEEP),
  standalone utilities (assistant-auto, git-rename, lessons), deep skill-only items
  (dev-auth/-i18n/-nextjs/-frontend-design, ops-mobile-release).
- `qa-perf` vs `dev-react-perf` is NOT redundant (measurement workflow vs React patterns —
  already explicitly scoped).

## Recommended execution — 4 waves (sequence by risk × leverage)

### Wave 1 — Collapse passthrough agents (S, low risk, zero capability loss)
Drop agents that are pure skill-passthroughs (read-only/default tools, no orchestration
role, not dispatched by qa-loop). Keep the command + skill. **−13 agents.**
- dev: `dev-component`, `dev-design-system`, `dev-trpc`, `dev-ai-integration`, `dev-rag`
- vendor cleanup (skill already a pointer): `dev-prisma`, `dev-supabase` agents; `ops-vercel` stale agent
- ops: `ops-serverless`
- qa: `qa-design`, `qa-tech-debt`, `qa-coverage`
- data: `data-modeling` (cmd↔agent near-verbatim — keep one form)

### Wave 2 — Sibling merges, biggest command reductions (M)
- **API cluster**: fold `dev-graphql` + `dev-trpc` + `dev-api-versioning` into `dev-api`
  (one skill of record). **−3 cmds.**
- **GitFlow family**: collapse `ops-gitflow-{init,feature,release,hotfix}` into one
  `ops-gitflow` mode-arg command; fold gitflow-release→`ops-release`, gitflow-hotfix→`ops-hotfix`.
  **−3 cmds.**
- **doc umbrella**: `doc-readme` + `doc-architecture` → `doc-generate` (both are steps of its
  own workflow). **−2 cmds.**

### Wave 3 — Module-internal + qa merges (M)
- qa: `qa-responsive`→`qa-design`; `qa-kaizen`+`qa-coverage`→`qa-tech-debt`. **−3 cmds.**
- ops twins: `ops-observability-stack`→`ops-monitoring`; `ops-cost-optimization`→`ops-cost`
  (or rename `ops-cloud-cost`); evaluate `ops-disaster-recovery`→`ops-backup`. **−2 to −3.**
- biz (opt-in): `biz-market`→`biz-competitor`; `biz-okr`→`biz-roadmap`. **−2.**
- growth (opt-in): `growth-funnel`+`growth-onboarding`→`growth-cro` (the CRO hub already
  claims signup/checkout/landing/onboarding scope). **−2.**
- legal (opt-in): resolve `legal-docs` umbrella overlap with `legal-terms-of-service` /
  `legal-privacy-policy` (and privacy-policy vs `legal-rgpd`). **−0 to −2.**
- dev: `dev-test`→`dev-tdd` (already borrows `skills:[dev-tdd]`); `dev-hook`→`dev-component`;
  demote `dev-testing-setup` to a section. **−2 to −3.**
- work (floor, conservative): slim `work-commit-push-pr` to *delegate* to work-commit/work-pr
  instead of restating them (keep the macro). **−0 cmds, removes duplication.**

### Wave 4 — Bugs & misfiling found en route (S)
- **Flutter-coupling bug**: `dev-graphql` and `dev-supabase` command/agent bodies are
  hard-coded to Flutter (`graphql_flutter`, `supabase_flutter`) despite generic names —
  copy-from-template artifacts; de-couple when merging.
- **Misfiled**: `doc-fix-issue` is an autonomous issue→PR TDD bugfix flow, not docs —
  duplicates `work-flow-bugfix` + `dev-debug`; relocate out of `doc/` or kill.
- Several collapsed agents (`dev-trpc`, `dev-design-system`, `dev-rag`) were framed as
  "builders" yet lacked Edit/Write — confirms they were never functional agents.

## Open decision for the maintainer

Pick the target: **(a) full targeted consolidation** (all 4 waves → ~110/48/53) or
**(b) Wave-1-only** (collapse the 13 passthrough agents, the safest zero-loss win, and
re-evaluate). Each wave ships via the proven module-change loop (bats RED→GREEN, counts
regen, one PR per wave). Removing commands/agents is breaking → MINOR with deprecation
pointers, or batch into a MAJOR. Cross-links in the merged-away items must be redirected
(tie-in: the P3 reference-graph validator would guard this automatically).
