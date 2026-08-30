#!/usr/bin/env bats

# =============================================================================
# Tests for doctor.sh
# =============================================================================

load 'test_helper'

DOCTOR_SCRIPT="$BATS_TEST_DIRNAME/../scripts/doctor.sh"

setup() {
    setup_test_dir
    # Provide a stub `claude` CLI so doctor's exit code reflects the health of the
    # TARGET, not whether this machine has the claude binary (CI has none). This
    # makes the exit-0 assertions below deterministic across environments.
    stub_claude_on_path
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

@test "doctor.sh checks bash and passes on the healthy foundation" {
    # Self-application: doctor on the foundation itself must succeed cleanly.
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bash"* ]]
}

@test "doctor.sh detects git" {
    run "$DOCTOR_SCRIPT"
    [[ "$output" == *"git"* ]]
}

# =============================================================================
# Project diagnostic tests
# =============================================================================

@test "doctor.sh exits 0 (warnings only, no failures) on an unconfigured project" {
    # An empty project has no .claude/CLAUDE.md — all WARNINGS, zero FAILURES,
    # so doctor exits 0. This pins that warnings never escalate to a failure.
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Failed:"* ]]
}

@test "doctor.sh detects missing .claude" {
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *".claude"* ]] || [[ "$output" == *"Claude"* ]]
}

@test "doctor.sh exits 0 on a healthy minimal project (known-good fixture)" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "doctor.sh exits 1 and names the problem on invalid settings.json (broken fixture)" {
    # doctor's only fixture-triggerable FAILURE is invalid settings.json JSON
    # (missing settings.json / .claude are warnings only). Exit code contract:
    # CHECKS_FAILED > 0 -> exit 1, else exit 0 (there is no exit 2).
    create_minimal_project "$TEST_DIR"
    printf '{ this is not valid json' > "$TEST_DIR/.claude/settings.json"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"settings.json"* ]]
    [[ "$output" == *"invalid JSON"* ]]
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

@test "doctor.sh checks foundation integrity (foundation passes, exit 0)" {
    # Self-application: the foundation itself must pass doctor with zero failures.
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [ "$status" -eq 0 ]
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

# --- the three surfaces the drift check could not see (2026-08-30) ------------
# A real installed project scored "No security drift detected" while its
# dangerous-command guard was provably dead. The rule was right; it was pointed
# at hook FILES only, so hooks living inline in settings.json, hooks pointing at
# a script that is not on disk, and a stale security policy all went unseen.

@test "doctor.sh flags an INLINE settings.json hook on the legacy TOOL_* contract" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    printf '%s\n' '{ "hooks": { "PostToolUse": [ { "matcher": "Edit", "hooks": [ { "type": "command", "command": "bash -c '"'"'echo \"$TOOL_FILE\" | grep -q x'"'"'" } ] } ] } }' \
        > "$TEST_DIR/.claude/settings.json"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"hook-contract-inline"* ]]
}

# CONTROL - the foundation's OWN inline idiom assigns a shell variable named
# TOOL_FILE *from stdin*. Flagging that would make every healthy project drift.
@test "doctor.sh does NOT flag an inline hook that reads its payload from stdin" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    printf '%s\n' '{ "hooks": { "PostToolUse": [ { "matcher": "Edit", "hooks": [ { "type": "command", "command": "bash -c '"'"'TOOL_FILE=$(cat | jq -r .tool_input.file_path); echo \"$TOOL_FILE\"'"'"'" } ] } ] } }' \
        > "$TEST_DIR/.claude/settings.json"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" != *"hook-contract-inline"* ]]
}

@test "doctor.sh flags a hook pointing at a script that is not on disk" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    printf '%s\n' '{ "hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/command-validator.sh\"" } ] } ] } }' \
        > "$TEST_DIR/.claude/settings.json"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"hook-missing-script"* ]]
    [[ "$output" == *"command-validator.sh"* ]]
}

# CONTROL - the same wiring with the script actually present must stay clean.
@test "doctor.sh does NOT flag a hook whose script is present" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"
    printf '%s\n' '{ "hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/command-validator.sh\"" } ] } ] } }' \
        > "$TEST_DIR/.claude/settings.json"
    mkdir -p "$TEST_DIR/scripts/hooks"
    printf '#!/usr/bin/env bash\nCMD=$(cat)\nexit 0\n' > "$TEST_DIR/scripts/hooks/command-validator.sh"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" != *"hook-missing-script"* ]]
}

@test "doctor.sh flags a security policy that has fallen behind the foundation" {
    create_minimal_project "$TEST_DIR"
    mkdir -p "$TEST_DIR/scripts/hooks"
    cp "$BATS_TEST_DIRNAME/../scripts/hooks/_policy-dangerous-commands.sh" \
       "$TEST_DIR/scripts/hooks/_policy-dangerous-commands.sh"
    printf '# stale copy\n' >> "$TEST_DIR/scripts/hooks/_policy-dangerous-commands.sh"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"policy-stale"* ]]
    [[ "$output" == *"_policy-dangerous-commands.sh"* ]]
}

# CONTROL - a byte-identical policy is not drift.
@test "doctor.sh does NOT flag a policy identical to the foundation's" {
    create_minimal_project "$TEST_DIR"
    mkdir -p "$TEST_DIR/scripts/hooks"
    cp "$BATS_TEST_DIRNAME/../scripts/hooks/_policy-dangerous-commands.sh" \
       "$TEST_DIR/scripts/hooks/_policy-dangerous-commands.sh"
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" != *"policy-stale"* ]]
}

# The hardest constraint: the foundation is the reference, so it must never
# report drift against itself. This is what stops the three new rules from
# being written loosely.
@test "doctor.sh reports no security drift on the foundation itself" {
    skip_if_no_jq
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
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
