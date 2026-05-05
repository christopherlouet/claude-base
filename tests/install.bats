#!/usr/bin/env bats

# =============================================================================
# Tests for install.sh — one-liner installer
#
# Tests run in a sandboxed TEST_DIR with --target / --bin overrides so the
# user's real ~/.local is never touched.
# =============================================================================

load 'test_helper'

INSTALL_SCRIPT="$BATS_TEST_DIRNAME/../install.sh"

setup() {
    setup_test_dir
    INSTALL_TARGET="$TEST_DIR/share/claude-base"
    INSTALL_BIN="$TEST_DIR/bin"
    export INSTALL_TARGET INSTALL_BIN
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic invariants
# =============================================================================

@test "install.sh exists and is executable" {
    [ -f "$INSTALL_SCRIPT" ]
    [ -x "$INSTALL_SCRIPT" ]
}

@test "install.sh shows help with --help" {
    run "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"--target"* ]]
    [[ "$output" == *"--bin"* ]]
    [[ "$output" == *"--update"* ]]
    [[ "$output" == *"--dry-run"* ]]
}

@test "install.sh -h short form works" {
    run "$INSTALL_SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

# =============================================================================
# Argument validation
# =============================================================================

@test "install.sh fails on unknown option" {
    run "$INSTALL_SCRIPT" --not-a-real-flag
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "install.sh fails when --target has no argument" {
    run "$INSTALL_SCRIPT" --target
    [ "$status" -ne 0 ]
    [[ "$output" == *"--target"* ]]
}

@test "install.sh fails when --bin has no argument" {
    run "$INSTALL_SCRIPT" --bin
    [ "$status" -ne 0 ]
    [[ "$output" == *"--bin"* ]]
}

# =============================================================================
# --dry-run
# =============================================================================

@test "install.sh --dry-run does not create the target directory" {
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY-RUN"* ]]
    [ ! -d "$INSTALL_TARGET" ]
}

@test "install.sh --dry-run prints the git clone command" {
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"git clone"* ]]
    [[ "$output" == *"$INSTALL_TARGET"* ]]
}

@test "install.sh --dry-run prints the symlink command" {
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"ln -s"* ]] || [[ "$output" == *"symlink"* ]] || [[ "$output" == *"Linked"* ]]
}

# =============================================================================
# Idempotent behavior on existing install
# =============================================================================

@test "install.sh detects existing install and skips without --update" {
    # Pre-create a fake target with .git/
    mkdir -p "$INSTALL_TARGET/.git"
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN"
    [ "$status" -eq 0 ]
    [[ "$output" == *"already installed"* ]]
}

@test "install.sh refuses to overwrite a non-git directory at target" {
    # Pre-create a non-git dir
    mkdir -p "$INSTALL_TARGET"
    touch "$INSTALL_TARGET/some-existing-file"
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not a git repository"* ]] || [[ "$output" == *"Refusing"* ]]
}

# =============================================================================
# Pre-flight checks
# =============================================================================

@test "install.sh refuses to run as root" {
    # We can't easily simulate root here; skip if not root, since the test
    # would only pass under sudo which is not how bats runs.
    if [ "$(id -u)" -eq 0 ]; then
        run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --dry-run
        [ "$status" -ne 0 ]
        [[ "$output" == *"root"* ]]
    else
        skip "not running as root, cannot test the refusal"
    fi
}

# =============================================================================
# Help text completeness
# =============================================================================

@test "install.sh --help mentions ~/.local/bin and PATH" {
    run "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *".local/bin"* ]] || [[ "$output" == *"PATH"* ]]
}

@test "install.sh --help mentions security disclaimers (no sudo, no rc edit)" {
    run "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"root"* ]] || [[ "$output" == *"sudo"* ]]
    [[ "$output" == *"rc"* ]] || [[ "$output" == *"shell"* ]]
}
