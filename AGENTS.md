# AGENTS.md

Cross-tool entry point for AI coding agents (Claude Code, Codex, Cursor, Copilot, Gemini CLI, and other [Agent Skills](https://agentskills.io)-compatible tools).

Native home is Claude Code — `.claude/skills/` and `.claude/rules/` directories follow the Anthropic conventions. The skills use the **SKILL.md open standard frontmatter** (`name`, `description`), so other agents can read them; Claude-specific extensions (`allowed-tools`, `context: fork`, `model`) are silently ignored by tools that don't support them.

## Workflow

Full mandatory workflow and project conventions: [`CLAUDE.md`](CLAUDE.md)

> Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit

## Skills

Reusable agent skills: [`.claude/skills/`](.claude/skills/)

Each subdirectory contains a `SKILL.md` (with YAML frontmatter) plus optional `examples/`, `references/`, `scripts/`. Catalog: [`docs/reference/skills-catalog.md`](docs/reference/skills-catalog.md). Examples of widely-applicable skills:
- `work-quick/` — trivial one-shot fix (< 50 LOC, 1-3 files)
- `work-explore/` — read-only codebase mapping before any modification
- `work-plan/` — implementation plan from a spec
- `dev-tdd/` — Red-Green-Refactor TDD cycle
- `writing-skills/` — guide for authoring new skills

## Rules

Path-scoped coding rules auto-activated by file type: [`.claude/rules/`](.claude/rules/)

30 rules covering TypeScript, React, Next.js, Flutter, Go, Python, security, TDD enforcement, accessibility, performance, and more. Catalog and priority order: [`.claude/rules/README.md`](.claude/rules/README.md).

## Agents

Specialist sub-agents (Claude Code-specific): [`.claude/agents/`](.claude/agents/)

Each `.md` file describes a focused sub-agent. Catalog: [`docs/reference/agents-catalog.md`](docs/reference/agents-catalog.md).

## Presets

Curated stack bundles: [`.claude/presets/`](.claude/presets/) (maintainer-vouched, vendor-pointer). Install via `./scripts/new-project.sh --preset <name> <path>`.

## Key Conventions

- Language: TypeScript strict, no `any`; tests 80%+ coverage; Conventional Commits.
- Security always overrides other rules.
- Never commit secrets (`.env`, credentials, API keys); MCP servers disabled by default in `.mcp.json`.
- Foundation maintenance discipline: every addition under `.claude/` must keep `./scripts/validate-counts.sh` green.
