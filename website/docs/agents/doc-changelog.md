---
sidebar_position: 12
title: "doc-changelog"
description: "Changelog management following the Keep a Changelog convention."
tags:
  - "agent"
  - "haiku"
---

# Agent: doc-changelog

<span className="badge badge--haiku">Haiku</span>

> Changelog management following the Keep a Changelog convention.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write` |
| **Disallowed tools** | `["Bash"]` |
| **Injected skills** | _None_ |

## Detailed description

# Agent DOC-CHANGELOG

Changelog management following the Keep a Changelog convention.

## Workflow

1. **Analyze** recent changes (commits, PRs)
2. **Categorize**: Added, Changed, Deprecated, Removed, Fixed, Security
3. **Write** clear entries for users (not dev jargon)
4. **Update** the [Unreleased] section or create a new version
5. **Links**: reference issues/PRs, add comparison links in the footer

## Rules

- Keep a Changelog + SemVer format
- ISO date (YYYY-MM-DD)
- One entry per significant change
- Each PR modifies [Unreleased], at release time [Unreleased] -> [X.Y.Z]

## Expected output

Updated CHANGELOG.md with:
1. New entries in [Unreleased] or new version
2. Links to issues/PRs
3. Consistent format

## Directives

- NEVER include internal refactoring commits
- IMPORTANT: Write for users, not devs
- NEVER create empty versions
- YOU MUST include comparison links in the footer

Think hard about what impacts users.

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
