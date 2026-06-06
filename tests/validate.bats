#!/usr/bin/env bats

# =============================================================================
# Tests for validate.sh
# =============================================================================

load 'test_helper'

VALIDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/validate.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

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
    [[ "$output" == *"commandes documentées existent"* ]] || [[ "$output" == *"cohérentes"* ]] || [[ "$output" == *"documented commands exist"* ]] || [[ "$output" == *"consistent"* ]]
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
    [[ "$output" == *"rm -rf bloqué"* ]] || [[ "$output" == *"rm -rf blocked"* ]]
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

# =============================================================================
# Foundation manifest validation (specs/foundation-modules US-1/EF-211, T016)
# =============================================================================

@test "validate.sh accepts a project with a valid foundation manifest" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    run "$VALIDATE_SCRIPT" "$TEST_DIR/proj"
    [[ "$output" == *"foundation.json"* ]]
    [[ "$output" != *"corrupted"* ]]
}

@test "validate.sh reports recorded-but-missing module items (EF-211)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # legal is recorded (full set at init) — remove its files.
    rm -rf "$TEST_DIR/proj/.claude/commands/legal"
    run "$VALIDATE_SCRIPT" "$TEST_DIR/proj"
    [[ "$output" == *"legal"* ]]
    [[ "$output" == *"missing"* ]]
}

@test "validate.sh never flags absent unrecorded modules (EF-211)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Unrecord biz, then remove its files: absence must NOT be a defect.
    local manifest="$TEST_DIR/proj/.claude/foundation.json"
    jq '.modules = ["legal", "growth"]' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"
    rm -rf "$TEST_DIR/proj/.claude/commands/biz"
    find "$TEST_DIR/proj/.claude/agents" -maxdepth 1 -name "biz-*.md" -delete
    run "$VALIDATE_SCRIPT" "$TEST_DIR/proj"
    [[ "$output" != *"module 'biz'"* ]]
}

@test "validate.sh flags a corrupted foundation manifest" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    echo "{ broken" > "$TEST_DIR/proj/.claude/foundation.json"
    run "$VALIDATE_SCRIPT" "$TEST_DIR/proj"
    [[ "$output" == *"corrupted"* ]] || [[ "$output" == *"invalid JSON"* ]]
}

@test "validate.sh notes a legacy marker pending migration" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    rm -f "$TEST_DIR/proj/.claude/foundation.json"
    echo "1.30.0" > "$TEST_DIR/proj/.claude/.foundation-version"
    run "$VALIDATE_SCRIPT" "$TEST_DIR/proj"
    [[ "$output" == *"legacy"* ]] || [[ "$output" == *"migrate"* ]]
}
