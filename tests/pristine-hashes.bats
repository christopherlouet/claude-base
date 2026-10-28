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

@test "gen: records every version of the .claude/ files update refreshes" {
    local f
    for f in skills/x/SKILL.md skills/x/references/r.md agents/a.md rules/r.md \
             commands/c.md commands/ns/c.md output-styles/o.md templates/t/f.md; do
        mkdir -p "$(dirname "$REPO/.claude/$f")"
        printf 'v1\n' > "$REPO/.claude/$f"
    done
    commit_all one
    printf 'v2\n' > "$REPO/.claude/skills/x/SKILL.md"; commit_all two

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'v1\n') .claude/skills/x/SKILL.md" "$REPO/$TABLE_REL"
    grep -qx "$(sha_of $'v2\n') .claude/skills/x/SKILL.md" "$REPO/$TABLE_REL"
    for f in skills/x/references/r.md agents/a.md rules/r.md commands/c.md \
             commands/ns/c.md output-styles/o.md templates/t/f.md; do
        grep -qx "$(sha_of $'v1\n') .claude/$f" "$REPO/$TABLE_REL" || { echo "missing .claude/$f" >&2; return 1; }
    done
}

@test "gen: ignores .claude/ files update never refreshes" {
    mkdir -p "$REPO/.claude/skills/x"
    printf '{}\n' > "$REPO/.claude/settings.json"
    printf 'x\n' > "$REPO/.claude/CLAUDE.local.md"
    printf 'v1\n' > "$REPO/.claude/skills/x/SKILL.md"
    commit_all one

    run_gen
    [ "$status" -eq 0 ]
    if grep -q 'settings.json' "$REPO/$TABLE_REL"; then return 1; fi
    if grep -q 'CLAUDE.local.md' "$REPO/$TABLE_REL"; then return 1; fi
    grep -q '.claude/skills/x/SKILL.md' "$REPO/$TABLE_REL"
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

# --- Append-only (#662) ----------------------------------------------------------
# The table used to be rebuilt from the branch's history alone: every PR added
# its intermediate versions, a squash merge erased those commits, and the next
# branch dropped the entries again. Keeping what the table already lists ends
# the churn without forgetting a version a fleet project may still carry.

_in_table() { grep -qx "$(sha_of "$1") scripts/hooks/guard.sh" "$REPO/$TABLE_REL"; }

@test "gen: keeps the entries of the table it rewrites" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    # A version the history no longer holds (a squash merge erased its commit).
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'gone\n')" >> "$REPO/$TABLE_REL"
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"; commit_all two

    run_gen
    [ "$status" -eq 0 ]
    _in_table $'gone\n' || false
    _in_table $'v1\n' || false
    _in_table $'v2\n' || false
    [ "$(grep -c '^# Generated' "$REPO/$TABLE_REL")" -eq 1 ]
}

@test "gen: no table line is lost across a squash merge and the next branch" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    git -C "$REPO" branch -M main
    run_gen; commit_all table
    # PR 1: two steps, the hook regenerating at each commit.
    git -C "$REPO" checkout -q -b pr1
    printf 'v2\n' > "$REPO/scripts/hooks/guard.sh"; run_gen; commit_all two
    printf 'v3\n' > "$REPO/scripts/hooks/guard.sh"; run_gen; commit_all three
    git -C "$REPO" checkout -q main
    git -C "$REPO" merge -q --squash pr1; git -C "$REPO" commit -qm squash
    cp "$REPO/$TABLE_REL" "$TEST_DIR/main-table"
    # PR 2 touches another managed file.
    git -C "$REPO" checkout -q -b pr2
    printf 'x\n' > "$REPO/scripts/hooks/other.sh"; run_gen; commit_all other

    # Only additions: nothing main's table lists is dropped.
    [ -z "$(LC_ALL=C comm -23 <(LC_ALL=C sort "$TEST_DIR/main-table") <(LC_ALL=C sort "$REPO/$TABLE_REL"))" ]
    _in_table $'v2\n'
}

@test "gen: ignores a malformed line in the table it rewrites" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    printf 'not a hash line\n\n' >> "$REPO/$TABLE_REL"
    grep -q 'not a hash line' "$REPO/$TABLE_REL" || false
    grep -qx '' "$REPO/$TABLE_REL" || false

    run_gen
    [ "$status" -eq 0 ]
    ! grep -q 'not a hash line' "$REPO/$TABLE_REL" || false
    ! grep -qx '' "$REPO/$TABLE_REL" || false
    _in_table $'v1\n'
}

@test "gen: rewrites a table that holds only its header" {
    printf 'readme\n' > "$REPO/README.md"; commit_all one
    run_gen
    [ "$status" -eq 0 ]
    run_gen
    [ "$status" -eq 0 ]
    [ ! -e "$REPO/$TABLE_REL.tmp" ]
}

@test "gen: keeps a line whose path holds a space, drops one outside the managed set" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    printf '%s .claude/skills/x/my notes.md\n' "$(sha_of $'n\n')" >> "$REPO/$TABLE_REL"
    printf '%s README.md\n' "$(sha_of $'r\n')" >> "$REPO/$TABLE_REL"
    grep -q ' README.md$' "$REPO/$TABLE_REL" || false

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'n\n') .claude/skills/x/my notes.md" "$REPO/$TABLE_REL" || false
    ! grep -q ' README.md$' "$REPO/$TABLE_REL" || false
}

# --- Files init copies under another name (#657) -----------------------------
# update refreshes an unmodified .husky hook, .commitlintrc.json and
# .lintstagedrc.mjs. Each is keyed by its INSTALL path: templates/husky/<f> is
# installed as .husky/<f>, and until #540 init copied the foundation's own
# .husky/<f> verbatim, so both histories name versions an install can hold.

@test "gen: records the husky templates and the foundation's own .husky under .husky/" {
    mkdir -p "$REPO/templates/husky" "$REPO/.husky/_"
    printf 't1\n' > "$REPO/templates/husky/pre-commit"
    printf 'own1\n' > "$REPO/.husky/pre-commit"
    printf 'internal\n' > "$REPO/.husky/_/h"
    commit_all one
    printf 't2\n' > "$REPO/templates/husky/pre-commit"; commit_all two

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'t1\n') .husky/pre-commit" "$REPO/$TABLE_REL" || false
    grep -qx "$(sha_of $'t2\n') .husky/pre-commit" "$REPO/$TABLE_REL" || false
    grep -qx "$(sha_of $'own1\n') .husky/pre-commit" "$REPO/$TABLE_REL" || false
    ! grep -q ' templates/husky/' "$REPO/$TABLE_REL" || false
    ! grep -q ' .husky/_/' "$REPO/$TABLE_REL" || false
}

@test "gen: records .commitlintrc.json and the lint-staged template under their install path" {
    mkdir -p "$REPO/templates/lint-staged"
    printf '{}\n' > "$REPO/.commitlintrc.json"
    printf 'export default {}\n' > "$REPO/templates/lint-staged/.lintstagedrc.mjs"
    commit_all one

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'{}\n') .commitlintrc.json" "$REPO/$TABLE_REL" || false
    grep -qx "$(sha_of $'export default {}\n') .lintstagedrc.mjs" "$REPO/$TABLE_REL"
}

@test "gen: records the retired .lintstagedrc.json (shipped before #654)" {
    printf '{"*": "old"}\n' > "$REPO/.lintstagedrc.json"; commit_all one
    git -C "$REPO" rm -q .lintstagedrc.json; commit_all two

    run_gen
    [ "$status" -eq 0 ]
    grep -qx "$(sha_of $'{"*": "old"}\n') .lintstagedrc.json" "$REPO/$TABLE_REL"
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

@test "check: tolerates an extra entry (the table keeps versions a squash merge erased)" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'intermediate\n')" >> "$REPO/$TABLE_REL"

    run_gen --check
    [ "$status" -eq 0 ]
}

# _lost_entry_setup <main-ref> — main's table lists a squash-erased version
# 'gone'; then a branch "feat" is cut. With refs/remotes/origin/main, there is
# no local main, as in CI's PR checkout.
_lost_entry_setup() {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    git -C "$REPO" branch -M trunk
    run_gen
    printf '%s scripts/hooks/guard.sh\n' "$(sha_of $'gone\n')" >> "$REPO/$TABLE_REL"
    commit_all table
    git -C "$REPO" update-ref "$1" HEAD
    git -C "$REPO" checkout -q -b feat
}

@test "check: fails when the table lost a line origin/main's table lists (CI layout)" {
    _lost_entry_setup refs/remotes/origin/main
    rm "$REPO/$TABLE_REL"; run_gen; commit_all rebuilt

    run_gen --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"$(sha_of $'gone\n') scripts/hooks/guard.sh"* ]]
}

@test "check: warns when there is no main to compare removed entries with" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    git -C "$REPO" branch -M trunk
    run_gen
    run_gen --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"removed entries not checked"* ]]
}

@test "check: fails when the table lost a line main's table lists (append-only)" {
    _lost_entry_setup refs/heads/main
    # Control: the branch still lists it, check passes.
    run_gen --check
    [ "$status" -eq 0 ]
    # A rebuild from scratch (a conflict resolved by regenerating) loses it.
    rm "$REPO/$TABLE_REL"; run_gen; commit_all rebuilt

    run_gen --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"$(sha_of $'gone\n') scripts/hooks/guard.sh"* ]]
}

@test "check: never writes the table" {
    printf 'v1\n' > "$REPO/scripts/hooks/guard.sh"; commit_all one
    run_gen --check
    [ ! -e "$REPO/$TABLE_REL" ]
}

# =============================================================================
# Self-application: the committed table covers the foundation's real history.
# =============================================================================

# _pristine_trigger — the regex .husky/pre-commit applies to decide whether to
# regenerate the table (the grep -qE line that names substance-check.sh).
_pristine_trigger() {
    grep -E "grep -qE '.*substance-check" "$BASE_DIR/.husky/pre-commit" \
        | sed -nE "s/.*grep -qE '([^']*)'.*/\1/p" | head -1
}

@test "pre-commit: regenerates the table for every managed path class" {
    # The generator and this trigger must cover the same set: a managed file
    # committed without regenerating leaves the table short, and the
    # self-application test below fails on the next CI run (found in review).
    local re p
    re="$(_pristine_trigger)"
    [ -n "$re" ]
    for p in scripts/hooks/guard.sh scripts/substance-check.sh \
             .claude/skills/dev-tdd/SKILL.md .claude/skills/x/references/r.md \
             .claude/agents/qa-audit.md .claude/rules/testing.md \
             .claude/commands/work/work-quick.md .claude/output-styles/o.md \
             .claude/templates/t/f.md .husky/pre-commit templates/husky/commit-msg \
             .commitlintrc.json templates/lint-staged/.lintstagedrc.mjs; do
        printf '%s\n' "$p" | grep -qE "$re" || { echo "does not fire: $p" >&2; return 1; }
    done
    for p in .claude/settings.json scripts/hooks/lib/x.sh README.md .husky/_/h; do
        if printf '%s\n' "$p" | grep -qE "$re"; then echo "fires: $p" >&2; return 1; fi
    done
}

@test "self-application: the committed table covers every shipped version" {
    [ "$(git -C "$BASE_DIR" rev-parse --is-shallow-repository)" = "false" ] \
        || skip "shallow clone: the history the table is derived from is not here"
    run bash "$GEN" --check
    [ "$status" -eq 0 ] || { printf '%s\n' "$output" >&2; return 1; }
    # Not vacuous: the real table holds more than the current files.
    [ "$(grep -c ' scripts/hooks/' "$BASE_DIR/$TABLE_REL")" -gt "$(ls "$BASE_DIR"/scripts/hooks/*.sh | wc -l)" ]
    [ "$(grep -c ' \.claude/skills/' "$BASE_DIR/$TABLE_REL")" -gt "$(find "$BASE_DIR/.claude/skills" -type f | wc -l)" ]
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
