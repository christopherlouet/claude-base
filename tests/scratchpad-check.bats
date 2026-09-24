#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/scratchpad-check.sh — the SessionStart warning about
# Claude Code temp dirs (session scratchpads) piling up.
#
# Why (2026-09-24): on a machine whose /tmp is a tmpfs, one session left 4 GB of
# node_modules in its scratchpad. Nothing cleans a scratchpad when its session
# ends, so the RAM stayed taken until reboot and the OOM killer ended another
# session. The culprit was ONE day old: an age-based sweep would have missed it,
# so the signal here is SIZE. Two of its three copies were root-owned (a
# `docker run -v` without --user), which no user-level cleanup can remove.
#
# The hook REPORTS and never deletes: it prints the total, the largest OTHER
# sessions and any file you do not own, when the total passes a threshold.
# =============================================================================

load 'test_helper'

HOOK="$BASE_DIR/scripts/hooks/scratchpad-check.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    # A temp tree shaped like Claude Code's: <base>/claude-<uid>/<slug>/<session>/scratchpad
    BASE="$TEST_DIR/claude-$(id -u)"
    CUR="$BASE/-home-me-proj/cur-session"
    mkdir -p "$CUR/scratchpad"
}
teardown() { teardown_test_dir; }

# session <slug> <id> <size-KiB> — another session dir holding a file of that size.
session() {
    mkdir -p "$BASE/$1/$2/scratchpad"
    dd if=/dev/zero of="$BASE/$1/$2/scratchpad/blob" bs=1024 count="$3" 2>/dev/null
}

# run_hook [VAR=value…] — the hook with a SessionStart payload for the current session.
run_hook() {
    local payload
    payload=$(jq -cn --arg s "$CUR/scratchpad" '{hook_event_name:"SessionStart", source:"startup", scratchpad_dir:$s}')
    run env "$@" bash -c 'printf "%s" "$1" | bash "$2"' _ "$payload" "$HOOK"
}

@test "scratchpad-check: script exists and is executable" {
    [ -f "$HOOK" ]
    [ -x "$HOOK" ]
}

@test "scratchpad-check: silent under the threshold" {
    session -home-me-other s1 100
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1024
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "scratchpad-check: warns over the threshold, naming the base dir" {
    session -home-me-other s1 3072
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1
    [ "$status" -eq 0 ]
    [[ "$output" == *"[SCRATCH]"* ]]
    [[ "$output" == *"$BASE"* ]]
}

@test "scratchpad-check: lists the largest OTHER session, never the current one" {
    session -home-me-other big 3072
    session -home-me-other small 10
    dd if=/dev/zero of="$CUR/scratchpad/mine" bs=1024 count=6144 2>/dev/null
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1
    [[ "$output" == *"other/big"* ]]
    [[ "$output" != *"cur-session"* ]]
}

@test "scratchpad-check: names rebuildable dirs found in the largest sessions" {
    session -home-me-other big 3072
    mkdir -p "$BASE/-home-me-other/big/scratchpad/w/node_modules"
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1
    [[ "$output" == *"node_modules"* ]]
}

@test "scratchpad-check: warns about files you do not own, even under the threshold" {
    # A root-owned file cannot be created without root, so the seam declares
    # another uid as "you": every file in the tree then reads as foreign.
    session -home-me-other s1 10
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1024 CLAUDE_BASE_SCRATCH_UID=99999
    [ "$status" -eq 0 ]
    [[ "$output" == *"not owned by you"* ]]
    [[ "$output" == *"--user"* ]]
}

@test "scratchpad-check: never deletes anything" {
    session -home-me-other big 3072
    mkdir -p "$BASE/-home-me-other/big/scratchpad/w/node_modules"
    local before after
    before=$(find "$BASE" | sort | cksum)
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1 CLAUDE_BASE_SCRATCH_UID=99999
    after=$(find "$BASE" | sort | cksum)
    [ "$before" = "$after" ]
}

@test "scratchpad-check: a non-numeric threshold falls back to the default (silent here)" {
    session -home-me-other s1 3072
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=lots
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "scratchpad-check: a payload without scratchpad_dir, or a missing dir, is a silent no-op" {
    run env bash -c 'printf "%s" "{\"hook_event_name\":\"SessionStart\"}" | CLAUDE_CODE_TMPDIR=/nonexistent/x bash "$1"' _ "$HOOK"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run env bash -c 'printf "%s" "not json" | bash "$1"' _ "$HOOK"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "scratchpad-check: a scratchpad_dir outside the claude-<uid> layout is ignored" {
    # The base is derived from the path; a path that does not have the shape must
    # not make the hook walk an arbitrary tree (e.g. /).
    run env bash -c 'printf "%s" "{\"scratchpad_dir\":\"/\"}" | CLAUDE_BASE_SCRATCH_WARN_MB=0 bash "$1"' _ "$HOOK"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # Right suffix, wrong base: three levels up is not claude-<uid>.
    mkdir -p "$TEST_DIR/notclaude/p/s/scratchpad"
    dd if=/dev/zero of="$TEST_DIR/notclaude/p/s/blob" bs=1024 count=2048 2>/dev/null
    run env bash -c 'printf "%s" "{\"scratchpad_dir\":\"$2\"}" | CLAUDE_BASE_SCRATCH_WARN_MB=0 bash "$1"' _ "$HOOK" "$TEST_DIR/notclaude/p/s/scratchpad"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "scratchpad-check: self-application — runs on this machine's real temp dir, exits 0 fast" {
    local base="${CLAUDE_CODE_TMPDIR:-${TMPDIR:-/tmp}}/claude-$(id -u)"
    [ -d "$base" ] || skip "no Claude temp dir on this machine"
    local payload start end
    payload=$(jq -cn --arg s "$base/-self-test/none/scratchpad" '{scratchpad_dir:$s}')
    start=$(date +%s)
    run bash -c 'printf "%s" "$1" | bash "$2"' _ "$payload" "$HOOK"
    end=$(date +%s)
    [ "$status" -eq 0 ]
    [ $((end - start)) -le 5 ]
}

# --- Independent review of #586 ----------------------------------------------

@test "scratchpad-check: a scan that outlives its budget is REPORTED, not silenced" {
    # A tree too big to measure in time is exactly the one to warn about. A fake
    # du that hangs stands in for millions of files.
    command -v timeout >/dev/null 2>&1 || skip "no timeout(1) on this machine"
    session -home-me-other s1 10
    mkdir -p "$TEST_DIR/slowbin"
    printf '#!/bin/sh\nsleep 5\n' > "$TEST_DIR/slowbin/du"
    chmod +x "$TEST_DIR/slowbin/du"
    run_hook PATH="$TEST_DIR/slowbin:$PATH" CLAUDE_BASE_SCRATCH_SCAN_SECONDS=1 CLAUDE_BASE_SCRATCH_WARN_MB=1024
    [ "$status" -eq 0 ]
    [[ "$output" == *"[SCRATCH]"* ]]
    [[ "$output" == *"too large to measure"* ]]
}

@test "scratchpad-check: a threshold with a leading zero is read as decimal" {
    session -home-me-other s1 9216
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=08
    [ "$status" -eq 0 ]
    [[ "$output" == *"[SCRATCH]"* ]]
}

@test "scratchpad-check: a base that is a symlink to the real tree is measured" {
    local real="$TEST_DIR/real-tree"
    mkdir -p "$real"
    mv "$BASE"/* "$real"/
    rmdir "$BASE"
    ln -s "$real" "$BASE"
    session -home-me-other s1 3072
    run_hook CLAUDE_BASE_SCRATCH_WARN_MB=1
    [[ "$output" == *"other/s1"* ]]
}
