---
name: git-worktrees
description: Using git worktrees for parallel development. Trigger when the user wants to work on multiple branches simultaneously, do parallel dev, or manage worktrees.
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
context: fork
---

# Git Worktrees (pointer)

> "The single biggest productivity unlock." — Boris Cherny, creator of Claude Code

Generic worktree mechanics (`git worktree add/list/remove/prune`, branch isolation, hooks sharing) are canonical at [git-scm.com/docs/git-worktree](https://git-scm.com/docs/git-worktree). This skill scopes to **Claude-Code-specific worktree integration** — what isn't in the git docs.

## Claude Code worktree settings (CLI 2.1.76+ / 2.1.141+)

Three settings in `.claude/settings.json` shape how Claude Code uses worktrees:

| Setting | Values | Purpose |
|---|---|---|
| `worktree.sparsePaths` | array of globs | Limit which files a worktree includes — speeds up monorepo operations and narrows Claude's exploration context |
| `worktree.bgIsolation` | `"auto"` (default) / `"none"` | Background sessions/agents default to writing into `.claude/worktrees/`; `"none"` lets them edit the working copy directly |
| `worktree.baseRef` | `"fresh"` / `"head"` | `"fresh"` branches new worktrees from `origin/<default>`, `"head"` from local HEAD (inherits in-progress local commits) |

Both `bgIsolation` and `baseRef` apply to `--worktree`, the `EnterWorktree` tool, and agent-isolation worktrees.

## Named-session pairing pattern

The foundation-specific workflow is **1 worktree = 1 branch = 1 named Claude session**:

```bash
git worktree add ../myapp-feature-auth -b feature/auth
cd ../myapp-feature-auth && claude -n "auth"
```

The `--name`/`-n` flag tags the session for logs and terminal identification. Combined with worktrees this lets you run 5+ Claude Code sessions in parallel without state collision — see the "Parallel Sessions" section in CLAUDE.md.

## See also

- `/work:work-explore` — dedicate an analysis worktree to read-only exploration
- `session-handoff` skill — transfer context across worktrees
- `parallel-agents` / `agent-teams` skills — orchestration on top of multi-worktree setups
