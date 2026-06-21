# Troubleshooting Guide

> Solve common problems with Claude Code and the claude-base foundation

## Sections

- [Common Claude Code problems](#1-common-claude-code-problems)
- [Foundation problems](#2-foundation-problems)
- [Quick diagnosis](#3-quick-diagnosis)
- [Diagnostic commands](#4-diagnostic-commands)
- [Emergency recovery](#5-emergency-recovery)
- [Performance optimization](#6-performance-optimization)

---

## 1. Common Claude Code problems

| Symptom | Probable cause | Solution |
|---------|---------------|----------|
| "Context window full" or automatic compaction | Too many files read, long session, verbose logs included | `/compact` to summarize, avoid reading `/tmp/` or `node_modules/` |
| Very slow session, high token count | Repeated reading of large files, uncompacted context | `/compact` between phases, use `effort low` for exploration |
| Silent hook that does not trigger | Non-executable script, wrong path, timeout exceeded | Check the logs in `/tmp/claude-sessions.log`, test the script manually |
| MCP server missing or disconnected | Server not listed in `.mcp.json`, pending approval, or missing dependency/env var | A server is active only if present in `.mcp.json` (no `enabled` flag — copy it from `.mcp.json.example`); approve project servers (`claude mcp reset-project-choices`), restart with `/mcp` |
| Agent or skill that does not trigger | Wrong namespace, description too vague, missing file | Check the exact name with `/help`, read the description in the `.md` file |
| Permission refusal loop | Command in the `deny` list of `settings.json`, strict auto mode | `/less-permission-prompts` to optimize allowlists, or `SKIP_COMMAND_VALIDATOR=1` |
| Too many permission prompts | Permissions too restrictive for the workflow | `/less-permission-prompts` scans transcripts and proposes optimized allowlists |
| Git conflict during the TDD cycle | Branch out of sync, missing intermediate commit | `git stash`, `git pull --rebase`, then `git stash pop` |
| `claude` not found or Node errors after `claude update` | Migration to the native binary (CLI 2.1.113+): the CLI is no longer a JavaScript bundle | Reinstall via the official channel, check `which claude` and `claude --version`. Old aliases pointing to `node /path/to/cli.js` no longer work |
| Subagent that "hangs" without returning | Before CLI 2.1.113: silent hang possible | Update: subagents idle > 10 min now fail with a clear message |
| Permission dialog that crashes when a teammate requests a tool | CLI bug prior to 2.1.114 | Update to CLI >= 2.1.114 |
| Truncated responses, incoherent reasoning, degraded quality between March 4 and April 10 2026 | Cumulative regression: default `medium` effort, broken thinking history caching, system prompt limiting to 25 words between tool calls | Resolved in v2.1.101 (April 10 2026). Run `claude update`; the default effort returns to `high` and caching is fixed |

### Context window full

Automatic compaction triggers when the context approaches the limit. If it fails or is mistimed:

```bash
# Compact manually between two phases
/compact

# If the context is corrupted or too fragmented
/clear
```

To avoid in order to reduce pressure on the context: reading entire directories (`node_modules/`, `.git/`, `dist/`), including large log files, re-reading already known files.

### MCP servers

MCP servers are disabled by default in `.mcp.json`. To diagnose:

```bash
# Check the state of MCP servers
cat .mcp.json | grep -A3 "disabled"

# Read MCP events
cat /tmp/claude-mcp.log
```

To enable a server, remove `"disabled": true` or change it to `"disabled": false` in `.mcp.json`.

---

## 2. Foundation problems

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

**If the tests fail legitimately** (known technical debt, work in progress):

```bash
# Disable pre-commit tests for this commit only
SKIP_PRE_COMMIT_TESTS=1 git commit -m "wip: ..."
```

**If the hook is faulty** (missing Husky, script not found):

Claude Code automatically detects and repairs Husky if necessary. In case of persistent failure, check:

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

The secret detection hook analyzes content before each write. It may flag false positives on test tokens, configuration examples, or placeholders.

**Identify the detected pattern:**

```bash
# Test gitleaks directly on the file in question
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

# Go
gofmt --version

# Dart
dart format --help
```

**If the formatter modifies the code too aggressively:**

Check the local configuration (`.prettierrc`, `pyproject.toml`, `.editorconfig`). The formatter uses the project configuration if it exists.

### Command validator blocking a legitimate command

The `Command validator` hook analyzes 8 risk categories. Some valid commands may match a dangerous pattern.

**Identify why the command is blocked:**

```bash
# Read the session logs to see the blocking reason
cat /tmp/claude-sessions.log | grep -i "block\|validator" | tail -10
```

**Bypass for a specific command:**

```bash
SKIP_COMMAND_VALIDATOR=1 <command>
```

**Bypass permanently for a session:**

Add in `.claude/settings.local.json` (not committed):

```json
{
  "env": {
    "SKIP_COMMAND_VALIDATOR": "1"
  }
}
```

### Security drift after an update (version bumped, hooks still stale)

`claude-base update` advances the recorded version (`.claude/foundation.json`)
on every run, but it leaves `settings.json` and `scripts/hooks/` **opt-in**
(behind `--settings` / `--hook-scripts`) so it never clobbers local
customizations. The side effect: a project can read as the latest version while
still running hook scripts from an older vintage. The most dangerous case is the
**stdin contract change** (CLI 2.1.76+): old hooks read their payload from
`$TOOL_INPUT`/`$TOOL_NAME` env vars that are no longer set, so they **silently
no-op** — a screen like `command-validator.sh` becomes a dead pass-through
while still appearing wired.

Detection:

```bash
claude-base doctor ./my-project   # section "6. Security drift"
```

`update` also prints a "Security drift detected" advisory at the end of a run
that left these surfaces behind. To re-sync (overwrites diverged hook scripts
and replaces `settings.json` — back up local hook customizations first):

```bash
claude-base update --settings --hook-scripts --force ./my-project
```

`--force` is required because a diverged hook is otherwise skipped as a possible
local customization. An interactive `update --hook-scripts` (without `-y`) lets
you resolve each conflict individually instead.

---

## 3. Quick diagnosis

Use this decision tree to quickly identify the source of a problem.

```
MY COMMIT IS BLOCKED
│
├── "tests failed" message?
│   ├── Yes → npm test (or equivalent) to see the errors
│   │         Fix the tests OR SKIP_PRE_COMMIT_TESTS=1
│   └── No
│       ├── "branch main protected" message?
│       │   └── Yes → Create a branch OR ALLOW_MAIN_EDIT=1
│       ├── "secret detected" message?
│       │   └── Yes → Remove the secret OR add exception .gitleaks.toml
│       └── Other → cat /tmp/claude-sessions.log | tail -30


CLAUDE NO LONGER RESPONDS / VERY SLOW
│
├── Long session (>1h, many files read)?
│   └── Yes → /compact (preserves the essential context)
├── Complete topic change?
│   └── Yes → /clear (start over)
├── Still slow even after /compact?
│   └── Yes → /clear + restart with a concise prompt
└── Claude seems stuck on a task?
    └── Ctrl+C to interrupt, then rephrase the request


THE AGENT / COMMAND DOES NOTHING
│
├── Is the name correct?
│   └── No → /help to list available commands
├── Is the agent waiting for parameters?
│   └── Possible → read the description: /work:work-plan "description"
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

| Command | Use | When to use it |
|---------|-----|----------------|
| `/compact` | Summarizes the context while preserving the essential | Long session, between two workflow phases |
| `/clear` | Erases the entire context | Total topic change, corrupted context |
| `/rewind` | Returns to the last stable state before a modification | Refactoring that broke everything |
| `/help` | Lists all available commands and agents | Agent not found, uncertain name |
| `claude --version` | Displays the installed version | Compatibility issue, missing feature |
| `cat /tmp/claude-sessions.log` | Session logs (startup, compaction, hooks) | Silent hook, startup problem |
| `cat /tmp/claude-agents.log` | Sub-agent logs | Agent that does not start or terminates prematurely |
| `cat /tmp/claude-notifications.log` | Permission and waiting logs | Permission refused, Claude waiting for the user |
| `cat /tmp/claude-mcp.log` | MCP Elicitation logs | MCP server disconnected, elicitation failed |

### Check the version and installation

```bash
# Claude Code CLI version
claude --version

# Check that hooks are properly loaded at startup
cat /tmp/claude-sessions.log | head -20

# Check the permissions of hook scripts
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

### /rewind: undo the latest modifications

Claude Code automatically saves a checkpoint before each modification. In case of refactoring that breaks everything:

```bash
/rewind
```

This returns to the last stable state, faster than `git stash` or `git checkout`. Use it before the situation degrades further.

### git stash + clean restart

When current modifications are too complex to untangle:

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
| `SKIP_PRE_COMMIT_TESTS=1` | Disables tests before commit |
| `SKIP_PRE_PUSH_CI=1` | Disables local CI before push |
| `SKIP_COMMAND_VALIDATOR=1` | Disables security validation of commands |
| `SKIP_DESTRUCTIVE_CHECK=1` | Disables protection against destructive operations |

### Fully reset the hooks

If the hooks are in an inconsistent state (permissions, modified scripts):

```bash
# Reset hook permissions
chmod +x .claude/hooks/*.sh

# Check that the content of the hooks has not been altered
git diff .claude/hooks/

# Restore from git if necessary
git checkout .claude/hooks/
```

### Unsolvable git conflict during TDD

When a merge conflict blocks the TDD cycle:

```bash
# Abort the ongoing merge
git merge --abort
# or
git rebase --abort

# Return to a clean state
git checkout main
git pull --rebase origin main

# Recreate the working branch from a clean state
git checkout -b feature/new-attempt
```

### Complete project cleanup (foundation + Claude Code state)

The foundation install and Claude Code's runtime state for a project live in two distinct places. A "clean slate" usually means wiping both.

| Tool | Scope | Removes |
|------|-------|---------|
| `bash scripts/uninstall.sh` (or `claude-base` dispatcher's uninstall flow) | Project-local foundation install | `<project>/.claude/`, `CLAUDE.md`, `CLAUDE.local.md`, claude-base entries in `.gitignore` |
| `claude project purge <path>` (CLI 2.1.126+) | Per-project Claude Code runtime state | `~/.claude/projects/<encoded-path>/` (transcripts, memory), `~/.claude/tasks/`, `~/.claude/file-history/`, `~/.claude/debug/`, the project entry in `~/.claude.json` |

The two scopes do not overlap. `uninstall.sh` does not touch `~/.claude/`; `claude project purge` does not touch the project directory. For a full teardown, run both:

```bash
# 1. Remove the foundation install from the project directory
bash scripts/uninstall.sh

# 2. Wipe Claude Code's runtime state for this project (preview first)
claude project purge --dry-run /path/to/project
claude project purge /path/to/project
```

`claude project purge` accepts `--dry-run`, `-i` (interactive per-item), `-y` (skip confirmation), and `--all` (every project, mutually exclusive with a path). The foundation's `uninstall.sh` is unchanged for backward compatibility — it prints a reminder pointing at `claude project purge` after a successful uninstall.

---

## 6. Performance optimization

### When to use /compact vs /clear

| Situation | Command | Reason |
|-----------|---------|--------|
| Long session, same topic | `/compact` | Preserves learned decisions and conventions |
| Between two workflow phases | `/compact` | Keeps the context of the plan and exploration |
| Switching to an unrelated feature | `/clear` | Prevents the old context from polluting the new one |
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
| Critical audit, complex debug | Maximum | `/effort max` |

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

Files and directories never to read in their entirety:

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
- Limit the number of simultaneously open files to what is strictly necessary.

---

## Resources

- [Configured hooks](../reference/hooks-reference.md) - Complete list of hooks and their variables
- [Available commands](../reference/commands.md) - Catalog of `/work:`, `/dev:`, `/qa:`, `/ops:` commands
- [Advanced features](../reference/advanced-features.md) - Workflow Explore → Specify → Plan → TDD → Audit → Commit
- [Best practices](../reference/best-practices.md) - Verification, models, effort levels
