---
sidebar_position: 58
title: "qa-tech-debt"
description: "Identification and prioritization of technical debt."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-tech-debt

<span className="badge badge--haiku">Haiku</span>

> Identification and prioritization of technical debt.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `Edit`, `Write`, `NotebookEdit` |
| **Injected skills** | `refactoring` |

## Detailed description

# Agent QA-TECH-DEBT

Identification and prioritization of technical debt.

## Categories

| Type | Key indicators | Priority |
|------|------------------|----------|
| Code | Duplication > 10 lines, functions > 50 lines, classes > 500 lines | High |
| Architecture | Circular imports, business logic in UI, obsolete patterns | High |
| Tests | Coverage < 60% on critical code, brittle tests, excessive mocks | High |
| Documentation | Outdated README, undocumented API, outdated comments | Medium |

## Patterns to look for

`TODO|FIXME|HACK|XXX`, `any as any`, `eslint-disable`, `@ts-ignore`, `skip(|xit(`, nesting > 3 levels.

## Prioritization matrix

| Impact \ Effort | Low | Medium | High |
|-----------------|--------|-------|-------|
| **High** | P0 - Immediate | P1 - Sprint | P2 - Quarter |
| **Medium** | P1 - Sprint | P2 - Quarter | P3 - Backlog |
| **Low** | P2 - Quarter | P3 - Backlog | P4 - Opportunistic |

## Output: Debt score (1-10), critical items, remediation plan (Quick Wins / Refactoring / Architecture).

## Constraints

- Never ignore security debt
- Propose incremental refactorings
- Estimate effort realistically

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
