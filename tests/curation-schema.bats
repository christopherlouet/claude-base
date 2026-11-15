#!/usr/bin/env bats

# =============================================================================
# Tests for the curation-engine schema additions to scripts/validate-presets.sh
#
# Slice 1 of specs/marketplace-curation-engine adds, to every
# recommendedVendorSkills[] entry, four mandatory fields:
#   - pinnedRef    : immutable ref (tag / full SHA); floating refs rejected (EF-005)
#   - trustTrack   : authority | community (EF-003)
#   - provenance   : disclosed publisher (EF-008)
#   - lastVerified : ISO date
# and introduces a canonicalVendor registry (.claude/curation/registry.json)
# validated via `--registry <file>` (EF-001).
#
# Each test writes a minimal fixture into $TEST_DIR and mutates one field at a
# time (AAA / one-logical-assertion discipline). gh is never called — these are
# pure shape/format checks, fully offline and deterministic.
# =============================================================================

load 'test_helper'

VALIDATE_PRESETS="$BATS_TEST_DIRNAME/../scripts/validate-presets.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# A baseline VALID maintainer-vouched manifest carrying ONE fully-formed
# recommendedVendorSkills entry. Tests mutate the entry via jq.
write_manifest_with_vendor() {
    cat > "$1" <<'EOF'
{
  "name": "test-stack",
  "displayName": "Test stack",
  "description": "A test manifest with one vendor recommendation.",
  "version": "1.0.0",
  "status": "maintainer-vouched",
  "appliesToTypes": ["generic"],
  "defaults": {
    "ci": true,
    "hooks": true,
    "mcp": false,
    "docker": false,
    "designStyle": "terminal"
  },
  "foundation": {},
  "marketplacePlugins": [],
  "recommendedVendorSkills": [
    {
      "id": "acme/skills",
      "url": "https://github.com/acme/skills",
      "rationale": "Canonical Acme patterns.",
      "condition": "always",
      "pinnedRef": "v1.2.3",
      "trustTrack": "authority",
      "provenance": "Acme",
      "lastVerified": "2026-06-13"
    }
  ],
  "outOfScope": []
}
EOF
}

# A baseline VALID registry with one record. Tests mutate via jq.
write_valid_registry() {
    cat > "$1" <<'EOF'
{
  "version": "1.0.0",
  "records": [
    {
      "foundationSkill": "dev-graphql",
      "vendorId": "apollographql/skills",
      "vendorUrl": "https://github.com/apollographql/skills",
      "pinnedRef": "v1.2.5",
      "trustTrack": "authority",
      "trustVerdict": "pass",
      "provenance": "Apollo GraphQL",
      "adviceNeutrality": "pass",
      "lastVerified": "2026-06-13",
      "status": "candidate",
      "sourceAudit": "dev-skills-pilot-2026-05-05",
      "flags": []
    }
  ]
}
EOF
}

mutate() { # mutate <file> <jq-program>
    local f="$1" prog="$2"
    jq "$prog" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

# =============================================================================
# recommendedVendorSkills — new mandatory fields (happy path)
# =============================================================================

@test "validate-presets.sh accepts a recommendation carrying all curation fields" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh accepts a recommendation pinned to a full commit SHA" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "a969c9a73e8a7a12f4002372ab41650d25d8beb6"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# pinnedRef — mandatory + immutable (EF-005)
# =============================================================================

@test "validate-presets.sh rejects a recommendation missing pinnedRef (EF-005)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" 'del(.recommendedVendorSkills[0].pinnedRef)'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh rejects pinnedRef set to the floating ref 'latest' (EF-005)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "latest"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh rejects pinnedRef set to a branch name 'main' (EF-005)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "main"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

# =============================================================================
# trustTrack — enum authority | community (EF-003)
# =============================================================================

@test "validate-presets.sh rejects a recommendation missing trustTrack" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" 'del(.recommendedVendorSkills[0].trustTrack)'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"trustTrack"* ]]
}

@test "validate-presets.sh rejects an unknown trustTrack value" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].trustTrack = "vendor"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"trustTrack"* ]]
}

@test "validate-presets.sh accepts trustTrack 'community'" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].trustTrack = "community"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# provenance — mandatory (EF-008)
# =============================================================================

@test "validate-presets.sh rejects a recommendation missing provenance" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" 'del(.recommendedVendorSkills[0].provenance)'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"provenance"* ]]
}

# =============================================================================
# lastVerified — ISO date
# =============================================================================

@test "validate-presets.sh rejects a recommendation missing lastVerified" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" 'del(.recommendedVendorSkills[0].lastVerified)'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"lastVerified"* ]]
}

@test "validate-presets.sh rejects a malformed lastVerified date" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].lastVerified = "13-06-2026"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"lastVerified"* ]]
}

# An empty recommendedVendorSkills array stays valid (no entries to pin).
@test "validate-presets.sh accepts an empty recommendedVendorSkills array" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills = []'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# registry — --registry <file> (EF-001)
# =============================================================================

@test "validate-presets.sh accepts a valid registry via --registry" {
    write_valid_registry "$TEST_DIR/registry.json"
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh validates the real shipped registry" {
    run "$VALIDATE_PRESETS" --registry "$BATS_TEST_DIRNAME/../.claude/curation/registry.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh rejects a registry that is not valid JSON" {
    echo '{ broken' > "$TEST_DIR/registry.json"
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
}

@test "validate-presets.sh rejects a registry whose records is not an array" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records = {}'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"records"* ]]
}

@test "validate-presets.sh rejects a registry record missing foundationSkill" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].foundationSkill)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"foundationSkill"* ]]
}

@test "validate-presets.sh rejects a registry record missing pinnedRef (EF-005)" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].pinnedRef)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh rejects a registry record with a floating pinnedRef (EF-005)" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].pinnedRef = "latest"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh rejects a registry record with an unknown trustTrack" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].trustTrack = "vendor"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"trustTrack"* ]]
}

@test "validate-presets.sh rejects a registry record with an unknown status" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].status = "retired"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"status"* ]]
}

@test "validate-presets.sh rejects a registry record with a malformed lastVerified" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].lastVerified = "2026/06/13"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"lastVerified"* ]]
}

@test "validate-presets.sh rejects a registry record with an out-of-range lastVerified" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].lastVerified = "9999-99-99"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"lastVerified"* ]]
}

@test "validate-presets.sh rejects a registry record missing vendorId" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].vendorId)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"vendorId"* ]]
}

@test "validate-presets.sh rejects a registry record missing provenance" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].provenance)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"provenance"* ]]
}

@test "validate-presets.sh rejects a registry record missing trustVerdict" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].trustVerdict)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"trustVerdict"* ]]
}

@test "validate-presets.sh rejects a registry record with an unknown trustVerdict" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].trustVerdict = "maybe"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"trustVerdict"* ]]
}

@test "validate-presets.sh rejects a registry record missing adviceNeutrality" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].adviceNeutrality)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"adviceNeutrality"* ]]
}

@test "validate-presets.sh rejects a registry record with an unknown adviceNeutrality" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].adviceNeutrality = "biased"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"adviceNeutrality"* ]]
}

@test "validate-presets.sh accepts a registry with an empty records array" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records = []'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# pinnedRef — floating aliases rejected case-insensitively (EF-005 shape guard).
# The guard is deliberately conservative: it rejects the universal floating
# aliases only; tag-vs-branch for ambiguous names is resolved later by the gh
# scorer (Slice 2), so an ambiguous `release-2.x` is ACCEPTED at shape level.
# =============================================================================

@test "validate-presets.sh rejects an uppercase floating alias pinnedRef (MAIN)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "MAIN"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh rejects a mixed-case floating alias pinnedRef in a registry record (HEAD)" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" '.records[0].pinnedRef = "Head"'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"pinnedRef"* ]]
}

@test "validate-presets.sh accepts a name@version tag pinnedRef (e.g. shadcn@4.11.0)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "shadcn@4.11.0"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh accepts an immutable tag whose name starts with a branch word (release-1.0.0)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "release-1.0.0"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh accepts an ambiguous ref at shape level (deferred to the gh scorer)" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills[0].pinnedRef = "release-2.x"'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# --registry argument handling
# =============================================================================

@test "validate-presets.sh rejects --registry combined with a positional preset file" {
    write_valid_registry "$TEST_DIR/registry.json"
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 2 ]]
    [[ "$output" == *"--registry"* ]]
}

@test "validate-presets.sh errors when --registry has no path" {
    run "$VALIDATE_PRESETS" --registry
    [[ "$status" -eq 2 ]]
}

# =============================================================================
# Coverage for enforced-but-previously-untested branches
# =============================================================================

@test "validate-presets.sh rejects recommendedVendorSkills when it is not an array" {
    write_manifest_with_vendor "$TEST_DIR/test-stack.json"
    mutate "$TEST_DIR/test-stack.json" '.recommendedVendorSkills = {}'
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"recommendedVendorSkills"* ]]
}

@test "validate-presets.sh rejects a registry record missing vendorUrl" {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" 'del(.records[0].vendorUrl)'
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"vendorUrl"* ]]
}

# Default mode (no args) validates the shipped presets AND the shipped registry,
# exercising the full-dir registry coupling (registry_fail wiring).
@test "validate-presets.sh default run validates presets and the shipped registry" {
    run "$VALIDATE_PRESETS"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"registry"* ]]
}

# =============================================================================
# Monorepo pins (#670): a record whose subpath is pinned to ANOTHER package's
# tag fails the registry pass, however the record arrived (discovery, an older
# digest, by hand). The tag names a package (`@scope/pkg@1.0.0`, `pkg@1.0.0`)
# or a release-please component (`pkg-v1.2.0`); it must match a segment of the
# subpath that is not a generic directory name, or the repo's own name. A
# commit SHA is never checked: it is the way out for any pin this gets wrong.
# =============================================================================

# pin_record <vendorId> <pinnedRef> — the valid registry, one record re-pinned.
pin_record() {
    write_valid_registry "$TEST_DIR/registry.json"
    mutate "$TEST_DIR/registry.json" \
        ".records[0].vendorId = \"$1\" | .records[0].vendorUrl = \"https://github.com/${1%%/*}\" | .records[0].pinnedRef = \"$2\""
    run "$VALIDATE_PRESETS" --registry "$TEST_DIR/registry.json"
}

@test "validate-presets.sh rejects a subpath pinned to another package's tag (#670)" {
    pin_record "acme/mono/packages/alpha/skills" "@acme/beta@3.0.0"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"tag of another package"* ]]
}

@test "validate-presets.sh rejects a subpath pinned to another release-please component (#670)" {
    pin_record "acme/mono/packages/alpha/skills" "gamma-v1.2.0"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"tag of another package"* ]]
}

@test "validate-presets.sh rejects a package matched only by a generic segment (#670)" {
    # packages/core/skills is core's; @acme/skills is a sibling package.
    pin_record "acme/mono/packages/core/skills" "@acme/skills@2.0.0"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"tag of another package"* ]]
}

@test "validate-presets.sh control - real registry shapes pass the pin check" {
    pin_record "shadcn-ui/ui/skills/shadcn" "shadcn@4.23.0"
    [[ "$status" -eq 0 ]] || false
    pin_record "ChromeDevTools/chrome-devtools-mcp/skills" "chrome-devtools-mcp-v1.12.0"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/tool/skills" "tool@2.0.0"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/packages/Alpha/skills" "@acme/alpha@1.5.0"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/packages/alpha/skills" "alpha-v1.5.0"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh control - SHA, plain version and whole-repo pins are not checked" {
    pin_record "acme/mono/packages/alpha/skills" "1a2c79d4e6c4a2283dc2c614b6538cbe1ed5ca62"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/packages/alpha/skills" "v2.14.10"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/packages/alpha/skills" "release-1.2.3"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono" "@acme/beta@3.0.0"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh control - a component is cut at the FIRST version, not a later one" {
    pin_record "acme/mono/x/foo" "foo-v1.0.0-beta-2.1"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/x/foo" "foo-1.0.0-1.2"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh control - a semver whose pre-release looks like a version is a plain version" {
    local t
    for t in 1.0.0-0.3.7 v2.1.0-1.0 v1.0.0-rc-1.2; do
        pin_record "acme/mono/skills/foo" "$t"
        [[ "$status" -eq 0 ]] || { echo "flagged: $t"; false; }
    done
}

@test "validate-presets.sh rejects an npm package named like a channel when it is another package's (#670)" {
    # The channel words skip dash tags only: next@15.0.0 names a package.
    pin_record "vercel/next.js/packages/create-next-app" "next@15.0.0"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"tag of another package"* ]]
}

@test "validate-presets.sh a capital V version still reads the component" {
    pin_record "acme/mono/packages/alpha/skills" "gamma-V1.2.0"
    [[ "$status" -eq 1 ]]
}

@test "validate-presets.sh control - odd shapes do not block (a--v1.2, empty subpath pieces)" {
    pin_record "acme/mono/a" "a--v1.2"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/a+" "a-v1.2"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh control - channel prefixes name no component" {
    local t
    for t in stable-1.2 nightly-1.2.3 latest-1.0 releases-v1.2.3 beta-2.0.0 canary-1.0.0; do
        pin_record "acme/mono/packages/alpha/skills" "$t"
        [[ "$status" -eq 0 ]] || { echo "flagged: $t"; false; }
    done
}

@test "validate-presets.sh control - a package named after a generic folder passes when it is the path's only name" {
    pin_record "acme/mono/packages/skills" "@acme/skills@1.0.0"
    [[ "$status" -eq 0 ]] || false
    pin_record "acme/mono/skills" "skills-v1.2.0"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh control - underscore and dash are the same in a package name" {
    pin_record "acme/mono/packages/foo-bar" "foo_bar-v1.0.0"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh the failure names the SHA way out" {
    pin_record "acme/mono/packages/alpha/skills" "@acme/beta@3.0.0"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"or a commit"* ]]
}

@test "validate-presets.sh control - a multi-subpath record matches on any of its subpaths" {
    pin_record "acme/mono/packages/alpha/skills+packages/beta/skills" "@acme/beta@3.0.0"
    [[ "$status" -eq 0 ]]
}
