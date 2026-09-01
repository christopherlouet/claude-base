#!/usr/bin/env bats

# =============================================================================
# Tests for the .husky hooks an install puts into a DOWNSTREAM project.
#
# The foundation's own .husky/* invoke foundation-only scripts: the private
# names check, the derived-counts self-heal, and preflight. None of the three
# is in scripts/lib/minimal-manifest.txt, so an install never puts them in the
# target. Copying .husky verbatim therefore ships hooks that call files which
# are not there — and because git-hooks-wire.sh sets core.hooksPath on the
# first Claude session, those hooks go live and refuse EVERY commit and push.
#
# Measured on a real install before the fix: the commit was refused with
# "bash: scripts/private-names-check.sh: No such file or directory", and the
# same commit with core.hooksPath unset succeeded. Both failure modes the
# guardrail-cleanup spec names appear here in sequence — a gate reported as
# installed while inert, then a gate that blocks all work.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
BASE_REPO="$BATS_TEST_DIRNAME/.."

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Every script path a hook actually INVOKES. Comments are stripped first: the
# foundation's pre-commit names its scripts in prose as well as in code, and a
# scanner that cannot tell the two apart would report the fixed file as broken.
invoked_scripts() {
    sed 's/#.*//' "$@" 2>/dev/null \
        | grep -oE '[A-Za-z0-9_.][A-Za-z0-9_./-]*\.sh' \
        | sort -u
}

# Installs a project with hooks into $TEST_DIR/proj and echoes its path.
install_with_hooks() {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    git -C "$proj" init -q
    bash "$NEW_PROJECT_SCRIPT" --simple --hooks -y "$proj" >/dev/null 2>&1
    printf '%s' "$proj"
}

# =============================================================================
# Anti-vacuity control — the scanner must be shown capable of a positive first.
# A grep that matches nothing looks exactly like a file with nothing to find.
# =============================================================================

@test "husky scanner: sees the invocations in the foundation's own pre-commit" {
    run invoked_scripts "$BASE_REPO/.husky/pre-commit"
    [ "$status" -eq 0 ]
    [[ "$output" == *"private-names-check.sh"* ]]
    [[ "$output" == *"sync-counts.sh"* ]]
}

@test "husky scanner: ignores a script named only in a comment" {
    printf '#!/usr/bin/env sh\n# see scripts/mentioned-only.sh for details\necho ok\n' \
        > "$TEST_DIR/hook-fixture"
    run invoked_scripts "$TEST_DIR/hook-fixture"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# The structural claim: an installed hook may only call what the install ships.
# =============================================================================

@test "install --hooks: every script an installed husky hook calls exists" {
    local proj; proj=$(install_with_hooks)
    [ -d "$proj/.husky" ]

    local missing=""
    local hook script
    for hook in "$proj"/.husky/*; do
        [ -f "$hook" ] || continue
        while IFS= read -r script; do
            [ -n "$script" ] || continue
            [ -e "$proj/$script" ] || missing="$missing $(basename "$hook"):$script"
        done < <(invoked_scripts "$hook")
    done

    # Collected, then asserted once: `! cmd` is exempt from set -e, so a negated
    # assertion inside the loop could not fail the case.
    [ -z "$missing" ] || {
        echo "hooks call scripts the install does not ship:$missing" >&2
        false
    }
}

@test "install --hooks: no installed hook calls a foundation-only script" {
    local proj; proj=$(install_with_hooks)
    run invoked_scripts "$proj"/.husky/*
    [ "$status" -eq 0 ]
    [[ "$output" != *"private-names-check.sh"* ]]
    [[ "$output" != *"sync-counts.sh"* ]]
    [[ "$output" != *"preflight.sh"* ]]
}

# =============================================================================
# The behavioural claim: the thing the defect actually broke.
# =============================================================================

@test "install --hooks: a commit still passes once the hooks are wired" {
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky

    echo "hello" > "$proj/readme.txt"
    git -C "$proj" add -A
    git -C "$proj" -c user.email=probe@example.invalid -c user.name=probe \
        commit -m "test: probe commit" >/dev/null 2>&1 || true

    # Asserted by EFFECT, not by exit status: the commit either exists or it
    # does not, and a status read through a pipe reports the wrong stage.
    run git -C "$proj" log --oneline
    [ "$status" -eq 0 ]
    [[ "$output" == *"probe commit"* ]]
}

@test "install --hooks: commit-msg is still shipped and stays tool-tolerant" {
    local proj; proj=$(install_with_hooks)
    [ -f "$proj/.husky/commit-msg" ]
    # Guarded on both npx and package.json: absent either, it must no-op rather
    # than refuse — a hook nobody feeds must not block a commit.
    grep -q 'command -v npx' "$proj/.husky/commit-msg"
    grep -q 'package.json' "$proj/.husky/commit-msg"
}
