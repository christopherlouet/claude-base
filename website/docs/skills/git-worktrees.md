---
sidebar_position: 24
title: "git-worktrees"
description: "Using git worktrees for parallel development. Trigger when the user wants to work on multiple branches simultaneously, do parallel dev, or manage worktrees."
tags:
  - "skill"
  - "fork"
---

# Skill: git-worktrees

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Using git worktrees for parallel development. Trigger when the user wants to work on multiple branches simultaneously, do parallel dev, or manage worktrees.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `git`, `worktrees`, `parallel sessions` |

## Detailed description

# Git Worktrees

> "The single biggest productivity unlock." — Boris Cherny, creator of Claude Code

## Goal

Use git worktrees to work on multiple branches simultaneously without having to switch branches. Boris uses 5+ Claude Code sessions in parallel with this technique.

## Concept

```
repo/                    # Main worktree (main)
repo-feature-auth/       # Worktree for feature/auth
repo-fix-login/          # Worktree for fix/login
repo-review-pr42/        # Worktree to review PR #42
repo-analysis/           # Worktree dedicated to analyses (read-only)
```

Each worktree is a separate folder with its own working directory, but shares the same git repo (.git).

## Setup recommended by Boris

### Shell alias configuration

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Quick navigation between worktrees
alias wa="cd ~/projects/myapp"           # Main worktree
alias wb="cd ~/projects/myapp-feature"   # Feature worktree
alias wc="cd ~/projects/myapp-fix"       # Fix worktree
alias wd="cd ~/projects/myapp-review"    # Review worktree
alias we="cd ~/projects/myapp-analysis"  # Analysis worktree

# Quick worktree creation
wtnew() {
  local name=$1
  local branch=${2:-$1}
  git worktree add "../$(basename $(pwd))-$name" -b "$branch" 2>/dev/null || \
  git worktree add "../$(basename $(pwd))-$name" "$branch"
  cd "../$(basename $(pwd))-$name"
}

# Worktree removal
wtrm() {
  local name=$1
  git worktree remove "../$(basename $(pwd))-$name"
}

# List worktrees
alias wtls="git worktree list"
```

### Terminal tab organization

Number your terminal tabs (1-5) to quickly identify each session:
- **Tab 1**: Main worktree (main/develop)
- **Tab 2**: Current feature
- **Tab 3**: Fix/bugfix
- **Tab 4**: Code review
- **Tab 5**: Analysis/research (read-only)

### Analysis worktree

A worktree dedicated to analyses lets you ask Claude questions without risking modifying the code:

```bash
# Create an analysis worktree on main
git worktree add ../myapp-analysis main

# Use for read-only queries
cd ../myapp-analysis
claude  # Session dedicated to questions/analyses
```

## Essential commands

### Create a worktree

```bash
# New branch + worktree
git worktree add ../repo-feature-auth -b feature/auth

# Existing branch
git worktree add ../repo-fix-login fix/login

# From a specific commit
git worktree add ../repo-review HEAD~5
```

### List worktrees

```bash
git worktree list
# /home/user/repo                  abc1234 [main]
# /home/user/repo-feature-auth     def5678 [feature/auth]
# /home/user/repo-fix-login        ghi9012 [fix/login]
```

### Remove a worktree

```bash
# Remove after merge
git worktree remove ../repo-feature-auth

# Force remove (uncommitted changes)
git worktree remove --force ../repo-feature-auth

# Clean up obsolete references
git worktree prune
```

## Workflows with worktrees

### Develop + Review in parallel

```bash
# Work on a feature
git worktree add ../myapp-feature -b feature/new-thing
cd ../myapp-feature
# ... develop ...

# In parallel, review a PR in another terminal
git worktree add ../myapp-review pr/42
cd ../myapp-review
# ... review the code ...
```

### Hotfix during a feature

```bash
# Situation: in the middle of dev on feature/auth
# Urgent bug in production

# Create a worktree for the hotfix (no need to stash)
git worktree add ../myapp-hotfix -b hotfix/critical-bug main
cd ../myapp-hotfix
# ... fix the bug, commit, push ...

# Return to the feature (nothing has changed)
cd ../myapp
# ... continue dev on feature/auth ...

# Clean up
git worktree remove ../myapp-hotfix
```

### Tests on multiple versions

```bash
# Test on the current AND previous version
git worktree add ../myapp-v1 v1.0.0
git worktree add ../myapp-v2 v2.0.0

# Run tests in parallel
cd ../myapp-v1 && npm test &
cd ../myapp-v2 && npm test &
wait
```

## Worktree naming convention

```
<repo>-<type>-<name>

Examples:
  myapp-feature-auth      # Feature branch
  myapp-fix-login         # Bug fix
  myapp-review-pr42       # Code review
  myapp-hotfix-critical   # Hotfix
  myapp-test-v2           # Test on a version
```

## Best practices

- One worktree per active task/branch
- Remove finished worktrees (`git worktree remove`)
- Run `git worktree prune` regularly
- Use descriptive folder names
- Do not nest worktrees inside the main repo

## Boris Cherny workflow (5+ parallel sessions)

### Full setup with named sessions (CLI 2.1.76+)

```bash
# 1. Create the worktrees
git worktree add ../myapp-feature-1 -b feature/user-auth
git worktree add ../myapp-feature-2 -b feature/payment
git worktree add ../myapp-fix -b fix/login-bug
git worktree add ../myapp-review main
git worktree add ../myapp-analysis main

# 2. Launch Claude in each worktree with --name
# Tab 1: cd ../myapp && claude -n "main"
# Tab 2: cd ../myapp-feature-1 && claude -n "auth"
# Tab 3: cd ../myapp-feature-2 && claude -n "payment"
# Tab 4: cd ../myapp-fix && claude -n "fix-login"
# Tab 5: cd ../myapp-analysis && claude -n "analysis"
```

The `--name` / `-n` flag names the session to identify it in logs and the terminal. Recommended pattern: 1 worktree = 1 branch = 1 named session.

### Key advantages

| Advantage | Description |
|-----------|-------------|
| No stash | Each worktree has its own state |
| Preserved context | Each Claude session keeps its history |
| Real parallelism | Work on 5 tasks simultaneously |
| Isolation | A bug in one session does not affect the others |
| Separate analysis | Ask questions without risking modifications |

### Combination with claude.ai/code

Boris also uses 5-10 sessions on claude.ai/code in parallel:
- Transfer local sessions to web with `&` (teleport)
- Web sessions for long tasks
- Local sessions for quick editing

### Notifications

Enable system notifications to know when Claude needs input:
```bash
# macOS
osascript -e 'display notification "Claude needs input" with title "Claude Code"'

# Linux (notify-send)
notify-send "Claude Code" "Claude needs input"
```

## Sparse Paths for Monorepos (CLI 2.1.76+)

`worktree.sparsePaths` configuration to limit the files included in a worktree. Useful for large monorepos:

```json
// In .claude/settings.json
{
  "worktree": {
    "sparsePaths": [
      "packages/frontend/**",
      "packages/shared/**",
      "package.json",
      "tsconfig.json"
    ]
  }
}
```

Examples of common configurations:

| Context | sparsePaths |
|---------|-------------|
| Frontend only | `packages/frontend/**`, `packages/shared/**`, `*.json` |
| Backend only | `packages/api/**`, `packages/shared/**`, `*.json` |
| Full-stack | `packages/frontend/**`, `packages/api/**`, `packages/shared/**` |

Advantages: faster operations, less noise in exploration, more targeted Claude Code context.

## Background isolation tuning (CLI 2.1.141+ / 2.1.142+)

When background sessions or agents write to disk, the runtime defaults to moving them into an isolated worktree under `.claude/worktrees/`. Two settings let you override this for repos where worktrees are impractical or where the branch base needs to be explicit:

```json
// In .claude/settings.json
{
  "worktree": {
    "bgIsolation": "none",
    "baseRef": "head"
  }
}
```

| Setting | Values | Behavior |
|---|---|---|
| `worktree.bgIsolation` | `"auto"` (default) / `"none"` | `"none"` lets background sessions edit the working copy directly — opt-in escape hatch for repos where the auto-isolation breaks tooling. |
| `worktree.baseRef` | `"fresh"` / `"head"` | `"fresh"` branches new worktrees from `origin/<default>` (the upstream tip), `"head"` from local HEAD. Use `"head"` when you want background sessions to inherit your in-progress local commits. |

Both apply to `--worktree`, the `EnterWorktree` tool, and agent-isolation worktrees.

## Limitations

- A branch can only be used in ONE worktree at a time
- Hooks are shared across all worktrees
- Submodules may require a `git submodule update` in each worktree

## See also

- "Parallel Sessions" section in CLAUDE.md
- `/work:work-explore` for code exploration
- `/session-handoff` for context transfer between sessions

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to git..."_
- _"I want to worktrees..."_
- _"I want to parallel sessions..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
