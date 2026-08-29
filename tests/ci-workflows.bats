#!/usr/bin/env bats

# =============================================================================
# Drift guards for the CI/CD enforcement surface (.github/workflows/*.yml,
# .husky/pre-commit, scripts/preflight.sh). Pass-3 audit findings: gates that
# LOOK enforcing but are decorative rot silently — the release "Validate" step
# ran with `|| true`, the PR-title gate skipped `edited` events, install.sh
# (the curl|bash entry point) was outside every shellcheck run, and the husky
# counts self-heal fired on a narrower input set than the CI counts gate reads.
# These pins fail the day someone reintroduces one of those holes.
# =============================================================================

load 'test_helper'

WORKFLOWS="$BASE_DIR/.github/workflows"

@test "release.yml: the Validate step is enforcing (no || true)" {
    grep -q 'validate.sh' "$WORKFLOWS/release.yml"
    ! grep -E 'validate\.sh[^|]*\|\|[[:space:]]*true' "$WORKFLOWS/release.yml"
}

@test "pr-check.yml: title/WIP gates re-run when the PR title is edited" {
    grep -qE 'types:.*edited|^\s+- edited' "$WORKFLOWS/pr-check.yml" || \
        grep -A4 'types:' "$WORKFLOWS/pr-check.yml" | grep -q 'edited'
}

@test "ci.yml: shellcheck also covers install.sh and bin/claude-base" {
    grep -A5 'action-shellcheck' "$WORKFLOWS/ci.yml" | grep -q 'additional_files'
    grep -A5 'action-shellcheck' "$WORKFLOWS/ci.yml" | grep -q 'install.sh'
    grep -A5 'action-shellcheck' "$WORKFLOWS/ci.yml" | grep -q 'claude-base'
}

@test "security.yml: shellcheck also covers install.sh and bin/claude-base" {
    grep -A5 'action-shellcheck' "$WORKFLOWS/security.yml" | grep -q 'install.sh'
    grep -A5 'action-shellcheck' "$WORKFLOWS/security.yml" | grep -q 'claude-base'
}

@test "preflight: shellcheck gate includes install.sh and bin/claude-base" {
    grep -qE 'shellcheck[^"]*install\.sh' "$BASE_DIR/scripts/preflight.sh"
    grep -qE 'shellcheck[^"]*bin/claude-base' "$BASE_DIR/scripts/preflight.sh"
}

@test "husky pre-commit: self-heal trigger covers every counts-gate input class" {
    # website/scripts/generate-counts.ts reads presets, the vendor-skills
    # recipe (via docs/), the minimal manifest and VERSION in addition to
    # .claude/{commands,agents,skills,rules}. NOT tests/*.bats: the test
    # counters stopped being tracked (specs/guardrail-cleanup, US4), so a
    # test-only commit no longer feeds any counted artifact; sync-docs.ts
    # mirrors all of docs/. A class missing from the husky regex commits
    # cleanly locally and fails the CI counts gate ("forgot to regenerate").
    local hook="$BASE_DIR/.husky/pre-commit"
    grep -q 'claude/(commands|agents|skills|rules|presets)' "$hook"
    grep -q 'presets' "$hook"
    grep -q 'docs/' "$hook"
    grep -q 'minimal-manifest' "$hook"
    grep -q 'VERSION' "$hook"
}

# --- Self-application: the release gate must be able to hold on the real repo

@test "validate.sh self-application: the real foundation validates clean (exit 0)" {
    run bash "$BASE_DIR/scripts/validate.sh" "$BASE_DIR"
    [ "$status" -eq 0 ]
}
