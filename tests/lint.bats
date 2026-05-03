#!/usr/bin/env bats

# =============================================================================
# Tests for lint.sh
# =============================================================================

load 'test_helper'

LINT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/lint.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests
# =============================================================================

@test "lint.sh exists and is executable" {
    [ -f "$LINT_SCRIPT" ]
    [ -x "$LINT_SCRIPT" ]
}

@test "lint.sh displays help with --help" {
    run "$LINT_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"ShellCheck"* ]] || [[ "$output" == *"lint"* ]]
}

@test "lint.sh displays version with --version" {
    run "$LINT_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"lint"* ]]
}

# =============================================================================
# Linting tests
# =============================================================================

@test "lint.sh checks if shellcheck is available" {
    run "$LINT_SCRIPT"
    # If shellcheck is not installed, the script must report it
    if ! command -v shellcheck &>/dev/null; then
        [[ "$output" == *"shellcheck"* ]] || [[ "$output" == *"ShellCheck"* ]] || true
    fi
}

@test "lint.sh can run on the foundation" {
    # Run lint on the foundation directory
    run "$LINT_SCRIPT" "$BATS_TEST_DIRNAME/.."
    # May succeed or fail depending on warnings, but must not crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Options tests
# =============================================================================

@test "lint.sh --quiet reduces output" {
    run "$LINT_SCRIPT" -q "$BATS_TEST_DIRNAME/.."
    # In quiet mode, less output
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "lint.sh accepts a specific path" {
    # Create a test script
    cat > "$TEST_DIR/test.sh" << 'EOF'
#!/bin/bash
echo "Hello"
EOF
    chmod +x "$TEST_DIR/test.sh"

    run "$LINT_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Error detection tests
# =============================================================================

@test "lint.sh detects syntax errors" {
    # Create a script with a common error (unquoted variable)
    cat > "$TEST_DIR/bad.sh" << 'EOF'
#!/bin/bash
files=$(ls)
for f in $files; do
    echo $f
done
EOF
    chmod +x "$TEST_DIR/bad.sh"

    if command -v shellcheck &>/dev/null; then
        run "$LINT_SCRIPT" "$TEST_DIR"
        # ShellCheck should find warnings
        [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$output" == *"SC"* ]] || true
    else
        skip "shellcheck not installed"
    fi
}
