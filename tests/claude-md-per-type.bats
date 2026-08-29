#!/usr/bin/env bats

# =============================================================================
# Tests for the CLAUDE.md an install deposits in a fresh project.
#
# The type -> template mapping lived ONLY on the create path (the interactive /
# `-y` flow). Simple mode — which every `--simple`, `--install-only` and
# `--preset` install goes through — had no mapping at all and unconditionally
# copied the foundation's OWN CLAUDE.md. A `--preset fastapi` install therefore
# shipped a Python project whose CLAUDE.md was titled "# claude-base Project",
# prescribed TypeScript conventions, told the reader to run the foundation's
# installer, and pointed at two files that exist only in this repo.
#
# Same family as the type-blind .gitignore seed (see gitignore-per-type.bats):
# a foundation-owned file used as a user-project template. These tests pin the
# two paths to ONE mapping, and pin the generic fallback to carry nothing that
# only makes sense inside the foundation.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# install_into <dir> <flags...> — non-interactive install, must succeed.
install_into() {
    local dir="$1"; shift
    mkdir -p "$dir"
    run "$NEW_PROJECT_SCRIPT" -y -q --skip-prompts "$@" "$dir"
    [ "$status" -eq 0 ]
    [ -f "$dir/CLAUDE.md" ]
}

title_of() { head -1 "$1/CLAUDE.md"; }

# -----------------------------------------------------------------------------
# Every mode honours the project type
# -----------------------------------------------------------------------------

@test "claude-md: the create path uses the type template" {
    install_into "$TEST_DIR/p" -t python

    [ "$(title_of "$TEST_DIR/p")" = "# Python Project" ]
}

@test "claude-md: simple mode uses the type template" {
    install_into "$TEST_DIR/p" --simple -t python

    [ "$(title_of "$TEST_DIR/p")" = "# Python Project" ]
}

@test "claude-md: install-only uses the type template" {
    install_into "$TEST_DIR/p" --install-only -t go

    [ "$(title_of "$TEST_DIR/p")" = "# Go Project" ]
}

@test "claude-md: a preset install uses the template of the preset's type" {
    # fastapi records projectType=python in foundation.json — the CLAUDE.md
    # must agree with it instead of describing the foundation itself.
    install_into "$TEST_DIR/p" --preset fastapi

    [ "$(title_of "$TEST_DIR/p")" = "# Python Project" ]
    grep -q "projectType.*python" "$TEST_DIR/p/.claude/foundation.json"
}

@test "claude-md: the react-typed presets get the react template" {
    install_into "$TEST_DIR/p" --preset nextjs

    [ "$(title_of "$TEST_DIR/p")" = "# React/Next.js Project" ]
}

@test "claude-md: create and simple modes agree on every templated type" {
    # The two paths had divergent mappings; one definition means one result.
    local t
    for t in react vue node-api python go rust java fullstack flutter neovim; do
        install_into "$TEST_DIR/create-$t" -t "$t"
        install_into "$TEST_DIR/simple-$t" --simple -t "$t"

        [ "$(title_of "$TEST_DIR/create-$t")" = "$(title_of "$TEST_DIR/simple-$t")" ]
    done
}

# -----------------------------------------------------------------------------
# The generic fallback must not leak the foundation's own content
# -----------------------------------------------------------------------------

@test "claude-md: the generic fallback drops the foundation-only doc rows" {
    # docs/CHEATSHEET.md and website/docs/guides/learning-path.md are never
    # copied into a user project — a row pointing at them is a dead link.
    install_into "$TEST_DIR/p" --simple -t generic

    ! grep -q 'docs/CHEATSHEET\.md' "$TEST_DIR/p/CLAUDE.md"
    ! grep -q 'learning-path\.md' "$TEST_DIR/p/CLAUDE.md"
}

@test "claude-md: the generic fallback drops the foundation's own setup line" {
    install_into "$TEST_DIR/p" --simple -t generic

    ! grep -q 'bin/claude-base init' "$TEST_DIR/p/CLAUDE.md"
}

@test "claude-md: the generic fallback is not titled after the foundation" {
    install_into "$TEST_DIR/p" --simple -t generic

    ! grep -q '^# claude-base Project' "$TEST_DIR/p/CLAUDE.md"
}

@test "claude-md: a type with no template still gets a clean fallback" {
    # astro/svelte/php/ruby/csharp are detectable types with no CLAUDE template
    # yet (assumed debt). The fallback must still be user-project-shaped.
    install_into "$TEST_DIR/p" --simple -t astro

    ! grep -q '^# claude-base Project' "$TEST_DIR/p/CLAUDE.md"
    ! grep -q 'docs/CHEATSHEET\.md' "$TEST_DIR/p/CLAUDE.md"
}

# -----------------------------------------------------------------------------
# Self-application: no CLAUDE.md may point at a file the install did not deposit
# -----------------------------------------------------------------------------

# assert_no_dead_pointers <project_dir> — every repo-relative path the
# installed CLAUDE.md names must exist in the installed tree.
#
# Refs are collected into a file and the whole file is walked: an earlier
# process-substitution version under-reported (it printed the first findings
# and stopped), which is the failure mode that lets a dead pointer through a
# green test. Nothing here is a hand-copied list — both the refs and the
# existence check come from the real artefacts.
assert_no_dead_pointers() {
    local project_dir="$1"
    local refs="$BATS_TEST_TMPDIR/refs.txt"
    local missing="$BATS_TEST_TMPDIR/missing.txt"

    : > "$refs"
    # @imports
    grep -o '^@[^ ]*' "$project_dir/CLAUDE.md" | sed 's/^@//' >> "$refs" || true
    # Backticked repo-relative markdown paths in the reference tables
    grep -o '`[a-zA-Z_./-]*\.md`' "$project_dir/CLAUDE.md" \
        | tr -d '`' | grep -v '^CLAUDE' >> "$refs" || true

    : > "$missing"
    local ref
    while IFS= read -r ref; do
        [ -n "$ref" ] || continue
        [ -e "$project_dir/$ref" ] || echo "$ref" >> "$missing"
    done < "$refs"

    if [ -s "$missing" ]; then
        echo "dead pointers in CLAUDE.md:"
        cat "$missing"
        return 1
    fi
    # Guard the guard: a scan that collected nothing would pass vacuously.
    [ "$(wc -l < "$refs")" -ge 7 ]
}

@test "claude-md: every referenced path exists in the installed project" {
    # The defect that started this was a dead pointer surviving a path rewrite.
    install_into "$TEST_DIR/p" --preset fastapi

    assert_no_dead_pointers "$TEST_DIR/p"
}

@test "claude-md: the same holds for a simple generic install" {
    install_into "$TEST_DIR/p" --simple -t generic

    assert_no_dead_pointers "$TEST_DIR/p"
}

@test "claude-md: the dead-pointer scan actually detects one" {
    # Mutation proof: without this, tests 11-12 could pass by scanning nothing.
    install_into "$TEST_DIR/p" --simple -t generic
    printf '| Bogus | `docs/NOT-SHIPPED.md` |\n' >> "$TEST_DIR/p/CLAUDE.md"

    run assert_no_dead_pointers "$TEST_DIR/p"
    [ "$status" -ne 0 ]
    [[ "$output" == *"docs/NOT-SHIPPED.md"* ]]
}

# -----------------------------------------------------------------------------
# Invariants that must survive the fix
# -----------------------------------------------------------------------------

@test "claude-md: the canonical @imports are present whatever the template" {
    install_into "$TEST_DIR/p" --simple -t python

    grep -q '^@\.claude/docs/reference/best-practices\.md' "$TEST_DIR/p/CLAUDE.md"
    grep -q '^@\.claude/docs/reference/commands\.md' "$TEST_DIR/p/CLAUDE.md"
    # advanced-features.md is shipped but no longer CARRIED: 37 179 bytes of
    # feature notes about the tool, in every session (2026-08-30).
    ! grep -q '^@\.claude/docs/reference/advanced-features\.md' "$TEST_DIR/p/CLAUDE.md"
}

@test "claude-md: an existing CLAUDE.md is never overwritten" {
    mkdir -p "$TEST_DIR/p"
    printf '# My own file\n' > "$TEST_DIR/p/CLAUDE.md"

    install_into "$TEST_DIR/p" --simple -t python

    grep -q '^# My own file' "$TEST_DIR/p/CLAUDE.md"
}

@test "claude-md: the design style is still appended in simple mode" {
    install_into "$TEST_DIR/p" --simple -t python --style editorial

    grep -q '^Style: editorial' "$TEST_DIR/p/CLAUDE.md"
}
