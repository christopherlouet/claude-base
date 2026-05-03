---
name: doc-changelog
description: CHANGELOG maintenance following Keep a Changelog. Trigger when the user wants to document changes or prepare a release.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
disable-model-invocation: true
---

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
