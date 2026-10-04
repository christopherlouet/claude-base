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

# _locale_awk_shim — a PATH dir whose `awk` is mawk (Ubuntu's default awk),
# the implementation that follows LC_NUMERIC; empty when mawk or a comma-decimal
# locale is missing (the tests then skip, saying why).
_locale_awk_shim() {
    command -v mawk >/dev/null 2>&1 || return 1
    locale -a 2>/dev/null | grep -qi '^fr_FR\.utf-\?8$' || return 1
    mkdir -p "$TEST_DIR/shim"
    ln -sf "$(command -v mawk)" "$TEST_DIR/shim/awk"
    printf '%s' "$TEST_DIR/shim"
}

@test "test.sh --shard gives the same partition under a comma-decimal locale" {
    # mawk under fr_FR read "348.7" as 348: the weights, and so the split, changed.
    local shim
    shim=$(_locale_awk_shim) || skip "needs mawk and the fr_FR.UTF-8 locale"
    local c fr i
    for i in 1 2 3 4; do
        c+=$(LC_ALL=C "$TEST_SCRIPT" --shard "$i/4" --dry-run | md5sum)
        fr+=$(PATH="$shim:$PATH" LC_ALL=fr_FR.UTF-8 "$TEST_SCRIPT" --shard "$i/4" --dry-run | md5sum)
    done
    [ "$c" = "$fr" ]
}

@test "measure-test-durations writes dot decimals under a comma-decimal locale" {
    local shim
    shim=$(_locale_awk_shim) || skip "needs mawk and the fr_FR.UTF-8 locale"
    cat > "$TEST_DIR/report.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<testsuites time="1.5">
<testsuite name="a.bats" tests="2" failures="0" errors="0" skipped="0" time="1.2" timestamp="x" hostname="h">
    <testcase classname="a" name="one" time="0.7" />
    <testcase classname="a" name="two &amp; &quot;more&quot;" time="0.5" />
</testsuite>
<testsuite name="b.bats" tests="1" failures="0" errors="0" skipped="0" time="0.3" timestamp="x" hostname="h">
    <testcase classname="b" name="three" time="0.3" />
</testsuite>
</testsuites>
XML
    run env PATH="$shim:$PATH" LC_ALL=fr_FR.UTF-8 \
        "$BATS_TEST_DIRNAME/../scripts/measure-test-durations.sh" --from-report "$TEST_DIR/report.xml" --out "$TEST_DIR/d.tsv"
    [ "$status" -eq 0 ]
    [ "$(cat "$TEST_DIR/d.tsv")" = "$(printf 'a.bats\t1.2\nb.bats\t0.3')" ]
}

@test "test.sh --shard weights a file missing from the table on the table's scale" {
    # A file absent from the table is estimated as lines x the table's ms per
    # line — tens of ms per line — not as its raw line count (~1000x too light).
    local partial="$TEST_DIR/partial.tsv" f="test-runner.bats" lines w
    grep -v "^$f	" "$BATS_TEST_DIRNAME/../scripts/test-durations.tsv" > "$partial"
    lines=$(wc -l < "$BATS_TEST_DIRNAME/$f" | tr -d ' ')
    w=$(TEST_SHARD_DEBUG=1 TEST_DURATIONS="$partial" "$TEST_SCRIPT" --shard 1/4 --dry-run 2>&1 >/dev/null \
        | awk -F'\t' -v f="$f" '{ n = split($2, p, "/"); if (p[n] == f) print $1 }')
    echo "lines=$lines weight=$w" >&3
    [ -n "$w" ]
    [ "$w" -ge $(( lines * 10 )) ]
}
