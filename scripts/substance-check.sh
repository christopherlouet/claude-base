#!/usr/bin/env bash
# =============================================================================
# substance-check.sh — static "substance gate" (anti-hollow-test / anti-stub).
#
# Flags work that satisfies "tests exist and pass" + coverage % while proving
# nothing: hollow tests (no assertion / always-true / skipped / empty) and stub
# implementations. ADVISORY + deterministic + offline (no execution, no network,
# no model). The next step in the anti-gaming-of-quality-gates thread.
#
# A finding prints to stdout as:   path:line: <kind>: <hint>
#   kinds: no-assertion | always-true | skipped | empty | stub
# Exit: 0 ALWAYS in advisory mode (findings are data, not failures); 2 on usage.
#
# FAIL-SAFE (EF-007): an unknown language, an unrecognized file, or any parse
# ambiguity yields NO finding — favour a false-negative over a false-positive.
# The hardest constraint (EF-008): ZERO findings on the foundation's own suite.
#
# Usage: substance-check.sh [--tests-only|--code-only] [--quiet] [paths…]
#   paths default to "." ; dirs are scanned recursively for supported files.
# =============================================================================

set -euo pipefail

MODE=both          # both | tests | code
QUIET=0
PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --tests-only) MODE=tests; shift ;;
        --code-only)  MODE=code; shift ;;
        --quiet)      QUIET=1; shift ;;
        -h|--help)
            sed -nE 's/^# ?//p' "$0" | sed -nE '/^substance-check/,/^Usage/p'; exit 0 ;;
        --) shift; while [ $# -gt 0 ]; do PATHS+=("$1"); shift; done ;;
        -*) echo "substance-check: unknown option: $1" >&2; exit 2 ;;
        *)  PATHS+=("$1"); shift ;;
    esac
done
[ "${#PATHS[@]}" -gt 0 ] || PATHS=(".")

# ---------------------------------------------------------------------------
# Scanners (one awk per language). Each prints `file:line: kind: hint` lines.
# ---------------------------------------------------------------------------

# Bats hollow-test scanner (state machine). A bats @test is HOLLOW when every
# meaningful body line is INERT — i.e. cannot fail the test: `run …` (captures
# status, never fails), echo/printf, assignments, load/source, comments. In bats
# ANY other bare command (`[ … ]`, `jq …`, `grep …`, a helper call) fails the
# test on non-zero exit, so it counts as a real check — we favour NOT flagging.
# Heredoc bodies are skipped (a test file may embed `@test` snippets in a heredoc).
# Bats `skip` is NOT flagged in v1: it is overwhelmingly a legitimate conditional
# env-guard in real suites (`skip_if_no_jq`, `if root; then skip`); flagging it
# would break the zero-false-positive constraint. JS/Py/Go skip detection (Phase 2)
# handles genuine disables.
_scan_bats() {
    local f="$1"
    awk -v file="$f" '
        function flush(   i, line, meaningful, allInert) {
            if (!inblock) return
            meaningful=0; allInert=1
            for (i=0;i<n;i++) {
                line=body[i]
                if (line ~ /^[[:space:]]*#/) continue
                if (line ~ /^[[:space:]]*$/) continue
                if (line ~ /^[[:space:]]*[}][[:space:]]*$/) continue
                meaningful++
                # INERT = a line that cannot make the test fail / assert nothing.
                if (line !~ /^[[:space:]]*(run([[:space:]]|$)|echo([[:space:]]|$)|printf([[:space:]]|$)|load([[:space:]]|$)|source([[:space:]]|$)|sleep([[:space:]]|$)|cd([[:space:]]|$)|true([[:space:]]|$)|:([[:space:]]|$)|export[[:space:]]|local[[:space:]]|declare[[:space:]]|readonly[[:space:]]|[A-Za-z_][A-Za-z0-9_]*=)/)
                    allInert=0
            }
            if (meaningful==0)
                printf "%s:%d: empty: empty test body\n", file, startline
            else if (allInert)
                printf "%s:%d: no-assertion: runs code but asserts nothing\n", file, startline
            inblock=0; n=0
        }
        {
            # Skip heredoc bodies entirely (brace/@test inside data must not count).
            if (inheredoc) { if ($0 ~ hend) inheredoc=0; next }
            tmp=$0; o=gsub(/[{]/,"",tmp); tmp=$0; c=gsub(/[}]/,"",tmp)
            startsheredoc=0
            if (match($0, /<<-?["'"'"']?[A-Za-z_][A-Za-z0-9_]*/)) {
                hm=substr($0, RSTART, RLENGTH); gsub(/[<\-"'"'"']/,"",hm)
                hend="^[[:space:]]*" hm "[[:space:]]*$"; startsheredoc=1
            }
        }
        /^[[:space:]]*@test/ && !inblock {
            flush(); inblock=1; startline=NR; n=0; depth=o-c
            if (startsheredoc) inheredoc=1
            next
        }
        inblock {
            depth += o-c
            body[n++]=$0
            if (depth<=0) { flush() }
            else if (startsheredoc) inheredoc=1
            next
        }
        END { flush() }
    ' "$f" || true
}

# Stub scanner — Phase 3 fills the per-language patterns. For now a no-op so the
# "no stubs in our own scripts/" regression (EF-008) holds while we build the
# hollow-test path first. NEVER emit on ambiguity.
_scan_code_stub() { : ; }

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

# _is_test_file <path> — bats/shell test file (has @test), or a *.test.* /
# *.spec.* / *_test.go / test_*.py name. Cheap heuristic.
_file_is_bats_tests() {
    case "$1" in
        *.bats) return 0 ;;
        *.sh|*.bash) grep -qE '^[[:space:]]*@test' "$1" 2>/dev/null && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

_scan_one() {
    local f="$1"
    [ -f "$f" ] || return 0
    if [ "$MODE" != code ] && _file_is_bats_tests "$f"; then
        _scan_bats "$f"
    fi
    if [ "$MODE" != tests ]; then
        _scan_code_stub "$f"
    fi
}

# Collect target files: expand dirs to supported extensions.
_collect() {
    local p
    for p in "${PATHS[@]}"; do
        if [ -d "$p" ]; then
            find "$p" -type f \( -name '*.bats' -o -name '*.sh' -o -name '*.bash' \
                -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
                -o -name '*.py' -o -name '*.go' \) 2>/dev/null
        elif [ -e "$p" ]; then
            printf '%s\n' "$p"
        fi
    done
}

findings=0
while IFS= read -r f; do
    [ -n "$f" ] || continue
    out=$(_scan_one "$f")
    if [ -n "$out" ]; then
        printf '%s\n' "$out"
        findings=$((findings + $(printf '%s\n' "$out" | grep -c ': ')))
    fi
done < <(_collect)

[ "$QUIET" = 1 ] || echo "substance-check: $findings finding(s)" >&2
exit 0
