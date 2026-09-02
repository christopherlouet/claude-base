#!/usr/bin/env bats

# =============================================================================
# The installer must never overwrite a file the PROJECT already has.
#
# Measured 2026-09-02 on a real repository: `new-project.sh -y --preset
# homelab-proxmox` on a Terraform project replaced its own .github/workflows/
# ci.yml with the foundation's generic one — 510 lines gone, silently.
#
# The flag maze is not the bug. There IS a guard (`$DETECTED_CICD &&
# INCLUDE_CICD=false`) and it works on the explicit path: `-y --ci` on a project
# that already has CI preserves it (arm below). It never fires on the --preset
# path, because a trace of the failing run shows DETECTED_CICD assigned exactly
# once — its initialiser — so detect_stack never ran there.
#
# Fixing that one branch would protect that one branch. These tests pin the
# property at the point of harm instead: install_cicd_files and
# install_hooks_files did `cp -r` with no existence check, so EVERY path that
# reached them overwrote. A file the project already has is the project's.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
    PROJ="$TEST_DIR/proj"
    mkdir -p "$PROJ"
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# The property: what the project already has, it keeps.
# =============================================================================

@test "install: an existing workflow is not overwritten" {
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: MY OWN CI\njobs:\n  build:\n    runs-on: ubuntu-latest\n' \
        > "$PROJ/.github/workflows/ci.yml"
    local before; before=$(cat "$PROJ/.github/workflows/ci.yml")

    run bash "$NEW_PROJECT_SCRIPT" -y --ci "$PROJ"
    [ "$status" -eq 0 ]
    [ "$(cat "$PROJ/.github/workflows/ci.yml")" = "$before" ]
}

@test "install: an existing workflow survives the --preset path too" {
    # The path that actually caused the loss: the preset carries defaults.ci,
    # and its branch never ran the detection the explicit path relies on.
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: MY OWN CI\njobs:\n  build:\n    runs-on: ubuntu-latest\n' \
        > "$PROJ/.github/workflows/ci.yml"
    local before; before=$(cat "$PROJ/.github/workflows/ci.yml")

    run bash "$NEW_PROJECT_SCRIPT" -y --preset homelab-proxmox "$PROJ"
    [ "$status" -eq 0 ]
    [ "$(cat "$PROJ/.github/workflows/ci.yml")" = "$before" ]
}

@test "install: an existing husky hook is not overwritten" {
    mkdir -p "$PROJ/.husky"
    printf '#!/usr/bin/env sh\necho "my own pre-commit"\n' > "$PROJ/.husky/pre-commit"
    local before; before=$(cat "$PROJ/.husky/pre-commit")

    run bash "$NEW_PROJECT_SCRIPT" -y --hooks "$PROJ"
    [ "$status" -eq 0 ]
    [ "$(cat "$PROJ/.husky/pre-commit")" = "$before" ]
}

@test "install: an existing lint/commit config is not overwritten" {
    printf '{"my":"own lintstaged"}\n' > "$PROJ/.lintstagedrc.json"
    local before; before=$(cat "$PROJ/.lintstagedrc.json")

    run bash "$NEW_PROJECT_SCRIPT" -y --hooks "$PROJ"
    [ "$status" -eq 0 ]
    [ "$(cat "$PROJ/.lintstagedrc.json")" = "$before" ]
}

# =============================================================================
# Anti-vacuity: the installer must still install. Without these, a fix that
# simply stopped writing anything would pass every case above.
# =============================================================================

@test "install: a workflow the project does NOT have is still installed" {
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: MY OWN CI\n' > "$PROJ/.github/workflows/ci.yml"

    run bash "$NEW_PROJECT_SCRIPT" -y --ci "$PROJ"
    [ "$status" -eq 0 ]
    # security.yml is the foundation's and the project has no such file.
    [ -f "$PROJ/.github/workflows/security.yml" ]
}

@test "install: on a project with no CI at all, the foundation's ci.yml lands" {
    run bash "$NEW_PROJECT_SCRIPT" -y --ci "$PROJ"
    [ "$status" -eq 0 ]
    [ -f "$PROJ/.github/workflows/ci.yml" ]
    grep -q "name:" "$PROJ/.github/workflows/ci.yml"
}

@test "install: a kept file is REPORTED, not silently skipped" {
    # Silence is the failure mode this repository keeps meeting: a guard that
    # protects without saying so leaves the user believing the install applied.
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: MY OWN CI\n' > "$PROJ/.github/workflows/ci.yml"

    run bash "$NEW_PROJECT_SCRIPT" -y --ci "$PROJ"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ci.yml"* ]]
    [[ "$output" == *"kept"* ]] || [[ "$output" == *"Kept"* ]]
}
