#!/usr/bin/env bats

# =============================================================================
# Tests for doctor.sh
# =============================================================================

load 'test_helper'

DOCTOR_SCRIPT="$BATS_TEST_DIRNAME/../scripts/doctor.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests
# =============================================================================

@test "doctor.sh exists and is executable" {
    [ -f "$DOCTOR_SCRIPT" ]
    [ -x "$DOCTOR_SCRIPT" ]
}

@test "doctor.sh displays help with --help" {
    run "$DOCTOR_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
}

@test "doctor.sh displays version with --version" {
    run "$DOCTOR_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"doctor"* ]]
}

# =============================================================================
# System diagnostic tests
# =============================================================================

@test "doctor.sh checks bash" {
    run "$DOCTOR_SCRIPT" -q
    # The script may succeed or fail depending on the environment
    # but must run without crashing
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh detects git" {
    run "$DOCTOR_SCRIPT"
    [[ "$output" == *"git"* ]]
}

# =============================================================================
# Project diagnostic tests
# =============================================================================

@test "doctor.sh works on an unconfigured project" {
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    # Must run (may have warnings)
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh detects missing .claude" {
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *".claude"* ]] || [[ "$output" == *"Claude"* ]]
}

@test "doctor.sh validates a well-configured project" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    # A minimal project should have fewer issues
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh detects CLAUDE.md" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "doctor.sh detects settings.json" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"settings"* ]]
}

# =============================================================================
# JSON mode tests
# =============================================================================

@test "doctor.sh --json returns valid JSON" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" --json "$TEST_DIR"
    # Verify that it is valid JSON
    echo "$output" | jq . > /dev/null 2>&1
    [ $? -eq 0 ]
}

@test "doctor.sh --json contains the expected keys" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" --json "$TEST_DIR"
    # Verify the presence of keys
    echo "$output" | jq -e '.checks' > /dev/null 2>&1 || \
    echo "$output" | jq -e '.status' > /dev/null 2>&1 || \
    echo "$output" | jq -e '.passed' > /dev/null 2>&1
}

# =============================================================================
# Dependency check tests
# =============================================================================

@test "doctor.sh mentions optional dependencies" {
    run "$DOCTOR_SCRIPT"
    # Should mention at least one optional dependency
    [[ "$output" == *"jq"* ]] || \
    [[ "$output" == *"node"* ]] || \
    [[ "$output" == *"python"* ]]
}

# =============================================================================
# Foundation integrity tests
# =============================================================================

@test "doctor.sh checks foundation integrity" {
    # The foundation itself should pass the check
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    # May have warnings but should not crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh counts agents" {
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [[ "$output" == *"agent"* ]] || [[ "$output" == *"command"* ]]
}

@test "doctor.sh counts skills" {
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [[ "$output" == *"skill"* ]]
}

# =============================================================================
# Section 6: security drift (#12)
# =============================================================================

@test "doctor.sh warns on a legacy TOOL_*-env hook in the target" {
    create_minimal_project "$TEST_DIR"
    mkdir -p "$TEST_DIR/scripts/hooks"
    cat > "$TEST_DIR/scripts/hooks/command-validator.sh" <<'EOF'
#!/usr/bin/env bash
CMD="$TOOL_INPUT"
exit 0
EOF
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"command-validator.sh"* ]]
    [[ "$output" == *"drift"* ]] || [[ "$output" == *"Security"* ]]
}

@test "doctor.sh warns on a bare mcp__* wildcard in permissions.allow" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    cat > "$TEST_DIR/.claude/settings.json" <<'EOF'
{ "permissions": { "allow": ["Read", "mcp__*"] } }
EOF
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"mcp-allow"* ]]
}

@test "doctor.sh reports no security drift on a clean project" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    # Assert the explicit clean verdict, not just the (always-printed) section title.
    [[ "$output" == *"No security drift detected"* ]]
}

@test "doctor.sh --json stays valid with the security-drift section" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    mkdir -p "$TEST_DIR/scripts/hooks"
    printf '#!/usr/bin/env bash\nCMD="$TOOL_INPUT"\n' > "$TEST_DIR/scripts/hooks/x.sh"
    run "$DOCTOR_SCRIPT" --json "$TEST_DIR"
    echo "$output" | jq -e '.checks' > /dev/null
}
