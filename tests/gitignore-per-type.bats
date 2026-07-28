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
