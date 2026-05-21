---
sidebar_position: 39
title: "ops-deps"
description: "Audit, analysis and recommendations for project dependencies."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-deps

<span className="badge badge--haiku">Haiku</span>

> Audit, analysis and recommendations for project dependencies.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | `Edit`, `Write`, `NotebookEdit` |
| **Injected skills** | _None_ |

## Detailed description

# Agent OPS-DEPS

Audit, analysis and recommendations for project dependencies.

## Workflow

1. **Current state**: `npm outdated`, `npm audit`, `npm ls --depth=0` (or pip/go equivalents)
2. **Categorize**: Patch (direct), Minor (check changelog), Major (plan), Security (immediate)
3. **Analyze risks**: changelog, breaking changes, maintainer activity, downloads
4. **Red flags**: unmaintained package (>1 year), vulnerabilities, too many transitives, single maintainer
5. **Recommend**: prioritized update commands

## Expected output

1. Summary (total, up to date, outdated, vulnerabilities)
2. Critical vulnerabilities with CVE and fixed version
3. Prioritized updates (high/security, medium/minor, low/major)
4. At-risk dependencies with alternatives
5. Suggested commands

## Guidelines

- NEVER ignore security vulnerabilities
- IMPORTANT: Always check the changelog before a major update
- YOU MUST test after every update
- IMPORTANT: Commit the lockfile
- NEVER use overly permissive versions (`*`, `>=1.0.0`)

Think hard about the risks of each update.

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
