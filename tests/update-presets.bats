#!/usr/bin/env bats

# =============================================================================
# Tests for preset-aware updates (specs/presets-update-aware/).
# Verifies that scripts/update.sh respects an active preset's skill filter:
#   - --preset NAME explicit override
#   - --no-preset opt-out
#   - auto-detection via scan_presets (PR #160)
#   - multi-match refusal
#   - dry-run lists skipped skills
#   - orphan detection excludes preset-dropped skills
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"
UPDATE="$BASE_DIR/scripts/update.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "update-presets: helper scripts exist" {
    [ -x "$UPDATE" ]
    [ -x "$NEW_PROJECT" ]
}

# =============================================================================
# Phase 2 — Foundation: argument parsing + resolve_active_preset
# =============================================================================

@test "update-presets: --preset bogus_xyz fails with clear error naming the preset (T003)" {
    local proj="$TEST_DIR/proj-bogus-preset"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    run "$UPDATE" -y --dry-run --preset bogus_xyz_no_such_preset "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"bogus_xyz_no_such_preset"* ]]
    [[ "$output" == *"preset"* ]]
}

@test "update-presets: --preset and --no-preset are mutually exclusive (T004)" {
    local proj="$TEST_DIR/proj-mutex"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --no-preset "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"mutually exclusive"* ]]
}

@test "update-presets: multi-match without flag refuses with disambiguation message (T005)" {
    local proj="$TEST_DIR/proj-multi"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    # Make the project match BOTH nextjs and astro detect rules.
    touch "$proj/next.config.js"
    touch "$proj/astro.config.mjs"
    echo '{"dependencies":{"next":"^15","astro":"^4"}}' > "$proj/package.json"
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"astro"* ]]
    [[ "$output" == *"--preset"* ]] || [[ "$output" == *"--no-preset"* ]]
}

@test "update-presets: multi-match nextjs+react-vite-spa hybrid refuses with disambiguation message (T044)" {
    # Hybrid fixture: satisfies BOTH nextjs (next.config.js + "next" in package.json)
    # and react-vite-spa (vite.config.ts + "react-router-dom" in package.json).
    # The update --skills auto-detect path must refuse and name both matches.
    local proj="$TEST_DIR/proj-hybrid-multi"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    cat > "$proj/vite.config.ts" <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({});
EOF
    cat > "$proj/next.config.js" <<'EOF'
module.exports = {};
EOF
    cat > "$proj/package.json" <<'EOF'
{
  "name": "hybrid-fixture",
  "version": "0.0.0",
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.0.0",
    "vite": "^5.0.0"
  }
}
EOF
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"react-vite-spa"* ]]
    [[ "$output" == *"--preset"* ]] || [[ "$output" == *"--no-preset"* ]]
}

@test "update-presets: --preset nextjs resolves and update proceeds (T006)" {
    local proj="$TEST_DIR/proj-resolve-ok"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
}

@test "update-presets: no preset match and no flag prints no Active preset line (T007/CS-006)" {
    local proj="$TEST_DIR/proj-no-match"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    # Bare simple project — no detect markers exist for any preset.
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Active preset:"* ]]
}

# =============================================================================
# Phase 3 — Filter applied to skill copy (US-1, US-2, US-3)
# =============================================================================

@test "update-presets: auto-detected preset blocks re-add of dropped skill (T014/US-1)" {
    local proj="$TEST_DIR/proj-auto-filter"
    # Bootstrap with the nextjs preset → drops dev-flutter, ops-mobile-release, etc.
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # Run update --skills. The project should still match nextjs detect rule
    # (next.config.js, package.json with "next") because new-project.sh
    # doesn't add those, BUT we add markers manually to trigger detection.
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"

    run "$UPDATE" -y -f --skills "$proj"
    [ "$status" -eq 0 ]
    # dev-flutter must still be absent — filter blocked the re-add.
    [ ! -d "$proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: explicit --preset override blocks re-add (T016/US-2)" {
    local proj="$TEST_DIR/proj-explicit-override"
    # Bootstrap simple — every skill installed including dev-shadcn (frontend).
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude/skills/dev-shadcn" ]

    # Simulate user removing dev-shadcn from the project.
    rm -rf "$proj/.claude/skills/dev-shadcn"
    [ ! -d "$proj/.claude/skills/dev-shadcn" ]

    # Run update with explicit --preset homelab-proxmox (which drops dev-shadcn).
    run "$UPDATE" -y -f --preset homelab-proxmox --skills "$proj"
    [ "$status" -eq 0 ]
    # dev-shadcn must NOT be re-added — homelab-proxmox filter blocks copy.
    [ ! -d "$proj/.claude/skills/dev-shadcn" ]
}

@test "update-presets: --no-preset disables filter, dropped skills re-added (T017/US-3)" {
    local proj="$TEST_DIR/proj-no-preset-flag"
    # Bootstrap with nextjs preset — dev-flutter absent.
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # Add nextjs detect markers so that without --no-preset, detection would fire.
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"

    # Run update --no-preset --skills: filter disabled, every skill copied.
    run "$UPDATE" -y -f --no-preset --skills "$proj"
    [ "$status" -eq 0 ]
    # dev-flutter MUST now be present.
    [ -d "$proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: no flag, no match - every skill re-added (T018/CS-006)" {
    local proj="$TEST_DIR/proj-cs006"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    # Simulate a user removing a skill that's not in any preset's drop list.
    rm -rf "$proj/.claude/skills/dev-tdd"
    [ ! -d "$proj/.claude/skills/dev-tdd" ]

    # Bare project, no detect markers, no flag.
    run "$UPDATE" -y -f --skills "$proj"
    [ "$status" -eq 0 ]
    # dev-tdd must be re-added (today's behavior preserved).
    [ -d "$proj/.claude/skills/dev-tdd" ]
}

# =============================================================================
# Phase 4 — Visibility line (US-4)
# =============================================================================

@test "update-presets: auto-detected preset prints Active preset (detected) line (T023/US-4)" {
    local proj="$TEST_DIR/proj-vis-detected"
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Active preset: nextjs"* ]]
    [[ "$output" == *"detected"* ]]
}

@test "update-presets: --preset prints Active preset (via --preset) line (T024/US-4)" {
    local proj="$TEST_DIR/proj-vis-explicit"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset fastapi --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Active preset: fastapi"* ]]
    [[ "$output" == *"--preset"* ]]
}

@test "update-presets: --no-preset stays silent on Active preset line (T025/US-4)" {
    local proj="$TEST_DIR/proj-vis-noflag"
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"
    run "$UPDATE" -y --dry-run --no-preset --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Active preset:"* ]]
}

# =============================================================================
# Phase 6 — Orphan detection respects active preset (US-6)
# =============================================================================

@test "update-presets: --detect-orphans on a preset project does not flag dropped skills (T029/US-6)" {
    local proj="$TEST_DIR/proj-orphans-aware"
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1
    # Add nextjs detect markers so resolution picks the preset.
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"
    run "$UPDATE" -y --detect-orphans "$proj"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    # Dropped skills (e.g. dev-flutter) must NOT be reported as orphans.
    [[ "$output" != *"dev-flutter is an orphan"* ]]
    [[ "$output" != *"orphan: .claude/skills/dev-flutter"* ]]
}

# =============================================================================
# Phase 5 — Dry-run lists skipped skills (US-5)
# =============================================================================

@test "update-presets: --dry-run with active preset lists skipped skills (T027/US-5)" {
    local proj="$TEST_DIR/proj-dry-run-list"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
    # The nextjs preset drops dev-flutter; dry-run must announce the skip.
    [[ "$output" == *"Skip (preset filter)"* ]]
    [[ "$output" == *"dev-flutter"* ]]
}

@test "update-presets: filter is COPY-only, never deletes existing nested skill files (T019/EF-011)" {
    local proj="$TEST_DIR/proj-copy-only"
    "$NEW_PROJECT" --preset nextjs "$proj" >/dev/null 2>&1

    # Manually create a customized file under a path the preset drops.
    mkdir -p "$proj/.claude/skills/dev-flutter"
    echo "user-customized content" > "$proj/.claude/skills/dev-flutter/custom.txt"

    # Add nextjs detect markers.
    touch "$proj/next.config.js"
    echo '{"dependencies":{"next":"^15"}}' > "$proj/package.json"

    run "$UPDATE" -y -f --skills "$proj"
    [ "$status" -eq 0 ]
    # The customized file is preserved (filter is COPY-only, never deletes).
    [ -f "$proj/.claude/skills/dev-flutter/custom.txt" ]
    # No SKILL.md was added from the foundation (filter blocked the copy).
    [ ! -f "$proj/.claude/skills/dev-flutter/SKILL.md" ]
}

# =============================================================================
# Phase 6 — Recommendations re-printed at end of update (US-2, T2.3/T2.4)
# =============================================================================

@test "update-presets: --preset nextjs reprints recommended vendor skills section (T2.3)" {
    local proj="$TEST_DIR/proj-reco-nextjs"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Recommended vendor skills for this stack"* ]]
    [[ "$output" == *"vercel-labs/agent-skills"* ]]
    [[ "$output" == *"docs/recipes/recommended-vendor-skills.md"* ]]
}

@test "update-presets: --quiet suppresses the recommendations section (T2.3)" {
    local proj="$TEST_DIR/proj-reco-quiet"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --quiet --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Recommended vendor skills for this stack"* ]]
}

@test "update-presets: no active preset means no recommendations section (T2.3)" {
    local proj="$TEST_DIR/proj-reco-no-preset"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --no-preset --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Recommended vendor skills for this stack"* ]]
}

@test "update-presets: recommendations appear AFTER the Update completed banner (T2.4/EF-004)" {
    local proj="$TEST_DIR/proj-reco-order"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
    local banner_line reco_line
    banner_line=$(echo "$output" | grep -n "Update completed" | head -1 | cut -d: -f1)
    reco_line=$(echo "$output" | grep -n "Recommended vendor skills for this stack" | head -1 | cut -d: -f1)
    [ -n "$banner_line" ]
    [ -n "$reco_line" ]
    [ "$reco_line" -gt "$banner_line" ]
}

# =============================================================================
# Phase 1.C — keep-filter persists across update lifecycle (T010, T011)
# =============================================================================

@test "update-presets: keep-preset filter holds on --skills re-add (T010)" {
    # Arrange: synthetic keep-preset that keeps only dev-tdd and dev-refactor.
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/keep-two.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "keep-two",
  "displayName": "Synthetic keep-two",
  "description": "Synthetic preset: keeps only dev-tdd and dev-refactor.",
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

    local proj="$TEST_DIR/proj-keep-update"

    # Bootstrap with the synthetic keep-preset (new-project.sh already supports --presets-dir).
    "$NEW_PROJECT" --preset keep-two --presets-dir "$preset_dir" -y "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    # After bootstrap: kept skills present, non-kept absent.
    [ -d "$proj/.claude/skills/dev-tdd" ]
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # Act: delete one kept skill, then run update --skills with the same preset filter.
    rm -rf "$proj/.claude/skills/dev-tdd"
    [ ! -d "$proj/.claude/skills/dev-tdd" ]

    run "$UPDATE" -y -f --preset keep-two --presets-dir "$preset_dir" --skills "$proj"
    [ "$status" -eq 0 ]

    # Assert: kept skill is re-added.
    [ -d "$proj/.claude/skills/dev-tdd" ]
    # Assert: non-kept skill is still absent (filter held).
    [ ! -d "$proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: --no-preset reverses keep-filter, all skills re-added (T011)" {
    # Arrange: same synthetic keep-preset.
    local preset_dir="$TEST_DIR/synthetic-presets"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/keep-two.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "keep-two",
  "displayName": "Synthetic keep-two",
  "description": "Synthetic preset: keeps only dev-tdd and dev-refactor.",
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

    local proj="$TEST_DIR/proj-keep-no-preset"

    # Bootstrap with the synthetic keep-preset.
    "$NEW_PROJECT" --preset keep-two --presets-dir "$preset_dir" -y "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # Act: run update --no-preset --skills — filter disabled, all foundation skills re-added.
    run "$UPDATE" -y -f --no-preset --skills "$proj"
    [ "$status" -eq 0 ]

    # Assert: a skill that was excluded by the keep-filter is now present.
    [ -d "$proj/.claude/skills/dev-flutter" ]
}

# =============================================================================
# Phase 4 — US-3 update lifecycle exerciser: react-vite-spa real preset (T033-T035)
# Integration tests that exercise load_active_keep_list + is_skill_kept against
# the actual .claude/presets/react-vite-spa.json (no synthetic preset).
# =============================================================================

@test "update-presets: react-vite-spa keep filter survives update (T033)" {
    local proj="$TEST_DIR/proj-react-vite-spa-keep"

    # Bootstrap with the real react-vite-spa preset.
    "$NEW_PROJECT" --preset react-vite-spa -y "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]

    # dev-tdd is in the react-vite-spa keep list — must be present after bootstrap.
    [ -d "$proj/.claude/skills/dev-tdd" ]

    # Simulate user deleting dev-tdd (e.g. accidental rm or branch reset).
    rm -rf "$proj/.claude/skills/dev-tdd"
    [ ! -d "$proj/.claude/skills/dev-tdd" ]

    # Run update with explicit --preset react-vite-spa (cleanest form: matches how
    # the user bootstrapped the project).
    run "$UPDATE" -y -f --preset react-vite-spa --skills "$proj"
    [ "$status" -eq 0 ]

    # dev-tdd must be re-added (it is in the keep list).
    [ -d "$proj/.claude/skills/dev-tdd" ]

    # dev-flutter must still be absent (not in the keep list — filter held).
    [ ! -d "$proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: react-vite-spa --no-preset reverses keep-filter (T034)" {
    local proj="$TEST_DIR/proj-react-vite-spa-no-preset"

    # Bootstrap with the real react-vite-spa preset — dev-flutter absent.
    "$NEW_PROJECT" --preset react-vite-spa -y "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    [ ! -d "$proj/.claude/skills/dev-flutter" ]

    # Run update --no-preset --skills: no preset filter applied, every foundation
    # skill is eligible for re-add.
    run "$UPDATE" -y -f --no-preset --skills "$proj"
    [ "$status" -eq 0 ]

    # dev-flutter must now be present (filter explicitly disabled).
    [ -d "$proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: react-vite-spa dry-run lists non-kept skills as skipped (T035)" {
    local proj="$TEST_DIR/proj-react-vite-spa-dryrun"

    # Bootstrap with the real react-vite-spa preset.
    "$NEW_PROJECT" --preset react-vite-spa -y "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]

    # Run dry-run with explicit --preset react-vite-spa.
    run "$UPDATE" -y --dry-run --preset react-vite-spa --skills "$proj"
    [ "$status" -eq 0 ]

    # dev-flutter is NOT in the react-vite-spa keep list; dry-run must announce skip.
    [[ "$output" == *"Skip (preset filter)"* ]]
    [[ "$output" == *"dev-flutter"* ]]
}

# =============================================================================
# Manifest-first preset resolution (specs/foundation-modules US-1, T013)
# Resolution order: --preset > --no-preset > manifest > auto-detect (legacy).
# =============================================================================

# Helper: synthetic preset dir with a drop-one preset whose detect rule
# matches a marker file we control.
_write_synthetic_preset() {
    local preset_dir="$1"
    mkdir -p "$preset_dir"
    cat > "$preset_dir/synth-drop.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "synth-drop",
  "displayName": "Synthetic drop preset",
  "description": "Synthetic preset for manifest-first resolution tests: drops dev-flutter.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["synth-drop.marker"]},
  "foundation": {"skills": {"drop": ["dev-flutter"]}},
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF
}

@test "update-presets: manifest-recorded preset drives the update without detection" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    _write_synthetic_preset "$preset_dir"

    "$NEW_PROJECT" --preset synth-drop --presets-dir "$preset_dir" -y "$TEST_DIR/proj" >/dev/null 2>&1
    # The project manifest must record the preset...
    [ "$(jq -r '.preset' "$TEST_DIR/proj/.claude/foundation.json")" = "synth-drop" ]
    # ...and NO detect marker file exists (auto-detection would find nothing).
    [ ! -f "$TEST_DIR/proj/synth-drop.marker" ]

    run "$UPDATE" --presets-dir "$preset_dir" --skills -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synth-drop"* ]]
    [[ "$output" == *"manifest"* ]]
    # The preset's skill filter applied: dev-flutter not reinstalled.
    [ ! -d "$TEST_DIR/proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: --preset flag overrides the manifest-recorded preset" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    _write_synthetic_preset "$preset_dir"

    "$NEW_PROJECT" --preset synth-drop --presets-dir "$preset_dir" -y "$TEST_DIR/proj" >/dev/null 2>&1

    # Explicit --preset nextjs must win over the recorded synth-drop.
    run "$UPDATE" --preset nextjs --skills -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"--preset"* ]]
}

@test "update-presets: --no-preset still disables filtering despite the manifest" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    _write_synthetic_preset "$preset_dir"

    "$NEW_PROJECT" --preset synth-drop --presets-dir "$preset_dir" -y "$TEST_DIR/proj" >/dev/null 2>&1

    run "$UPDATE" --no-preset --skills -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # Full catalog restored: dev-flutter is back.
    [ -d "$TEST_DIR/proj/.claude/skills/dev-flutter" ]
}

@test "update-presets: multi-match refusal is unreachable when the manifest records a preset (CS-205)" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    _write_synthetic_preset "$preset_dir"
    # Second synthetic preset whose detect rule matches the same marker.
    sed 's/synth-drop/synth-two/g' "$preset_dir/synth-drop.json" > "$preset_dir/synth-two.json"

    "$NEW_PROJECT" --preset synth-drop --presets-dir "$preset_dir" -y "$TEST_DIR/proj" >/dev/null 2>&1
    # Plant BOTH detect markers: auto-detection alone would refuse (2 matches).
    touch "$TEST_DIR/proj/synth-drop.marker" "$TEST_DIR/proj/synth-two.marker"

    run "$UPDATE" --presets-dir "$preset_dir" --skills -y "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synth-drop"* ]]
    [[ "$output" != *"multiple presets match"* ]]
}

@test "update-presets: corrupted manifest fails loud instead of silent auto-detect fallback" {
    local preset_dir="$TEST_DIR/synthetic-presets"
    _write_synthetic_preset "$preset_dir"
    "$NEW_PROJECT" --preset synth-drop --presets-dir "$preset_dir" -y "$TEST_DIR/proj" >/dev/null 2>&1

    echo "{ broken" > "$TEST_DIR/proj/.claude/foundation.json"

    run "$UPDATE" --presets-dir "$preset_dir" --skills -y "$TEST_DIR/proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"foundation.json"* ]]
}
