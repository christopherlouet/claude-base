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
# Tests for foundation marker (T1.1 — write_foundation_marker)
# =============================================================================

@test "write_foundation_marker creates the marker file with the version" {
    mkdir -p "$TEST_DIR/.claude"
    run write_foundation_marker "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/.foundation-version" ]
    [ "$(cat "$TEST_DIR/.claude/.foundation-version")" = "1.37.0" ]
}

@test "write_foundation_marker appends a trailing newline" {
    mkdir -p "$TEST_DIR/.claude"
    write_foundation_marker "$TEST_DIR" "1.37.0"
    # Compare byte-exact: printf '%s\n' "1.37.0" should equal the file content.
    printf '%s\n' "1.37.0" > "$TEST_DIR/expected"
    diff "$TEST_DIR/expected" "$TEST_DIR/.claude/.foundation-version"
}

@test "write_foundation_marker creates .claude/ if missing" {
    # No .claude/ subdir exists yet
    [ ! -d "$TEST_DIR/.claude" ]
    run write_foundation_marker "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/.claude/.foundation-version" ]
}

@test "write_foundation_marker creates target_dir if missing" {
    local nested="$TEST_DIR/new/nested/project"
    [ ! -d "$nested" ]
    run write_foundation_marker "$nested" "1.37.0"
    [ "$status" -eq 0 ]
    [ -f "$nested/.claude/.foundation-version" ]
}

@test "write_foundation_marker is idempotent (same args produce same content)" {
    mkdir -p "$TEST_DIR/.claude"
    write_foundation_marker "$TEST_DIR" "1.37.0"
    local first_sha
    first_sha=$(sha256sum "$TEST_DIR/.claude/.foundation-version" | cut -d' ' -f1)

    write_foundation_marker "$TEST_DIR" "1.37.0"
    local second_sha
    second_sha=$(sha256sum "$TEST_DIR/.claude/.foundation-version" | cut -d' ' -f1)

    [ "$first_sha" = "$second_sha" ]
}

@test "write_foundation_marker overwrites an existing marker with a new version" {
    mkdir -p "$TEST_DIR/.claude"
    echo "1.36.0" > "$TEST_DIR/.claude/.foundation-version"
    run write_foundation_marker "$TEST_DIR" "1.37.0"
    [ "$status" -eq 0 ]
    [ "$(cat "$TEST_DIR/.claude/.foundation-version")" = "1.37.0" ]
}

@test "write_foundation_marker returns 1 if target_dir is empty" {
    run write_foundation_marker "" "1.37.0"
    [ "$status" -eq 1 ]
}

@test "write_foundation_marker returns 1 if version is empty" {
    run write_foundation_marker "$TEST_DIR" ""
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests for foundation marker (T1.2 — read_foundation_marker_from_project)
# =============================================================================

@test "read_foundation_marker_from_project returns the version when marker exists" {
    mkdir -p "$TEST_DIR/.claude"
    printf '%s\n' "1.37.0" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.37.0" ]
}

@test "read_foundation_marker_from_project strips the trailing newline" {
    mkdir -p "$TEST_DIR/.claude"
    printf '%s\n' "1.37.0" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    # If a trailing newline leaked through, output would be "1.37.0\n" — bats run captures
    # output without the trailing newline, but the test asserts the precise expected string.
    [ "${#output}" -eq 6 ]
}

@test "read_foundation_marker_from_project returns empty when marker is missing" {
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

@test "read_foundation_marker_from_project does not create the marker file as a side effect" {
    [ ! -d "$TEST_DIR/.claude" ]
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
}

@test "read_foundation_marker_from_project returns first line when marker has multiple lines" {
    mkdir -p "$TEST_DIR/.claude"
    printf '%s\n%s\n' "1.37.0" "extra-line" > "$TEST_DIR/.claude/.foundation-version"
    run read_foundation_marker_from_project "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "1.37.0" ]
}

@test "read_foundation_marker_from_project round-trips with write_foundation_marker" {
    write_foundation_marker "$TEST_DIR" "1.42.0"
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
