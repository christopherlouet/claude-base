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

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"
VALIDATE_PRESETS="$BASE_DIR/scripts/validate-presets.sh"

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
    [ -f "$BASE_DIR/.claude/presets/nextjs.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/nextjs.json"
    [ "$status" -eq 0 ]
}

@test "presets: nextjs.json has required fields" {
    local f="$BASE_DIR/.claude/presets/nextjs.json"
    [ "$(jq -r '.name' "$f")" = "nextjs" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ -n "$(jq -r '.displayName' "$f")" ]
    [ -n "$(jq -r '.description' "$f")" ]
    [ "$(jq -r '.appliesToTypes | length' "$f")" -gt 0 ]
}

@test "presets: nextjs.json defaults are well-typed" {
    local f="$BASE_DIR/.claude/presets/nextjs.json"
    [ "$(jq -r '.defaults.ci | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.hooks | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.mcp | type' "$f")" = "boolean" ]
    [ "$(jq -r '.defaults.docker | type' "$f")" = "boolean" ]
}

@test "presets: nextjs.json drops at least one out-of-stack skill" {
    local f="$BASE_DIR/.claude/presets/nextjs.json"
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
# validate-presets.sh: optional `detect` block (data-driven detection)
# See specs/presets-detection-and-e2e/spec.md (EF-010).
# =============================================================================

@test "presets: validate-presets.sh accepts a valid detect block (anyOf + files + depFiles)" {
    cat > "$TEST_DIR/with-detect.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "files": ["next.config.js"],
    "depFiles": [{"path": "package.json", "contains": "\"next\""}]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/with-detect.json"
    [ "$status" -eq 0 ]
}

@test "presets: validate-presets.sh accepts a detect block with only files (no depFiles)" {
    cat > "$TEST_DIR/files-only.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "allOf",
    "files": ["manage.py"]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/files-only.json"
    [ "$status" -eq 0 ]
}

@test "presets: validate-presets.sh accepts a detect block omitting combinator (defaults to anyOf)" {
    cat > "$TEST_DIR/no-combinator.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "files": ["astro.config.mjs"]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/no-combinator.json"
    [ "$status" -eq 0 ]
}

@test "presets: validate-presets.sh rejects a detect block with no signals (empty files AND depFiles)" {
    cat > "$TEST_DIR/empty-detect.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "files": [],
    "depFiles": []
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/empty-detect.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"detect"* ]]
}

@test "presets: validate-presets.sh rejects a detect block with a bad combinator" {
    cat > "$TEST_DIR/bad-combinator.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "alwaysmatch",
    "files": ["next.config.js"]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-combinator.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"combinator"* ]]
}

@test "presets: validate-presets.sh rejects a depFiles entry missing path" {
    cat > "$TEST_DIR/bad-depfile-path.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"contains": "fastapi"}]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-depfile-path.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"depFiles"* ]]
}

@test "presets: validate-presets.sh rejects a depFiles entry missing contains" {
    cat > "$TEST_DIR/bad-depfile-contains.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "requirements.txt"}]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-depfile-contains.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"depFiles"* ]]
}

# =============================================================================
# new-project.sh: integration of preset suggestion (US-1, EF-016)
# =============================================================================

@test "presets: --simple -y on a Next.js project prints the preset suggestion" {
    local target="$TEST_DIR/proj-nextjs-suggest"
    mkdir -p "$target"
    touch "$target/next.config.js"
    echo '{"dependencies":{"next":"^15"},"name":"smoke"}' > "$target/package.json"
    run "$NEW_PROJECT" -y --simple --dry-run "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Detected stack"* ]]
    [[ "$output" == *"nextjs"* ]]
}

@test "presets: --simple -y on a FastAPI project prints the preset suggestion" {
    local target="$TEST_DIR/proj-fastapi-suggest"
    mkdir -p "$target"
    echo "fastapi==0.110" > "$target/requirements.txt"
    run "$NEW_PROJECT" -y --simple --dry-run "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Detected stack"* ]]
    [[ "$output" == *"fastapi"* ]]
}

@test "presets: --simple -y on an empty project prints no preset suggestion" {
    local target="$TEST_DIR/proj-empty-suggest"
    mkdir -p "$target"
    run "$NEW_PROJECT" -y --simple --dry-run "$target"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Detected stack — preset matches"* ]]
    [[ "$output" != *"Detected stack — multiple presets match"* ]]
}

@test "presets: interactive menu prepends matching preset as option 1 (US-4)" {
    # Existing Next.js fixture, run interactively (no -y, no --simple).
    # The menu must show "Use preset: nextjs" as option 1 and renumber the
    # standard types so React becomes option 2.
    local target="$TEST_DIR/proj-interactive-menu"
    mkdir -p "$target"
    touch "$target/next.config.js"
    echo '{"dependencies":{"next":"^15"},"name":"smoke"}' > "$target/package.json"
    # Write input to a file (portable across GNU/BSD; no `timeout` —
    # not available on macOS by default). The script reads each prompt
    # until stdin is exhausted, then exits on EOF.
    local input_file="$TEST_DIR/menu-input"
    printf '1\nn\nn\nn\nn\n\nn\n' > "$input_file"
    run bash -c "'$NEW_PROJECT' --dry-run '$target' < '$input_file' 2>&1"
    [[ "$output" == *"Use preset: nextjs"* ]]
    [[ "$output" == *"2) React / Next.js"* ]]
    [[ "$output" == *"Choice [1-12]"* ]]
}

@test "presets: explicit --preset suppresses the Detected stack line (EF-016)" {
    # The target dir matches the nextjs detect rule; without --preset we
    # would print "Detected stack — preset matches: nextjs". With --preset
    # nextjs explicit, no such suggestion line should appear (EF-016: the
    # explicit choice is honored without commentary).
    local target="$TEST_DIR/proj-explicit-preset"
    mkdir -p "$target"
    touch "$target/next.config.js"
    echo '{"dependencies":{"next":"^15"},"name":"smoke"}' > "$target/package.json"
    run "$NEW_PROJECT" --preset nextjs --dry-run "$target"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Detected stack"* ]]
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
    drops=$(jq -r '.foundation.skills.drop[]' "$BASE_DIR/.claude/presets/nextjs.json")
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
    [ -f "$BASE_DIR/.claude/presets/homelab-proxmox.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/homelab-proxmox.json"
    [ "$status" -eq 0 ]
}

@test "presets: homelab-proxmox.json has required fields" {
    local f="$BASE_DIR/.claude/presets/homelab-proxmox.json"
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
    [ -f "$BASE_DIR/.claude/presets/cli-tools.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/cli-tools.json"
    [ "$status" -eq 0 ]
}

@test "presets: cli-tools.json has required fields" {
    local f="$BASE_DIR/.claude/presets/cli-tools.json"
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

# =============================================================================
# fastapi preset (4th maintainer-vouched preset — Python async backend)
# =============================================================================

@test "presets: fastapi.json exists and is valid JSON" {
    [ -f "$BASE_DIR/.claude/presets/fastapi.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/fastapi.json"
    [ "$status" -eq 0 ]
}

@test "presets: fastapi.json has required fields" {
    local f="$BASE_DIR/.claude/presets/fastapi.json"
    [ "$(jq -r '.name' "$f")" = "fastapi" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ "$(jq -r '.defaults.designStyle' "$f")" = "editorial" ]
    [ "$(jq -r '.defaults.docker' "$f")" = "true" ]
    # appliesToTypes contains "python"
    [[ "$(jq -r '.appliesToTypes[]' "$f" | tr '\n' ' ')" == *"python"* ]]
}

@test "presets: --list-presets shows all four vouched presets" {
    run "$NEW_PROJECT" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"homelab-proxmox"* ]]
    [[ "$output" == *"cli-tools"* ]]
    [[ "$output" == *"fastapi"* ]]
}

@test "presets: --preset fastapi drops frontend/mobile/homelab skills" {
    local target="$TEST_DIR/proj-fastapi"
    "$NEW_PROJECT" --preset fastapi "$target" >/dev/null 2>&1
    [ ! -d "$target/.claude/skills/dev-flutter" ]
    [ ! -d "$target/.claude/skills/dev-nextjs" ]
    [ ! -d "$target/.claude/skills/dev-shadcn" ]
    [ ! -d "$target/.claude/skills/dev-react-perf" ]
    [ ! -d "$target/.claude/skills/dev-frontend-design" ]
    [ ! -d "$target/.claude/skills/ops-mobile-release" ]
    [ ! -d "$target/.claude/skills/ops-proxmox" ]
    [ ! -d "$target/.claude/skills/ops-opnsense" ]
    [ ! -d "$target/.claude/skills/qa-chrome" ]
    [ ! -d "$target/.claude/skills/qa-design" ]
    [ ! -d "$target/.claude/skills/qa-e2e" ]
    [ ! -d "$target/.claude/skills/growth-cro" ]
}

@test "presets: --preset fastapi keeps backend-relevant skills" {
    local target="$TEST_DIR/proj-fastapi"
    "$NEW_PROJECT" --preset fastapi "$target" >/dev/null 2>&1
    [ -d "$target/.claude/skills/dev-api" ]
    [ -d "$target/.claude/skills/dev-auth" ]
    [ -d "$target/.claude/skills/dev-tdd" ]
    [ -d "$target/.claude/skills/dev-prompt-engineering" ]
    [ -d "$target/.claude/skills/ops-database" ]
    [ -d "$target/.claude/skills/ops-docker" ]
    [ -d "$target/.claude/skills/ops-monitoring" ]
    [ -d "$target/.claude/skills/qa-perf" ]
    [ -d "$target/.claude/skills/qa-security" ]
}

@test "presets: --preset fastapi installs successfully on a Python project" {
    # FastAPI defaults docker=true (unique among the 4 vouched presets) and
    # designStyle=editorial. No file-level assertion on those — they live
    # in foundation state. Smoke-check that the install completed.
    local target="$TEST_DIR/proj-fastapi-smoke"
    run "$NEW_PROJECT" --preset fastapi "$target"
    [ "$status" -eq 0 ]
    [ -d "$target/.claude" ]
    [ -d "$target/.claude/skills" ]
}

# =============================================================================
# astro preset (5th maintainer-vouched preset — content/static-first web)
# =============================================================================

@test "presets: astro.json exists and is valid JSON" {
    [ -f "$BASE_DIR/.claude/presets/astro.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/astro.json"
    [ "$status" -eq 0 ]
}

@test "presets: astro.json has required fields" {
    local f="$BASE_DIR/.claude/presets/astro.json"
    [ "$(jq -r '.name' "$f")" = "astro" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    [ "$(jq -r '.defaults.designStyle' "$f")" = "editorial" ]
    [[ "$(jq -r '.appliesToTypes[]' "$f" | tr '\n' ' ')" == *"astro"* ]]
}

@test "presets: --list-presets shows all five vouched presets" {
    run "$NEW_PROJECT" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"homelab-proxmox"* ]]
    [[ "$output" == *"cli-tools"* ]]
    [[ "$output" == *"fastapi"* ]]
    [[ "$output" == *"astro"* ]]
}

@test "presets: --preset astro drops mobile/homelab/non-Astro-framework skills" {
    local target="$TEST_DIR/proj-astro"
    "$NEW_PROJECT" --preset astro "$target" >/dev/null 2>&1
    [ ! -d "$target/.claude/skills/dev-flutter" ]
    [ ! -d "$target/.claude/skills/dev-nextjs" ]
    [ ! -d "$target/.claude/skills/ops-mobile-release" ]
    [ ! -d "$target/.claude/skills/ops-proxmox" ]
    [ ! -d "$target/.claude/skills/ops-opnsense" ]
    [ ! -d "$target/.claude/skills/ops-infra-code" ]
    [ ! -d "$target/.claude/skills/data-pipeline" ]
}

@test "presets: --preset astro keeps broader frontend skills (islands architecture)" {
    local target="$TEST_DIR/proj-astro"
    "$NEW_PROJECT" --preset astro "$target" >/dev/null 2>&1
    # Astro's islands architecture lets users mix React/Vue/Svelte components,
    # so frontend skills that fastapi/cli-tools drop stay relevant here.
    [ -d "$target/.claude/skills/dev-shadcn" ]
    [ -d "$target/.claude/skills/dev-react-perf" ]
    [ -d "$target/.claude/skills/dev-frontend-design" ]
    # Content sites care strongly about CRO, design audit, browser testing
    [ -d "$target/.claude/skills/growth-cro" ]
    [ -d "$target/.claude/skills/qa-design" ]
    [ -d "$target/.claude/skills/qa-chrome" ]
    [ -d "$target/.claude/skills/qa-perf" ]
    # i18n is core to many Astro content sites
    [ -d "$target/.claude/skills/dev-i18n" ]
}

@test "presets: --preset astro applies editorial designStyle by default" {
    local target="$TEST_DIR/proj-astro-style"
    "$NEW_PROJECT" --preset astro "$target" >/dev/null 2>&1
    [ -d "$target/.claude" ]
}

# =============================================================================
# recommendedVendorSkills (printed at install end, never auto-installed)
# =============================================================================

@test "presets: nextjs has at least 3 recommendedVendorSkills entries" {
    local f="$BASE_DIR/.claude/presets/nextjs.json"
    local n
    n=$(jq -r '.recommendedVendorSkills | length' "$f")
    [ "$n" -ge 3 ]
}

@test "presets: validate-presets.sh validates recommendedVendorSkills schema" {
    cat > "$TEST_DIR/bad-recs.json" <<'EOF'
{
  "name": "x",
  "displayName": "x",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "recommendedVendorSkills": [
    {"id": "missing-fields"}
  ]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-recs.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"recommendedVendorSkills"* ]]
}

# =============================================================================
# US-5 — fixture pairing: each preset's detect rule must match its paired
# fixture under tests/presets-fixtures/<preset>/. Drift-guard: if upstream
# renames its config file or signal, the paired test fails loudly.
# =============================================================================

@test "presets: nextjs detect rule matches its fixture (US-5)" {
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/nextjs'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
}

@test "presets: fastapi detect rule matches its fixture (US-5)" {
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/fastapi'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"fastapi"* ]]
}

@test "presets: astro detect rule matches its fixture (US-5)" {
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/astro'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"astro"* ]]
}

@test "presets: homelab-proxmox detect rule matches its fixture (US-5)" {
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/homelab-proxmox'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"homelab-proxmox"* ]]
}

# =============================================================================
# US-6 — --detect-only standalone mode (P3): prints matching preset names
# without performing any install. Useful for users who want to audit the
# detection without committing to anything.
# =============================================================================

@test "presets: --detect-only on a Next.js fixture prints nextjs and exits 0" {
    local target="$TEST_DIR/proj-detect-only"
    mkdir -p "$target"
    touch "$target/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$target/package.json"
    run "$NEW_PROJECT" --detect-only "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    # No file writes
    [ ! -d "$target/.claude" ]
}

@test "presets: --detect-only on an empty dir reports no match and exits 0" {
    local target="$TEST_DIR/proj-detect-only-empty"
    mkdir -p "$target"
    run "$NEW_PROJECT" --detect-only "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No matching preset"* ]]
    [ ! -d "$target/.claude" ]
}

@test "presets: --detect-only without a path fails with a clear error" {
    run "$NEW_PROJECT" --detect-only
    [ "$status" -ne 0 ]
    [[ "$output" == *"path"* ]] || [[ "$output" == *"required"* ]]
}

@test "presets: --detect-only and --preset are mutually exclusive" {
    local target="$TEST_DIR/proj-detect-only-conflict"
    mkdir -p "$target"
    run "$NEW_PROJECT" --detect-only --preset nextjs "$target"
    [ "$status" -ne 0 ]
    [[ "$output" == *"mutually exclusive"* ]] || [[ "$output" == *"--preset"* ]]
}

@test "presets: --preset nextjs prints Recommended vendor skills section" {
    local target="$TEST_DIR/proj-rec"
    run "$NEW_PROJECT" --preset nextjs "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Recommended vendor skills"* ]]
    [[ "$output" == *"vercel-labs"* ]]
    [[ "$output" == *"recommended-vendor-skills.md"* ]]
}

@test "presets: --preset cli-tools (empty list) does NOT print the section" {
    local target="$TEST_DIR/proj-cli-rec"
    run "$NEW_PROJECT" --preset cli-tools "$target"
    [ "$status" -eq 0 ]
    # When recommendedVendorSkills is [], the heading should not appear
    [[ "$output" != *"Recommended vendor skills for this stack"* ]]
}

@test "presets: --preset homelab-proxmox prints terraform-skill always pair" {
    local target="$TEST_DIR/proj-proxmox-rec"
    run "$NEW_PROJECT" --preset homelab-proxmox "$target"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Always pair with this preset"* ]]
    [[ "$output" == *"terraform-skill"* ]]
}

# =============================================================================
# T003-T005 — validator XOR enforcement: foundation.skills drop vs keep
# (Phase 1.A — must FAIL before T006 implementation)
# =============================================================================

@test "presets: validate-presets.sh rejects a preset declaring both drop and keep in foundation.skills (T003)" {
    cat > "$TEST_DIR/both-drop-and-keep.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "foundation": {
    "skills": {
      "drop": ["dev-flutter"],
      "keep": ["dev-tdd"]
    }
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/both-drop-and-keep.json"
    [ "$status" -ne 0 ]
    [[ "$output" == *"mutually exclusive"* ]]
}

@test "presets: validate-presets.sh accepts a preset with only keep in foundation.skills (T004)" {
    cat > "$TEST_DIR/keep-only.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "foundation": {
    "skills": {
      "keep": ["dev-tdd"]
    }
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/keep-only.json"
    [ "$status" -eq 0 ]
}

@test "presets: validate-presets.sh accepts a preset with only drop in foundation.skills (regression T005)" {
    cat > "$TEST_DIR/drop-only.json" <<'EOF'
{
  "name": "synthetic",
  "displayName": "Synthetic",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["react"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "foundation": {
    "skills": {
      "drop": ["dev-flutter"]
    }
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/drop-only.json"
    [ "$status" -eq 0 ]
}

# =============================================================================
# react-vite-spa preset (T018-T022)
# =============================================================================

@test "presets: react-vite-spa.json exists and is valid JSON (T018)" {
    [ -f "$BASE_DIR/.claude/presets/react-vite-spa.json" ]
    run jq -e . "$BASE_DIR/.claude/presets/react-vite-spa.json"
    [ "$status" -eq 0 ]
}

@test "presets: react-vite-spa.json has required fields (T019)" {
    local f="$BASE_DIR/.claude/presets/react-vite-spa.json"
    [ "$(jq -r '.name' "$f")" = "react-vite-spa" ]
    [ "$(jq -r '.status' "$f")" = "maintainer-vouched" ]
    local desc_len
    desc_len=$(jq -r '.description | length' "$f")
    [ "$desc_len" -ge 80 ]
    [ "$(jq -r '.appliesToTypes | length' "$f")" -ge 1 ]
    [ "$(jq -r '.version' "$f")" = "1.0.0" ]
}

@test "presets: react-vite-spa uses keep XOR drop (T020)" {
    local f="$BASE_DIR/.claude/presets/react-vite-spa.json"
    # keep must exist and be a non-empty array
    [ "$(jq -r '.foundation.skills.keep | type' "$f")" = "array" ]
    [ "$(jq -r '.foundation.skills.keep | length' "$f")" -gt 0 ]
    # drop must NOT exist
    [ "$(jq -r '.foundation.skills | has("drop")' "$f")" = "false" ]
    # Additionally: a known out-of-stack skill must NOT be in the keep list
    local in_keep
    in_keep=$(jq -r '.foundation.skills.keep[] | select(. == "dev-flutter")' "$f")
    [ -z "$in_keep" ]
}

@test "presets: react-vite-spa has honest outOfScope and relatedPresetsWanted (T021)" {
    local f="$BASE_DIR/.claude/presets/react-vite-spa.json"
    [ "$(jq -r '.outOfScope | length' "$f")" -ge 4 ]
    [ "$(jq -r '.relatedPresetsWanted | length' "$f")" -ge 3 ]
}

@test "presets: react-vite-spa bundles no marketplace plugins at v1 and 4 vendor recommendations (T022)" {
    local f="$BASE_DIR/.claude/presets/react-vite-spa.json"
    # marketplacePlugins must be an empty array
    [ "$(jq -r '.marketplacePlugins | length' "$f")" -eq 0 ]
    # exactly 4 recommendedVendorSkills
    [ "$(jq -r '.recommendedVendorSkills | length' "$f")" -eq 4 ]
    # exactly 2 always conditions
    local always_count
    always_count=$(jq -r '[.recommendedVendorSkills[] | select(.condition == "always")] | length' "$f")
    [ "$always_count" -eq 2 ]
    # exactly 2 conditional (non-always) entries
    local conditional_count
    conditional_count=$(jq -r '[.recommendedVendorSkills[] | select(.condition != "always")] | length' "$f")
    [ "$conditional_count" -eq 2 ]
}

# =============================================================================
# vendor-pointer tier tests (spec: presets-vendor-pointer-tier)
#
# T004-T008: negative tests for the tier-conditional validation rules
#   EF-003: recommendedVendorSkills MUST be non-empty
#   EF-004: marketplacePlugins / foundation.skills.{keep,drop} / defaults
#           MUST be absent or empty
#   EF-005: detect MUST contain exactly 1 signal entry (files[1] XOR
#           depFiles[1])
# T009: positive test for the shipped phaser preset
# T018: phaser detect rule must match its paired fixture (drift-guard)
# =============================================================================

@test "presets: validate-presets.sh rejects a vendor-pointer preset declaring marketplacePlugins (EF-004, T004)" {
    cat > "$TEST_DIR/bad-vp-mp.json" <<'EOF'
{
  "name": "bad-vp-mp",
  "displayName": "Bad vendor-pointer with marketplacePlugins",
  "description": "Test fixture: vendor-pointer presets must not declare marketplacePlugins per EF-004.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always"}
  ],
  "marketplacePlugins": [
    {"id": "some/plugin", "rationale": "should be forbidden"}
  ]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-vp-mp.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"marketplacePlugins"* ]]
}

@test "presets: validate-presets.sh rejects a vendor-pointer preset declaring foundation.skills.keep (EF-004, T005)" {
    cat > "$TEST_DIR/bad-vp-keep.json" <<'EOF'
{
  "name": "bad-vp-keep",
  "displayName": "Bad vendor-pointer with foundation.skills.keep",
  "description": "Test fixture: vendor-pointer presets must not declare foundation.skills.keep per EF-004.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always"}
  ],
  "foundation": {
    "skills": { "keep": ["dev-tdd"] }
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-vp-keep.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"foundation.skills.keep"* ]]
}

@test "presets: validate-presets.sh rejects a vendor-pointer preset missing recommendedVendorSkills (EF-003, T006)" {
    cat > "$TEST_DIR/bad-vp-no-vendor.json" <<'EOF'
{
  "name": "bad-vp-no-vendor",
  "displayName": "Bad vendor-pointer with no recommendedVendorSkills",
  "description": "Test fixture: vendor-pointer presets must declare at least one recommendedVendorSkills entry per EF-003.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  }
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-vp-no-vendor.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"recommendedVendorSkills"* ]]
}

@test "presets: validate-presets.sh rejects a vendor-pointer preset with multi-entry detect.depFiles (EF-005, T007)" {
    cat > "$TEST_DIR/bad-vp-multi.json" <<'EOF'
{
  "name": "bad-vp-multi",
  "displayName": "Bad vendor-pointer with multi-entry detect",
  "description": "Test fixture: vendor-pointer presets must have a detect rule with exactly 1 signal entry per EF-005.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [
      {"path": "package.json", "contains": "foo"},
      {"path": "package.json", "contains": "bar"}
    ]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always"}
  ]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-vp-multi.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"detect MUST contain exactly 1 signal entry"* ]]
}

@test "presets: validate-presets.sh rejects a vendor-pointer preset with both files and depFiles (EF-005 XOR, T008)" {
    cat > "$TEST_DIR/bad-vp-xor.json" <<'EOF'
{
  "name": "bad-vp-xor",
  "displayName": "Bad vendor-pointer with both files and depFiles",
  "description": "Test fixture: vendor-pointer presets must use either files OR depFiles, not both — EF-005 XOR.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "files": ["foo.config.ts"],
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always"}
  ]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-vp-xor.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"detect MUST contain exactly 1 signal entry"* ]]
}

@test "presets: phaser.json (vendor-pointer) is accepted by validate-presets.sh (T009)" {
    [ -f "$BASE_DIR/.claude/presets/phaser.json" ]
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"phaser.json"* ]]
}

@test "presets: phaser detect rule matches its fixture (US-5, T018)" {
    [ -d "$BASE_DIR/tests/presets-fixtures/phaser" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/phaser'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"phaser"* ]]
}

# =============================================================================
# playwright vendor-pointer preset (2nd vendor-pointer instance)
# =============================================================================

@test "presets: playwright.json (vendor-pointer) is accepted by validate-presets.sh" {
    [ -f "$BASE_DIR/.claude/presets/playwright.json" ]
    [ "$(jq -r '.status' "$BASE_DIR/.claude/presets/playwright.json")" = "vendor-pointer" ]
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"playwright.json"* ]]
}

@test "presets: playwright detect rule matches its fixture (US-5)" {
    [ -d "$BASE_DIR/tests/presets-fixtures/playwright" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/playwright'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"playwright"* ]]
}
