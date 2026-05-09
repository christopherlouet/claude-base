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
