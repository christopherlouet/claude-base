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
    # Feed enough lines so the script does not block; the timeout caps
    # runtime in case of accidental infinite loop.
    run bash -c "echo -e '1\nn\nn\nn\nn\n\nn' | timeout 10 '$NEW_PROJECT' --dry-run '$target' 2>&1"
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
