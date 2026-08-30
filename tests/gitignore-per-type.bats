#!/usr/bin/env bats

# =============================================================================
# Tests for the .gitignore an install deposits in a fresh project.
#
# When the target has no .gitignore, the installer seeds it from the
# foundation's OWN .gitignore — which is Node-flavoured (node_modules/, dist/,
# .next/). A `-t python` install therefore shipped a project that ignored
# node_modules/ and tracked __pycache__/, and the same held for go, rust, java
# and flutter. The seed is type-blind; these tests pin that it no longer is.
#
# Scope rule under test: the type block is appended only when the installer
# CREATES the .gitignore. A project that already has one manages its own
# ignores — we still add the Claude local-config lines there, nothing else.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# install_as <type> — run a non-interactive install of the given project type
# into $TEST_DIR and fail loudly if it does not succeed.
install_as() {
    run "$NEW_PROJECT_SCRIPT" -y -q -t "$1" --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.gitignore" ]
}

# --- the foundation must ignore what the foundation WRITES (2026-08-30) ------
# Versioning .claude/ is the doctrine, and the moment four projects started
# doing it, three foundation-written artefacts landed in `git status`: the
# update's backups in both shapes, the CLAUDE.md backups, and Claude Code's own
# worktrees. Each had to be excluded by hand, in every project.

@test "gitignore: the Claude block ignores the backups an update writes" {
    printf 'node_modules/\n' > "$TEST_DIR/.gitignore"
    run "$NEW_PROJECT_SCRIPT" -y -q --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    grep -q '^\.claude/commands\.backup\.\*/$' "$TEST_DIR/.gitignore"
    grep -q '^\.claude\.backup\.\*/$' "$TEST_DIR/.gitignore"
    grep -q '^CLAUDE\.md\.backup\.\*$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the Claude block ignores Claude Code worktrees" {
    printf 'node_modules/\n' > "$TEST_DIR/.gitignore"
    run "$NEW_PROJECT_SCRIPT" -y -q --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    grep -q '^\.claude/worktrees/$' "$TEST_DIR/.gitignore"
}

# The other path: a project with NO .gitignore gets one seeded from the
# foundation's, which must therefore carry the same four entries. Two code
# paths, one contract.
@test "gitignore: a seeded .gitignore carries the same foundation-written ignores" {
    run "$NEW_PROJECT_SCRIPT" -y -q --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    grep -q '^\.claude\.backup\.\*/$' "$TEST_DIR/.gitignore"
    grep -q '^CLAUDE\.md\.backup\.\*$' "$TEST_DIR/.gitignore"
    grep -q '^\.claude/worktrees/$' "$TEST_DIR/.gitignore"
}

# CONTROL - the doctrine itself must not move: .claude/ and CLAUDE.md stay
# versioned. Widening the ignore list is exactly how that would get undone.
@test "gitignore: the Claude block still leaves .claude/ and CLAUDE.md versioned" {
    printf 'node_modules/\n' > "$TEST_DIR/.gitignore"
    run "$NEW_PROJECT_SCRIPT" -y -q --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    ! grep -qE '^\.claude/?$' "$TEST_DIR/.gitignore"
    ! grep -qE '^CLAUDE\.md$' "$TEST_DIR/.gitignore"
}

# The foundation's OWN worktree rule lives in .git/info/exclude — local to one
# clone, invisible to every other checkout and impossible to seed into a
# project. Assert the TRACKED file, not `git check-ignore`, which would pass
# vacuously wherever that local rule happens to exist.
@test "gitignore: the foundation's tracked .gitignore ignores its own worktrees" {
    grep -q 'worktrees' "$BATS_TEST_DIRNAME/../.gitignore"
}

@test "gitignore: a python install ignores Python build artefacts" {
    install_as python

    grep -qE '^__pycache__/$' "$TEST_DIR/.gitignore"
    grep -qE '^\.venv/$' "$TEST_DIR/.gitignore"
    grep -qE '^\.pytest_cache/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a go install ignores Go build artefacts" {
    install_as go

    grep -qE '^\*\.test$' "$TEST_DIR/.gitignore"
    grep -qE '^\*\.out$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a rust install ignores the target directory" {
    install_as rust

    grep -qE '^target/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a java install ignores class files and the gradle cache" {
    install_as java

    grep -qE '^\*\.class$' "$TEST_DIR/.gitignore"
    grep -qE '^\.gradle/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a flutter install ignores the dart tool cache" {
    install_as flutter

    grep -qE '^\.dart_tool/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a php install ignores the composer vendor tree" {
    install_as php

    grep -qE '^vendor/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a ruby install ignores the bundler path and Rails runtime dirs" {
    install_as ruby

    grep -qE '^\.bundle/$' "$TEST_DIR/.gitignore"
    grep -qE '^log/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the ruby block never blanket-ignores vendor/" {
    # A Rails app can carry hand-written code under vendor/; only the bundler
    # install path is a build artefact. Same trap as the java wrapper jar.
    install_as ruby

    ! grep -qE '^vendor/$' "$TEST_DIR/.gitignore"
    grep -qE '^vendor/bundle/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a csharp install ignores the .NET build output" {
    install_as csharp

    grep -qE '^bin/$' "$TEST_DIR/.gitignore"
    grep -qE '^obj/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a svelte install ignores the SvelteKit build dir" {
    install_as svelte

    grep -qE '^\.svelte-kit/$' "$TEST_DIR/.gitignore"
    # Still a Node project: the seed's baseline must survive the appended block.
    grep -qE '^node_modules/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: an astro install ignores the astro cache" {
    install_as astro

    grep -qE '^\.astro/$' "$TEST_DIR/.gitignore"
    grep -qE '^node_modules/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the java block never ignores the gradle wrapper jar" {
    # A blanket *.jar would ignore gradle/wrapper/gradle-wrapper.jar, which
    # every consumer must be able to clone. Blocking that is worse than the
    # gap this change closes.
    install_as java

    ! grep -qE '^\*\.jar$' "$TEST_DIR/.gitignore"
}

@test "gitignore: a node install keeps the Node baseline and gains no foreign block" {
    install_as node-api

    grep -qE '^node_modules/$' "$TEST_DIR/.gitignore"
    ! grep -qE '^__pycache__/$' "$TEST_DIR/.gitignore"
    ! grep -qE '^target/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: every install still ignores the Claude local config" {
    install_as python

    grep -qE '^CLAUDE\.local\.md$' "$TEST_DIR/.gitignore"
    grep -qE '^\.claude/settings\.local\.json$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the seed drops the foundation-only blocks" {
    # The seed is the foundation's OWN .gitignore, which carries entries that
    # exist nowhere but this repo: the Docusaurus site, the generated catalog
    # mirrors, the curation engine's runtime state, local .deb installers.
    install_as python

    ! grep -q '^website/' "$TEST_DIR/.gitignore"
    ! grep -q 'Docusaurus' "$TEST_DIR/.gitignore"
    ! grep -q 'curation/watch-state\.json' "$TEST_DIR/.gitignore"
    ! grep -qE '^\*\.deb$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the foundation-only fence is derived, not hand-copied" {
    # Prove the exclusion follows the markers IN the seed rather than a list
    # kept in the installer: a new entry added inside the fence must vanish
    # from the install without touching any script.
    local seed="$TEST_DIR/seed.gitignore" out="$TEST_DIR/out.gitignore"
    cat > "$seed" <<'EOF'
node_modules/
# >>> foundation-only (never seeded into a user project's .gitignore) >>>
some-brand-new-foundation-artefact/
# <<< foundation-only <<<
.env
EOF

    seed_gitignore_from_foundation "$seed" "$out"

    grep -qE '^node_modules/$' "$out"
    grep -qE '^\.env$' "$out"
    ! grep -q 'some-brand-new-foundation-artefact' "$out"
    ! grep -q 'foundation-only' "$out"
}

@test "gitignore: the fence markers in the real seed are balanced" {
    # An unclosed opening marker would silently truncate every user .gitignore
    # from that line onwards.
    local seed="$BATS_TEST_DIRNAME/../.gitignore"

    [ "$(grep -c '^# >>> foundation-only' "$seed")" -eq \
      "$(grep -c '^# <<< foundation-only' "$seed")" ]
}

@test "gitignore: the seed still carries the shared baseline" {
    # Fencing must not eat the entries every project wants.
    install_as python

    grep -qE '^\.env$' "$TEST_DIR/.gitignore"
    grep -qE '^\.idea/$' "$TEST_DIR/.gitignore"
    grep -qE '^\.DS_Store$' "$TEST_DIR/.gitignore"
}

@test "gitignore: an existing .gitignore keeps its content and gains no type block" {
    printf '# hand written\n*.log\n' > "$TEST_DIR/.gitignore"

    install_as python

    # The project's own rules survive untouched...
    grep -qE '^\*\.log$' "$TEST_DIR/.gitignore"
    grep -qE '^# hand written$' "$TEST_DIR/.gitignore"
    # ...the Claude local-config lines are appended as before...
    grep -qE '^CLAUDE\.local\.md$' "$TEST_DIR/.gitignore"
    # ...and we do not editorialise their ignore rules.
    ! grep -qE '^__pycache__/$' "$TEST_DIR/.gitignore"
    ! grep -qE '^node_modules/$' "$TEST_DIR/.gitignore"
}

@test "gitignore: the type block is written once, not once per run" {
    install_as python
    local first
    first=$(grep -c '^__pycache__/$' "$TEST_DIR/.gitignore")
    [ "$first" -eq 1 ]

    # A re-run over the same target must not stack a second copy.
    run "$NEW_PROJECT_SCRIPT" -y -q -t python --skip-prompts "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$(grep -c '^__pycache__/$' "$TEST_DIR/.gitignore")" -eq 1 ]
}
