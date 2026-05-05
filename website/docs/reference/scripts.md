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

Main script to create a new project or configure an existing project.

```bash
# Quick install (recommended)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/new-project.sh | bash

# Or from the cloned foundation
./scripts/new-project.sh [OPTIONS] [PATH]
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
./scripts/new-project.sh -t react -n my-app --cicd --hooks

# Configure an existing project
cd my-existing-project
./scripts/new-project.sh --cicd --hooks
```

**Features:**
- Automatic project type detection
- Analysis of existing CI/CD with improvement suggestions
- Claude Code hooks configuration
- Dependency installation

---

## Maintenance Scripts

### update.sh

Updates commands, agents, skills and rules from the foundation.

```bash
# Quick update
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/update.sh | bash

# Or from the cloned foundation
./scripts/update.sh [OPTIONS] [PATH]
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
./scripts/update.sh

# Forced update with cleanup
./scripts/update.sh --force --clean

# Update skills only
./scripts/update.sh --skills
```

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

Removes the Claude Code configuration from a project.

```bash
./scripts/uninstall.sh [OPTIONS] [PATH]
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
./scripts/uninstall.sh

# Full uninstall
./scripts/uninstall.sh --force --no-backup
```

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

Validates the Claude Code configuration and computes a quality score.

```bash
./scripts/validate.sh [OPTIONS] [PATH]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--json` | JSON output format |
| `--score` | Show only the score |

**Special actions (used by hooks):**

```bash
# Protect the main branch
./scripts/validate.sh protect-main

# Auto-format
./scripts/validate.sh auto-format $FILE_PATH

# Type check
./scripts/validate.sh typecheck $FILE_PATH

# Auto-install dependencies
./scripts/validate.sh auto-install $FILE_PATH

# Session message
./scripts/validate.sh session-start
```

**Example:**

```bash
# Full validation
./scripts/validate.sh

# Score only
./scripts/validate.sh --score
# Output: 85
```

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

Exports a minimal configuration of the foundation as a `.tar.gz` archive (or copies directly to a target folder). Used by `new-project.sh --minimal` for projects that only want a subset of the foundation.

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

## Usage with curl

Several scripts can be run directly from GitHub:

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/new-project.sh | bash

# Update
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/update.sh | bash

# With options (requires downloading first)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/scripts/new-project.sh -o /tmp/new-project.sh
chmod +x /tmp/new-project.sh
/tmp/new-project.sh --cicd --hooks
```

---

## Summary

| Script | Main usage | Quick command |
|--------|-----------------|-----------------|
| `new-project.sh` | Create/configure a project | `curl ... \| bash` |
| `update.sh` | Update | `curl ... \| bash` |
| `check-updates.sh` | Check for updates | `./scripts/check-updates.sh` |
| `diff.sh` | Compare with the foundation | `./scripts/diff.sh` |
| `uninstall.sh` | Uninstall | `./scripts/uninstall.sh` |
| `doctor.sh` | Diagnose | `./scripts/doctor.sh --fix` |
| `validate.sh` | Validate config | `./scripts/validate.sh` |
| `ide.sh` | Configure IDEs | `./scripts/ide.sh setup vscode` |
