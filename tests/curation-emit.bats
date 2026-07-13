#!/usr/bin/env bats

# Tests for emit_issue (scripts/lib/curation-emit.sh) — the idempotent digest
# emission. With a dedupe-key it must UPDATE the one rolling issue (marker in the
# body) instead of opening a duplicate every run (the digest-dup bug). Without a
# key it stays legacy create-only. Fully offline: a fake `gh` logs calls and
# returns a configurable existing-issue number.

load 'test_helper'

EMIT="$BATS_TEST_DIRNAME/../scripts/lib/curation-emit.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/fakebin"
    export CURATION_GH_REPO="owner/repo"   # skip git-remote resolution
    cat > "$TEST_DIR/fakebin/gh" <<EOF
#!/usr/bin/env bash
echo "gh \$*" >> "$TEST_DIR/gh.log"
prev=""
for a in "\$@"; do
  [ "\$prev" = "--body-file" ] && cat "\$a" >> "$TEST_DIR/body.cap" 2>/dev/null
  prev="\$a"
done
case "\$*" in
  *"issue list"*) printf '%s' "\${FAKE_EXISTING:-}" ;;
  *"pr list"*) printf '%s' "\${FAKE_REPIN_OPEN:-1}" ;;
esac
exit 0
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
    printf 'digest body\n' > "$TEST_DIR/body.md"
}
teardown() { teardown_test_dir; }

@test "emit_issue updates the existing rolling issue (no duplicate create)" {
    source "$EMIT"
    FAKE_EXISTING=42 PATH="$TEST_DIR/fakebin:$PATH" emit_issue "Curation digest — 2026-06-28" "$TEST_DIR/body.md" "watch-digest"
    grep -q "issue edit 42" "$TEST_DIR/gh.log"
    ! grep -q "issue create" "$TEST_DIR/gh.log"
}

@test "emit_issue creates when no rolling issue exists yet" {
    source "$EMIT"
    FAKE_EXISTING="" PATH="$TEST_DIR/fakebin:$PATH" emit_issue "Curation digest — 2026-06-28" "$TEST_DIR/body.md" "watch-digest"
    grep -q "issue create" "$TEST_DIR/gh.log"
    ! grep -q "issue edit" "$TEST_DIR/gh.log"
}

@test "emit_issue embeds the dedupe marker in the emitted body" {
    source "$EMIT"
    FAKE_EXISTING="" PATH="$TEST_DIR/fakebin:$PATH" emit_issue "t" "$TEST_DIR/body.md" "watch-digest"
    grep -q "curation-issue:watch-digest" "$TEST_DIR/body.cap"
}

@test "emit_issue without a key is create-only (legacy, no list lookup)" {
    source "$EMIT"
    PATH="$TEST_DIR/fakebin:$PATH" emit_issue "t" "$TEST_DIR/body.md"
    grep -q "issue create" "$TEST_DIR/gh.log"
    ! grep -q "issue list" "$TEST_DIR/gh.log"
}

# =============================================================================
# _repin_apply — marketplace preset entries (2026-07-12 audit, cluster C7).
# A marketplace plugin's preset copy carries a NON-github url (claude.com/...)
# that the github repo-root matcher can never match, while the pin-lockstep gate
# (validate-presets.sh) DOES couple the registry and preset pins by marketplace
# key. Without the mktkey match, every real drift of such a plugin emits a
# registry-only re-pin PR that fails its own lockstep CI — guaranteed red.
# =============================================================================

# mkt_registry <pin> — a registry whose single record is a marketplace plugin
# (vendorId subpathed under the marketplace repo, vendorUrl on claude.com).
mkt_registry() {
    jq -cn --arg p "$1" '{version:"1.0.0", records:[
        {foundationSkill:"dev-frontend-design",
         vendorId:"anthropics/claude-code/plugins/frontend-design",
         vendorUrl:"https://claude.com/plugins/frontend-design",
         pinnedRef:$p, trustTrack:"authority", trustVerdict:"pass",
         provenance:"Anthropic", adviceNeutrality:"pass",
         lastVerified:"2026-01-01", status:"candidate"}]}' \
        > "$TEST_DIR/registry.json"
}

@test "_repin_apply re-pins a marketplace preset entry via the registry marketplace key" {
    source "$EMIT"
    mkdir -p "$TEST_DIR/presets"
    mkt_registry "oldsha1111111111111111111111111111111111"
    jq -cn '{recommendedVendorSkills:[
        {id:"frontend-design@claude-plugins-official",
         url:"https://claude.com/plugins/frontend-design",
         pinnedRef:"oldsha1111111111111111111111111111111111", lastVerified:"2026-01-01"}]}' \
        > "$TEST_DIR/presets/nextjs.json"
    _repin_apply "$TEST_DIR/registry.json" "$TEST_DIR/presets" \
        "anthropics/claude-code" "newsha2222222222222222222222222222222222" "2026-07-13"
    [ "$(jq -r '.records[0].pinnedRef' "$TEST_DIR/registry.json")" = "newsha2222222222222222222222222222222222" ]
    [ "$(jq -r '.recommendedVendorSkills[0].pinnedRef' "$TEST_DIR/presets/nextjs.json")" = "newsha2222222222222222222222222222222222" ]
    [ "$(jq -r '.recommendedVendorSkills[0].lastVerified' "$TEST_DIR/presets/nextjs.json")" = "2026-07-13" ]
}

@test "_repin_apply leaves an UNRELATED marketplace entry untouched (exact key, no substring)" {
    source "$EMIT"
    mkdir -p "$TEST_DIR/presets"
    mkt_registry "oldsha"
    jq -cn '{recommendedVendorSkills:[
        {id:"frontend-design@claude-plugins-official",
         url:"https://claude.com/plugins/frontend-design",
         pinnedRef:"oldsha", lastVerified:"2026-01-01"},
        {id:"other@claude-plugins-official",
         url:"https://claude.com/plugins/frontend-design-pro",
         pinnedRef:"keepme", lastVerified:"2026-01-01"},
        {id:"acme/github-skill",
         url:"https://github.com/acme/github-skill",
         pinnedRef:"keepme", lastVerified:"2026-01-01"}]}' \
        > "$TEST_DIR/presets/mixed.json"
    _repin_apply "$TEST_DIR/registry.json" "$TEST_DIR/presets" \
        "anthropics/claude-code" "newsha" "2026-07-13"
    [ "$(jq -r '.recommendedVendorSkills[0].pinnedRef' "$TEST_DIR/presets/mixed.json")" = "newsha" ]
    [ "$(jq -r '.recommendedVendorSkills[1].pinnedRef' "$TEST_DIR/presets/mixed.json")" = "keepme" ]
    [ "$(jq -r '.recommendedVendorSkills[2].pinnedRef' "$TEST_DIR/presets/mixed.json")" = "keepme" ]
}

@test "_repin_apply still re-pins a github preset entry by repo-root (regression, registry absent)" {
    source "$EMIT"
    mkdir -p "$TEST_DIR/presets"
    jq -cn '{recommendedVendorSkills:[
        {id:"acme/skill", url:"https://github.com/acme/skill",
         pinnedRef:"v1.0.0", lastVerified:"2026-01-01"}]}' \
        > "$TEST_DIR/presets/gh.json"
    _repin_apply "$TEST_DIR/no-registry.json" "$TEST_DIR/presets" "acme/skill" "v1.2.0" "2026-07-13"
    [ "$(jq -r '.recommendedVendorSkills[0].pinnedRef' "$TEST_DIR/presets/gh.json")" = "v1.2.0" ]
}

# =============================================================================
# emit_repin_pr — open-PR lock lookup pagination (2026-07-12 audit, cluster C7).
# =============================================================================

@test "emit_repin_pr open-PR lookup passes --limit 100 (default 30 can miss the lock)" {
    source "$EMIT"
    mkdir -p "$TEST_DIR/presets"
    echo '{"version":"1.0.0","records":[]}' > "$TEST_DIR/registry.json"
    local findings='[{"subject":"acme/x","type":"drift","proposedAction":"re-pin","pinnedRef":"v1.0.0","currentRef":"v1.2.0"}]'
    # FAKE_REPIN_OPEN=1 (stub default): the lock is held, so emit_repin_pr stops
    # right after the lookup — no git/branch machinery is ever reached.
    run env PATH="$TEST_DIR/fakebin:$PATH" bash -c \
        "source '$EMIT'; emit_repin_pr '$findings' '$TEST_DIR/registry.json' '$TEST_DIR/presets' true 2026-07-13"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"skipped":"open-pr"'* ]]
    grep 'pr list' "$TEST_DIR/gh.log" | grep -q -- '--limit 100'
}
