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

### Method 1: `new-project.sh` script (recommended)

The foundation exposes a single script that copies the `.claude/` configuration, `CLAUDE.md` and the necessary files into your existing project or into a new project.

```bash
# 1. Clone the foundation (just once, anywhere)
git clone https://github.com/christopherlouet/claude-base.git ~/.claude-base

# 2. Simple installation (just .claude/ + CLAUDE.md)
~/.claude-base/scripts/new-project.sh --simple /path/to/your-project

# 3. Or full installation (adds hooks, MCP, .github/, CI scripts)
~/.claude-base/scripts/new-project.sh --all /path/to/your-project
```

You can also run the script from your project:

```bash
cd /path/to/your-project
~/.claude-base/scripts/new-project.sh --simple .
```

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
Version: <!-- version -->1.39.0<!-- /version -->
Commandes: <!-- count:commands -->131<!-- /count -->
Agents: <!-- count:agents -->63<!-- /count -->
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
# Update the local foundation
cd ~/.claude-base
git pull origin main

# Re-synchronize the files in your project
~/.claude-base/scripts/update.sh /path/to/your-project
```

The `update.sh` script is idempotent: it updates the foundation files (commands, agents, skills, rules, scripts/hooks) without touching your customizations (`CLAUDE.md`, `.claude/settings.local.json`).

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
~/.claude-base/scripts/update.sh .
```

### Permission errors on hooks

```bash
chmod +x .claude/scripts/*.sh scripts/hooks/*.sh
```

### Conflict with an existing configuration

```bash
# Backup + clean reinstall
./scripts/uninstall.sh --keep-claude-md .
~/.claude-base/scripts/new-project.sh --simple .
```

### Full diagnosis

```bash
~/.claude-base/scripts/doctor.sh /path/to/your-project
~/.claude-base/scripts/diff.sh   /path/to/your-project
```

## Next steps

- [Quick Start](/docs/intro/quick-start) - First workflow in 5 minutes
- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills vs Rules
- [Workflows](/docs/concepts/workflows) - See the detailed workflows
- [Utility scripts](/docs/reference/scripts) - All available scripts
