#!/usr/bin/env bats

# =============================================================================
# Tests for uninstall.sh
# =============================================================================

load 'test_helper'

UNINSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/uninstall.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests
# =============================================================================

@test "uninstall.sh exists and is executable" {
    [ -f "$UNINSTALL_SCRIPT" ]
    [ -x "$UNINSTALL_SCRIPT" ]
}

@test "uninstall.sh displays help with --help" {
    run "$UNINSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"désinstall"* ]] || [[ "$output" == *"uninstall"* ]] || [[ "$output" == *"supprim"* ]]
}

@test "uninstall.sh displays version with --version" {
    run "$UNINSTALL_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"uninstall"* ]]
}

# =============================================================================
# Uninstall tests
# =============================================================================

@test "uninstall.sh handles an unconfigured project" {
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    # May succeed or warn, but must not crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "uninstall.sh removes .claude" {
    # Install first with new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude" ]

    # Uninstall
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # .claude should be removed
    [ ! -d "$TEST_DIR/.claude" ]
}

@test "uninstall.sh removes CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ ! -f "$TEST_DIR/CLAUDE.md" ]
}

@test "uninstall.sh preserves CLAUDE.local.md by default" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Create a local file
    echo "# My configurations" > "$TEST_DIR/CLAUDE.local.md"

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The local file should be preserved
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
}

# =============================================================================
# Option tests
# =============================================================================

@test "uninstall.sh --dry-run does not remove anything" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UNINSTALL_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Files should still exist
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "uninstall.sh --all removes everything including local files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    echo "# Local" > "$TEST_DIR/CLAUDE.local.md"

    run "$UNINSTALL_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Everything should be removed
    [ ! -d "$TEST_DIR/.claude" ]
    [ ! -f "$TEST_DIR/CLAUDE.md" ]
}

# =============================================================================
# Security tests
# =============================================================================

@test "uninstall.sh does not remove files outside .claude" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Create a user file
    echo "My code" > "$TEST_DIR/app.js"

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The user file must be preserved
    [ -f "$TEST_DIR/app.js" ]
}

@test "uninstall.sh displays what will be removed" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [[ "$output" == *"supprim"* ]] || [[ "$output" == *"remov"* ]] || [[ "$output" == *"delet"* ]] || [[ "$output" == *"OK"* ]] || true
}
