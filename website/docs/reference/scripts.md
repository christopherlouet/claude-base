---
sidebar_position: 4
title: Scripts
description: Catalog of claude-base utility scripts
---

import Stats from '@site/src/components/Stats';

# Utility Scripts

> **14 scripts** to install, configure and maintain claude-base

<Stats items={[
  { number: 14, label: 'Scripts' },
  { number: 5, label: 'Categories' },
]} />

## Overview

The scripts are organized into 5 categories:

| Category | Scripts | Description |
|-----------|---------|-------------|
| **Installation** | `new-project.sh` | Install the foundation |
| **Maintenance** | `update.sh`, `diff.sh`, `uninstall.sh`, `check-updates.sh` | Maintain the foundation |
| **Diagnostic** | `doctor.sh`, `validate.sh`, `validate-counts.sh` | Verify the installation |
| **Tools** | `ide.sh` | IDE configuration |
| **Internal** | `lint.sh`, `test.sh`, `bump-version.sh`, `audit-base.sh`, `export-minimal.sh` | CI and foundation maintenance |

---

## Installation Scripts

### new-project.sh

Installs the foundation in a new or existing project. **User-facing CLI: `claude-base init`** (alias for this script — same args, dispatched via `bin/claude-base`).

```bash
# Quick install of the foundation itself (recommended)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash

# Then, to install the foundation into a project:
claude-base init [OPTIONS] [PATH]
```

**Main options:**

| Option | Description |
|--------|-------------|
| `-t, --type TYPE` | Project type (react, vue, node-api, python, go, flutter) |
| `-n, --name NAME` | Project name |
| `--cicd` | Include CI/CD workflows |
| `--hooks` | Include Git hooks |
| `--mcp` | Include MCP configuration |
| `--docker` | Include Docker configuration |
| `-y, --yes` | Non-interactive mode |

**Example:**

```bash
# New React project with CI/CD
claude-base init -t react -n my-app --cicd --hooks

# Configure an existing project
cd my-existing-project
claude-base init --cicd --hooks
```

**Direct script access (advanced)** — from a foundation clone, `./scripts/new-project.sh [OPTIONS] [PATH]` is equivalent.

**Features:**
- Automatic project type detection
- Analysis of existing CI/CD with improvement suggestions
- Claude Code hooks configuration
- Dependency installation

---

## Maintenance Scripts

### update.sh

Updates commands, agents, skills and rules from the foundation. **User-facing CLI: `claude-base update`**.

```bash
claude-base update [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `-f, --force` | Force update (overwrites local changes) |
| `--backup` | Create a backup only |
| `--settings` | Update settings.json |
| `--skills` | Update skills only |
| `--agents` | Update agents only |
| `--rules` | Update rules only |
| `--clean` | Clean before update |
| `--orphans` | Detect orphan files |
| `--remove-orphans` | Remove orphan files |

**Example:**

```bash
# Standard update
claude-base update

# Forced update with cleanup
claude-base update --force --clean

# Update skills only
claude-base update --skills
```

**Direct script access (advanced)** — `./scripts/update.sh [OPTIONS] [PATH]` is equivalent.

---

### check-updates.sh

Checks for available updates for Claude Code CLI and community skills.

```bash
./scripts/check-updates.sh [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--json` | JSON output format |
| `--quiet` | Silent mode (only if updates available) |
| `--force` | Ignore cache (24h TTL by default) |
| `--no-cli` | Do not check Claude Code CLI |
| `--no-skills` | Do not check skills.sh |
| `--timeout N` | Network timeout in seconds (default: 10) |

**Return codes:**

| Code | Meaning |
|------|---------------|
| 0 | Everything is up to date |
| 1 | Updates available |
| 2 | Error during check |

**Example:**

```bash
# Full check
./scripts/check-updates.sh

# JSON output for CI/CD
./scripts/check-updates.sh --json

# CLI only, no cache
./scripts/check-updates.sh --no-skills --force
```

---

### diff.sh

Compares the local configuration with the foundation to identify differences.

```bash
./scripts/diff.sh [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--show new` | Show only new files |
| `--show modified` | Show only modified files |
| `--show deleted` | Show only deleted files |
| `--content` | Show the content of differences |
| `--no-color` | Disable colors |

**Example:**

```bash
# See all differences
./scripts/diff.sh

# See only local modifications
./scripts/diff.sh --show modified --content
```

**Output:**

```
📊 Comparison with the claude-base foundation

New files (local):              2
Modified files:                 5
Deleted files:                  0
Identical files:               98
```

---

### uninstall.sh

Removes the Claude Code configuration from a project. **User-facing CLI: `claude-base uninstall`**.

```bash
claude-base uninstall [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--keep-claude-md` | Keep the CLAUDE.md file |
| `--no-backup` | Do not create a backup |
| `-f, --force` | Remove without confirmation |
| `--remove-local` | Also remove local files |

**Example:**

```bash
# Uninstall with backup (default)
claude-base uninstall

# Full uninstall
claude-base uninstall --force --no-backup
```

**Direct script access (advanced)** — `./scripts/uninstall.sh [OPTIONS] [PATH]` is equivalent.

:::caution
By default, a backup is created in `.claude-backup-YYYYMMDD-HHMMSS/`.
:::

---

## Diagnostic Scripts

### doctor.sh

Full diagnostic of the Claude Code environment.

```bash
./scripts/doctor.sh [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--fix` | Attempt to fix detected issues |
| `--json` | JSON output format |

**Checks performed:**

| Check | Description |
|-------|-------------|
| Claude Code | Version and installation |
| Git | Configuration and version |
| Node.js | Version (if JS/TS project) |
| .claude folder | Presence and permissions |
| settings.json | JSON validity |
| Hooks | Hooks configuration |
| MCP | Configured MCP servers |

**Example:**

```bash
# Full diagnostic
./scripts/doctor.sh

# Diagnostic with automatic fixes
./scripts/doctor.sh --fix
```

**Output:**

```
🏥 Claude Code Diagnostic

✓ Claude Code installed (v1.0.0)
✓ Git configured
✓ Node.js 20.x
✓ .claude folder present
⚠ settings.json: missing hook
✗ MCP: github server not configured

Result: 4 OK, 1 warning, 1 error
```

---

### validate.sh

Validates the Claude Code configuration and computes a quality score. **User-facing CLI: `claude-base validate`**.

```bash
claude-base validate [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--json` | JSON output format |
| `--score` | Show only the score |

**Special actions (used internally by hooks, not user-facing):**

```bash
# These subcommands are invoked by hook scripts in .claude/settings.json
# and call validate.sh directly. Users do NOT invoke them via claude-base.
./scripts/validate.sh protect-main
./scripts/validate.sh auto-format $FILE_PATH
./scripts/validate.sh typecheck $FILE_PATH
./scripts/validate.sh auto-install $FILE_PATH
./scripts/validate.sh session-start
```

**Example:**

```bash
# Full validation
claude-base validate

# Score only
claude-base validate --score
# Output: 85
```

**Direct script access (advanced)** — `./scripts/validate.sh [OPTIONS] [PATH]` is equivalent.

---

## Tool Scripts

### ide.sh

Configures IDEs for optimal integration with claude-base.

```bash
./scripts/ide.sh <setup|check|remove> <ide> [OPTIONS] [PATH]
```

**Supported IDEs:**

| IDE | Command | Generated files |
|-----|----------|------------------|
| VSCode | `vscode` | settings.json, tasks.json, extensions.json, snippets |
| Cursor | `cursor` | Same as VSCode |
| IntelliJ | `idea` | run configurations, code style, templates |
| Vim/Neovim | `vim` | abbreviations, mappings, autocmds |
| All | `all` | Configures all detected IDEs |

**Commands:**

| Command | Description |
|----------|-------------|
| `setup` | Configure the IDE |
| `check` | Verify the configuration |
| `remove` | Remove the configuration |

**Options:**

| Option | Description |
|--------|-------------|
| `-n, --dry-run` | Simulate without modifying |
| `-f, --force` | Overwrite existing files |

**Example:**

```bash
# Configure VSCode
./scripts/ide.sh setup vscode

# Verify IntelliJ configuration
./scripts/ide.sh check idea

# Remove Vim configuration
./scripts/ide.sh remove vim

# Configure all detected IDEs
./scripts/ide.sh setup all
```

---

---

## Internal Scripts

### lint.sh

Validates the code quality of the foundation itself (used by CI).

```bash
./scripts/lint.sh
```

### test.sh

Runs the foundation's tests (bats tests).

```bash
./scripts/test.sh
```

### bump-version.sh

Updates the foundation's version (`VERSION`, badges, references).

```bash
./scripts/bump-version.sh <new-version>
```

### audit-base.sh

Full structural audit: detects orphan files, broken references, inconsistencies between the foundation and the documentation.

```bash
./scripts/audit-base.sh
```

### export-minimal.sh

Exports a minimal configuration of the foundation as a `.tar.gz` archive (or copies directly to a target folder). Used internally by `claude-base init --minimal` for projects that only want a subset of the foundation.

```bash
# Default archive (dist/claude-base-minimal.tar.gz)
./scripts/export-minimal.sh

# Archive with custom path
./scripts/export-minimal.sh --output /tmp/claude-base.tar.gz

# Direct copy to a folder (no archive)
./scripts/export-minimal.sh --dest-dir /path/project
```

The manifest of included files is defined in `scripts/lib/minimal-manifest.txt`.

---

## Installing the foundation itself (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
```

This clones the foundation to `~/.local/share/claude-base/` and symlinks the `claude-base` dispatcher into `~/.local/bin/`. After that, all the user-facing commands below are available on your PATH.

---

## Summary

| Script | User-facing CLI | Main usage |
|--------|-----------------|------------|
| `new-project.sh` | `claude-base init` | Create/configure a project |
| `update.sh` | `claude-base update` | Update an installed project |
| `validate.sh` | `claude-base validate` | Validate config |
| `uninstall.sh` | `claude-base uninstall` | Uninstall the foundation |
| `check-updates.sh` | _(no alias)_ — `./scripts/check-updates.sh` | Check for updates |
| `diff.sh` | _(no alias)_ — `./scripts/diff.sh` | Compare with the foundation |
| `doctor.sh` | _(no alias)_ — `./scripts/doctor.sh --fix` | Diagnose |
| `ide.sh` | _(no alias)_ — `./scripts/ide.sh setup vscode` | Configure IDEs |
