#!/usr/bin/env bats

# =============================================================================
# Tests for the recommendation-drift helpers (US-9, specs/marketplace-curation-engine).
#
# When a project bootstrapped with a preset is updated, the preset's
# recommendedVendorSkills set may have changed (added / removed / re-pinned).
# These helpers snapshot the set into the project manifest (.claude/foundation.json)
# and diff the current preset against that snapshot so the change is surfaced as a
# TRACKED change on update, not a silent drift. Pure (jq-only), offline.
# =============================================================================

load 'test_helper'

LIB="$BATS_TEST_DIRNAME/../scripts/lib/preset-recommendations.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/.claude"
}
teardown() { teardown_test_dir; }

# preset_file <json> — write a preset file and echo its path.
preset_file() { printf '%s' "$1" > "$TEST_DIR/preset.json"; echo "$TEST_DIR/preset.json"; }

# manifest <recommendations-json-or-empty> — write foundation.json with an
# optional .recommendations snapshot.
manifest() {
    if [ -n "${1:-}" ]; then
        jq -cn --argjson r "$1" '{version:"1.0.0", preset:"nextjs", modules:[], recommendations:$r}' > "$TEST_DIR/.claude/foundation.json"
    else
        jq -cn '{version:"1.0.0", preset:"nextjs", modules:[]}' > "$TEST_DIR/.claude/foundation.json"
    fi
}

rec() { # rec <id> <pinnedRef> → one recommendedVendorSkills entry
    jq -cn --arg id "$1" --arg p "$2" '{id:$id, url:("https://github.com/"+$id), rationale:"r", condition:"always", pinnedRef:$p}'
}
preset_with() { # preset_with <entry...> → preset JSON with those recs
    local items; items=$(printf '%s\n' "$@" | jq -s '.')
    jq -cn --argjson r "$items" '{name:"nextjs", recommendedVendorSkills:$r}'
}

call() { run env bash -c "source '$LIB'; $*"; }

# =============================================================================
# snapshot
# =============================================================================

@test "snapshot: extracts {id,pinnedRef} sorted by id" {
    local pf; pf=$(preset_file "$(preset_with "$(rec b/two v2)" "$(rec a/one v1)")")
    call "recommendations_snapshot_from_preset '$pf'"
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.[0].id')" == "a/one" ]]
    [[ "$(printf '%s' "$output" | jq -r '.[1].id')" == "b/two" ]]
    [[ "$(printf '%s' "$output" | jq -r '.[0].pinnedRef')" == "v1" ]]
}

@test "snapshot: empty for a preset with no recommendations" {
    local pf; pf=$(preset_file '{"name":"x"}')
    call "recommendations_snapshot_from_preset '$pf'"
    [[ "$(printf '%s' "$output" | jq -r 'length')" -eq 0 ]]
}

# =============================================================================
# drift: added / removed / repinned / none / first-run
# =============================================================================

@test "drift: no prior snapshot (first run) → empty (no false drift)" {
    manifest ""   # manifest without .recommendations
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "drift: unchanged set → empty" {
    manifest "$(jq -cn '[{id:"a/one",pinnedRef:"v1"}]')"
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ -z "$output" ]]
}

@test "drift: a newly-added recommendation is reported" {
    manifest "$(jq -cn '[{id:"a/one",pinnedRef:"v1"}]')"
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)" "$(rec b/new v9)")")
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ "$output" == *"+ added: b/new @ v9"* ]]
}

@test "drift: a removed recommendation is reported" {
    manifest "$(jq -cn '[{id:"a/one",pinnedRef:"v1"},{id:"b/gone",pinnedRef:"v2"}]')"
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ "$output" == *"- removed: b/gone"* ]]
}

@test "drift: a re-pinned recommendation is reported with old → new" {
    manifest "$(jq -cn '[{id:"a/one",pinnedRef:"v1"}]')"
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v2)")")
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ "$output" == *"~ repinned: a/one v1"* ]]
    [[ "$output" == *"v2"* ]]
}

# =============================================================================
# record: persists into the manifest, preserves other fields
# =============================================================================

@test "record: writes the snapshot into foundation.json, preserving version/preset/modules" {
    manifest ""
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "record_recommendations_snapshot '$pf' '$TEST_DIR'"
    [[ "$status" -eq 0 ]]
    [[ "$(jq -r '.recommendations[0].id' "$TEST_DIR/.claude/foundation.json")" == "a/one" ]]
    [[ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" == "1.0.0" ]]
    [[ "$(jq -r '.preset' "$TEST_DIR/.claude/foundation.json")" == "nextjs" ]]
}

@test "record: no manifest → no-op (does not create one)" {
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "record_recommendations_snapshot '$pf' '$TEST_DIR'"
    [[ "$status" -eq 0 ]]
    [ ! -f "$TEST_DIR/.claude/foundation.json" ]
}

@test "drift then record round-trip: after recording, drift is empty next run" {
    manifest ""
    local pf; pf=$(preset_file "$(preset_with "$(rec a/one v1)")")
    call "record_recommendations_snapshot '$pf' '$TEST_DIR'"
    call "recommendation_drift '$pf' '$TEST_DIR'"
    [[ -z "$output" ]]
}
