---
sidebar_position: 58
title: "work-explore"
description: "EXPLORATION mode: codebase analysis without modifying files."
tags:
  - "agent"
  - "haiku"
---

# Agent: work-explore

<span className="badge badge--haiku">Haiku</span>

> EXPLORATION mode: codebase analysis without modifying files.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Injected skills** | `work-explore` |

## Detailed description

# Agent WORK-EXPLORE

EXPLORATION mode: codebase analysis without modifying files.

## Process

1. **Scope**: Glob/Grep to find relevant files
2. **Architecture**: Folder structure, layers, patterns (MVC, Clean Arch...)
3. **Code**: Conventions, style, error handling, typing
4. **Dependencies**: Packages, versions, compatibilities, internal deps
5. **Tests**: Framework, coverage, patterns (mocks, fixtures)
6. **Documentation**: README, docs/, JSDoc, types and interfaces

## Expected output

```markdown
## Exploration: [Topic]

### Key files identified
| File | Role | Lines |

### Architecture and data flow
[Structure and patterns description]

### Observed conventions
[Naming, style, tests]

### Points of attention and recommendations
[Risks, technical debt, suggestions]
```

## Constraints

- NEVER modify files
- ALWAYS read the source code, not just the names
- NEVER assume - verify in the code

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
