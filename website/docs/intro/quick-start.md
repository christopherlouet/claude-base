---
sidebar_position: 2
title: Quick Start
description: Get started with claude-socle in 5 minutes
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Quick Start

Be productive with claude-socle in less than 5 minutes.

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/overview) installed and configured
- An existing project or a new directory

## Installation

### Option 1: Automatic script (recommended)

```bash
# In your project directory
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash
```

This script:
- Clones the foundation into `.claude/`
- Configures the hooks and settings
- Verifies the installation

### Option 2: Manual installation

```bash
# Clone the repository
git clone https://github.com/christopherlouet/claude-socle.git temp-socle

# Copy the .claude folder
cp -r temp-socle/.claude .

# Clean up
rm -rf temp-socle
```

## Verification

Launch Claude Code in your project:

```bash
claude
```

At startup you should see:
```
=== Claude Code Session ===
Version socle: 1.33.0
Commandes: <!-- count:commands -->131<!-- /count -->
Agents: <!-- count:agents -->63<!-- /count -->
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
- [Explore the commands](/docs/commands) - Complete catalog of the <!-- count:commands -->131<!-- /count --> commands
