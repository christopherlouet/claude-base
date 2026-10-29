#!/usr/bin/env bash
# =============================================================================
# _lessons-store.sh — the personal lessons store's location and byte budget.
#
# Sourced by: lessons-budget-guard.sh (Edit|Write|MultiEdit), bash-write-guard.sh
#             (Bash) and scripts/lessons.sh (prune-check), so the guard that
#             refuses a write and the check that reports the size agree on the
#             SAME file and the SAME number (one representation, no drift).
#
# The store is the always-loaded ~/.claude/rules/lessons.md only; path-scoped
# ~/.claude/rules/lessons-*.md files load on demand and carry no budget.
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only.
# =============================================================================

# Avoid double-sourcing. Keyed on a function, not a variable: an exported
# marker inherited from a caller would otherwise skip every definition.
declare -F is_lessons_store >/dev/null 2>&1 && return 0

# A starting point, not a measured optimum (docs/recipes/personal-lessons-referential.md).
LESSONS_DEFAULT_BUDGET=4000

# lessons_store_path — print the store's path. Returns 1 without a HOME, so a
# caller under `set -u` never dies on it (a hook exiting 1 under onFailure
# "block" refuses the call instead of giving a verdict).
lessons_store_path() {
    [ -n "${HOME:-}" ] || return 1
    printf '%s\n' "$HOME/.claude/rules/lessons.md"
}

# lessons_budget [BUDGET] — print the budget: the argument, else
# $LESSONS_BUDGET, else LESSONS_DEFAULT_BUDGET. Returns 2 on a value that is
# not a whole number of at most 18 digits (a longer one overflows `[ -gt ]`,
# whose error then reads as "not over").
lessons_budget() {
    local budget="${1:-${LESSONS_BUDGET:-$LESSONS_DEFAULT_BUDGET}}"
    case "$budget" in
        ''|*[!0-9]*|???????????????????*) return 2 ;;
    esac
    printf '%s\n' "$budget"
}

# lessons_expand_path <path> [BASE] — print <path> with a leading `~`,
# `$HOME`, `${HOME}` or `${HOME:?}` expanded (a shell command carries them
# unexpanded; `~user` is not recognised), and a relative path joined to BASE
# (default: the current directory).
lessons_expand_path() {
    local p="$1" base="${2:-$PWD}"
    # shellcheck disable=SC2016,SC2088  # matching the literal, unexpanded text
    case "$p" in
        '~')           p="${HOME:-}" ;;
        '~/'*)         p="${HOME:-}/${p#\~/}" ;;
        '$HOME/'*)     p="${HOME:-}/${p#\$HOME/}" ;;
        '${HOME}/'*)   p="${HOME:-}/${p#\$\{HOME\}/}" ;;
        '${HOME:?}/'*) p="${HOME:-}/${p#\$\{HOME:?\}/}" ;;
        /*) ;;
        *)             p="$base/$p" ;;
    esac
    printf '%s\n' "$p"
}

# _lessons_real_dir <dir> — print <dir> resolved (symlinks, `.`, `..`, `//`),
# or nothing when it does not exist.
_lessons_real_dir() {
    (cd -- "$1" 2>/dev/null && pwd -P) || true
}

# is_lessons_store <path> [BASE] — 0 if <path> names the store, existing or
# not: its directory is compared resolved, so `rules/./lessons.md` or
# `.claude//rules` match before the file exists; a symlink to the store
# matches once it does.
is_lessons_store() {
    local p store dir
    store=$(lessons_store_path) || return 1
    p=$(lessons_expand_path "$1" "${2:-}")
    [ "$p" = "$store" ] && return 0
    if [ "$(basename -- "$p")" = lessons.md ]; then
        dir=$(_lessons_real_dir "$(dirname -- "$p")")
        [ -n "$dir" ] && [ "$dir" = "$(_lessons_real_dir "$(dirname -- "$store")")" ] && return 0
    fi
    [ -e "$store" ] && [ "$p" -ef "$store" ]
}

# is_lessons_store_dir <path> [BASE] — 0 if <path> names the store's directory
# (a `cp x.md <dir>/` writes into it under the source's name).
is_lessons_store_dir() {
    local store dir
    store=$(lessons_store_path) || return 1
    dir=$(_lessons_real_dir "$(lessons_expand_path "$1" "${2:-}")")
    [ -n "$dir" ] && [ "$dir" = "$(_lessons_real_dir "$(dirname -- "$store")")" ]
}
