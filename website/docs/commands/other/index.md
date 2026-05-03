---
sidebar_position: 1
title: "Autres"
description: "Autres commands - Commandes diverses et orchestrateurs"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Autres Commands

> Commandes diverses et orchestrateurs

## Overview

This domain contains **4 commands** for commandes diverses et orchestrateurs.

## Commands list

| Command | Description |
|----------|-------------|
| [`/assistant`](/docs/commands/other/assistant) | Single entry point of the Claude Code foundation. Guides toward the right commands, agents, skills and workflows. |
| [`/assistant-auto`](/docs/commands/other/assistant-auto) | Orchestrator in automatic mode. Choose the workflow that semantically fits based on the request + the injected repo context, then execute immediately via Skill. |
| [`/git-rename`](/docs/commands/other/git-rename) | Renames the current branch (typically a `feature/auto-*` branch created by the PreToolUse hook). |
| [`/lessons`](/docs/commands/other/lessons) | Lists the `feedback` memories captured for the current project (and globally) — the "lessons" learned from user corrections. |

## Commands in detail

<CommandGrid>
  <CommandCard
    name="assistant"
    description="Single entry point of the Claude Code foundation. Guides toward the right commands, agents, skills and workflows."
    domain="other"
    href="/docs/commands/other/assistant"
  />
  <CommandCard
    name="assistant-auto"
    description="Orchestrator in automatic mode. Choose the workflow that semantically fits based on the request + the injected repo context, then execute immediately via Skill."
    domain="other"
    href="/docs/commands/other/assistant-auto"
  />
  <CommandCard
    name="git-rename"
    description="Renames the current branch (typically a `feature/auto-*` branch created by the PreToolUse hook)."
    domain="other"
    href="/docs/commands/other/git-rename"
  />
  <CommandCard
    name="lessons"
    description="Lists the `feedback` memories captured for the current project (and globally) — the &quot;lessons&quot; learned from user corrections."
    domain="other"
    href="/docs/commands/other/lessons"
  />
</CommandGrid>

---

[Back to all commands](/docs/commands)
