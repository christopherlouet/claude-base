---
sidebar_position: 21
title: "Troubleshooting Guide"
description: "Diagnose and resolve common issues"
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Troubleshooting Guide

> Resolve common issues with Claude Code and the claude-base foundation

## Sections

- [Common Claude Code issues](#1-common-claude-code-issues)
- [Foundation issues](#2-foundation-issues)
- [Quick diagnosis](#3-quick-diagnosis)
- [Diagnostic commands](#4-diagnostic-commands)
- [Emergency recovery](#5-emergency-recovery)
- [Performance optimization](#6-performance-optimization)

---

## 1. Common Claude Code issues

| Symptom | Likely cause | Solution |
|---------|--------------|----------|
| "Context window full" or automatic compaction | Too many files read, long session, verbose logs included | `/compact` to summarize, avoid reading `/tmp/` or `node_modules/` |
| Very slow session, high token usage | Repeated reads of large files, uncompacted context | `/compact` between phases, use `effort low` for exploration |
| Silent hook that does not trigger | Non-executable script, wrong path, exceeded timeout | Check the logs in `/tmp/claude-sessions.log`, test the script manually |
| MCP server missing or disconnected | Server disabled in `.mcp.json`, missing dependency | Check `"disabled": true` in `.mcp.json`, restart with `/mcp` |
| Agent or skill that does not trigger | Wrong namespace, description too vague, missing file | Check the exact name with `/help`, read the description in the `.md` file |
| Permission loop denied | Command in the `deny` list of `settings.json`, strict auto mode | Use `SKIP_COMMAND_VALIDATOR=1` or revise the command |
| Git conflict during the TDD cycle | Out-of-sync branch, missing intermediate commit | `git stash`, `git pull --rebase`, then `git stash pop` |

### Context window full

Automatic compaction triggers when the context approaches the limit. If it fails or is poorly timed:

```bash
# Compact manually between two phases
/compact

# If the context is corrupted or too fragmented
/clear
```

To reduce pressure on the context, avoid: reading entire directories (`node_modules/`, `.git/`, `dist/`), including large log files, re-reading already-known files.

### MCP servers

MCP servers are disabled by default in `.mcp.json`. To diagnose:

```bash
# Check the state of MCP servers
cat .mcp.json | grep -A3 "disabled"

# Read MCP events
cat /tmp/claude-mcp.log
```

To enable a server, remove `"disabled": true` or switch it to `"disabled": false` in `.mcp.json`.

---

## 2. Foundation issues

### Pre-commit tests blocking a commit

The `PreToolUse` hook intercepts `git commit` and runs the tests. If the tests fail, the commit is blocked.

**Diagnosis:**

```bash
# Run the tests manually to see the errors
npm test

# Or depending on the project
pytest
go test ./...
flutter test
```

**If the tests legitimately fail** (known technical debt, work in progress):

```bash
# Disable pre-commit tests for this commit only
SKIP_PRE_COMMIT_TESTS=1 git commit -m "wip: ..."
```

**If the hook is faulty** (Husky missing, script not found):

Claude Code automatically detects and repairs Husky if needed. If failure persists, check:

```bash
ls -la .husky/
cat /tmp/claude-sessions.log | tail -20
```

### Main branch protection

The `PreToolUse` hook blocks any direct modification on `main` or `master`. This is an intentional safeguard.

**Normal solution:** work on a feature branch.

```bash
git checkout -b feature/my-modification
```

**If a direct modification on main is absolutely necessary** (critical hotfix, personal repository):

```bash
ALLOW_MAIN_EDIT=1 git commit -m "fix: critical hotfix"
```

### Gitleaks: false positives

The secret-detection hook scans content before each write. It may flag false positives on test tokens, configuration examples, or placeholders.

**Identify the detected pattern:**

```bash
# Test gitleaks directly on the relevant file
gitleaks detect --source . --verbose 2>&1 | grep -A5 "leak"
```

**Add an exception in `.gitleaks.toml`** (at the project root, create if absent):

```toml
[allowlist]
  description = "Known false positives"
  regexes = [
    '''EXAMPLE_TOKEN_FOR_TESTS''',
    '''placeholder_api_key'''
  ]
  paths = [
    '''tests/fixtures/.*''',
    '''docs/.*'''
  ]
```

### Formatting hooks that break the code

The `PostToolUse` hooks run Prettier, Ruff, gofmt, etc. after each write. If the formatter is missing or misconfigured, it may produce empty output or a silent error.

**Check that the formatter is installed:**

```bash
# TypeScript/JavaScript
npx prettier --version

# Python
ruff --version || black --version

# Go (gofmt has no --version flag; check the toolchain / the binary)
go version && command -v gofmt

# Dart
dart format --help
```

**If the formatter modifies the code too aggressively:**

Check the local configuration (`.prettierrc`, `pyproject.toml`, `.editorconfig`). The formatter uses the project configuration if it exists.

### Command validator blocking a legitimate command

The `Command validator` hook analyzes 9 risk categories. Some valid commands may match a dangerous pattern.

**Identify why the command is blocked:**

```bash
# Read the session logs to see the reason for blocking
cat /tmp/claude-sessions.log | grep -i "block\|validator" | tail -10
```

**Bypass for a specific command:**

```bash
SKIP_COMMAND_VALIDATOR=1 <command>
```

**Bypass permanently for a session:**

Add to `.claude/settings.local.json` (not committed):

```json
{
  "env": {
    "SKIP_COMMAND_VALIDATOR": "1"
  }
}
```

---

## 3. Quick diagnosis

Use this decision tree to quickly identify the source of a problem.

```
MY COMMIT IS BLOCKED
│
├── Message "tests failed"?
│   ├── Yes → npm test (or equivalent) to see the errors
│   │         Fix the tests OR SKIP_PRE_COMMIT_TESTS=1
│   └── No
│       ├── Message "branch main protected"?
│       │   └── Yes → Create a branch OR ALLOW_MAIN_EDIT=1
│       ├── Message "secret detected"?
│       │   └── Yes → Remove the secret OR add exception in .gitleaks.toml
│       └── Other → cat /tmp/claude-sessions.log | tail -30


CLAUDE NO LONGER RESPONDS / VERY SLOW
│
├── Long session (>1h, many files read)?
│   └── Yes → /compact (preserves the essential context)
├── Complete topic change?
│   └── Yes → /clear (start from scratch)
├── Still slow even after /compact?
│   └── Yes → /clear + restart with a concise prompt
└── Claude seems stuck on a task?
    └── Ctrl+C to interrupt, then rephrase the request


THE AGENT / COMMAND DOES NOTHING
│
├── Is the name correct?
│   └── No → /help to list available commands
├── Is the agent waiting for parameters?
│   └── Possibly → read the description: /work:work-plan "description"
├── Does the agent file exist?
│   └── Check: ls .claude/commands/
├── Model insufficient for the task?
│   └── Opus for complex tasks, Sonnet for audits
└── Sub-agent that does not start?
    └── cat /tmp/claude-agents.log | tail -20


THE HOOK DOES NOT TRIGGER
│
├── Check that the script is executable
│   └── ls -la .claude/hooks/
├── Test the script manually
│   └── bash .claude/hooks/my-script.sh
├── Check the logs
│   └── cat /tmp/claude-sessions.log | tail -30
└── Timeout too short?
    └── Check the "timeout" property in settings.json
```

---

## 4. Diagnostic commands

| Command | Usage | When to use it |
|---------|-------|----------------|
| `/compact` | Summarizes the context while preserving the essentials | Long session, between two workflow phases |
| `/clear` | Erases the entire context | Total topic change, corrupted context |
| `/rewind` | Returns to the last stable state before a modification | Refactoring that broke everything |
| `/help` | Lists all available commands and agents | Agent not found, uncertain name |
| `claude --version` | Displays the installed version | Compatibility issue, missing feature |
| `cat /tmp/claude-sessions.log` | Session logs (startup, compaction, hooks) | Silent hook, startup issue |
| `cat /tmp/claude-agents.log` | Sub-agent logs | Agent that does not start or terminates prematurely |
| `cat /tmp/claude-notifications.log` | Permission and waiting logs | Permission denied, Claude waiting for the user |
| `cat /tmp/claude-mcp.log` | MCP Elicitation logs | MCP server disconnected, elicitation failed |

### Check the version and installation

```bash
# Claude Code CLI version
claude --version

# Check that hooks are properly loaded at startup
cat /tmp/claude-sessions.log | head -20

# Check the permissions of the hook scripts
ls -la .claude/hooks/

# Test a specific hook independently
bash .claude/hooks/pre-commit-tests.sh
```

### Inspect logs in real time

```bash
# Follow session logs live during a Claude session
tail -f /tmp/claude-sessions.log

# Follow agent logs live
tail -f /tmp/claude-agents.log
```

---

## 5. Emergency recovery

### /rewind: undo the last modifications

Claude Code automatically saves a checkpoint before each modification. In case of a refactoring that breaks everything:

```bash
/rewind
```

This returns to the last stable state, faster than `git stash` or `git checkout`. Use before the situation degrades further.

### git stash + clean restart

When the in-progress modifications are too complex to untangle:

```bash
# Save the current state
git stash push -m "wip: before clean restart"

# Return to the last clean commit
git status   # check that we are clean

# Restart Claude Code in a fresh state
/clear
```

To recover the saved work later:

```bash
git stash pop
```

### Disable hooks temporarily

If a hook persistently blocks the work, disable it via environment variables. Several methods:

**For a single command:**

```bash
SKIP_PRE_COMMIT_TESTS=1 git commit -m "..."
SKIP_PRE_PUSH_CI=1 git push
SKIP_COMMAND_VALIDATOR=1 <command>
SKIP_DESTRUCTIVE_CHECK=1 <command>
```

**For an entire session (in `.claude/settings.local.json`, not committed):**

```json
{
  "env": {
    "SKIP_PRE_COMMIT_TESTS": "1",
    "ALLOW_MAIN_EDIT": "1"
  }
}
```

Available variables:

| Variable | Effect |
|----------|--------|
| `ALLOW_MAIN_EDIT=1` | Disables main branch protection |
| `SKIP_PRE_COMMIT_TESTS=1` | Disables pre-commit tests |
| `SKIP_PRE_PUSH_CI=1` | Disables local CI before push |
| `SKIP_COMMAND_VALIDATOR=1` | Disables command security validation |
| `SKIP_DESTRUCTIVE_CHECK=1` | Disables protection against destructive operations |

### Fully reset the hooks

If the hooks are in an inconsistent state (permissions, modified scripts):

```bash
# Reset hook permissions
chmod +x .claude/hooks/*.sh

# Check that the hook contents have not been altered
git diff .claude/hooks/

# Restore from git if necessary
git checkout .claude/hooks/
```

### Unsolvable git conflict during TDD

When a merge conflict blocks the TDD cycle:

```bash
# Abort the merge in progress
git merge --abort
# or
git rebase --abort

# Return to a clean state
git checkout main
git pull --rebase origin main

# Recreate the work branch from a clean state
git checkout -b feature/new-attempt
```

---

## 6. Performance optimization

### When to use /compact vs /clear

| Situation | Command | Reason |
|-----------|---------|--------|
| Long session, same topic | `/compact` | Preserves learned decisions and conventions |
| Between two workflow phases | `/compact` | Keeps the context of the plan and exploration |
| Switch to an unrelated feature | `/clear` | Prevents the old context from polluting the new one |
| Context window > 80% used | `/compact` | Preventive before saturation |
| Corrupted or inconsistent context | `/clear` | Start over on a clean basis |

Rule: prefer `/compact` over `/clear`. Compaction preserves the essentials (decisions, conventions, project structure) whereas `/clear` erases everything and forces re-exploration.

### Reduce token consumption

**Use the appropriate effort levels:**

| Task | Recommended effort | Command |
|------|-------------------|---------|
| Read and explore code | Low | `/effort low` |
| Implement a standard feature | Medium | `/effort medium` |
| Design an architecture | High | `/effort high` |
| Critical audit, complex debugging | Maximum | `/effort max` |

**Avoid expensive reads:**

```bash
# Do not read entire directories
# Bad: read all of src/
# Good: target the relevant files

# Use grep before reading
grep -r "functionName" src/ --include="*.ts" -l
# then read only the relevant files
```

### Avoid reading large files

Files and directories never to read in full:

| To avoid | Alternative |
|----------|-------------|
| `node_modules/` | Read only `package.json` |
| `dist/`, `build/`, `.next/` | Generated files, useless to read |
| `/tmp/claude-*.log` (entire) | `tail -20 /tmp/claude-sessions.log` |
| `yarn.lock`, `package-lock.json` | Read only `package.json` |
| `.git/` | Use git commands |

### Structure sessions to minimize context

- One session = one feature or one bug. Do not mix topics.
- Commit frequently: `/compact` is more effective on recent context.
- Use `/compact` between workflow phases (after Explore, after Plan).
- Limit the number of files open simultaneously to what is strictly necessary.

---

## Resources

- [Configured hooks](../reference/hooks-reference.md) - Full list of hooks and their variables
- [Available commands](../reference/commands.md) - Catalog of `/work:`, `/dev:`, `/qa:`, `/ops:` commands
- [Advanced features](../reference/advanced-features.md) - Explore → Specify → Plan → TDD → Audit → Commit workflow
- [Best practices](../reference/best-practices.md) - Verification, models, effort levels
