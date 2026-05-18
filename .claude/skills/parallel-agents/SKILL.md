---
name: parallel-agents
description: Orchestration of parallel agents to maximize efficiency. Trigger when a task can be decomposed into independent sub-tasks that can run in parallel.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
---

# Parallel Agents Orchestration

## Goal

Decompose complex tasks into independent sub-tasks and run them in parallel via specialized sub-agents to maximize efficiency.

## When to use parallelism

```
┌──────────────────────────────────────────────────────────────────┐
│                   DECISION: PARALLEL OR SEQUENTIAL ?              │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PARALLEL if:                                                     │
│  - INDEPENDENT sub-tasks (no data dependency)                    │
│  - MERGEABLE results (combinable without conflict)               │
│  - Task DECOMPOSABLE into distinct parts                         │
│                                                                   │
│  SEQUENTIAL if:                                                   │
│  - Result A required to start B                                  │
│  - Modifications on the SAME files                               │
│  - Execution order MATTERS                                       │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Parallelization patterns

### 1. Fan-Out / Fan-In

```
         ┌─→ [Agent A: security audit] ─→┐
         │                                 │
[Task]  ─┼─→ [Agent B: perf audit]     ─→┼─→ [Combined report]
         │                                 │
         └─→ [Agent C: a11y audit]     ─→┘
```

**Usage:** Audits, multi-criteria analyses, parallel reviews

### 2. Map-Reduce

```
[Files] ─→ [Agent 1: file A] ─→┐
        → [Agent 2: file B] ─→┼─→ [Synthesis]
        → [Agent 3: file C] ─→┘
```

**Usage:** Code analysis by module, tests by domain

### 3. Pipeline with parallel steps

```
[Step 1] ─→ [Step 2a] ─→┐
            [Step 2b] ─→┼─→ [Step 3]
            [Step 2c] ─→┘
```

**Usage:** Build pipeline, workflow with independent steps

## Common parallelizable tasks

### Audits and analyses

| Task | Parallel agents | Result |
|------|----------------|--------|
| Full audit | `qa-security` + `qa-perf` + `wcag-audit` | Combined report |
| Code review | `qa-review` per module/file | Issue list |
| Exploration | `work-explore` per functional domain | Code map |

### Development

| Task | Parallel agents | Result |
|------|----------------|--------|
| Tests per module | `dev-test` per service | Test suite |
| Documentation | `doc-generate` per component | Complete docs |
| Migration | `ops-migrate` per dependency | Complete migration |

### Business

| Task | Parallel agents | Result |
|------|----------------|--------|
| Market research | `biz-competitor` + `biz-personas` | Complete analysis |
| Launch | `growth-landing` + `growth-seo` + `growth-analytics` | Launch kit |

## How to dispatch

### Step 1: Decompose the task

```markdown
## Main task: [Description]

### Identified sub-tasks:
1. [ ] [Sub-task A] - Agent: [type] - Independent: Yes/No
2. [ ] [Sub-task B] - Agent: [type] - Independent: Yes/No
3. [ ] [Sub-task C] - Agent: [type] - Independent: Yes/No

### Dependencies:
- A → independent
- B → independent
- C → depends on A and B

### Plan:
- Phase 1 (parallel): A + B
- Phase 2 (sequential): C (after A and B)
```

### Step 2: Launch in parallel

Use the Task tool with multiple calls in a single message:

```
[Call 1] Task(subagent_type="qa-security", prompt="Audit...")
[Call 2] Task(subagent_type="qa-perf", prompt="Analyze...")
[Call 3] Task(subagent_type="wcag-audit", prompt="Verify...")
```

### Step 3: Combine results

```markdown
## Combined report

### Agent A: [Summarized results]
### Agent B: [Summarized results]
### Agent C: [Summarized results]

### Synthesis
[Overview and priorities]
```

## File conflict prevention

IMPORTANT: Parallel agents editing the same files cause race conditions and broken builds.

### Before parallelizing, establish a file map

```markdown
### Files per agent:
- Agent A: src/auth/ (exclusive)
- Agent B: src/api/ (exclusive)
- Agent C: src/utils/helpers.ts (CONFLICT with A and B!)

→ Solution: Agent C sequential after A and B
```

### File-locking rules

| Situation | Action |
|-----------|--------|
| 2 agents modify the same file | SEQUENTIAL mandatory |
| 2 agents modify the same folder | Check the specific files |
| Read-only agents (audit) | PARALLEL always OK |
| Shared config (package.json, tsconfig) | SEQUENTIAL for edits |

### Typically shared files (caution)

- `package.json` — deps added by multiple agents
- `tsconfig.json` — paths modified
- `src/index.ts` — exports added
- `.env.example` — variables added
- Routing/navigation files

## Best practices

- Verify the independence of sub-tasks BEFORE parallelizing
- Establish the map of files modified per agent BEFORE launching
- Give each agent a clear and bounded scope
- Use `run_in_background: true` for long tasks
- Combine results with a high-level synthesis
- Limit to 3-5 parallel agents for readability
- Prefer `isolation: "worktree"` for agents that edit many files

## Native Agent Teams (recommended for teams > 2 agents)

For complex orchestrations requiring inter-agent communication, prefer **native Agent Teams**:

| | Sub-Agents (Task) | Agent Teams |
|---|---|---|
| **Communication** | Return to parent only | Direct messaging between agents |
| **Coordination** | Main agent handles everything | Shared task list |
| **Token cost** | Low | High (1 context per agent) |
| **Ideal for** | Focused tasks, combined results | Complex collaboration, debate, consensus |

**Recommendation**: Use Task sub-agents (this skill) for focused and independent tasks. Use Agent Teams (`/work:work-team`) for teams of 3+ agents requiring discussion and coordination.

See the `agent-teams` skill for full documentation.

## Rules

- ALWAYS verify dependencies between sub-tasks
- NEVER parallelize modifications on the same files
- ALWAYS establish the map of modified files BEFORE launching agents
- ALWAYS provide full context to each agent
- COMBINE results into a coherent report
- PREFER `isolation: "worktree"` when agents modify many files

## Dispatched sessions (CLI 2.1.142+)

For workloads that outgrow in-process Task sub-agents, the `claude agents` CLI dispatches background sessions with their own configuration. Flags `--add-dir`, `--settings`, `--mcp-config`, `--plugin-dir`, `--permission-mode`, `--model`, `--effort` let each dispatched session run with a tailored model/effort/permission profile. Pair with the `agent-teams` skill for coordinated multi-process work, and use Agent View (research preview) to monitor running sessions.
