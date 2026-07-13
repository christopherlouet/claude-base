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
# Foundation version manifest (written after update; surfaced in --version)
# Since specs/foundation-modules: .claude/foundation.json replaces the legacy
# .foundation-version marker (EF-204/EF-205).
# =============================================================================

@test "update.sh writes .claude/foundation.json after a successful update" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Erase the manifest created by init to verify update re-creates it
    rm -f "$TEST_DIR/proj/.claude/foundation.json"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/.claude/foundation.json" ]
    local manifest_version expected
    manifest_version=$(jq -r '.version' "$TEST_DIR/proj/.claude/foundation.json")
    expected=$(cat "$BASE_DIR/VERSION")
    [ "$manifest_version" = "$expected" ]
}

# BUG 5: create_backup captured the success() log line together with the path,
# so BACKUP_DIR held "[OK] Backup created...\n<path>" — a non-directory. The
# summary's `[[ -d "$BACKUP_DIR" ]]` therefore always failed and the
# "Backup available:" line never printed. create_backup must echo ONLY the path.
@test "update.sh prints the backup path in the summary after a real update" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # The backup message reaches the user (stderr, no longer swallowed).
    [[ "$output" == *"Backup created"* ]]
    # The summary now resolves BACKUP_DIR as a real directory.
    [[ "$output" == *"Backup available:"* ]]
    # And a real backup directory exists on disk.
    local nbackups
    nbackups=$(find "$TEST_DIR/proj" -type d -name '*.backup.*' | wc -l | tr -d ' ')
    [ "$nbackups" -ge 1 ]
}

@test "update.sh --dry-run does NOT modify .claude/foundation.json" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Force an old version into the manifest
    local manifest="$TEST_DIR/proj/.claude/foundation.json"
    jq '.version = "1.0.0-old"' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"

    run "$UPDATE_SCRIPT" --dry-run -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # Manifest must still hold the old fake version
    [ "$(jq -r '.version' "$manifest")" = "1.0.0-old" ]
}

@test "update.sh creates the manifest on a project that never had one" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    rm -f "$TEST_DIR/proj/.claude/foundation.json"
    [ ! -f "$TEST_DIR/proj/.claude/foundation.json" ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/.claude/foundation.json" ]
}

@test "update.sh --version surfaces the project manifest version when run from inside a project" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Set a distinguishable version in the manifest so we can assert it's read
    local manifest="$TEST_DIR/proj/.claude/foundation.json"
    jq '.version = "1.36.0-test"' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"

    cd "$TEST_DIR/proj"
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base update v"* ]]
    [[ "$output" == *"1.36.0-test"* ]]
}

@test "update.sh --version falls back to the legacy marker on a pre-modules project" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Simulate a legacy install: marker only, no manifest
    rm -f "$TEST_DIR/proj/.claude/foundation.json"
    echo "1.30.0-legacy" > "$TEST_DIR/proj/.claude/.foundation-version"

    cd "$TEST_DIR/proj"
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.30.0-legacy"* ]]
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
    [[ "$status" -ne 0 ]] || [[ "$output" == *".claude"* ]] || [[ "$output" == *"non"* ]]
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
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"OK"* ]]
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

@test "update.sh --clean preserves vendor skill symlinks (regression)" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Simulate an installed vendor skill: a symlink in skills/ pointing into
    # a sibling vendor-skills/ tree (the shape `git clone` + link produces).
    mkdir -p "$TEST_DIR/.claude/vendor-skills/acme/cool-skill"
    echo "# vendor" > "$TEST_DIR/.claude/vendor-skills/acme/cool-skill/SKILL.md"
    ln -s "../vendor-skills/acme/cool-skill" "$TEST_DIR/.claude/skills/cool-skill"
    [ -L "$TEST_DIR/.claude/skills/cool-skill" ]

    run "$UPDATE_SCRIPT" -y --clean "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The vendor symlink must survive --clean and still resolve to its target.
    [ -L "$TEST_DIR/.claude/skills/cool-skill" ]
    [ -e "$TEST_DIR/.claude/skills/cool-skill/SKILL.md" ]
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

@test "update.sh --all --clean updates everything with cleanup" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Add an obsolete file in commands (in a subdirectory)
    echo "# Old" > "$TEST_DIR/.claude/commands/work/obsolete.md"
    [ -f "$TEST_DIR/.claude/commands/work/obsolete.md" ]

    # C2 audit: --all no longer implies --clean — the wipe needs the
    # explicit flag (see tests/update-clean-backup.bats for the decoupling).
    run "$UPDATE_SCRIPT" -y --all --clean "$TEST_DIR"
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
# --add-plugin flag (lets users opt into a marketplace plugin without
# overwriting their settings.json on update.sh --settings)
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

@test "update.sh --settings preserves user enabledPlugins (regression)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1

    # A user enabled a marketplace plugin via `claude plugin install`.
    local tmp
    tmp=$(mktemp)
    jq '.enabledPlugins = {"frontend-design@claude-plugins-official": true}' \
        "$TEST_DIR/.claude/settings.json" > "$tmp"
    cp "$tmp" "$TEST_DIR/.claude/settings.json"
    rm -f "$tmp"

    # A forced settings overwrite must NOT silently disable the plugin.
    run "$UPDATE_SCRIPT" -y --settings "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ "$(jq -r '.enabledPlugins["frontend-design@claude-plugins-official"]' \
        "$TEST_DIR/.claude/settings.json")" = "true" ]
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

# =============================================================================
# Dogfood finding #3 — --dry-run alone (no -y) must not prompt
# Captured 2026-05-22 in specs/dogfood-v2-findings/spec.md. Without this
# guarantee, agents / CI / scripted invocations of `update --dry-run` block
# on stdin EOF as soon as a "modified" file is encountered. The fix is for
# --dry-run to imply --yes (non-interactive) implicitly.
# =============================================================================

@test "update.sh --dry-run alone (no -y) completes with closed stdin (friction #3)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    # Customise a command so the update would normally prompt.
    echo "# user-customised work-explore" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"

    # Pipe empty stdin to simulate non-TTY (agent / CI / scripted invocation).
    # If --dry-run still prompts, the subshell receives EOF and exits non-zero.
    run bash -c "'$UPDATE_SCRIPT' -n '$TEST_DIR/proj' </dev/null"
    [ "$status" -eq 0 ]
    # And the conflict surfacing from US-4 must still work (since --dry-run
    # implies --yes, the conflict tracking path is reached).
    [[ "$output" == *"Conflicts requiring decision"* ]]
    [[ "$output" == *"work-explore.md"* ]]
}

@test "update.sh --dry-run alone (no -y) does not print 'has been modified' prompt (friction #3)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# customised" > "$TEST_DIR/proj/.claude/commands/work/work-explore.md"

    run bash -c "'$UPDATE_SCRIPT' -n '$TEST_DIR/proj' </dev/null"
    [ "$status" -eq 0 ]
    # The interactive prompt line must NOT appear in --dry-run.
    [[ "$output" != *"has been modified. What to do?"* ]]
}

# =============================================================================
# Dogfood finding #2 — counter delta is correct in --dry-run
# Captured 2026-05-22 in specs/dogfood-v2-findings/spec.md. The "Commands:
# X → Y" line in update output reads `after` from the target dir, but in
# dry-run nothing is written, so before == after even when the foundation
# count would differ. The fix is to compute `after` from the foundation
# source dir (which is the would-be-state post-update).
# =============================================================================

@test "update.sh --dry-run reports correct counter delta when target has extras (friction #2)" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj" >/dev/null 2>&1

    # Foundation has N commands; inject 3 extras that don't exist in the
    # foundation, so the count diverges. After update --all --clean (the
    # wipe needs the explicit flag since the C2 audit) the extras would be
    # gone; before is N+3, after should be N.
    mkdir -p "$TEST_DIR/proj/.claude/commands/work"
    echo "# extra 1" > "$TEST_DIR/proj/.claude/commands/work/extra-fake-1.md"
    echo "# extra 2" > "$TEST_DIR/proj/.claude/commands/work/extra-fake-2.md"
    echo "# extra 3" > "$TEST_DIR/proj/.claude/commands/work/extra-fake-3.md"

    local before_count after_count
    before_count=$(find "$TEST_DIR/proj/.claude/commands" -name "*.md" -type f | wc -l | tr -d ' ')
    # v3+: a --simple project records no modules, so update --all deposits the
    # CORE only — full minus every module-owned command (horizontal AND thematic),
    # counted from the bundles so the expectation auto-tracks new modules.
    local full_cmds module_cmds
    full_cmds=$(find "$BATS_TEST_DIRNAME/../.claude/commands" -name "*.md" -type f | wc -l | tr -d ' ')
    module_cmds=$(grep -h '^\.claude/commands/' "$BATS_TEST_DIRNAME/../scripts/lib/modules/"*.txt | grep -c '\.md$')
    after_count=$((full_cmds - module_cmds))

    run bash -c "'$UPDATE_SCRIPT' -n -y --all --clean '$TEST_DIR/proj' </dev/null"
    [ "$status" -eq 0 ]
    # The delta must reflect what would have happened, not the
    # untouched-in-dry-run target. before > after expected (extras would
    # be removed by --clean).
    [[ "$output" == *"Commands: $before_count → $after_count"* ]]
    [ "$before_count" -gt "$after_count" ]
}

@test "update.sh migrates a legacy marker to the manifest and reports it (EF-205)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Simulate a pre-modules install: legacy marker only, no manifest.
    rm -f "$TEST_DIR/proj/.claude/foundation.json"
    echo "1.30.0" > "$TEST_DIR/proj/.claude/.foundation-version"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/.claude/foundation.json" ]
    [ ! -f "$TEST_DIR/proj/.claude/.foundation-version" ]
    [[ "$output" == *"migrated"* ]]
    # v3 strict migration: a legacy marker carries no recorded modules, so it
    # migrates with an empty module set (horizontal is opt-in; on-disk files are
    # untouched, `claude-base add` to resume tracking them).
    [ "$(jq -r '.modules | sort | join(",")' "$TEST_DIR/proj/.claude/foundation.json")" = "" ]
}

@test "update.sh --dry-run does NOT migrate a legacy marker" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    rm -f "$TEST_DIR/proj/.claude/foundation.json"
    echo "1.30.0" > "$TEST_DIR/proj/.claude/.foundation-version"

    run "$UPDATE_SCRIPT" --dry-run -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/proj/.claude/foundation.json" ]
    [ -f "$TEST_DIR/proj/.claude/.foundation-version" ]
}

# =============================================================================
# US-3 — module-aware update (T021)
#
# Spec: specs/foundation-modules/spec.md — CS-202/CS-203
# When a project has only a subset of modules installed, update must:
#   - Refresh files that belong to installed modules (treat them like core).
#   - Skip files that belong to absent modules (never copy them).
#   - Report installed-module updates and absent-module skips distinctly.
#   - In dry-run, name the module alongside each skipped item.
# =============================================================================

_modules_lib="$BATS_TEST_DIRNAME/../scripts/lib/modules.sh"

# Helper: set up a project with ONLY the 'legal' module installed + recorded.
# Returns the project path in $TEST_DIR/proj_us3.
# v3: modules are opt-in, so a --simple install ships the core only; we then
# explicitly add legal (files + manifest record). biz/growth stay absent.
_init_legal_only_project() {
    local proj="$TEST_DIR/proj_us3"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1
    bash -c "FOUNDATION_ROOT='$BATS_TEST_DIRNAME/..' '$BATS_TEST_DIRNAME/../scripts/module.sh' add legal --target '$proj'" >/dev/null 2>&1
    echo "$proj"
}

@test "update --all: installed module (legal) files are refreshed when stale (US-3)" {
    local proj
    proj="$(_init_legal_only_project)"
    # Corrupt a legal file to make it differ from the foundation.
    local legal_cmd
    legal_cmd=$(bash -c "source '$_modules_lib'; module_bundle_paths legal" | grep "commands" | head -1)
    echo "# stale" > "$proj/$legal_cmd"

    # C2 audit: --all no longer implies --clean, and a diverged file is
    # conservatively skipped without --force — the wipe-redeposit refresh
    # under test needs the explicit --clean.
    run "$UPDATE_SCRIPT" -y --all --clean "$proj"
    [ "$status" -eq 0 ]
    # The legal file must have been restored to the foundation copy.
    diff "$BASE_DIR/$legal_cmd" "$proj/$legal_cmd"
}

@test "update --all: absent module (biz) files are NOT installed (US-3 / CS-202)" {
    local proj
    proj="$(_init_legal_only_project)"

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    # No biz command should exist after the update.
    local biz_cmd
    biz_cmd=$(bash -c "source '$_modules_lib'; module_bundle_paths biz" | grep "commands" | head -1)
    [ ! -f "$proj/$biz_cmd" ]
}

@test "update --all: absent module (growth) files are NOT installed (US-3 / CS-203)" {
    local proj
    proj="$(_init_legal_only_project)"

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    local growth_cmd
    growth_cmd=$(bash -c "source '$_modules_lib'; module_bundle_paths growth" | grep "commands" | head -1)
    [ ! -f "$proj/$growth_cmd" ]
}

@test "update --all: summary reports absent modules as skipped (CS-203 / US-3)" {
    local proj
    proj="$(_init_legal_only_project)"

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    # The output must mention that biz and growth are not installed / skipped.
    [[ "$output" == *"biz"* ]] || [[ "$output" == *"growth"* ]]
    [[ "$output" == *"skip"* ]] || [[ "$output" == *"not installed"* ]] || [[ "$output" == *"module"* ]]
}

@test "update --all --dry-run: names the module for each skipped module item (US-3)" {
    local proj
    proj="$(_init_legal_only_project)"

    run "$UPDATE_SCRIPT" -y -n --all "$proj"
    [ "$status" -eq 0 ]
    # Dry-run must name at least one absent module in its output.
    [[ "$output" == *"biz"* ]] || [[ "$output" == *"growth"* ]]
}

# =============================================================================
# US-3 hardening — code-review findings on PR #267
# =============================================================================

@test "update --all --no-preset: corrupted manifest fails loud, no silent module skip (review)" {
    # Contract (EF-204): a corrupted manifest is a loud error, never a
    # silent fallback. --no-preset bypasses resolve_active_preset's check,
    # so the module filter itself must fail loud too.
    local proj="$TEST_DIR/proj_corrupt"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1
    echo '{not json' > "$proj/.claude/foundation.json"

    run "$UPDATE_SCRIPT" -y --all --no-preset "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"foundation.json"* ]]
}

@test "update --all --dry-run: legacy project previews the SAME module filtering as the real run (review)" {
    # A legacy minimal project (marker, no manifest, legal files only).
    # The real run migrates the marker then filters; dry-run must preview
    # that filtering — not announce installing every absent-module file —
    # while still writing nothing.
    local proj
    proj="$(_init_legal_only_project)"
    # Convert to legacy: drop the manifest, restore the version marker.
    rm -f "$proj/.claude/foundation.json"
    echo "1.40.0" > "$proj/.claude/.foundation-version"

    run "$UPDATE_SCRIPT" -y -n --all "$proj"
    [ "$status" -eq 0 ]
    # Dry-run writes nothing: no manifest created, marker untouched.
    [ ! -f "$proj/.claude/foundation.json" ]
    [ -f "$proj/.claude/.foundation-version" ]
    # No absent-module file is previewed as an ADDITION (the name may
    # appear in "Skip (module not installed: ...)" lines — that is the
    # correct preview of the real run's filtering).
    ! grep -E "Add.*biz-competitor" <<<"$output"
    # The module skip is announced instead.
    [[ "$output" == *"not installed"* ]]
}

@test "update --all: summary counts module-skipped FILES, not just module names (review)" {
    local proj
    proj="$(_init_legal_only_project)"

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    # Summary must carry a numeric file count for the module skips,
    # e.g. "Modules not installed (skipped): biz, growth (26 files)".
    [[ "$output" =~ [Mm]odules\ not\ installed.*\([0-9]+\ files\) ]]
}

@test "update --all: commands 'after' count excludes absent-module commands (review)" {
    local proj
    proj="$(_init_legal_only_project)"

    # The project records only `legal`, so update --all deposits core + legal.
    # Absent = every module-owned command EXCEPT legal's (all other modules,
    # horizontal AND thematic, are not in the manifest). Counted from bundles.
    local total all_module_cmds legal_cmds absent expected
    total=$(find "$BASE_DIR/.claude/commands" -name "*.md" -type f | wc -l | tr -d ' ')
    all_module_cmds=$(grep -h '^\.claude/commands/' "$BASE_DIR/scripts/lib/modules/"*.txt | grep -c '\.md$')
    legal_cmds=$(grep -h '^\.claude/commands/' "$BASE_DIR/scripts/lib/modules/legal.txt" | grep -c '\.md$')
    absent=$((all_module_cmds - legal_cmds))
    expected=$((total - absent))

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Commands: "*"→ $expected"* ]]
}

@test "update: warns about on-disk files of an absent module, preserves them (review)" {
    # Reachable state: interrupted remove, hand-edited manifest, or manual
    # restore. A plain update must not silently strand these files forever.
    # (--all is out of scope here: it cleans foundation dirs first, which
    # resolves the stale state by itself.)
    local proj
    proj="$(_init_legal_only_project)"
    # Simulate a leftover biz file (module absent from the manifest).
    local biz_cmd
    biz_cmd=$(grep '^\.claude/commands/' "$BASE_DIR/scripts/lib/modules/biz.txt" | head -1)
    mkdir -p "$proj/$(dirname "$biz_cmd")"
    cp "$BASE_DIR/$biz_cmd" "$proj/$biz_cmd"

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # Warned, with the adopt-or-remove hint naming the module.
    [[ "$output" == *"biz"* ]]
    [[ "$output" == *"add biz"* ]]
    # Preserved: update never deletes user files.
    [ -f "$proj/$biz_cmd" ]
}

# =============================================================================
# --restore flag (restore_backup)
#
# These exercise the destructive `rm -rf "$TARGET_DIR/.claude/commands"` branch
# that was previously only reachable via the (flag-driven but untested)
# --restore path.
# =============================================================================

@test "update.sh --restore replaces .claude/commands with the backup contents" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    [ -d "$TEST_DIR/.claude/commands" ]

    # Build a backup holding a sentinel that does not exist in the live dir
    local backup="$TEST_DIR/.claude/commands.backup.20240101_120000"
    mkdir -p "$backup"
    echo "from-backup" > "$backup/sentinel.md"
    # A live-only file that must be gone after restore
    echo "live" > "$TEST_DIR/.claude/commands/live-only.md"

    run "$UPDATE_SCRIPT" -y --restore "$backup" "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The sentinel from the backup is now live, the live-only file is gone
    [ -f "$TEST_DIR/.claude/commands/sentinel.md" ]
    [ ! -f "$TEST_DIR/.claude/commands/live-only.md" ]
}

@test "update.sh --restore creates a pre-restore safety backup of the live dir" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    local backup="$TEST_DIR/.claude/commands.backup.20240101_120000"
    mkdir -p "$backup"
    echo "from-backup" > "$backup/sentinel.md"

    run "$UPDATE_SCRIPT" -y --restore "$backup" "$TEST_DIR"
    [ "$status" -eq 0 ]

    # A .pre-restore.* safety copy of the previous live dir must exist
    run bash -c "ls -d $TEST_DIR/.claude/commands.pre-restore.* 2>/dev/null"
    [ -n "$output" ]
}

@test "update.sh --restore --dry-run does not modify .claude/commands" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1
    local backup="$TEST_DIR/.claude/commands.backup.20240101_120000"
    mkdir -p "$backup"
    echo "from-backup" > "$backup/sentinel.md"

    run "$UPDATE_SCRIPT" -y --dry-run --restore "$backup" "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Dry-run must not pull the sentinel into the live dir
    [ ! -f "$TEST_DIR/.claude/commands/sentinel.md" ]
}

@test "update.sh --restore errors on a non-existent backup" {
    "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null 2>&1

    run "$UPDATE_SCRIPT" -y --restore ".claude/commands.backup.does-not-exist" "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]] || [[ "$output" == *"backup"* ]]
}

@test "update.sh --restore requires an argument" {
    run "$UPDATE_SCRIPT" --restore
    [ "$status" -ne 0 ]
    [[ "$output" == *"--restore"* ]] || [[ "$output" == *"argument"* ]]
}

# =============================================================================
# Security drift advisory (#12) + --hook-scripts resync behavior
# =============================================================================

@test "update.sh warns about a legacy-contract hook left behind (no resync flag)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    mkdir -p "$TEST_DIR/proj/scripts/hooks"
    printf '#!/usr/bin/env bash\nCMD="$TOOL_INPUT"\nexit 0\n' > "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [[ "$output" == *"Security drift"* ]]
    [[ "$output" == *"command-validator.sh"* ]]
    [[ "$output" == *"--hook-scripts"* ]]
}

@test "update.sh --dry-run does not emit the security-drift advisory" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    mkdir -p "$TEST_DIR/proj/scripts/hooks"
    printf '#!/usr/bin/env bash\nCMD="$TOOL_INPUT"\nexit 0\n' > "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    run "$UPDATE_SCRIPT" --dry-run -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Security drift detected"* ]]
}

@test "update.sh --hook-scripts without --force skips a diverged hook (drift persists)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    printf '#!/usr/bin/env bash\nCMD="$TOOL_INPUT"\nexit 0\n' > "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    run "$UPDATE_SCRIPT" -y --hook-scripts "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # A diverged hook is conservatively skipped (could be a local customization),
    # so the legacy contract — and the advisory — remain.
    grep -q 'TOOL_INPUT' "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    [[ "$output" == *"Security drift detected"* ]]
}

@test "update.sh --hook-scripts --force resyncs hook scripts and clears the drift" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    printf '#!/usr/bin/env bash\nCMD="$TOOL_INPUT"\nexit 0\n' > "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    run "$UPDATE_SCRIPT" -y --hook-scripts --force "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # --force overwrites the diverged hook with the foundation's modern version
    # (reads stdin via jq), so the post-update advisory stays silent.
    grep -qE 'jq |/dev/stdin' "$TEST_DIR/proj/scripts/hooks/command-validator.sh"
    [[ "$output" != *"Security drift detected"* ]]
}

# =============================================================================
# C2 audit — install-tier coherence (minimal vs full) + substance-check shipping
#
# A minimal install (init --minimal) records tier "minimal" in foundation.json;
# update must refuse to silently convert it into a full install (~177 extra
# files). The deliberate conversion is update --graduate-full, which performs
# the full update and rewrites the tier to "full".
# =============================================================================

@test "update.sh errors on a minimal-tier project without --graduate-full" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Fake a minimal-tier manifest (behavior gate is the tier field, not the
    # install path — keeps the fixture fast).
    local manifest="$TEST_DIR/proj/.claude/foundation.json"
    jq '.tier = "minimal"' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -ne 0 ]
    # The refusal explains BOTH paths: minimal refresh and deliberate upgrade.
    [[ "$output" == *"minimal"* ]]
    [[ "$output" == *"export-minimal"* ]]
    [[ "$output" == *"--graduate-full"* ]]
}

@test "update.sh --graduate-full converts a real minimal install to full" {
    "$NEW_PROJECT_SCRIPT" --minimal -y "$TEST_DIR/proj" >/dev/null 2>&1
    [ "$(jq -r '.tier' "$TEST_DIR/proj/.claude/foundation.json")" = "minimal" ]

    run "$UPDATE_SCRIPT" -y --graduate-full "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # Tier rewritten: the project is now a tracked full install.
    [ "$(jq -r '.tier' "$TEST_DIR/proj/.claude/foundation.json")" = "full" ]
    # And the full catalog landed (minimal ships 5 agents; full ships far more).
    local agents
    agents=$(find "$TEST_DIR/proj/.claude/agents" -name "*.md" -type f | wc -l | tr -d ' ')
    [ "$agents" -gt 10 ]
}

@test "update.sh --graduate-full re-run on a full project stays green (idempotent)" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1

    run "$UPDATE_SCRIPT" -y --graduate-full "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ "$(jq -r '.tier' "$TEST_DIR/proj/.claude/foundation.json")" = "full" ]
}

@test "update.sh --help documents --graduate-full" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--graduate-full"* ]]
}

# The hook scripts/hooks/substance-check.sh requires the detector at
# scripts/substance-check.sh and silently no-ops when it is absent — so
# --hook-scripts (and therefore --all) must ship/refresh the detector too.

@test "update.sh --hook-scripts ships scripts/substance-check.sh when absent" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    rm -f "$TEST_DIR/proj/scripts/substance-check.sh"

    run "$UPDATE_SCRIPT" -y --hook-scripts "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/proj/scripts/substance-check.sh" ]
    [ -x "$TEST_DIR/proj/scripts/substance-check.sh" ]
}

@test "update.sh --hook-scripts --force refreshes a stale substance-check.sh" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    mkdir -p "$TEST_DIR/proj/scripts"
    echo "# stale detector" > "$TEST_DIR/proj/scripts/substance-check.sh"

    run "$UPDATE_SCRIPT" -y --hook-scripts --force "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    diff "$BASE_DIR/scripts/substance-check.sh" "$TEST_DIR/proj/scripts/substance-check.sh"
}
