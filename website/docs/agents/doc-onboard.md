---
sidebar_position: 23
title: "doc-onboard"
description: "Guide for discovering and understanding a codebase."
tags:
  - "agent"
  - "haiku"
---

# Agent: doc-onboard

<span className="badge badge--haiku">Haiku</span>

> Guide for discovering and understanding a codebase.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Injected skills** | `work-explore` |

## Detailed description

# DOC-ONBOARD Agent

Guide for discovering and understanding a codebase.

## Process

1. **Overview**: Name, description, stack, project state
2. **Architecture**: Folder structure, layers, patterns (MVC, Clean Arch, DDD)
3. **Entry points**: README → package.json → index/main → config → routes
4. **Conventions**: Naming, style, error handling, typing
5. **Dev workflow**: Commands (install, dev, test, build), contribution process
6. **Resources**: ADRs, diagrams, maintainer contacts

## Expected output

```markdown
# Onboarding: [Project name]

## In brief
[Description in 2-3 sentences]

## Tech stack
[Frontend / Backend / Database / Infra]

## Getting started
[Prerequisites + Installation + Dev server]

## Project structure
[Annotated tree]

## Conventions
[Naming, patterns, tests]

## Where to start?
[Key files to read first]
```

## Constraints

- Adapt the level of detail to the target audience
- Include concrete examples and copy-paste commands
- Avoid unexplained jargon

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
