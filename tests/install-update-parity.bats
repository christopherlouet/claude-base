#!/usr/bin/env bats

# =============================================================================
# install ≡ update: the selection must survive the first update.
#
# install.sh computes WHAT ships from the selection seam (compute_selected_set:
# preset filters, module ownership, the per-stack rules whitelist). update.sh
# re-derives the same decision on its own, file by file. Nothing kept the two
# in agreement — so an item install deliberately EXCLUDED could be deposited by
# the very next `update --all`, silently undoing the install-time selection.
#
# The guard: for representative configs, `install` then `update --all --force`
# must leave the set of manifest-driven files UNCHANGED — nothing added
# (selection respected) and nothing removed (EF-011: update is copy-only).
#
# A negative probe plants a divergence and asserts the comparison catches it.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# _snapshot <project_dir> <out_file> — the project's installed file set,
# repo-relative and sorted. Backup trees are update's own bookkeeping
# (.claude/commands.backup.<ts>/, .claude.backup.<ts>/), never selection.
_snapshot() {
    (cd "$1" && find .claude scripts -type f 2>/dev/null \
        | grep -v 'backup\.' \
        | LC_ALL=C sort) > "$2"
}

# _assert_parity <install flags...> — install, snapshot, update --all --force,
# snapshot, compare both directions. Leaves the two snapshots in $TEST_DIR.
_assert_parity() {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"

    run "$NEW_PROJECT_SCRIPT" -y "$@" "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/after-install"
    # Non-empty first: a broken find would make both directions vacuously green.
    [ -s "$TEST_DIR/after-install" ]

    run "$UPDATE_SCRIPT" -y --all --force "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/after-update"
    [ -s "$TEST_DIR/after-update" ]

    local added removed
    added=$(comm -13 "$TEST_DIR/after-install" "$TEST_DIR/after-update")
    removed=$(comm -23 "$TEST_DIR/after-install" "$TEST_DIR/after-update")

    if [ -n "$added" ]; then
        echo "update deposited files the install excluded:" >&2
        printf '%s\n' "$added" >&2
        return 1
    fi
    if [ -n "$removed" ]; then
        echo "update removed installed files (EF-011 says copy-only):" >&2
        printf '%s\n' "$removed" >&2
        return 1
    fi
    return 0
}

@test "parity: update --all adds nothing to a simple (generic) install" {
    _assert_parity --simple
}

@test "parity: update --all does not deposit foreign stack rules on a python install" {
    _assert_parity --simple --type python
    # The stack is recorded — that field is what makes the selection durable.
    run bash -c "jq -r '.projectType' '$TEST_DIR/proj/.claude/foundation.json'"
    [ "$output" = "python" ]
    # The whitelist really bit: a python project has python.md and none of the
    # web/mobile framework rules — before AND after the update.
    [ -f "$TEST_DIR/proj/.claude/rules/python.md" ]
    [ ! -f "$TEST_DIR/proj/.claude/rules/react.md" ]
    [ ! -f "$TEST_DIR/proj/.claude/rules/flutter.md" ]
}

@test "parity: base-maintenance.md (foundation-internal) never reaches a project" {
    _assert_parity --simple
    [ ! -f "$TEST_DIR/proj/.claude/rules/base-maintenance.md" ]
}

@test "update reports the rules it left out, naming the recorded stack" {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple --type go "$proj"
    [ "$status" -eq 0 ]
    # Wipe the rules so the update has real work to do (and real skips).
    rm -f "$proj/.claude/rules/"*.md

    run "$UPDATE_SCRIPT" -y --rules "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Outside the project stack (skipped)"* ]]
    [[ "$output" == *"'go' whitelist"* ]]
    # And the whitelist was applied, not just announced.
    [ -f "$proj/.claude/rules/go.md" ]
    [ ! -f "$proj/.claude/rules/react.md" ]
}

@test "legacy project (no projectType recorded): update still ships every rule" {
    # A project installed before the field existed has no recorded stack. The
    # whitelist must NOT be guessed there — update keeps refreshing the whole
    # rules dir, exactly as it did before. No silent change under users' feet.
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple --type python "$proj"
    [ "$status" -eq 0 ]

    # Age the manifest back to a pre-projectType install.
    local mf="$proj/.claude/foundation.json"
    jq 'del(.projectType)' "$mf" > "$mf.tmp" && mv "$mf.tmp" "$mf"
    run bash -c "jq -r 'has(\"projectType\")' '$mf'"
    [ "$output" = "false" ]

    run "$UPDATE_SCRIPT" -y --all --force "$proj"
    [ "$status" -eq 0 ]

    # Old behaviour preserved: foreign rules land again...
    [ -f "$proj/.claude/rules/react.md" ]
    [ -f "$proj/.claude/rules/flutter.md" ]
    # ...but the foundation-internal one never does, legacy included.
    [ ! -f "$proj/.claude/rules/base-maintenance.md" ]
    # And the summary must not invent a whitelist this project has no stack
    # for: withholding base-maintenance is not "outside the generic whitelist".
    [[ "$output" != *"whitelist"* ]]
}

@test "parity negative probe: a planted extra file IS flagged" {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/a"
    # Stand in for "update deposited something the install excluded".
    touch "$proj/.claude/rules/planted-divergence.md"
    _snapshot "$proj" "$TEST_DIR/b"

    local added
    added=$(comm -13 "$TEST_DIR/a" "$TEST_DIR/b")
    [[ "$added" == *"planted-divergence.md"* ]]
}
