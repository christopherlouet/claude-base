#!/usr/bin/env bash
# =============================================================================
# main-branch-guard.sh — PreToolUse hook (Edit|Write).
#
# Keeps edits off main/master: when the working tree is on main/master, it
# auto-creates a fresh `feature/auto-<timestamp>` branch and switches to it so
# the edit lands there instead. Extracted from an inline settings.json
# `bash -c` gate (which shipped with ZERO test coverage) and fixed:
#
#   the inline version ran `git checkout -b … 2>/dev/null` then unconditionally
#   `exit 0`, so if branch creation FAILED (detached HEAD, name collision,
#   read-only repo) the edit proceeded on main anyway — exactly what the guard
#   exists to prevent. This version BLOCKS (exit 2) when the auto-branch cannot
#   be created.
#
# It also looks at WHAT is being edited. The guard fires on the tool, not on the
# path, so editing a file outside the working tree — a dotfile in $HOME, another
# project — used to branch this repo for a change it will never contain, leaving
# an empty `feature/auto-…` for the user to notice and delete. A guard that
# reacts to what it does not guard is one the user learns to ignore.
#
# Payload arrives on STDIN as JSON; the target is .tool_input.file_path (Edit,
# Write, MultiEdit) or .tool_input.notebook_path (NotebookEdit). An UNREADABLE
# target (no jq, no path, unparseable) keeps the old behaviour and guards
# anyway: this hook fails toward protecting main, never toward an edit landing
# on it silently.
#
# Disable with ALLOW_MAIN_EDIT=1 (edit main/master intentionally).
# =============================================================================
set -euo pipefail

[ "${ALLOW_MAIN_EDIT:-0}" = "1" ] && exit 0

# No git → nothing to guard (a non-repo project edits freely).
command -v git >/dev/null 2>&1 || exit 0

# abs_path <path> — absolute, symlink-free, WITHOUT requiring the path to exist
# (a Write creates its target, and `..` must be resolved rather than compared
# textually). Walk up to the deepest existing ancestor, resolve that with
# `cd -P`, then re-append the tail.
#
# A relative path is resolved against $PWD, NEVER against CLAUDE_PROJECT_DIR:
# the repository this hook reasons about is the one at $PWD (that is where
# `git rev-parse --show-toplevel` and the branch switch happen). Resolving the
# target against a different root places an IN-repo path outside it whenever
# the two diverge — a worktree, a sub-repo, a second project — and the guard
# then falls silent on exactly the edit it exists to catch. Fail-open, so the
# two references must be the same one.
abs_path() {
  _p=$1 _tail="" _parent=""
  case "$_p" in
    /*) ;;
    *) _p="$PWD/$_p" ;;
  esac
  while [ ! -d "$_p" ]; do
    _tail="$(basename "$_p")${_tail:+/$_tail}"
    _parent=$(dirname "$_p")
    [ "$_parent" = "$_p" ] && break
    _p=$_parent
  done
  [ -d "$_p" ] || return 1
  _p=$(cd "$_p" 2>/dev/null && pwd -P) || return 1
  printf '%s' "${_p%/}${_tail:+/$_tail}"
}

# Is the edit aimed somewhere this repository will never track? Unknown → no.
# Reads stdin, so it must be called at most once — and only on main/master,
# which is why the envelope is never even read off a feature branch. Exiting
# without draining stdin is already this hook's normal path (ALLOW_MAIN_EDIT
# and the no-git case both do it).
target_is_outside_repo() {
  command -v jq >/dev/null 2>&1 || return 1
  _file=$(cat 2>/dev/null |
    jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null ||
    true)
  [ -n "$_file" ] || return 1

  _top=$(git rev-parse --show-toplevel 2>/dev/null || true)
  [ -n "$_top" ] || return 1
  _top=$(cd "$_top" 2>/dev/null && pwd -P) || return 1

  _abs=$(abs_path "$_file") || return 1
  # Quoted patterns: a path is a literal here, never a glob. The trailing `/`
  # keeps a sibling that merely shares a prefix (repo-notes vs repo) outside.
  case "$_abs" in
    "$_top" | "$_top"/*) return 1 ;;
    *) return 0 ;;
  esac
}

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  # Scoping is checked HERE, not before the branch test: off main — the common
  # case — the answer is discarded, and a Write envelope carries the file's
  # whole content, so parsing it would cost a multi-megabyte jq pass on every
  # large edit. This hook runs with timeout 5000 and onFailure "block", so
  # wasted work is not merely slow: it is a way for a legitimate edit to be
  # refused. Same semantics, none of the cost.
  target_is_outside_repo && exit 0

  NEW_BRANCH="feature/auto-$(date +%Y%m%d-%H%M%S)"
  if git checkout -b "$NEW_BRANCH" 2>/dev/null; then
    echo "Branch $NEW_BRANCH created automatically (you were on $BRANCH)."
    echo "Tip: rename it with git branch -m feature/descriptive-name"
    exit 0
  fi
  # Branch creation failed — do NOT let the edit land on main/master.
  echo >&2 "BLOCKED: on $BRANCH and could not auto-create a feature branch ($NEW_BRANCH)."
  echo >&2 "Create one manually (git checkout -b feature/…) or set ALLOW_MAIN_EDIT=1 to edit $BRANCH intentionally."
  exit 2
fi

exit 0
