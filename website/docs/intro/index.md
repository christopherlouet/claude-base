---
sidebar_position: 1
title: Welcome
description: Claude Code configuration template for an optimal workflow
slug: /
---

import Stats, { SOCLE_STATS } from '@site/src/components/Stats';

# Welcome to claude-socle

> **Claude Code configuration template for an optimal workflow: Explore → Specify → Plan → TDD → Audit → Commit**

claude-socle is a complete set of configurations, commands, and automations to maximize your productivity with Claude Code. It offers a structured workflow and specialized agents for each type of task.

<Stats items={SOCLE_STATS} />

## Why claude-socle?

### The problem

When you use Claude Code without structure:
- You code without understanding the existing code → bugs and regressions
- You implement without a plan → constant refactoring
- You make giant commits → unreadable history
- You waste time looking for the right commands

### The solution

claude-socle enforces a structured workflow:

```
Explore → Specify → Plan → TDD → Audit → Commit
```

Each step has its dedicated commands, specialized agents, and best practices.

## Key numbers

| Component | Count | Description |
|-----------|--------|-------------|
| **Commands** | 131 | Manually triggered commands (`/name`) |
| **Agents** | 63 | Autonomous sub-agents with isolated context |
| **Skills** | 54 | Auto-triggered on keywords |
| **Rules** | 30 | Rules per technology/file |

## Domains covered

| Domain | Commands | Description |
|---------|-----------|-------------|
| **WORK** | 15 | Main workflow (explore, plan, commit, PR) |
| **DEV** | 23 | Development (TDD, API, components, debug) |
| **QA** | 16 | Quality (review, security, performance, a11y) |
| **OPS** | 34 | Operations (CI/CD, Docker, monitoring, GitFlow) |
| **DOC** | 9 | Documentation (changelog, README, architecture) |
| **BIZ** | 11 | Business (model, MVP, pricing, pitch) |
| **GROWTH** | 11 | Growth (SEO, analytics, landing, funnel) |
| **DATA** | 3 | Data (pipeline, analytics, modeling) |
| **LEGAL** | 5 | Legal (GDPR, ToS, payment) |

## Quick start

```bash
# Clone the template
git clone https://github.com/christopherlouet/claude-socle.git .claude

# Or use the install script
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash
```

Then in Claude Code:

```bash
# Discover available commands
/assistant

# Start by exploring the code
/work:work-explore

# Plan a change
/work:work-plan
```

## Next steps

import Link from '@docusaurus/Link';

<div className="quick-actions">
  <Link className="quick-action" to="/docs/guides/learning-path">
    Learning path (9h30, 5 levels)
  </Link>
  <Link className="quick-action" to="/docs/intro/quick-start">
    Quick Start in 5 min
  </Link>
  <Link className="quick-action" to="/docs/intro/what-is-claude-code">
    What is Claude Code?
  </Link>
</div>
