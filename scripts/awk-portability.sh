#!/usr/bin/env bash
# =============================================================================
# awk-portability.sh — replay the hook policy suites under another awk
# =============================================================================
# The hook policies call awk, and a hook runs on the USER's machine: mawk is
# Ubuntu's default awk, busybox is the awk of Alpine images. CI's own runners
# use gawk (ubuntu) and BWK (macOS), so without this nothing ever ran the
# guards under the other two.
#
# Each implementation is put first on PATH as `awk` through a shim, then the
# suites run. A control runs first with an awk that always fails: if that
# breaks nothing, the shim never reached the tests and every "ok" below would
# be blind — the run is refused instead.
#
# Usage:
#   scripts/awk-portability.sh [IMPL...]   # default: mawk busybox
#   scripts/awk-portability.sh --list      # print the suites, run nothing
#
#   IMPL is a command name or path; `busybox` is reached as `busybox awk`.
#   AWK_PORTABILITY_TESTS overrides the suites (space-separated paths).
#
# Exit: 0 every implementation passed · 1 one failed · 2 an implementation is
# missing or the control shows the suites are blind to awk.
# macOS bash 3.2 compatible.
# =============================================================================

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 2

if [ -n "${AWK_PORTABILITY_TESTS:-}" ]; then
    # shellcheck disable=SC2206  # space-separated list, by contract
    SUITES=($AWK_PORTABILITY_TESTS)
else
    SUITES=(tests/policy-*.bats)
fi

if [ "${1:-}" = "--list" ]; then
    printf '%s\n' "${SUITES[@]}"
    exit 0
fi

[ $# -gt 0 ] || set -- mawk busybox

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Build $WORK/<n>/awk running the given implementation; print the dir.
_shim() {
    local dir="$WORK/$1" impl="$2" path
    mkdir -p "$dir"
    if [ "$impl" = "busybox" ]; then
        path=$(command -v busybox) || return 1
        printf '#!/bin/sh\nexec "%s" awk "$@"\n' "$path" > "$dir/awk"
    elif [ "$impl" = "--broken" ]; then
        printf '#!/bin/sh\nexit 3\n' > "$dir/awk"
    else
        path=$(command -v "$impl") || return 1
        printf '#!/bin/sh\nexec "%s" "$@"\n' "$path" > "$dir/awk"
    fi
    chmod +x "$dir/awk"
    printf '%s' "$dir"
}

_run_suites() {
    PATH="$1:$PATH" bats "${SUITES[@]}" > "$WORK/out" 2>&1
}

# Resolve every implementation before spending time on any run.
n=0
for impl in "$@"; do
    n=$((n + 1))
    if ! _shim "$n" "$impl" > /dev/null; then
        echo "awk-portability: implementation not found: $impl" >&2
        exit 2
    fi
done

# Control: an awk that always fails must break at least one suite.
if _run_suites "$(_shim control --broken)"; then
    echo "awk-portability: the suites are blind to awk (a broken awk failed nothing)" >&2
    echo "  suites: ${SUITES[*]}" >&2
    exit 2
fi

failed=0
n=0
for impl in "$@"; do
    n=$((n + 1))
    name=$(basename "$impl")
    if _run_suites "$WORK/$n"; then
        echo "$name: ok"
    else
        failed=1
        echo "$name: FAILED ($(grep -c '^not ok' "$WORK/out") failing)"
        grep '^not ok' "$WORK/out" | head -20
    fi
done
exit "$failed"
