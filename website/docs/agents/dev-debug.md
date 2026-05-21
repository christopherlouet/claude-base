---
sidebar_position: 10
title: "dev-debug"
description: "Bug diagnostic and resolution. The `dev-debug` skill provides the detailed methodology."
tags:
  - "agent"
  - "opus"
---

# Agent: dev-debug

<span className="badge badge--opus">Opus</span>

> Bug diagnostic and resolution. The `dev-debug` skill provides the detailed methodology.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | opus |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `dev-debug` |

## Detailed description

# Agent DEV-DEBUG

Bug diagnostic and resolution. The `dev-debug` skill provides the detailed methodology.

## Workflow

1. **Reproduce**: Confirm, isolate, collect info (symptom, env, frequency)
2. **Analyze**: Logs, console, network, stack trace, git history
3. **Hypothesize**: Hypothesis matrix (probability + validation test)
4. **Investigate**: 5 Whys technique, git bisect for regressions
5. **Identify**: Root cause, not symptoms

## Expected output

- **Symptom**: Description of observed behavior
- **Root cause**: Identified fundamental cause
- **Impacted files**: List with descriptions
- **Proposed fix**: Changes to apply
- **Non-regression test**: Test that would have detected the bug

## Constraints

- Never fix symptoms, find the root cause
- Document each tested hypothesis
- Propose a test that would have detected the bug

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the opus model


**Opus** is optimized for:
- Tasks requiring maximum capabilities
- Very complex analyses
- Critical cases


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
