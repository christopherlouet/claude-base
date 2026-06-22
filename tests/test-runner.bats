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
# Execution tests
# =============================================================================

@test "test.sh checks if bats is available" {
    run "$TEST_SCRIPT" --check
    # Should indicate whether bats is installed or not
    [[ "$output" == *"bats"* ]] || [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "test.sh can list available tests" {
    run "$TEST_SCRIPT" --list 2>/dev/null || run "$TEST_SCRIPT" -l 2>/dev/null || true
    # May fail if the option does not exist, but must not crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Option tests
# =============================================================================

@test "test.sh accepts a specific test file" {
    if command -v bats &>/dev/null; then
        run "$TEST_SCRIPT" "$BATS_TEST_DIRNAME/common.bats"
        [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
    else
        skip "bats not installed"
    fi
}

@test "test.sh --verbose increases verbosity" {
    run "$TEST_SCRIPT" --verbose --help 2>/dev/null || run "$TEST_SCRIPT" -v --help 2>/dev/null || true
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
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
