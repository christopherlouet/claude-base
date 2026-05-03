---
sidebar_position: 22
title: "doc-changelog"
description: "CHANGELOG maintenance following Keep a Changelog. Trigger when the user wants to document changes or prepare a release."
tags:
  - "skill"
  - "fork"
---

# Skill: doc-changelog

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> CHANGELOG maintenance following Keep a Changelog. Trigger when the user wants to document changes or prepare a release.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Keywords** | `doc`, `changelog` |

## Detailed description

# Changelog Maintenance

## Keep a Changelog Format

```markdown
# Changelog

All notable changes will be documented here.

## [Unreleased]

### Added
- New feature

### Changed
- Modified behavior

### Fixed
- Bug fix

## [1.2.0] - 2024-01-15

### Added
- User authentication (#123)

### Fixed
- Login timeout (#127)

[Unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/releases/tag/v1.2.0
```

## Categories

| Category | Description |
|----------|-------------|
| Added | New features |
| Changed | Changes in existing functionality |
| Deprecated | Soon-to-be removed features |
| Removed | Removed features |
| Fixed | Bug fixes |
| Security | Security fixes |

## Best practices

- One entry per significant change
- Links to issues/PRs
- ISO date format (YYYY-MM-DD)
- [Unreleased] always up to date
- Write for users

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to doc..."_
- _"I want to changelog..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
