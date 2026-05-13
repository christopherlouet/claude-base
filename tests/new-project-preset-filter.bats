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
# T024 — react-vite-spa keep filter: kept skills present, OUT skills absent
# ---------------------------------------------------------------------------
@test "new-project-preset-filter: react-vite-spa applies keep filter (T024)" {
    local proj="$TEST_DIR/proj-react-vite-spa"

    # --- Act: bootstrap with the real react-vite-spa preset ---
    run "$NEW_PROJECT" --preset react-vite-spa -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude" ]

    # --- Assert: every skill in the keep list MUST be present ---
    local keep_list
    keep_list=$(jq -r '.foundation.skills.keep[]' "$BASE_DIR/.claude/presets/react-vite-spa.json")
    while IFS= read -r skill; do
        [ -z "$skill" ] && continue
        if [ ! -d "$proj/.claude/skills/$skill" ]; then
            echo "ERROR: kept skill '$skill' is absent after install" >&2
            return 1
        fi
    done <<< "$keep_list"

    # --- Assert: known out-of-scope skills MUST be absent ---
    local out_skills=(
        "dev-flutter"
        "ops-mobile-release"
        "ops-proxmox"
        "ops-opnsense"
        "ops-infra-code"
        "data-pipeline"
    )
    for skill in "${out_skills[@]}"; do
        if [ -d "$proj/.claude/skills/$skill" ]; then
            echo "ERROR: out-of-scope skill '$skill' is present but should be absent" >&2
            return 1
        fi
    done
}
