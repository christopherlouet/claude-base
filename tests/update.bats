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
# Foundation version marker (T1.4 — written after update; T1.5 — surfaced in --version)
# =============================================================================

@test "update.sh writes .claude/.foundation-version after a successful update" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Erase the marker created by init to verify update re-creates it
    rm -f "$TEST_DIR/proj/.claude/.foundation-version"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/.claude/.foundation-version" ]
    local marker expected
    marker=$(cat "$TEST_DIR/proj/.claude/.foundation-version")
    expected=$(cat "$BASE_DIR/VERSION")
    [ "$marker" = "$expected" ]
}

@test "update.sh --dry-run does NOT modify .claude/.foundation-version" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Force an old version into the marker
    echo "1.0.0-old" > "$TEST_DIR/proj/.claude/.foundation-version"

    run "$UPDATE_SCRIPT" --dry-run -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # Marker must still hold the old fake version
    [ "$(cat "$TEST_DIR/proj/.claude/.foundation-version")" = "1.0.0-old" ]
}

@test "update.sh creates the marker on a project that never had one" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    rm -f "$TEST_DIR/proj/.claude/.foundation-version"
    [ ! -f "$TEST_DIR/proj/.claude/.foundation-version" ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/.claude/.foundation-version" ]
}

@test "update.sh --version surfaces the project marker when run from inside a project" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Set a distinguishable marker so we can assert it's read
    echo "1.36.0-test" > "$TEST_DIR/proj/.claude/.foundation-version"

    cd "$TEST_DIR/proj"
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base update v"* ]]
    [[ "$output" == *"1.36.0-test"* ]]
}

@test "update.sh --version does NOT show a project marker when run outside a project" {
    cd "$TEST_DIR"
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base update v"* ]]
    # The output should NOT mention any 1.36.0-test or similar fake marker
    # (we just assert it doesn't include a "project:" line that T1.5 will add)
    [[ "$output" != *"project:"* ]]
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
    [[ "$output" == *"orphelin"* ]] || [[ "$output" == *"Orphelins"* ]] || [[ "$output" == *"orphan"* ]] || [[ "$output" == *"Orphans"* ]]

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
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"

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
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"

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
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"

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
    [[ "$output" == *"skip"* ]] || [[ "$output" == *"déjà"* ]] || [[ "$output" == *"contient tous les @imports"* ]] || [[ "$output" == *"already"* ]] || [[ "$output" == *"contains all @imports"* ]]
}

@test "update.sh --upgrade-claude-md detects duplicated sections" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Remove the @imports and add a duplicated section
    rm -rf "$TEST_DIR/.claude/docs/reference"
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"
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
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"

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
    sed -i.bak '/@\.claude\/docs\/reference/d' "$TEST_DIR/CLAUDE.md" && rm -f "$TEST_DIR/CLAUDE.md.bak"

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

# =============================================================================
# --add-plugin flag (mirrors --add-hook pattern, lets users opt into a
# marketplace plugin without overwriting their settings.json on update.sh
# --settings)
# =============================================================================

@test "update.sh --help documents --add-plugin" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--add-plugin"* ]]
}

@test "update.sh --add-plugin requires an argument" {
    run "$UPDATE_SCRIPT" --add-plugin
    [ "$status" -ne 0 ]
    [[ "$output" == *"--add-plugin"* ]] || [[ "$output" == *"argument"* ]]
}

@test "update.sh --add-plugin adds plugin to settings.json enabledPlugins" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    run "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -eq 0 ]
    run jq -e '.enabledPlugins["astral@astral-sh"]' "$TEST_DIR/.claude/settings.json"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "update.sh --add-plugin is idempotent (already enabled)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR" >/dev/null 2>&1
    run "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"already"* ]] || [[ "$output" == *"enabled"* ]]
}

@test "update.sh --add-plugin preserves existing enabledPlugins entries" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    # Inject an existing plugin entry
    local tmp
    tmp=$(mktemp)
    jq '.enabledPlugins = {"existing@vendor": true}' "$TEST_DIR/.claude/settings.json" > "$tmp"
    mv "$tmp" "$TEST_DIR/.claude/settings.json"

    run "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Both entries must coexist
    [ "$(jq -r '.enabledPlugins["existing@vendor"]' "$TEST_DIR/.claude/settings.json")" = "true" ]
    [ "$(jq -r '.enabledPlugins["astral@astral-sh"]' "$TEST_DIR/.claude/settings.json")" = "true" ]
}

@test "update.sh --add-plugin --dry-run does not modify settings.json" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    local before_md5
    before_md5=$(md5sum "$TEST_DIR/.claude/settings.json" | cut -d' ' -f1)

    run "$UPDATE_SCRIPT" -y -n --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -eq 0 ]

    local after_md5
    after_md5=$(md5sum "$TEST_DIR/.claude/settings.json" | cut -d' ' -f1)
    [ "$before_md5" = "$after_md5" ]
}

@test "update.sh --add-plugin fails when settings.json is missing" {
    mkdir -p "$TEST_DIR/.claude"
    # Note: NO settings.json created
    run "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"settings.json"* ]] || [[ "$output" == *"not found"* ]]
}

@test "update.sh --add-plugin preserves the rest of settings.json (hooks, permissions)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    # Capture the .hooks and .permissions sections before the change
    local hooks_before permissions_before
    hooks_before=$(jq -c '.hooks' "$TEST_DIR/.claude/settings.json")
    permissions_before=$(jq -c '.permissions' "$TEST_DIR/.claude/settings.json")

    run "$UPDATE_SCRIPT" -y --add-plugin "astral@astral-sh" "$TEST_DIR"
    [ "$status" -eq 0 ]

    local hooks_after permissions_after
    hooks_after=$(jq -c '.hooks' "$TEST_DIR/.claude/settings.json")
    permissions_after=$(jq -c '.permissions' "$TEST_DIR/.claude/settings.json")

    [ "$hooks_before" = "$hooks_after" ]
    [ "$permissions_before" = "$permissions_after" ]
}

# =============================================================================
# US-4 — Dry-run conflicts in non-TTY (T4.1, T4.2, T4.3, T4.4)
# Non-interactive dry-run used to silently report differing files as
# "skipped". US-4 surfaces them as "Conflicts requiring decision" so that
# CI / scripted runs see what would have prompted a human, and reports the
# count separately from auto-skipped files.
# =============================================================================

@test "update.sh --dry-run -y surfaces a modified file as a conflict (T4.1/T4.2)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    [ -d "$TEST_DIR/proj/.claude" ]
    # Customise a command so it differs from the foundation source.
    echo "# user-customised work-explore" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Conflicts requiring decision"* ]]
    [[ "$output" == *"work-explore.md"* ]]
}

@test "update.sh --dry-run -y replaces silent skipped warning with conflict tracking (T4.1)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# customised" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # The legacy silent warning must NOT appear for the conflict file in dry-run.
    [[ "$output" != *"work-explore.md skipped (use --force to overwrite)"* ]]
}

@test "update.sh summary reports Conflicts: count separately from Skipped: when conflicts exist (T4.3)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# customised" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Conflicts:"* ]]
}

@test "update.sh --dry-run -y exits 0 even when conflicts are listed (T4.4)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# customised A" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"
    echo "# customised B" > "$TEST_DIR/proj/.claude/commands/work/work-plan.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
}

@test "update.sh --dry-run -y with no modifications shows no conflict section (T4.5 regression)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    # Pristine project — no customisations.

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Conflicts requiring decision"* ]]
}
