---
sidebar_position: 1
title: Welcome
description: Claude Code configuration template for an optimal workflow
slug: /
---

import Stats, { BASE_STATS } from '@site/src/components/Stats';

# Welcome to claude-base

> **Claude Code configuration template for an optimal workflow: Explore → Specify → Plan → TDD → Audit → Commit**

claude-base is a complete set of configurations, commands, and automations to maximize your productivity with Claude Code. It offers a structured workflow and specialized agents for each type of task.

<Stats items={BASE_STATS} />

## Why claude-base?

### The problem

When you use Claude Code without structure:
- You code without understanding the existing code → bugs and regressions
- You implement without a plan → constant refactoring
- You make giant commits → unreadable history
- You waste time looking for the right commands

### The solution

claude-base enforces a structured workflow:

```
Explore → Specify → Plan → TDD → Audit → Commit
```

Each step has its dedicated commands, specialized agents, and best practices.

## Key numbers

| Component | Count | Description |
|-----------|--------|-------------|
| **Commands** | <!-- count:commands -->131<!-- /count --> | Manually triggered commands (`/name`) |
| **Agents** | <!-- count:agents -->63<!-- /count --> | Autonomous sub-agents with isolated context |
| **Skills** | <!-- count:skills -->54<!-- /count --> | Auto-triggered on keywords |
| **Rules** | <!-- count:rules -->30<!-- /count --> | Rules per technology/file |

## Domains covered

| Domain | Commands | Description |
|---------|-----------|-------------|
| **WORK** | <!-- count:byDomain.work -->15<!-- /count --> | Main workflow (explore, plan, commit, PR) |
| **DEV** | <!-- count:byDomain.dev -->23<!-- /count --> | Development (TDD, API, components, debug) |
| **QA** | <!-- count:byDomain.qa -->16<!-- /count --> | Quality (review, security, performance, a11y) |
| **OPS** | <!-- count:byDomain.ops -->34<!-- /count --> | Operations (CI/CD, Docker, monitoring, GitFlow) |
| **DOC** | <!-- count:byDomain.doc -->9<!-- /count --> | Documentation (changelog, README, architecture) |
| **BIZ** | <!-- count:byDomain.biz -->11<!-- /count --> | Business (model, MVP, pricing, pitch) |
| **GROWTH** | <!-- count:byDomain.growth -->11<!-- /count --> | Growth (SEO, analytics, landing, funnel) |
| **DATA** | <!-- count:byDomain.data -->3<!-- /count --> | Data (pipeline, analytics, modeling) |
| **LEGAL** | <!-- count:byDomain.legal -->5<!-- /count --> | Legal (GDPR, ToS, payment) |

## Quick start

```bash
# Clone the template
git clone https://github.com/christopherlouet/claude-base.git .claude

# Or use the install script
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/new-project.sh | bash
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
