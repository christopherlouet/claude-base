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

@test "modules: modules_default_set returns the full catalog" {
    # Lib-owned default for "no explicit module choice" call sites
    # (init, version recording, legacy migration). Full set at v1;
    # preset defaultModules will hook in here with US-5.
    run_lib modules_default_set
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "biz" ]
    [ "${lines[1]}" = "growth" ]
    [ "${lines[2]}" = "legal" ]
    [ "${#lines[@]}" -eq 3 ]
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

@test "migration: empty legacy marker migrates as 0.0.0 with a warning" {
    # An empty/whitespace-only marker has no usable version. "unknown" is
    # not sortable by version_gte; 0.0.0 keeps comparisons meaningful and
    # the warning tells the user what happened.
    mkdir -p "$TEST_DIR/.claude"
    : > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
    [ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" = "0.0.0" ]
    [[ "$output" == *"warning"* ]]
    [[ "$output" == *"0.0.0"* ]]
}

@test "migration: whitespace-only legacy marker migrates as 0.0.0" {
    mkdir -p "$TEST_DIR/.claude"
    printf '   \n' > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$(jq -r '.version' "$TEST_DIR/.claude/foundation.json")" = "0.0.0" ]
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

@test "manifest: write_foundation_manifest leaves no partial file when jq fails" {
    mkdir -p "$TEST_DIR/fakebin"
    printf '#!/usr/bin/env bash\nexit 7\n' > "$TEST_DIR/fakebin/jq"
    chmod +x "$TEST_DIR/fakebin/jq"
    run bash -c "PATH='$TEST_DIR/fakebin':\$PATH; source '$MODULES_LIB'; write_foundation_manifest '$TEST_DIR/proj' '2.1.0' '' legal"
    [ "$status" -ne 0 ]
    [ ! -f "$TEST_DIR/proj/.claude/foundation.json" ]
}

@test "manifest: write_foundation_manifest refuses a non-file destination" {
    mkdir -p "$TEST_DIR/.claude/foundation.json"   # directory squatting the path
    run_lib write_foundation_manifest "$TEST_DIR" "2.1.0" "" legal
    [ "$status" -ne 0 ]
    [[ "$output" == *"not a regular file"* ]]
}

# =============================================================================
# module add — cmd_add (T017, US-2)
# Exercises scripts/module.sh via the MODULE_SCRIPT variable.
# =============================================================================

MODULE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/module.sh"
REPO_ROOT_LOCAL="$BATS_TEST_DIRNAME/.."

# Helper: initialise a minimal foundation project in TEST_DIR:
#   - .claude/foundation.json records version=2.1.0, no preset, no modules.
#   - .claude/settings.json present (foundation marker used by some guard checks).
setup_lean_project() {
    local dir="${1:-$TEST_DIR}"
    mkdir -p "$dir/.claude"
    echo '{}' > "$dir/.claude/settings.json"
    bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
             write_foundation_manifest '$dir' '2.1.0' ''"
}

# Helper: run module.sh with a stable FOUNDATION_ROOT pointing to the repo.
run_module() {
    run bash -c "FOUNDATION_ROOT='$REPO_ROOT_LOCAL' '$MODULE_SCRIPT' \"\$@\"" _ "$@"
}

# -----------------------------------------------------------------------
# Guard: script exists
# -----------------------------------------------------------------------

@test "module: scripts/module.sh exists and is executable" {
    [ -f "$MODULE_SCRIPT" ]
    [ -x "$MODULE_SCRIPT" ]
}

# -----------------------------------------------------------------------
# add fresh — files + manifest + summary (CS-201)
# -----------------------------------------------------------------------

@test "module add: fresh add installs all legal bundle files" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Every path declared in the legal bundle must now exist in the project.
    local p
    while IFS= read -r p; do
        [ -e "$TEST_DIR/$p" ] || {
            echo "Missing: $p" >&2
            return 1
        }
    done < <(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                      module_bundle_paths legal")
}

@test "module add: fresh add records the module in the manifest" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    run bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                 manifest_has_module '$TEST_DIR' legal"
    [ "$status" -eq 0 ]
}

@test "module add: summary lists what was added" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Output should mention the module name and some indication of files installed.
    [[ "$output" == *"legal"* ]]
}

# -----------------------------------------------------------------------
# add idempotent — re-add refreshes files, single manifest entry (EF-206)
# -----------------------------------------------------------------------

@test "module add: idempotent — re-add does not duplicate the manifest entry" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Manifest must list legal exactly once.
    local count
    count=$(bash -c "jq '[.modules[] | select(. == \"legal\")] | length' \
                    '$TEST_DIR/.claude/foundation.json'")
    [ "$count" -eq 1 ]
}

# -----------------------------------------------------------------------
# unknown module — fail with available list, distinct exit code (EF-96)
# -----------------------------------------------------------------------

@test "module add: unknown module fails with available list" {
    setup_lean_project
    run_module add does-not-exist --target "$TEST_DIR"
    [ "$status" -ne 0 ]
    # Must name the bad module and list the known ones.
    [[ "$output" == *"does-not-exist"* ]]
    [[ "$output" == *"biz"* ]] || [[ "$output" == *"legal"* ]] || [[ "$output" == *"growth"* ]]
}

@test "module add: unknown module exit code is distinct from success (non-zero)" {
    setup_lean_project
    run_module add does-not-exist --target "$TEST_DIR"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------
# dry-run — lists files, writes nothing (EF-206)
# -----------------------------------------------------------------------

@test "module add --dry-run: lists files to install, writes nothing" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR" --dry-run
    [ "$status" -eq 0 ]
    # Output must reference at least one legal path.
    [[ "$output" == *"legal"* ]]
    # Manifest must remain unchanged (no modules recorded).
    run bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                 manifest_has_module '$TEST_DIR' legal"
    [ "$status" -ne 0 ]
}

@test "module add --dry-run: no files written to project" {
    setup_lean_project
    local before_count
    before_count=$(find "$TEST_DIR/.claude" -type f | wc -l)
    run_module add biz --target "$TEST_DIR" --dry-run
    [ "$status" -eq 0 ]
    local after_count
    after_count=$(find "$TEST_DIR/.claude" -type f | wc -l)
    # Only the foundation.json + settings.json should be present — dry-run must not add files.
    [ "$after_count" -eq "$before_count" ]
}

# -----------------------------------------------------------------------
# non-foundation target — refused (spec edge case, EF-206)
# -----------------------------------------------------------------------

@test "module add: non-foundation target (no manifest) is refused with clear message" {
    # A directory with no .claude/foundation.json at all.
    local bare_dir="$TEST_DIR/bare"
    mkdir -p "$bare_dir"
    run_module add legal --target "$bare_dir"
    [ "$status" -ne 0 ]
    # Must tell the user to init first.
    [[ "$output" == *"init"* ]] || [[ "$output" == *"foundation"* ]] || [[ "$output" == *"manifest"* ]]
}

# -----------------------------------------------------------------------
# partial manual copy — converged and owned (CS-202 precondition / EF-206)
# -----------------------------------------------------------------------

@test "module add: partial manual copy is converged (heals staleness)" {
    setup_lean_project
    # Manually plant one legal file (stale version — same content for simplicity).
    local first_path
    first_path=$(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                          module_bundle_paths legal" | head -1)
    mkdir -p "$TEST_DIR/$(dirname "$first_path")"
    echo "# stale content" > "$TEST_DIR/$first_path"

    # add must converge even when files exist (--force or non-interactive auto-update).
    run_module add legal --target "$TEST_DIR" --force
    [ "$status" -eq 0 ]
    # The file must now match the foundation copy.
    diff "$REPO_ROOT_LOCAL/$first_path" "$TEST_DIR/$first_path"
}

# -----------------------------------------------------------------------
# user-modified file — update-style conflict behavior (backup / non-interactive listing)
# -----------------------------------------------------------------------

@test "module add: user-modified file triggers backup in non-interactive mode" {
    setup_lean_project
    # Install legal first so files are present.
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Modify one file to simulate user customisation.
    local first_path
    first_path=$(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                          module_bundle_paths legal" | head -1)
    echo "# user edit" >> "$TEST_DIR/$first_path"
    # Re-add with --force in non-interactive mode: must produce a backup.
    run_module add legal --target "$TEST_DIR" --force --non-interactive
    [ "$status" -eq 0 ]
    # A .backup.* file should exist next to the original (update.sh convention).
    local backup_count
    backup_count=$(find "$(dirname "$TEST_DIR/$first_path")" -name "*.backup.*" -type f 2>/dev/null | wc -l)
    [ "$backup_count" -ge 1 ]
}
