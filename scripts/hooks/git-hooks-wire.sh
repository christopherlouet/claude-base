#!/usr/bin/env bash
# =============================================================================
# git-hooks-wire.sh — SessionStart repair of a broken core.hooksPath
# =============================================================================
# The foundation commits .husky/, whose pre-commit regenerates and STAGES the
# derived count artifacts. When core.hooksPath does not point at it, that hook
# stops running and stale counts reach CI — the repo's top recurring failure.
#
# Why this is not folded into setup-deps.sh: that script installs dependencies
# (npm/uv/go/bundle/composer) and is registered on Setup/init with a 120s
# timeout. It must never run per session. But the two ways hooks break both
# happen AFTER init, so an init-only repair structurally cannot catch them:
#
#   fresh clone   core.hooksPath is local config, so it is not cloned. .husky/
#                 arrives with the tree, the wiring does not, and no hook runs.
#   repo moved    an ABSOLUTE core.hooksPath left over from the old location
#                 silently disables every hook once the directory is renamed.
#                 Observed live in this repo.
#
# Deliberately narrow. It repairs only unambiguous breakage:
#   unset + .husky present            -> wire it
#   set, but the path does not exist  -> repair it
#   set to some OTHER existing dir    -> LEAVE ALONE (a deliberate choice)
#
# Silent on the happy path, one line when it repairs. Always exits 0: a session
# must never fail because of this.
# =============================================================================

set -u

# Dependencies missing or not a work tree — nothing to do, quietly.
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$TOPLEVEL" ] || exit 0
[ -d "$TOPLEVEL/.husky" ] || exit 0

CURRENT=$(git config --local core.hooksPath 2>/dev/null || true)

if [ -n "$CURRENT" ]; then
    # A relative hooksPath resolves against the repo root, not the cwd.
    case "$CURRENT" in
        /*) RESOLVED="$CURRENT" ;;
        *)  RESOLVED="$TOPLEVEL/$CURRENT" ;;
    esac
    # Points somewhere real: honour it, whatever it is.
    [ -d "$RESOLVED" ] && exit 0
    REASON="stale (was: $CURRENT)"
else
    REASON="unset"
fi

git config --local core.hooksPath .husky 2>/dev/null || exit 0
echo "[INFO] git hooks were $REASON — wired to .husky (the pre-commit that keeps derived counts in sync now runs)"
exit 0
