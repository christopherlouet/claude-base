#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/modules.sh — foundation modules
#
# Spec: specs/foundation-modules/spec.md
# Phase 1 (T005): bundle registry — modules_list, module_exists,
#   module_bundle_paths, bundle drift guard against the repo catalogs.
# Phase 2 (T007): project manifest helpers — added in a later commit.
# =============================================================================

load 'test_helper'

REPO_ROOT="$BATS_TEST_DIRNAME/.."
MODULES_LIB="$REPO_ROOT/scripts/lib/modules.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Source the lib in a subshell-friendly way for `run`, preserving argument
# boundaries (incl. empty args — the preset slot may legitimately be "").
# Usage: run_lib <function> [args...]
run_lib() {
    run bash -c 'source "$1"; shift; "$@"' _ "$MODULES_LIB" "$@"
}

# =============================================================================
# Registry — basic invariants
# =============================================================================

@test "modules: lib file exists" {
    [ -f "$MODULES_LIB" ]
}

@test "modules: modules_list returns exactly biz, growth, legal (sorted)" {
    run_lib modules_list
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "biz" ]
    [ "${lines[1]}" = "growth" ]
    [ "${lines[2]}" = "legal" ]
    [ "${#lines[@]}" -eq 3 ]
}

@test "modules: module_exists accepts known modules" {
    run_lib module_exists biz
    [ "$status" -eq 0 ]
    run_lib module_exists legal
    [ "$status" -eq 0 ]
    run_lib module_exists growth
    [ "$status" -eq 0 ]
}

@test "modules: module_exists rejects unknown module" {
    run_lib module_exists bizz
    [ "$status" -ne 0 ]
}

@test "modules: module_exists rejects empty name" {
    run_lib module_exists ""
    [ "$status" -ne 0 ]
}

@test "modules: module_exists is not fooled by path traversal" {
    run_lib module_exists "../minimal-manifest"
    [ "$status" -ne 0 ]
}

# =============================================================================
# Bundle parsing
# =============================================================================

@test "modules: module_bundle_paths legal returns 9 entries, no comments" {
    run_lib module_bundle_paths legal
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 9 ]
    for line in "${lines[@]}"; do
        [[ "$line" != \#* ]]
        [ -n "$line" ]
    done
}

@test "modules: module_bundle_paths biz returns 15 entries" {
    run_lib module_bundle_paths biz
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 15 ]
}

@test "modules: module_bundle_paths growth returns 18 entries incl. skill dir" {
    run_lib module_bundle_paths growth
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 18 ]
    [[ "$output" == *".claude/skills/growth-cro/"* ]]
}

@test "modules: module_bundle_paths fails loud on unknown module" {
    run_lib module_bundle_paths nope
    [ "$status" -ne 0 ]
    [[ "$output" == *"nope"* ]]
}

@test "modules: bundle paths are repo-relative (no absolute, no ..)" {
    for m in biz legal growth; do
        run_lib module_bundle_paths "$m"
        [ "$status" -eq 0 ]
        for line in "${lines[@]}"; do
            [[ "$line" != /* ]]
            [[ "$line" != *".."* ]]
        done
    done
}

# =============================================================================
# Drift guard — bundles must match the repo catalogs
# =============================================================================

@test "modules: every bundle path exists in the repo" {
    for m in biz legal growth; do
        run_lib module_bundle_paths "$m"
        [ "$status" -eq 0 ]
        for line in "${lines[@]}"; do
            [ -e "$REPO_ROOT/$line" ]
        done
    done
}

@test "modules: bundles cover every repo catalog item of their domain (no orphan)" {
    # Any commands/<domain>/*.md, agents/<domain>-*.md or skills/<domain>-*/
    # in the repo MUST be listed in the domain bundle, otherwise the bundle
    # drifted behind the catalog.
    for m in biz legal growth; do
        bundle=$(bash -c "source '$MODULES_LIB' && module_bundle_paths $m")
        while IFS= read -r f; do
            rel="${f#"$REPO_ROOT"/}"
            [[ "$bundle" == *"$rel"* ]]
        done < <(find "$REPO_ROOT/.claude/commands/$m" -name "*.md" -type f 2>/dev/null)
        while IFS= read -r f; do
            rel="${f#"$REPO_ROOT"/}"
            [[ "$bundle" == *"$rel"* ]]
        done < <(find "$REPO_ROOT/.claude/agents" -maxdepth 1 -name "${m}-*.md" -type f 2>/dev/null)
        while IFS= read -r d; do
            rel="${d#"$REPO_ROOT"/}/"
            [[ "$bundle" == *"$rel"* ]]
        done < <(find "$REPO_ROOT/.claude/skills" -maxdepth 1 -mindepth 1 -name "${m}-*" -type d 2>/dev/null)
    done
}

@test "modules: bundles never include core workflow or orchestrators (EF-203)" {
    for m in biz legal growth; do
        run_lib module_bundle_paths "$m"
        [ "$status" -eq 0 ]
        [[ "$output" != *"commands/work/"* ]]
        [[ "$output" != *"assistant"* ]]
    done
}

# =============================================================================
# Project manifest (.claude/foundation.json) — EF-204/EF-205
# =============================================================================

@test "manifest: write then read roundtrip" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "nextjs" legal growth
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    run bash -c "jq -r '.version' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "2.1.0" ]
    run bash -c "jq -r '.preset' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "nextjs" ]
    run bash -c "jq -r '.modules | join(\",\")' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "legal,growth" ]
}

@test "manifest: write without preset stores null" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "" biz legal growth
    [ "$status" -eq 0 ]
    run bash -c "jq -r '.preset' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "null" ]
}

@test "manifest: manifest_preset and manifest_modules read back values" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "fastapi" legal
    run_lib manifest_preset "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "fastapi" ]
    run_lib manifest_modules "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "legal" ]
}

@test "manifest: manifest_preset is empty when preset is null" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "" legal
    run_lib manifest_preset "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "manifest: manifest_has_module distinguishes installed from absent" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "" legal
    run_lib manifest_has_module "$TEST_DIR" legal
    [ "$status" -eq 0 ]
    run_lib manifest_has_module "$TEST_DIR" biz
    [ "$status" -ne 0 ]
}

@test "manifest: read fails cleanly when manifest is missing" {
    run_lib read_foundation_manifest "$TEST_DIR"
    [ "$status" -ne 0 ]
}

@test "manifest: corrupted JSON fails loud with path and repair hint" {
    mkdir -p "$TEST_DIR/.claude"
    echo "{ broken" > "$TEST_DIR/.claude/foundation.json"
    run_lib manifest_modules "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"foundation.json"* ]]
    [[ "$output" == *"update"* ]]
}

@test "manifest: unknown module names in manifest warn but are ignored" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "" legal bizz
    run_lib manifest_modules "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"legal"* ]]
    [[ "$output" != *"bizz"* ]] || [[ "$output" == *"warning"* ]]
}

# =============================================================================
# Legacy marker migration — EF-205
# =============================================================================

@test "migration: legacy marker becomes manifest with full module set" {
    mkdir -p "$TEST_DIR/.claude"
    echo "1.40.0" > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
    run bash -c "jq -r '.version' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "1.40.0" ]
    run bash -c "jq -r '.modules | sort | join(\",\")' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "biz,growth,legal" ]
}

@test "migration: no-op when manifest already present" {
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "nextjs" legal
    echo "1.40.0" > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    run bash -c "jq -r '.version' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "2.1.0" ]
}

@test "migration: no-op when neither marker nor manifest exist" {
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.claude/foundation.json" ]
}

@test "migration: detects installed modules from project content (EF-205)" {
    # A legacy minimal-style install: commands dir present, legal only.
    mkdir -p "$TEST_DIR/.claude/commands/legal"
    touch "$TEST_DIR/.claude/commands/legal/legal-rgpd.md"
    echo "1.30.0" > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    run bash -c "jq -r '.modules | join(\",\")' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "legal" ]
}
