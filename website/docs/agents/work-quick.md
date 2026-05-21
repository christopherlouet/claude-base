---
sidebar_position: 62
title: "work-quick"
description: "Quick workflow for trivial changes. The `work-quick` skill provides the eligibility criteria and methodology."
tags:
  - "agent"
  - "sonnet"
---

# Agent: work-quick

<span className="badge badge--sonnet">Sonnet</span>

> Quick workflow for trivial changes. The `work-quick` skill provides the eligibility criteria and methodology.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `work-quick` |

## Detailed description

# Agent WORK-QUICK

Quick workflow for trivial changes. The `work-quick` skill provides the eligibility criteria and methodology.

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
