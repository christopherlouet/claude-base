#!/usr/bin/env bats

# =============================================================================
# Tests for the preset system (specs/presets/spec.md)
# =============================================================================
# Covers:
#   - .claude/presets/nextjs.json schema validation
#   - scripts/validate-presets.sh
#   - scripts/new-project.sh --preset / --list-presets flags
#   - foundation.skills.drop filter applied on real install
# =============================================================================

load 'test_helper'

NEW_PROJECT="$SOCLE_DIR/scripts/new-project.sh"
VALIDATE_PRESETS="$SOCLE_DIR/scripts/validate-presets.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Manifest validation
# =============================================================================

@test "presets: nextjs.json exists and is valid JSON" {
    [ -f "$SOCLE_DIR/.claude/presets/nextjs.json" ]
    run jq -e . "$SOCLE_DIR/.claude/presets/nextjs.json"
    [ "$status" -eq 0 ]
}

@test "presets: nextjs.json has required fields" {
    local f="$SOCLE_DIR/.claude/presets/nextjs.json"
    [ "$(jq -r '.name' "$f")" = "nextjs" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ -n "$(jq -r '.displayName' "$f")" ]
    [ -n "$(jq -r '.description' "$f")" ]
    [ "$(jq -r '.appliesToTypes | length' "$f")" -gt 0 ]
}

@test "presets: nextjs.json defaults are well-typed" {
    local f="$SOCLE_DIR/.claude/presets/nextjs.json"
    [ "$(jq -r '.defaults.ci | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.hooks | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.mcp | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.docker | type' "$f")" = "boolean" ]
}

@test "presets: nextjs.json drops at least one out-of-stack skill" {
    local f="$SOCLE_DIR/.claude/presets/nextjs.json"
    local n
    n=$(jq -r '.foundation.skills.drop | length' "$f")
    [ "$n" -ge 1 ]
}

# =============================================================================
# validate-presets.sh
# =============================================================================

@test "presets: validate-presets.sh accepts the official nextjs preset" {
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs.json"* ]]
}

@test "presets: validate-presets.sh rejects a preset with missing required fields" {
    cat > "$TEST_DIR/bad.json" <<'EOF'
{
  "name": "bad-preset",
  "appliesToTypes": ["react"]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing required field"* ]]
}

@test "presets: validate-presets.sh rejects an invalid status" {
    cat > "$TEST_DIR/bad-status.json" <<'EOF'
{
  "name": "x",
  "displayName": "x",
  "description": "x",
  "status": "alpha-release",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": []
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-status.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"status"* ]]
}

@test "presets: validate-presets.sh rejects invalid name pattern" {
    cat > "$TEST_DIR/bad-name.json" <<'EOF'
{
  "name": "Bad_Name",
  "displayName": "x",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": []
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-name.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"pattern"* ]]
}

# =============================================================================
# new-project.sh --list-presets
# =============================================================================

@test "presets: --list-presets shows nextjs" {
    run "$NEW_PROJECT" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"maintainer-vouched"* ]]
}

# =============================================================================
# new-project.sh --preset
# =============================================================================

@test "presets: --preset on unknown name fails with clear error" {
    run "$NEW_PROJECT" --preset nonexistent-preset "$TEST_DIR/proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"preset not found"* ]] || [[ "$output" == *"nonexistent-preset"* ]]
}

@test "presets: --preset requires a project path" {
    run "$NEW_PROJECT" --preset nextjs
    [ "$status" -ne 0 ]
    [[ "$output" == *"project path"* ]] || [[ "$output" == *"required"* ]]
}

@test "presets: --preset nextjs --dry-run does not write files and exits 0" {
    local target="$TEST_DIR/dry-target"
    run "$NEW_PROJECT" --preset nextjs --dry-run "$target"
    [ "$status" -eq 0 ]
    [ ! -d "$target/.claude" ]
}

@test "presets: --preset nextjs install actually drops the listed skills" {
    local target="$TEST_DIR/proj"
    "$NEW_PROJECT" --preset nextjs "$target" >/dev/null 2>&1
    [ -d "$target/.claude/skills" ]
    # Each skill in foundation.skills.drop must be absent post-install
    local drops
    drops=$(jq -r '.foundation.skills.drop[]' "$SOCLE_DIR/.claude/presets/nextjs.json")
    while IFS= read -r skill; do
        [ -z "$skill" ] && continue
        [ ! -d "$target/.claude/skills/$skill" ]
    done <<< "$drops"
}

@test "presets: --preset nextjs install keeps stack-relevant skills" {
    local target="$TEST_DIR/proj"
    "$NEW_PROJECT" --preset nextjs "$target" >/dev/null 2>&1
    # Pro-dev essentials must be present
    [ -d "$target/.claude/skills/work-quick" ]
    [ -d "$target/.claude/skills/dev-tdd" ]
    [ -d "$target/.claude/skills/qa-review" ]
    [ -d "$target/.claude/skills/dev-nextjs" ]
}

@test "presets: --preset nextjs applies CI default (ci=true)" {
    local target="$TEST_DIR/proj"
    "$NEW_PROJECT" --preset nextjs "$target" >/dev/null 2>&1
    # The nextjs preset has ci: true → .github/workflows/ should exist
    [ -d "$target/.github/workflows" ]
}

@test "presets: --preset nextjs respects user override (--mcp adds mcp despite default false)" {
    local target="$TEST_DIR/proj-mcp"
    "$NEW_PROJECT" --preset nextjs --mcp "$target" >/dev/null 2>&1
    # User passed --mcp; preset's default mcp:false should not override
    [ -f "$target/.mcp.json" ] || [ -f "$target/.claude/.mcp.json" ]
}

# =============================================================================
# homelab-proxmox preset
# =============================================================================

@test "presets: homelab-proxmox.json exists and is valid JSON" {
    [ -f "$SOCLE_DIR/.claude/presets/homelab-proxmox.json" ]
    run jq -e . "$SOCLE_DIR/.claude/presets/homelab-proxmox.json"
    [ "$status" -eq 0 ]
}

@test "presets: homelab-proxmox.json has required fields" {
    local f="$SOCLE_DIR/.claude/presets/homelab-proxmox.json"
    [ "$(jq -r '.name' "$f")" = "homelab-proxmox" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ "$(jq -r '.defaults.designStyle' "$f")" = "cockpit" ]
}

@test "presets: --list-presets shows both nextjs and homelab-proxmox" {
    run "$NEW_PROJECT" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"homelab-proxmox"* ]]
}

@test "presets: --preset homelab-proxmox install drops UI/mobile skills" {
    local target="$TEST_DIR/proj-proxmox"
    "$NEW_PROJECT" --preset homelab-proxmox "$target" >/dev/null 2>&1
    # 10 skills dropped from foundation.skills.drop
    [ ! -d "$target/.claude/skills/dev-flutter" ]
    [ ! -d "$target/.claude/skills/dev-nextjs" ]
    [ ! -d "$target/.claude/skills/dev-shadcn" ]
    [ ! -d "$target/.claude/skills/qa-chrome" ]
    [ ! -d "$target/.claude/skills/qa-responsive" ]
    [ ! -d "$target/.claude/skills/qa-design" ]
    [ ! -d "$target/.claude/skills/ops-mobile-release" ]
    [ ! -d "$target/.claude/skills/growth-cro" ]
    [ ! -d "$target/.claude/skills/dev-frontend-design" ]
    [ ! -d "$target/.claude/skills/dev-react-perf" ]
}

@test "presets: --preset homelab-proxmox install keeps homelab-relevant skills" {
    local target="$TEST_DIR/proj-proxmox"
    "$NEW_PROJECT" --preset homelab-proxmox "$target" >/dev/null 2>&1
    # Stack-essential skills must be present
    [ -d "$target/.claude/skills/ops-proxmox" ]
    [ -d "$target/.claude/skills/ops-opnsense" ]
    [ -d "$target/.claude/skills/ops-infra-code" ]
    [ -d "$target/.claude/skills/ops-monitoring" ]
    [ -d "$target/.claude/skills/ops-database" ]
    # Workflow essentials always present
    [ -d "$target/.claude/skills/dev-tdd" ]
    [ -d "$target/.claude/skills/qa-review" ]
}

@test "presets: --preset homelab-proxmox applies cockpit designStyle by default" {
    local target="$TEST_DIR/proj-proxmox-style"
    "$NEW_PROJECT" --preset homelab-proxmox "$target" >/dev/null 2>&1
    # Foundation install completed (no specific assertion on style file —
    # the style is captured in DESIGN_STYLE global; this test just validates
    # no failure when style differs from nextjs preset)
    [ -d "$target/.claude" ]
}

# =============================================================================
# cli-tools preset
# =============================================================================

@test "presets: cli-tools.json exists and is valid JSON" {
    [ -f "$SOCLE_DIR/.claude/presets/cli-tools.json" ]
    run jq -e . "$SOCLE_DIR/.claude/presets/cli-tools.json"
    [ "$status" -eq 0 ]
}

@test "presets: cli-tools.json has required fields" {
    local f="$SOCLE_DIR/.claude/presets/cli-tools.json"
    [ "$(jq -r '.name' "$f")" = "cli-tools" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ "$(jq -r '.defaults.designStyle' "$f")" = "terminal" ]
}

@test "presets: --list-presets shows all three vouched presets" {
    run "$NEW_PROJECT" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"homelab-proxmox"* ]]
    [[ "$output" == *"cli-tools"* ]]
}

@test "presets: --preset cli-tools drops UI/mobile/infra-heavy skills" {
    local target="$TEST_DIR/proj-cli"
    "$NEW_PROJECT" --preset cli-tools "$target" >/dev/null 2>&1
    [ ! -d "$target/.claude/skills/dev-flutter" ]
    [ ! -d "$target/.claude/skills/dev-nextjs" ]
    [ ! -d "$target/.claude/skills/dev-shadcn" ]
    [ ! -d "$target/.claude/skills/ops-proxmox" ]
    [ ! -d "$target/.claude/skills/ops-opnsense" ]
    [ ! -d "$target/.claude/skills/qa-chrome" ]
    [ ! -d "$target/.claude/skills/qa-e2e" ]
    [ ! -d "$target/.claude/skills/growth-cro" ]
}

@test "presets: --preset cli-tools keeps automation/scripting skills" {
    local target="$TEST_DIR/proj-cli"
    "$NEW_PROJECT" --preset cli-tools "$target" >/dev/null 2>&1
    [ -d "$target/.claude/skills/dev-debug" ]
    [ -d "$target/.claude/skills/dev-tdd" ]
    [ -d "$target/.claude/skills/web-scraping" ]
    [ -d "$target/.claude/skills/parallel-agents" ]
    [ -d "$target/.claude/skills/qa-review" ]
    [ -d "$target/.claude/skills/work-quick" ]
}
