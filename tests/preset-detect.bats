#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/preset-detect.sh
# Covers data-driven preset detection (see specs/presets-detection-and-e2e/).
# Tests use synthetic presets in $TEST_DIR/presets-dir, pointed at via the
# PRESETS_DIR env var so they stay decoupled from the official preset content.
# =============================================================================

load 'test_helper'

PRESET_DETECT_LIB="$BASE_DIR/scripts/lib/preset-detect.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    [ -f "$PRESET_DETECT_LIB" ]
    mkdir -p "$TEST_DIR/presets-dir"
    mkdir -p "$TEST_DIR/proj"
}

teardown() {
    teardown_test_dir
}

# Helper: write a synthetic preset .json with a given detect block.
make_synthetic_preset() {
    local name="$1"
    local detect_json="$2"
    local presets_dir="${3:-$TEST_DIR/presets-dir}"
    mkdir -p "$presets_dir"
    cat > "$presets_dir/$name.json" <<EOF
{
  "name": "$name",
  "displayName": "$name",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": $detect_json
}
EOF
}

# Helper: invoke scan_presets in a subshell with PRESETS_DIR overridden.
scan_in_temp() {
    local target="$1"
    local presets_dir="${2:-$TEST_DIR/presets-dir}"
    bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$PRESET_DETECT_LIB'
        PRESETS_DIR='$presets_dir' scan_presets '$target'
    "
}

# =============================================================================
# Library wiring
# =============================================================================

@test "preset-detect: library file exists and is sourceable" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$PRESET_DETECT_LIB'"
    [ "$status" -eq 0 ]
}

@test "preset-detect: scan_presets is defined after sourcing" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$PRESET_DETECT_LIB' && declare -f scan_presets >/dev/null"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Files signal
# =============================================================================

@test "preset-detect: anyOf + files signal matches when file exists" {
    make_synthetic_preset "alpha" '{"combinator":"anyOf","files":["alpha.cfg"]}'
    touch "$TEST_DIR/proj/alpha.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"alpha"* ]]
}

@test "preset-detect: anyOf + files signal does NOT match when file missing" {
    make_synthetic_preset "alpha" '{"combinator":"anyOf","files":["alpha.cfg"]}'
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"alpha"* ]]
}

@test "preset-detect: files signal supports a glob pattern" {
    make_synthetic_preset "globbed" '{"combinator":"anyOf","files":["config.*.yaml"]}'
    touch "$TEST_DIR/proj/config.prod.yaml"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"globbed"* ]]
}

# =============================================================================
# depFiles signal
# =============================================================================

@test "preset-detect: depFiles signal matches when path exists and contains string (case-insensitive)" {
    make_synthetic_preset "py" '{"combinator":"anyOf","depFiles":[{"path":"requirements.txt","contains":"FastAPI"}]}'
    echo "fastapi==0.100" > "$TEST_DIR/proj/requirements.txt"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"py"* ]]
}

@test "preset-detect: depFiles signal does NOT match when path missing" {
    make_synthetic_preset "py" '{"combinator":"anyOf","depFiles":[{"path":"requirements.txt","contains":"fastapi"}]}'
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"py"* ]]
}

@test "preset-detect: depFiles signal does NOT match when path exists but content missing" {
    make_synthetic_preset "py" '{"combinator":"anyOf","depFiles":[{"path":"requirements.txt","contains":"fastapi"}]}'
    echo "django==5.0" > "$TEST_DIR/proj/requirements.txt"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"py"* ]]
}

# =============================================================================
# Dogfood finding #8 — depFiles signal supports common subdirectory layouts
# Captured 2026-05-22 in specs/dogfood-v2-findings/spec.md. Real-world IaC
# repos commonly place .tf files in infrastructure/, terraform/, iac/ etc.
# rather than at the root. The `files` signal already uses `find -maxdepth 2`,
# but `depFiles` was root-only — asymmetric and broke detection for the
# homelab-proxmox preset against a project layout like
# `pve-home/infrastructure/proxmox/versions.tf`.
# =============================================================================

@test "preset-detect: depFiles signal matches when path exists in a subdirectory (friction #8)" {
    make_synthetic_preset "iac" '{"combinator":"anyOf","depFiles":[{"path":"versions.tf","contains":"bpg/proxmox"}]}'
    # Mimic the real-world pve-home layout: Terraform code under
    # infrastructure/proxmox/, NOT at the project root.
    mkdir -p "$TEST_DIR/proj/infrastructure/proxmox"
    echo 'proxmox = { source = "bpg/proxmox" }' > "$TEST_DIR/proj/infrastructure/proxmox/versions.tf"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"iac"* ]]
}

@test "preset-detect: depFiles signal still matches when path exists at root (regression for friction #8)" {
    make_synthetic_preset "iac" '{"combinator":"anyOf","depFiles":[{"path":"versions.tf","contains":"bpg/proxmox"}]}'
    echo 'proxmox = { source = "bpg/proxmox" }' > "$TEST_DIR/proj/versions.tf"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"iac"* ]]
}

@test "preset-detect: depFiles signal does NOT match when subdir file lacks expected content (friction #8)" {
    make_synthetic_preset "iac" '{"combinator":"anyOf","depFiles":[{"path":"versions.tf","contains":"bpg/proxmox"}]}'
    mkdir -p "$TEST_DIR/proj/infrastructure/proxmox"
    # Wrong provider (aws not proxmox) → must not match
    echo 'aws = { source = "hashicorp/aws" }' > "$TEST_DIR/proj/infrastructure/proxmox/versions.tf"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"iac"* ]]
}

# =============================================================================
# Combinator semantics
# =============================================================================

@test "preset-detect: allOf does NOT match when one signal misses" {
    make_synthetic_preset "strict" '{"combinator":"allOf","files":["a.cfg","b.cfg"]}'
    touch "$TEST_DIR/proj/a.cfg"
    # b.cfg missing
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"strict"* ]]
}

@test "preset-detect: allOf matches when every signal matches" {
    make_synthetic_preset "strict" '{"combinator":"allOf","files":["a.cfg","b.cfg"]}'
    touch "$TEST_DIR/proj/a.cfg" "$TEST_DIR/proj/b.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"strict"* ]]
}

@test "preset-detect: anyOf matches when at least one signal matches" {
    make_synthetic_preset "loose" '{"combinator":"anyOf","files":["a.cfg","b.cfg","c.cfg"]}'
    touch "$TEST_DIR/proj/b.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"loose"* ]]
}

@test "preset-detect: combinator defaults to anyOf when omitted" {
    make_synthetic_preset "implicit" '{"files":["x.cfg"]}'
    touch "$TEST_DIR/proj/x.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"implicit"* ]]
}

# =============================================================================
# Edge cases
# =============================================================================

@test "preset-detect: empty target directory yields no matches" {
    make_synthetic_preset "alpha" '{"combinator":"anyOf","files":["alpha.cfg"]}'
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "preset-detect: preset without detect block is silent (never matched)" {
    cat > "$TEST_DIR/presets-dir/no-detect.json" <<'EOF'
{
  "name": "no-detect",
  "displayName": "No Detect",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": []
}
EOF
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"no-detect"* ]]
}

@test "preset-detect: malformed detect block in one preset does not break the scan" {
    # detect is a string, not an object → malformed.
    cat > "$TEST_DIR/presets-dir/broken.json" <<'EOF'
{
  "name": "broken",
  "displayName": "Broken",
  "description": "x",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": true, "hooks": true, "mcp": false, "docker": false},
  "outOfScope": [],
  "detect": "this is not an object"
}
EOF
    make_synthetic_preset "good" '{"files":["mark.cfg"]}'
    touch "$TEST_DIR/proj/mark.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"good"* ]]
    [[ "$output" != *"broken"* ]]
}

@test "preset-detect: deterministic alphabetical output order" {
    make_synthetic_preset "zeta" '{"files":["mark.cfg"]}'
    make_synthetic_preset "alpha" '{"files":["mark.cfg"]}'
    make_synthetic_preset "mu" '{"files":["mark.cfg"]}'
    touch "$TEST_DIR/proj/mark.cfg"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    # Expected output lines: alpha, mu, zeta in that order.
    local first second third
    first=$(echo "$output" | sed -n '1p')
    second=$(echo "$output" | sed -n '2p')
    third=$(echo "$output" | sed -n '3p')
    [ "$first" = "alpha" ]
    [ "$second" = "mu" ]
    [ "$third" = "zeta" ]
}

@test "preset-detect: gracefully exits when the lib's jq check is wired" {
    # Code-level guard: the library MUST short-circuit when jq is unavailable.
    # We verify the guard exists rather than simulating jq absence at runtime
    # (which is brittle to stage cleanly in CI).
    grep -qE 'command -v jq.*return 0' "$PRESET_DETECT_LIB"
}

@test "preset-detect: missing target directory yields no matches" {
    make_synthetic_preset "alpha" '{"files":["alpha.cfg"]}'
    run scan_in_temp "$TEST_DIR/does-not-exist"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# US-2 zero-code property: dropping a brand-new preset .json is enough to
# expand detection coverage. No other file should need to change.
# =============================================================================

@test "preset-detect: a brand-new preset is discovered without any code change (US-2)" {
    # Drop a preset name that does not exist anywhere else in the codebase.
    make_synthetic_preset "made-up-stack" '{"files":["made-up.marker"]}'
    touch "$TEST_DIR/proj/made-up.marker"
    run scan_in_temp "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"made-up-stack"* ]]
}

# =============================================================================
# US-2 Phase 3: react-vite-spa shipped detection rule vs fixtures
# Tests use the official .claude/presets/ dir (PRESETS_DIR=$BASE_DIR/.claude/presets)
# so they exercise the SHIPPED allOf rule (files + depFiles) end-to-end.
# =============================================================================

# Helper: invoke scan_presets against the official presets dir.
scan_official() {
    local target="$1"
    bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$PRESET_DETECT_LIB'
        PRESETS_DIR='$BASE_DIR/.claude/presets' scan_presets '$target'
    "
}

@test "preset-detect: react-vite-spa fixture matches react-vite-spa (T027)" {
    # The fixture must satisfy allOf: vite.config.ts present AND package.json
    # contains "react-router-dom". Both signals must be present.
    local fixture="$BASE_DIR/tests/presets-fixtures/react-vite-spa"
    run scan_official "$fixture"
    [ "$status" -eq 0 ]
    [[ "$output" == *"react-vite-spa"* ]]
}

@test "preset-detect: astro fixture does NOT match react-vite-spa (T028)" {
    # The astro fixture has no vite.config.* and no package.json with
    # react-router-dom, so the allOf check fails on both signals.
    local fixture="$BASE_DIR/tests/presets-fixtures/astro"
    run scan_official "$fixture"
    [ "$status" -eq 0 ]
    [[ "$output" != *"react-vite-spa"* ]]
}

@test "preset-detect: nextjs fixture does NOT match react-vite-spa (T029)" {
    # The nextjs fixture has next.config.js and package.json with "next" dep
    # but no vite.config.* — the files signal of allOf fails.
    local fixture="$BASE_DIR/tests/presets-fixtures/nextjs"
    run scan_official "$fixture"
    [ "$status" -eq 0 ]
    [[ "$output" != *"react-vite-spa"* ]]
}

@test "preset-detect: react-vite-spa drift-guard — missing react-router-dom breaks match (T030)" {
    # Copy the react-vite-spa fixture to a writable temp dir, strip
    # react-router-dom from package.json, and verify that the preset no
    # longer matches (the depFiles signal is load-bearing in the allOf).
    cp -r "$BASE_DIR/tests/presets-fixtures/react-vite-spa/." "$TEST_DIR/proj/"
    # Remove the react-router-dom entry from dependencies.
    jq 'del(.dependencies["react-router-dom"])' "$TEST_DIR/proj/package.json" \
        > "$TEST_DIR/proj/package.json.tmp"
    mv "$TEST_DIR/proj/package.json.tmp" "$TEST_DIR/proj/package.json"
    run scan_official "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"react-vite-spa"* ]]
}

@test "preset-detect: react-vite-spa matches a real-world project with a single vite.config.ts (T030b)" {
    # Regression guard against treating each entry in detect.files[] as an
    # independent allOf signal. Real projects ship ONE vite.config.* (TS or JS
    # or MJS), never the three at once. The detect rule must use a glob so the
    # files signal is "any vite.config.* exists", not "all three exist".
    cat > "$TEST_DIR/proj/vite.config.ts" <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({});
EOF
    cat > "$TEST_DIR/proj/package.json" <<'EOF'
{
  "name": "real-world-spa",
  "version": "0.0.0",
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.0.0",
    "vite": "^5.0.0"
  }
}
EOF
    run scan_official "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"react-vite-spa"* ]]
}

@test "preset-detect: react-vite-spa matches a real-world project with a single vite.config.js (T030c)" {
    # Same regression guard but with the .js variant — confirms the glob covers
    # every documented extension, not just .ts.
    cat > "$TEST_DIR/proj/vite.config.js" <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({});
EOF
    cat > "$TEST_DIR/proj/package.json" <<'EOF'
{
  "name": "real-world-spa-js",
  "version": "0.0.0",
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.0.0",
    "vite": "^5.0.0"
  }
}
EOF
    run scan_official "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"react-vite-spa"* ]]
}

# =============================================================================
# US-6 Phase 7: multi-match disambiguation — hybrid project
# A project satisfying BOTH nextjs and react-vite-spa detect rules must
# surface both preset names so the caller can prompt for disambiguation.
# =============================================================================

@test "preset-detect: hybrid project matches both nextjs and react-vite-spa (T043)" {
    # Build a hybrid fixture inline (not a permanent fixture under presets-fixtures/).
    # nextjs detect: anyOf → next.config.js present OR package.json contains "next"
    # react-vite-spa detect: allOf → vite.config.* present AND package.json contains "react-router-dom"
    cat > "$TEST_DIR/proj/vite.config.ts" <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({});
EOF
    cat > "$TEST_DIR/proj/next.config.js" <<'EOF'
module.exports = {};
EOF
    cat > "$TEST_DIR/proj/package.json" <<'EOF'
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
    run scan_official "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"react-vite-spa"* ]]
}
