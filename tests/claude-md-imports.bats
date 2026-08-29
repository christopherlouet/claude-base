#!/usr/bin/env bats

# =============================================================================
# ensure_claude_md_imports() — which documents a project CARRIES into every
# session, as opposed to which documents it ships.
#
# Measured on a real install on 2026-08-30: a project carried **109 914 bytes**
# per session, 5.3x what the foundation itself carries, and 75 061 of those were
# four documents that describe rather than instruct:
#
#   advanced-features.md  37 179  40 sections of Claude Code feature notes,
#                                 including one about a superseded model
#   hooks-reference.md    20 821  a catalogue of hooks that run whether or not
#                                 they are documented
#   agents-catalog.md      9 756  the harness already lists agent types natively
#   skills-catalog.md      7 305  the harness already lists skills natively
#
# The three that stay are the ones with no native equivalent or a user-facing
# purpose: commands.md (the harness does NOT list slash commands), plus
# best-practices.md and project-structures.md, kept deliberately because a
# downstream user may be new to the tool — an argument that did not apply to the
# foundation's own copy (specs/guardrail-cleanup/carried-material.md).
#
# The invariant this function exists for is unchanged and is NOT the count:
# install and update must produce the SAME set, or a project's CLAUDE.md depends
# on which script last touched it.
# =============================================================================

load 'test_helper'

CARRIED=(
    "@.claude/docs/reference/best-practices.md"
    "@.claude/docs/reference/project-structures.md"
    "@.claude/docs/reference/commands.md"
)

RETIRED=(
    "@.claude/docs/reference/agents-catalog.md"
    "@.claude/docs/reference/hooks-reference.md"
    "@.claude/docs/reference/skills-catalog.md"
    "@.claude/docs/reference/advanced-features.md"
)

setup() {
    setup_test_dir
    CM="$TEST_DIR/CLAUDE.md"
    printf '# A project\n\nSome prose.\n' > "$CM"
}
teardown() { teardown_test_dir; }

# legacy_claude_md — a CLAUDE.md as installs produced it before this change.
legacy_claude_md() {
    {
        echo "# A project"
        echo
        local i
        for i in "${CARRIED[@]}" "${RETIRED[@]}"; do echo "$i"; done
        echo
        echo "Some prose."
    } > "$CM"
}

@test "imports: the three carried documents are added" {
    ensure_claude_md_imports "$CM"
    local i
    for i in "${CARRIED[@]}"; do
        grep -qF "$i" "$CM" || { echo "missing: $i" >&2; false; }
    done
}

@test "imports: the four retired documents are never added" {
    ensure_claude_md_imports "$CM"
    local added="" i
    for i in "${RETIRED[@]}"; do
        grep -qF "$i" "$CM" && added="$added $i"
    done
    [ -z "$added" ] || { echo "carried again:$added" >&2; false; }
}

@test "imports: a project carrying the retired four has them pruned" {
    # The fleet path. Twenty-odd installed projects carry them today, and an
    # update that only ever ADDS would leave every one of them heavy forever.
    legacy_claude_md
    ensure_claude_md_imports "$CM"
    local left="" i
    for i in "${RETIRED[@]}"; do
        grep -qF "$i" "$CM" && left="$left $i"
    done
    [ -z "$left" ] || { echo "still carried:$left" >&2; false; }
}

@test "imports: pruning keeps the three carried ones" {
    # Half a repair is worse than none: the prune must not take the survivors.
    legacy_claude_md
    ensure_claude_md_imports "$CM"
    local i
    for i in "${CARRIED[@]}"; do
        grep -qF "$i" "$CM" || { echo "pruned by mistake: $i" >&2; false; }
    done
}

@test "imports: a user's own @import is left alone" {
    printf '# A project\n\n@docs/our-own-conventions.md\n\nProse.\n' > "$CM"
    ensure_claude_md_imports "$CM"
    grep -qF "@docs/our-own-conventions.md" "$CM"
}

@test "imports: the function is idempotent" {
    ensure_claude_md_imports "$CM"
    cp "$CM" "$TEST_DIR/first.md"
    ensure_claude_md_imports "$CM"
    diff -q "$TEST_DIR/first.md" "$CM"
}

@test "imports: idempotent on a legacy file too" {
    legacy_claude_md
    ensure_claude_md_imports "$CM"
    cp "$CM" "$TEST_DIR/first.md"
    ensure_claude_md_imports "$CM"
    diff -q "$TEST_DIR/first.md" "$CM"
}

@test "CONTROL: the function actually writes to the file" {
    # Every assertion above would pass on a function that did nothing to a file
    # that already looked right. This one fails if it became a no-op.
    cp "$CM" "$TEST_DIR/before.md"
    ensure_claude_md_imports "$CM"
    ! diff -q "$TEST_DIR/before.md" "$CM"
}

@test "CONTROL: a missing file is a no-op, not a crash" {
    run ensure_claude_md_imports "$TEST_DIR/does-not-exist.md"
    [ "$status" -eq 0 ]
}
