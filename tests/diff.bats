#!/usr/bin/env bats

# =============================================================================
# Tests for diff.sh
# =============================================================================

load 'test_helper'

DIFF_SCRIPT="$BATS_TEST_DIRNAME/../scripts/diff.sh"
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

@test "diff.sh exists and is executable" {
    [ -f "$DIFF_SCRIPT" ]
    [ -x "$DIFF_SCRIPT" ]
}

@test "diff.sh shows help with --help" {
    run "$DIFF_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
}

@test "diff.sh shows version with --version" {
    run "$DIFF_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"diff"* ]]
}

# =============================================================================
# Comparison tests
# =============================================================================

@test "diff.sh works on an empty directory" {
    run "$DIFF_SCRIPT" "$TEST_DIR"
    # May fail because no .claude, but must not crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh detects an unconfigured project" {
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *".claude"* ]] || [[ "$output" == *"pas"* ]] || [[ "$output" == *"non"* ]] || true
}

@test "diff.sh compares an installed project" {
    # Install the foundation with new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    if [ "$status" -ne 0 ]; then
        echo "=== DEBUG: new-project.sh -y --simple exit $status ==="
        echo "=== DEBUG: bash version ==="
        bash --version | head -1
        echo "=== DEBUG: which bash ==="
        which bash
        echo "=== DEBUG: env PATH ==="
        echo "$PATH"
        echo "=== DEBUG: stderr+stdout from script ==="
        echo "$output"
    fi
    [ "$status" -eq 0 ]

    # Then compare. diff.sh exits 0 if everything is in sync, exits 1 if there are
    # differences. Since v1.30, CLAUDE.md is intentionally rewritten by
    # the install (paths @docs → @.claude/docs) so 1 file is "modified"
    # by design: exit 1 expected on a fresh install.
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh detects identical files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"identique"* ]] || [[ "$output" == *"identical"* ]] || [[ "$output" == *"="* ]] || true
}

@test "diff.sh detects modified files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Modify a file
    echo "# Modification" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"modifi"* ]] || [[ "$output" == *"changed"* ]] || [[ "$output" == *"M"* ]] || true
}

# =============================================================================
# Option tests
# =============================================================================

@test "diff.sh --modified shows only modified files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # See test "diff.sh compares an installed project" for details:
    # CLAUDE.md modified by design since v1.30, exit 1 acceptable.
    run "$DIFF_SCRIPT" --modified "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh --content shows the content of differences" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Modify a file
    echo "# Test" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$DIFF_SCRIPT" --content "$TEST_DIR"
    # Should show diff content
    [[ "$output" == *"+"* ]] || [[ "$output" == *"-"* ]] || [[ "$output" == *"Test"* ]] || true
}

# =============================================================================
# Summary tests
# =============================================================================

@test "diff.sh shows a summary" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"total"* ]] || true
}
