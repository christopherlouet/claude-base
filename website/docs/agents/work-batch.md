---
sidebar_position: 54
title: "work-batch"
description: "Autonomous execution of stories from a PRD. The `work-batch` skill provides the formats and methodology."
tags:
  - "agent"
  - "sonnet"
---

# Agent: work-batch

<span className="badge badge--sonnet">Sonnet</span>

> Autonomous execution of stories from a PRD. The `work-batch` skill provides the formats and methodology.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `work-batch` |

## Detailed description

# Agent WORK-BATCH

Autonomous execution of stories from a PRD. The `work-batch` skill provides the formats and methodology.

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
