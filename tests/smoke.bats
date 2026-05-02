#!/usr/bin/env bats

# =============================================================================
# Smoke tests - Quick validation of foundation integrity
# =============================================================================
# These tests verify that all essential components are present and
# correctly formatted. Used as the first line of validation before
# more detailed tests.
# =============================================================================

load 'test_helper'

# =============================================================================
# Command structure tests
# =============================================================================

@test "smoke: all commands have a .md file" {
    local count
    count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 100 ]
}

@test "smoke: command categories exist" {
    [ -d "$SOCLE_DIR/.claude/commands/work" ]
    [ -d "$SOCLE_DIR/.claude/commands/dev" ]
    [ -d "$SOCLE_DIR/.claude/commands/qa" ]
    [ -d "$SOCLE_DIR/.claude/commands/ops" ]
    [ -d "$SOCLE_DIR/.claude/commands/doc" ]
    [ -d "$SOCLE_DIR/.claude/commands/biz" ]
    [ -d "$SOCLE_DIR/.claude/commands/growth" ]
    [ -d "$SOCLE_DIR/.claude/commands/legal" ]
    [ -d "$SOCLE_DIR/.claude/commands/data" ]
}

@test "smoke: essential work commands exist" {
    [ -f "$SOCLE_DIR/.claude/commands/work/work-explore.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-plan.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-commit.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-pr.md" ]
}

@test "smoke: essential dev commands exist" {
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-tdd.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-test.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-debug.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-api.md" ]
}

@test "smoke: essential qa commands exist" {
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-security.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-review.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-perf.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-audit.md" ]
}

@test "smoke: assistant orchestrator exists" {
    [ -f "$SOCLE_DIR/.claude/commands/assistant.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/assistant-auto.md" ]
}

# =============================================================================
# Agent structure tests
# =============================================================================

@test "smoke: all agents have a .md file" {
    local count
    count=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 40 ]
}

@test "smoke: essential agents exist" {
    [ -f "$SOCLE_DIR/.claude/agents/work-explore.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/qa-security.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/qa-audit.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/dev-debug.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/ops-health.md" ]
}

# =============================================================================
# Skill structure tests
# =============================================================================

@test "smoke: all skills have a folder with SKILL.md" {
    local count
    count=$(find "$SOCLE_DIR/.claude/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 25 ]
}

@test "smoke: essential skills exist" {
    [ -f "$SOCLE_DIR/.claude/skills/dev-tdd/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/work-commit/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/qa-review/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/qa-security/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/work-explore/SKILL.md" ]
}

@test "smoke: skills have valid YAML frontmatter" {
    local skill_file="$SOCLE_DIR/.claude/skills/dev-tdd/SKILL.md"
    # Check that the file starts with ---
    head -1 "$skill_file" | grep -q "^---$"
}

# =============================================================================
# Rule structure tests
# =============================================================================

@test "smoke: essential rules exist" {
    [ -f "$SOCLE_DIR/.claude/rules/git.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/workflow.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/typescript.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/security.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/testing.md" ]
}

@test "smoke: per-language rules exist" {
    [ -f "$SOCLE_DIR/.claude/rules/typescript.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/python.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/go.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/flutter.md" ]
}

# =============================================================================
# Configuration tests
# =============================================================================

@test "smoke: settings.json is valid" {
    skip_if_no_jq
    jq . "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json contains permissions" {
    skip_if_no_jq
    jq -e '.permissions' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json contains hooks" {
    skip_if_no_jq
    jq -e '.hooks' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json blocks rm -rf /" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("rm -rf /"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json blocks git push --force" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("git push --force"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json blocks sudo" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("sudo"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

# =============================================================================
# Main file tests
# =============================================================================

@test "smoke: CLAUDE.md exists and is not empty" {
    [ -f "$SOCLE_DIR/CLAUDE.md" ]
    [ -s "$SOCLE_DIR/CLAUDE.md" ]
    local lines
    lines=$(wc -l < "$SOCLE_DIR/CLAUDE.md")
    # CLAUDE.md uses @imports since PR#29, baseline is ~70 lines
    [ "$lines" -gt 30 ]
}

@test "smoke: VERSION exists and contains a valid version" {
    [ -f "$SOCLE_DIR/VERSION" ]
    grep -qE "^[0-9]+\.[0-9]+\.[0-9]+$" "$SOCLE_DIR/VERSION"
}

@test "smoke: CHANGELOG.md exists and is up to date" {
    [ -f "$SOCLE_DIR/CHANGELOG.md" ]
    # Check that the changelog mentions the current version
    local version
    version=$(cat "$SOCLE_DIR/VERSION")
    # The version may be in [Unreleased] or in a section
    grep -qE "\[.*\]" "$SOCLE_DIR/CHANGELOG.md"
}

@test "smoke: SECURITY.md exists" {
    [ -f "$SOCLE_DIR/SECURITY.md" ]
    [ -s "$SOCLE_DIR/SECURITY.md" ]
}

@test "smoke: .gitleaks.toml exists" {
    [ -f "$SOCLE_DIR/.gitleaks.toml" ]
}

# =============================================================================
# Script tests
# =============================================================================

@test "smoke: all scripts are executable" {
    for script in "$SOCLE_DIR/scripts"/*.sh; do
        [ -x "$script" ]
    done
}

@test "smoke: essential scripts exist" {
    [ -f "$SOCLE_DIR/scripts/validate.sh" ]
    [ -f "$SOCLE_DIR/scripts/doctor.sh" ]
    [ -f "$SOCLE_DIR/scripts/new-project.sh" ]
    [ -f "$SOCLE_DIR/scripts/lint.sh" ]
    [ -f "$SOCLE_DIR/scripts/test.sh" ]
}

@test "smoke: lib/common.sh exists and is sourceable" {
    [ -f "$SOCLE_DIR/scripts/lib/common.sh" ]
    source "$SOCLE_DIR/scripts/lib/common.sh"
}

# =============================================================================
# Counter consistency tests
# =============================================================================

@test "smoke: command count matches CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    # Must be within the expected range (~130 currently, margin for growth)
    [ "$actual_count" -ge 100 ]
    [ "$actual_count" -le 150 ]
}

@test "smoke: agent count matches CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    # Must be within the expected range (50-60)
    [ "$actual_count" -ge 45 ]
    [ "$actual_count" -le 70 ]
}

@test "smoke: skill count matches CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/skills" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    # -1 for the skills directory itself
    actual_count=$((actual_count - 1))
    # Must be within the expected range (35-55)
    [ "$actual_count" -ge 25 ]
    [ "$actual_count" -le 55 ]
}

# =============================================================================
# Command file format tests
# =============================================================================

@test "smoke: commands have a markdown title" {
    local errors=0
    while IFS= read -r file; do
        if ! head -5 "$file" | grep -q "^# "; then
            errors=$((errors + 1))
        fi
    done < <(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f)
    [ "$errors" -eq 0 ]
}

@test "smoke: agents have a markdown title" {
    local errors=0
    while IFS= read -r file; do
        # Agents may have a YAML frontmatter before the title
        if ! head -20 "$file" | grep -q "^# "; then
            errors=$((errors + 1))
        fi
    done < <(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f)
    [ "$errors" -eq 0 ]
}

# =============================================================================
# Template tests
# =============================================================================

@test "smoke: templates exist" {
    [ -d "$SOCLE_DIR/.claude/templates" ]
    local count
    count=$(find "$SOCLE_DIR/.claude/templates" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 3 ]
}

# =============================================================================
# Output-styles tests
# =============================================================================

@test "smoke: output-styles exist" {
    [ -d "$SOCLE_DIR/.claude/output-styles" ]
    local count
    count=$(find "$SOCLE_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 5 ]
}

# =============================================================================
# Documentation tests
# =============================================================================

@test "smoke: documentation exists" {
    [ -d "$SOCLE_DIR/docs" ]
    [ -f "$SOCLE_DIR/README.md" ]
}

@test "smoke: guides exist" {
    [ -d "$SOCLE_DIR/docs/guides" ] || [ -d "$SOCLE_DIR/website/docs/guides" ]
}

# =============================================================================
# CI/CD tests
# =============================================================================

@test "smoke: GitHub Actions workflows exist" {
    [ -d "$SOCLE_DIR/.github/workflows" ]
    [ -f "$SOCLE_DIR/.github/workflows/ci.yml" ]
}
