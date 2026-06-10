---
sidebar_position: 2
title: Quick Start
description: Get started with claude-base in 5 minutes
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Quick Start

Be productive with claude-base in less than 5 minutes.

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/overview) installed and configured
- An existing project or a new directory

## Installation

### Option 1: One-liner install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
```

This installer :
- Clones the foundation to `~/.local/share/claude-base/`
- Symlinks the `claude-base` dispatcher to `~/.local/bin/`
- Never modifies your shell rc files, never runs as root, only requires `git`

After install, use `claude-base init` to set up a project :

```bash
claude-base init --simple /path/to/your-project
```

### Option 2: Manual installation

```bash
# Clone the repository
git clone https://github.com/christopherlouet/claude-base.git temp-base

# Copy the .claude folder
cp -r temp-base/.claude .

# Clean up
rm -rf temp-base
```

### Option 3: Stack-specific install with `--preset`

```bash
# Pick a preset that matches your stack — 11 available
claude-base init --preset nextjs        ./my-web-app
claude-base init --preset react-vite-spa ./my-spa
claude-base init --preset fastapi       ./my-api
claude-base init --preset phaser        ./my-2d-game
claude-base preset list                 # discover all available presets
```

Each preset filters the foundation to the relevant skills, ships a curated `recommendedVendorSkills` list printed at install end, and (for several) self-describes a `detect` block so running `claude-base init <existing-project>` auto-recognises the stack.

### Option 4: Interactive on an empty directory (don't know which preset?)

If you run `claude-base init ./my-project` on an empty directory without a preset flag, an **interactive category prompt** fires :

```
What are you building?
  1) Web frontend
  2) API / Backend
  3) Mobile / Desktop
  4) Game / Interactive media
  5) Data / Database
  6) Infra / DevOps
  7) CLI / Automation
  8) Other / Generic     ← default
```

The chosen category filters the subsequent menu to relevant presets + types. Default "Other / Generic" → full unfiltered menu (regression-safe). Skipped on non-TTY, `--skip-prompts`, `--yes`, `--preset`, `--type`, or when auto-detection produced a match. See [`specs/preset-category-prompt/spec.md`](https://github.com/christopherlouet/claude-base/blob/main/specs/preset-category-prompt/spec.md) for the full design.

## Verification

Launch Claude Code in your project:

```bash
claude
```

At startup you should see:
```
=== Claude Code Session ===
Version: <!-- version -->4.0.0<!-- /version -->
Commandes: 128
Agents: 61
===========================
```

## First workflow

<WorkflowDiagram steps={MAIN_WORKFLOW} title="Main workflow: Explore → Specify → Plan → TDD → Audit → Commit" />

### Step 1: Explore

Before any modification, understand the existing code:

```bash
/work:work-explore
```

Claude will analyze:
- The project structure
- The patterns and conventions
- The dependencies
- The points of attention

### Step 2: Specify

Define the user stories and acceptance criteria before designing:

```bash
/work:work-specify "Add an authentication feature"
```

Claude will produce:
- Prioritized user stories (P1 = MVP, P2, P3)
- Acceptance criteria (Given/When/Then)
- Functional requirements and edge cases
- Out-of-scope explicitly listed

### Step 3: Plan

Once the spec is validated, plan the implementation:

```bash
/work:work-plan
```

Claude will propose:
- The recommended architecture
- The files to create/modify
- The identified risks
- The tests to write

### Step 4: TDD

Implement following the plan, tests first:

```bash
/dev:dev-tdd "Implement the authentication service"
```

Red → Green → Refactor cycle, 80%+ coverage on new code.

### Step 5: Audit

Run the adaptive audit + fix loop until target score:

```bash
/qa:qa-loop "score 90"
```

Covers security, performance, accessibility — fixes are applied automatically until the target score is reached.

### Step 6: Commit

Create a clean commit:

```bash
/work:work-commit
```

Or a complete Pull Request:

```bash
/work:work-pr
```

## Essential commands

| Command | Usage |
|----------|-------|
| `/assistant` | Entry point - guides you to the right commands (guide mode) |
| `/assistant-auto` | Automatic execution of the suitable workflow (auto mode) |
| `/work:work-explore` | Explore and understand the code |
| `/work:work-specify` | Specify user stories and acceptance criteria |
| `/work:work-plan` | Plan a modification |
| `/dev:dev-tdd` | Develop in TDD |
| `/qa:qa-loop` | Adaptive audit + fix loop until target score |
| `/work:work-commit` | Create a clean commit |
| `/work:work-pr` | Create a Pull Request |

## Predefined workflows

For common tasks, use the complete workflows:

```bash
# New feature
/work:work-flow-feature "Feature description"

# Bug fix
/work:work-flow-bugfix "Bug description"

# New release
/work:work-flow-release "v2.0.0"

# Product launch
/work:work-flow-launch "My new SaaS"
```

## Getting help

```bash
# Complete commands guide (guide mode with confirmation)
/assistant

# Help on a specific command
/assistant "How to use /dev:dev-tdd?"

# Automatic execution without confirmation (advanced users)
/assistant-auto "Add an authentication feature"
```

## Next steps

- [Understand the architecture](/docs/intro/architecture) - Difference between Commands, Agents and Skills
- [See the workflows](/docs/workflow) - Detailed workflows by task type
- [Explore the commands](/docs/commands) - Complete catalog of the <!-- count:commands -->128<!-- /count --> commands
