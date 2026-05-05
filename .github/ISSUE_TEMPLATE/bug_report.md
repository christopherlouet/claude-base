---
name: Bug report
about: Report a defect in claude-base
title: "[Bug] "
labels: ["bug", "triage"]
assignees: []
---

> Please write this issue in **English**. See [CONTRIBUTING.md](../../CONTRIBUTING.md#language-policy).

## Description

A clear and concise description of the bug.

## Steps to Reproduce

1. ...
2. ...
3. ...

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened. Include error messages or stack traces if relevant.

## Environment

- claude-base version: <!-- e.g. v1.30.0 (run `cat VERSION`) -->
- Claude Code CLI version: <!-- run `claude --version` -->
- OS: <!-- e.g. Ubuntu 24.04, macOS 14.2, Windows 11 (WSL2) -->
- Shell: <!-- bash, zsh, fish -->

## Additional Context

- Hooks enabled? Anything in `.claude/settings.local.json`?
- MCP servers active?
- Logs from `scripts/hooks/*` if relevant.

## Checklist

- [ ] I searched existing issues for duplicates.
- [ ] I am running a supported version (see `SECURITY.md`).
- [ ] I redacted any secrets/tokens before pasting logs.
