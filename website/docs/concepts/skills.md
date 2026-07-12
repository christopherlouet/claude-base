---
sidebar_position: 4
title: Skills
description: Understanding Claude Code skills
---

# Skills

> Behaviors auto-triggered by keyword detection

## What is a Skill?

A **skill** is a set of instructions that automatically activate when certain keywords are detected in the conversation.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  User: "I want to do TDD for this feature"                     │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Keyword detection                      │                    │
│  │                                        │                    │
│  │ "TDD" detected → TDD Skill active      │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ TDD instructions injected              │                    │
│  │                                        │                    │
│  │ - Write the test first (RED)           │                    │
│  │ - Implement the minimum (GREEN)        │                    │
│  │ - Refactor (REFACTOR)                  │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  Claude automatically follows the TDD cycle                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## File structure

Skills live in `.claude/skills/`, each in its own folder:

```
.claude/skills/
├── dev-tdd/
│   ├── SKILL.md              # Skill instructions
│   └── examples/             # Practical examples (optional)
│       └── example.md
├── work-commit/
│   └── SKILL.md
├── dev-debug/
│   └── SKILL.md
├── qa-security/
│   └── SKILL.md
└── ...
```

## Anatomy of a skill

### SKILL.md file

```markdown
---
name: dev-tdd
description: TDD development with Red-Green-Refactor cycle
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Test Driven Development Skill

## Triggers

This skill activates when the user mentions:
- "TDD", "test first", "test driven"
- "write tests first"
- "red green refactor"

## Instructions

### TDD cycle

1. **RED** - Write a failing test
2. **GREEN** - Implement the minimum to pass
3. **REFACTOR** - Improve without breaking the tests

### Rules

IMPORTANT: Always start with the test.

YOU MUST verify that the test fails before implementing.

NEVER write more code than necessary to pass the test.
```

## Frontmatter

### Required fields

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Skill name | `dev-tdd` |
| `description` | Short description | `TDD development...` |

### Optional fields

| Field | Description | Values |
|-------|-------------|--------|
| `allowed-tools` | Authorized tools | List of tools |
| `context` | Context type | `fork` or `shared` |

### Contexts

| Context | Description | Usage |
|---------|-------------|-------|
| `fork` | Isolated context | Autonomous tasks (recommended) |
| `shared` | Shared context | Interactive tasks |

## Trigger keywords

Skills are activated by keyword detection. Define them in the "Triggers" section:

```markdown
## Triggers

This skill activates when the user mentions:
- "TDD", "test first"
- "write tests first"
- "red green refactor"
```

## Skill categories

### Development

| Skill | Keywords | Action |
|-------|----------|--------|
| `dev-tdd` | TDD, test first | Red-Green-Refactor cycle |
| `dev-debug` | bug, error, debug | Systematic investigation |
| `dev-refactor` | refactor, clean up | Guided refactoring |
| `dev-api` | API, endpoint, REST | API creation |

### Workflow

| Skill | Keywords | Action |
|-------|----------|--------|
| `work-commit` | commit, message | Conventional Commits |
| `work-pr` | PR, pull request | Structured PR |
| `qa-review` | review, code review | Thorough review |
| `work-explore` | explore, understand | Code analysis |

### Quality

| Skill | Keywords | Action |
|-------|----------|--------|
| `qa-security` | security, OWASP | Security audit |

### Infrastructure

| Skill | Keywords | Action |
|-------|----------|--------|
| `ops-docker` | Docker, container | Containerization |
| `ops-ci` | CI/CD, pipeline | CI configuration |
| `ops-monitoring` | logs, metrics | Instrumentation |
| `ops-infra-code` | Terraform, IaC, OpenTofu, module, Proxmox | Terraform/OpenTofu modules, Proxmox infrastructure |

> These tables show a handful of the skills. The foundation ships 53 skills in total — see the [skills catalog](/docs/reference/skills-catalog) for the full list.

## Skill examples

### Simple skill

```markdown
---
name: work-commit
description: Generate Conventional Commits commit messages
context: fork
---

# Work Commit

## Triggers

- "commit", "commit message"
- "git commit"

## Instructions

Generate a commit message following Conventional Commits:

\`\`\`
type(scope): description

[body]

[footer]
\`\`\`

### Types
- feat: new feature
- fix: bug fix
- docs: documentation
- refactor: refactoring
- test: adding tests
- chore: maintenance
```

### Skill with restricted tools

```markdown
---
name: work-explore
description: Explore and understand a codebase
allowed-tools:
  - Read
  - Grep
  - Glob
context: fork
---

# Work Explore

## Triggers

- "explore", "understand the code"
- "discover the project"

## Instructions

1. Read the configuration files
2. Identify the structure
3. Spot the patterns

## Constraints

NEVER modify files.
```

## Create a new skill

### 1. Create the folder

```bash
mkdir -p .claude/skills/my-skill
```

### 2. Create SKILL.md

```markdown
---
name: my-skill
description: Description of my skill
allowed-tools:
  - Read
  - Write
  - Edit
context: fork
---

# My Skill

## Triggers

This skill activates when:
- "keyword-1", "keyword-2"
- "trigger phrase"

## Instructions

1. Step 1
2. Step 2
3. Step 3

## Rules

IMPORTANT: Important rule.

YOU MUST do this.

NEVER do that.
```

### 3. Add examples (optional)

```bash
mkdir -p .claude/skills/my-skill/examples
touch .claude/skills/my-skill/examples/example.md
```

## Difference with Commands and Agents

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Trigger | Manual (`/xxx`) | **Auto (keywords)** | Auto (delegation) |
| Context | Shared | **Fork** | Isolated |
| Control | Total | **Partial** | Delegated |
| Visibility | Explicit | **Transparent** | Transparent |

## Best practices

1. **Precise keywords**: Avoid false positives
2. **Fork context**: Recommended for isolation
3. **Minimal tools**: Restrict to what's needed
4. **Clear instructions**: The skill must be self-contained
5. **Practical examples**: Help understand usage

---

## See also

- [Commands](./commands) - Manual instructions
- [Agents](./agents) - Autonomous sub-agents
- [Skills catalog](/docs/skills) - All claude-base skills
