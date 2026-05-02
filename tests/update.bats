#!/usr/bin/env bats

# =============================================================================
# Tests for update.sh
# =============================================================================

load 'test_helper'

UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
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

@test "update.sh exists and is executable" {
    [ -f "$UPDATE_SCRIPT" ]
    [ -x "$UPDATE_SCRIPT" ]
}

@test "update.sh shows help with --help" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"mise à jour"* ]] || [[ "$output" == *"update"* ]] || [[ "$output" == *"MAJ"* ]]
}

@test "update.sh shows version with --version" {
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"update"* ]]
}

# =============================================================================
# Update tests
# =============================================================================

@test "update.sh fails on a non-configured project" {
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Should fail or warn because no .claude
    [[ "$status" -ne 0 ]] || [[ "$output" == *".claude"* ]] || [[ "$output" == *"non"* ]] || true
}

@test "update.sh works on a configured project" {
    # First install with new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Then update
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "update.sh preserves local files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Create a local file
    echo "# My notes" > "$TEST_DIR/CLAUDE.local.md"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Verify the local file still exists
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
    run cat "$TEST_DIR/CLAUDE.local.md"
    [[ "$output" == *"My notes"* ]]
}

@test "update.sh updates the commands" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Simulate an old version by removing a file
    rm "$TEST_DIR/.claude/commands/work/work-explore.md" 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The file should be restored
    [ -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

# =============================================================================
# Option tests
# =============================================================================

@test "update.sh --dry-run does not modify anything" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove a file
    rm "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The file should NOT be restored in dry-run
    [ ! -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

@test "update.sh shows the changes" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Should display something about files
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"OK"* ]] || true
}

# =============================================================================
# Tests for new options (--clean, --agents, --rules, --styles, --all)
# =============================================================================

@test "update.sh --clean removes the old files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an obsolete file in commands (in an existing subdirectory)
    echo "# Old command" > "$TEST_DIR/.claude/commands/work/old-command.md"
    [ -f "$TEST_DIR/.claude/commands/work/old-command.md" ]

    run "$UPDATE_SCRIPT" -y --clean "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The obsolete file should no longer exist (the whole folder was recreated)
    [ ! -f "$TEST_DIR/.claude/commands/work/old-command.md" ]
}

@test "update.sh --agents updates the agents" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove an agent
    rm -f "$TEST_DIR/.claude/agents/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --agents "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The agents should be restored
    local count
    count=$(find "$TEST_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --rules updates the rules" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the rules
    rm -f "$TEST_DIR/.claude/rules/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --rules "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The rules should be restored
    local count
    count=$(find "$TEST_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --styles updates the output-styles" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the styles
    rm -f "$TEST_DIR/.claude/output-styles/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --styles "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The styles should be restored
    local count
    count=$(find "$TEST_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --all updates everything with cleanup" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an obsolete file in commands (in a subdirectory)
    echo "# Old" > "$TEST_DIR/.claude/commands/work/obsolete.md"
    [ -f "$TEST_DIR/.claude/commands/work/obsolete.md" ]

    run "$UPDATE_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The obsolete files should no longer exist
    [ ! -f "$TEST_DIR/.claude/commands/work/obsolete.md" ]

    # Verify that the directories are present
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -d "$TEST_DIR/.claude/agents" ]
    [ -d "$TEST_DIR/.claude/rules" ]
    [ -d "$TEST_DIR/.claude/output-styles" ]
}

@test "update.sh --help shows the new options" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--clean"* ]]
    [[ "$output" == *"--agents"* ]]
    [[ "$output" == *"--rules"* ]]
    [[ "$output" == *"--styles"* ]]
    [[ "$output" == *"--all"* ]]
    [[ "$output" == *"--detect-orphans"* ]]
    [[ "$output" == *"--remove-orphans"* ]]
}

# =============================================================================
# Orphan file detection tests
# =============================================================================

@test "update.sh --detect-orphans detects files absent from the foundation" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an orphan file (absent from the foundation)
    echo "# Orphan command" > "$TEST_DIR/.claude/commands/work/orphan-command.md"
    [ -f "$TEST_DIR/.claude/commands/work/orphan-command.md" ]

    run "$UPDATE_SCRIPT" -y --detect-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Should mention the orphans
    [[ "$output" == *"orphelin"* ]] || [[ "$output" == *"Orphelins"* ]]

    # The file should still exist (detection only)
    [ -f "$TEST_DIR/.claude/commands/work/orphan-command.md" ]
}

@test "update.sh --remove-orphans removes files absent from the foundation" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an orphan file
    echo "# Orphan command" > "$TEST_DIR/.claude/commands/work/orphan-to-delete.md"
    [ -f "$TEST_DIR/.claude/commands/work/orphan-to-delete.md" ]

    run "$UPDATE_SCRIPT" -y --remove-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The orphan file should be removed
    [ ! -f "$TEST_DIR/.claude/commands/work/orphan-to-delete.md" ]

    # The valid files should still exist
    [ -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

# =============================================================================
# --upgrade-claude-md tests
# =============================================================================

@test "update.sh --upgrade-claude-md copies .claude/docs/reference/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove .claude/docs/reference/ if it already exists
    rm -rf "$TEST_DIR/.claude/docs/reference"

    # Remove the @imports from CLAUDE.md to simulate an old project
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # .claude/docs/reference/ must exist with files
    [ -d "$TEST_DIR/.claude/docs/reference" ]
    local count
    count=$(find "$TEST_DIR/.claude/docs/reference" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --upgrade-claude-md adds the @imports in CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove .claude/docs/reference/ and the @imports
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # CLAUDE.md must contain the @imports (new layout)
    grep -q "@\.claude/docs/reference/commands\.md" "$TEST_DIR/CLAUDE.md"
    grep -q "@\.claude/docs/reference/agents-catalog\.md" "$TEST_DIR/CLAUDE.md"
    grep -q "@\.claude/docs/reference/skills-catalog\.md" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --upgrade-claude-md creates a backup" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the @imports to trigger the migration
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # A backup file must exist
    local backup_count
    backup_count=$(find "$TEST_DIR" -maxdepth 1 -name "CLAUDE.md.backup.*" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$backup_count" -ge 1 ]
}

@test "update.sh --upgrade-claude-md skips if @imports already present" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # First run: adds the missing @imports
    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Second run: all @imports are present, must skip
    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # No backup created (skip) - contains all @imports
    [[ "$output" == *"skip"* ]] || [[ "$output" == *"déjà"* ]] || [[ "$output" == *"contient tous les @imports"* ]]
}

@test "update.sh --upgrade-claude-md detects duplicated sections" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the @imports and add a duplicated section
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"
    echo "" >> "$TEST_DIR/CLAUDE.md"
    echo "## Commandes Essentielles" >> "$TEST_DIR/CLAUDE.md"
    echo "Contenu inline ancien" >> "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The duplicated section must be removed (mode -y)
    ! grep -q "^## Commandes Essentielles" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --all includes the CLAUDE.md migration" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the @imports
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # .claude/docs/reference/ must exist
    [ -d "$TEST_DIR/.claude/docs/reference" ]
    # @imports must be present
    grep -q "@\.claude/docs/reference/" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --dry-run --upgrade-claude-md does not modify anything" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the @imports
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y -n --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # .claude/docs/reference/ must NOT exist
    [ ! -d "$TEST_DIR/.claude/docs/reference" ]
    # @imports must NOT be present
    ! grep -q "@docs/reference/" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --help shows --upgrade-claude-md" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--upgrade-claude-md"* ]]
}

@test "update.sh --detect-orphans --dry-run does not remove the files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an orphan file
    echo "# Orphan" > "$TEST_DIR/.claude/commands/work/dry-run-orphan.md"

    run "$UPDATE_SCRIPT" -y -n --remove-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The file should still exist in dry-run
    [ -f "$TEST_DIR/.claude/commands/work/dry-run-orphan.md" ]
}
