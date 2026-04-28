## Summary

<!-- 1-3 bullets explaining what this PR does and why. -->

## Type of Change

- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change (existing behavior modified)
- [ ] Documentation only
- [ ] Refactor / chore

## Related Issues

<!-- Closes #123, Refs #456 -->

## Changes

<!-- High-level list of what changed. Keep it scannable. -->

-
-

## Test Plan

<!-- How a reviewer can validate this PR. -->

- [ ] `bats tests/` passes locally
- [ ] `shellcheck scripts/*.sh` clean
- [ ] Tested on a fresh project (`./scripts/new-project.sh --simple /tmp/test-project`)
- [ ] Documentation updated (`README.md`, `docs/`, `website/`)
- [ ] CHANGELOG entry added under `[Unreleased]`

## Checklist

- [ ] Conventional Commits format used (`feat:`, `fix:`, `docs:`, ...)
- [ ] No secrets, tokens, or personal paths in the diff
- [ ] If counters changed (agents/commands/skills), `scripts/validate-counts.sh` passes
- [ ] If breaking change, migration steps documented
