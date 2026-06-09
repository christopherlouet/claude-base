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

@test "modules: modules_list returns the 12 modules (3 horizontal + 9 thematic, sorted)" {
    run_lib modules_list
    [ "$status" -eq 0 ]
    # 3 horizontal + 9 thematic, lexically sorted.
    local expected="ai api-data biz data-eng editor frontend growth iac legal mobile observability self-hosted"
    [ "$(echo "$output" | tr '\n' ' ' | sed 's/ $//')" = "$expected" ]
    [ "${#lines[@]}" -eq 12 ]
}

@test "modules: each thematic module exists (module_exists)" {
    for m in mobile self-hosted iac data-eng observability editor api-data ai frontend; do
        run_lib module_exists "$m"
        [ "$status" -eq 0 ]
    done
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

@test "modules: modules_default_set is empty (opt-in by default, v3 — EF-302)" {
    # Lib-owned default for "no explicit module choice" call sites (init,
    # version recording). From v3.0.0 horizontal domains are pure opt-in:
    # absence of an explicit choice means NO modules (supersedes EF-210).
    run_lib modules_default_set
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "${#lines[@]}" -eq 0 ]
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

@test "modules: every bundle path exists in the repo (all modules)" {
    local all_modules
    all_modules=$(bash -c "source '$MODULES_LIB' && modules_list")
    for m in $all_modules; do
        run_lib module_bundle_paths "$m"
        [ "$status" -eq 0 ]
        for line in "${lines[@]}"; do
            [ -e "$REPO_ROOT/$line" ]
        done
    done
}

@test "modules: no item is owned by two modules (EF-404 no-overlap drift guard)" {
    # Every bundle path must belong to exactly one module — the safety net for
    # the cross-domain item-level exclusion (S1). A path listed twice would be
    # double-counted in the core/full split and ambiguously owned.
    local all_modules dupes
    all_modules=$(bash -c "source '$MODULES_LIB' && modules_list")
    dupes=$(
        for m in $all_modules; do
            bash -c "source '$MODULES_LIB' && module_bundle_paths $m"
        done | LC_ALL=C sort | uniq -d
    )
    [ -z "$dupes" ] || { echo "items owned by >1 module:"; echo "$dupes"; false; }
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

@test "modules: bundles never include core workflow or orchestrators (EF-203, all modules)" {
    local all_modules
    all_modules=$(bash -c "source '$MODULES_LIB' && modules_list")
    for m in $all_modules; do
        run_lib module_bundle_paths "$m"
        [ "$status" -eq 0 ]
        [[ "$output" != *"commands/work/"* ]]
        [[ "$output" != *"assistant"* ]]
        # the universal monitoring/component entry points stay core, never modular
        [[ "$output" != *"commands/ops/ops-monitoring.md"* ]]
        [[ "$output" != *"commands/dev/dev-component.md"* ]]
    done
}

@test "modules: thematic bundle item counts are stable (api-data, frontend, mobile)" {
    run_lib module_bundle_paths api-data
    [ "${#lines[@]}" -eq 10 ]   # 4 cmds + 3 agents + 3 skills
    run_lib module_bundle_paths frontend
    [ "${#lines[@]}" -eq 7 ]    # 2 cmds + 1 agent + 4 skills
    run_lib module_bundle_paths mobile
    [ "${#lines[@]}" -eq 6 ]    # 3 cmds + 1 agent + 2 skills
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

@test "migration: legacy marker becomes manifest with empty module set (v3 opt-in/strict)" {
    mkdir -p "$TEST_DIR/.claude"
    echo "1.40.0" > "$TEST_DIR/.claude/.foundation-version"
    run_lib migrate_legacy_marker "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/foundation.json" ]
    [ ! -f "$TEST_DIR/.claude/.foundation-version" ]
    run bash -c "jq -r '.version' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "1.40.0" ]
    # v3: horizontal is opt-in. A legacy marker (pre-manifest) migrates with NO
    # modules recorded (strict — files on disk are untouched; `add` to resume).
    run bash -c "jq -r '.modules | sort | join(\",\")' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "" ]
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

@test "module add: fresh add installs a cross-domain thematic module (mobile)" {
    setup_lean_project
    run_module add mobile --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # mobile spans dev/ops/qa — every listed path (commands, agent, skills) lands.
    local p
    while IFS= read -r p; do
        [ -e "$TEST_DIR/$p" ] || { echo "Missing: $p" >&2; return 1; }
    done < <(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                      module_bundle_paths mobile")
    # spot-check the cross-domain spread actually materialised
    [ -f "$TEST_DIR/.claude/commands/dev/dev-flutter.md" ]
    [ -f "$TEST_DIR/.claude/commands/ops/ops-mobile-release.md" ]
    [ -f "$TEST_DIR/.claude/commands/qa/qa-mobile.md" ]
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

# =============================================================================
# module remove — cmd_remove (T023, US-4)
#
# Spec: specs/foundation-modules/spec.md — CS-206
# Clean removal: foundation-owned files removed, user-modified preserved,
# manifest unrecorded. Zero silent deletions.
# =============================================================================

# -----------------------------------------------------------------------
# clean remove — foundation-owned files gone, manifest unrecorded (CS-206)
# -----------------------------------------------------------------------

@test "module remove: clean remove deletes foundation-owned files" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Every legal bundle file must be gone.
    local p
    while IFS= read -r p; do
        [ ! -f "$TEST_DIR/$p" ] || {
            echo "Still present after remove: $p" >&2
            return 1
        }
    done < <(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; module_bundle_paths legal")
}

@test "module remove: clean remove unrecords the module in the manifest" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    run bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                 manifest_has_module '$TEST_DIR' legal"
    [ "$status" -ne 0 ]
}

@test "module remove: summary reports how many files were removed" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Output must mention removal count or module name.
    [[ "$output" == *"legal"* ]]
    [[ "$output" == *"removed"* ]] || [[ "$output" == *"remove"* ]]
}

# -----------------------------------------------------------------------
# user-modified file — preserved with explicit notice (CS-206)
# -----------------------------------------------------------------------

@test "module remove: user-modified file is preserved with explicit notice" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Modify one legal file to simulate user customisation.
    local modified_path
    modified_path=$(bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                             module_bundle_paths legal" | head -1)
    echo "# user customisation" >> "$TEST_DIR/$modified_path"

    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # The modified file must still be present.
    [ -f "$TEST_DIR/$modified_path" ]
    # Output must say it was preserved (not silently ignored).
    [[ "$output" == *"preserved"* ]] || [[ "$output" == *"user-modified"* ]]
}

# -----------------------------------------------------------------------
# remove not-installed → clean message, no error spiral (CS-206)
# -----------------------------------------------------------------------

@test "module remove: remove not-installed module gives clean message with exit 0" {
    setup_lean_project
    # Do NOT install the module; remove must handle gracefully.
    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Must say it's not installed, not blow up.
    [[ "$output" == *"not installed"* ]] || [[ "$output" == *"nothing"* ]] || [[ "$output" == *"not recorded"* ]]
}

# -----------------------------------------------------------------------
# remove with all files absent after removal → unrecord + notice (CS-206)
# -----------------------------------------------------------------------

@test "module remove: module with zero foundation-owned files left → unrecord + notice" {
    setup_lean_project
    # Record legal in the manifest but plant NO actual files (simulates a
    # project where legal was never actually deployed despite the manifest entry).
    bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
             write_foundation_manifest '$TEST_DIR' '2.1.0' '' legal"

    run_module remove legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    # legal must be unrecorded from the manifest.
    run bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                 manifest_has_module '$TEST_DIR' legal"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------
# dry-run — lists files to remove, writes nothing (CS-206)
# -----------------------------------------------------------------------

@test "module remove --dry-run: lists files to remove, writes nothing" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Capture file list before dry-run.
    local before_count
    before_count=$(find "$TEST_DIR/.claude" -type f | wc -l)

    run_module remove legal --target "$TEST_DIR" --dry-run
    [ "$status" -eq 0 ]
    # Output must reference legal and removal action.
    [[ "$output" == *"legal"* ]]
    [[ "$output" == *"DRY-RUN"* ]] || [[ "$output" == *"dry-run"* ]] || [[ "$output" == *"dry_run"* ]] || [[ "$output" == *"Remove"* ]]

    # File count in .claude must be unchanged (nothing actually removed).
    local after_count
    after_count=$(find "$TEST_DIR/.claude" -type f | wc -l)
    [ "$before_count" -eq "$after_count" ]
}

@test "module remove --dry-run: manifest is not modified" {
    setup_lean_project
    run_module add legal --target "$TEST_DIR"
    [ "$status" -eq 0 ]

    run_module remove legal --target "$TEST_DIR" --dry-run
    [ "$status" -eq 0 ]
    # legal must still be recorded after dry-run.
    run bash -c "source '$REPO_ROOT_LOCAL/scripts/lib/modules.sh'; \
                 manifest_has_module '$TEST_DIR' legal"
    [ "$status" -eq 0 ]
}

# =============================================================================
# PR #268 review hardening — positional target, legacy hint, dir cleanup
# =============================================================================

@test "module add: accepts a positional target dir like init/update/validate (review)" {
    # The docs examples use 'claude-base add legal .' — the module verbs
    # must honor the same positional-path contract as every other verb.
    setup_lean_project
    run_module add legal "$TEST_DIR"
    [ "$status" -eq 0 ]
    run bash -c "jq -r '.modules | join(\",\")' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "legal" ]
}

@test "module modules: accepts a positional dir (review)" {
    setup_lean_project
    run_module modules "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"legal"* ]]
}

@test "module add: positional dir combines with flags in any position (review)" {
    setup_lean_project
    run_module add legal --dry-run "$TEST_DIR"
    [ "$status" -eq 0 ]
    # dry-run: nothing recorded
    run bash -c "jq -r '.modules | length' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "0" ]
}

@test "module add: legacy project (marker, no manifest) hints at claude-base update (review)" {
    # require_foundation_project must not send a legacy user to 'init' —
    # the migration path is 'claude-base update' (EF-205).
    mkdir -p "$TEST_DIR/.claude"
    echo "1.40.0" > "$TEST_DIR/.claude/.foundation-version"
    run_module add legal --target "$TEST_DIR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"update"* ]]
    [[ "$output" != *"'claude-base init'"* ]]
}

@test "module remove: emptied module directories are removed (review)" {
    # Same contract as the init-time filter: no hollow
    # .claude/commands/<module>/ shells after the last file is removed.
    setup_lean_project
    run_module add biz --target "$TEST_DIR"
    [ "$status" -eq 0 ]
    run_module remove biz --target "$TEST_DIR" --non-interactive
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.claude/commands/biz" ]
}

@test "module add: explicit --target plus a positional dir is an error (review)" {
    # update.sh rejects extra targets ('Too many arguments') — the module
    # verbs must not silently let the positional overwrite --target.
    setup_lean_project
    mkdir -p "$TEST_DIR/other/.claude"
    run_module add legal --target "$TEST_DIR" "$TEST_DIR/other"
    [ "$status" -ne 0 ]
    [[ "$output" == *"target"* ]]
    # Neither project was touched.
    run bash -c "jq -r '.modules | length' '$TEST_DIR/.claude/foundation.json'"
    [ "$output" = "0" ]
}

# =============================================================================
# Polish session — shared bundle-file removal helper (lib-owned)
# =============================================================================

@test "modules: remove_bundle_file drops the file and its emptied parent" {
    mkdir -p "$TEST_DIR/x/sub"
    touch "$TEST_DIR/x/sub/f.md"
    run_lib remove_bundle_file "$TEST_DIR/x/sub/f.md"
    [ "$status" -eq 0 ]
    [ ! -e "$TEST_DIR/x/sub" ]
    [ -d "$TEST_DIR/x" ]
}

@test "modules: remove_bundle_file keeps a non-empty parent" {
    mkdir -p "$TEST_DIR/y"
    touch "$TEST_DIR/y/f.md" "$TEST_DIR/y/keep.md"
    run_lib remove_bundle_file "$TEST_DIR/y/f.md"
    [ "$status" -eq 0 ]
    [ ! -e "$TEST_DIR/y/f.md" ]
    [ -e "$TEST_DIR/y/keep.md" ]
}

# =============================================================================
# counts.json core split (S4) — core = full foundation minus module-owned items.
# The "core" totals are what a default (opt-in) install ships; the full totals
# are what the repo catalogs. They must stay in lockstep with the bundles.
# =============================================================================

@test "counts: core = full catalog minus module-owned items (S4/EF-311)" {
    local counts="$REPO_ROOT/counts.json"
    [ -f "$counts" ]

    # Module-owned totals, summed from the real bundles.
    local mc=0 ma=0 ms=0 m p
    while IFS= read -r m; do
        while IFS= read -r p; do
            case "$p" in
                .claude/commands/*) mc=$((mc + 1)) ;;
                .claude/agents/*)   ma=$((ma + 1)) ;;
                .claude/skills/*)   ms=$((ms + 1)) ;;
            esac
        done < <(bash -c "source '$REPO_ROOT/scripts/lib/modules.sh'; module_bundle_paths $m")
    done < <(bash -c "source '$REPO_ROOT/scripts/lib/modules.sh'; modules_list")

    local full_c full_a full_s
    full_c=$(jq -r '.commands' "$counts")
    full_a=$(jq -r '.agents' "$counts")
    full_s=$(jq -r '.skills' "$counts")

    [ "$(jq -r '.core.commands' "$counts")" -eq "$((full_c - mc))" ]
    [ "$(jq -r '.core.agents' "$counts")" -eq "$((full_a - ma))" ]
    [ "$(jq -r '.core.skills' "$counts")" -eq "$((full_s - ms))" ]
}
