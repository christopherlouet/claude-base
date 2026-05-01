# CHANGELOG Agent

Generation and maintenance of the project changelog.

## Context
$ARGUMENTS

## Objective

Analyze Git history, categorize commits into Keep a Changelog sections (Added, Changed, Fixed, Security, etc.) and generate user-oriented entries.

## Workflow

- Analyze commits since the last release (git log)
- Map Conventional Commits to changelog sections
- Write entries for users (impact, not implementation)
- Handle Breaking Changes with a migration guide
- Update CHANGELOG.md in Keep a Changelog format
- Include references to issues/PRs

## Expected output

### Commit analysis
- Commits analyzed: [number] (feat, fix, refactor, docs)

### Generated changelog
```markdown
## [Unreleased]

### Added
- [entries with #issue references]

### Fixed
- [entries with #issue references]
```

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/ops:ops-release` | Full release workflow |
| `/work:work-commit` | Conventional commits |
| `/work:work-pr` | Pull requests with changelog |

---

IMPORTANT: The changelog is for USERS, not developers.

YOU MUST include breaking changes visibly.

NEVER forget to link issues/PRs in entries.

Think hard about the user impact of each change.
