#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/hooks/_core-helpers.sh — the harness-neutral core
# side of the core/shell split (specs/agnostic-core/).
#
# These tests source the core and call its functions on plain strings: no
# stdin JSON envelope, no exit-2 semantics, no harness at all. They are the
# reference tests a future harness shell must keep green; the existing
# hook-level bats (command-validator.bats, …) remain the Claude-Code-contract
# regression oracle.
#
# The behavioral cases mirror the documented strip_msg_values invariants
# (see the function's header comment): value removed / flag kept, shell-word
# fidelity (quotes, apostrophe idiom, squished clusters), and separator
# preservation (the pass-3 sudo-bypass class).
# =============================================================================

load 'test_helper'

CORE="$BASE_DIR/scripts/hooks/_core-helpers.sh"

@test "core-helpers: file exists and is sourceable under set -euo pipefail" {
    [ -f "$CORE" ]
    run bash -c "set -euo pipefail; . '$CORE'; declare -F strip_msg_values >/dev/null"
    [ "$status" -eq 0 ]
}

@test "core-helpers: sourcing twice is idempotent (double-source guard)" {
    run bash -c "set -euo pipefail; . '$CORE'; . '$CORE'; declare -F strip_msg_values >/dev/null"
    [ "$status" -eq 0 ]
}

@test "core-helpers: contains no harness-specific plumbing (pure core)" {
    # The core must stay sourceable by ANY harness shell: no stdin envelope
    # fields, no hook JSON output, no Claude-Code env vars, no exit-2.
    ! grep -E 'tool_input|hookSpecificOutput|CLAUDE_PROJECT_DIR|exit 2' "$CORE"
}

# --- strip_msg_values behavioral invariants (direct, no envelope) ------------

# strip <cmd> — run strip_msg_values on a plain string, output on stdout.
strip() {
    bash -c ". '$CORE'; strip_msg_values \"\$1\"" _ "$1"
}

@test "strip: removes a double-quoted -m value, keeps the flag" {
    result=$(strip 'git commit -m "document mkfs usage" file.txt')
    [[ "$result" != *"mkfs"* ]]
    [[ "$result" == *"-m"* ]]
    [[ "$result" == *"file.txt"* ]]
}

@test "strip: removes a single-quoted --grep value" {
    result=$(strip "git log --grep 'passwd rotation'")
    [[ "$result" != *"passwd"* ]]
    [[ "$result" == *"--grep"* ]]
}

@test "strip: keeps the -nm/-anm short-flag cluster while dropping its value" {
    # Category 9 must still see the n (= --no-verify) after the strip.
    result=$(strip "git commit -anm 'wip'")
    [[ "$result" == *"-anm"* ]]
    [[ "$result" != *"wip"* ]]
}

@test "strip: bare value stops at a separator — the next command survives" {
    # Leftmost-longest must NOT eat the ';' (pass-3 sudo-bypass class).
    result=$(strip "git commit -m wip;sudo id")
    [[ "$result" == *"sudo id"* ]]
}

@test "strip: separator after a quoted value is preserved" {
    result=$(strip "git commit -m 'done'; sudo id")
    [[ "$result" == *"sudo id"* ]]
}

@test "strip: squished -am\"msg\" cluster (no space) is stripped, cluster kept" {
    result=$(strip 'git commit -am"my message text"')
    [[ "$result" != *"my message text"* ]]
    [[ "$result" == *"-am"* ]]
}

@test "strip: multiline quoted -m value is removed whole" {
    cmd=$'git commit -m "line one\nline two --no-verify inside" && echo done'
    result=$(strip "$cmd")
    [[ "$result" != *"line two"* ]]
    [[ "$result" == *"echo done"* ]]
}

@test "strip: apostrophe idiom ('…'\\''…') removed as one value" {
    cmd="git commit -m 'it'\\''s done' next"
    result=$(strip "$cmd")
    [[ "$result" != *"done"* ]]
    [[ "$result" == *"next"* ]]
}

@test "strip: string without message flags is unchanged" {
    result=$(strip "npm run build && npm test")
    [ "$result" = "npm run build && npm test" ]
}

@test "strip: empty string yields empty output, exit 0" {
    run bash -c ". '$CORE'; strip_msg_values ''"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# --- single canonical copy (the anti-divergence invariant) -------------------

@test "core-helpers: strip_msg_values is defined ONLY in _core-helpers.sh" {
    # Divergent per-guard copies are how the pass-3 F1/F3 bugs shipped. The
    # function body must exist in exactly one file; other scripts may only
    # declare the no-op fallback `strip_msg_values() { printf '%s' "$1"; }`.
    # -F on the exclusion: the fallback text contains BRE metacharacters
    # ($1 mid-pattern) that silently break a regex match — fixed-string is
    # the only faithful comparison here.
    # `|| true` keeps the substitution's status at 0 when the LAST scanned
    # file is a clean non-match — bats' errexit would otherwise fail the
    # assignment itself before the comparison runs.
    hits=$(grep -rl 'strip_msg_values()' "$BASE_DIR/scripts/hooks/" \
        | while IFS= read -r f; do
            { grep -vF "strip_msg_values() { printf '%s' \"\$1\"; }" "$f" \
                | grep -q 'strip_msg_values()' && echo "$f"; } || true
          done)
    [ "$hits" = "$BASE_DIR/scripts/hooks/_core-helpers.sh" ]
}

@test "core-helpers: _hook-helpers.sh still provides strip (compat via core)" {
    run bash -c "set -euo pipefail; . '$BASE_DIR/scripts/hooks/_hook-helpers.sh'; declare -F strip_msg_values >/dev/null"
    [ "$status" -eq 0 ]
}
