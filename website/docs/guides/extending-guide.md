---
sidebar_position: 10
title: "Foundation Extension Guide"
description: " How to customize and extend the claude-socle foundation for your own projects."
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Foundation Extension Guide

&gt; How to customize and extend the claude-socle foundation for your own projects.

&gt; **Dual audience**: this guide covers two distinct cases.
&gt;
&gt; - **You are extending your user project** (adding custom commands/rules/skills): your `@imports` in `CLAUDE.md` should point to `@.claude/docs/...` (since the foundation's docs are installed under `.claude/docs/` on your side).
&gt; - **You are contributing to the claude-socle repo**: the foundation's `@imports` point to `@docs/...` (the foundation keeps its docs in `docs/` directly). See also [CONTRIBUTING.md](https://github.com/christopherlouet/claude-socle/blob/main/CONTRIBUTING.md).

## Overview

The foundation is designed to be extended. Four main extension points exist:

| Element | Location | Purpose |
|---------|-------------|---------|
| Rules | `.claude/rules/` | Apply conventions based on file type |
| Skills | `.claude/skills/` | Encapsulate a reusable workflow |
| Agents | `.claude/agents/` | Orchestrate a workflow with a dedicated LLM |
| Hooks | `.claude/settings.json` | Automate pre/post tool actions |

---

## 1. Create a custom Rule

Rules are Markdown files with a YAML frontmatter that define constraints and conventions. They activate automatically when Claude modifies a file matching the declared paths.

### Frontmatter format

```yaml
---
paths:
  - "**/*.vue"
  - "**/components/**"
---

# Vue Rules

## Conventions
- IMPORTANT: Use the Composition API (not Options API)
- YOU MUST declare props with defineProps<T>()
```

The frontmatter is optional. Without `paths`, the rule applies globally to all interactions.

### Location

Create the file in `.claude/rules/`:

```
.claude/rules/vue.md
.claude/rules/my-framework.md
```

### Full example: rule for Svelte

```markdown
---
paths:
  - "**/*.svelte"
  - "**/src/lib/**"
  - "**/src/routes/**"
---

# Svelte Rules

## Component structure

| Element | Convention | Example |
|---------|-----------|---------|
| Script | `<script lang="ts">` | Always TypeScript |
| Stores | Native Svelte stores | `writable<User \| null>(null)` |
| Props | `export let prop: Type` | Explicit typing required |

## Conventions

- IMPORTANT: Prefer Svelte stores over an external state manager
- YOU MUST type all exported props
- NEVER use `any` in Svelte components
- File naming: PascalCase for components, kebab-case for routes

## Lifecycle

- Prefer `onMount` over `beforeUpdate` for side effects
- Mandatory cleanup in `onDestroy` for subscriptions
```

### Test the trigger

Modify a `.svelte` file and verify in the Claude Code session that the rule appears loaded. Rules are displayed in the session info at startup (`InstructionsLoaded` hook).

To force a reload: restart a session or use `/clear`.

---

## 2. Create a Skill

A skill is a `SKILL.md` file in a subfolder of `.claude/skills/`. It encapsulates a complete workflow with its instructions, examples, and constraints.

&gt; Since CLI 2.1.x, **slash commands and skills are unified**: each skill automatically gets a `/slash-command` interface. Files in `.claude/commands/` continue to work for compatibility, but the recommended approach for any new workflow is `.claude/skills/`. The foundation keeps `.claude/commands/` only for namespaced shortcuts (e.g., `/work:work-pr`).

### Folder structure

```
.claude/skills/my-skill/
├── SKILL.md          # Mandatory definition
├── examples/         # Concrete examples (optional)
└── references/       # Reference files (optional)
```

### SKILL.md format

```yaml
---
name: my-skill
description: What the skill does. Trigger when the user [context].
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[project-name] [options]"
---

# Skill Title

## Goal
Description in 1-2 sentences.

## Instructions

1. Step 1
2. Step 2
3. Step 3

## Expected output
Output format.

## Rules
- IMPORTANT: Critical rule
- NEVER: What must never be done
```

### Available frontmatter fields

| Field | Required | Values | Description |
|-------|--------|---------|-------------|
| `name` | No | kebab-case | Skill name (default: folder name) |
| `description` | Recommended | text | Trigger context |
| `allowed-tools` | No | list | Tools allowed without confirmation |
| `context` | No | `fork` | Execution in an isolated sub-agent |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` | Model to use |
| `argument-hint` | No | text | Autocompletion in the `/` menu |
| `disable-model-invocation` | No | `true`/`false` | Manual invocation only |
| `user-invocable` | No | `true`/`false` | Visible in the `/` menu |

### Best practices

- Limit SKILL.md to 500 lines maximum. Move details to `examples/` or `references/`
- Declare only the necessary tools (least privilege principle)
- Always use `context: fork` for isolation
- Write the `description` with the trigger context: Claude uses this field to automatically decide when to load the skill
- Prefer tables over prose for quick references

### Tools by skill type

| Skill type | Recommended tools |
|---------------|-------------------|
| Read-only (audit, review) | `Read`, `Glob`, `Grep` |
| Development | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| Documentation | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Analysis | `Read`, `Glob`, `Grep` |
| Infrastructure | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |

### Full example: changelog generation skill

```yaml
---
name: changelog-entry
description: Generate a CHANGELOG.md entry from recent commits. Trigger when the user wants to document a release or update the changelog.
allowed-tools:
  - Read
  - Edit
  - Bash
  - Glob
context: fork
model: sonnet
argument-hint: "[version] [since-tag]"
---

# Generate a Changelog Entry

## Goal

Analyze Git commits since the last tag and generate a CHANGELOG.md entry
formatted according to Keep a Changelog.

## Instructions

1. Read the existing CHANGELOG.md to understand the format used
2. Retrieve the commits: `git log <since-tag>..HEAD --oneline`
3. Group commits by type (feat, fix, refactor, docs, etc.)
4. Generate the entry in Keep a Changelog format
5. Insert at the beginning of CHANGELOG.md, after the title

## Output format

\`\`\`markdown
## [1.2.0] - 2026-04-03

### New features
- Clear description of the feature (ref: commit abc123)

### Fixes
- Description of the fixed bug (ref: commit def456)
\`\`\`

## Rules

- NEVER modify existing changelog entries
- IMPORTANT: Use the ISO date format (YYYY-MM-DD)
- Exclude style and chore commits unless significant
```

---

## 3. Create an Agent

An agent is a `.md` file in `.claude/agents/`. It combines a YAML frontmatter (sub-agent configuration) with Markdown instructions (behavior).

### Agent format

```yaml
---
name: my-agent
description: Short description. Trigger when [usage context].
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
permissionMode: default
skills:
  - my-skill
---

# Agent MY-AGENT

Body of the agent's instructions.
```

### Agent frontmatter fields

| Field | Description |
|-------|-------------|
| `name` | Agent identifier (kebab-case) |
| `description` | Automatic activation context |
| `tools` | Allowed tools (comma-separated) |
| `model` | `sonnet`, `opus`, `haiku` |
| `permissionMode` | `default`, `acceptEdits`, `bypassPermissions` |
| `skills` | List of skills to load |
| `hooks` | Hooks scoped to the agent's lifecycle |

### When to use agent vs skill vs command

| Need | Solution | Reason |
|--------|----------|--------|
| Reusable workflow with instructions | Skill | Invocable via `/name`, shared between agents |
| Isolated execution with dedicated LLM | Agent | Sub-agent with its own context |
| Sequence of bash commands | Command `.md` | Prompt without additional LLM |
| Automation without interaction | Hook | Runs a script at the right moment |

### Full example: dependency audit agent

```yaml
---
name: deps-audit
description: Audit of obsolete or vulnerable dependencies. Trigger when the user wants to check or update the project's dependencies.
tools: Read, Bash, Glob, Edit
model: sonnet
permissionMode: default
---

# Agent DEPS-AUDIT

Analyzes the project's dependencies and produces a report ranked by criticality.

## Workflow

1. Detect the package manager (npm, pnpm, yarn, pip, go mod)
2. Run the vulnerability audit (`npm audit`, `pip-audit`, etc.)
3. Identify outdated dependencies
4. Rank by criticality: CRITICAL > HIGH > MEDIUM > LOW
5. Propose an update plan

## Output

Structured report with:
- Table of vulnerabilities by level
- Update commands to run
- Dependencies to watch (potential breaking changes)

## Rules

- NEVER automatically update major dependencies without confirmation
- IMPORTANT: Check breaking changes before proposing a major update
```

### Agent naming

Follow the existing `domain-action` convention:

| Domain | Prefix | Examples |
|---------|---------|----------|
| Development | `dev-` | `dev-api`, `dev-tdd`, `dev-debug` |
| Quality | `qa-` | `qa-review`, `qa-security` |
| Operations | `ops-` | `ops-deploy`, `ops-docker` |
| Documentation | `doc-` | `doc-generate`, `doc-changelog` |
| Business | `biz-` | `biz-model`, `biz-mvp` |
| Workflow | `work-` | `work-explore`, `work-plan` |

---

## 4. Create a Hook

Hooks let you automate actions at specific moments in the lifecycle of a Claude Code session. They are configured in `.claude/settings.json` (global hooks) or in the frontmatter of an agent/skill (scoped hooks).

### Hook types

| Type | Description | Use case |
|------|-------------|-------------|
| `command` | Runs a bash script | Validation, formatting, logging |
| `prompt` | Evaluated via a Haiku LLM | Smart contextual verification |
| `http` | POST JSON to a URL | External webhook, CI/CD |

### Available events

| Event | Trigger | Typical usage |
|-----------|--------------|---------------|
| `SessionStart` | Session start | Display project info, check prereqs |
| `PreToolUse` | Before tool execution | Validate, block, transform |
| `PostToolUse` | After successful execution | Format, lint, notify |
| `Stop` | End of Claude response | Final validation, logging |
| `PreCompact` | Before context compaction | Save state |
| `SessionEnd` | End of session | Cleanup, report |

### Hook properties

| Property | Description |
|-----------|-------------|
| `type` | `command`, `prompt`, or `http` |
| `command` | Bash script to execute (type `command`) |
| `matcher` | Filter on the tool name (regex) |
| `timeout` | Timeout in milliseconds |
| `onFailure` | `"block"` or `"ignore"` |
| `async` | `true` for background execution |

### When to use async

| Situation | async | Reason |
|-----------|-------|--------|
| Logging, monitoring | `true` | Does not block the workflow |
| Blocking validation | `false` | Must run before continuing |
| Auto formatting | `false` | Must finish before the next tool |
| External webhook | `true` | Non-blocking network latency |

### Example: PostToolUse hook to format SQL

In `.claude/settings.json`, `hooks` section:

```json
{
  "PostToolUse": [
    {
      "description": "Format SQL files with sqlfluff",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'if command -v sqlfluff >/dev/null 2>&1; then FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *.sql ]]; then sqlfluff fix --dialect ansi \"$FILE\" 2>/dev/null && echo \"[SQL] Formatted: $FILE\"; fi; fi'",
          "timeout": 10000,
          "onFailure": "ignore"
        }
      ]
    }
  ]
}
```

### Example: PreToolUse hook for business validation

```json
{
  "PreToolUse": [
    {
      "description": "Prevent modification of production configuration files",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *prod* ]] || [[ \"$FILE\" == *production* ]]; then echo \"BLOCKED: Modification of a production file detected. Use ALLOW_PROD_EDIT=1 to force.\"; if [ \"$ALLOW_PROD_EDIT\" != \"1\" ]; then exit 1; fi; fi'",
          "timeout": 5000,
          "onFailure": "block"
        }
      ]
    }
  ]
}
```

### Hooks in settings.local.json

For hooks specific to your machine (uncommitted):

```json
// .claude/settings.local.json
{
  "hooks": {
    "PostToolUse": [
      {
        "description": "Desktop notification after each modification",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'notify-send \"Claude Code\" \"File modified\" 2>/dev/null || true'",
            "timeout": 3000,
            "async": true,
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

---

## 5. Customize CLAUDE.md

`CLAUDE.md` is the project's main configuration file. It is loaded at every session.

### @import pattern

```markdown
@path/to/file.md
```

Imported files are injected directly into the context. Use for large references that aren't needed every session.

Always-loaded files (imports in this project):
- `@docs/reference/best-practices.md`
- `@docs/reference/project-structures.md`

### What goes where

| Element | Location | Reason |
|---------|-------------|--------|
| Mandatory workflow | `CLAUDE.md` | Applies to the whole team |
| Code conventions | `CLAUDE.md` or rules | Depending on whether contextual or global |
| Personal preferences | `~/.claude/memory/` | Not committed, personal |
| Per-language conventions | `.claude/rules/&lt;lang&gt;.md` | Active only on the right files |
| Architecture decisions | `~/.claude/memory/` | Memorized per session |
| Long references | Separate file with `@import` | Avoids overloading the context |

### Recommended content for CLAUDE.md

```markdown
# My Project

> Short project description

## Workflow

[Adapt the mandatory workflow to the project context]

## Conventions

[Project-specific conventions, not covered by rules]

## References

| Topic | File |
|-------|---------|
| Architecture | `docs/ARCHITECTURE.md` |
| API | `docs/api/README.md` |
```

### What not to put in CLAUDE.md

- Secrets, credentials, tokens (use `.env`)
- Information that changes often (dependency versions, etc.)
- Content duplicated from rules (useless, increases the context)
- History of decisions (use CHANGELOG.md or git log)

---

## 6. Contribute to the foundation

### Fork and PR workflow

```bash
# 1. Fork the repo on GitHub
# 2. Clone your fork
git clone https://github.com/<you>/claude-socle.git
cd claude-socle

# 3. Create a feature branch
git checkout -b feature/my-python-typing-skill

# 4. Create or modify the files
# 5. Test manually in a Claude Code session
# 6. Check counter consistency
./scripts/validate-counts.sh

# 7. Commit using Conventional Commits
git commit -m "feat(skills): add python-typing skill for strict type annotations"

# 8. Push and create the PR
git push origin feature/my-python-typing-skill
gh pr create --title "feat(skills): add python-typing skill" --body "..."
```

### Naming conventions

| Type | Convention | Example |
|------|-----------|---------|
| Skills | `domain-action` | `dev-typing`, `qa-mutation` |
| Agents | `domain-action` | `dev-typing`, `qa-mutation` |
| Rules | language/framework name | `svelte.md`, `fastapi.md` |
| Commands | `domain/action.md` | `dev/dev-typing.md` |
| Branches | `feature/xxx`, `fix/xxx` | `feature/svelte-rule` |
| Commits | Conventional Commits | `feat(rules): add svelte rule` |

### Pre-PR checklist

```
[ ] The skill/agent has a kebab-case name following the domain-action convention
[ ] The YAML frontmatter is valid (name, description, allowed-tools)
[ ] The description contains the trigger context
[ ] The declared tools are the minimum necessary
[ ] context: fork is present for skills
[ ] The file is less than 500 lines
[ ] Code examples are relevant and functional
[ ] validate-counts.sh passes without error
[ ] The reference documentation is updated if necessary
```

### validate-counts.sh compliance

When you add a skill, an agent, a rule, or a command, several documentation files must be updated to reflect the new counters:

| File | Counter to update |
|---------|--------------------------|
| `README.md` | Number of commands |
| `CLAUDE.md` | Number of commands, agents, skills |
| `docs/reference/agents-catalog.md` | File header |
| `website/src/pages/index.tsx` | Homepage statistics |
| `website/docs/intro/architecture.md` | Architecture counters |

Run `./scripts/validate-counts.sh --fix` to identify inconsistencies. Manually correct numeric values in the flagged files.

### Structure of a quality PR

```markdown
## Description
Add a `svelte` skill for Svelte 5 development conventions.

## Motivation
The foundation did not cover Svelte. This skill activates Composition API conventions,
props typing, and store handling automatically on `.svelte` files.

## Changes
- `.claude/skills/dev-svelte/SKILL.md`: new skill
- `.claude/rules/svelte.md`: associated rule
- `docs/reference/skills-catalog.md`: entry added
- Counters updated in README.md, CLAUDE.md, website

## Tests
- Tested manually by modifying a .svelte file in a Claude Code session
- validate-counts.sh passes

## Checklist
- [x] Naming conventions followed
- [x] validate-counts.sh OK
- [x] Documentation updated
```

---

## Recap of locations

```
.claude/
├── rules/              # Rules per language/framework
│   ├── python.md       # Active on **/*.py
│   └── my-framework.md
├── skills/             # Reusable skills
│   └── my-skill/
│       ├── SKILL.md    # Mandatory definition
│       └── examples/
├── agents/             # Sub-agents with dedicated LLM
│   └── my-agent.md
├── commands/           # Commands invokable via /domain:name
│   └── domain/
│       └── my-command.md
└── settings.json       # Global project hooks
    settings.local.json # Local uncommitted hooks
```
