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
    [[ "$output" == *"Node"* ]] || [[ "$output" == *"Express"* ]]
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
    [[ "$output" == *"React"* ]]
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
    [[ "$output" == *"TypeScript"* ]]
}

@test "new-project.sh detects Python" {
    mkdir -p "$TEST_DIR"
    echo "flask==2.0.0" > "$TEST_DIR/requirements.txt"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Python"* ]] || [[ "$output" == *"Flask"* ]]
}

@test "new-project.sh detects Go" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/go.mod" << 'EOF'
module test-go

go 1.21
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Go"* ]]
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
    [[ "$output" == *"CI/CD"* ]] || [[ "$output" == *"GitHub Actions"* ]] || [[ "$output" == *"Tests"* ]]
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
# --ci-existing flag tests
#
# These drive the existing-CI/CD decision non-interactively so the destructive
# merge/replace branches (which delete *.yml) are reachable in tests instead of
# being gated behind the interactive `get_cicd_choice` prompt.
# =============================================================================

@test "new-project.sh --help documents --ci-existing" {
    run "$NEW_PROJECT_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--ci-existing"* ]]
}

@test "new-project.sh --ci-existing rejects an invalid value" {
    run "$NEW_PROJECT_SCRIPT" --ci-existing bogus "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"ci-existing"* ]] || [[ "$output" == *"keep"* ]]
}

@test "new-project.sh --ci-existing without a value fails with a clean error" {
    run "$NEW_PROJECT_SCRIPT" --ci-existing
    [ "$status" -ne 0 ]
    [[ "$output" == *"ci-existing"* ]]
}

@test "new-project.sh --ci-existing replace removes existing workflows and installs the foundation ones" {
    mkdir -p "$TEST_DIR/.github/workflows"
    echo "name: Custom" > "$TEST_DIR/.github/workflows/custom.yml"

    run "$NEW_PROJECT_SCRIPT" -y --ci-existing replace "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The custom workflow is gone, replaced by the foundation templates
    [ ! -f "$TEST_DIR/.github/workflows/custom.yml" ]
    [ -f "$TEST_DIR/.github/workflows/ci.yml" ]
}

@test "new-project.sh --ci-existing merge keeps existing workflows and adds the missing ones" {
    mkdir -p "$TEST_DIR/.github/workflows"
    # Only automated tests present → ci.yml (lint/security/...) is missing and added
    cat > "$TEST_DIR/.github/workflows/custom.yml" << 'EOF'
name: Custom
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test
EOF

    run "$NEW_PROJECT_SCRIPT" -y --ci-existing merge "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The custom workflow survives AND foundation workflows were added
    [ -f "$TEST_DIR/.github/workflows/custom.yml" ]
    [ -f "$TEST_DIR/.github/workflows/ci.yml" ]
}

@test "new-project.sh --ci-existing keep leaves existing CI/CD untouched and adds nothing" {
    mkdir -p "$TEST_DIR/.github/workflows"
    echo "name: Custom" > "$TEST_DIR/.github/workflows/custom.yml"

    run "$NEW_PROJECT_SCRIPT" -y --ci-existing keep "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/.github/workflows/custom.yml" ]
    [ ! -f "$TEST_DIR/.github/workflows/ci.yml" ]
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

@test "new-project.sh --preset records the preset name in foundation.json (US-1)" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/synth-rec.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "synth-rec",
  "displayName": "Synthetic recording preset",
  "description": "Synthetic preset for manifest preset-recording test.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["synth-rec.marker"]},
  "foundation": {"skills": {"drop": ["dev-flutter"]}},
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF
    run "$NEW_PROJECT_SCRIPT" --preset synth-rec --presets-dir "$preset_dir" -y "$TEST_DIR/proj-rec"
    [ "$status" -eq 0 ]
    local manifest="$TEST_DIR/proj-rec/.claude/foundation.json"
    [ -f "$manifest" ]
    [ "$(jq -r '.preset' "$manifest")" = "synth-rec" ]
    # v3: a preset with no defaultModules records NO modules (opt-in default).
    [ "$(jq -r '.modules | sort | join(",")' "$manifest")" = "" ]
    [ ! -f "$TEST_DIR/proj-rec/.claude/.foundation-version" ]
}

@test "new-project.sh bare init records null preset and empty module set (US-1, v3 opt-in)" {
    run "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj-bare"
    [ "$status" -eq 0 ]
    local manifest="$TEST_DIR/proj-bare/.claude/foundation.json"
    [ "$(jq -r '.preset' "$manifest")" = "null" ]
    # v3: horizontal domains are opt-in — a bare init records no modules.
    [ "$(jq -r '.modules | sort | join(",")' "$manifest")" = "" ]
}

@test "new-project.sh --simple fails loud when the manifest cannot be written" {
    mkdir -p "$TEST_DIR/proj/.claude/foundation.json"   # directory squatting the path
    run "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"foundation"* ]]
}

# =============================================================================
# US-5: preset defaultModules — init installs only declared modules;
# backward compat: no defaultModules → all modules; summary shows hints.
# =============================================================================

# Helper: write a synthetic preset with defaultModules into $1
# $1 = directory, $2 = preset name, $3 = JSON array of defaultModules (or empty string for absent)
_write_preset_with_dm() {
    local dir="$1" name="$2" dm_json="$3"
    mkdir -p "$dir"
    local dm_field=""
    [[ -n "$dm_json" ]] && dm_field=", \"defaultModules\": $dm_json"
    cat > "$dir/$name.json" <<EOF
{
  "name": "$name",
  "displayName": "Synthetic $name preset",
  "description": "Synthetic preset for US-5 test.",
  "version": "1.0.0",
  "status": "community-curated",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false},
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "outOfScope": []${dm_field}
}
EOF
}

@test "new-project.sh preset with defaultModules installs only those modules and records them (US-5)" {
    local preset_dir="$TEST_DIR/presets-dm"
    _write_preset_with_dm "$preset_dir" "slim-preset" '["legal"]'
    run "$NEW_PROJECT_SCRIPT" --preset slim-preset --presets-dir "$preset_dir" -y "$TEST_DIR/proj-dm"
    [ "$status" -eq 0 ]
    local manifest="$TEST_DIR/proj-dm/.claude/foundation.json"
    [ -f "$manifest" ]
    # Only "legal" must be in the manifest modules
    [ "$(jq -r '.modules | sort | join(",")' "$manifest")" = "legal" ]
    # At least one legal agent/command must be present (bundle was installed)
    local legal_count
    legal_count=$(find "$TEST_DIR/proj-dm/.claude/agents" -name "legal-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$legal_count" -gt 0 ]
    # No file of a non-selected module survives the filter.
    local biz_count
    biz_count=$(find "$TEST_DIR/proj-dm/.claude" -name "biz-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$biz_count" -eq 0 ]
    # Emptied module directories are removed too — no hollow biz/growth
    # shells left under commands/.
    [ ! -d "$TEST_DIR/proj-dm/.claude/commands/biz" ]
    [ ! -d "$TEST_DIR/proj-dm/.claude/commands/growth" ]
}

@test "new-project.sh preset without defaultModules installs no modules (v3 opt-in, supersedes US-5 backward compat)" {
    local preset_dir="$TEST_DIR/presets-no-dm"
    _write_preset_with_dm "$preset_dir" "full-preset" ""
    run "$NEW_PROJECT_SCRIPT" --preset full-preset --presets-dir "$preset_dir" -y "$TEST_DIR/proj-no-dm"
    [ "$status" -eq 0 ]
    local manifest="$TEST_DIR/proj-no-dm/.claude/foundation.json"
    [ -f "$manifest" ]
    # v3: absence of defaultModules means NO modules (opt-in) — not "all".
    [ "$(jq -r '.modules | sort | join(",")' "$manifest")" = "" ]
    [ ! -d "$TEST_DIR/proj-no-dm/.claude/commands/biz" ]
    [ ! -d "$TEST_DIR/proj-no-dm/.claude/commands/legal" ]
    [ ! -d "$TEST_DIR/proj-no-dm/.claude/commands/growth" ]
}

@test "new-project.sh init summary lists available-but-not-installed modules with claude-base add hint (US-5)" {
    local preset_dir="$TEST_DIR/presets-hint"
    _write_preset_with_dm "$preset_dir" "hint-preset" '["legal"]'
    run "$NEW_PROJECT_SCRIPT" --preset hint-preset --presets-dir "$preset_dir" -y "$TEST_DIR/proj-hint"
    [ "$status" -eq 0 ]
    # Summary must mention the two not-installed modules (biz, growth) with the add verb
    [[ "$output" == *"claude-base add"* ]]
    [[ "$output" == *"biz"* ]] || [[ "$output" == *"growth"* ]]
}

# =============================================================================
# S2 (horizontal-pure-modules) — default install is CORE ONLY (opt-in modules).
# =============================================================================

@test "new-project.sh default install is core-only — no horizontal modules (S2/EF-301)" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Horizontal domains are NOT installed by default (opt-in via claude-base add).
    [ ! -d "$TEST_DIR/.claude/commands/biz" ]
    [ ! -d "$TEST_DIR/.claude/commands/legal" ]
    [ ! -d "$TEST_DIR/.claude/commands/growth" ]
    [ ! -f "$TEST_DIR/.claude/agents/biz-mvp.md" ]
    [ ! -f "$TEST_DIR/.claude/agents/growth-cro.md" ]
    # Core is present.
    [ -f "$TEST_DIR/.claude/commands/work/work-plan.md" ]
    [ -d "$TEST_DIR/.claude/commands/dev" ]
    [ -d "$TEST_DIR/.claude/commands/ops" ]
}

@test "new-project.sh default install count = full catalog minus all modules (CS-301)" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    # A default install ships the core only — every module (horizontal AND
    # thematic) is opt-in, so the deposited command count is full minus every
    # module-owned command. Computed from the bundles so it auto-tracks new modules.
    local full module_cmds proj_cmds
    full=$(find "$BASE_DIR/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    module_cmds=$(grep -h '^\.claude/commands/' "$BASE_DIR"/scripts/lib/modules/*.txt | grep -c '\.md$')
    proj_cmds=$(find "$TEST_DIR/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    [ "$proj_cmds" -eq "$((full - module_cmds))" ]
}

@test "new-project.sh bare install advertises opt-in modules with add hint (S2/EF-301)" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base add"* ]]
}

# =============================================================================
# CI/CD analysis — path with spaces (regression)
# =============================================================================

@test "new-project.sh analyze_existing_cicd detects capabilities when the project path contains spaces" {
    # Regression: workflow_files was piped to `xargs grep`, which word-splits
    # a path like ".../my project/..." so grep never sees the real files and
    # every capability is reported missing.
    local proj="$TEST_DIR/my project"
    mkdir -p "$proj/.github/workflows"
    cat > "$proj/.github/workflows/ci.yml" <<'YAML'
name: ci
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/cache@v4
      - run: npm test
YAML

    run env BASE_DIR="$BASE_DIR" bash -c '
        source "$BASE_DIR/scripts/new-project.sh"
        analyze_existing_cicd "$1"
        printf "PRESENT:%s\n" "${CICD_PRESENT[@]-}"
        printf "MISSING:%s\n" "${CICD_MISSING[@]-}"
    ' _ "$proj"

    [ "$status" -eq 0 ]
    # The two capabilities the workflow declares must be classified PRESENT,
    # each on its own line (so a substring match cannot leak from MISSING).
    [[ "$output" == *"PRESENT:Automated tests"* ]]
    [[ "$output" == *"PRESENT:Dependency cache"* ]]
    [[ "$output" != *"MISSING:Automated tests"* ]]
    [[ "$output" != *"MISSING:Dependency cache"* ]]
}

@test "new-project.sh installs all 4 global (path-less) rules (2026-07-12 regression)" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    # The copied rules/README.md documents 4 global rules; init must ship all
    # four, else an installed project references rules absent from disk.
    [ -f "$TEST_DIR/.claude/rules/git.md" ]
    [ -f "$TEST_DIR/.claude/rules/workflow.md" ]
    [ -f "$TEST_DIR/.claude/rules/self-improvement.md" ]
    [ -f "$TEST_DIR/.claude/rules/vendor-precedence.md" ]
}
