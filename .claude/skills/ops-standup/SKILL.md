---
name: ops-standup
description: Cross-repo morning briefing. Aggregation of recent commits, PRs, CI, blockers and priorities of the day. Trigger when the user wants a standup, an activity summary, or to know what happened.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
model: sonnet
argument-hint: "[repo-paths] [--since 24h] [--summary-only]"
---

# Daily Standup — Morning Briefing

## Objective

Scan one or several git repos to generate a structured briefing:
recent commits, open PRs, CI state, blockers and priorities of the day.

Read-only mode — no code modification.

## Phase 1: Repo detection

### Determine the repos to scan

1. If paths are provided as arguments: use them
2. If a parent directory is provided: scan 1 level for `.git/`
3. Otherwise: use the current directory

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--since <duration>` | `24h` | Time window (24h, 48h, 7d) |
| `--summary-only` | no | Short version without per-repo details |

## Phase 2: Data collection

For each repo, collect:

### 2.1 Recent commits

```bash
# Commits from the last 24h grouped by author
git log --since="24 hours ago" --format="%h %an: %s" --no-merges
```

Group by author, count commits, identify types (feat/fix/refactor/docs).

### 2.2 Pull Requests and CI

If `gh` is available:

```bash
# Open PRs
gh pr list --state open --json number,title,author,reviewDecision,statusCheckRollup

# Recently merged PRs
gh pr list --state merged --json number,title,mergedAt --limit 10
```

Classify the PRs:
- **To review**: reviewDecision = REVIEW_REQUIRED
- **Approved**: reviewDecision = APPROVED (ready to merge)
- **CI failing**: statusCheckRollup contains FAILURE
- **Pending**: statusCheckRollup contains PENDING

### 2.3 CI state

If `gh` is available:

```bash
# Latest workflow runs
gh run list --limit 10 --json status,conclusion,name,createdAt
```

Identify:
- Failing workflows (conclusion = failure)
- Stuck workflows (status = in_progress for > 30 min)
- Recently cancelled workflows

### 2.4 Stale branches

```bash
# Branches with no commit for 7+ days (excluding main/develop/release)
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ | grep -E "(weeks|months) ago"
```

### 2.5 Uncommitted changes

```bash
git status --porcelain
```

Categorize: staged, unstaged, untracked.

## Phase 3: Synthesis

Aggregate the data into 4 categories:

### What has been done
- Features delivered (feat commits)
- Bugs fixed (fix commits)
- Merged PRs

### What is in progress
- Open PRs and their state
- Active branches with recent commits

### What is blocked
- PRs with failing CI
- Stuck or failing workflows
- PRs awaiting review for > 48h

### Suggested priorities
- Approved PRs to merge
- CI failures to fix
- Pending reviews
- Stale branches to clean up

## Phase 4: Output

### Technical view (default)

```markdown
# Standup — YYYY-MM-DD

## [repo-name]

### Activity (last 24h)
- X commits by Y authors
- Z PRs merged, W open

### Recent commits
| Author | Commits | Summary |
|--------|---------|--------|
| [name] | N | feat: ..., fix: ... |

### Pull Requests
| # | Title | Status | CI |
|---|-------|--------|-----|
| #123 | ... | To review | Passing |

### CI Health
| Workflow | Last run | Status |
|----------|------------|--------|
| ci.yml | 2h ago | Passing |

### Alerts
- [!] PR #456 with failing CI for 12h
- [!] Branch feature/old inactive for 3 weeks

---

## Cross-Repo Synthesis

### To do today
1. [High priority] ...
2. [Medium priority] ...

### Metrics
- Features delivered: X
- PRs to handle: Y
- CI failures: Z
- Stale branches: W
```

### Summary view (`--summary-only`)

```markdown
# Standup Summary — YYYY-MM-DD

Yesterday: X features delivered, Y bugs fixed, Z PRs merged.
Today: W PRs to review, V CI failures to fix.
Blockers: [list or "none"].
```

## Graceful degradation

| Missing tool | Impact | Fallback |
|----------------|--------|----------|
| `gh` not installed | No PRs nor CI | Signal it, show only commits |
| Remote repo unreachable | No remote status | Use local data |
| No recent commits | Empty section | Indicate "No activity" |

## Rules

- ALWAYS use read-only commands (git log, git status, gh pr list)
- NEVER modify files, branches, or PRs
- NEVER invent data — if a source is unavailable, signal it
- Clearly indicate data gaps
- If `gh` is not available, mention it and show what is available
