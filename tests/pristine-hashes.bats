#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/gen-pristine-hashes.sh and the table it writes,
# scripts/lib/pristine-hashes.txt.
#
# `update` cannot tell a hook script left untouched since an OLDER foundation
# version from one the user customised: both simply differ from today's copy.
# So it skipped both without --force, and --force overwrote real
# customisations along with them. Measured 2026-09-15 on a v5.3.0 install
# updated to v5.5.0: even `update --hook-scripts` and `update --all` left
# _policy-dangerous-commands.sh, _policy-secrets.sh, _policy-write-targets.sh,
# main-branch-guard.sh, setup-deps.sh and substance-check.sh on their v5.3.0
# rules, while stamping 5.5.0.
#
# The table records the sha256 of every version of those files the foundation
# ever shipped. A copy whose hash is in it is a foundation copy nobody edited,
# and update can replace it. Installs are `git clone --depth 1`, so history is
# not available at update time: the table has to be computed here and shipped.
# =============================================================================

load 'test_helper'

GEN="$BASE_DIR/scripts/gen-pristine-hashes.sh"

setup() {
    setup_test_dir
    REPO="$TEST_DIR/repo"
    mkdir -p "$REPO/scripts/hooks" "$REPO/scripts/lib"
    git -C "$REPO" init -q
    git -C "$REPO" config user.email t@t
    git -C "$REPO" config user.name t
}

teardown() {
    teardown_test_dir
}

commit_all() {
    git -C "$REPO" add -A
    git -C "$REPO" commit -qm "$1"
}

sha_of() {
    printf '%s' "$1" | { sha256sum 2>/dev/null || shasum -a 256; } | cut -d' ' -f1
}

run_gen() {
    run env PRISTINE_ROOT="$REPO" bash "$GEN" "$@"
}

TABLE_REL="scripts/lib/pristine-hashes.txt"

# =============================================================================
# Generation
# =============================================================================

@test "gen: records every version of a hook script, not only the current one" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"; commit_all two
    printf 'v3\n' > "$REPO/scripts/hooks/guard.sh"; commit_all three

    run_gen
    [ "$status" -eq 0 ]
    # Three versions: with two, the last change alone names both.
    grep -qx "$(sha_of $'v1\n') scripts/hooks/guard.sh" "$REPO/$TABLE_REL"
    grep -qx "$(sha_of $'v2\n') scripts/hooks/guard.sh" "$REPO/$TABLE_REL"
    grep -qx "$(sha_of $'v3\n') scripts/hooks/guard.sh" "$REPO/$TABLE_REL"
}

@test "gen: records the support script substance-check.sh" {
    printf 'detector\n' > "$REPO/scripts/substance-check.sh"; commit_all one

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'detector\n') scripts/substance-check.sh" "$REPO/$TABLE_REL"
}

@test "gen: keeps the versions of a hook that was later deleted" {
    # An old install still carries it; the table is about what shipped.
    printf 'old\n' > "$REPO/scripts/hooks/retired.sh"; commit_all one
    git -C "$REPO" rm -q scripts/hooks/retired.sh; commit_all two

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'old\n') scripts/hooks/retired.sh" "$REPO/$TABLE_REL"
}

@test "gen: ignores files outside the managed set" {
    printf 'x\n' > "$REPO/scripts/hooks/README.md"
    printf 'x\n' > "$REPO/scripts/other.sh"
    printf 'real\n' > "$REPO/scripts/hooks/guard.sh"
    commit_all one

    run_gen
    [ "$status" -eq 0 ]
    # `! grep` does not fail a bats test unless it is the last command.
    if grep -q 'README.md' "$REPO/$TABLE_REL"; then return 1; fi
    if grep -q 'scripts/other.sh' "$REPO/$TABLE_REL"; then return 1; fi
    grep -q 'scripts/hooks/guard.sh' "$REPO/$TABLE_REL"
}

@test "gen: records content that only a merge commit introduced" {
    # A conflict resolved in a merge has no post-image in `git log --raw`
    # without -m: the next full rewrite of the table dropped it.
    printf 'base\n' > "$REPO/scripts/hooks/guard.sh"; commit_all base
    git -C "$REPO" checkout -q -b side
    printf 'side\n' > "$REPO/scripts/hooks/guard.sh"; commit_all side
    git -C "$REPO" checkout -q -
    printf 'main\n' > "$REPO/scripts/hooks/guard.sh"; commit_all main
    git -C "$REPO" merge -q side >/dev/null 2>&1 || true
    printf 'resolved\n' > "$REPO/scripts/hooks/guard.sh"; commit_all merge
    # A later version replaces it, so neither HEAD nor the index holds it.
    printf 'later\n' > "$REPO/scripts/hooks/guard.sh"; commit_all later

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'resolved\n') scripts/hooks/guard.sh" "$REPO/$TABLE_REL"
}

@test "gen: includes a staged version not committed yet (pre-commit use)" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"
    git -C "$REPO" add scripts/hooks/guard.sh

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'v2\n') scripts/hooks/guard.sh" "$REPO/$TABLE_REL"
}

@test "gen: output is deterministic" {
    printf 'a\n' > "$REPO/scripts/hooks/a.sh"
    printf 'b\n' > "$REPO/scripts/hooks/b.sh"
    commit_all one

    run_gen
    cp "$REPO/$TABLE_REL" "$TEST_DIR/first"
    run_gen
    cmp -s "$TEST_DIR/first" "$REPO/$TABLE_REL"
}

@test "gen: refuses a shallow clone instead of writing a truncated table" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"; commit_all two
    git clone -q --depth 1 "file://$REPO" "$TEST_DIR/shallow"

    run env PRISTINE_ROOT="$TEST_DIR/shallow" bash "$GEN"
    [ "$status" -eq 2 ]
    [[ "$output" == *"shallow"* ]]
    [ ! -e "$TEST_DIR/shallow/$TABLE_REL" ]
}

# =============================================================================
# --check
# =============================================================================

@test "check: passes on a freshly generated table" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    run_gen --check
    [ "$status" -eq 0 ]
}

@test "check: fails and names the path when a shipped version is missing" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"; commit_all two
    run_gen
    grep -v "$(sha_of $'v1\n')" "$REPO/$TABLE_REL" > "$TEST_DIR/t" && mv "$TEST_DIR/t" "$REPO/$TABLE_REL"

    run_gen --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"scripts/hooks/guard.sh"* ]]
}

@test "check: fails when the table is absent" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen --check
    [ "$status" -eq 1 ]
}

@test "check: tolerates an extra entry (a squash merge drops intermediate commits)" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'intermediate\n')" >> "$REPO/$TABLE_REL"

    run_gen --check
    [ "$status" -eq 0 ]
}

@test "check: never writes the table" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen --check
    [ ! -e "$REPO/$TABLE_REL" ]
}

# =============================================================================
# Self-application: the committed table covers the foundation's real history.
# =============================================================================

@test "self-application: the committed table covers every shipped hook version" {
    [ "$(git -C "$BASE_DIR" rev-parse --is-shallow-repository)" = "false" ] \
        || skip "shallow clone: the history the table is derived from is not here"
    run bash "$GEN" --check
    [ "$status" -eq 0 ] || { printf '%s\n' "$output" >&2; return 1; }
    # Not vacuous: the real table holds more than the current files.
    [ "$(grep -c ' scripts/hooks/' "$BASE_DIR/$TABLE_REL")" -gt "$(ls "$BASE_DIR"/scripts/hooks/*.sh | wc -l)" ]
}

# =============================================================================
# The lookup update relies on.
# =============================================================================

@test "lookup: a copy whose hash is in the table is a known foundation copy" {
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'v1\n')" > "$TEST_DIR/table"
    printf 'v1\n' > "$TEST_DIR/guard.sh"
    PRISTINE_HASHES_FILE="$TEST_DIR/table" run is_known_foundation_copy scripts/hooks/guard.sh "$TEST_DIR/guard.sh"
    [ "$status" -eq 0 ]
}

@test "lookup: an edited copy is not" {
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'v1\n')" > "$TEST_DIR/table"
    printf 'v1 plus my change\n' > "$TEST_DIR/guard.sh"
    PRISTINE_HASHES_FILE="$TEST_DIR/table" run is_known_foundation_copy scripts/hooks/guard.sh "$TEST_DIR/guard.sh"
    [ "$status" -ne 0 ]
}

@test "lookup: the hash must belong to THAT path" {
    # Content shipped as another hook is not a pristine copy of this one.
    printf '%s scripts/hooks/other.sh\n' "$(sha_of $'v1\n')" > "$TEST_DIR/table"
    printf 'v1\n' > "$TEST_DIR/guard.sh"
    PRISTINE_HASHES_FILE="$TEST_DIR/table" run is_known_foundation_copy scripts/hooks/guard.sh "$TEST_DIR/guard.sh"
    [ "$status" -ne 0 ]
}

@test "lookup: no table means not known (never a blanket overwrite)" {
    printf 'v1\n' > "$TEST_DIR/guard.sh"
    PRISTINE_HASHES_FILE="$TEST_DIR/absent" run is_known_foundation_copy scripts/hooks/guard.sh "$TEST_DIR/guard.sh"
    [ "$status" -ne 0 ]
}
