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
#   ABSOLUTE path to this repo's .husky, and .husky is TRACKED
#                                     -> make it relative (.husky): it works
#                 today and is the repo-moved breakage on the next rename.
#                 The config is shared by all linked worktrees while a relative
#                 path resolves per worktree, so only a tracked dir is a safe
#                 target: an untracked one (.localhooks, husky v9's .husky/_)
#                 is missing in a worktree, whose next session would rewire the
#                 shared value and take over the main checkout's choice.
#                 Trade-off, same as a fresh clone: a worktree on a branch that
#                 has no .husky then runs no hooks, where the absolute value ran
#                 the main checkout's.
#   set to some OTHER existing dir    -> LEAVE ALONE (a deliberate choice;
#                 a ~ or ~/ path counts, git expands the tilde itself)
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
    # A relative hooksPath resolves against the repo root, not the cwd; git
    # expands a leading ~ itself, so it is a home path, not a relative one.
    # shellcheck disable=SC2088  # the LITERAL ~ git stores, matched on purpose
    case "$CURRENT" in
        /*)
            RESOLVED="$CURRENT"
            # Same directory as our own .husky, by inode, so a symlinked or
            # trailing-slash spelling counts; and tracked, so it exists in
            # every worktree whose branch has it.
            if [ "$RESOLVED" -ef "$TOPLEVEL/.husky" ] \
                && [ -n "$(git -C "$TOPLEVEL" ls-files -- .husky 2>/dev/null | head -n 1)" ]; then
                git config --local core.hooksPath .husky 2>/dev/null || exit 0
                echo "[INFO] git hooks path was absolute ($CURRENT) - made relative (.husky) so a repo move cannot break it"
                exit 0
            fi ;;
        "~")   RESOLVED="$HOME" ;;
        "~/"*) RESOLVED="$HOME/${CURRENT#"~/"}" ;;
        *)  RESOLVED="$TOPLEVEL/$CURRENT" ;;
    esac
    # Points somewhere real: honour it, whatever it is.
    [ -d "$RESOLVED" ] && exit 0
    REASON="stale (was: $CURRENT)"
else
    REASON="unset"
fi

git config --local core.hooksPath .husky 2>/dev/null || exit 0
echo "[INFO] git hooks were $REASON - wired to .husky (the pre-commit that keeps derived counts in sync now runs)"
exit 0
