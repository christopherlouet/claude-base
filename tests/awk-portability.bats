#!/usr/bin/env bats

# =============================================================================
# awk-portability.sh — the policy suites replayed under another awk
#
# The hook policies call awk, and a hook runs on the USER's machine: mawk is
# Ubuntu's default awk, busybox is the awk of Alpine images. CI runs gawk
# (ubuntu) and BWK (macOS) only, so mawk and busybox were covered nowhere.
# Measured 2026-09-27: 197/197 policy tests pass under both, and an awk that
# always fails breaks 21 of them — the harness sees awk.
#
# These tests pin the harness on a fixture suite, not on the real one, so they
# stay fast: the real replay is the dedicated CI job.
# =============================================================================

load 'test_helper'

TOOL="$BASE_DIR/scripts/awk-portability.sh"

setup() {
    setup_test_dir
    # A suite whose verdict depends on awk actually working.
    cat > "$TEST_DIR/uses-awk.bats" <<'BATS'
@test "awk splits fields" {
    [ "$(echo 'a b c' | awk '{print $2}')" = "b" ]
}
BATS
    # A suite that never calls awk: a broken awk cannot fail it.
    cat > "$TEST_DIR/no-awk.bats" <<'BATS'
@test "no awk here" {
    [ 1 -eq 1 ]
}
BATS
    # An "implementation" that runs but answers wrong.
    printf '#!/bin/sh\necho wrong\n' > "$TEST_DIR/bad-awk"
    chmod +x "$TEST_DIR/bad-awk"
}

teardown() {
    teardown_test_dir
}

@test "awk-portability: a suite that passes under the named awk passes" {
    command -v mawk >/dev/null || skip "mawk not installed"
    run env AWK_PORTABILITY_TESTS="$TEST_DIR/uses-awk.bats" bash "$TOOL" mawk
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"mawk: ok"* ]]
}

@test "awk-portability: an awk that answers wrong fails the run and is named" {
    run env AWK_PORTABILITY_TESTS="$TEST_DIR/uses-awk.bats" bash "$TOOL" "$TEST_DIR/bad-awk"
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "$output" == *"bad-awk: FAILED"* ]]
}

@test "awk-portability: busybox is reached as 'busybox awk'" {
    command -v busybox >/dev/null || skip "busybox not installed"
    run env AWK_PORTABILITY_TESTS="$TEST_DIR/uses-awk.bats" bash "$TOOL" busybox
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"busybox: ok"* ]]
}

@test "awk-portability: a suite a broken awk cannot fail is refused as blind" {
    # The control: without it, a harness whose shim never reached the tests
    # would report every awk as portable.
    command -v mawk >/dev/null || skip "mawk not installed"
    run env AWK_PORTABILITY_TESTS="$TEST_DIR/no-awk.bats" bash "$TOOL" mawk
    echo "$output"
    [ "$status" -eq 2 ]
    [[ "$output" == *"blind"* ]]
}

@test "awk-portability: a missing implementation is an error, not a pass" {
    run env AWK_PORTABILITY_TESTS="$TEST_DIR/uses-awk.bats" bash "$TOOL" "no-such-awk-$$"
    echo "$output"
    [ "$status" -eq 2 ]
    [[ "$output" == *"no-such-awk-$$"* ]]
}

@test "awk-portability: the default suite is the policy suites" {
    # Guards against the default silently shrinking to nothing.
    run bash "$TOOL" --list
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tests/policy-dangerous-commands.bats"* ]]
    [[ "$output" == *"tests/policy-write-targets.bats"* ]]
}
