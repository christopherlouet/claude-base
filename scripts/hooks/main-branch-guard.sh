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
# Disable with ALLOW_MAIN_EDIT=1 (edit main/master intentionally).
# =============================================================================
set -euo pipefail

[ "${ALLOW_MAIN_EDIT:-0}" = "1" ] && exit 0

# No git → nothing to guard (a non-repo project edits freely).
command -v git >/dev/null 2>&1 || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
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
