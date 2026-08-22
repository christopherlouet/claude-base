#!/usr/bin/env bats

# Tests for scripts/private-names-check.sh — the pre-commit gate that keeps
# an end user's PRIVATE project names out of this PUBLIC repository.
#
# Design constraints this suite pins:
#
#  1. The protected-name list lives OUTSIDE the repo (default
#     ~/.claude/private-names, overridable with CLAUDE_BASE_PRIVATE_NAMES).
#     Committing the list would publish exactly what it protects — the mistake
#     the pre-existing spec checklists made.
#  2. No list → the gate is a silent no-op. Anyone cloning the public
#     foundation has no such list and must not be blocked by it.
#  3. Only lines the commit ADDS are scanned. A pre-existing occurrence in an
#     untouched region must not block an unrelated commit, and REMOVING an
#     occurrence (the cleanup commit) must always be allowed.
#  4. Names are matched as FIXED strings, never as regexes: a name carrying a
#     metacharacter must not silently widen the match.
#
# NOTE: every name used here is fictional. Putting a real protected name in
# this file would make the test itself the leak it guards against.

load 'test_helper'

CHECK="$BATS_TEST_DIRNAME/../scripts/private-names-check.sh"

setup() {
    cd "$BATS_TEST_TMPDIR"
    rm -rf repo && mkdir repo && cd repo
    git init --quiet .
    git config user.email "test@example.com"
    git config user.name "Test"
    # Never inherit the developer's real list while testing.
    export CLAUDE_BASE_PRIVATE_NAMES="$BATS_TEST_TMPDIR/names.txt"
    rm -f "$CLAUDE_BASE_PRIVATE_NAMES"
    unset SKIP_PRIVATE_NAMES
}

# write the protected-name list
names() { printf '%s\n' "$@" > "$CLAUDE_BASE_PRIVATE_NAMES"; }

# stage a file with the given content
stage() { mkdir -p "$(dirname "$1")"; printf '%s\n' "$2" > "$1"; git add "$1"; }

# commit whatever is staged, bypassing the gate under test
commit_staged() { git commit --quiet --no-verify -m "seed"; }

# --- no list: the gate must not exist for public users ----------------------

@test "no list file: exits 0 and stays silent" {
    stage "doc.md" "anything at all"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "empty list file: exits 0" {
    : > "$CLAUDE_BASE_PRIVATE_NAMES"
    stage "doc.md" "anything at all"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "list of only comments and blank lines: exits 0" {
    printf '# a comment\n\n   \n' > "$CLAUDE_BASE_PRIVATE_NAMES"
    stage "doc.md" "anything at all"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

# --- blocking ---------------------------------------------------------------

@test "added line containing a protected name: blocks and names the file" {
    names "zephyr-ledger"
    stage "docs/design.md" "we validated this against zephyr-ledger last week"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"docs/design.md"* ]]
    [[ "$output" == *"zephyr-ledger"* ]]
}

@test "protected name in a staged FILE PATH: blocks" {
    names "zephyr-ledger"
    stage "notes/zephyr-ledger-migration.md" "nothing sensitive in the body"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"zephyr-ledger-migration.md"* ]]
}

@test "match is case-insensitive" {
    names "zephyr-ledger"
    stage "docs/design.md" "see ZEPHYR-Ledger for the layout"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}

@test "reports every offending name, not just the first" {
    names "zephyr-ledger" "orchid-relay"
    stage "docs/design.md" "zephyr-ledger and orchid-relay both matter"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"zephyr-ledger"* ]]
    [[ "$output" == *"orchid-relay"* ]]
}

# --- what must NOT block ----------------------------------------------------

@test "clean staged content: exits 0" {
    names "zephyr-ledger"
    stage "docs/design.md" "a perfectly ordinary sentence"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "pre-existing occurrence in an untouched region does not block" {
    names "zephyr-ledger"
    stage "docs/legacy.md" "historical mention of zephyr-ledger"
    commit_staged
    stage "docs/other.md" "an unrelated new file"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "REMOVING a protected name is always allowed" {
    names "zephyr-ledger"
    stage "docs/legacy.md" "historical mention of zephyr-ledger"
    commit_staged
    stage "docs/legacy.md" "historical mention of a personal project"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "SKIP_PRIVATE_NAMES=1 bypasses the gate" {
    names "zephyr-ledger"
    stage "docs/design.md" "zephyr-ledger appears here"
    SKIP_PRIVATE_NAMES=1 run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "nothing staged: exits 0" {
    names "zephyr-ledger"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

# --- fixed-string matching (a name is data, not a pattern) ------------------

@test "a name carrying a regex metacharacter matches literally only" {
    names "orchid.relay"
    stage "docs/design.md" "orchidXrelay is a different thing entirely"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "a name carrying a regex metacharacter still matches its literal form" {
    names "orchid.relay"
    stage "docs/design.md" "orchid.relay is the protected one"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}

# --- robustness -------------------------------------------------------------

@test "a staged binary file does not break the scan" {
    names "zephyr-ledger"
    printf '\x00\x01\x02binary\x00' > blob.bin
    git add blob.bin
    stage "docs/ok.md" "harmless text"
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "list entries are trimmed of surrounding whitespace" {
    printf '  zephyr-ledger  \n' > "$CLAUDE_BASE_PRIVATE_NAMES"
    stage "docs/design.md" "zephyr-ledger appears here"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}

# --- regressions found by review of 21cff612 --------------------------------
# All four fail-OPEN cases below let a protected name through silently, which
# is the one failure mode this gate must never have.

@test "regression: a non-ASCII path is still scanned (git C-quotes it)" {
    names "zephyr-ledger"
    stage "d/café.md" "mentions zephyr-ledger in the body"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}

@test "regression: an added line whose content starts with ++ is still scanned" {
    names "zephyr-ledger"
    stage "docs/design.md" "++zephyr-ledger noted here"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}

@test "regression: works when invoked from a subdirectory" {
    names "zephyr-ledger"
    stage "docs/design.md" "zephyr-ledger appears here"
    mkdir -p sub
    run bash -c "cd '$PWD/sub' && bash '$CHECK'"
    [ "$status" -ne 0 ]
}

@test "regression: HOME unset does not block every commit" {
    stage "docs/design.md" "a perfectly ordinary sentence"
    run env -u HOME -u CLAUDE_BASE_PRIVATE_NAMES bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "regression: a path containing a space is reported as one row" {
    names "zephyr-ledger"
    stage "d/my notes.md" "harmless"
    stage "docs/design.md" "zephyr-ledger here"
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" != *"  d/my"$'\n'* ]]
}

@test "regression: a protected name inside a staged binary is caught" {
    names "zephyr-ledger"
    printf 'prefix\x00zephyr-ledger\x00suffix' > blob.bin
    git add blob.bin
    run bash "$CHECK"
    [ "$status" -ne 0 ]
}
