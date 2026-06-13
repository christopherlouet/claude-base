#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/curation-watch.sh (Slice 3a, specs/marketplace-curation-engine).
#
# Fully OFFLINE + DETERMINISTIC: `gh` is a fake on PATH that maps each `gh api
# <path>` to a fixture file (missing fixture → exit 1, i.e. a 404 / error), and
# CURATION_NOW pins "today". A tiny throwaway registry + an empty presets dir
# isolate each test to exactly the targets it declares. No network, no LLM.
# =============================================================================

load 'test_helper'

WATCH="$BATS_TEST_DIRNAME/../scripts/curation-watch.sh"
THRESHOLDS="$BATS_TEST_DIRNAME/../.claude/curation/trust-thresholds.json"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/fakebin" "$TEST_DIR/fx" "$TEST_DIR/presets"
    cat > "$TEST_DIR/fakebin/gh" <<EOF
#!/usr/bin/env bash
[ "\$1" = "api" ] || { echo "fake gh: bad call \$*" >&2; exit 1; }
f="$TEST_DIR/fx/\$(printf '%s' "\$2" | tr '/' '_')"
if [ -f "\$f" ]; then cat "\$f"; else echo "fake gh: 404 \$2" >&2; exit 1; fi
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
}

teardown() { teardown_test_dir; }

# gh_fixture <api-path> <json> — register a canned response for `gh api <path>`.
gh_fixture() {
    printf '%s' "$2" > "$TEST_DIR/fx/$(printf '%s' "$1" | tr '/' '_')"
}

# repo_meta <stars> <pushed> <archived> <spdx> — a GitHub repo JSON body.
repo_meta() {
    jq -cn --argjson s "$1" --arg p "$2" --argjson a "$3" --arg l "$4" \
        '{stargazers_count:$s, forks_count:1, pushed_at:$p, archived:$a, license:{spdx_id:$l}}'
}

# registry_one <vendorId> <pinnedRef> <track> — a one-record registry with a
# stale lastVerified (2026-01-01) so refresh is observable.
registry_one() {
    jq -cn --arg v "$1" --arg p "$2" --arg t "$3" '
      {version:"1.0.0", records:[
        {foundationSkill:"x", vendorId:$v, vendorUrl:("https://github.com/"+$v),
         pinnedRef:$p, trustTrack:$t, trustVerdict:"pass", provenance:"Acme",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate",
         sourceAudit:"t", flags:[]}]}' > "$TEST_DIR/registry.json"
}

# run_watch <extra args...> — run the watch offline with "now" pinned.
run_watch() {
    run env PATH="$TEST_DIR/fakebin:$PATH" CURATION_NOW=2026-06-13 \
        CURATION_GH_RETRIES=1 CURATION_GH_BACKOFF=0 CURATION_THRESHOLDS="$THRESHOLDS" \
        bash "$WATCH" --registry "$TEST_DIR/registry.json" --presets-dir "$TEST_DIR/presets" "$@"
}

# =============================================================================
# drift / clean
# =============================================================================

@test "watch: flags content-drift when the current ref moved beyond the pin (re-pin)" {
    registry_one "acme/x" "v1.0.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "drift" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].proposedAction')" == "re-pin" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].currentRef')" == "v1.2.0" ]]
}

@test "watch: a healthy repo still pinned to the current ref produces NO finding (no noise)" {
    registry_one "acme/x" "v1.2.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findingCount')" -eq 0 ]]
}

# =============================================================================
# rot: archived / stale / below-bar
# =============================================================================

@test "watch: flags an archived repo as rot (propose-only)" {
    registry_one "acme/dead" "v1.0.0" authority
    gh_fixture "repos/acme/dead" "$(repo_meta 5000 '2026-06-10T00:00:00Z' true MIT)"
    gh_fixture "repos/acme/dead/releases/latest" '{"tag_name":"v1.0.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "rot" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].verdict')" == "fail" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].proposedAction')" == "propose" ]]
    [[ "$output" == *"archived"* ]]
}

@test "watch: flags an abandoned (stale) repo as rot" {
    registry_one "acme/stale" "v1.0.0" authority
    gh_fixture "repos/acme/stale" "$(repo_meta 5000 '2024-01-01T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/stale/releases/latest" '{"tag_name":"v1.0.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "rot" ]]
    [[ "$output" == *"stale:"* ]]
}

@test "watch: a below-bar community repo is rot (fail) even if still on its pin" {
    registry_one "person/small" "v1.0.0" community
    gh_fixture "repos/person/small" "$(repo_meta 100 '2026-06-10T00:00:00Z' false MIT)"
    gh_fixture "repos/person/small/releases/latest" '{"tag_name":"v1.0.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "rot" ]]
    [[ "$output" == *"below-popularity-bar"* ]]
}

# =============================================================================
# no-noise: a standing soft flag (e.g. missing license) is NOT re-surfaced
# =============================================================================

@test "watch: a healthy repo with a standing soft flag (no license) is NOT surfaced" {
    registry_one "acme/nolicense" "v1.2.0" authority
    gh_fixture "repos/acme/nolicense" "$(repo_meta 82 '2026-06-12T00:00:00Z' false NONE)"
    gh_fixture "repos/acme/nolicense/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findingCount')" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.counts.flag')" -eq 1 ]]
}

# =============================================================================
# fail-safe / SHA pins
# =============================================================================

@test "watch: a gh error becomes an 'error' finding and the run still completes (fail-safe)" {
    registry_one "acme/gone" "v1.0.0" authority
    # No fixtures registered → fake gh returns 404/non-zero for every call.
    run_watch
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "error" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].proposedAction')" == "propose" ]]
    [[ "$output" == *"gh-unavailable"* ]]
}

@test "watch: a SHA-pinned repo drifts when HEAD has advanced" {
    registry_one "acme/sha" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" authority
    gh_fixture "repos/acme/sha" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/sha/commits/HEAD" '{"sha":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].type')" == "drift" ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].currentRef')" == "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" ]]
}

# =============================================================================
# lastVerified idempotent update + --dry-run
# =============================================================================

@test "watch: refreshes lastVerified on the scored record" {
    registry_one "acme/x" "v1.2.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch
    [[ "$(jq -r '.records[0].lastVerified' "$TEST_DIR/registry.json")" == "2026-06-13" ]]
}

@test "watch: --dry-run does NOT touch lastVerified" {
    registry_one "acme/x" "v1.2.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch --dry-run
    [[ "$(jq -r '.records[0].lastVerified' "$TEST_DIR/registry.json")" == "2026-01-01" ]]
}

# =============================================================================
# digest artifact (json + markdown)
# =============================================================================

@test "watch: --digest-dir writes both digest.json and digest.md" {
    registry_one "acme/x" "v1.0.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch --digest-dir "$TEST_DIR/digest"
    [[ "$status" -eq 0 ]]
    [ -f "$TEST_DIR/digest/digest.json" ]
    [ -f "$TEST_DIR/digest/digest.md" ]
    [[ "$(jq -r '.findings[0].type' "$TEST_DIR/digest/digest.json")" == "drift" ]]
    grep -q "acme/x" "$TEST_DIR/digest/digest.md"
}

@test "watch: an all-clean run writes a no-noise markdown digest" {
    registry_one "acme/x" "v1.2.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch --digest-dir "$TEST_DIR/digest"
    grep -q "No rot or drift detected" "$TEST_DIR/digest/digest.md"
}

# =============================================================================
# dedupe
# =============================================================================

@test "watch: --thresholds as the last argument errors cleanly (no hang)" {
    registry_one "acme/x" "v1.0.0" authority
    run timeout 10 env PATH="$TEST_DIR/fakebin:$PATH" \
        bash "$WATCH" --registry "$TEST_DIR/registry.json" --thresholds
    [[ "$status" -eq 2 ]]
}

@test "watch: does NOT refresh lastVerified for a gh-errored (unverified) record" {
    jq -cn '
      {version:"1.0.0", records:[
        {foundationSkill:"ok", vendorId:"acme/ok", vendorUrl:"https://github.com/acme/ok",
         pinnedRef:"v1.0.0", trustTrack:"authority", trustVerdict:"pass", provenance:"A",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]},
        {foundationSkill:"gone", vendorId:"acme/gone", vendorUrl:"https://github.com/acme/gone",
         pinnedRef:"v1.0.0", trustTrack:"authority", trustVerdict:"pass", provenance:"A",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]}]}' \
        > "$TEST_DIR/registry.json"
    # only acme/ok has fixtures; acme/gone gh-errors
    gh_fixture "repos/acme/ok" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/ok/releases/latest" '{"tag_name":"v1.0.0"}'
    run_watch
    [[ "$(jq -r '.records[] | select(.vendorId=="acme/ok").lastVerified' "$TEST_DIR/registry.json")" == "2026-06-13" ]]
    [[ "$(jq -r '.records[] | select(.vendorId=="acme/gone").lastVerified' "$TEST_DIR/registry.json")" == "2026-01-01" ]]
}

@test "watch: a mixed run counts and surfaces the right subset (clean+rot+drift)" {
    jq -cn '
      {version:"1.0.0", records:[
        {foundationSkill:"c", vendorId:"acme/clean", vendorUrl:"https://github.com/acme/clean",
         pinnedRef:"v2.0.0", trustTrack:"authority", trustVerdict:"pass", provenance:"A",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]},
        {foundationSkill:"r", vendorId:"acme/rot", vendorUrl:"https://github.com/acme/rot",
         pinnedRef:"v1.0.0", trustTrack:"authority", trustVerdict:"pass", provenance:"A",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]},
        {foundationSkill:"d", vendorId:"acme/drift", vendorUrl:"https://github.com/acme/drift",
         pinnedRef:"v1.0.0", trustTrack:"authority", trustVerdict:"pass", provenance:"A",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]}]}' \
        > "$TEST_DIR/registry.json"
    gh_fixture "repos/acme/clean" "$(repo_meta 90 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/clean/releases/latest" '{"tag_name":"v2.0.0"}'
    gh_fixture "repos/acme/rot" "$(repo_meta 90 '2026-06-12T00:00:00Z' true MIT)"
    gh_fixture "repos/acme/rot/releases/latest" '{"tag_name":"v1.0.0"}'
    gh_fixture "repos/acme/drift" "$(repo_meta 90 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/drift/releases/latest" '{"tag_name":"v3.0.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.scope.targets')" -eq 3 ]]
    [[ "$(printf '%s' "$output" | jq -r '.counts.clean')" -eq 1 ]]
    [[ "$(printf '%s' "$output" | jq -r '.counts.rot')" -eq 1 ]]
    [[ "$(printf '%s' "$output" | jq -r '.counts.drift')" -eq 1 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findingCount')" -eq 2 ]]
    [[ "$(printf '%s' "$output" | jq -r '[.findings[].type] | sort | join(",")')" == "drift,rot" ]]
}

@test "watch: collects and scores a target sourced from a preset recommendation" {
    echo '{"version":"1.0.0","records":[]}' > "$TEST_DIR/registry.json"
    jq -cn '{name:"p", recommendedVendorSkills:[
        {id:"acme/from-preset", url:"https://github.com/acme/from-preset", rationale:"r",
         condition:"always", pinnedRef:"v1.0.0", trustTrack:"authority", provenance:"A",
         lastVerified:"2026-01-01"}]}' > "$TEST_DIR/presets/p.json"
    gh_fixture "repos/acme/from-preset" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/from-preset/releases/latest" '{"tag_name":"v2.0.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.scope.targets')" -eq 1 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findings[0].subject')" == "acme/from-preset" ]]
}

@test "watch: a tag pin on a repo with NO releases is not falsely flagged as drift" {
    registry_one "acme/notags" "v1.0.0" authority
    gh_fixture "repos/acme/notags" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    # no releases/latest fixture → gh 404 → current ref unresolved → no drift
    run_watch
    [[ "$status" -eq 0 ]]
    [[ "$(printf '%s' "$output" | jq -r '.findingCount')" -eq 0 ]]
}

@test "watch: --digest-dir markdown renders a complete table row for a finding" {
    registry_one "acme/x" "v1.0.0" authority
    gh_fixture "repos/acme/x" "$(repo_meta 82 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/acme/x/releases/latest" '{"tag_name":"v1.2.0"}'
    run_watch --digest-dir "$TEST_DIR/digest"
    grep -qE '^\| acme/x \| drift \| pass \| v1\.0\.0 \| v1\.2\.0 \| re-pin \|$' "$TEST_DIR/digest/digest.md"
}

@test "watch: scores a repo once even when several records share its repo-root" {
    jq -cn '
      {version:"1.0.0", records:[
        {foundationSkill:"a", vendorId:"corey/marketing/cro", vendorUrl:"https://github.com/corey/marketing",
         pinnedRef:"v2.3.0", trustTrack:"community", trustVerdict:"pass", provenance:"C",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]},
        {foundationSkill:"b", vendorId:"corey/marketing/onboarding", vendorUrl:"https://github.com/corey/marketing",
         pinnedRef:"v2.3.0", trustTrack:"community", trustVerdict:"pass", provenance:"C",
         adviceNeutrality:"pass", lastVerified:"2026-01-01", status:"candidate", sourceAudit:"t", flags:[]}]}' \
        > "$TEST_DIR/registry.json"
    gh_fixture "repos/corey/marketing" "$(repo_meta 33000 '2026-06-12T00:00:00Z' false MIT)"
    gh_fixture "repos/corey/marketing/releases/latest" '{"tag_name":"v2.3.0"}'
    run_watch
    [[ "$(printf '%s' "$output" | jq -r '.scope.targets')" -eq 1 ]]
}
