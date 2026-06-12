#!/usr/bin/env bats

# =============================================================================
# Tests for the v3 strict crossing-update migration — US-3 (S3).
#
# Spec: specs/horizontal-pure-modules/spec.md (EF-306/307/308)
# When `claude-base update` runs on a project whose manifest predates v3.0.0
# (horizontal installed by the old opt-out default), the horizontal domains
# (biz/legal/growth) become opt-in: they are dropped from the manifest, no
# longer refreshed (COPY-only — files left on disk), and the user is told to
# `claude-base add <module>` to keep them. A v3 manifest is untouched.
# =============================================================================

load 'test_helper'

UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
MODULE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/module.sh"
REPO="$BATS_TEST_DIRNAME/.."

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

_add_module() {
    bash -c "FOUNDATION_ROOT='$REPO' '$MODULE_SCRIPT' add $1 --target '$2'" >/dev/null 2>&1
}

# Pre-flip project: core install + all three horizontal modules installed and
# recorded, manifest version rewound to a pre-3.0.0 value.
_setup_preflip_project() {
    local proj="$TEST_DIR/proj"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1
    _add_module biz "$proj"
    _add_module legal "$proj"
    _add_module growth "$proj"
    jq '.version = "2.0.0"' "$proj/.claude/foundation.json" > "$proj/.claude/foundation.json.tmp"
    mv "$proj/.claude/foundation.json.tmp" "$proj/.claude/foundation.json"
    echo "$proj"
}

_manifest_modules_joined() {
    jq -r '.modules | sort | join(",")' "$1/.claude/foundation.json"
}

# ---------------------------------------------------------------------------
# EF-307/308 — crossing update drops horizontal, retains files, reports.
# ---------------------------------------------------------------------------
@test "migration: crossing update stops refreshing horizontal but keeps files (EF-307)" {
    local proj
    proj="$(_setup_preflip_project)"
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]
    # Corrupt a horizontal file: if it is skipped (not refreshed) it stays stale.
    echo "# STALE" > "$proj/.claude/commands/biz/biz-mvp.md"

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # File retained (COPY-only never deletes) ...
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]
    # ... and NOT refreshed (still stale → proves it was skipped).
    grep -q "# STALE" "$proj/.claude/commands/biz/biz-mvp.md"
    # Manifest no longer records the horizontal modules, version bumped.
    [ "$(_manifest_modules_joined "$proj")" = "" ]
    [ "$(jq -r '.version' "$proj/.claude/foundation.json")" = "4.0.0" ]
    # Migration is reported with the opt-in instruction.
    [[ "$output" == *"claude-base add"* ]]
}

# ---------------------------------------------------------------------------
# EF-306 — after re-adding a module, update refreshes it again.
# ---------------------------------------------------------------------------
@test "migration: re-adding a module restores refresh (EF-306)" {
    local proj
    proj="$(_setup_preflip_project)"
    "$UPDATE_SCRIPT" -y "$proj" >/dev/null 2>&1     # crossing → biz dropped
    [ "$(_manifest_modules_joined "$proj")" = "" ]

    _add_module biz "$proj"                          # opt back in
    rm -f "$proj/.claude/commands/biz/biz-mvp.md"     # simulate it going missing
    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # biz is recorded again and refreshed (the missing file is re-added —
    # proves it is no longer module-skipped).
    [ "$(_manifest_modules_joined "$proj")" = "biz" ]
    [ -f "$proj/.claude/commands/biz/biz-mvp.md" ]
}

# ---------------------------------------------------------------------------
# EF-306 — a v3 manifest is NOT migrated; its recorded modules still refresh.
# ---------------------------------------------------------------------------
@test "migration: a v3 manifest keeps refreshing its recorded modules (no reset)" {
    local proj="$TEST_DIR/proj"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1
    _add_module legal "$proj"
    [ -f "$proj/.claude/commands/legal/legal-rgpd.md" ]
    # Already v3 (fresh install records 3.0.0); legal explicitly opted in.
    rm -f "$proj/.claude/commands/legal/legal-rgpd.md"   # simulate it going missing

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_manifest_modules_joined "$proj")" = "legal" ]   # still recorded, not reset
    [ -f "$proj/.claude/commands/legal/legal-rgpd.md" ]   # refreshed (re-added)
}

# ---------------------------------------------------------------------------
# EF-308 — the migration is idempotent (a second update does not re-trigger).
# ---------------------------------------------------------------------------
@test "migration: idempotent — second update does not re-migrate" {
    local proj
    proj="$(_setup_preflip_project)"
    "$UPDATE_SCRIPT" -y "$proj" >/dev/null 2>&1     # first crossing

    run "$UPDATE_SCRIPT" -y "$proj"                 # second update
    [ "$status" -eq 0 ]
    [ "$(_manifest_modules_joined "$proj")" = "" ]
    [ "$(jq -r '.version' "$proj/.claude/foundation.json")" = "4.0.0" ]
}

# ---------------------------------------------------------------------------
# dry-run reports the migration but does not mutate the manifest.
# ---------------------------------------------------------------------------
@test "migration: --dry-run reports but does not rewrite the manifest" {
    local proj
    proj="$(_setup_preflip_project)"

    run "$UPDATE_SCRIPT" -n -y "$proj"
    [ "$status" -eq 0 ]
    # Manifest untouched: modules + version preserved.
    [ "$(_manifest_modules_joined "$proj")" = "biz,growth,legal" ]
    [ "$(jq -r '.version' "$proj/.claude/foundation.json")" = "2.0.0" ]
}

# ---------------------------------------------------------------------------
# A manifest-less / core-only project triggers no migration report.
# ---------------------------------------------------------------------------
@test "migration: core-only project (no horizontal) shows no migration report" {
    local proj="$TEST_DIR/proj"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1   # v3, no modules

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_manifest_modules_joined "$proj")" = "" ]
}

# ---------------------------------------------------------------------------
# Review fix A1 — under --clean/--all the horizontal files ARE removed (clean
# wipes them, opt-in does not re-deposit), so the migration message must NOT
# claim they were "left in place"; it must point at re-install.
# ---------------------------------------------------------------------------
@test "migration: --all crossing message does not falsely claim files were kept" {
    local proj
    proj="$(_setup_preflip_project)"

    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"left in place"* ]]
    [[ "$output" == *"claude-base add"* ]]
}

# ---------------------------------------------------------------------------
# Review fix A2 — a manifest whose version is the literal "unknown" must be
# treated as pre-flip (crossing) and migrated, not skipped.
# ---------------------------------------------------------------------------
@test "migration: manifest version 'unknown' is treated as a crossing update" {
    local proj
    proj="$(_setup_preflip_project)"
    jq '.version = "unknown"' "$proj/.claude/foundation.json" > "$proj/.claude/foundation.json.tmp"
    mv "$proj/.claude/foundation.json.tmp" "$proj/.claude/foundation.json"

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    [ "$(_manifest_modules_joined "$proj")" = "" ]   # migrated (horizontal dropped)
}

# ===========================================================================
# Thematic-modules crossing migration (S3, US-3 generalised, EF-405)
# Thematic items (mobile/self-hosted/iac/data-eng/observability/editor/
# api-data/ai/frontend) used to be CORE — never manifest-recorded. A project
# crossing the thematic release (< 4.0.0) with those files present must:
# stop refreshing them (COPY-only, files kept), report ONE consolidated
# message + add hint (not one orphan nag per module), and rewrite NO manifest.
# ===========================================================================

# Pre-thematic project: core install + all thematic files on disk but NOT
# recorded (modules=[]) and version rewound to a pre-4.0.0 value — exactly the
# state of a project installed when those items were still core.
_setup_pre_thematic_project() {
    local proj="$TEST_DIR/proj"
    "$NEW_PROJECT_SCRIPT" --simple -y "$proj" >/dev/null 2>&1
    local m
    for m in mobile self-hosted iac data-eng observability editor api-data ai frontend nextjs flutter gitflow; do
        _add_module "$m" "$proj"
    done
    jq '.version = "3.5.0" | .modules = []' "$proj/.claude/foundation.json" > "$proj/.claude/foundation.json.tmp"
    mv "$proj/.claude/foundation.json.tmp" "$proj/.claude/foundation.json"
    echo "$proj"
}

@test "migration: thematic crossing keeps files, stops refreshing, reports add hint (EF-405)" {
    local proj
    proj="$(_setup_pre_thematic_project)"
    [ -f "$proj/.claude/commands/dev/dev-flutter.md" ]
    echo "# STALE" > "$proj/.claude/commands/dev/dev-flutter.md"

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # File retained (COPY-only) and NOT refreshed (still stale → was skipped).
    [ -f "$proj/.claude/commands/dev/dev-flutter.md" ]
    grep -q "# STALE" "$proj/.claude/commands/dev/dev-flutter.md"
    # Reported with the opt-in instruction, naming the themes.
    [[ "$output" == *"opt-in modules"* ]]
    [[ "$output" == *"claude-base add"* ]]
    # No manifest rewrite — thematic items were core, never recorded.
    [ "$(jq -r '.modules | length' "$proj/.claude/foundation.json")" -eq 0 ]
}

@test "migration: thematic crossing consolidates the orphan nag (not one per module)" {
    local proj
    proj="$(_setup_pre_thematic_project)"
    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # The generic per-module "present but the module is not in the manifest" nag
    # must be suppressed for thematic modules (replaced by one crossing message).
    [[ "$output" != *"present but the module is not in the manifest"* ]]
}

@test "migration: after re-adding a thematic module, update refreshes it again" {
    local proj
    proj="$(_setup_pre_thematic_project)"
    "$UPDATE_SCRIPT" -y "$proj" >/dev/null 2>&1           # crossing
    _add_module flutter "$proj"                            # opt back in (dev-flutter lives in flutter)
    rm -f "$proj/.claude/commands/dev/dev-flutter.md"      # simulate it going missing

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    # flutter is recorded again → the missing file is re-added (no longer
    # module-skipped). Other thematic modules stay skipped.
    [ -f "$proj/.claude/commands/dev/dev-flutter.md" ]
}

@test "migration: thematic --all crossing message does not claim files were kept" {
    local proj
    proj="$(_setup_pre_thematic_project)"
    run "$UPDATE_SCRIPT" -y --all "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"left in place"* ]]
    [[ "$output" == *"claude-base add"* ]]
}

@test "migration: a v4 manifest shows no thematic crossing report" {
    local proj
    proj="$(_setup_pre_thematic_project)"
    jq '.version = "4.0.0"' "$proj/.claude/foundation.json" > "$proj/.claude/foundation.json.tmp"
    mv "$proj/.claude/foundation.json.tmp" "$proj/.claude/foundation.json"

    run "$UPDATE_SCRIPT" -y "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"opt-in modules"* ]]
}
