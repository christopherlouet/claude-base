# GITFLOW Agent

Manage the GitFlow branching model: init, feature, release and hotfix branches.

## Request context
$ARGUMENTS

## Goal

Drive a GitFlow workflow on the repository — initialise the model, then manage
feature, release and hotfix branches with the correct merges, tags and back-merges.

> GitFlow is mutually exclusive with the foundation's default trunk-ish flow
> (`feature/` off `main`, rebase, squash — see `.claude/rules/git.md`). Use this
> opt-in module only on projects that have chosen GitFlow.

## Usage

`/ops:ops-gitflow <init|feature|release|hotfix> [action] [name|version]`

Dispatch on the first argument (the sub-command); the second is the action
(`start` / `finish` / `list` / …). Check prerequisites (git repo, clean tree,
up-to-date branches) before every operation.

### init

- Check prerequisites (git repo, current branch, uncommitted changes).
- Create the `develop` branch from `main` if it does not exist, push it to the remote.
- Recommend branch protection for `main` and `develop`.
- Output: configured branches (`main` = production, `develop` = integration),
  prefixes (`feature/`, `release/`, `hotfix/`), the table of sub-commands, and the
  recommended workflow (feature → develop → release → main).

### feature — actions: `start` | `finish` | `list` | `publish` | `pull`

- **start**: create `feature/xxx` from an up-to-date `develop`, push the branch.
- **finish**: merge `--no-ff` into `develop`, delete the local and remote branch.
- **list**: list ongoing feature branches.
- **publish**: push the feature branch to the remote.
- **pull**: fetch a remote feature branch.
- Use kebab-case for branch naming.

### release — actions: `start` | `finish` | `list`

- **start**: create `release/vX.Y.Z` from `develop`, push the branch.
- **finish**: merge into `main`, create the tag, back-merge into `develop`, delete the branch.
- **list**: list release branches and existing tags.
- Follow semantic versioning (MAJOR.MINOR.PATCH). Preparation checklist: bump
  version, changelog, tests. No new features on a release branch.

### hotfix — actions: `start` | `finish` | `list`

- **start**: create `hotfix/xxx` from `main`, push the branch.
- **finish**: merge into `main`, create the PATCH tag, merge into `develop` (and the
  current `release` branch if one exists), delete the branch.
- **list**: list ongoing hotfixes.
- The fix must be minimal and targeted (only the bug). Automatic PATCH bump if not specified.

## Related commands

| Command | Usage |
|---------|-------|
| `/doc:doc-changelog` | Generate the changelog before a release |
| `/qa:qa-audit` | Quality audit before a release |
| `/dev:dev-debug` | Investigate the bug before a hotfix |
| `/ops:ops-hotfix` | Simplified urgent fix (default trunk flow, non-GitFlow) |
| `/work:work-flow-bugfix` | Non-critical bug |

---

IMPORTANT: Check that the repo is clean before any GitFlow operation.

YOU MUST use `--no-ff` for feature merges to preserve history.

YOU MUST merge a release/hotfix into BOTH `main` AND `develop` (and `release` if it
exists, for a hotfix), and create the tag on `main`.

A hotfix ALWAYS starts from `main`; a feature or release ALWAYS starts from `develop`.

NEVER add features on a release branch.

NEVER force push or delete branches without confirmation, and NEVER force push to `develop`.
