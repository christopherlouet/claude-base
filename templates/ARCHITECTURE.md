# claude-base Architecture

This document describes the architecture and organization of claude-base agents.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CLAUDE-BASE                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    CLAUDE CODE                       │   │
│  │              (Official Anthropic CLI)                │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   CLAUDE.md                          │   │
│  │             (Project configuration)                  │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              .claude/commands/                       │   │
│  │                   (Agents)                           │   │
│  │  ┌─────────┬─────────┬─────────┬─────────┐         │   │
│  │  │  work-  │  dev-   │   qa-   │  ops-   │  ...    │   │
│  │  └─────────┴─────────┴─────────┴─────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
claude-base/
├── .claude/
│   └── commands/              # Agents (slash commands)
│       ├── work-*.md          # General workflow
│       ├── dev-*.md           # Development
│       ├── qa-*.md            # Quality
│       ├── ops-*.md           # Operations
│       ├── doc-*.md           # Documentation
│       ├── biz-*.md           # Business
│       ├── growth-*.md        # Growth
│       └── legal-*.md         # Legal
│
├── templates/                 # Reusable templates
│   ├── CLAUDE.md              # Configuration template
│   ├── CONTRIBUTING.md        # Contribution guide
│   ├── ARCHITECTURE.md        # This file
│   ├── TROUBLESHOOTING.md     # Troubleshooting
│   ├── FAQ.md                 # Frequently asked questions
│   └── PERFORMANCE-GUIDE.md   # Performance guide
│
├── CLAUDE.md                  # Root project configuration
└── README.md                  # Main documentation
```

## Agent Categories

### Taxonomy

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENT CATEGORIES                          │
├──────────────┬──────────────────────────────────────────────┤
│ WORK-*       │ Daily workflow                               │
│              │ explore, plan, commit, pr                    │
├──────────────┼──────────────────────────────────────────────┤
│ DEV-*        │ Development                                  │
│              │ tdd, debug, refactor, api, testing-setup     │
├──────────────┼──────────────────────────────────────────────┤
│ QA-*         │ Quality                                      │
│              │ review, automation                           │
├──────────────┼──────────────────────────────────────────────┤
│ OPS-*        │ Operations                                   │
│              │ ci, monitoring, load-testing, backup           │
├──────────────┼──────────────────────────────────────────────┤
│ DOC-*        │ Documentation                                │
│              │ api, changelog, fix-issue                    │
├──────────────┼──────────────────────────────────────────────┤
│ BIZ-*        │ Business                                     │
│              │ launch, market, mvp, pricing                 │
├──────────────┼──────────────────────────────────────────────┤
│ GROWTH-*     │ Growth                                       │
│              │ seo, analytics, landing                      │
├──────────────┼──────────────────────────────────────────────┤
│ LEGAL-*      │ Legal                                        │
│              │ gdpr, tos, notices                           │
└──────────────┴──────────────────────────────────────────────┘
```

### Relations between agents

```
                    ┌─────────────┐
                    │  ONBOARD    │
                    │ (Discovery) │
                    └──────┬──────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│                     MAIN WORKFLOW                         │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │ EXPLORE  │───►│   PLAN   │───►│   TDD    │           │
│  └──────────┘    └──────────┘    └────┬─────┘           │
│                                       │                  │
│                                       ▼                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │    PR    │◄───│  COMMIT  │◄───│  REVIEW  │           │
│  └──────────┘    └──────────┘    └──────────┘           │
│                                                          │
└──────────────────────────────────────────────────────────┘
         │                                    │
         ▼                                    ▼
┌─────────────────┐                ┌─────────────────┐
│  SUPPORT AGENTS │                │  QUALITY AGENTS │
│                 │                │                 │
│  - debug        │                │  - security     │
│  - refactor     │                │  - perf         │
│  - api          │                │  - a11y         │
│  - test         │                │  - automation   │
└─────────────────┘                └─────────────────┘
```

## Agent Structure

### Standard format

```markdown
# Agent AGENT-NAME

Short, clear description of the agent.

## Context
$ARGUMENTS                    ← MANDATORY placeholder

## Objective
[Main objective of the agent]

## [Specific sections]
[Content adapted to the agent]

## Checklist
- [ ] Step 1
- [ ] Step 2

## Related agents
| Agent | Usage |
|-------|-------|
| /xxx | Description |

---

IMPORTANT: [Critical instruction]
YOU MUST [Obligation]
NEVER [Prohibition]
Think hard about [Aspect to consider]
```

### Required elements

| Element | Mandatory | Description |
|---------|-----------|-------------|
| `# Agent NAME` | Yes | Agent title |
| `$ARGUMENTS` | Yes | Placeholder for arguments |
| `## Objective` | Recommended | Agent purpose |
| `## Checklist` | Recommended | Steps to follow |
| `## Related agents` | Recommended | Cross-references |
| Final instructions | Recommended | IMPORTANT, YOU MUST, NEVER |

### Naming conventions

```
File: .claude/commands/[category]-[name].md

Examples:
  dev-tdd.md         → /dev-tdd
  ops-ci.md          → /ops-ci
  work-explore.md    → /work-explore
```

## Data Flow

### Agent invocation

```
┌─────────────────────────────────────────────────────────────┐
│                     INVOCATION FLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User                                                       │
│      │                                                      │
│      │  /explore src/auth                           │
│      ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Claude Code                        │   │
│  │  1. Parses the command                               │   │
│  │  2. Reads .claude/commands/work-explore.md           │   │
│  │  3. Replaces $ARGUMENTS with "src/auth"              │   │
│  │  4. Sends the prompt to the Claude API               │   │
│  └─────────────────────────────────────────────────────┘   │
│      │                                                      │
│      ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Claude API                         │   │
│  │  - Interprets the instructions                       │   │
│  │  - Executes actions (file reading, etc.)             │   │
│  │  - Generates the response                            │   │
│  └─────────────────────────────────────────────────────┘   │
│      │                                                      │
│      ▼                                                      │
│  User (response displayed)                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Context and inheritance

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT HIERARCHY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CLAUDE.md (project root)                                │
│     └── Conventions, global rules                           │
│         │                                                   │
│         ▼                                                   │
│  2. Agent (.claude/commands/*.md)                           │
│     └── Task-specific instructions                          │
│         │                                                   │
│         ▼                                                   │
│  3. Arguments ($ARGUMENTS)                                  │
│     └── Invocation-specific context                         │
│         │                                                   │
│         ▼                                                   │
│  4. Conversation history                                    │
│     └── Context of previous exchanges                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Best Practices

### Agent design

| Principle | Description |
|-----------|-------------|
| **Single Responsibility** | One agent = one task |
| **Composable** | Agents can reference each other |
| **Progressive** | From simple to complex |
| **Self-documenting** | Clear instructions |

### Anti-patterns

| Anti-pattern | Problem | Solution |
|--------------|---------|----------|
| Catch-all agent | Too many responsibilities | Split into specialized agents |
| Vague instructions | Inconsistent results | Be precise and give examples |
| No checklist | Frequent omissions | Always include a checklist |
| Isolation | No references | Add "Related agents" |

## System Extension

### Adding a new agent

1. **Identify the need**
   - What problem does it solve?
   - Does a similar agent already exist?

2. **Choose the category**
   - work, dev, qa, ops, doc, biz, growth, legal

3. **Create the file**
   ```bash
   touch .claude/commands/[category]-[name].md
   ```

4. **Follow the template**
   - Title, Context, Objective, Instructions, Checklist

5. **Test**
   - Invoke with different arguments
   - Verify the consistency of results

6. **Document**
   - Add to cross-references of related agents

### Create a new category

1. Define the prefix (e.g., `perf-`)
2. Document the category's objective
3. Create at least 2-3 agents in the category
4. Update CLAUDE.md
5. Add to this documentation

---

## Versions and Evolution

### Semantic versioning

```
MAJOR.MINOR.PATCH

MAJOR: Incompatible changes (structure, conventions)
MINOR: New agents, new categories
PATCH: Fixes, minor improvements
```

### Changelog

See `doc-changelog.md` for the format and best practices for changelogs.
