---
sidebar_position: 4
title: Installation
description: Complete installation guide for claude-base
---

# Installation

Complete guide to install and configure claude-base in your project.

## Prerequisites

### Mandatory

- **Claude Code** installed and configured
  ```bash
  claude --version
  ```

- **Git** for versioning
  ```bash
  git --version
  ```

### Recommended

- **Node.js 18+** for web projects
- **npm** or **yarn** for dependency management
- **Bats** and **ShellCheck** only if you plan to contribute to the foundation

## Installation methods

Three methods are available depending on your use case. The first is recommended.

### Method 1: One-liner install + `claude-base init` (recommended)

The foundation ships a one-liner installer that clones to `~/.local/share/claude-base/` and symlinks the `claude-base` dispatcher to `~/.local/bin/`. After install, use the CLI to drop the foundation into any project.

```bash
# 1. Install the foundation itself (one-liner, once per machine)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash

# 2. Simple installation into a project (just .claude/ + CLAUDE.md)
claude-base init --simple /path/to/your-project

# 3. Or full installation (adds hooks, MCP, .github/, CI scripts)
claude-base init --all /path/to/your-project
```

You can also run it from the project directory :

```bash
cd /path/to/your-project
claude-base init --simple .
```

The installer never modifies your shell rc files, never runs as root, and only requires `git`. If `~/.local/bin` is not on your `PATH`, the installer prints the line to add to `~/.bashrc` or `~/.zshrc`.

#### Useful options

| Flag | Effect |
|------|--------|
| `--simple` | Minimal copy: `.claude/` + `CLAUDE.md` + `.mcp.json` |
| `--all` | Full installation: adds hooks, GitHub Actions, scripts |
| `-y` | Silent mode (CI/CD) |
| `--dry-run` | Simulation without modifications |
| `--help` | Display the full help |

### Method 2: Manual copy

For fine-grained control over what is copied:

```bash
# Clone the foundation into a temporary folder
git clone --depth 1 https://github.com/christopherlouet/claude-base.git temp-base

# Copy the bare minimum
cp -r temp-base/.claude /path/to/your-project/
cp temp-base/CLAUDE.md /path/to/your-project/

# Optional
cp temp-base/.mcp.json /path/to/your-project/
cp -r temp-base/.github /path/to/your-project/

# Clean up
rm -rf temp-base
```

### Method 3: Use as a template

For a new project, the foundation can serve directly as a skeleton:

```bash
git clone https://github.com/christopherlouet/claude-base.git my-new-project
cd my-new-project

# Reinitialize the git history (optional)
rm -rf .git && git init

# Customize CLAUDE.md based on your stack
# (templates available in templates/CLAUDE.*.md)
cp templates/CLAUDE.react.md CLAUDE.md
```

## Verification

Once installed, launch Claude Code in your project:

```bash
cd /path/to/your-project
claude
```

You should see the welcome message from the `SessionStart` hook:

```
=== Claude Code Session ===
Version: <!-- version -->1.41.1<!-- /version -->
Commandes: 131
Agents: 63
===========================
```

If the numbers differ, your foundation is probably installed but on a different version — that's normal if you installed an earlier version.

### Testing commands

In Claude Code, try:

```
/assistant
```

You should see the orientation guide. Then try a simple workflow:

```
/work:work-explore .
```

## Update

```bash
# Refresh the foundation itself
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash -s -- --update

# Then re-synchronize the files in your project
claude-base update /path/to/your-project
```

`claude-base update` is idempotent : it refreshes the foundation files (commands, agents, skills, rules, scripts/hooks) without touching your customizations (`CLAUDE.md`, `.claude/settings.local.json`). Use `--clean` if you want a wipe-and-replace (a backup is created first).

## Customization

### CLAUDE.md file

The `CLAUDE.md` file at the root contains the main instructions. Adapt it to your project:

```markdown
# My Project

## Structure
- /src - Source code
- /tests - Tests

## Conventions
- TypeScript strict
- Mandatory tests

## Workflows
- /work:work-flow-feature for features
- /work:work-flow-bugfix for bugs
```

Pre-filled templates are available in `templates/CLAUDE.*.md` of the foundation (React, Next.js, Vue, Node API, Python, Go, Rust, Java, Flutter, fullstack, neovim).

### .mcp.json file

Enable MCP servers as needed. **By default, MCPs are disabled** for security reasons.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    }
  }
}
```

### Add a custom command

Create a file in `.claude/commands/`:

```markdown
---
description: My command
---

# My Custom Command

## Context
$ARGUMENTS

## Goal
Description of what the command does.

## Process
1. Step 1
2. Step 2
```

### Add a contextual rule

Create a file in `.claude/rules/`:

```markdown
---
paths:
  - "**/my-folder/**"
---

# Rules for my-folder

- Always use pure functions
- Mandatory documentation
```

## Troubleshooting

### The welcome message doesn't appear

Check the `SessionStart` hook in `.claude/settings.json`:

```bash
grep -A 3 SessionStart .claude/settings.json
```

If the hook is present but does not execute, check that the scripts in the `scripts/hooks/` folder are present and executable.

### Slash commands are not recognized

```bash
# Check that the folder exists
ls .claude/commands/

# Re-synchronize from the foundation
claude-base update .
```

### Permission errors on hooks

```bash
chmod +x .claude/scripts/*.sh scripts/hooks/*.sh
```

### Conflict with an existing configuration

```bash
# Backup + clean reinstall
claude-base uninstall --keep-claude-md .
claude-base init --simple .
```

### Full diagnosis

`doctor.sh` and `diff.sh` are foundation-internal tools (no dispatcher alias). Invoke them directly from the foundation clone :

```bash
~/.local/share/claude-base/scripts/doctor.sh /path/to/your-project
~/.local/share/claude-base/scripts/diff.sh   /path/to/your-project
```

## Next steps

- [Quick Start](/docs/intro/quick-start) - First workflow in 5 minutes
- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills vs Rules
- [Workflows](/docs/concepts/workflows) - See the detailed workflows
- [Utility scripts](/docs/reference/scripts) - All available scripts
