---
sidebar_position: 3
title: Agents
description: Understanding Claude Code sub-agents
---

# Agents (Sub-agents)

> Autonomous sub-processes with isolated context for specialized tasks

## What is an Agent?

An **agent** is a sub-process launched by Claude via the **Task tool** to execute a task autonomously. The agent has its own isolated context and restricted tools.

```
┌────────────────────────────────────────────────────────────────┐
│ Main conversation                                              │
│                                                                │
│  User: "Run a security audit"                                  │
│                                                                │
│  Claude: I'm delegating to the qa-security agent...            │
│          ┌──────────────────────────────────┐                  │
│          │ Agent qa-security                │                  │
│          │ ┌──────────────────────────────┐ │                  │
│          │ │ ISOLATED context             │ │                  │
│          │ │ Tools: Read, Grep, Glob      │ │                  │
│          │ │ Model: sonnet                │ │                  │
│          │ └──────────────────────────────┘ │                  │
│          │                                  │                  │
│          │ [Running the audit...]           │                  │
│          │                                  │                  │
│          │ Result: 3 vulnerabilities        │                  │
│          └──────────────────────────────────┘                  │
│                                                                │
│  Claude: The audit found 3 vulnerabilities...                  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Benefits of agents

| Benefit | Description |
|---------|-------------|
| **Isolated context** | Does not pollute the main conversation |
| **Restricted tools** | Limited access (read-only for audits) |
| **Optimized model** | Haiku for simple tasks, Sonnet for complex ones |
| **Parallelization** | Multiple agents can run simultaneously |
| **Specialization** | Domain-specific instructions |

## File structure

Agents are defined in `.claude/agents/`:

```
.claude/agents/
├── work-explore.md       # Code exploration
├── qa-security.md        # Security audit
├── qa-perf.md            # Performance audit
├── ops-deps.md           # Dependency audit
├── dev-debug.md          # Bug investigation
├── biz-competitor.md     # Competitive analysis
└── ...
```

## Anatomy of an agent

### Mandatory frontmatter

```yaml
---
model: haiku              # or "sonnet" for complex tasks
---
```

### Full frontmatter

```yaml
---
model: sonnet
permissionMode: plan      # "plan" = read-only
disallowedTools:
  - Edit
  - Write
  - NotebookEdit
hooks:
  PreToolUse:
    - matcher: ".*"
      command: "echo 'Tool used'"
skills:
  - security-audit        # Skills injected into the agent
---
```

### Agent content

```markdown
---
model: haiku
---

# Work-Explore Agent

Agent specialized in codebase exploration.

## Mission

Explore and understand an existing codebase without modifying it.

## Instructions

1. Identify configuration files (package.json, etc.)
2. Analyze the folder structure
3. Spot patterns and conventions
4. Document key dependencies

## Constraints

- NEVER modify files
- Focus on understanding
- Provide a structured summary

## Output

Exploration report with:
- Overview
- Technologies used
- Points of attention
```

## Agent configuration

### Available models

| Model | Usage | Cost | Speed |
|-------|-------|------|-------|
| `haiku` | Simple, fast tasks | Low | Fast |
| `sonnet` | Complex tasks, analyses | Medium | Medium |

### Permission modes

| Mode | Description | Tools |
|------|-------------|-------|
| `default` | Full access | All |
| `plan` | Read-only | Read, Grep, Glob only |

### Restricted tools

```yaml
disallowedTools:
  - Edit           # No modification
  - Write          # No creation
  - NotebookEdit   # No notebook editing
  - Bash           # No shell commands
```

## Automatic triggering

Claude automatically delegates to agents based on context:

| User request | Delegated agent | Reason |
|--------------|-----------------|--------|
| "Explore the code" | `work-explore` | Exploration keywords |
| "Security audit" | `qa-security` | Security keywords |
| "Check dependencies" | `ops-deps` | Dependency keywords |
| "Analyze competitors" | `biz-competitor` | Business keywords |

## Agent categories

### Exploration & Documentation

| Agent | Model | Description |
|-------|-------|-------------|
| `work-explore` | haiku | Explore a codebase |
| `doc-onboard` | haiku | Developer onboarding |
| `doc-explain` | haiku | Explain code |

### Quality & Audits

| Agent | Model | Description |
|-------|-------|-------------|
| `qa-security` | sonnet | OWASP Top 10 audit |
| `qa-perf` | sonnet | Performance audit |
| `wcag-audit` | haiku | Accessibility audit |
| `qa-audit` | sonnet | Full audit |

### Operations

| Agent | Model | Description |
|-------|-------|-------------|
| `ops-deps` | haiku | Dependency audit |
| `ops-health` | haiku | Health check |
| `ops-docker` | haiku | Containerization |

### Development

| Agent | Model | Description |
|-------|-------|-------------|
| `dev-debug` | sonnet | Bug investigation |
| `dev-test` | haiku | Test generation |

### Business & Growth

| Agent | Model | Description |
|-------|-------|-------------|
| `biz-model` | haiku | Business model |
| `biz-competitor` | haiku | Competitor analysis |
| `growth-seo` | haiku | SEO audit |

## Create a new agent

### 1. Create the file

```bash
touch .claude/agents/my-agent.md
```

### 2. Define the frontmatter

```yaml
---
model: haiku
permissionMode: plan
disallowedTools:
  - Edit
  - Write
---
```

### 3. Write the instructions

```markdown
# My-Agent

## Mission
Description of the mission.

## Instructions
1. Step 1
2. Step 2

## Output
Expected format.
```

## Difference with Commands and Skills

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Triggering | Manual | Auto (keywords) | Auto (delegation) |
| Context | Shared | Fork | **Isolated** |
| Tools | All | Restricted | **Highly restricted** |
| Model | Main | Main | **Configurable** |
| Parallelization | No | No | **Yes** |

## Best practices

1. **Choose the right model**: Haiku for simple tasks, Sonnet for complex analyses
2. **Restrict tools**: Minimum necessary for the task
3. **Plan mode for audits**: Prevents accidental modifications
4. **Clear instructions**: The agent must be autonomous
5. **Structured output**: Facilitates result integration

---

## See also

- [Commands](./commands) - Manual instructions
- [Skills](./skills) - Automatic behaviors
- [Agents catalog](/docs/agents) - All claude-socle agents
