# Positioning — how claude-base fits the AI-coding ecosystem

claude-base plays **two roles**, both Claude-Code-native:

1. **Workflow framework** — the foundation owns the rigor: Explore → Specify → Plan → TDD → Audit, enforced via path-specific rules (TypeScript strict, OWASP, WCAG, perf), wired into hooks (`settings.json`, PostToolUse tsc+eslint, gitleaks, anti-drift counters), orchestrated via the `claude-base` CLI.
2. **Curator** — for tool-specific depth (React, Prisma, Supabase, MSW, Docker, Web Vitals, Chrome DevTools, analytics, email, SEO…), the foundation points to vendor-published skills validated through audit pilots (see [`docs/recipes/recommended-vendor-skills.md`](./recipes/recommended-vendor-skills.md)). Each vendor maintains their own canonical content; we curate the list of which ones are worth trusting — kept current by a deterministic, billing-safe **curation engine** (nightly rot-watch + monthly discovery, observe-never-install).

The foundation does NOT chase vendor freshness: a 1-maintainer project can't out-update a 6,700+ skill ecosystem refreshed daily. Instead, the skills the foundation ships either (a) capture **workflow patterns** that survive across vendor releases (TDD discipline, audit-loop orchestration, deploy-safety checklists), or (b) **point** to the canonical vendor source with a thin foundation-specific discipline overlay.

Two adjacent ecosystems share part of the surface area.

## Capability comparison

The structured **workflow** (explore → specify → plan → TDD → audit) is now
table-stakes — most serious Claude Code setups ship some form of it. So it is
**not** what differentiates claude-base from similar projects. The differentiators
are *mechanical enforcement*, the *anti-gaming* layer, and *curation*. The matrix
below is from a 2026-06-28 capability audit of public repos/docs.

| Capability | spec-kit | SuperClaude | claude-code-templates | shinpr boilerplate | moai-adk | oh-my-claudecode | trailofbits | **claude-base** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| Multi-phase workflow | ✓ | ✓ | ~ | ✓ | ✓ | ✓ | ~ | ✓ |
| **Quality enforcement** (blocks commit-on-failing-tests / secret-in-content / `--no-verify`), by default | ✗ | ✗ | ~ opt-in | ~ lint only | ~ OS-safety | ~ workflow-only | ~ OS-safety | **✓** |
| **Anti-gaming gates** (block linter-weakening / hollow-`.only`-stub tests / gate-bypass) | ✗ | ✗ | ✗ | ✗ | ~? | ✗ | ✗ (documented, not shipped) | **✓** |
| Path-scoped rules auto-injected per file | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✓ |
| Curation engine for community skills | ~ catalog | ✗ | ~ security-only | ✗ | ✗ | ✗ | ~ external marketplace | **✓** |
| Cross-project lessons / memory | ✗ | ~ session | ✗ | ✗ | ~ per-project | ✓ | ✗ | ✓ |
| Own test suite + CI | ✓ | ✓ | ✓ | ~ (tests off) | ✓ | ✓ | ✗ | ✓ |

✓ present · ~ partial/opt-in/adjacent · ✗ no evidence found

**Read of the matrix.**
- **Anti-gaming is the clearest differentiator** — no audited project ships it
  (Trail of Bits *documents* an anti-rationalization hook but does not ship it).
- **Default, integrated quality enforcement** — several ship *pieces* (OS-safety
  blocks, opt-in component hooks, a workflow-continuation block), but none block
  the failing-tests / secret-in-content / `--no-verify` set by default and
  integrated.
- **Curation** is near-unique (one ships security-only PR scanning; one points to a
  separately, human-reviewed marketplace).
- The closest overlap is **oh-my-claudecode** (workflow, path-rules, cross-project
  learning, CI) — but it lacks anti-gaming, curation, and the quality-gate set.
- **Cross-project lessons** are shared only with oh-my-claudecode — but theirs
  *auto*-extracts skills to user scope, whereas claude-base's is a **human-gated,
  sanitized lessons referential** (you approve each one-line lesson; it lands in
  your own `~/.claude/rules/lessons.md`, loaded into every project, never committed).
  Approval + sanitization are the distinction, not just "has memory".

These deterministic gates are demonstrable: the executable
[`eval/value-proof/gate-demo`](../eval/value-proof/gate-demo/) matrix shows each one
catching a planted violation while sparing a clean control.

> **Method caveat.** The audit relied on each project's README/source (not
> clone-and-run), so a ✗ means "no evidence found in the public config/docs", not
> a proof of absence. Capabilities of fast-moving projects drift; corrections
> welcome.

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

## Long-term direction

claude-base's irreducible value is the workflow rigor (TDD, audit-loop, anti-drift) and the path-specific rules. **Domain-specific knowledge is increasingly available as vendor-published skills/plugins** in the official Claude Code marketplace. The foundation lives alongside the marketplace, not in opposition.

Four mechanisms keep it aligned with that trajectory:

1. **A living curation engine** (not one-off manual audits) — a deterministic, **billing-safe** system keeps the recommended list current: a **nightly LLM-free rot-watch** ($0 tokens) flags archived / abandoned / popularity-collapse / license-change / content-drift, and a **monthly, budget-capped discovery** proposes new candidates after trust + safety + advice-neutrality gates (it also flags *moat-encroachment* as a strategic signal). **Observe-never-install** — the most it does is open a draft PR / propose-only issue. Deploy: [`docs/recipes/curation-bot-deploy.md`](./recipes/curation-bot-deploy.md).
2. **Advice-neutrality over publisher-veto** — skills are judged on whether their *advice* pushes lock-in or steers you off your stack/Claude, not on who published them; the publisher is *disclosed as provenance*. Every recommendation is **pinned** and **safety-screened** (popularity ≠ safety). Output: [`docs/recipes/recommended-vendor-skills.md`](./recipes/recommended-vendor-skills.md).
3. **Recommended vendor skills per preset** — surfaced at `claude-base init`/`update`, with recommendation **drift tracked** across updates. Manual install only; the foundation does NOT auto-install third-party code.
4. **Trajectory-driven automation** — when most vendors are on the official marketplace, automating install becomes safe. We don't today (~21% are on the official marketplace, as of last audit) but will revisit when the ratio inverts.
