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
# $4 = optional defaultModules JSON array (e.g. '["biz"]') — modules are opt-in
# since v3, so a test that needs a horizontal module on disk declares it here.
_write_cat_preset() {
    local dir="$1" name="${2:-synth-cat}" foundation="${3:-}" dm="${4:-}"
    mkdir -p "$dir"
    [ -z "$foundation" ] && foundation='{"commands":{"drop":["domain:ops"]},"agents":{"drop":["dev-flutter"]}}'
    local dm_line=""
    [ -n "$dm" ] && dm_line="  \"defaultModules\": $dm,"
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
$dm_line
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
    # Exact skip line for a dropped ops command (not just any 'ops' token).
    [[ "$output" == *"Skip (preset filter): commands/ops/"* ]]
    # Dry-run must not re-create the removed file.
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
}

# ---------------------------------------------------------------------------
# Reporting — the "Commands: N → M" would-be count must subtract the commands
# the preset filters out. A --simple project records no modules (v3 opt-in), so
# the would-be core also excludes the horizontal domains. With domain:ops
# dropped, M = (full catalog − horizontal modules − ops command count).
# ---------------------------------------------------------------------------
@test "update catalog-filter: Commands count reflects the preset filter" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1

    local total horiz ops_count expected
    total=$(find "$BASE_DIR/.claude/commands" -name '*.md' -type f | wc -l | tr -d ' ')
    horiz=$(find "$BASE_DIR/.claude/commands/biz" "$BASE_DIR/.claude/commands/legal" "$BASE_DIR/.claude/commands/growth" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
    ops_count=$(find "$BASE_DIR/.claude/commands/ops" -name '*.md' -type f | wc -l | tr -d ' ')
    expected=$((total - horiz - ops_count))

    run "$UPDATE" -y --dry-run --preset synth-cat --presets-dir "$pdir" --agents "$proj"
    [ "$status" -eq 0 ]
    local reported
    reported=$(echo "$output" | grep "Commands:" | head -1 | grep -oE '[0-9]+' | tail -1)
    [ "$reported" -eq "$expected" ]
}

# ---------------------------------------------------------------------------
# keep-mode (whitelist) on update — exercises the keep branch of
# _catalog_remove_set (update-specific mode detection, distinct from the lib).
# A commands.keep=[domain:work] preset must keep work (+ floor) and drop the
# rest; a previously-removed ops command stays removed, work-plan is restored.
# ---------------------------------------------------------------------------
@test "update catalog-filter: keep-mode whitelist holds on update" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir" "keep-work" '{"commands":{"keep":["domain:work"]}}'
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    rm -f "$proj/.claude/commands/ops/ops-proxmox.md" "$proj/.claude/commands/work/work-plan.md"

    run "$UPDATE" -y -f --preset keep-work --presets-dir "$pdir" "$proj"
    [ "$status" -eq 0 ]
    # Non-whitelisted command stays out; whitelisted (work) command restored.
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

# ---------------------------------------------------------------------------
# EF-309 — a `keep` whitelist on update must NOT skip module-owned
# (biz/legal/growth) items: they are out of the preset filter's jurisdiction,
# so update still refreshes them. Since v3 modules are opt-in, the preset opts
# into biz (defaultModules) so it is installed + recorded, then we verify the
# keep filter does not cause it to be skipped on update.
# ---------------------------------------------------------------------------
@test "update catalog-filter: keep whitelist does not skip module items (EF-309)" {
    local pdir="$TEST_DIR/presets" proj="$TEST_DIR/proj"
    _write_cat_preset "$pdir" "keep-work" '{"commands":{"keep":["domain:work"]}}' '["biz"]'
    "$NEW_PROJECT" -y --preset keep-work --presets-dir "$pdir" "$proj" >/dev/null 2>&1
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]   # biz opted in at install
    # User removes a module command; a keep[domain:work] update must re-add it
    # (the filter does not govern module domains).
    rm -f "$proj/.claude/commands/biz/biz-mvp.md"

    run "$UPDATE" -y -f --preset keep-work --presets-dir "$pdir" "$proj"
    [ "$status" -eq 0 ]
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]      # module refreshed, not skipped
    [ -f "$proj/.claude/commands/work/work-plan.md" ]   # kept core present
}
