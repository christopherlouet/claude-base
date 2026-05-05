---
sidebar_position: 0
title: "What is Claude Code?"
description: "Understand Claude Code and the foundation in 2 minutes"
---

# What is Claude Code?

> Understand the tool and the foundation in 2 minutes, before getting started

## Claude Code in a nutshell

Claude Code is an **agentic AI tool** from Anthropic that lives in your terminal. Unlike a classic chatbot, it can:

| Classic chatbot | Claude Code |
|-------------------|-------------|
| Answers questions | **Executes** tasks in your code |
| Copy-paste of snippets | **Reads, modifies and creates** files directly |
| No project context | **Understands** your entire codebase |
| Manual interaction | **Orchestrates** autonomous sub-agents |

Claude Code reads your code, runs commands, runs tests, creates commits and PRs — all driven by natural language.

## Why a foundation?

Claude Code is powerful but unstructured. Without a framework, you:
- Code without understanding the existing code (bugs)
- Implement without a plan (constant refactoring)
- Forget the tests (regressions)
- Make giant commits (unreadable history)

**claude-base** enforces a structured workflow with pre-configured commands, agents, skills and rules:

```
Explore → Specify → Plan → TDD → Audit → Commit
```

## The 4 components of the foundation

| Component | Trigger | Example | Count |
|-----------|--------------|---------|--------|
| **Commands** | Manual (`/name`) | `/work:work-explore` | <!-- count:commands -->131<!-- /count --> |
| **Agents** | Via commands | Isolated autonomous sub-agents | <!-- count:agents -->63<!-- /count --> |
| **Skills** | Automatic (keywords) | Triggers when "bug" is mentioned | <!-- count:skills -->54<!-- /count --> |
| **Rules** | Automatic (files) | Activates when a `.tsx` is modified | <!-- count:rules -->30<!-- /count --> |

### How it fits together

```
You type a command
        ↓
   The command launches an Agent
        ↓
   The agent uses Skills (auto-detected)
        ↓
   The Rules apply based on the modified files
```

## Where to start?

| Your profile | Recommended path |
|-------------|-------------------|
| **Never used Claude Code** | [Claude Code Training](/docs/guides/claude-code-training) (3h45, 9 modules) |
| **Knows Claude Code, discovering the foundation** | [Foundation path](/docs/guides/learning-path) (9h30, 5 levels) |
| **In a hurry** (5 min) | [Quick Start](/docs/intro/quick-start) |
| **Developer (web, mobile, API, backend, infra…)** | [Stack Recipes](/docs/concepts/stack-recipes) — commands/agents/skills by stack |
| **Tech lead / team** | [Team Guide](/docs/guides/team-guide) |
| **Extend the foundation** | [Extending Guide](/docs/guides/extending-guide) |

## Next step

import Link from '@docusaurus/Link';

<div className="quick-actions">
  <Link className="button button--primary button--lg" to="/docs/guides/claude-code-training">
    Claude Code Training (prerequisite)
  </Link>
  <Link className="button button--secondary button--lg" to="/docs/guides/learning-path">
    Foundation path (after the training)
  </Link>
</div>
