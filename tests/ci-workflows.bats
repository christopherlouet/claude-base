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
    ! grep -E 'validate\.sh[^|]*\|\|[[:space:]]*true' "$WORKFLOWS/release.yml" || false
}

@test "pr-check.yml: title/WIP gates re-run when the PR title is edited" {
    grep -qE 'types:.*edited|^\s+- edited' "$WORKFLOWS/pr-check.yml" || \
        grep -A4 'types:' "$WORKFLOWS/pr-check.yml" | grep -q 'edited'
}

# job_of <file> <pattern> — the jobs: block (2-space key and its body) whose
# text matches <pattern>; empty when none does. Comment lines are dropped: one
# explaining a job sits above its key, inside the block before.
job_of() {
    awk -v pat="$2" '
        /^jobs:/ { j = 1; next }
        /^[[:space:]]*#/ { next }
        j && /^  [A-Za-z0-9_-]+:/ { if (buf ~ pat) printf "%s", buf; buf = "" }
        j { buf = buf $0 "\n" }
        END { if (buf ~ pat) printf "%s", buf }' "$1"
}

# The size labeler writes (a label) and only it may: its own job gets
# pull-requests: write, the title/commit/WIP job keeps the read-only default.
# It is pinned to a commit — its floating v1 tag moved on 2026-09-28 and
# started failing on the permission the workflow never granted.
@test "pr-check.yml: only the size-label job may write, and it is pinned to a commit" {
    local label validate
    label=$(job_of "$WORKFLOWS/pr-check.yml" 'pr-size-labeler@')
    validate=$(job_of "$WORKFLOWS/pr-check.yml" 'action-semantic-pull-request')
    [ -n "$label" ] && [ -n "$validate" ]
    [ "$label" != "$validate" ]
    printf '%s' "$label" | grep -qE '^\s+pull-requests:\s*write'
    printf '%s' "$label" | grep -qE 'pr-size-labeler@[0-9a-f]{40}\b'
    if printf '%s' "$validate" | grep -qE ':\s*write'; then echo "Validate PR job can write" >&2; return 1; fi
    if grep -E '^permissions:' -A4 "$WORKFLOWS/pr-check.yml" | grep -qE ':\s*write'; then echo "workflow-wide write" >&2; return 1; fi
}

# A tag is a pointer its owner can move: the size labeler's `v1` changed
# behaviour under us on 2026-09-28 (#615). Every action from another repo is
# pinned to a full commit SHA, its version in a trailing comment; Dependabot
# (github-actions ecosystem) bumps both.
_unpinned_actions() {
    grep -nE '^[[:space:]-]*uses:[[:space:]]*[^.[:space:]][^[:space:]]*@' "$@" \
        | grep -vE 'uses:[[:space:]]*docker://' \
        | grep -vE '@[0-9a-f]{40}[[:space:]]+#[[:space:]]*v?[0-9]+(\.[0-9]+)*[[:space:]]*$' || true
}

@test "workflows: every external action is pinned to a commit SHA with its version" {
    run _unpinned_actions "$WORKFLOWS"/*.yml
    [ -z "$output" ] || { echo "actions on a movable ref:" >&2; echo "$output" >&2; return 1; }
}

@test "workflows: the pin guard is not vacuous — it flags tags, short SHAs and bare SHAs" {
    local f="$BATS_TEST_TMPDIR/w.yml"
    printf '%s\n' \
        '      - uses: actions/checkout@v7' \
        '        uses: a/b@0123456789abcdef0123456789abcdef01234567 # v1.2.3' \
        '        uses: a/c@0123456 # v1' \
        '        uses: a/d@0123456789abcdef0123456789abcdef01234567' \
        '        uses: ./.github/actions/local' \
        '        uses: docker://alpine:3' > "$f"
    run _unpinned_actions "$f"
    [ "$(printf '%s\n' "$output" | cut -d: -f1 | tr '\n' ' ')" = "1 3 4 " ]
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
    ! _fires "README.md" || false
    ! _fires "tests/ci-workflows.bats" || false
    ! _fires "scripts/validate-counts.sh" || false
    ! _fires "website/docs/reference/commands.md" || false
    ! _fires "VERSIONING.md" || false
    ! _fires "specs/guardrail-cleanup/spec.md" || false
}

# --- Self-application: the release gate must be able to hold on the real repo

@test "validate.sh self-application: the real foundation validates clean (exit 0)" {
    run bash "$BASE_DIR/scripts/validate.sh" "$BASE_DIR"
    [ "$status" -eq 0 ]
}
