---
sidebar_position: 10
title: Advanced Features
description: Opus 4.8, Agent Teams, Plugins, LSP, MCP and advanced features of Claude Code
---

# Advanced Features

> Advanced capabilities of Claude Code: Opus 4.8, Agent Teams, Plugins, LSP and more

## Opus 4.8: New Capabilities

Claude Opus 4.8 (`claude-opus-4-8`) brings major improvements for Claude Code.

### Adaptive Thinking

Replaces the "extended thinking" toggle with 4 effort levels:

| Level | Usage | Relative cost |
|--------|-------|-------------|
| `low` | Simple tasks, rephrasings | $ |
| `medium` | Standard code, moderate analyses | $$ |
| `high` | Complex problems, deep audits | $$$ |
| `xhigh` | Critical tasks, architecture, advanced debugging | $$$$ |

The model automatically adjusts its effort based on the detected complexity. It is also possible to force a level via the API:

```typescript
const response = await anthropic.messages.create({
  model: 'claude-opus-4-8',
  max_tokens: 16384,
  thinking: {
    type: 'enabled',
    budget_tokens: 10000,  // budget for reasoning
    effort: 'high',        // low | medium | high | xhigh
  },
  messages: [{ role: 'user', content: prompt }],
});
```

### 1M token context window (default)

Opus 4.8 supports up to **1 million tokens** as input **by default** on the Claude API, Amazon Bedrock and Vertex AI (no longer a beta opt-in). Standard pricing applies up to 200k tokens, with premium pricing beyond that.

| Tier | Pricing |
|---------|-------------|
| 0 - 200k tokens | Standard |
| 200k - 1M tokens | Premium (increased rate) |

### 128k tokens of output

The output limit is raised to **128k tokens** (compared to 8k-32k previously), allowing the generation of complete files, extensive documentation, or massive refactorings in a single response.

### Context Compaction

Automatically summarizes old context to maintain coherence over long sessions. Particularly useful with parallel sessions (git worktrees) and complex multi-file tasks.

## Agent Teams (Experimental)

Parallel coordination of agent teams on complex tasks. A lead agent orchestrates teammates who work in parallel with direct communication between them.

> **Activation required**: Experimental feature disabled by default.

### Activation

```json
// .claude/settings.json or .claude/settings.local.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT TEAM                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐                                               │
│   │  TEAM LEAD   │ <── You interact with the lead                │
│   │ (coordinates)│                                               │
│   └──────┬───────┘                                               │
│          │                                                       │
│          ├──── Shared Task List ────┐                             │
│          │                          │                             │
│    ┌─────┴─────┐  ┌──────────┐  ┌──┴───────┐                    │
│    │ Teammate 1 │  │ Teammate 2│  │ Teammate 3│                   │
│    │ (security) │  │ (perf)   │  │ (a11y)   │                   │
│    └────────────┘  └──────────┘  └──────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Display modes

| Mode | Description | Prerequisites |
|------|-------------|-----------|
| `auto` (default) | Split-panes if in tmux, otherwise in-process | - |
| `in-process` | All agents in the main terminal | None |
| `tmux` | Each agent in its own pane | tmux installed |

```bash
# Force a mode
claude --teammate-mode tmux
```

### Comparison of parallel approaches

| | Sub-Agents (Task) | Agent Teams | Manual sessions (worktrees) |
|---|---|---|---|
| **Communication** | Return to parent | Direct messaging | None |
| **Coordination** | Parent manages | Shared tasks | Manual |
| **Token cost** | Low | High | High |
| **Ideal for** | Focused tasks | Complex collaboration | Independent branches |

### Keyboard shortcuts

| Shortcut | Action |
|-----------|--------|
| `Shift+Up/Down` | Navigate between teammates |
| `Shift+Tab` | Delegate mode (lead = coordination) |
| `Ctrl+T` | Display the task list |

### Environment variables

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enables the feature (value: `1`) |
| `CLAUDE_CODE_TASK_LIST_ID` | Shares a task list between sessions |

### Limitations

- No resume of in-process teammates after `/resume`
- Only one team per session
- No nested teams
- Split-panes not supported in VS Code / Windows Terminal / Ghostty

### Usage in the foundation

The foundation provides an [agent-teams skill](/docs/skills/agent-teams) and a [/work:work-team command](/docs/commands/work/work-team) with pre-configured patterns:

```bash
# Parallel audit (3 agents: security, perf, a11y)
/work:work-team "full project audit"

# Team feature (frontend, backend, tests)
/work:work-team "implement notifications"

# Collaborative debug (concurrent hypotheses)
/work:work-team "investigate the login bug"
```

## Output Styles

Customized interaction modes in `.claude/output-styles/` (10 styles):

| Style | Usage | Command |
|-------|-------------|----------|
| `teaching` | Pedagogical mode with explanations | `/output-style teaching` |
| `explanatory` | Detailed reasoning, understand the why | `/output-style explanatory` |
| `concise` | Brief and direct responses | `/output-style concise` |
| `technical` | In-depth technical details | `/output-style technical` |
| `review` | Structured code review | `/output-style review` |
| `emoji` | Responses enriched with emojis | `/output-style emoji` |
| `minimal` | Clean responses without decoration | `/output-style minimal` |
| `structured` | ASCII structure with separators | `/output-style structured` |
| `debug` | Diagnostic and bug investigation | `/output-style debug` |
| `metrics` | Metrics and dashboards | `/output-style metrics` |

See the [Output Styles](/docs/concepts/output-styles) page for the full documentation.

## Specification Templates

Structured templates for the Explore → Specify → Plan → TDD → Audit → Commit workflow in `.claude/templates/`:

| Template | Description | Used by |
|----------|-------------|-------------|
| `spec-template.md` | Functional specification with User Stories | `/work:work-specify` |
| `plan-template.md` | Technical implementation plan | `/work:work-plan` |
| `tasks-template.md` | Breakdown into tasks per User Story | `/work:work-plan` |

### Structure of a Specification

```
specs/[feature]/
├── spec.md           # Functional specification
├── plan.md           # Implementation plan
├── tasks.md          # Breakdown into tasks
└── clarifications.md # History of clarifications (opt)
```

### Conventions

| Marker | Meaning |
|----------|---------------|
| `P1` | MVP priority (essential) |
| `P2` | Important priority |
| `P3` | Nice-to-have priority |
| `[P]` | Parallelizable task |
| `[US1]` | Belongs to User Story 1 |
| `EF-XXX` | Functional Requirement |
| `CS-XXX` | Success Criterion |

## MCP Configuration

Centralized configuration of MCP servers in `.mcp.json`:

### Base servers

| Server | Usage |
|--------|-------|
| `filesystem` | Advanced file access |
| `memory` | Persistent memory |
| `fetch` | External HTTP requests |
| `github` | GitHub integration |
| `postgres` | PostgreSQL connection |
| `sqlite` | Local SQLite database |
| `puppeteer` | Browser automation |
| `sequential-thinking` | Structured step-by-step reasoning |

### Servers recommended by Boris Cherny

| Server | Usage |
|--------|-------|
| `slack` | Bug search in threads, team communication |
| `sentry` | Error analysis and monitoring in production |
| `bigquery` | Direct analytics queries |
| `linear` | Project and issue management |
| `notion` | Documentation and knowledge bases |

To enable a server, copy its block from `.mcp.json.example` into `.mcp.json` (which ships empty as `{"mcpServers": {}}`). There is no per-server `"enabled"` flag — a server is active if and only if it is present in `.mcp.json`.

## CLAUDE.md @imports

CLAUDE.md files support importing files with the `@path/to/file` syntax:

```markdown
# Import files into CLAUDE.md
See @README for project overview and @package.json for npm commands.

# Individual instructions (not committed)
@~/.claude/my-project-instructions.md
```

### Import rules
- Relative and absolute paths supported
- Recursive imports (max 5 levels)
- Not evaluated inside markdown code blocks
- Alternative to CLAUDE.local.md for multiple worktrees
- View loaded imports with `/memory`

## Plugins

Plugin system to distribute skills, agents, hooks and MCP servers:

### Structure of a plugin

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       # Manifest (name, version, description)
├── commands/              # Legacy commands / skills
├── skills/                # Skills with SKILL.md
├── agents/                # Sub-agents
├── hooks/
│   └── hooks.json         # Plugin hooks
├── .mcp.json              # MCP servers
└── .lsp.json              # LSP servers
```

### Usage

```bash
# Test a plugin locally
claude --plugin-dir ./my-plugin

# Skills are namespaced
/my-plugin:skill-name
```

### When to use plugins vs standalone

| Approach | Skill naming | Usage |
|----------|---------------|-------|
| Standalone (`.claude/`) | `/hello` | Personal, single project |
| Plugin | `/plugin:hello` | Team sharing, distribution, multi-project |

## LSP (Language Server Protocol)

LSP configuration in `.lsp.json` for semantic code navigation.

### Activation

```bash
export ENABLE_LSP_TOOL=1
```

### Supported languages (12)

| Language | Server |
|---------|---------|
| TypeScript/JavaScript | `typescript-language-server` |
| Python | `pylsp` |
| Go | `gopls` |
| Rust | `rust-analyzer` |
| Java | `jdtls` |
| C/C++ | `clangd` |
| C# | `omnisharp` |
| PHP | `phpactor` |
| Kotlin | `kotlin-language-server` |
| Ruby | `solargraph` |
| HTML | `vscode-html-language-server` |
| CSS | `vscode-css-language-server` |

### LSP vs Grep

| Need | Tool | Why |
|--------|-------|----------|
| Definition of a symbol | LSP `goToDefinition` | Semantic resolution |
| All references | LSP `findReferences` | Real usages, no false positives |
| Text/pattern search | Grep | Faster for textual searches |
| Structure navigation | LSP `documentSymbol` | Tree of classes/functions |
| Type errors | LSP `getDiagnostics` | Real-time diagnostics |

---

## See also

- [Output Styles](/docs/concepts/output-styles) - Formatting styles
- [Best Practices](/docs/reference/best-practices) - Boris Cherny recommendations
- [agent-teams skill](/docs/skills/agent-teams) - Agent Teams documentation
- [/work:work-team command](/docs/commands/work/work-team) - Agent Teams launch
- [Back to concepts](/docs/concepts)
