#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/preset-recommendations.sh
# Covers the print function extracted from new-project.sh (T2.1) plus the
# already-installed indicator and install pointers (T3.1, T3.2, T3.3).
# Tests use synthetic preset JSONs in $TEST_DIR so they stay decoupled from
# the official preset content.
# =============================================================================

load 'test_helper'

PRESET_RECO_LIB="$BASE_DIR/scripts/lib/preset-recommendations.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    [ -f "$PRESET_RECO_LIB" ]
    # shellcheck source=/dev/null
    source "$PRESET_RECO_LIB"
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Writes a synthetic preset JSON at $TEST_DIR/preset.json. Caller passes the
# JSON literal as $1.
make_preset() {
    printf '%s\n' "$1" > "$TEST_DIR/preset.json"
}

PRESET_EMPTY='{"name":"empty","recommendedVendorSkills":[]}'

PRESET_ALWAYS_ONLY='{
  "name":"always-only",
  "recommendedVendorSkills":[
    {"id":"vercel-react-best-practices","url":"https://example.com/v","rationale":"Canonical Next.js patterns","condition":"always"}
  ]
}'

PRESET_CONDITIONAL_ONLY='{
  "name":"conditional-only",
  "recommendedVendorSkills":[
    {"id":"prisma-cli","url":"https://example.com/p","rationale":"Prisma CLI patterns","condition":"if using Prisma"}
  ]
}'

PRESET_MIXED='{
  "name":"mixed",
  "recommendedVendorSkills":[
    {"id":"vercel-react-best-practices","url":"https://example.com/v","rationale":"Canonical Next.js patterns","condition":"always"},
    {"id":"prisma-cli","url":"https://example.com/p","rationale":"Prisma CLI patterns","condition":"if using Prisma"}
  ]
}'

# -----------------------------------------------------------------------------
# T2.1 — print_recommended_vendor_skills <preset_file>
# -----------------------------------------------------------------------------

@test "print_recommended_vendor_skills returns 0 with no output when preset_file arg is empty" {
    run print_recommended_vendor_skills ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "print_recommended_vendor_skills returns 0 with no output when preset_file does not exist" {
    run print_recommended_vendor_skills "$TEST_DIR/missing.json"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "print_recommended_vendor_skills returns 0 with no output when recommendedVendorSkills is empty" {
    make_preset "$PRESET_EMPTY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "print_recommended_vendor_skills prints 'Always pair' header when always-recos exist" {
    make_preset "$PRESET_ALWAYS_ONLY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Always pair with this preset:"* ]]
}

@test "print_recommended_vendor_skills prints 'Add if your project uses' header when conditionals exist" {
    make_preset "$PRESET_CONDITIONAL_ONLY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Add if your project uses these tools:"* ]]
}

@test "print_recommended_vendor_skills prints both headers when always + conditional coexist" {
    make_preset "$PRESET_MIXED"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Always pair with this preset:"* ]]
    [[ "$output" == *"Add if your project uses these tools:"* ]]
}

@test "print_recommended_vendor_skills includes id, rationale and url for each item" {
    make_preset "$PRESET_ALWAYS_ONLY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"vercel-react-best-practices"* ]]
    [[ "$output" == *"Canonical Next.js patterns"* ]]
    [[ "$output" == *"https://example.com/v"* ]]
}

@test "print_recommended_vendor_skills surfaces the condition string for conditional items" {
    make_preset "$PRESET_CONDITIONAL_ONLY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"if using Prisma"* ]]
}

@test "print_recommended_vendor_skills closes with the recipe pointer line" {
    make_preset "$PRESET_ALWAYS_ONLY"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"docs/recipes/recommended-vendor-skills.md"* ]]
}

@test "print_recommended_vendor_skills prints always-recos before conditional-recos" {
    make_preset "$PRESET_MIXED"
    run print_recommended_vendor_skills "$TEST_DIR/preset.json"
    [ "$status" -eq 0 ]
    local always_line conditional_line
    always_line=$(printf '%s\n' "$output" | grep -n "Always pair" | cut -d: -f1)
    conditional_line=$(printf '%s\n' "$output" | grep -n "Add if your project uses" | cut -d: -f1)
    [ "$always_line" -lt "$conditional_line" ]
}
