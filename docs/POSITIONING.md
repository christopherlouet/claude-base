# Positioning — how claude-base fits the AI-coding ecosystem

claude-base plays **two roles**, both Claude-Code-native:

1. **Workflow framework** — the foundation owns the rigor: Explore → Specify → Plan → TDD → Audit, enforced via path-specific rules (TypeScript strict, OWASP, WCAG, perf), wired into hooks (`settings.json`, PostToolUse tsc+eslint, gitleaks, anti-drift counters), orchestrated via the `claude-base` CLI.
2. **Curator** — for tool-specific depth (React, Prisma, Supabase, MSW, Docker, Web Vitals, Chrome DevTools, analytics, email, SEO…), the foundation points to vendor-published skills validated through audit pilots (see [`docs/recipes/recommended-vendor-skills.md`](./recipes/recommended-vendor-skills.md)). Each vendor maintains their own canonical content; we curate the list of which ones are worth trusting — kept current by a deterministic, billing-safe **curation engine** (nightly rot-watch + monthly discovery, observe-never-install).

The foundation does NOT chase vendor freshness: a 1-maintainer project can't out-update a 6,700+ skill ecosystem refreshed daily. Instead, the skills the foundation ships either (a) capture **workflow patterns** that survive across vendor releases (TDD discipline, audit-loop orchestration, deploy-safety checklists), or (b) **point** to the canonical vendor source with a thin foundation-specific discipline overlay.

Two adjacent ecosystems share part of the surface area.

## vs [Spec Kit](https://github.com/github/spec-kit) (GitHub, Spec-Driven Development across 30+ agents)

Spec Kit is the **canonical SDD primitives toolkit**: `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement` — agent-agnostic, well-documented, batteries-included. If you need spec-driven development that works across Claude, Codex, Cursor, Copilot and 30+ other agents, **use spec-kit**.

claude-base is **the opinionated discipline layer on top of (or in place of) those primitives, specifically for Claude Code**. It adds what Spec Kit does not:

| | spec-kit | claude-base |
|---|---|---|
| Scope | Multi-agent (30+) | Claude Code-native + cross-tool via [`AGENTS.md`](../AGENTS.md) |
| Spec → Plan → Tasks → Implement | ✓ | ✓ (different command names; same workflow shape) |
| Explore phase (read-before-write) | — | ✓ `/work:work-explore` |
| TDD enforced (tests-first mandatory) | — | ✓ via `tdd-enforcement` rule + `/dev:dev-tdd` |
| Adaptive audit-fix loop (quality score) | — | ✓ `/qa:qa-loop "score 90"` |
| Path-specific rules (TS strict, OWASP, WCAG, perf...) | — | ✓ auto-activated rules |
| Hooks wired into `settings.json` (PostToolUse tsc+eslint, gitleaks, anti-drift) | — | ✓ |
| Anti-drift CI strategy (`counts.json`, `audit-docs.sh` firewall) | — | ✓ |
| Stack presets with vendor-skill pointers | — | ✓ presets in 3 tiers |

**They are complementary, not competing.** If you adopt SDD primitives, spec-kit is the canonical choice. If you want Claude Code with deep TDD/audit/rules baked in, claude-base ships the opinionated stack. There's no clean way to package claude-base as a spec-kit extension (the rules engine, hooks wiring, and presets system have no spec-kit equivalent) — but a project can reasonably use both: spec-kit for the multi-agent SDD primitives, claude-base for the Claude-Code-side discipline.

## vs the [official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) (vendor-published skills/plugins)

For deeper coverage of **specific tools** — vendor-published skills for Terraform, Postgres, Playwright, MongoDB, observability stacks, framework-specific patterns — the marketplace and community skills ship targeted depth that goes further than what a foundation could bundle. That's the design: a foundation curates **workflow integration + a trusted list**, vendor skills curate **depth on a single tool or stack**.

**Recommended pattern**

```
claude-base (workflow framework + curator)   ← Explore → TDD → Audit, anti-drift, qa-loop, hooks, rules
       +
vendor skills (tool-specific depth)          ← Prisma, Supabase, Playwright, Grafana, MSW, PostHog, ...
```

The foundation ships a full command + agent + skill catalogue, but most skills are **thin pointers** pairing the canonical vendor source with a few foundation-specific discipline lines (security/GDPR wraps, anti-patterns, cross-skill orchestration). What's NOT pointer-shaped is the workflow layer:

- **Workflow rigor coordinated as one experience** — TDD enforcement, autonomous `qa-loop` audit-fix cycle, score-90 gates
- **Anti-drift counter strategy** across the entire foundation, CI-enforced via `counts.json` + a doc drift firewall (`scripts/audit-docs.sh`)
- **Path-specific rules** auto-activated by file path (TypeScript strict, OWASP defaults, WCAG, Core Web Vitals, deploy-safety)
- **PostToolUse output rewriter** for Bash + tsc/eslint (Claude Code 2.1.121+)
- **A personal cross-project lessons referential** — the foundation learns from your mistakes and carries the lessons into every project ([recipe](./recipes/personal-lessons-referential.md))
- **Integrated install + update flow** via the `claude-base` CLI

## How the curator role works today

[`docs/recipes/recommended-vendor-skills.md`](./recipes/recommended-vendor-skills.md) lists the vendor skills validated through audit pilots, organised by stack (see the *By stack* matrix) and by domain. You install the ones matching your stack; the foundation does not bundle them (vendors handle their own distribution and updates). A deterministic, **billing-safe curation engine** keeps that list honest — a **nightly, LLM-free rot-watch** ($0 tokens) flags archived/abandoned/drifted entries and a **monthly, budget-capped discovery** proposes new candidates; both are **observe-and-propose only** (see [`docs/recipes/curation-bot-deploy.md`](./recipes/curation-bot-deploy.md)).

**Where this is going**: see [`specs/foundation-positioning-review/phase-6-curator-bindings.md`](../specs/foundation-positioning-review/phase-6-curator-bindings.md) — the next milestone wires preset detection to per-stack vendor-skill recommendations, surfaced in a single `claude-base init` prompt instead of leaving the curation as a homework assignment.
