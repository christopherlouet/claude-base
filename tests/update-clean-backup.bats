#!/usr/bin/env bats

# =============================================================================
# Audit cluster C2 — update/init data-loss guardrails.
#
# P1: `update --all` used to imply --clean, silently wiping user-created files
# in every .claude/ subdir with a backup covering ONLY commands/. And re-running
# init on an existing project cleaned with NO backup at all.
# Contract under test:
#   - --all means "update every category"; wiping requires an explicit --clean.
#   - Any clean (update --clean, re-init) is preceded by a full backup of all
#     six dirs clean_claude_dirs wipes: commands, skills, agents, rules,
#     output-styles, templates — under a single .claude.backup.<ts>/ root.
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

# Plant one user-created file in each of the six cleaned dirs.
_plant_user_files() {
    local proj="$1"
    mkdir -p "$proj/.claude/rules" "$proj/.claude/agents" "$proj/.claude/commands" \
             "$proj/.claude/skills/my-team-skill" "$proj/.claude/output-styles" \
             "$proj/.claude/templates"
    echo "# my team rule"     > "$proj/.claude/rules/my-team-rule.md"
    echo "# my team agent"    > "$proj/.claude/agents/my-team-agent.md"
    echo "# my team command"  > "$proj/.claude/commands/my-team-command.md"
    echo "# my team skill"    > "$proj/.claude/skills/my-team-skill/SKILL.md"
    echo "# my team style"    > "$proj/.claude/output-styles/my-team-style.md"
    echo "# my team template" > "$proj/.claude/templates/my-team-template.md"
}

# Print the single .claude.backup.<ts> root of a project (fails if none).
_backup_root() {
    find "$1" -maxdepth 1 -type d -name '.claude.backup.*' | head -1
}

@test "update --all does NOT imply --clean: user rule survives" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# my team rule" > "$TEST_DIR/proj/.claude/rules/my-team-rule.md"

    run "$UPDATE_SCRIPT" -y --all "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # --all alone must never wipe: the user file survives.
    [ -f "$TEST_DIR/proj/.claude/rules/my-team-rule.md" ]
}

@test "update --all --clean wipes but backs up ALL SIX cleaned dirs first" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    _plant_user_files "$TEST_DIR/proj"

    run "$UPDATE_SCRIPT" -y --all --clean "$TEST_DIR/proj"
    [ "$status" -eq 0 ]

    # The explicit --clean removed the user files from the live tree.
    [ ! -f "$TEST_DIR/proj/.claude/rules/my-team-rule.md" ]
    [ ! -f "$TEST_DIR/proj/.claude/agents/my-team-agent.md" ]

    # ...but every one of them landed in the timestamped backup root.
    local backup_root
    backup_root="$(_backup_root "$TEST_DIR/proj")"
    [ -n "$backup_root" ]
    [ -f "$backup_root/rules/my-team-rule.md" ]
    [ -f "$backup_root/agents/my-team-agent.md" ]
    [ -f "$backup_root/commands/my-team-command.md" ]
    [ -f "$backup_root/skills/my-team-skill/SKILL.md" ]
    [ -f "$backup_root/output-styles/my-team-style.md" ]
    [ -f "$backup_root/templates/my-team-template.md" ]
}

@test "update --clean (without --all) also takes the full backup" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# my team rule" > "$TEST_DIR/proj/.claude/rules/my-team-rule.md"

    run "$UPDATE_SCRIPT" -y --clean "$TEST_DIR/proj"
    [ "$status" -eq 0 ]

    local backup_root
    backup_root="$(_backup_root "$TEST_DIR/proj")"
    [ -n "$backup_root" ]
    [ -f "$backup_root/rules/my-team-rule.md" ]
}

@test "update --help documents --all --clean as the wipe-and-replace combo" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--all --clean"* ]]
}

@test "re-init (simple mode) backs up user files before cleaning" {
    "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# my team rule" > "$TEST_DIR/proj/.claude/rules/my-team-rule.md"

    run "$NEW_PROJECT_SCRIPT" --simple -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]

    # Re-init still cleans (fresh install semantics)...
    [ ! -f "$TEST_DIR/proj/.claude/rules/my-team-rule.md" ]
    # ...but only after a backup captured the user file.
    local backup_root
    backup_root="$(_backup_root "$TEST_DIR/proj")"
    [ -n "$backup_root" ]
    [ -f "$backup_root/rules/my-team-rule.md" ]
}

@test "re-init (full create_project path) backs up user files before cleaning" {
    "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR/proj" >/dev/null 2>&1
    echo "# my team rule" > "$TEST_DIR/proj/.claude/rules/my-team-rule.md"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]

    [ ! -f "$TEST_DIR/proj/.claude/rules/my-team-rule.md" ]
    local backup_root
    backup_root="$(_backup_root "$TEST_DIR/proj")"
    [ -n "$backup_root" ]
    [ -f "$backup_root/rules/my-team-rule.md" ]
}
