#!/usr/bin/env bats

# =============================================================================
# Tests for command/agent filtering on UPDATE — US-3 (S4).
#
# Spec: specs/presets-commands-agents-filter/spec.md (EF-108, CS-102, EF-111)
# scripts/update.sh must skip excluded commands/agents on update (copy-only,
# never deleting on-disk), report them distinctly, and the --no-preset escape
# hatch must restore the full catalog. Mirrors the skill-filter + module-skip
# tests in tests/update-presets.bats.
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

# Synthetic preset dropping the ops command domain + the dev-flutter agent.
_write_cat_preset() {
    local dir="$1" name="${2:-synth-cat}" foundation="${3:-}"
    mkdir -p "$dir"
    [ -z "$foundation" ] && foundation='{"commands":{"drop":["domain:ops"]},"agents":{"drop":["dev-flutter"]}}'
    cat > "$dir/$name.json" <<EOF
{
  "\$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "$name",
  "displayName": "Synthetic $name",
  "description": "Synthetic preset for update catalog-filter tests.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["$name.marker"]},
  "foundation": $foundation,
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF
}

# ---------------------------------------------------------------------------
# CS-102 — excluded command + agent are NOT re-added on update.
# ---------------------------------------------------------------------------
@test "update catalog-filter: dropped command/agent are not re-added (CS-102)" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    [ -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ -f "$proj/.claude/agents/dev-flutter.md" ]

    # User removes them; the filtering update must not bring them back.
    rm -f "$proj/.claude/commands/ops/ops-proxmox.md" "$proj/.claude/agents/dev-flutter.md"

    run "$UPDATE" -y -f --preset synth-cat --presets-dir "$pdir" --agents "$proj"
    [ "$status" -eq 0 ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ ! -f "$proj/.claude/agents/dev-flutter.md" ]
}

# ---------------------------------------------------------------------------
# EF-108 — skipped-by-preset items are reported distinctly.
# ---------------------------------------------------------------------------
@test "update catalog-filter: preset-skipped items reported distinctly" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    rm -f "$proj/.claude/commands/ops/ops-proxmox.md"

    run "$UPDATE" -y -f --preset synth-cat --presets-dir "$pdir" --agents "$proj"
    [ "$status" -eq 0 ]
    # Distinct summary line for preset-filter skips (not lumped with modules).
    [[ "$output" == *"Filtered by preset"* ]]
}

# ---------------------------------------------------------------------------
# EF-108 escape hatch — --no-preset restores the full catalog.
# ---------------------------------------------------------------------------
@test "update catalog-filter: --no-preset restores the dropped command/agent" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    rm -f "$proj/.claude/commands/ops/ops-proxmox.md" "$proj/.claude/agents/dev-flutter.md"

    run "$UPDATE" -y -f --no-preset --agents "$proj"
    [ "$status" -eq 0 ]
    [ -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ -f "$proj/.claude/agents/dev-flutter.md" ]
}

# ---------------------------------------------------------------------------
# EF-111 — the protected floor is never skipped on update, even if a
# (malformed) preset drops domain:work.
# ---------------------------------------------------------------------------
@test "update catalog-filter: floor (domain:work) is restored, never skipped (EF-111)" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir" "drop-work" '{"commands":{"drop":["domain:work"]}}'
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
    rm -f "$proj/.claude/commands/work/work-plan.md"

    run "$UPDATE" -y -f --preset drop-work --presets-dir "$pdir" "$proj"
    [ "$status" -eq 0 ]
    # Floor command re-added (filter must not skip it).
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

# ---------------------------------------------------------------------------
# EF-107 — dry-run lists preset-skipped items and changes nothing.
# ---------------------------------------------------------------------------
@test "update catalog-filter: --dry-run lists preset-skipped commands, no writes" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    rm -f "$proj/.claude/commands/ops/ops-proxmox.md"

    run "$UPDATE" -y --dry-run --preset synth-cat --presets-dir "$pdir" --agents "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"preset filter"* ]]
    [[ "$output" == *"ops"* ]]
    # Dry-run must not re-create the removed file.
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
}

# ---------------------------------------------------------------------------
# Reporting — the "Commands: N → M" would-be count must subtract the commands
# the preset filters out, not just absent-module commands. With domain:ops
# dropped, M must equal (foundation total − ops command count). Regression
# guard for the stale "Presets still do not filter commands today" path.
# ---------------------------------------------------------------------------
@test "update catalog-filter: Commands count reflects the preset filter" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1

    local total ops_count expected
    total=$(find "$BASE_DIR/.claude/commands" -name '*.md' -type f | wc -l | tr -d ' ')
    ops_count=$(find "$BASE_DIR/.claude/commands/ops" -name '*.md' -type f | wc -l | tr -d ' ')
    expected=$((total - ops_count))

    run "$UPDATE" -y --dry-run --preset synth-cat --presets-dir "$pdir" --agents "$proj"
    [ "$status" -eq 0 ]
    local reported
    reported=$(echo "$output" | grep "Commands:" | head -1 | grep -oE '[0-9]+' | tail -1)
    [ "$reported" -eq "$expected" ]
}
