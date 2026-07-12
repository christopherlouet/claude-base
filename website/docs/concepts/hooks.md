---
sidebar_position: 6
title: Hooks
description: Understanding Claude Code hooks
---

# Hooks

> Automatic actions before or after tool usage

## What is a Hook?

A **hook** is a shell command automatically executed before (PreToolUse) or after (PostToolUse) Claude uses a tool.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Claude wants to use the "Edit" tool                           │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ PreToolUse Hook                        │                    │
│  │                                        │                    │
│  │ Matcher: "Edit|Write"                  │                    │
│  │ Command: main-branch-guard.sh          │                    │
│  │                                        │                    │
│  │ → Blocks the edit (exit 2) on main     │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼ (if hook OK)                                    │
│  ┌────────────────────────────────────────┐                    │
│  │ "Edit" tool executed                   │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ PostToolUse Hook                       │                    │
│  │                                        │                    │
│  │ Matcher: "Edit|Write"                  │                    │
│  │ Command: auto-format (prettier/ruff)   │                    │
│  │                                        │                    │
│  │ → Automatically formats the file       │                    │
│  └────────────────────────────────────────┘                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Configuration

Hooks are configured in `.claude/settings.json`. Each hook runs a **discrete script** under `scripts/hooks/` (there is no single dispatcher script) — a PreToolUse hook **blocks** the tool call by exiting with code **2**:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/main-branch-guard.sh\"",
            "onFailure": "block"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/post-edit-typecheck-and-lint.sh\"",
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

> The full list of real hook scripts and events lives in [`docs/reference/hooks-reference.md`](/docs/reference/hooks-reference). The repo ships 16+ discrete scripts under `scripts/hooks/` (e.g. `main-branch-guard.sh`, `pre-commit-tests.sh`, `command-validator.sh`, `secret-scan.sh`, `config-protection.sh`, `destructive-ops.sh`, `bash-write-guard.sh`).

## Types of hooks

### PreToolUse

Executed **before** the tool is used.

**Use cases:**
- Block certain actions
- Validate preconditions
- Check permissions

**Behavior:**
- Exit code **2** blocks the tool: it is not executed and the hook's stderr is shown to Claude
- Exit code **0** allows the tool; any other non-zero code surfaces an error but does **not** block
- Blocking scripts are wired with `"onFailure": "block"` in `.claude/settings.json`

### PostToolUse

Executed **after** the tool is used.

**Use cases:**
- Format modified code
- Type-check
- Update caches

**Behavior:**
- Executed even if the tool failed
- Does not affect the tool's result

## Structure of a hook

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/main-branch-guard.sh\"",
      "onFailure": "block"
    }
  ]
}
```

### `matcher` field

Regular expression to filter tools:

| Matcher | Description |
|---------|-------------|
| `"Edit"` | Edit only |
| `"Edit\|Write"` | Edit or Write |
| `".*"` | All tools |
| `"Bash"` | Bash only |

### `command` field

Shell command to execute. Available variables:

| Variable | Description |
|----------|-------------|
| `$FILE_PATH` | Path of the file involved |
| `$TOOL_NAME` | Name of the tool |

## Hook examples

### Protecting the main branch

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/main-branch-guard.sh\"",
            "onFailure": "block"
          }
        ]
      }
    ]
  }
}
```

`scripts/hooks/main-branch-guard.sh` (a dedicated script — exits **2** to block):

```bash
#!/bin/bash
# scripts/hooks/main-branch-guard.sh

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "BLOCKED: Cannot modify files on $BRANCH branch" >&2
  echo "Please create a feature branch first" >&2
  exit 2   # exit 2 blocks the tool; exit 1 would NOT block
fi
```

### Auto-format with Prettier

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/auto-format.sh\"",
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

`scripts/hooks/auto-format.sh` (PostToolUse reads the edited file path from the hook's stdin JSON):

```bash
#!/bin/bash
# scripts/hooks/auto-format.sh

FILE=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
  npx prettier --write "$FILE" 2>/dev/null || true
fi
```

### TypeScript type-check

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/typecheck.sh\"",
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

`scripts/hooks/typecheck.sh`:

```bash
#!/bin/bash
# scripts/hooks/typecheck.sh

FILE=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [[ "$FILE" =~ \.(ts|tsx)$ ]]; then
  npx tsc --noEmit 2>&1 | head -20 || true
fi
```

### Auto-install dependencies

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/auto-install.sh\"",
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

`scripts/hooks/auto-install.sh`:

```bash
#!/bin/bash
# scripts/hooks/auto-install.sh

FILE=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [[ "$FILE" == *"package.json" ]]; then
  npm install
fi
```

## Complete configuration

Example of a complete `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/main-branch-guard.sh\"",
            "onFailure": "block"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/auto-format.sh\"",
            "onFailure": "ignore"
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/typecheck.sh\"",
            "onFailure": "ignore"
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/auto-install.sh\"",
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

## Discrete hook scripts

There is **no single dispatcher script**. Each hook is its own small script under `scripts/hooks/`, matched by event and tool. The repo ships **16+** of them, each with one responsibility:

| Script | Event | Role |
|--------|-------|------|
| `main-branch-guard.sh` | PreToolUse (Edit/Write) | Blocks edits on `main`/`master` (exit 2) |
| `secret-scan.sh` | PreToolUse (Write/Edit/MultiEdit) | Blocks hardcoded secrets before writing |
| `command-validator.sh` | PreToolUse (Bash) | Blocks risky commands across risk categories |
| `pre-commit-tests.sh` | PreToolUse (Bash git commit) | Runs the test suite, blocks on failure |
| `destructive-ops.sh` | PreToolUse (Bash) | Blocks destructive DB/filesystem ops |
| `config-protection.sh` | PreToolUse (Edit/Write) | Blocks edits to existing linter/formatter configs |
| `bash-write-guard.sh` | PreToolUse (Bash) | Blocks Bash writes to protected/secrets files |

A PreToolUse script **blocks** the tool by exiting **2** (exit 1 does **not** block); PostToolUse scripts are advisory and wired with `"onFailure": "ignore"`. See [`docs/reference/hooks-reference.md`](/docs/reference/hooks-reference) for the full, authoritative catalogue of scripts, events and environment toggles.

## Best practices

### 1. Fast hooks

Hooks run on every tool usage. Keep them fast:

```bash
# Good - fast
npx prettier --write "$FILE"

# Bad - slow
npm run build
```

### 2. Error handling

PreToolUse hooks can block, but PostToolUse hooks should not fail loudly:

```bash
# PostToolUse - do not block
npx prettier --write "$FILE" 2>/dev/null || true
```

### 3. Clear messages

For blocking PreToolUse hooks:

```bash
echo "BLOCKED: Clear reason" >&2
echo "Solution: What the user needs to do" >&2
exit 2   # exit 2 blocks the tool; exit 1 would NOT block
```

### 4. Precise filtering

Target only the necessary tools:

```json
{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command", "command": "..." }]
}
```

## Debugging hooks

### See active hooks

```bash
cat .claude/settings.json | jq '.hooks'
```

### Test a hook manually

```bash
scripts/hooks/main-branch-guard.sh
echo $?  # 0 = allow, 2 = blocked
```

### Verbose logs

```bash
#!/bin/bash
# Add at the beginning of the script
echo "[HOOK] Action: $1, File: $2" >> /tmp/claude-hooks.log
```

---

## See also

- [Rules](./rules) - Per-file conventions
- [MCP Servers](./mcp-servers) - Extensions via MCP
- [Architecture](/docs/intro/architecture) - Overview
