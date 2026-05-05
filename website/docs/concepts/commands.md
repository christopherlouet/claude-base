---
sidebar_position: 2
title: Commands
description: Understanding Claude Code commands
---

# Commands

> Manually triggered instructions with the `/` prefix

## What is a Command?

A **command** is a Markdown file that contains instructions for Claude. It is explicitly triggered by the user with the `/` prefix.

```bash
# Invocation examples
/work:work-explore "Understand the architecture"
/dev:dev-tdd "Implement the user service"
/qa:qa-security
```

## File structure

Commands are organized by domain in `.claude/commands/`:

```
.claude/commands/
├── work/                    # Main workflow
│   ├── work-explore.md
│   ├── work-plan.md
│   ├── work-commit.md
│   └── work-pr.md
├── dev/                     # Development
│   ├── dev-tdd.md
│   ├── dev-api.md
│   └── dev-component.md
├── qa/                      # Quality
│   ├── qa-security.md
│   ├── qa-perf.md
│   └── wcag-audit.md
├── ops/                     # Operations
├── doc/                     # Documentation
├── biz/                     # Business
├── growth/                  # Growth
├── data/                    # Data
└── legal/                   # Legal
```

## Anatomy of a command

### Minimal structure

```markdown
# Command title

Description of what the command does.

## Instructions

1. Step 1
2. Step 2
3. Step 3

## Expected output

Description of the expected result.
```

### Advanced structure with frontmatter

```markdown
---
description: Short description for the help
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
---

# My Command

## Context
$ARGUMENTS

## Instructions
...
```

### Special variable `$ARGUMENTS`

The `$ARGUMENTS` variable is replaced by the arguments passed to the command:

```bash
/dev:dev-tdd "Implement JWT authentication"
```

In the `dev-tdd.md` file:
```markdown
## Context
$ARGUMENTS
# Becomes: "Implement JWT authentication"
```

## Characteristics

| Property | Value |
|----------|-------|
| **Trigger** | Manual (`/name`) |
| **Context** | Shared with the conversation |
| **Tools** | All available (unless restricted) |
| **Visibility** | The user sees the invocation |

## Difference with Skills and Agents

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Trigger | Manual | Auto (keywords) | Auto (delegation) |
| Context | Shared | Fork | Isolated |
| Control | Total | Partial | Delegated |
| Use case | Explicit actions | Recurring behaviors | Autonomous tasks |

## Best practices

### 1. Consistent naming

```
domain-action
```

Examples:
- `work-explore` (workflow + explore)
- `dev-tdd` (development + TDD)
- `qa-security` (quality + security)

### 2. Clear instructions

```markdown
## Instructions

IMPORTANT: Always explore the code before modifying.

YOU MUST follow the existing pattern.

NEVER modify configuration files without validation.
```

### 3. Output structure

```markdown
## Expected output

### Format
- Section 1: Summary
- Section 2: Details
- Section 3: Recommendations

### Example
\`\`\`markdown
## Summary
...
\`\`\`
```

## Create a new command

### 1. Create the file

```bash
# In the right domain
touch .claude/commands/dev/dev-my-command.md
```

### 2. Write the content

```markdown
# My New Command

## Context
$ARGUMENTS

## Instructions

1. Analyze the request
2. Execute the action
3. Verify the result

## Output

Provide a structured report.
```

### 3. Test

```bash
/dev:dev-my-command "Command test"
```

## Command examples

### Simple command (exploration)

```markdown
# Work Explore

Explore and understand an existing codebase.

## Context
$ARGUMENTS

## Instructions

1. Identify the main files (package.json, README, etc.)
2. Analyze the folder structure
3. Spot the patterns and conventions
4. Document the key dependencies

## Output

Provide a structured overview of the project.
```

### Complex command (workflow)

```markdown
# Work Flow Feature

Complete workflow to implement a new feature.

## Context
$ARGUMENTS

## Steps

### 1. Exploration
Use /work:work-explore to understand the context.

### 2. Specification
Use /work:work-specify to define the User Stories.

### 3. Planning
Use /work:work-plan to create the implementation plan.

### 4. Development
Use /dev:dev-tdd to implement with tests.

### 5. Review
Use /qa:qa-review to check the quality.

### 6. Delivery
Use /work:work-pr to create the Pull Request.
```

## List the available commands

In Claude Code, use `/help` to see the available commands, or explore the `.claude/commands/` folder directly.

---

## See also

- [Skills](./skills) - Automatic behaviors
- [Agents](./agents) - Autonomous sub-agents
- [Commands catalog](/docs/commands) - All claude-base commands
