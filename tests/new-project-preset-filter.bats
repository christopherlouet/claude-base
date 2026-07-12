#!/usr/bin/env bats

# =============================================================================
# Tests for bootstrap preset filter: keep and drop.
# Phase 1.B of the preset-react-vite-spa spec (tasks T007, T008).
#
# T007 — keep-filter: bootstrap with a synthetic keep-preset copies ONLY the
#         listed skills; every other skill from the foundation is absent.
# T008 — drop-filter regression: bootstrap with a synthetic drop-preset omits
#         the listed skills; at least 3 other skills are present.
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# ---------------------------------------------------------------------------
# T007 — keep-filter: only listed skills survive the install
# ---------------------------------------------------------------------------
@test "new-project-preset-filter: keep-preset copies only the listed skills (T007)" {
    # --- Arrange: write a synthetic preset that uses keep: [dev-tdd, dev-refactor] ---
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/keep-two.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "keep-two",
  "displayName": "Synthetic keep-two",
  "description": "Synthetic preset for testing the keep filter: keeps only dev-tdd and dev-refactor.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["keep-two.marker"]},
  "foundation": {
    "skills": {
      "keep": ["dev-tdd", "dev-refactor"]
    }
  },
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF

    local proj="$TEST_DIR/proj-keep-two"

    # --- Act: bootstrap with the synthetic keep-preset ---
    run "$NEW_PROJECT" --preset keep-two --presets-dir "$preset_dir" -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude" ]

    # --- Assert: the two kept skills MUST be present ---
    [ -d "$proj/.claude/skills/dev-tdd" ]
    [ -d "$proj/.claude/skills/dev-refactor" ]

    # --- Assert: every OTHER skill from the foundation MUST be absent ---
    # Iterate over all skills in the source tree and confirm none besides
    # dev-tdd and dev-refactor survived.
    local skill_name
    while IFS= read -r skill_dir; do
        skill_name="$(basename "$skill_dir")"
        [ "$skill_name" = "dev-tdd" ] && continue
        [ "$skill_name" = "dev-refactor" ] && continue
        [ "$skill_name" = "README.md" ] && continue
        if [ -d "$proj/.claude/skills/$skill_name" ]; then
            echo "ERROR: non-kept skill '$skill_name' was installed but should have been absent" >&2
            return 1
        fi
    done < <(find "$BASE_DIR/.claude/skills" -maxdepth 1 -mindepth 1 -type d)
}

# ---------------------------------------------------------------------------
# T008 — drop-filter regression: drop-preset removes listed skills,
#          leaves others intact
# ---------------------------------------------------------------------------
@test "new-project-preset-filter: drop-preset omits listed skill and leaves others (T008)" {
    # --- Arrange: write a synthetic preset that uses drop: [dev-flutter] ---
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/drop-flutter.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "drop-flutter",
  "displayName": "Synthetic drop-flutter",
  "description": "Synthetic preset for testing the drop filter: drops dev-flutter.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["drop-flutter.marker"]},
  "foundation": {
    "skills": {
      "drop": ["dev-flutter"]
    }
  },
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF

    local proj="$TEST_DIR/proj-drop-flutter"

    # --- Act: bootstrap with the synthetic drop-preset ---
    run "$NEW_PROJECT" --preset drop-flutter --presets-dir "$preset_dir" -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude" ]

    # --- Assert: dev-flutter MUST be absent ---
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # --- Assert: at least 3 other skills are present (regression: filter is not over-broad) ---
    local present_count=0
    local skill_name
    while IFS= read -r skill_dir; do
        skill_name="$(basename "$skill_dir")"
        [ "$skill_name" = "dev-flutter" ] && continue
        if [ -d "$proj/.claude/skills/$skill_name" ]; then
            present_count=$((present_count + 1))
        fi
    done < <(find "$BASE_DIR/.claude/skills" -maxdepth 1 -mindepth 1 -type d)

    if [ "$present_count" -lt 3 ]; then
        echo "ERROR: only $present_count non-dropped skills present; expected at least 3" >&2
        return 1
    fi
}

# ---------------------------------------------------------------------------
# T024 — react-vite-spa scopes purely by module opt-in (api-data + frontend);
# its opted module skills are present, off-stack module skills absent, no filter.
# ---------------------------------------------------------------------------
@test "new-project-preset-filter: react-vite-spa scopes via module opt-in (T024)" {
    local proj="$TEST_DIR/proj-react-vite-spa"

    run "$NEW_PROJECT" --preset react-vite-spa -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude" ]

    # --- Opted-in module skills (api-data + frontend) MUST be present ---
    local in_skills=(
        "dev-prisma" "dev-supabase" "dev-graphql"        # api-data
        "dev-react-perf" "dev-shadcn" "dev-frontend-design"  # frontend
        "dev-tdd" "qa-review"                            # core
    )
    for skill in "${in_skills[@]}"; do
        if [ ! -d "$proj/.claude/skills/$skill" ]; then
            echo "ERROR: opted-in skill '$skill' is absent after install" >&2
            return 1
        fi
    done

    # --- Off-stack module skills (not opted in) MUST be absent ---
    local out_skills=(
        "dev-flutter"          # mobile
        "dev-nextjs"           # nextjs (its own module — SPA, not Next.js)
        "ops-mobile-release"   # mobile
        "ops-proxmox"          # self-hosted
        "ops-infra-code"       # iac
        "data-pipeline"        # data-eng
    )
    for skill in "${out_skills[@]}"; do
        if [ -d "$proj/.claude/skills/$skill" ]; then
            echo "ERROR: off-stack skill '$skill' is present but should be absent" >&2
            return 1
        fi
    done
}

# ---------------------------------------------------------------------------
# 2026-07-12 regression — the INTERACTIVE preset path (menu → create_project)
# must apply the SAME skill/command/agent filters as run_simple_mode. Before
# the fix, create_project only ran apply_modules_filter, so a menu-selected
# preset installed the FULL catalog and foundation.json disagreed with disk.
# This drives create_project directly with a preset loaded, exactly as main()'s
# interactive branch does (load_preset + load_module_partition, then create).
# ---------------------------------------------------------------------------
@test "new-project-preset-filter: create_project applies the keep filter (interactive path, regression)" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/keep-two.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "keep-two",
  "displayName": "Synthetic keep-two",
  "description": "Synthetic preset for testing the keep filter via create_project.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["keep-two.marker"]},
  "foundation": {
    "skills": {
      "keep": ["dev-tdd", "dev-refactor"]
    }
  },
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF

    local proj="$TEST_DIR/proj-interactive-keep"
    mkdir -p "$proj"

    run env BASE_DIR="$BASE_DIR" proj="$proj" preset_dir="$preset_dir" bash -c '
        source "$BASE_DIR/scripts/new-project.sh"   # source guard prevents main()
        PROJECT_PATH="$proj"; PROJECT_TYPE="generic"; EXISTING_PROJECT=false; DRY_RUN=false
        QUIET=true
        INCLUDE_CICD=false; INCLUDE_HOOKS=false; INCLUDE_MCP=false; INCLUDE_DOCKER=false
        PRESETS_DIR_OVERRIDE="$preset_dir"
        PRESET_NAME="keep-two"
        # mirror main()'"'"'s interactive preset branch
        load_preset "$PRESET_NAME"
        load_module_partition
        create_project
    ' >/dev/null 2>&1
    [ "$status" -eq 0 ]

    # The two kept skills survive
    [ -d "$proj/.claude/skills/dev-tdd" ]
    [ -d "$proj/.claude/skills/dev-refactor" ]
    # And ONLY those two — the keep-filter removed every other skill
    local n
    n=$(find "$proj/.claude/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    [ "$n" = "2" ]
}
