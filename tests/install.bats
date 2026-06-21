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

# =============================================================================
# --ref <tag>: release pinning (opt-in; no --ref keeps the current main behavior)
# =============================================================================

@test "install.sh --help documents --ref" {
    run "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--ref"* ]]
}

@test "install.sh fails when --ref has no argument" {
    run "$INSTALL_SCRIPT" --ref
    [ "$status" -ne 0 ]
    [[ "$output" == *"--ref"* ]]
}

@test "install.sh --ref --dry-run prints git clone --branch <tag>" {
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --ref v5.0.0 --dry-run
    [ "$status" -eq 0 ]
    # run() echoes the command with the path/ref args still quoted, so match the
    # --branch flag and the tag value separately (same style as the clone test above).
    [[ "$output" == *"--branch"* ]]
    [[ "$output" == *"v5.0.0"* ]]
}

@test "install.sh without --ref does not pin (no --branch in clone)" {
    run "$INSTALL_SCRIPT" --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"git clone"* ]]
    [[ "$output" != *"--branch"* ]]
}

@test "install.sh --ref clones the tag and records the pin under .git" {
    local repo="$TEST_DIR/fake-remote"
    create_fake_foundation_repo "$repo"
    CLAUDE_BASE_REPO_URL="file://$repo" run "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --ref v1.0.0
    [ "$status" -eq 0 ]
    # HEAD is parked on the requested tag
    run git -C "$INSTALL_TARGET" describe --tags --exact-match HEAD
    [ "$status" -eq 0 ]
    [[ "$output" == "v1.0.0" ]]
    # The pin is recorded so --update stays pinned
    [ -f "$INSTALL_TARGET/.git/claude-base-ref" ]
    [[ "$(cat "$INSTALL_TARGET/.git/claude-base-ref")" == "v1.0.0" ]]
}

@test "install.sh --update on a pinned install is a no-op and never jumps to main" {
    local repo="$TEST_DIR/fake-remote"
    create_fake_foundation_repo "$repo"
    CLAUDE_BASE_REPO_URL="file://$repo" "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --ref v1.0.0
    # Update with no --ref: must stay on v1.0.0 and tell the user it's pinned
    CLAUDE_BASE_REPO_URL="file://$repo" run "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --update
    [ "$status" -eq 0 ]
    [[ "$output" == *"pinned"* ]]
    run git -C "$INSTALL_TARGET" describe --tags --exact-match HEAD
    [[ "$output" == "v1.0.0" ]]
}

@test "install.sh --update --ref moves a pinned install to the new tag" {
    local repo="$TEST_DIR/fake-remote"
    create_fake_foundation_repo "$repo"
    CLAUDE_BASE_REPO_URL="file://$repo" "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --ref v1.0.0
    CLAUDE_BASE_REPO_URL="file://$repo" run "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --update --ref v2.0.0
    [ "$status" -eq 0 ]
    run git -C "$INSTALL_TARGET" describe --tags --exact-match HEAD
    [[ "$output" == "v2.0.0" ]]
    [[ "$(cat "$INSTALL_TARGET/.git/claude-base-ref")" == "v2.0.0" ]]
}

@test "install.sh --update --ref <missing> leaves the existing install intact" {
    local repo="$TEST_DIR/fake-remote"
    create_fake_foundation_repo "$repo"
    CLAUDE_BASE_REPO_URL="file://$repo" "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --ref v1.0.0
    # A bad tag must fail without destroying the working install (no rm-before-clone)
    CLAUDE_BASE_REPO_URL="file://$repo" run "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --update --ref v9.9.9-nope
    [ "$status" -ne 0 ]
    [ -d "$INSTALL_TARGET/.git" ]
    run git -C "$INSTALL_TARGET" describe --tags --exact-match HEAD
    [[ "$output" == "v1.0.0" ]]
    [[ "$(cat "$INSTALL_TARGET/.git/claude-base-ref")" == "v1.0.0" ]]
}

@test "install.sh --update on a non-pinned (main) install still fast-forwards" {
    local repo="$TEST_DIR/fake-remote"
    create_fake_foundation_repo "$repo"
    # Plain clone (no --ref) → not pinned, even though the tip is a tagged commit
    CLAUDE_BASE_REPO_URL="file://$repo" "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN"
    [ ! -f "$INSTALL_TARGET/.git/claude-base-ref" ]
    # Advance the remote default branch, then update should pull it
    echo "2.0.1" > "$repo/VERSION"
    git -C "$repo" add -A
    git -C "$repo" commit -q -m "v2.0.1-dev"
    CLAUDE_BASE_REPO_URL="file://$repo" run "$INSTALL_SCRIPT" \
        --target "$INSTALL_TARGET" --bin "$INSTALL_BIN" --update
    [ "$status" -eq 0 ]
    [[ "$output" != *"pinned"* ]]
    [[ "$(cat "$INSTALL_TARGET/VERSION")" == "2.0.1" ]]
}
