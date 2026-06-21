#!/usr/bin/env bats

# =============================================================================
# Tests for lib/common.sh
# =============================================================================

load 'test_helper'

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests for utility functions
# =============================================================================

@test "command_exists returns 0 for an existing command" {
    run command_exists bash
    [ "$status" -eq 0 ]
}

@test "command_exists returns 1 for a non-existing command" {
    run command_exists commande_inexistante_xyz
    [ "$status" -eq 1 ]
}

@test "get_absolute_path converts a relative path" {
    cd "$TEST_DIR"
    mkdir -p subdir
    run get_absolute_path "subdir"
    [ "$status" -eq 0 ]
    [[ "$output" == "$TEST_DIR/subdir" ]]
}

@test "count_files counts files correctly" {
    touch "$TEST_DIR/file1.md"
    touch "$TEST_DIR/file2.md"
    touch "$TEST_DIR/file3.txt"
    run count_files "$TEST_DIR" "*.md"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

@test "count_dirs counts directories correctly" {
    mkdir -p "$TEST_DIR/dir1"
    mkdir -p "$TEST_DIR/dir2"
    touch "$TEST_DIR/file.txt"
    run count_dirs "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

# =============================================================================
# Tests for JSON validation functions
# =============================================================================

@test "validate_json returns 0 for valid JSON" {
    skip_if_no_jq
    echo '{"key": "value"}' > "$TEST_DIR/valid.json"
    run validate_json "$TEST_DIR/valid.json"
    [ "$status" -eq 0 ]
}

@test "validate_json returns 1 for invalid JSON" {
    skip_if_no_jq
    echo '{key: value}' > "$TEST_DIR/invalid.json"
    run validate_json "$TEST_DIR/invalid.json"
    [ "$status" -eq 1 ]
}

@test "validate_json returns 1 for a non-existing file" {
    run validate_json "$TEST_DIR/nonexistent.json"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests for versioning functions
# =============================================================================

@test "version_gte returns 0 if v1 >= v2" {
    run version_gte "2.0.0" "1.5.0"
    [ "$status" -eq 0 ]
}

@test "version_gte returns 0 if v1 == v2" {
    run version_gte "1.5.0" "1.5.0"
    [ "$status" -eq 0 ]
}

@test "version_gte returns 1 if v1 < v2" {
    run version_gte "1.0.0" "2.0.0"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests for foundation version recording (record_foundation_version)
# Since specs/foundation-modules: writes .claude/foundation.json (manifest),
# never the legacy .foundation-version marker (EF-204/EF-205).
# =============================================================================

@test "record_foundation_version creates the manifest with the version" {
    mkdir -p "$TEST_DIR/.claude"
    run record_foundation_version "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
    [ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" = "1.37.0" ]
}

@test "record_foundation_version defaults to no preset and empty module set (v3 opt-in)" {
    run record_foundation_version "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ "$(jq -r '.preset' "$TEST_DIR/.claude/foundation.json")" = "null" ]
    # v3: horizontal domains are opt-in — no modules recorded by default.
    [ "$(jq -r '.modules | sort | join(",")' "$TEST_DIR/.claude/foundation.json")" = "" ]
}

@test "record_foundation_version creates .claude/ and target_dir if missing" {
    local nested="$TEST_DIR/new/nested/project"
    [ ! -d "$nested" ]
    run record_foundation_version "$nested" "1.37.0"
    [ "$status" -eq 0 ]
    [ -f "$nested/.claude/foundation.json" ]
}

@test "record_foundation_version is idempotent (same args produce same content)" {
    record_foundation_version "$TEST_DIR" "1.37.0"
    local first_sha
    first_sha=$(sha256sum "$TEST_DIR/.claude/foundation.json" | cut -d' ' -f1)

    record_foundation_version "$TEST_DIR" "1.37.0"
    local second_sha
    second_sha=$(sha256sum "$TEST_DIR/.claude/foundation.json" | cut -d' ' -f1)

    [ "$first_sha" = "$second_sha" ]
}

@test "record_foundation_version updates version but preserves preset and modules" {
    # An existing manifest (e.g. written at init with a preset and a module
    # subset) must keep its preset/modules when update bumps the version.
    source "$BATS_TEST_DIRNAME/../scripts/lib/modules.sh"
    write_foundation_manifest "$TEST_DIR" "1.36.0" "nextjs" legal
    run record_foundation_version "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" = "1.37.0" ]
    [ "$(jq -r '.preset' "$TEST_DIR/.claude/foundation.json")" = "nextjs" ]
    [ "$(jq -r '.modules | join(",")' "$TEST_DIR/.claude/foundation.json")" = "legal" ]
}

@test "record_foundation_version removes a stale legacy marker" {
    mkdir -p "$TEST_DIR/.claude"
    echo "1.36.0" > "$TEST_DIR/.claude/.foundation-version"
    run record_foundation_version "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
}

@test "record_foundation_version returns 1 if target_dir is empty" {
    run record_foundation_version "" "1.37.0"
    [ "$status" -eq 1 ]
}

@test "record_foundation_version returns 1 if version is empty" {
    run record_foundation_version "$TEST_DIR" ""
    [ "$status" -eq 1 ]
}

@test "write_foundation_marker is a deprecated alias for record_foundation_version" {
    # Legacy name kept for downstream sourcers of lib/common.sh — same
    # behavior, plus a one-line deprecation notice on stderr.
    run write_foundation_marker "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    [ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" = "1.37.0" ]
    [[ "$output" == *"deprecated"* ]]
    [[ "$output" == *"record_foundation_version"* ]]
}

# =============================================================================
# Tests for foundation version reading (read_foundation_marker_from_project)
# Manifest-first; falls back to the legacy marker (pure read, migration is
# triggered elsewhere — EF-205).
# =============================================================================

@test "read_foundation_marker_from_project reads the manifest version" {
    record_foundation_version "$TEST_DIR" "1.37.0"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.37.0" ]
}

@test "read_foundation_marker_from_project falls back to the legacy marker" {
    mkdir -p "$TEST_DIR/.claude"
    printf '%s\n' "1.36.0" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.36.0" ]
}

@test "read_foundation_marker_from_project prefers manifest over legacy marker" {
    record_foundation_version "$TEST_DIR" "1.37.0"
    printf '%s\n' "1.30.0" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.37.0" ]
}

@test "read_foundation_marker_from_project returns empty when nothing exists" {
    mkdir -p "$TEST_DIR/.claude"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "read_foundation_marker_from_project returns empty when target_dir does not exist" {
    run read_foundation_marker_from_project "$TEST_DIR/nonexistent"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "read_foundation_marker_from_project returns empty when arg is empty" {
    run read_foundation_marker_from_project ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "read_foundation_marker_from_project has no side effects (pure read)" {
    [ ! -d "$TEST_DIR/.claude" ]
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.claude" ]
}

@test "read_foundation_marker_from_project legacy fallback reads first line only" {
    mkdir -p "$TEST_DIR/.claude"
    printf '%s\n%s\n' "1.36.0" "extra-line" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.36.0" ]
}

@test "read_foundation_marker_from_project round-trips with record_foundation_version" {
    record_foundation_version "$TEST_DIR" "1.42.0"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.42.0" ]
}

# =============================================================================
# Tests for foundation statistics
# =============================================================================

@test "count_agents counts .md files in commands" {
    create_minimal_project
    create_test_command "test-agent"
    run count_agents "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
}

@test "count_agents counts .md files in subdirectories" {
    create_minimal_project
    create_test_command_in_subdir "work" "work-explore"
    create_test_command_in_subdir "work" "work-plan"
    create_test_command_in_subdir "dev" "dev-tdd"
    run count_agents "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 3 ]
}

@test "count_skills counts directories in skills" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/skills/skill1"
    mkdir -p "$TEST_DIR/.claude/skills/skill2"
    run count_skills "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

# =============================================================================
# Tests for display functions (smoke tests)
# =============================================================================

@test "title does not produce an error" {
    run title "Test Title"
    [ "$status" -eq 0 ]
}

@test "section does not produce an error" {
    run section "Test Section"
    [ "$status" -eq 0 ]
}

@test "separator does not produce an error" {
    run separator
    [ "$status" -eq 0 ]
}

@test "success does not produce an error" {
    run success "Test success"
    [ "$status" -eq 0 ]
}

@test "warning does not produce an error" {
    run warning "Test warning"
    [ "$status" -eq 0 ]
}

@test "info does not produce an error" {
    run info "Test info"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Tests BASE_DIR (via test_helper)
# =============================================================================

@test "BASE_DIR is defined and points to the foundation" {
    [ -n "$BASE_DIR" ]
    [ -d "$BASE_DIR" ]
    [ -d "$BASE_DIR/scripts" ]
    [ -f "$BASE_DIR/VERSION" ]
}

@test "check_base_requirements requires jq (foundation-modules hard dependency)" {
    # Override command_exists to simulate a machine without jq: every other
    # tool resolves, jq does not. record_foundation_version now needs jq on
    # every install path, so the requirements gate must catch it upfront.
    run bash -c "source '$BATS_TEST_DIRNAME/../scripts/lib/common.sh'; command_exists() { [[ \"\$1\" != jq ]]; }; check_base_requirements"
    [ "$status" -ne 0 ]
    [[ "$output" == *"jq"* ]]
}

# =============================================================================
# Security drift detection (#12): legacy hook contract + invalid mcp__ allow
# =============================================================================

# Write a hook script reading tool input from the legacy TOOL_* env contract.
_write_legacy_hook() {
    cat > "$1" <<'EOF'
#!/usr/bin/env bash
# legacy: reads the payload from an environment variable, never from stdin
CMD="$TOOL_INPUT"
case "$CMD" in
  *rm\ -rf*) echo "blocked"; exit 2 ;;
esac
exit 0
EOF
}

# Write a hook script reading tool input from stdin via jq (modern contract).
_write_modern_hook() {
    cat > "$1" <<'EOF'
#!/usr/bin/env bash
INPUT=$(cat)
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
exit 0
EOF
}

@test "hook_uses_legacy_contract: true for a TOOL_*-env hook with no stdin read" {
    _write_legacy_hook "$TEST_DIR/legacy.sh"
    run hook_uses_legacy_contract "$TEST_DIR/legacy.sh"
    [ "$status" -eq 0 ]
}

@test "hook_uses_legacy_contract: false for a stdin/jq hook (even one naming a TOOL_NAME var)" {
    _write_modern_hook "$TEST_DIR/modern.sh"
    run hook_uses_legacy_contract "$TEST_DIR/modern.sh"
    [ "$status" -ne 0 ]
}

@test "hook_uses_legacy_contract: false for a hook that reads no tool input at all" {
    printf '#!/usr/bin/env bash\necho hello\nexit 0\n' > "$TEST_DIR/noinput.sh"
    run hook_uses_legacy_contract "$TEST_DIR/noinput.sh"
    [ "$status" -ne 0 ]
}

@test "detect_security_drift: flags a legacy-contract hook in the target" {
    mkdir -p "$TEST_DIR/scripts/hooks" "$TEST_DIR/.claude"
    _write_legacy_hook "$TEST_DIR/scripts/hooks/command-validator.sh"
    run detect_security_drift "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"command-validator.sh"* ]]
    [[ "$output" == *"hook-contract"* ]]
}

@test "detect_security_drift: flags the bare mcp__* wildcard in permissions.allow" {
    skip_if_no_jq
    mkdir -p "$TEST_DIR/.claude"
    cat > "$TEST_DIR/.claude/settings.json" <<'EOF'
{ "permissions": { "allow": ["Read", "mcp__*", "Bash"] } }
EOF
    run detect_security_drift "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"mcp-allow"* ]]
    [[ "$output" == *"mcp__*"* ]]
}

@test "detect_security_drift: does NOT flag fully-qualified mcp__ grants (valid)" {
    skip_if_no_jq
    mkdir -p "$TEST_DIR/.claude"
    cat > "$TEST_DIR/.claude/settings.json" <<'EOF'
{ "permissions": { "allow": ["Read", "mcp__github__create_issue", "mcp__filesystem__read_text_file"] } }
EOF
    run detect_security_drift "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "hook_uses_legacy_contract: a 'jq' mention in a COMMENT does not mask legacy drift" {
    cat > "$TEST_DIR/sneaky.sh" <<'EOF'
#!/usr/bin/env bash
# we used to pipe this through jq from /dev/stdin
CMD="$TOOL_INPUT"
exit 0
EOF
    run hook_uses_legacy_contract "$TEST_DIR/sneaky.sh"
    [ "$status" -eq 0 ]
}

@test "detect_security_drift: clean target (modern hooks, no mcp allow) returns 0" {
    skip_if_no_jq
    mkdir -p "$TEST_DIR/scripts/hooks" "$TEST_DIR/.claude"
    _write_modern_hook "$TEST_DIR/scripts/hooks/command-validator.sh"
    echo '{ "permissions": { "allow": ["Read", "Bash"] } }' > "$TEST_DIR/.claude/settings.json"
    run detect_security_drift "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "detect_security_drift: no settings.json and no hooks dir is a silent no-op" {
    run detect_security_drift "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "detect_security_drift: the foundation's own current hooks report ZERO drift" {
    # Anti-false-positive guard: the modern foundation must never flag itself
    # (covers the base-integrity-check.sh TOOL_NAME=$(jq ...) trap).
    run detect_security_drift "$BASE_DIR"
    [ "$status" -eq 0 ]
}
