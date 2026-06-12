---
name: agent-teams
description: Multi-agent team orchestration with native Agent Teams. Trigger when the user wants to launch a team of agents, coordinate parallel work with inter-agent communication, or use swarm mode.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
---

# Agent Teams (Multi-Agent Orchestration)

> Coordinate multiple Claude Code instances working together as a team, with shared tasks, inter-agent messaging, and centralized management.

## Prerequisites

- **Claude Code >= 2.1.19**
- **Feature flag enabled**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- **tmux** (optional): for split-panes mode

### Activation

Add to `.claude/settings.local.json` or `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or via environment variable:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## When to use Agent Teams vs Sub-Agents

```
┌────────────────────────────────────────────────────────────────────┐
│           AGENT TEAMS vs SUB-AGENTS: DECISION GUIDE                │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  AGENT TEAMS if:                                                   │
│  - Agents need to COMMUNICATE with each other                     │
│  - COMPLEX work requiring discussion and collaboration            │
│  - Tasks with coordination (cross-review, debate, consensus)      │
│  - 3+ agents working in parallel over a long duration             │
│                                                                    │
│  SUB-AGENTS (Task tool) if:                                        │
│  - FOCUSED task where only the result matters                     │
│  - No need for inter-agent communication                          │
│  - 1-2 agents for short tasks                                     │
│  - Token economy is the priority                                  │
│                                                                    │
│  MANUAL PARALLEL SESSIONS (git worktrees) if:                      │
│  - Full control over each session                                 │
│  - No need for automatic coordination                             │
│  - Work on completely independent branches                        │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Comparison table

| | Sub-Agents (Task) | Agent Teams | Manual sessions |
|---|---|---|---|
| **Context** | Clean, result returned | Clean, independent | Clean, independent |
| **Communication** | Return to parent only | Direct messaging between agents | None (manual) |
| **Coordination** | Main agent handles everything | Shared task list | Manual |
| **Token cost** | Low | High (1 context per agent) | High |
| **Ideal for** | Focused tasks | Complex collaborative work | Independent branches |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT TEAM                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐                                               │
│   │  TEAM LEAD   │ ←── You interact with the lead                │
│   │ (coordinates)│                                               │
│   └──────┬───────┘                                               │
│          │                                                       │
│          ├──── Shared Task List ────┐                             │
│          │                          │                             │
│    ┌─────┴─────┐  ┌──────────┐  ┌──┴───────┐                    │
│    │ Teammate 1 │  │ Teammate 2│  │ Teammate 3│                   │
│    │ (security) │  │ (perf)   │  │ (a11y)   │                   │
│    └────────────┘  └──────────┘  └──────────┘                    │
│          ↕              ↕              ↕                          │
│       Direct messaging between agents                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

| Component | Role |
|-----------|------|
| **Team Lead** | Main session, creates the team, coordinates the work |
| **Teammates** | Independent Claude Code instances, execute the tasks |
| **Task List** | Shared list of tasks with statuses and dependencies |
| **Mailbox** | Messaging system for inter-agent communication |

## Display modes

| Mode | Description | Prerequisites |
|------|-------------|---------------|
| `in-process` | All teammates in the main terminal. Navigation: `Shift+Up/Down` | None |
| `tmux` | Each teammate in its own tmux pane | tmux installed |
| `auto` (default) | Split-panes if already in tmux, otherwise in-process | - |

Configuration in `settings.json`:

```json
{
  "teammateMode": "auto"
}
```

Or via command line:

```bash
claude --teammate-mode tmux
```

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `Shift+Up/Down` | Navigate between teammates (in-process mode) |
| `Shift+Tab` | Switch to delegate mode (lead = coordination only) |
| `Ctrl+T` | Show/hide the task list |
| `Enter` | Enter a teammate's session |
| `Escape` | Interrupt a teammate's turn |

## Team lifecycle

```
1. CREATE the team   → Describe the task and desired structure
       │
       ▼
2. SPAWN teammates   → The lead creates the specialized agents
       │
       ▼
3. COORDINATE        → Shared tasks, messaging, delegation
       │
       ▼
4. SYNTHESIZE        → The lead combines the results
       │
       ▼
5. SHUTDOWN          → Stop each teammate cleanly
       │
       ▼
6. CLEANUP           → Clean up the team's resources
```

### Launch example

```
Create a team of 3 agents to audit this project in parallel:
- A security agent (focus on OWASP Top 10)
- A performance agent (focus on Core Web Vitals)
- An accessibility agent (focus on WCAG 2.1 AA)
Each produces a report, then synthesize the results.
```

### Delegate mode (recommended for teams > 3 agents)

Delegate mode prevents the lead from implementing itself, forcing it to stay in coordination:
- Activate with `Shift+Tab` after creating the team
- The lead can only: spawn, send messages, manage tasks, shutdown
- Recommended when you want the lead to focus on orchestration

## Best practices

- **2-5 teammates**: beyond that, coordination becomes expensive in tokens
- **5-6 tasks per agent**: enough to keep agents productive
- **File isolation**: each agent works on different files
- **Explicit context**: give a detailed prompt to each teammate at spawn
- **Plan approval**: for risky tasks, ask the lead to approve the plan before execution
- **Regular monitoring**: check progress, redirect if needed

## Known limitations

| Limitation | Workaround |
|------------|------------|
| No resume for in-process teammates | The lead re-creates the team after `/resume` |
| Only one team per session | Cleanup before creating a new team |
| No nested teams | Only the lead can manage the team |
| Fixed lead (no transfer) | The creator stays lead for the whole duration |
| Two agents on the same file = overwrite | Split the work by file |
| Split-panes not supported in VS Code / Windows Terminal | Use in-process mode |

## Pre-configured patterns

See @patterns.md for the 4 ready-to-use patterns:

| Pattern | Teammates | Use case |
|---------|-----------|----------|
| **Audit** | 3-4 agents (security, perf, a11y, design) | Full quality audit |
| **Feature** | 2-3 agents (frontend, backend, tests) | Multi-layer development |
| **Debug** | 3-5 agents (concurrent hypotheses) | Complex bug investigation |
| **Review** | 3 agents (security, perf, coverage) | Parallel code review |

## Full example: Parallel audit

```
/work:work-team "Full project audit"
```

The lead will:
1. Create an "audit-team"
2. Spawn 3 teammates:
   - **security-reviewer**: "Audit the code for OWASP Top 10 vulnerabilities. Focus on authentication, injections, and sensitive data."
   - **perf-analyst**: "Analyze performance. Focus on slow queries, bundle size, and Core Web Vitals."
   - **a11y-checker**: "Check WCAG 2.1 AA accessibility. Focus on contrast, keyboard navigation, and screen readers."
3. Each agent works independently
4. The lead synthesizes into a consolidated report
5. Shutdown and cleanup

## Full example: Feature as a team

```
/work:work-team "Implement the notifications system"
```

The lead will:
1. Create the team and decompose the work:
   - **backend-dev**: "Implement the notifications service in `src/services/notification.ts` and the API endpoints."
   - **frontend-dev**: "Create the NotificationCenter component in `src/components/` and the associated hooks."
   - **test-writer**: "Write the unit and integration tests for the notifications system."
2. Manage dependencies via the task list (backend before frontend)
3. The test-writer can start with the tests (TDD) while the devs are planning
4. Merge once all agents are done

## Recent CLI surface (CLI 2.1.142+)

The `claude agents` subcommand for dispatched background sessions gained per-session configuration flags: `--add-dir`, `--settings`, `--mcp-config`, `--plugin-dir`, `--permission-mode`, `--model`, `--effort`, `--dangerously-skip-permissions`. Useful when a teammate needs a different model than the lead (e.g. dispatch a Haiku worker for grep-heavy tasks while the lead stays on Opus), a tighter permission mode, or an alternate `.mcp-config`. Fast mode runs on **Opus 4.8** (also available on 4.7/4.6).

For the foundation's own heaviest dispatched sessions (large multi-PR migrations, deep audits), `--model claude-fable-5` selects Anthropic's most capable model — a deliberate, costlier choice (~2× Opus 4.8). This is a per-session selection only: agent `model:` frontmatter is unchanged and there is no `fable` tier alias.

### Agent View (research preview)

Anthropic ships an **Agent View** (research preview, May 2026): a unified terminal dashboard that lists every running session, their current state, last responses, and a key to jump back into any of them. Complementary to the in-process Team Lead model — Agent View covers cross-process sessions that the Team Lead can't see. See the [official preview note](https://code.claude.com/docs/en/whats-new) for activation.

## See also

- Skill `parallel-agents` for orchestration via Task sub-agents
- Skill `git-worktrees` for manual parallel sessions
- Skill `session-handoff` for context handoff between sessions
- `/work:work-team` for the direct launch command
