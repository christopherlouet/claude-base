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
# Tests SOCLE_DIR (via test_helper)
# =============================================================================

@test "SOCLE_DIR is defined and points to the foundation" {
    [ -n "$SOCLE_DIR" ]
    [ -d "$SOCLE_DIR" ]
    [ -d "$SOCLE_DIR/scripts" ]
    [ -f "$SOCLE_DIR/VERSION" ]
}
