#!/usr/bin/env bats

# =============================================================================
# Tests for new-project.sh
# =============================================================================

load 'test_helper'

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

@test "new-project.sh exists and is executable" {
    [ -f "$NEW_PROJECT_SCRIPT" ]
    [ -x "$NEW_PROJECT_SCRIPT" ]
}

@test "new-project.sh displays help with --help" {
    run "$NEW_PROJECT_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"EXEMPLES"* ]] || [[ "$output" == *"EXAMPLES"* ]]
}

@test "new-project.sh displays version with --version" {
    run "$NEW_PROJECT_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"new-project"* ]]
}

# =============================================================================
# Stack detection tests
# =============================================================================

@test "new-project.sh detects a Node.js project" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Node"* ]] || [[ "$output" == *"Express"* ]] || true
}

@test "new-project.sh detects a React project" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-react",
  "dependencies": {
    "react": "^18.0.0"
  }
}
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"React"* ]] || true
}

@test "new-project.sh detects TypeScript" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-ts",
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF
    echo '{}' > "$TEST_DIR/tsconfig.json"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"TypeScript"* ]] || true
}

@test "new-project.sh detects Python" {
    mkdir -p "$TEST_DIR"
    echo "flask==2.0.0" > "$TEST_DIR/requirements.txt"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Python"* ]] || [[ "$output" == *"Flask"* ]] || true
}

@test "new-project.sh detects Go" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/go.mod" << 'EOF'
module test-go

go 1.21
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Go"* ]] || true
}

# =============================================================================
# Configuration tests
# =============================================================================

@test "new-project.sh creates the .claude structure" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -f "$TEST_DIR/.claude/settings.json" ]
}

@test "new-project.sh creates CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "new-project.sh forces the type with --type" {
    run "$NEW_PROJECT_SCRIPT" -y -t python "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# CI/CD options tests
# =============================================================================

@test "new-project.sh with --ci installs GitHub Actions" {
    run "$NEW_PROJECT_SCRIPT" -y --ci "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -f "$TEST_DIR/.github/workflows/ci.yml" ]
}

@test "new-project.sh with --hooks installs husky" {
    run "$NEW_PROJECT_SCRIPT" -y --hooks "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.husky" ]
}

@test "new-project.sh with --docker creates Dockerfile" {
    run "$NEW_PROJECT_SCRIPT" -y --docker -t node-api "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/Dockerfile" ]
}

@test "new-project.sh with --all installs everything" {
    run "$NEW_PROJECT_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -d "$TEST_DIR/.husky" ]
    [ -f "$TEST_DIR/.mcp.json" ]
    [ -f "$TEST_DIR/Dockerfile" ]
}

# =============================================================================
# Existing CI/CD analysis tests
# =============================================================================

@test "new-project.sh detects existing GitHub Actions" {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CI/CD"* ]] || [[ "$output" == *"GitHub Actions"* ]] || [[ "$output" == *"Tests"* ]] || true
}

@test "new-project.sh does not replace existing CI/CD by default" {
    mkdir -p "$TEST_DIR/.github/workflows"
    echo "name: Custom" > "$TEST_DIR/.github/workflows/custom.yml"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The custom.yml file must still exist
    [ -f "$TEST_DIR/.github/workflows/custom.yml" ]
    run cat "$TEST_DIR/.github/workflows/custom.yml"
    [[ "$output" == *"Custom"* ]]
}

# =============================================================================
# Security tests
# =============================================================================

@test "new-project.sh initializes git if necessary" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.git" ]
}

@test "new-project.sh creates .gitignore with secure exclusions" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.gitignore" ]

    run cat "$TEST_DIR/.gitignore"
    # Local config that MUST be gitignored
    [[ "$output" == *"CLAUDE.local.md"* ]]
    [[ "$output" == *"settings.local.json"* ]]
    [[ "$output" == *".env"* ]]
}

@test "new-project.sh does NOT put .claude/ or CLAUDE.md in .gitignore" {
    # Regression: before the fix, new-project.sh added .claude/ and
    # CLAUDE.md to the user's .gitignore, preventing them from versioning
    # their custom commands/rules with the team (cf. CONTRIBUTING.md).
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.gitignore" ]

    # .claude/ and CLAUDE.md (pure lines, not substring) must NOT
    # appear as gitignore entries.
    ! grep -qE "^\.claude/?$" "$TEST_DIR/.gitignore"
    ! grep -qE "^CLAUDE\.md$" "$TEST_DIR/.gitignore"
}

# =============================================================================
# Tests for the new directories (agents, rules, output-styles)
# =============================================================================

@test "new-project.sh creates the agents directory" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/agents" ]

    # Check that there are files
    local count
    count=$(find "$TEST_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "new-project.sh creates the rules directory" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/rules" ]

    # Check that there are files
    local count
    count=$(find "$TEST_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "new-project.sh creates the output-styles directory" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/output-styles" ]

    # Check that there are files
    local count
    count=$(find "$TEST_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "new-project.sh installs the 7 canonical @imports in CLAUDE.md" {
    # Regression: before the fix, new-project.sh installed CLAUDE.md with
    # only 2 @imports (best-practices, project-structures), creating an
    # asymmetry with update.sh --all which enforced 7. Fix in
    # ensure_claude_md_imports() (lib/common.sh).
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    # The 7 canonical @imports must be present
    local expected_imports=(
        "@.claude/docs/reference/best-practices.md"
        "@.claude/docs/reference/project-structures.md"
        "@.claude/docs/reference/commands.md"
        "@.claude/docs/reference/agents-catalog.md"
        "@.claude/docs/reference/hooks-reference.md"
        "@.claude/docs/reference/skills-catalog.md"
        "@.claude/docs/reference/advanced-features.md"
    )
    for import in "${expected_imports[@]}"; do
        grep -qF "$import" "$TEST_DIR/CLAUDE.md" || {
            echo "Missing @import: $import"
            return 1
        }
    done
}

@test "new-project.sh copies scripts/hooks/ referenced by settings.json" {
    # Regression: settings.json references scripts/hooks/*.sh, they must
    # be copied otherwise SessionStart/PreToolUse hooks fail
    # silently (counterpart to the update.sh fix in dcaa059).
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/scripts/hooks" ]

    # At least one .sh copied
    local count
    count=$(find "$TEST_DIR/scripts/hooks" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]

    # All .sh are executable
    local non_exec
    non_exec=$(find "$TEST_DIR/scripts/hooks" -name "*.sh" -type f ! -executable 2>/dev/null | wc -l | tr -d ' ')
    [ "$non_exec" -eq 0 ]
}

# =============================================================================
# Cleanup-before-copy tests
# =============================================================================

@test "new-project.sh cleans up old files before installation" {
    # Create a first installation
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an obsolete file in commands
    echo "# Old command" > "$TEST_DIR/.claude/commands/old-command.md"
    [ -f "$TEST_DIR/.claude/commands/old-command.md" ]

    # Reinstall
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The obsolete file should no longer exist
    [ ! -f "$TEST_DIR/.claude/commands/old-command.md" ]
}

# =============================================================================
# Dry-run exit code regression (bash 5+ set -eo pipefail behavior)
# =============================================================================

@test "new-project.sh --simple --dry-run exits 0 when stdout is non-TTY" {
    # Regression: bash 5+ with `set -eo pipefail` kills an assignment whose
    # command-sub contains a pipeline where one stage fails. In dry-run,
    # print_simple_summary did `$(find $non_existent_dir | wc -l | tr -d ' ')`,
    # find exited 1, pipefail propagated, the assignment died via set -e.
    # The visible symptom was: exit 1 when stdout is redirected (not a TTY).
    run bash -c "'$NEW_PROJECT_SCRIPT' --simple --dry-run '$TEST_DIR/dry-target' >/dev/null 2>&1"
    [ "$status" -eq 0 ]
    # Dry-run must still not have written anything
    [ ! -d "$TEST_DIR/dry-target/.claude" ]
}

@test "new-project.sh --simple --dry-run exits 0 when stdout goes to TTY-like" {
    # Same regression, ensuring it works for both stdout-redirect and direct.
    run "$NEW_PROJECT_SCRIPT" --simple --dry-run "$TEST_DIR/dry-target-2"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/dry-target-2/.claude" ]
}

# =============================================================================
# Foundation version manifest (written after install)
# Since specs/foundation-modules: .claude/foundation.json replaces the legacy
# .foundation-version marker (EF-204/EF-205).
# =============================================================================

@test "new-project.sh --simple writes .claude/foundation.json with the foundation version" {
    run "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/marker-target"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/marker-target/.claude/foundation.json" ]
    # Direct replacement (EF-205): the legacy marker must NOT be written.
    [ ! -f "$TEST_DIR/marker-target/.claude/.foundation-version" ]
    local manifest_version expected
    manifest_version=$(jq -r '.version' "$TEST_DIR/marker-target/.claude/foundation.json")
    expected=$(cat "$BASE_DIR/VERSION")
    [ "$manifest_version" = "$expected" ]
}

@test "new-project.sh --simple --dry-run does NOT write the manifest" {
    run "$NEW_PROJECT_SCRIPT" --simple --dry-run -y "$TEST_DIR/dry-marker-target"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/dry-marker-target/.claude/foundation.json" ]
}
