#!/usr/bin/env bats

# =============================================================================
# Tests for the install-time command/agent filter (US-1, S2).
#
# Spec: specs/presets-commands-agents-filter/spec.md (US-1, EF-101/106/107/110/111)
# Plan: specs/presets-commands-agents-filter/plan.md (Phase 2, T004-T007)
#
# A preset's foundation.commands / foundation.agents drop|keep filter is applied
# at init by apply_catalog_filters(), consuming the S1 catalog-filter lib. These
# tests drive that behaviour through the real CLI (scripts/new-project.sh
# --preset … --presets-dir … -y <proj>), mirroring tests/new-project-preset-filter.bats.
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

# Write a synthetic preset JSON into a temp presets dir and echo the dir.
# $1 = preset name, $2 = the "foundation" object body (JSON), $3 = presets dir,
# $4 = optional defaultModules JSON array (e.g. '["biz","legal","growth"]').
_write_preset() {
    local name="$1" foundation="$2" dir="$3" dm="${4:-}"
    mkdir -p "$dir"
    local dm_line=""
    [ -n "$dm" ] && dm_line="  \"defaultModules\": $dm,"
    cat > "$dir/$name.json" << EOF
{
  "\$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "$name",
  "displayName": "Synthetic $name",
  "description": "Synthetic preset for catalog-filter install tests ($name).",
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
    echo "$dir"
}

# ---------------------------------------------------------------------------
# T004a — drop: a domain (commands) + an exact item (agents) are removed,
#          no hollow command-domain dir is left behind.
# ---------------------------------------------------------------------------
@test "catalog-filter install: drop domain:ops (commands) + dev-flutter (agent)" {
    local pdir="$TEST_DIR/presets"
    _write_preset "drop-ops" \
        '{"commands": {"drop": ["domain:ops"]}, "agents": {"drop": ["dev-flutter"]}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset drop-ops --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude" ]

    # The ops command domain is gone, and the emptied dir is removed (no hollow shell).
    [ ! -e "$proj/.claude/commands/ops" ]
    # The dropped agent is gone.
    [ ! -e "$proj/.claude/agents/dev-flutter.md" ]
    # Non-targeted catalogs/domains are intact (filter is not over-broad).
    [ -d "$proj/.claude/commands/work" ]
    [ -f "$proj/.claude/agents/work-explore.md" ]
    # Agents of the ops domain are NOT removed (commands filter is catalog-scoped).
    [ -f "$proj/.claude/agents/ops-deploy.md" ]
}

# ---------------------------------------------------------------------------
# T004b — keep (whitelist): only kept domain + floor survive on commands.
# ---------------------------------------------------------------------------
@test "catalog-filter install: keep domain:work (commands) drops the rest, floor stays" {
    local pdir="$TEST_DIR/presets"
    _write_preset "keep-work" \
        '{"commands": {"keep": ["domain:work"]}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset keep-work --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    # Kept domain present.
    [ -d "$proj/.claude/commands/work" ]
    # Floor entry points present even though not in the keep list.
    [ -f "$proj/.claude/commands/assistant.md" ]
    [ -f "$proj/.claude/commands/assistant-auto.md" ]
    # A non-kept, non-floor domain is removed.
    [ ! -e "$proj/.claude/commands/ops" ]
    # Agents catalog declared no filter → untouched (full set).
    [ -f "$proj/.claude/agents/ops-deploy.md" ]
}

# ---------------------------------------------------------------------------
# T006a — EF-106: a preset with NO command/agent filter installs the full
#          catalog, byte-for-byte identical to the unfiltered foundation.
# ---------------------------------------------------------------------------
@test "catalog-filter install: no command/agent filter = full catalog (EF-106)" {
    local pdir="$TEST_DIR/presets"
    # Opt into every module so "full catalog" is on disk to compare against —
    # the point of EF-106 is that the absence of a command/agent FILTER removes
    # nothing, not that modules install by default (they no longer do, v3).
    _write_preset "skills-only" \
        '{"skills": {"drop": ["dev-flutter"]}}' \
        "$pdir" '["biz","legal","growth"]' >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset skills-only --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    # Command + agent counts match the foundation catalog exactly.
    local src_cmds proj_cmds src_agents proj_agents
    src_cmds=$(find "$BASE_DIR/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    proj_cmds=$(find "$proj/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    src_agents=$(find "$BASE_DIR/.claude/agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
    proj_agents=$(find "$proj/.claude/agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
    [ "$proj_cmds" -eq "$src_cmds" ]
    [ "$proj_agents" -eq "$src_agents" ]
}

# ---------------------------------------------------------------------------
# T006b — EF-111: even a preset that tries to drop domain:work cannot remove
#          the protected floor at install time.
# ---------------------------------------------------------------------------
@test "catalog-filter install: drop domain:work cannot remove the floor (EF-111)" {
    local pdir="$TEST_DIR/presets"
    _write_preset "drop-work" \
        '{"commands": {"drop": ["domain:work", "assistant", "assistant-auto"]}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset drop-work --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    [ -d "$proj/.claude/commands/work" ]
    [ -f "$proj/.claude/commands/assistant.md" ]
    [ -f "$proj/.claude/commands/assistant-auto.md" ]
}

# ---------------------------------------------------------------------------
# T007a — dry-run (EF-107): lists what would be removed, removes nothing.
# ---------------------------------------------------------------------------
@test "catalog-filter install: --dry-run lists removals, installs nothing" {
    local pdir="$TEST_DIR/presets"
    _write_preset "drop-ops" \
        '{"commands": {"drop": ["domain:ops"]}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset drop-ops --presets-dir "$pdir" -y --dry-run "$proj"
    [ "$status" -eq 0 ]
    # Dry-run must emit a filter-specific removal line for the dropped command
    # domain (distinct from generic install/copy DRY-RUN lines) and install nothing.
    [[ "$output" == *"catalog filter"* ]]
    [[ "$output" == *"commands/ops"* ]]
    [ ! -d "$proj/.claude/commands/ops" ]
}

# ---------------------------------------------------------------------------
# Robustness (code review): a malformed filter (non-array drop, or scalar
# foundation) must not crash the install under set -euo pipefail; the bad
# declaration is ignored (full catalog) — the validator flags it in S3.
# ---------------------------------------------------------------------------
@test "catalog-filter install: malformed non-array drop does not crash, ignored" {
    local pdir="$TEST_DIR/presets"
    _write_preset "bad-drop" \
        '{"commands": {"drop": "not-an-array"}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset bad-drop --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]
    # Bad filter ignored → ops commands still present (full catalog).
    [ -d "$proj/.claude/commands/ops" ]
}

@test "catalog-filter install: scalar foundation does not crash the install" {
    local pdir="$TEST_DIR/presets"
    mkdir -p "$pdir"
    cat > "$pdir/scalar-foundation.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "scalar-foundation",
  "displayName": "Synthetic scalar-foundation",
  "description": "Malformed: foundation is a scalar; install must not crash.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["any"],
  "detect": {"combinator": "anyOf", "files": ["scalar-foundation.marker"]},
  "foundation": 123,
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false}
}
EOF
    local proj="$TEST_DIR/proj"
    run "$NEW_PROJECT" --preset scalar-foundation --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.claude/commands/ops" ]
}

# ---------------------------------------------------------------------------
# T007b — EF-110: project validation passes on a filtered install.
# ---------------------------------------------------------------------------
@test "catalog-filter install: filtered project passes validation (EF-110)" {
    local pdir="$TEST_DIR/presets"
    _write_preset "drop-ops" \
        '{"commands": {"drop": ["domain:ops"]}, "agents": {"drop": ["dev-flutter"]}}' \
        "$pdir" >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset drop-ops --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    run "$BASE_DIR/scripts/validate.sh" "$proj"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# T015 — CS-101: the shipped `nextjs` preset (stack-mirror filter) trims at
# least 6 commands and 5 agents (the command/agent counterparts of its dropped
# skills) vs the full catalog. nextjs keeps every module (defaultModules:null),
# so the reduction is purely the stack-mirror filter — horizontal-domain
# reduction is out of scope here (measured by foundation-modules CS-201/203).
# Uses the REAL official preset, not a synthetic one.
# ---------------------------------------------------------------------------
@test "catalog-filter install: nextjs preset trims >=6 commands and >=5 agents (CS-101)" {
    local proj="$TEST_DIR/proj-nextjs"
    run "$NEW_PROJECT" --preset nextjs -y "$proj"
    [ "$status" -eq 0 ]

    local src_cmds proj_cmds src_agents proj_agents
    src_cmds=$(find "$BASE_DIR/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    proj_cmds=$(find "$proj/.claude/commands" -type f -name '*.md' | wc -l | tr -d ' ')
    src_agents=$(find "$BASE_DIR/.claude/agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
    proj_agents=$(find "$proj/.claude/agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')

    [ "$((src_cmds - proj_cmds))" -ge 6 ]
    [ "$((src_agents - proj_agents))" -ge 5 ]

    # The specific stack-mirror counterparts are gone (diagnostic precision).
    [ ! -f "$proj/.claude/commands/dev/dev-flutter.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-mobile-release.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-opnsense.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-proxmox.md" ]
    [ ! -f "$proj/.claude/commands/ops/ops-infra-code.md" ]
    [ ! -f "$proj/.claude/commands/data/data-pipeline.md" ]
    [ ! -f "$proj/.claude/agents/dev-flutter.md" ]
    [ ! -f "$proj/.claude/agents/ops-opnsense.md" ]
    [ ! -f "$proj/.claude/agents/ops-proxmox.md" ]
    [ ! -f "$proj/.claude/agents/ops-infra-code.md" ]
    [ ! -f "$proj/.claude/agents/data-pipeline.md" ]

    # A kept item survives (install is not hollowed out).
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
}

# ---------------------------------------------------------------------------
# EF-309 — a `keep` whitelist over the core must NOT remove module-owned
# (biz/legal/growth) commands/agents: modules are out of the filter's
# jurisdiction (governed by defaultModules, not the preset filter). Since v3
# modules are opt-in, so the preset explicitly opts into biz via defaultModules
# to put a module on disk, then we assert the keep filter does not sweep it.
# ---------------------------------------------------------------------------
@test "catalog-filter install: keep whitelist does not sweep up module items (EF-309)" {
    local pdir="$TEST_DIR/presets"
    _write_preset "keep-work-only" \
        '{"commands": {"keep": ["domain:work"]}, "agents": {"keep": ["domain:work"]}}' \
        "$pdir" '["biz"]' >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset keep-work-only --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    # Whitelisted core kept; non-kept non-module core removed.
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
    [ ! -f "$proj/.claude/commands/dev/dev-tdd.md" ]
    # The opted-in module survives the keep (not in the filter's jurisdiction).
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]
    [ -f "$proj/.claude/agents/biz-mvp.md" ]
    # A module NOT opted in is simply absent (opt-in default), not "swept".
    [ ! -d "$proj/.claude/commands/legal" ]
}

# ---------------------------------------------------------------------------
# EF-309 generalised (thematic-modules S1) — a `keep` whitelist must NOT sweep
# up a CROSS-DOMAIN module item (module ≠ domain). A synthetic `thematic`
# module owns ops-deploy (command + agent) — its domain `ops` is NOT a module.
# Opted in, a keep[domain:work] install must keep ops-deploy (module-owned by
# name) while a sibling ops item NOT owned (ops-health) is still swept.
# This fails without the CF_EXCLUDE_ITEMS wiring (ops-deploy would be removed).
# ---------------------------------------------------------------------------
# Build a temp bundles dir = real bundles + a synthetic cross-domain `thematic`.
# Echoes the dir; caller exports MODULES_BUNDLES_DIR to it.
_synthetic_bundles_dir() {
    local dir="$TEST_DIR/bundles"
    mkdir -p "$dir"
    cp "$BASE_DIR"/scripts/lib/modules/*.txt "$dir"/
    cat > "$dir/thematic.txt" <<'EOF'
# Synthetic cross-domain module for S1 tests (domain `ops` is not a module).
.claude/commands/ops/ops-deploy.md
.claude/agents/ops-deploy.md
EOF
    echo "$dir"
}

@test "catalog-filter install: keep does not sweep a cross-domain module item (EF-309 generalised)" {
    local bdir; bdir="$(_synthetic_bundles_dir)"
    export MODULES_BUNDLES_DIR="$bdir"
    local pdir="$TEST_DIR/presets"
    _write_preset "keep-work-only" \
        '{"commands": {"keep": ["domain:work"]}, "agents": {"keep": ["domain:work"]}}' \
        "$pdir" '["thematic"]' >/dev/null
    local proj="$TEST_DIR/proj"

    run "$NEW_PROJECT" --preset keep-work-only --presets-dir "$pdir" -y "$proj"
    [ "$status" -eq 0 ]

    # Whitelisted core kept.
    [ -f "$proj/.claude/commands/work/work-plan.md" ]
    # Cross-domain module-owned item survives the keep (out of jurisdiction).
    [ -f "$proj/.claude/commands/ops/ops-deploy.md" ]
    [ -f "$proj/.claude/agents/ops-deploy.md" ]
    # A non-owned sibling of the SAME (ops) domain is still swept by the keep.
    [ ! -f "$proj/.claude/commands/ops/ops-health.md" ]
}
