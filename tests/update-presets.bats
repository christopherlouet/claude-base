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
