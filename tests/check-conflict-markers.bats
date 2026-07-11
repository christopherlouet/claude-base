#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/check-conflict-markers.sh (prevention gate, 2026-07-11
# route-to-stable Lot E). Fixture markers are ASSEMBLED at runtime from
# fragments so no literal conflict marker ever lands in this file (which would
# trip the gate's own self-application run on the real repo).
# =============================================================================

load 'test_helper'

CHECK="$BATS_TEST_DIRNAME/../scripts/check-conflict-markers.sh"

setup() {
    setup_test_dir
    git -C "$TEST_DIR" init -q
    git -C "$TEST_DIR" config user.email t@t && git -C "$TEST_DIR" config user.name t
}
teardown() { teardown_test_dir; }

# marker <char> — assemble a 7-char conflict marker line at runtime.
marker() {
    local c="$1" out="" i
    for i in 1 2 3 4 5 6 7; do out+="$c"; done
    printf '%s' "$out"
}

# commit_file <name> <content>
commit_file() {
    printf '%s\n' "$2" > "$TEST_DIR/$1"
    git -C "$TEST_DIR" add "$1"
    git -C "$TEST_DIR" commit -qm "add $1"
}

@test "conflict-markers: a tracked file with an open marker fails, file:line listed" {
    commit_file bad.txt "line1
$(marker '<') HEAD
line3"
    run bash "$CHECK" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"bad.txt"* ]]
}

@test "conflict-markers: a close marker and a diff3 base marker are both caught" {
    commit_file close.txt "$(marker '>') feature-branch"
    commit_file base.txt "$(marker '|') merged common ancestors"
    run bash "$CHECK" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"close.txt"* ]]
    [[ "$output" == *"base.txt"* ]]
}

@test "conflict-markers: a clean repo passes" {
    commit_file ok.txt "nothing to see"
    run bash "$CHECK" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "conflict-markers: a Markdown ======= underline is NOT a finding (FP guard)" {
    commit_file doc.md "Title
=======
body; and a table row | with | pipes"
    run bash "$CHECK" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "conflict-markers: an UNTRACKED file with markers does not trip the gate" {
    commit_file ok.txt "clean"
    printf '%s HEAD\n' "$(marker '<')" > "$TEST_DIR/scratch.txt"
    run bash "$CHECK" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "conflict-markers: outside a git repo exits 2" {
    # NOT under $TEST_DIR — setup() git-inits that one.
    local norepo; norepo=$(mktemp -d)
    run bash "$CHECK" "$norepo"
    rm -rf "$norepo"
    [ "$status" -eq 2 ]
}

@test "conflict-markers: self-application — the REAL repo is clean" {
    run bash "$CHECK" "$BATS_TEST_DIRNAME/.."
    [ "$status" -eq 0 ]
}
