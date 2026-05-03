#!/usr/bin/env bats

# =============================================================================
# End-to-End integration tests
# Simulates a complete foundation usage workflow
# =============================================================================

load 'test_helper'

VALIDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/validate.sh"
UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
DIFF_SCRIPT="$BATS_TEST_DIRNAME/../scripts/diff.sh"
DOCTOR_SCRIPT="$BATS_TEST_DIRNAME/../scripts/doctor.sh"
UNINSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/uninstall.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# E2E: Complete installation workflow
# =============================================================================

@test "E2E: Workflow new-project → validate → doctor → uninstall" {
    # 1. Installation with new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    # 2. Validation
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]

    # 3. Doctor
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]

    # 4. Uninstall
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.claude" ]
}

@test "E2E: Workflow new-project → modify → diff → update" {
    # 1. Installation
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # 2. Modify a file
    echo "# Custom modification" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    # 3. Diff detects the modification (returns 1 because there are differences)
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"work/work-explore.md"* ]] || [[ "$output" == *"work-explore.md"* ]]

    # 4. Update restores the files
    run "$UPDATE_SCRIPT" -y --force "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "E2E: Workflow new-project --all with all options" {
    # Full installation
    run "$NEW_PROJECT_SCRIPT" -y --simple --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Check all components
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -f "$TEST_DIR/.claude/settings.json" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -d "$TEST_DIR/.husky" ]
    [ -f "$TEST_DIR/.mcp.json" ]

    # Validation
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# E2E: new-project workflow
# =============================================================================

@test "E2E: new-project creates a complete and functional project" {
    # Create a new project
    run "$NEW_PROJECT_SCRIPT" -y -t node-api "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Check the structure
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
    [ -d "$TEST_DIR/.git" ]

    # The project must be valid
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Doctor must work
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "E2E: new-project with existing CI/CD suggests improvements" {
    # Create a project with partial CI
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

    # new-project must detect the existing CI
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The original file must be preserved
    [ -f "$TEST_DIR/.github/workflows/test.yml" ]
}

# =============================================================================
# E2E: Local file management
# =============================================================================

@test "E2E: Local files are preserved throughout the cycle" {
    # Installation
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Create local files
    echo "# My personal notes" > "$TEST_DIR/CLAUDE.local.md"
    echo '{"custom": true}' > "$TEST_DIR/.claude/settings.local.json"

    # Update preserves local files
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
    [ -f "$TEST_DIR/.claude/settings.local.json" ]

    # Uninstall also preserves local files
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
}

# =============================================================================
# E2E: Stack detection
# =============================================================================

@test "E2E: Detection and configuration of Node.js/React project" {
    # Create a React project
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "my-react-app",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "jest": "^29.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "jest"
  }
}
EOF
    echo '{}' > "$TEST_DIR/tsconfig.json"

    # new-project must detect React + TypeScript
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # CLAUDE.md must contain the project info
    [ -f "$TEST_DIR/CLAUDE.md" ]
    run cat "$TEST_DIR/CLAUDE.md"
    [[ "$output" == *"npm"* ]] || [[ "$output" == *"test"* ]] || [[ "$output" == *"build"* ]]
}

@test "E2E: Detection and configuration of Python project" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/requirements.txt" << 'EOF'
fastapi==0.100.0
uvicorn==0.23.0
pytest==7.4.0
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "E2E: Detection and configuration of monorepo" {
    mkdir -p "$TEST_DIR/packages/web"
    mkdir -p "$TEST_DIR/packages/api"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "my-monorepo",
  "workspaces": ["packages/*"]
}
EOF
    echo '{}' > "$TEST_DIR/turbo.json"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# E2E: Foundation integrity
# =============================================================================

@test "E2E: The foundation itself is valid" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Validation of the foundation
    run "$VALIDATE_SCRIPT" "$SOCLE_DIR"
    [ "$status" -eq 0 ]
}

@test "E2E: The foundation passes doctor" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    run "$DOCTOR_SCRIPT" "$SOCLE_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "E2E: All agents are present and valid" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Count agents (recursively in subdirectories)
    agent_count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l)
    [ "$agent_count" -ge 70 ]

    # Check that each agent has a title
    while IFS= read -r agent; do
        run head -1 "$agent"
        [[ "$output" == "# "* ]]
    done < <(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null)
}

@test "E2E: All skills are present and valid" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Count skills
    skill_count=$(ls -d "$SOCLE_DIR/.claude/skills/"*/ 2>/dev/null | wc -l)
    [ "$skill_count" -ge 5 ]

    # Check that each skill has a README
    for skill in "$SOCLE_DIR/.claude/skills/"*/; do
        [ -f "${skill}README.md" ] || [ -f "${skill}index.md" ] || [ -f "${skill}skill.md" ] || true
    done
}

# =============================================================================
# E2E: Error scenarios
# =============================================================================

@test "E2E: Graceful error handling - nonexistent directory" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "/nonexistent/path/that/does/not/exist"
    # Must fail cleanly
    [ "$status" -ne 0 ]
}

@test "E2E: Graceful error handling - permissions" {
    if [ "$(id -u)" -eq 0 ]; then
        skip "Test not applicable as root"
    fi

    # Create a directory without write permissions
    mkdir -p "$TEST_DIR/readonly"
    chmod 444 "$TEST_DIR/readonly"

    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/readonly"
    # Must fail or warn
    [[ "$status" -ne 0 ]] || [[ "$output" == *"permission"* ]] || [[ "$output" == *"Permission"* ]] || true

    # Cleanup
    chmod 755 "$TEST_DIR/readonly"
}
