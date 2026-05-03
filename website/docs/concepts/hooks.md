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
│  │ Command: scripts/validate.sh protect   │                    │
│  │                                        │                    │
│  │ → Checks we are not on main            │                    │
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
│  │ Command: scripts/validate.sh format    │                    │
│  │                                        │                    │
│  │ → Automatically formats the file       │                    │
│  └────────────────────────────────────────┘                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh protect-main"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      }
    ]
  }
}
```

## Types of hooks

### PreToolUse

Executed **before** the tool is used.

**Use cases:**
- Block certain actions
- Validate preconditions
- Check permissions

**Behavior:**
- If the hook fails (exit code != 0), the tool is not executed
- The error message is shown to the user

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
  "command": "scripts/validate.sh action $FILE_PATH"
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
        "command": "scripts/validate.sh protect-main"
      }
    ]
  }
}
```

`scripts/validate.sh` script:

```bash
#!/bin/bash

case "$1" in
  protect-main)
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
      echo "BLOCKED: Cannot modify files on $BRANCH branch"
      echo "Please create a feature branch first"
      exit 1
    fi
    ;;
esac
```

### Auto-format with Prettier

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  auto-format)
    FILE="$2"
    if [[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
      npx prettier --write "$FILE" 2>/dev/null
    fi
    ;;
esac
```

### TypeScript type-check

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh typecheck $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  typecheck)
    FILE="$2"
    if [[ "$FILE" =~ \.(ts|tsx)$ ]]; then
      npx tsc --noEmit 2>&1 | head -20
    fi
    ;;
esac
```

### Auto-install dependencies

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-install $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  auto-install)
    FILE="$2"
    if [[ "$FILE" == *"package.json" ]]; then
      npm install
    fi
    ;;
esac
```

## Complete configuration

Example of a complete `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh protect-main"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      },
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh typecheck $FILE_PATH"
      },
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-install $FILE_PATH"
      }
    ]
  }
}
```

## Unified validation script

A single script for all hooks:

```bash
#!/bin/bash
# scripts/validate.sh

set -e

case "$1" in
  protect-main)
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
      echo "BLOCKED: Cannot modify files on $BRANCH"
      exit 1
    fi
    ;;

  auto-format)
    FILE="$2"
    if [[ -n "$FILE" && "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
      npx prettier --write "$FILE" 2>/dev/null || true
    fi
    ;;

  typecheck)
    FILE="$2"
    if [[ -n "$FILE" && "$FILE" =~ \.(ts|tsx)$ ]]; then
      npx tsc --noEmit 2>&1 | head -20 || true
    fi
    ;;

  auto-install)
    FILE="$2"
    if [[ "$FILE" == *"package.json" ]]; then
      npm install
    fi
    ;;

  *)
    echo "Unknown action: $1"
    exit 1
    ;;
esac
```

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
echo "BLOCKED: Clear reason"
echo "Solution: What the user needs to do"
exit 1
```

### 4. Precise filtering

Target only the necessary tools:

```json
{
  "matcher": "Edit|Write",  // Not ".*"
  "command": "..."
}
```

## Debugging hooks

### See active hooks

```bash
cat .claude/settings.json | jq '.hooks'
```

### Test a hook manually

```bash
scripts/validate.sh protect-main
echo $?  # 0 = OK, 1 = blocked
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
