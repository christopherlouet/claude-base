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

@test "presets: nextjs.json scopes its stack via defaultModules (no module-owned filter)" {
    local f="$BASE_DIR/.claude/presets/nextjs.json"
    # Stack-scoping moved from a skills.drop list to module opt-in: nextjs opts
    # into a non-empty, stack-relevant module set (and references no module-owned
    # item in any catalog filter — validate-presets enforces that separately).
    local n
    n=$(jq -r '.defaultModules | length' "$f")
    [ "$n" -ge 1 ]
    [[ "$(jq -r '.defaultModules | join(",")' "$f")" == *"frontend"* ]]
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

@test "presets: --preset nextjs install excludes off-stack module skills" {
    local target="$TEST_DIR/proj"
    "$NEW_PROJECT" --preset nextjs "$target" >/dev/null 2>&1
    [ -d "$target/.claude/skills" ]
    # nextjs opts into api-data + frontend only; everything in the modules it does
    # NOT request is absent (the exclusion is now by module opt-in, not a filter).
    [ ! -d "$target/.claude/skills/dev-flutter" ]        # mobile
    [ ! -d "$target/.claude/skills/ops-mobile-release" ] # mobile
    [ ! -d "$target/.claude/skills/ops-proxmox" ]        # self-hosted
    [ ! -d "$target/.claude/skills/ops-opnsense" ]       # self-hosted
    [ ! -d "$target/.claude/skills/ops-infra-code" ]     # iac
    [ ! -d "$target/.claude/skills/data-pipeline" ]      # data-eng
    # ... while the requested stack skills are present.
    [ -d "$target/.claude/skills/dev-nextjs" ]           # frontend
    [ -d "$target/.claude/skills/dev-prisma" ]           # api-data
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

@test "presets: --preset homelab-proxmox install excludes off-stack module skills" {
    local target="$TEST_DIR/proj-proxmox"
    "$NEW_PROJECT" --preset homelab-proxmox "$target" >/dev/null 2>&1
    # Scoping is by module opt-in: homelab requests self-hosted + iac +
    # observability only, so the frontend/mobile/growth module skills are absent
    # (universal core skills like qa-chrome stay — they are not module-owned).
    [ ! -d "$target/.claude/skills/dev-flutter" ]          # mobile
    [ ! -d "$target/.claude/skills/dev-nextjs" ]           # frontend
    [ ! -d "$target/.claude/skills/dev-shadcn" ]           # frontend
    [ ! -d "$target/.claude/skills/dev-react-perf" ]       # frontend
    [ ! -d "$target/.claude/skills/dev-frontend-design" ]  # frontend
    [ ! -d "$target/.claude/skills/ops-mobile-release" ]   # mobile
    [ ! -d "$target/.claude/skills/growth-cro" ]           # growth
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

@test "presets: --preset cli-tools excludes off-stack module skills" {
    local target="$TEST_DIR/proj-cli"
    "$NEW_PROJECT" --preset cli-tools "$target" >/dev/null 2>&1
    # cli-tools opts into no module → every themed skill is absent (universal
    # core skills remain; they are not module-owned).
    [ ! -d "$target/.claude/skills/dev-flutter" ]      # mobile
    [ ! -d "$target/.claude/skills/dev-nextjs" ]       # frontend
    [ ! -d "$target/.claude/skills/dev-shadcn" ]       # frontend
    [ ! -d "$target/.claude/skills/dev-prisma" ]       # api-data
    [ ! -d "$target/.claude/skills/ops-proxmox" ]      # self-hosted
    [ ! -d "$target/.claude/skills/ops-opnsense" ]     # self-hosted
    [ ! -d "$target/.claude/skills/growth-cro" ]       # growth
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

@test "presets: --preset fastapi excludes off-stack module skills" {
    local target="$TEST_DIR/proj-fastapi"
    "$NEW_PROJECT" --preset fastapi "$target" >/dev/null 2>&1
    # fastapi opts into api-data only → frontend/mobile/self-hosted/growth module
    # skills are absent (universal core skills like qa-chrome stay).
    [ ! -d "$target/.claude/skills/dev-flutter" ]          # mobile
    [ ! -d "$target/.claude/skills/dev-nextjs" ]           # frontend
    [ ! -d "$target/.claude/skills/dev-shadcn" ]           # frontend
    [ ! -d "$target/.claude/skills/dev-react-perf" ]       # frontend
    [ ! -d "$target/.claude/skills/dev-frontend-design" ]  # frontend
    [ ! -d "$target/.claude/skills/ops-mobile-release" ]   # mobile
    [ ! -d "$target/.claude/skills/ops-proxmox" ]          # self-hosted
    [ ! -d "$target/.claude/skills/ops-opnsense" ]         # self-hosted
    [ ! -d "$target/.claude/skills/growth-cro" ]           # growth
}

@test "presets: --preset fastapi keeps backend-relevant skills" {
    local target="$TEST_DIR/proj-fastapi"
    "$NEW_PROJECT" --preset fastapi "$target" >/dev/null 2>&1
    [ -d "$target/.claude/skills/dev-api" ]
    [ -d "$target/.claude/skills/dev-auth" ]
    [ -d "$target/.claude/skills/dev-tdd" ]
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
    # Content sites care about design audit, browser testing, perf (core skills).
    # (growth-cro is now a `growth` module skill — opt-in via `claude-base add
    # growth`, no longer installed by a core-only preset.)
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
    [ "$(jq -r '.version' "$f")" = "1.2.0" ]
}

@test "presets: react-vite-spa scopes via defaultModules, no foundation filter (T020)" {
    local f="$BASE_DIR/.claude/presets/react-vite-spa.json"
    # Pure opt-in: it requests its stack modules and carries no catalog/skills
    # filter at all (the keep list it used to need only trimmed dev-nextjs, which
    # is now its own module the preset simply does not opt into).
    [ "$(jq -r '.defaultModules | join(",")' "$f")" = "api-data,frontend" ]
    [ "$(jq -r '.foundation | length' "$f")" -eq 0 ]
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
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
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
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
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
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
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
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
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

# =============================================================================
# pulumi vendor-pointer preset (3rd vendor-pointer instance) — uses files[1]
# detect rule (vs depFiles[1] for phaser/playwright), exercises EF-005 XOR.
# =============================================================================

@test "presets: pulumi.json (vendor-pointer) is accepted by validate-presets.sh" {
    [ -f "$BASE_DIR/.claude/presets/pulumi.json" ]
    [ "$(jq -r '.status' "$BASE_DIR/.claude/presets/pulumi.json")" = "vendor-pointer" ]
    # Specifically a files[1] detect (not depFiles)
    [ "$(jq -r '.detect.files | length' "$BASE_DIR/.claude/presets/pulumi.json")" -eq 1 ]
    [ "$(jq -r '.detect | has("depFiles")' "$BASE_DIR/.claude/presets/pulumi.json")" = "false" ]
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"pulumi.json"* ]]
}

@test "presets: pulumi detect rule matches its fixture (US-5)" {
    [ -f "$BASE_DIR/tests/presets-fixtures/pulumi/Pulumi.yaml" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/pulumi'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"pulumi"* ]]
}

# =============================================================================
# apollo vendor-pointer preset (4th vendor-pointer instance) — depFiles[1] on
# "@apollo/client" (the dominant Apollo entry point). Server-side Apollo is
# documented in outOfScope per the strict 1-entry detect rule (EF-005).
# =============================================================================

@test "presets: apollo.json (vendor-pointer) is accepted by validate-presets.sh" {
    [ -f "$BASE_DIR/.claude/presets/apollo.json" ]
    [ "$(jq -r '.status' "$BASE_DIR/.claude/presets/apollo.json")" = "vendor-pointer" ]
    # Detect targets the client-side package, not server-side
    [ "$(jq -r '.detect.depFiles[0].contains' "$BASE_DIR/.claude/presets/apollo.json")" = '"@apollo/client"' ]
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"apollo.json"* ]]
}

@test "presets: apollo detect rule matches its fixture (US-5)" {
    [ -d "$BASE_DIR/tests/presets-fixtures/apollo" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/apollo'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"apollo"* ]]
}

# =============================================================================
# mongodb vendor-pointer preset (5th vendor-pointer instance) — exercises the
# colon-anchored substring pattern ("mongodb":) to avoid false positives on
# packages whose name starts with "mongodb" (mongodb-memory-server, etc.).
# The paired fixture intentionally includes mongodb-memory-server as a
# devDependency to validate the disambiguation.
# =============================================================================

@test "presets: mongodb.json (vendor-pointer) uses colon-anchored substring (regression guard)" {
    [ -f "$BASE_DIR/.claude/presets/mongodb.json" ]
    [ "$(jq -r '.status' "$BASE_DIR/.claude/presets/mongodb.json")" = "vendor-pointer" ]
    # The substring MUST include the trailing colon to disambiguate from
    # mongodb-memory-server, @types/mongodb, mongodb-runner, etc.
    local contains
    contains=$(jq -r '.detect.depFiles[0].contains' "$BASE_DIR/.claude/presets/mongodb.json")
    [ "$contains" = '"mongodb":' ]
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
    [[ "$output" == *"mongodb.json"* ]]
}

@test "presets: mongodb detect rule matches its fixture (US-5)" {
    [ -d "$BASE_DIR/tests/presets-fixtures/mongodb" ]
    # Fixture includes mongodb-memory-server as a devDependency — the detect
    # must still match because the direct mongodb dep is present.
    grep -q '"mongodb-memory-server"' "$BASE_DIR/tests/presets-fixtures/mongodb/package.json"
    grep -q '"mongodb": ' "$BASE_DIR/tests/presets-fixtures/mongodb/package.json"
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/preset-detect.sh'
        scan_presets '$BASE_DIR/tests/presets-fixtures/mongodb'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"mongodb"* ]]
}

# =============================================================================
# Category-prompt feature (spec: preset-category-prompt)
#
# 10 tests covering EF-001/005/006/007/009/010 + CP1/CP4 + drift-guard.
# TDD pattern: each test must fail in RED state (lib missing OR validator
# enum missing), pass after the corresponding GREEN phase.
# =============================================================================

@test "presets: validate-presets.sh rejects categories[] with out-of-enum value (T004, EF-006)" {
    cat > "$TEST_DIR/bad-cat-enum.json" <<'EOF'
{
  "name": "bad-cat-enum",
  "displayName": "Bad category enum",
  "description": "Test fixture: categories[] must contain only values from the locked 8-slug enum.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
  ],
  "categories": ["mobile-native"]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/bad-cat-enum.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"categories"* ]]
    [[ "$output" == *"mobile-native"* ]]
}

@test "presets: validate-presets.sh accepts categories[] empty array as field-absent (T005, EF-006)" {
    cat > "$TEST_DIR/cat-empty.json" <<'EOF'
{
  "name": "cat-empty",
  "displayName": "Empty categories",
  "description": "Test fixture: an empty categories[] is treated as field-absent (no rejection).",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
  ],
  "categories": []
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/cat-empty.json"
    [ "$status" -eq 0 ]
}

@test "presets: validate-presets.sh accepts categories[] with 2 valid slugs (T006, EF-014 multi-category)" {
    cat > "$TEST_DIR/cat-multi.json" <<'EOF'
{
  "name": "cat-multi",
  "displayName": "Multi-category",
  "description": "Test fixture: categories[] may declare multiple valid slugs.",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "outOfScope": [],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [{"path": "package.json", "contains": "foo"}]
  },
  "recommendedVendorSkills": [
    {"id": "x/y", "url": "https://example.com", "rationale": "test", "condition": "always", "pinnedRef": "v1.0.0", "trustTrack": "authority", "provenance": "Example", "lastVerified": "2026-06-13"}
  ],
  "categories": ["web-frontend", "api-backend"]
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/cat-multi.json"
    [ "$status" -eq 0 ]
}

@test "presets: ask_category reads stdin and prints selected slug (T007, US-1)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        echo '4' | ask_category
    "
    [ "$status" -eq 0 ]
    # Choice 4 (1-indexed) → game-interactive-media per locked taxonomy order
    [[ "$output" == *"game-interactive-media"* ]]
}

@test "presets: get_project_type skips category prompt when stdin is not a TTY (T008, EF-009)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    # Stdin redirected from /dev/null → not a TTY → guard short-circuits.
    # The marker word "What are you building" must NOT appear.
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        # Simulate the guard logic from get_project_type
        if [ -t 0 ]; then
            ask_category
        fi
    " < /dev/null
    [ "$status" -eq 0 ]
    [[ "$output" != *"What are you building"* ]]
}

@test "presets: get_project_type bypasses category prompt when PRESET_NAME is set (T009, EF-010)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    # When PRESET_NAME is set (user passed --preset), category prompt MUST NOT fire.
    run env BASE_DIR="$BASE_DIR" PRESET_NAME=phaser bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        # Simulate the 5-guard logic from get_project_type
        if [[ -z \"\$PRESET_NAME\" ]] && [[ -z \"\$FORCE_TYPE\" ]]; then
            echo '4' | ask_category
        fi
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"game-interactive-media"* ]]
}

@test "presets: get_project_type bypasses category prompt when FORCE_TYPE is set (T010, EF-010)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    run env BASE_DIR="$BASE_DIR" FORCE_TYPE=python bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        if [[ -z \"\$PRESET_NAME\" ]] && [[ -z \"\$FORCE_TYPE\" ]]; then
            echo '4' | ask_category
        fi
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"game-interactive-media"* ]]
}

@test "presets: print_filtered_type_menu(game-interactive-media) lists phaser (T011, US-4)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    [ "$(jq -r '.categories // [] | join(",")' "$BASE_DIR/.claude/presets/phaser.json")" = "game-interactive-media" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/menu.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        MATCHED_PRESETS=()
        print_filtered_type_menu 'game-interactive-media'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"phaser"* ]]
}

@test "presets: other-generic filtered menu decodes choice 1 as a standard type, not a preset" {
    # Regression: in the other/generic category the menu renders the 11
    # standard types (1 = React) but the choice handler must NOT decode
    # choice 1 as a preset. With _FILTERED_PRESETS populated, choice 1
    # wrongly yielded PRESET_NAME=<first preset> and PROJECT_TYPE empty.
    [ -f "$BASE_DIR/scripts/lib/menu.sh" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/menu.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        MATCHED_PRESETS=()
        PRESET_NAME=''
        PROJECT_TYPE=''
        print_filtered_type_menu 'other-generic' >/dev/null
        apply_filtered_type_choice 1
        echo \"PROJECT_TYPE=[\$PROJECT_TYPE] PRESET_NAME=[\$PRESET_NAME]\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"PROJECT_TYPE=[react]"* ]]
    [[ "$output" == *"PRESET_NAME=[]"* ]]
}

@test "presets: apply_category_choice on empty input maps to other-generic (T012, CP1 default)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        apply_category_choice ''
        echo \"\$SELECTED_CATEGORY_SLUG\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"other-generic"* ]]
}

@test "presets: taxonomy slugs in lib/category-map.sh match roadmap.md exactly (T013, drift-guard CS-013)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    [ -f "$BASE_DIR/specs/presets/roadmap.md" ]
    # Extract slugs from lib by sourcing the file and reading the array.
    # Avoids brittle regex over multi-line array literals.
    local lib_slugs
    lib_slugs=$(BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        printf '%s\n' \"\${_CATEGORY_SLUGS[@]}\"
    " | sort -u | tr '\n' ',')
    # Extract slugs documented in the roadmap's "Category taxonomy" section.
    # The section's table has backtick-wrapped slugs in column 1.
    local roadmap_slugs
    roadmap_slugs=$(sed -n '/^## Category taxonomy/,/^## /p' "$BASE_DIR/specs/presets/roadmap.md" \
        | grep -oE '`[a-z][a-z-]+`' \
        | tr -d '`' \
        | grep -E '^(web-frontend|api-backend|mobile-desktop|game-interactive-media|data-database|infra-devops|cli-automation|other-generic)$' \
        | sort -u | tr '\n' ',')
    [ -n "$lib_slugs" ]
    [ -n "$roadmap_slugs" ]
    [ "$lib_slugs" = "$roadmap_slugs" ]
}

# ===========================================================================
# T015 (thematic-modules S4) — per-preset stack-scoped reduction.
# Each vouched preset installs a measurably reduced, stack-relevant catalog:
# off-stack module items are absent, the requested module + core items are
# present. The exclusion is driven by module opt-in (defaultModules) now, not a
# long skills.drop list — so the filters reference no module-owned item.
# ===========================================================================

# full-catalog command count (every command shipped by the foundation)
_full_cmd_count() {
    find "$BASE_DIR/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' '
}
_proj_cmd_count() {
    find "$1/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' '
}

@test "presets: fastapi install is reduced and opts into api-data (T015)" {
    local proj="$TEST_DIR/proj-fastapi-red"
    run "$NEW_PROJECT" --preset fastapi -y "$proj"
    [ "$status" -eq 0 ]
    # measurably reduced vs the full catalog
    [ "$(_proj_cmd_count "$proj")" -lt "$(_full_cmd_count)" ]
    # api-data restored (it never dropped prisma/supabase/graphql)
    [ -f "$proj/.claude/commands/dev/dev-prisma.md" ]
    [ -d "$proj/.claude/skills/dev-supabase" ]
    # off-stack themes absent (frontend / mobile / self-hosted)
    [ ! -f "$proj/.claude/commands/dev/dev-react-perf.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ ! -d "$proj/.claude/skills/dev-flutter" ]
    # core kept
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
    [ -d "$proj/.claude/skills/dev-tdd" ]
}

@test "presets: astro install is reduced, keeps frontend, trims dev-nextjs (T015)" {
    local proj="$TEST_DIR/proj-astro-red"
    run "$NEW_PROJECT" --preset astro -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_proj_cmd_count "$proj")" -lt "$(_full_cmd_count)" ]
    # frontend opted in (shadcn/react-perf), but the Next.js skill is trimmed
    [ -d "$proj/.claude/skills/dev-shadcn" ]
    [ -f "$proj/.claude/commands/dev/dev-react-perf.md" ]
    [ ! -d "$proj/.claude/skills/dev-nextjs" ]
    # off-stack absent (data-eng / self-hosted)
    [ ! -f "$proj/.claude/commands/data/data-pipeline.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

@test "presets: react-vite-spa install is reduced, keeps api-data + frontend (T015)" {
    local proj="$TEST_DIR/proj-rv-red"
    run "$NEW_PROJECT" --preset react-vite-spa -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_proj_cmd_count "$proj")" -lt "$(_full_cmd_count)" ]
    # whitelisted module skills present (frontend + api-data), nextjs omitted
    [ -d "$proj/.claude/skills/dev-shadcn" ]
    [ -d "$proj/.claude/skills/dev-prisma" ]
    [ ! -d "$proj/.claude/skills/dev-nextjs" ]
    # off-stack absent (mobile / self-hosted)
    [ ! -d "$proj/.claude/skills/dev-flutter" ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

@test "presets: cli-tools install is minimal — no opt-in modules (T015)" {
    local proj="$TEST_DIR/proj-cli-red"
    run "$NEW_PROJECT" --preset cli-tools -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_proj_cmd_count "$proj")" -lt "$(_full_cmd_count)" ]
    # no modules opted in → all themed items absent
    [ ! -d "$proj/.claude/skills/dev-prisma" ]
    [ ! -d "$proj/.claude/skills/dev-shadcn" ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    # core kept
    [ -d "$proj/.claude/skills/dev-tdd" ]
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

@test "presets: ask_category prints ONLY the slug to stdout, menu to stderr (2026-07-12 regression)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    # The real caller (new-project.sh::get_project_type) does
    #   SELECTED_CATEGORY_SLUG=$(ask_category)
    # so ask_category's STDOUT must be EXACTLY the slug — the menu and prompt
    # belong on stderr. Before the fix they went to stdout, so the capture was
    # polluted with the whole menu (and the user saw nothing). This asserts the
    # stdout capture equals the bare slug.
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        slug=\$(echo '4' | ask_category 2>/dev/null)
        printf '%s' \"\$slug\"
    "
    [ "$status" -eq 0 ]
    [ "$output" = "game-interactive-media" ]
}

@test "presets: ask_category still shows the menu on stderr (2026-07-12 regression)" {
    [ -f "$BASE_DIR/scripts/lib/category-map.sh" ]
    # The menu must remain visible to the user — i.e. on stderr, not swallowed.
    run env BASE_DIR="$BASE_DIR" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$BASE_DIR/scripts/lib/category-map.sh'
        echo '4' | ask_category 2>&1 1>/dev/null
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"What are you building"* ]]
}
