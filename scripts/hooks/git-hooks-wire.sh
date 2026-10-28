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
#   set to some OTHER existing dir    -> LEAVE ALONE (a deliberate choice)
#
# Every layer counts: the value read is the one git uses (local, a linked
# worktree's config.worktree, global, system), resolved by git itself, so ~,
# ~user/, %(prefix)/ and a drive letter mean what they mean to git on this
# platform. A repair is written to the layer the value came from; a global or
# system value that points somewhere real is the user's, never overridden,
# and one line per session says this repo's .husky hooks then do not run.
#
# Silent on the happy path, one line when it repairs (or cannot). Always exits 0: a session
# must never fail because of this.
# =============================================================================

set -u

# Dependencies missing or not a work tree — nothing to do, quietly.
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$TOPLEVEL" ] || exit 0
[ -d "$TOPLEVEL/.husky" ] || exit 0

# "<scope>\t<value>" of the value git uses; status 1 = unset. An explicitly
# empty value is set (git resolves it to the work tree). A git older than
# --show-scope (2.26) still reads the value git uses, without its layer.
SET=true SCOPE="" CURRENT=""
if EFFECTIVE=$(git config --show-scope core.hooksPath 2>/dev/null); then
    SCOPE=${EFFECTIVE%%$'\t'*}; CURRENT=${EFFECTIVE#*$'\t'}
elif [ $? -eq 1 ] || ! CURRENT=$(git config core.hooksPath 2>/dev/null); then
    SET=false
fi

# A value from the command line (git -c, or GIT_CONFIG_COUNT/KEY_n/VALUE_n in
# the environment) outranks every file: no write here would change the hooks
# git runs.
[ "$SCOPE" = command ] && exit 0

# The main checkout, not a linked worktree: its git dir IS the common dir.
# The .husky rewrite below is decided from here only — from a worktree, its
# own index would speak for a config every other checkout shares.
in_main_checkout() {
    local gd cd
    gd=$(cd "$(git rev-parse --git-dir 2>/dev/null)" 2>/dev/null && pwd -P) || return 1
    cd=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P) || return 1
    [ "$gd" = "$cd" ]
}

# A per-worktree value is repaired where it lives; anything else gets the
# local value, which overrides a stale global or system one.
WRITE_SCOPE=--local
[ "$SCOPE" = worktree ] && WRITE_SCOPE=--worktree

if $SET; then
    # git's own resolution: ~, ~user/ and %(prefix)/ expanded, and absolute or
    # relative as git decides on this platform (C:/x is absolute only on
    # Windows). A relative result is relative to the cwd, as every test is.
    RESOLVED=$(git rev-parse --git-path hooks 2>/dev/null) || exit 0
    # An absolute path to our own .husky, by inode, so a symlinked or
    # trailing-slash spelling counts; tracked, so it exists in every worktree
    # whose branch has it; set in the local layer, the one this rewrite
    # replaces (a global value is the user's); and seen from the main checkout.
    case "$SCOPE:$CURRENT" in
        local:/*|:/*)
            if [ "$RESOLVED" -ef "$TOPLEVEL/.husky" ] \
                && [ -n "$(git -C "$TOPLEVEL" ls-files -- .husky 2>/dev/null | head -n 1)" ] \
                && in_main_checkout; then
                MESSAGE="git hooks path was absolute ($CURRENT) - made relative (.husky) so a repo move cannot break it"
            fi ;;
    esac
    # Points somewhere real: honour it, whatever it is. A global or system
    # value is the user's choice for every repo, so it is not overridden, but
    # the .husky hooks then do not run here: say so.
    if [ -z "${MESSAGE:-}" ] && [ -d "$RESOLVED" ]; then
        [ "$RESOLVED" -ef "$TOPLEVEL/.husky" ] || case "$SCOPE" in
            global|system) echo "[INFO] git hooks come from $SCOPE config (${CURRENT:-empty}) - this repo's .husky hooks do not run; to use them here instead of those: git config core.hooksPath .husky" ;;
        esac
        exit 0
    fi
    if [ -z "${MESSAGE:-}" ]; then
        case "$SCOPE" in local|"") FROM="" ;; *) FROM=", $SCOPE config" ;; esac
        MESSAGE="git hooks were stale (was: $CURRENT$FROM) - wired to .husky (the pre-commit that keeps derived counts in sync now runs)"
    fi
else
    MESSAGE="git hooks were unset - wired to .husky (the pre-commit that keeps derived counts in sync now runs)"
fi

# The one write: every repair ends on the relative .husky. Announced only once
# git reads it back: a value from an [include]d file, or set several times,
# wins over (or refuses) this write, and the hooks would stay dead.
git config "$WRITE_SCOPE" core.hooksPath .husky 2>/dev/null
if [ "$(git config core.hooksPath 2>/dev/null)" != .husky ]; then
    $SET || CURRENT="unset"
    echo "[WARN] git hooks path could not be repaired (was: ${CURRENT:-empty}) - check core.hooksPath (git config --show-origin --get-all core.hooksPath)"
    exit 0
fi
echo "[INFO] $MESSAGE"
exit 0
