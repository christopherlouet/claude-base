# GIT-RENAME Command

Renames the current branch (typically a `feature/auto-*` branch created by the PreToolUse hook).

## Context
$ARGUMENTS

## Goal

Give a descriptive name to an auto-generated branch (or simply rename the current branch), locally and on the remote if it has already been pushed.

## Usage

```
/git-rename <new-name>
```

Examples:

```
/git-rename feature/git-rename-command
/git-rename fix/login-redirect
/git-rename refactor/api-client
```

The prefix (`feature/`, `fix/`, `refactor/`...) is optional: if absent, `feature/` is added by default.

## Workflow

1. **Check the state**
    - Read the current branch (`git rev-parse --abbrev-ref HEAD`)
    - Refuse if the branch is `main` or `master` (impossible to rename in place without confusion)
    - Check that the new name is valid (no spaces, no git-special characters)
2. **Rename locally**
    - `git branch -m <new-name>`
3. **Sync the remote (if the branch has been pushed)**
    - Detect the upstream (`git rev-parse --abbrev-ref --symbolic-full-name @{u}`)
    - If upstream exists: `git push origin :<old-name> <new-name>` then `git push origin -u <new-name>`
    - Otherwise: no push, just a message indicating that the branch is local
4. **Confirm**
    - Display the new branch and its remote tracking

## Expected output

- Branch renamed locally (and on the remote if applicable)
- `git status` + `git branch -vv` confirmation to verify tracking
- If a PR already exists on the old branch, warn the user that they must update it manually (GitHub does not follow a branch rename)

## Special cases

| Situation | Action |
|-----------|--------|
| `main`/`master` branch | REFUSE, explain why |
| New name == current name | Do nothing, informative message |
| New name already exists locally | REFUSE, suggest another name |
| No upstream | Rename locally only |
| PR open on the old branch | Rename + WARN: the PR points to a branch that no longer exists, manual action required |

---

IMPORTANT: NEVER delete the old remote branch before having pushed the new one (use `git push origin :old new` in a single command to stay atomic on the remote side).

NEVER rename `main` or `master`.

YOU MUST check the presence of an upstream before attempting a push.
