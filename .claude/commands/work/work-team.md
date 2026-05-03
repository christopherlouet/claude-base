# WORK-TEAM Agent

Launches a coordinated team of agents (Agent Teams) to parallelize work.

## Context
$ARGUMENTS

## Goal

Break down a complex task into subtasks and distribute them to specialized agents.
Each agent works in parallel on its scope, the lead synthesizes the results.

## Workflow

- Check that Agent Teams is enabled (`$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` = 1)
- Analyze the task and choose the appropriate pattern (see below)
- Spawn the agents with clear roles and distinct scopes
- Coordinate via task list, direct messaging, delegate mode if > 3 agents
- Synthesize the results into a consolidated report
- Cleanup: shutdown each agent + resource cleanup

## Available patterns

| Keywords | Pattern | Agents |
|----------|---------|--------|
| audit, quality, security | **Audit** | security-reviewer, perf-analyst, a11y-checker |
| feature, implement | **Feature** | backend-dev, frontend-dev, test-writer |
| bug, investigate, debug | **Debug** | 3-5 investigators with different hypotheses |
| review, code review | **Review** | security-reviewer, perf-reviewer, quality-reviewer |
| Other | **Custom** | Describe the structure |

Patterns detailed in `.claude/skills/agent-teams/patterns.md`.

## Expected output

1. **Team**: Agents created with roles and scopes
2. **Consolidated report**: Results per agent + synthesis + priorities
3. **Cleanup**: Confirmation of shutdown of all agents

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Explore BEFORE launching a team |
| `/work:work-plan` | Plan BEFORE a Feature pattern |
| `/qa:qa-audit` | Single-agent alternative to the audit |

---

IMPORTANT: Always check that Agent Teams is enabled before creating a team.

YOU MUST choose the pattern appropriate to the task.

YOU MUST clean up the team after use (shutdown + cleanup).

NEVER launch more than 5 agents without warning about the token cost.

NEVER have 2 agents work on the same file.

Think hard about the task decomposition before spawning the agents.
