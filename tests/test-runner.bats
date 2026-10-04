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

# shard_loads <table> — the summed measured seconds of each of the 4 shards,
# one per line, read from the same table test.sh weights by.
shard_loads() {
    local table="$1" i
    for i in 1 2 3 4; do
        TEST_DURATIONS="$table" "$TEST_SCRIPT" --shard "$i/4" --dry-run 2>/dev/null \
            | awk -F/ '{print $NF}' \
            | awk -v t="$table" 'BEGIN { while ((getline l < t) > 0) { split(l, a, "\t"); d[a[1]] = a[2] } }
                                 { s += d[$0] } END { printf "%d\n", s }'
    done
}

@test "test.sh --shard balances shards by measured duration" {
    # Measured 2026-10-04: weighting by line count gave shards of 194/862/395/378 s
    # (the slowest shard set every CI run's wall time); by duration, 457 each.
    local table="$BATS_TEST_DIRNAME/../scripts/test-durations.tsv"
    [ -f "$table" ]
    local loads max min sum ideal
    loads=$(shard_loads "$table")
    max=$(printf '%s\n' "$loads" | sort -n | tail -1)
    min=$(printf '%s\n' "$loads" | sort -n | head -1)
    sum=$(printf '%s\n' "$loads" | awk '{s += $1} END {print s}')
    ideal=$(( sum / 4 ))
    echo "loads: $(printf '%s ' $loads) ideal=$ideal" >&3
    # the slowest shard stays within 15% of an even split
    [ "$max" -le $(( ideal * 115 / 100 )) ]
    [ "$min" -gt 0 ]
}

@test "test.sh --shard still partitions every file when the table misses some" {
    # A new test file is not in the table yet: it gets an estimate, never dropped.
    local partial="$TEST_DIR/partial.tsv"
    head -20 "$BATS_TEST_DIRNAME/../scripts/test-durations.tsv" > "$partial"
    local total all="" i
    total=$(ls "$BATS_TEST_DIRNAME"/*.bats | wc -l | tr -d ' ')
    for i in 1 2 3 4; do
        run env TEST_DURATIONS="$partial" "$TEST_SCRIPT" --shard "$i/4" --dry-run
        [ "$status" -eq 0 ]
        all+="$output"$'\n'
    done
    [ "$(printf '%s' "$all" | grep -c '\.bats$')" -eq "$total" ]
    [ "$(printf '%s' "$all" | grep -o '[^/]*\.bats$' | sort -u | wc -l | tr -d ' ')" -eq "$total" ]
}

@test "test.sh --shard falls back to line counts without a duration table" {
    local total all="" i
    total=$(ls "$BATS_TEST_DIRNAME"/*.bats | wc -l | tr -d ' ')
    for i in 1 2 3 4; do
        run env TEST_DURATIONS="$TEST_DIR/none.tsv" "$TEST_SCRIPT" --shard "$i/4" --dry-run
        [ "$status" -eq 0 ]
        all+="$output"$'\n'
    done
    [ "$(printf '%s' "$all" | grep -c '\.bats$')" -eq "$total" ]
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
