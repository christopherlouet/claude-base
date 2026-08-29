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

# _trigger_regex — the counts self-heal trigger as the hook actually applies it.
# Pinning the regex by SUBSTRING is what let a documentation gap through on
# 2026-08-29: `grep -q VERSION` matched the surrounding prose comment, not the
# pattern, so dropping `^VERSION$` from the trigger would not have failed
# anything. Extract the literal and test the BEHAVIOUR — does this path fire the
# hook — one class at a time.
_trigger_regex() {
    sed -nE "s/.*grep -qE '([^']*)'.*/\1/p" "$BASE_DIR/.husky/pre-commit" | head -1
}

# _fires <path> — would a commit staging this path trigger the self-heal?
_fires() { printf '%s\n' "$1" | grep -qE "$(_trigger_regex)"; }

@test "husky pre-commit: the trigger regex can be extracted and is not empty" {
    # Without this, every arm below would be vacuous: an empty regex matches
    # everything, so every "fires" assertion would pass and every "does not
    # fire" assertion would be the only thing failing.
    local re
    re="$(_trigger_regex)"
    [ -n "$re" ]
    [[ "$re" == *"claude/"* ]]
}

@test "husky pre-commit: self-heal fires for every counts-gate input class" {
    # website/scripts/generate-counts.ts reads presets, the marketplace pilot
    # specs, the vendor-skills recipe (via docs/), the minimal manifest and
    # VERSION in addition to .claude/{commands,agents,skills,rules}. A class
    # missing from the trigger commits cleanly locally and fails the CI counts
    # gate ("forgot to regenerate" — the top lesson of this repo).
    _fires ".claude/commands/work/work-quick.md"
    _fires ".claude/agents/qa-audit.md"
    _fires ".claude/skills/dev-tdd/SKILL.md"
    _fires ".claude/rules/testing.md"
    _fires ".claude/presets/saas.json"
    _fires "docs/reference/commands.md"
    _fires "specs/marketplace-audit/growth-skills-pilot-2026-05-21.md"
    _fires "scripts/lib/minimal-manifest.txt"
    _fires "VERSION"
}

@test "husky pre-commit: self-heal does NOT fire for paths feeding no counter" {
    # The other half of the contract: a trigger that fires on everything would
    # pass every arm above while running node on every commit. NOT tests/*.bats
    # since the test counters stopped being tracked (specs/guardrail-cleanup,
    # US4), and not the generated website mirror.
    ! _fires "README.md"
    ! _fires "tests/ci-workflows.bats"
    ! _fires "scripts/validate-counts.sh"
    ! _fires "website/docs/reference/commands.md"
    ! _fires "VERSIONING.md"
    ! _fires "specs/guardrail-cleanup/spec.md"
}

# --- Self-application: the release gate must be able to hold on the real repo

@test "validate.sh self-application: the real foundation validates clean (exit 0)" {
    run bash "$BASE_DIR/scripts/validate.sh" "$BASE_DIR"
    [ "$status" -eq 0 ]
}
