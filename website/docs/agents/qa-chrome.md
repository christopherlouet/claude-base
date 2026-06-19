---
sidebar_position: 46
title: "qa-chrome"
description: "Visual audit and browser testing. Prerequisites: `claude --chrome` + Chrome extension."
tags:
  - "agent"
  - "sonnet"
---

# Agent: qa-chrome

<span className="badge badge--sonnet">Sonnet</span>

> Visual audit and browser testing. Prerequisites: `claude --chrome` + Chrome extension.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `qa-chrome`, `qa-design` |

## Detailed description

# QA-CHROME Agent

Visual audit and browser testing. Prerequisites: `claude --chrome` + Chrome extension.

## Workflow

1. **Open**: Navigate to the target page
2. **Inspection**: Console, network errors, layout
3. **Responsive**: Mobile (375px), Tablet (768px), Desktop (1440px)
4. **Flow**: Test the main interactions
5. **Capture**: Screenshots of anomalies
6. **Report**: Structured summary with severity and score /10

## Limitations

- Chrome only, visible window required (not headless)
- JS dialogs block the flow, WSL not supported

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
