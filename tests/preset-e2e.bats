#!/usr/bin/env bats

# =============================================================================
# End-to-end tests per preset.
# For each maintainer-vouched preset, bootstrap a project via
# new-project.sh --preset, run validate.sh + doctor.sh, then assert every
# hook script referenced by the bootstrapped settings.json exists on disk
# (drift-guard against the v1.36.1 regression class — install completes
# but hooks point at missing files).
# See specs/presets-detection-and-e2e/spec.md US-3 (EF-012, EF-013, EF-014).
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"
VALIDATE="$BASE_DIR/scripts/validate.sh"
DOCTOR="$BASE_DIR/scripts/doctor.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Stub the claude CLI so doctor's exit code reflects the bootstrapped
    # project's health, not the CI runner's missing binary.
    stub_claude_on_path
}

teardown() {
    teardown_test_dir
}

# Helper: bootstrap a preset into $TEST_DIR/proj-<name> and echo the path.
# Asserts the install exited 0 and produced a .claude/ tree.
e2e_bootstrap() {
    local preset="$1"
    local target="$TEST_DIR/proj-$preset"
    "$NEW_PROJECT" --preset "$preset" "$target" >/dev/null 2>&1
    [ -d "$target/.claude" ] || return 1
    echo "$target"
}

# Helper: every scripts/hooks/*.sh referenced by the bootstrapped
# settings.json must resolve to an existing file in the target tree.
# Returns 1 with a descriptive stderr message when any reference is broken.
e2e_check_hooks() {
    local target="$1"
    local settings="$target/.claude/settings.json"
    [ -f "$settings" ] || return 0  # no settings = no hooks to check
    local hook missing=()
    while IFS= read -r hook; do
        [ -z "$hook" ] && continue
        if [ ! -f "$target/$hook" ]; then
            missing+=("$hook")
        fi
    done < <(grep -oE 'scripts/hooks/[a-zA-Z0-9_-]+\.sh' "$settings" | sort -u)
    if [ "${#missing[@]}" -gt 0 ]; then
        echo "Missing hooks in $target:" >&2
        printf '  - %s\n' "${missing[@]}" >&2
        return 1
    fi
    return 0
}

# =============================================================================
# Sanity
# =============================================================================

@test "preset-e2e: helper scripts exist" {
    [ -x "$NEW_PROJECT" ]
    [ -x "$VALIDATE" ]
    [ -x "$DOCTOR" ]
}

# =============================================================================
# Per-preset bootstrap + validate.sh + doctor.sh + hook drift-guard.
# One @test per preset for diagnostic clarity (failure message names which
# preset broke).
# =============================================================================

@test "preset-e2e: nextjs bootstraps, validates, and ships every referenced hook" {
    local target
    target=$(e2e_bootstrap nextjs)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

@test "preset-e2e: fastapi bootstraps, validates, and ships every referenced hook" {
    local target
    target=$(e2e_bootstrap fastapi)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

@test "preset-e2e: astro bootstraps, validates, and ships every referenced hook" {
    local target
    target=$(e2e_bootstrap astro)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

@test "preset-e2e: homelab-proxmox bootstraps, validates, and ships every referenced hook" {
    local target
    target=$(e2e_bootstrap homelab-proxmox)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

@test "preset-e2e: cli-tools bootstraps, validates, and ships every referenced hook" {
    local target
    target=$(e2e_bootstrap cli-tools)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

# =============================================================================
# Self-check (T042): the drift-guard MUST fail when a referenced hook is
# missing. Without this, a silently-passing assertion would leave the same
# failure mode that produced v1.36.1 undetected.
# =============================================================================

@test "preset-e2e: react-vite-spa bootstraps, validates, and ships every referenced hook (T023)" {
    local target
    target=$(e2e_bootstrap react-vite-spa)
    [ -d "$target/.claude" ]

    run "$VALIDATE" -q "$target"
    [ "$status" -eq 0 ]

    run "$DOCTOR" "$target"
    [ "$status" -eq 0 ]  # a cleanly bootstrapped preset must pass doctor

    e2e_check_hooks "$target"
}

@test "preset-e2e: hook drift-guard fails when a referenced hook is missing (self-check)" {
    local target
    target=$(e2e_bootstrap nextjs)
    [ -d "$target/.claude" ]

    # Sanity: hook check passes on a clean install.
    e2e_check_hooks "$target"

    # Identify a referenced hook and delete it.
    local first_hook
    first_hook=$(grep -oE 'scripts/hooks/[a-zA-Z0-9_-]+\.sh' "$target/.claude/settings.json" | sort -u | head -1)
    [ -n "$first_hook" ]
    [ -f "$target/$first_hook" ]
    rm -f "$target/$first_hook"

    # The helper must now report failure with a precise message.
    run e2e_check_hooks "$target"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Missing hooks"* ]]
    [[ "$output" == *"$first_hook"* ]]
}
