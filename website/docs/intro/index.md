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
| **Commands** | <!-- count:commands -->117<!-- /count --> | Manually triggered commands (`/name`) |
| **Agents** | <!-- count:agents -->47<!-- /count --> | Autonomous sub-agents with isolated context |
| **Skills** | <!-- count:skills -->53<!-- /count --> | Auto-triggered on keywords |
| **Rules** | <!-- count:rules -->31<!-- /count --> | Rules per technology/file |
| **Presets** | <!-- count:presets -->11<!-- /count --> | Stack-specific bundles installable via `--preset <name>` |

## Domains covered

| Domain | Commands | Description |
|---------|-----------|-------------|
| **WORK** | <!-- count:byDomain.work -->15<!-- /count --> | Main workflow (explore, plan, commit, PR) |
| **DEV** | <!-- count:byDomain.dev -->19<!-- /count --> | Development (TDD, API, components, debug) |
| **QA** | <!-- count:byDomain.qa -->13<!-- /count --> | Quality (review, security, performance, a11y) |
| **OPS** | <!-- count:byDomain.ops -->31<!-- /count --> | Operations (CI/CD, Docker, monitoring, GitFlow) |
| **DOC** | <!-- count:byDomain.doc -->6<!-- /count --> | Documentation (changelog, README, architecture) |
| **BIZ** | <!-- count:byDomain.biz -->11<!-- /count --> | Business (model, MVP, pricing, pitch) |
| **GROWTH** | <!-- count:byDomain.growth -->11<!-- /count --> | Growth (SEO, analytics, landing, funnel) |
| **DATA** | <!-- count:byDomain.data -->2<!-- /count --> | Data (pipeline, analytics, modeling) |
| **LEGAL** | <!-- count:byDomain.legal -->5<!-- /count --> | Legal (GDPR, ToS, payment) |

## Quick start

```bash
# Install the foundation (one-liner)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash

# Stack-specific init (auto-filtered foundation + curated vendor pointers)
claude-base init --preset nextjs   ./my-web-app    # Next.js fullstack
claude-base init --preset fastapi  ./my-api        # Python async backend
claude-base init --preset phaser   ./my-game       # 2D web game (vendor-pointer)
claude-base preset list                            # See all 11 presets
```

When no `--preset` is passed on an empty directory, an interactive prompt asks **"What are you building?"** with an 8-entry intent taxonomy (Web frontend / API-Backend / Mobile-Desktop / Game-Interactive media / Data-Database / Infra-DevOps / CLI-Automation / Other-Generic) and filters the subsequent menu accordingly.

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
