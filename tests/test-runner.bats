#!/usr/bin/env bats

# =============================================================================
# Tests for test.sh (the script that runs bats tests)
# =============================================================================

load 'test_helper'

TEST_SCRIPT="$BATS_TEST_DIRNAME/../scripts/test.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests
# =============================================================================

@test "test.sh exists and is executable" {
    [ -f "$TEST_SCRIPT" ]
    [ -x "$TEST_SCRIPT" ]
}

@test "test.sh displays help with --help" {
    run "$TEST_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"test"* ]] || [[ "$output" == *"bats"* ]]
}

@test "test.sh displays version with --version" {
    run "$TEST_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"test"* ]]
}

# =============================================================================
# Option handling
# =============================================================================

@test "test.sh --help documents usage, key options, and examples" {
    run "$TEST_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
    [[ "$output" == *"--shard"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--verbose"* ]]
    [[ "$output" == *"EXAMPLES"* ]]
}

@test "test.sh rejects an unknown option with exit 1 and names it" {
    run "$TEST_SCRIPT" --nonexistent-option
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
    [[ "$output" == *"--nonexistent-option"* ]]
}

# =============================================================================
# FILTER selection (exercised via --dry-run so no bats run is required)
# =============================================================================

@test "test.sh applies a FILTER, selecting only matching test files" {
    run "$TEST_SCRIPT" --dry-run common
    [ "$status" -eq 0 ]
    # Only files whose basename contains the filter are selected.
    [[ "$output" == *"common.bats"* ]]
    # A non-matching file must be excluded.
    [[ "$output" != *"doctor.bats"* ]]
    # Exactly one file matches "common".
    [ "$(printf '%s\n' "$output" | grep -c '\.bats$')" -eq 1 ]
}

@test "test.sh errors with exit 1 when a FILTER matches no test file" {
    run "$TEST_SCRIPT" --dry-run zzz-no-such-test-file
    [ "$status" -eq 1 ]
    [[ "$output" == *"No test file"* ]]
}

# =============================================================================
# bats installation tests
# =============================================================================

@test "test.sh offers to install bats if missing" {
    if ! command -v bats &>/dev/null; then
        run "$TEST_SCRIPT"
        [[ "$output" == *"install"* ]] || [[ "$output" == *"bats"* ]]
    else
        skip "bats already installed"
    fi
}

# =============================================================================
# Sharding tests (--shard I/N, used by CI to parallelize across runners)
# =============================================================================

@test "test.sh --dry-run lists the selected test files without running bats" {
    run "$TEST_SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    # Should print real test files, one per line, and NOT a TAP plan (no "1..N", no "ok ")
    [[ "$output" == *".bats"* ]]
    [[ "$output" != *"1..1"* ]]
    [[ "$output" != *$'\nok '* ]]
}

@test "test.sh --shard accepts the I/N form and emits a strict subset" {
    run "$TEST_SCRIPT" --shard 1/4 --dry-run
    [ "$status" -eq 0 ]
    local shard_count total_count
    shard_count=$(printf '%s\n' "$output" | grep -c '\.bats$')
    total_count=$(ls "$BATS_TEST_DIRNAME"/*.bats | wc -l | tr -d ' ')
    [ "$shard_count" -gt 0 ]
    [ "$shard_count" -lt "$total_count" ]
}

@test "test.sh --shard partitions every file exactly once across all shards" {
    local total
    total=$(ls "$BATS_TEST_DIRNAME"/*.bats | wc -l | tr -d ' ')
    local all=""
    for i in 1 2 3 4; do
        run "$TEST_SCRIPT" --shard "$i/4" --dry-run
        [ "$status" -eq 0 ]
        all+="$output"$'\n'
    done
    # Union (deduped by basename) must equal the full file count — no gaps, no overlaps
    local union_count
    union_count=$(printf '%s' "$all" | grep -o '[^/]*\.bats$' | sort -u | wc -l | tr -d ' ')
    [ "$union_count" -eq "$total" ]
    # And the non-deduped total must also equal it (proves disjoint: no file in two shards)
    local raw_count
    raw_count=$(printf '%s' "$all" | grep -c '\.bats$')
    [ "$raw_count" -eq "$total" ]
}

@test "test.sh --shard balances shards within a reasonable spread" {
    local min=99999 max=0 c
    for i in 1 2 3 4; do
        run "$TEST_SCRIPT" --shard "$i/4" --dry-run
        [ "$status" -eq 0 ]
        c=$(printf '%s\n' "$output" | grep -c '\.bats$')
        [ "$c" -lt "$min" ] && min=$c
        [ "$c" -gt "$max" ] && max=$c
    done
    # Greedy balancing should keep the file-count spread small (<= 4 files apart)
    [ "$((max - min))" -le 4 ]
}

@test "test.sh --shard 1/1 selects all files" {
    run "$TEST_SCRIPT" --shard 1/1 --dry-run
    [ "$status" -eq 0 ]
    local shard_count total_count
    shard_count=$(printf '%s\n' "$output" | grep -c '\.bats$')
    total_count=$(ls "$BATS_TEST_DIRNAME"/*.bats | wc -l | tr -d ' ')
    [ "$shard_count" -eq "$total_count" ]
}

@test "test.sh --shard rejects an out-of-range index" {
    run "$TEST_SCRIPT" --shard 5/4 --dry-run
    [ "$status" -ne 0 ]
}

@test "test.sh --shard rejects a zero index" {
    run "$TEST_SCRIPT" --shard 0/4 --dry-run
    [ "$status" -ne 0 ]
}

@test "test.sh --shard rejects a malformed spec" {
    run "$TEST_SCRIPT" --shard abc --dry-run
    [ "$status" -ne 0 ]
}
