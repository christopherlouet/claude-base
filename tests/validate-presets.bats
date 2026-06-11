#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/validate-presets.sh
#
# The script validates preset JSON manifests against the schema described in
# specs/presets/spec.md (+ specs/presets-vendor-pointer-tier/spec.md for
# vendor-pointer tier semantics). Exit codes :
#   0  every preset valid
#   1  at least one preset invalid
#   2  tooling error (jq missing, presets dir missing, etc.)
#
# Each test writes a minimal manifest into $TEST_DIR and invokes the script
# on the single file. Helper `write_valid_manifest` produces a baseline
# valid maintainer-vouched manifest ; tests mutate one field at a time to
# drive the assertions, matching the AAA / one-logical-assertion discipline.
# =============================================================================

load 'test_helper'

VALIDATE_PRESETS="$BATS_TEST_DIRNAME/../scripts/validate-presets.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Write a baseline VALID maintainer-vouched manifest at $1
write_valid_manifest() {
    cat > "$1" <<'EOF'
{
  "name": "test-stack",
  "displayName": "Test stack",
  "description": "A test manifest for bats coverage.",
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
  "foundation": {
    "skills": {
      "drop": ["dev-flutter"]
    }
  },
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "outOfScope": []
}
EOF
}

# =============================================================================
# Help / basic surface
# =============================================================================

@test "validate-presets.sh --help displays usage and exit codes" {
    run "$VALIDATE_PRESETS" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Exit codes:"* ]]
}

# =============================================================================
# Happy path
# =============================================================================

@test "validate-presets.sh accepts a baseline valid maintainer-vouched manifest" {
    write_valid_manifest "$TEST_DIR/test-stack.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/test-stack.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# JSON syntax
# =============================================================================

@test "validate-presets.sh rejects invalid JSON syntax" {
    echo '{ this is not json' > "$TEST_DIR/broken.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/broken.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"invalid JSON syntax"* ]]
}

# =============================================================================
# Required fields
# =============================================================================

@test "validate-presets.sh rejects manifest missing the name field" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq 'del(.name)' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"missing required field: name"* ]]
}

@test "validate-presets.sh rejects manifest missing the displayName field" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq 'del(.displayName)' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"missing required field: displayName"* ]]
}

@test "validate-presets.sh rejects manifest with empty appliesToTypes" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.appliesToTypes = "not-an-array"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"appliesToTypes"* ]]
}

# =============================================================================
# Enum constraints
# =============================================================================

@test "validate-presets.sh rejects manifest with unknown status value" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.status = "experimental-bogus"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"status"* ]]
    [[ "$output" == *"experimental-bogus"* ]]
}

@test "validate-presets.sh accepts each of the four allowed status values" {
    local s
    for s in maintainer-vouched community-curated draft; do
        write_valid_manifest "$TEST_DIR/x.json"
        jq --arg s "$s" '.status = $s' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
        run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
        [[ "$status" -eq 0 ]] || { echo "failed for status=$s, output=$output"; return 1; }
    done
}

@test "validate-presets.sh rejects defaults.designStyle outside the allowed enum" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaults.designStyle = "neon-cyber-2087"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"designStyle"* ]]
}

# =============================================================================
# Name pattern
# =============================================================================

@test "validate-presets.sh rejects name with uppercase characters" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.name = "NotKebabCase"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"name"* ]]
}

# =============================================================================
# defaults shape (5 fields)
# =============================================================================

@test "validate-presets.sh rejects defaults.ci when it is not a boolean" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaults.ci = "yes-please"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"defaults.ci"* ]]
}

# =============================================================================
# foundation.skills XOR
# =============================================================================

@test "validate-presets.sh rejects manifest declaring BOTH skills.drop and skills.keep (XOR)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.skills = { "drop": ["a"], "keep": ["b"] }' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"mutually exclusive"* ]]
}

@test "validate-presets.sh rejects empty foundation.skills.keep array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.skills = { "keep": [] }' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"keep"* ]]
    [[ "$output" == *"non-empty"* ]]
}

# =============================================================================
# vendor-pointer tier — defaults forbidden, foundation filter forbidden
# (specs/presets-vendor-pointer-tier/spec.md, EF-004)
# =============================================================================

@test "validate-presets.sh accepts a minimal vendor-pointer manifest (no defaults)" {
    cat > "$TEST_DIR/vp.json" <<'EOF'
{
  "name": "test-vendor",
  "displayName": "Test vendor",
  "description": "Vendor pointer minimal manifest for bats coverage.",
  "version": "1.0.0",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [
      { "path": "package.json", "contains": "\"test-vendor\":" }
    ]
  },
  "recommendedVendorSkills": [
    {
      "id": "test-vendor/skill",
      "url": "https://example.org/skill",
      "rationale": "test",
      "condition": "always"
    }
  ],
  "outOfScope": []
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/vp.json"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# marketplacePlugins shape
# =============================================================================

@test "validate-presets.sh rejects marketplacePlugins when it is not an array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.marketplacePlugins = "should-be-array"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"marketplacePlugins"* ]]
}

# =============================================================================
# defaultModules — US-5 (EF-210)
# Optional array of known module names; unknown name → error;
# forbidden on vendor-pointer tier (EF-210).
# =============================================================================

@test "validate-presets.sh accepts a manifest with a valid defaultModules array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = ["biz","legal"]' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh accepts a manifest with an empty defaultModules array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = []' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 0 ]]
}

@test "validate-presets.sh rejects defaultModules when it is not an array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = "biz"' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"defaultModules"* ]]
}

@test "validate-presets.sh rejects defaultModules containing an unknown module name" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = ["biz","not-a-module"]' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"defaultModules"* ]]
    [[ "$output" == *"not-a-module"* ]]
}

@test "validate-presets.sh rejects defaultModules on a vendor-pointer preset (EF-210)" {
    cat > "$TEST_DIR/vp2.json" <<'EOF'
{
  "name": "test-vendor2",
  "displayName": "Test vendor2",
  "description": "Vendor pointer manifest with forbidden defaultModules.",
  "version": "1.0.0",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [
      { "path": "package.json", "contains": "\"test-vendor2\":" }
    ]
  },
  "recommendedVendorSkills": [
    {
      "id": "test-vendor2/skill",
      "url": "https://example.org/skill",
      "rationale": "test",
      "condition": "always"
    }
  ],
  "defaultModules": ["biz"],
  "outOfScope": []
}
EOF
    run "$VALIDATE_PRESETS" "$TEST_DIR/vp2.json"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"defaultModules"* ]]
    [[ "$output" == *"vendor-pointer"* ]]
}

# =============================================================================
# Regression : the foundation's own shipped presets all validate
# =============================================================================

@test "validate-presets.sh on the REAL foundation .claude/presets/: exit 0" {
    run "$VALIDATE_PRESETS"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# PR #268 review hardening — defaultModules name guard + duplicates
# =============================================================================

@test "validate-presets.sh rejects a defaultModules name with path separators (review)" {
    # Mirror module_exists(): only [a-z0-9-] names are module names. A raw
    # -f test accepts "./biz" (resolves to an existing bundle file) while
    # module_exists rejects it — pin the syntax guard, not just -f.
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = ["./biz"]' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -ne 0 ]
    [[ "$output" == *"defaultModules"* ]]
}

@test "validate-presets.sh rejects duplicate defaultModules entries (review)" {
    # Duplicates would flow verbatim into foundation.json (no dedup
    # downstream) — malformed manifest, catch it at validation time.
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.defaultModules = ["legal", "legal"]' "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -ne 0 ]
    [[ "$output" == *"duplicate"* ]]
}

# =============================================================================
# foundation.commands / foundation.agents catalog filters — US-2 (S3)
# spec: specs/presets-commands-agents-filter/spec.md (EF-104/105/111)
# Baseline write_valid_manifest + jq mutation, one logical assertion each.
# =============================================================================

@test "validate-presets.sh rejects commands.drop and commands.keep together (XOR)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["domain:ops"],"keep":["domain:work"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"mutually exclusive"* ]]
    [[ "$output" == *"commands"* ]]
}

@test "validate-presets.sh rejects commands.drop that is not an array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":"not-an-array"}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"commands.drop must be an array"* ]]
}

@test "validate-presets.sh rejects empty commands.keep array" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"keep":[]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"commands.keep"* ]]
}

@test "validate-presets.sh rejects agents filter on a vendor-pointer preset (tier)" {
    write_valid_manifest "$TEST_DIR/x.json"
    # Shape a vendor-pointer preset: status, vendor skills, single detect signal,
    # no defaults, then add the forbidden agents filter.
    jq '.status="vendor-pointer"
        | .recommendedVendorSkills=[{"id":"x/y","url":"https://x","rationale":"r","condition":"always"}]
        | .detect={"combinator":"anyOf","files":["m.marker"]}
        | del(.defaults) | del(.foundation.skills)
        | .foundation.agents={"drop":["dev-flutter"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"vendor-pointer"* ]]
    [[ "$output" == *"agents"* ]]
}

@test "validate-presets.sh rejects dropping the protected floor domain:work (EF-111)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["domain:work"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"floor"* ]] || [[ "$output" == *"EF-111"* ]]
    [[ "$output" == *"work"* ]]
}

@test "validate-presets.sh rejects dropping an assistant entry point (EF-111)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["assistant-auto"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"assistant-auto"* ]]
}

@test "validate-presets.sh rejects targeting a module-owned domain (biz -> defaultModules)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["domain:biz"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"biz"* ]]
    [[ "$output" == *"defaultModules"* ]] || [[ "$output" == *"module"* ]]
}

@test "validate-presets.sh warns (non-fatal) on an unknown command name" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["domain:nope","no-such-command"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"* ]]
    [[ "$output" == *"nope"* ]]
    [[ "$output" == *"no-such-command"* ]]
}

@test "validate-presets.sh accepts a clean stack-scoped command/agent filter" {
    write_valid_manifest "$TEST_DIR/x.json"
    # CORE-only entries: domain:ops (a partly-modularised domain — drops only its
    # core commands) + dev-debug (core command) + dev-debug agent. None is
    # module-owned, so the filter is accepted.
    jq '.foundation.commands = {"drop":["domain:ops","dev-debug"]}
        | .foundation.agents = {"drop":["dev-debug"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"[OK]"* ]]
}

@test "validate-presets.sh still validates the real presets dir (regression)" {
    run "$VALIDATE_PRESETS"
    [ "$status" -eq 0 ]
}

# --- S3 review: additional spec-coverage (amendment + keep-mode + agents floor) ---

@test "validate-presets.sh rejects domain:legal and domain:growth (modules, not preset filters)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["domain:legal"]} | .foundation.agents = {"drop":["domain:growth"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"legal"* ]]
    [[ "$output" == *"growth"* ]]
}

@test "validate-presets.sh rejects an exact module-owned item (biz-competitor)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.agents = {"drop":["biz-competitor"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"biz"* ]]
}

# --- S3 (thematic modules): item-level rejection generalised cross-domain ---
# The filter must reject ANY module-owned item, not just horizontal-domain ones.
# These items live under non-module domains (dev/ops/data) yet belong to a
# thematic module, so the old "entry's domain is a module" heuristic missed them.

@test "validate-presets.sh rejects a cross-domain module-owned command (dev-flutter -> flutter)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"drop":["dev-flutter"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"dev-flutter"* ]]
    [[ "$output" == *"flutter"* ]]
    [[ "$output" == *"defaultModules"* ]] || [[ "$output" == *"module"* ]]
}

@test "validate-presets.sh rejects a cross-domain module-owned agent (ops-proxmox -> self-hosted)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.agents = {"drop":["ops-proxmox"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ops-proxmox"* ]]
    [[ "$output" == *"self-hosted"* ]]
}

@test "validate-presets.sh rejects a thematic item in keep mode too (data-pipeline -> data-eng)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"keep":["domain:work","data-pipeline"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"data-pipeline"* ]]
    [[ "$output" == *"data-eng"* ]]
}

@test "validate-presets.sh rejects an exact work-domain item drop (EF-111)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.agents = {"drop":["work-explore"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"work-explore"* ]]
}

@test "validate-presets.sh rejects a module domain in keep mode too" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"keep":["domain:work","domain:biz"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"biz"* ]]
}

@test "validate-presets.sh accepts keep mode that omits the floor (force-kept, no violation)" {
    write_valid_manifest "$TEST_DIR/x.json"
    jq '.foundation.commands = {"keep":["domain:ops"]}' \
        "$TEST_DIR/x.json" > "$TEST_DIR/x.tmp" && mv "$TEST_DIR/x.tmp" "$TEST_DIR/x.json"
    run "$VALIDATE_PRESETS" "$TEST_DIR/x.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"[OK]"* ]]
}
