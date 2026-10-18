#!/usr/bin/env bats

# =============================================================================
# Tests for the lint-staged config an install puts into a DOWNSTREAM project.
#
# The config used to be a static .lintstagedrc.json calling `eslint --fix` and
# `prettier --write`. Measured on a real install that followed the post-install
# instructions to the letter (husky, lint-staged, commitlint): staging one .md
# file refused the commit with "prettier --write [ENOENT]", because nothing
# installs prettier. Installing prettier and eslint was not enough either:
# eslint with no config of the project's own failed on the first .js file.
#
# The shipped config now asks for a tool only when it is installed, and for
# eslint only when the project has configured it — the same rule as the husky
# hooks: a gate nobody feeds must step aside, not block the work.
# =============================================================================

load 'test_helper'

TEMPLATE="$BATS_TEST_DIRNAME/../templates/lint-staged/.lintstagedrc.mjs"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
    command -v node >/dev/null || skip "node not on PATH: lint-staged cannot run here either"
    PROJ="$TEST_DIR/proj"
    mkdir -p "$PROJ"
    cp "$TEMPLATE" "$PROJ/.lintstagedrc.mjs"
}

teardown() {
    teardown_test_dir
}

# Puts an executable stub named $1 in the project's node_modules/.bin.
install_tool() {
    mkdir -p "$PROJ/node_modules/.bin"
    printf '#!/bin/sh\nexit 0\n' > "$PROJ/node_modules/.bin/$1"
    chmod +x "$PROJ/node_modules/.bin/$1"
}

# Prints the commands the config resolves for the staged file $1, one per
# line — the same call lint-staged makes for a function task. Run from
# another directory on purpose: the config must not depend on the cwd.
tasks_for() {
    node --input-type=module -e '
        const [config, file] = process.argv.slice(1)
        const { default: c } = await import(config)
        const ext = file.slice(file.lastIndexOf(".") + 1)
        for (const [glob, task] of Object.entries(c)) {
            const exts = glob === "*" ? [ext] : (glob.match(/\{([^}]*)\}/)?.[1] ?? "").split(",")
            if (!exts.includes(ext)) continue
            const out = typeof task === "function" ? task([file]) : task
            for (const cmd of [].concat(out)) console.log(cmd.split(" ").slice(0, 2).join(" "))
        }
    ' "file://$PROJ/.lintstagedrc.mjs" "$PROJ/$1"
}

# =============================================================================
# What the config asks for
# =============================================================================

@test "lint-staged config: nothing installed asks for nothing" {
    run tasks_for a.md
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run tasks_for a.ts
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "lint-staged config: nothing installed is still a valid, non-empty config" {
    # lint-staged rejects `{}` ("Configuration should not be empty"): the
    # no-op must be a real entry, or the commit is refused all the same.
    run node --input-type=module -e '
        const { default: c } = await import(process.argv[1])
        if (Object.keys(c).length === 0) process.exit(1)
    ' "file://$PROJ/.lintstagedrc.mjs"
    [ "$status" -eq 0 ]
}

@test "lint-staged config: an installed prettier formats code and docs" {
    install_tool prettier
    run tasks_for a.md
    [ "$output" = "prettier --write" ]
    run tasks_for a.tsx
    [ "$output" = "prettier --write" ]
    run tasks_for a.scss
    [ "$output" = "prettier --write" ]
}

@test "lint-staged config: eslint installed but not configured is not run" {
    install_tool eslint
    run tasks_for a.js
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "lint-staged config: eslint installed and configured runs before prettier" {
    install_tool eslint
    install_tool prettier
    echo 'export default []' > "$PROJ/eslint.config.mjs"
    run tasks_for a.ts
    [ "${lines[0]}" = "eslint --fix" ]
    [ "${lines[1]}" = "prettier --write" ]
    # eslint never touches a file it does not lint.
    run tasks_for a.md
    [ "$output" = "prettier --write" ]
}

@test "lint-staged config: a legacy .eslintrc counts as configured" {
    install_tool eslint
    echo '{}' > "$PROJ/.eslintrc.json"
    run tasks_for a.js
    [ "$output" = "eslint --fix" ]
}

# =============================================================================
# What the install ships
# =============================================================================

install_into() {
    git -C "$1" init -q
    bash "$NEW_PROJECT_SCRIPT" --simple --hooks -y "$1" >/dev/null 2>&1
}

@test "install --hooks: ships the adaptive lint-staged config" {
    local p="$TEST_DIR/fresh"; mkdir -p "$p"
    install_into "$p"
    [ -f "$p/.lintstagedrc.mjs" ]
    cmp -s "$TEMPLATE" "$p/.lintstagedrc.mjs"
    # The static config it replaces must not come back beside it.
    [ ! -e "$p/.lintstagedrc.json" ]
}

@test "install --hooks: a project's own lint-staged config file means no second one" {
    local p="$TEST_DIR/own-file"; mkdir -p "$p"
    printf '{"*.md":"echo own"}\n' > "$p/.lintstagedrc.json"
    install_into "$p"
    [ ! -e "$p/.lintstagedrc.mjs" ]
}

@test "install --hooks: a lint-staged key in package.json means no config file" {
    local p="$TEST_DIR/own-key"; mkdir -p "$p"
    printf '{"name":"p","lint-staged":{"*.md":"echo own"}}\n' > "$p/package.json"
    install_into "$p"
    [ ! -e "$p/.lintstagedrc.mjs" ]
}
