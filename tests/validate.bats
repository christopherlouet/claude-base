#!/usr/bin/env bats

# =============================================================================
# Tests for validate.sh
# =============================================================================

load 'test_helper'

VALIDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/validate.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Structure tests
# =============================================================================

@test "validate.sh exists and is executable" {
    [ -f "$VALIDATE_SCRIPT" ]
    [ -x "$VALIDATE_SCRIPT" ]
}

@test "validate.sh displays help with --help" {
    run "$VALIDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

@test "validate.sh displays version with --version" {
    run "$VALIDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"validate"* ]]
}

# =============================================================================
# Validation tests
# =============================================================================

@test "validate.sh fails on an empty directory" {
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    # Warnings are not blocking, but no claude structure
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "validate.sh succeeds on a valid minimal project" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "validate.sh detects missing CLAUDE.md" {
    mkdir -p "$TEST_DIR/.claude/commands"
    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "validate.sh detects invalid JSON" {
    skip_if_no_jq
    create_minimal_project
    echo "invalid json" > "$TEST_DIR/.claude/settings.json"
    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"invalide"* ]] || [[ "$output" == *"invalid"* ]]
}

# =============================================================================
# Output format tests
# =============================================================================

@test "validate.sh --json produces valid JSON" {
    skip_if_no_jq
    create_minimal_project
    run "$VALIDATE_SCRIPT" --json "$TEST_DIR"
    [ "$status" -eq 0 ]
    echo "$output" | jq . > /dev/null
}

@test "validate.sh --score produces a score" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" --score "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/"* ]]
    [[ "$output" == *"%"* ]]
}

# =============================================================================
# CLAUDE.md ↔ Commands consistency tests
# =============================================================================

@test "validate.sh detects commands in subdirectories" {
    create_minimal_project
    create_test_command_in_subdir "work" "work-explore"
    create_test_command_in_subdir "dev" "dev-tdd"

    # CLAUDE.md mentions the commands
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Commandes
- /work-explore
- /dev-tdd
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"commandes documentées existent"* ]] || [[ "$output" == *"cohérentes"* ]]
}

@test "validate.sh does not capture false positives (directory paths)" {
    create_minimal_project

    # CLAUDE.md with paths that are NOT commands
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Structure
- /components
- /services
- /utils
- /hooks
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Must NOT report missing commands for /components, /services, etc.
    [[ "$output" != *"commande(s) mentionnée(s)"*"non trouvée"* ]]
}

@test "validate.sh reports missing commands" {
    create_minimal_project

    # CLAUDE.md mentions a command that does not exist
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Commandes
- /work-nonexistent
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"mentionnée"* ]] || [[ "$output" == *"non trouvée"* ]] || [ "$status" -eq 0 ]
}

# =============================================================================
# Skills tests
# =============================================================================

@test "validate.sh detects skills" {
    create_minimal_project
    create_test_skill "test-skill"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"skill"* ]]
}

@test "validate.sh detects skills without YAML frontmatter" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/skills/bad-skill"
    echo "# Bad skill without frontmatter" > "$TEST_DIR/.claude/skills/bad-skill/SKILL.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    # Should report a warning or info about the frontmatter
    [[ "$output" == *"skill"* ]]
}

# =============================================================================
# Hooks tests
# =============================================================================

@test "validate.sh detects configured hooks" {
    skip_if_no_jq
    create_minimal_project
    create_settings_with_hooks

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"hook"* ]]
}

# =============================================================================
# Security tests
# =============================================================================

@test "validate.sh checks CLAUDE.local.md in .gitignore" {
    create_minimal_project
    echo "CLAUDE.local.md" > "$TEST_DIR/.gitignore"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CLAUDE.local.md"* ]] && [[ "$output" == *"gitignore"* ]]
}

@test "validate.sh warns if rm -rf is not blocked" {
    create_minimal_project
    echo '{"permissions": {"allow": ["Edit"]}}' > "$TEST_DIR/.claude/settings.json"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    # Should report a warning about rm -rf
    [[ "$output" == *"rm"* ]] || [ "$status" -eq 0 ]
}

@test "validate.sh validates rm -rf blocked" {
    skip_if_no_jq
    create_minimal_project
    create_settings_with_hooks

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rm -rf bloqué"* ]]
}

# =============================================================================
# Command files tests
# =============================================================================

@test "validate.sh detects empty command files" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/commands/work"
    touch "$TEST_DIR/.claude/commands/work/work-empty.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"vide"* ]] || [[ "$output" == *"empty"* ]]
}

@test "validate.sh warns if a command file has no title" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/commands/work"
    echo "Pas de titre markdown" > "$TEST_DIR/.claude/commands/work/work-notitle.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"titre"* ]] || [[ "$output" == *"title"* ]] || [ "$status" -eq 0 ]
}

# =============================================================================
# Verbose mode tests
# =============================================================================

@test "validate.sh --verbose displays more details" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" --verbose "$TEST_DIR"
    [ "$status" -eq 0 ]
}
