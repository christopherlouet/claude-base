---
sidebar_position: 1
title: Workflows
description: Recommended workflows for claude-base
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflows

> Step-by-step guides for common development scenarios

## Main workflow

<WorkflowDiagram steps={MAIN_WORKFLOW} title="Explore → Specify → Plan → TDD → Audit → Commit" />

The main claude-base workflow follows 6 mandatory steps (+ 1 optional):

1. **Explore** - Understand the existing code before modifying
1b. **Brainstorm** _(optional)_ - Structured ideation before specification (alternatives, fuzzy ideas)
2. **Specify** - Create a functional specification (User Stories, criteria)
3. **Plan** - Plan changes before implementing
4. **TDD** - Develop by writing tests BEFORE the code (mandatory)
5. **Audit** - Adaptive `/qa:qa-loop "score 90"` until reaching the target score
6. **Commit** - Create clean, descriptive commits (Conventional Commits)

## Available workflows

| Workflow | Description | Commands |
|----------|-------------|-----------|
| [Explore → Specify → Plan → TDD → Audit → Commit](/docs/workflow/explore-plan-code-commit) | Main workflow (TDD mandatory) | `/work:work-explore`, `/work:work-specify`, `/work:work-plan`, `/dev:dev-tdd`, `/work:work-commit` |
| [New Feature](/docs/workflow/feature) | Add a feature | `/work:work-flow-feature` |
| [Bug Fix](/docs/workflow/bugfix) | Fix an issue | `/work:work-flow-bugfix` |
| [Release](/docs/workflow/release) | Prepare a version | `/work:work-flow-release` |
| [Product Launch](/docs/workflow/launch) | Launch a product | `/work:work-flow-launch` |
| [TDD](/docs/workflow/tdd) | Test-driven development | `/dev:dev-tdd` |

## Choosing the right workflow

```mermaid
graph TD
    A[New task] --> B{Type ?}
    B -->|Feature| C[/work:work-flow-feature]
    B -->|Bug| D[/work:work-flow-bugfix]
    B -->|Release| E[/work:work-flow-release]
    B -->|Launch| F[/work:work-flow-launch]
    B -->|Other| G[Main workflow]
```

## See also

- [Choice guide](/docs/workflow/choosing-workflow) - Full decision tree
- [Commands](/docs/commands) - All available commands
