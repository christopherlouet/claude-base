#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/git-hooks-wire.sh — the SessionStart repair of a
# broken core.hooksPath.
#
# Why a second hook rather than registering setup-deps.sh on SessionStart:
# setup-deps installs dependencies (npm/uv/go/bundle/composer) on a 120s
# timeout and must never run per session. Its git-wiring block was therefore
# reachable only at init — and BOTH ways the wiring breaks happen after init,
# so the guard structurally could not catch the incident it was written for:
#
#   fresh clone   core.hooksPath is local config and is not cloned; .husky/
#                 arrives with the tree, the wiring does not.
#   repo moved    an absolute core.hooksPath from the old location silently
#                 disables every hook. Observed live in this repo, which is
#                 what prompted this file.
#
# The discriminating behaviour versus setup-deps is the LEAVE-ALONE case: a
# per-session hook must not hijack a hooksPath the user deliberately set.
# =============================================================================

load 'test_helper'

WIRE="$BASE_DIR/scripts/hooks/git-hooks-wire.sh"

setup() { setup_test_dir; }

# The self-application tests write the developer's REAL local hooksPath; the
# value they found is put back here, whether the test passed or not.
teardown() {
    if [ -n "${REAL_HOOKS_PATH_SAVED:-}" ]; then
        if [ -n "${REAL_HOOKS_PATH:-}" ]; then
            git -C "$BASE_DIR" config --local core.hooksPath "$REAL_HOOKS_PATH"
        else
            git -C "$BASE_DIR" config --local --unset core.hooksPath || true
        fi
    fi
    teardown_test_dir
}

save_real_hooks_path() {
    REAL_HOOKS_PATH=$(git -C "$BASE_DIR" config --local core.hooksPath || true)
    REAL_HOOKS_PATH_SAVED=1
}

@test "git-hooks-wire: script exists and is executable" {
    [ -f "$WIRE" ]
    [ -x "$WIRE" ]
}

# --- The two real breakages ---------------------------------------------------

@test "git-hooks-wire: fresh clone (unset + .husky present) gets wired" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    local hp; hp=$(git config --local core.hooksPath)
    [ "$hp" = ".husky" ]
    [[ "$hp" != /* ]]                       # never absolute — that is the bug
    [[ "$output" == *"unset"* ]]
}

@test "git-hooks-wire: stale ABSOLUTE hooksPath from a repo rename is repaired" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    git config --local core.hooksPath /gone/old/checkout/.husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
    [[ "$output" == *"stale"* ]]
}

@test "git-hooks-wire: stale RELATIVE hooksPath pointing nowhere is repaired" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    git config --local core.hooksPath .githooks-that-vanished
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

# --- An absolute path that still works is the next rename's breakage -----------
#
# The repo-moved case above is only repaired AFTER the move, once the path is
# stale. An absolute value that still resolves to the repo's own .husky works
# today and breaks silently on the next rename — observed on this very repo
# after it moved, where the absolute value had been re-created at the new
# location. It is unambiguous (it IS the foundation's hooks dir), so the hook
# makes it relative before the move instead of after.

@test "git-hooks-wire: an ABSOLUTE hooksPath to the repo's own .husky becomes relative" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
    [[ "$output" == *"made relative (.husky)"* ]]
}

# Any directory inside the repo breaks the same way on a rename, not only
# .husky: a deliberate .githooks keeps its target, only its spelling changes.
@test "git-hooks-wire: an ABSOLUTE hooksPath to another dir INSIDE the repo becomes relative" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky .githooks
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.githooks"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".githooks" ]
}

# What husky v9 itself points at.
@test "git-hooks-wire: an ABSOLUTE hooksPath to husky v9's .husky/_ keeps its subdirectory" {
    cd "$TEST_DIR"
    git init -q
    mkdir -p .husky/_
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky/_"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky/_" ]
}

# git expands a leading ~/ itself; read raw it looks relative to the repo,
# and a working home directory was declared stale and replaced.
@test "git-hooks-wire: a ~/ hooksPath to an existing dir is left alone" {
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME/.githooks" "$TEST_DIR/repo"
    cd "$TEST_DIR/repo"
    git init -q
    mkdir .husky
    git config --local core.hooksPath '~/.githooks'
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = '~/.githooks' ]
    [ -z "$output" ]
}

# Same directory reached through a symlink and a trailing slash: a string
# comparison would miss it, the inode comparison does not.
@test "git-hooks-wire: the repo's own .husky is recognised through a symlink" {
    mkdir "$TEST_DIR/real"
    ln -s "$TEST_DIR/real" "$TEST_DIR/link"
    cd "$TEST_DIR/real"
    git init -q
    mkdir .husky
    git config --local core.hooksPath "$TEST_DIR/link/.husky/"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

@test "git-hooks-wire: an ABSOLUTE hooksPath to some OTHER existing dir is left alone" {
    cd "$TEST_DIR"
    mkdir repo shared-hooks
    cd repo
    git init -q
    mkdir .husky
    git config --local core.hooksPath "$TEST_DIR/shared-hooks"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$TEST_DIR/shared-hooks" ]
    [ -z "$output" ]
}

@test "git-hooks-wire: once made relative, a second run is silent" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky"
    bash "$WIRE" >/dev/null
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # Silent because it was FIXED, not because nothing happened.
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

# --- The discriminating case: do not hijack a deliberate choice ---------------

@test "git-hooks-wire: an EXISTING non-.husky hooksPath is left alone" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky .githooks
    git config --local core.hooksPath .githooks
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    # Deliberate and working — the hook must not take it over.
    [ "$(git config --local core.hooksPath)" = ".githooks" ]
    [ -z "$output" ]
}

@test "git-hooks-wire: a relative hooksPath resolves against the repo root, not the cwd" {
    # Run from a SUBDIRECTORY: resolving ".githooks" against the cwd would find
    # nothing and wrongly declare the (valid) configuration stale.
    cd "$TEST_DIR"
    git init -q
    mkdir .husky .githooks sub
    git config --local core.hooksPath .githooks
    cd sub
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".githooks" ]
    [ -z "$output" ]
}

# --- Quiet, safe no-ops -------------------------------------------------------

@test "git-hooks-wire: already correct → silent no-op" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    git config --local core.hooksPath .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git-hooks-wire: no .husky → no wiring, exit 0" {
    cd "$TEST_DIR"
    git init -q
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run git config --local core.hooksPath
    [ "$status" -ne 0 ]
}

@test "git-hooks-wire: not a git work tree → exit 0, silent, no crash" {
    cd "$TEST_DIR"
    mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git-hooks-wire: runs twice without re-announcing (idempotent)" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    bash "$WIRE" >/dev/null
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

# --- Self-application ---------------------------------------------------------

@test "git-hooks-wire: on the real foundation it converges to .husky, then goes quiet" {
    # Asserts the INVARIANT, not the incidental. An earlier version demanded
    # silence on the first run, which encoded the state of one developer's
    # machine: a checkout that had already been repaired by hand. CI proved it
    # wrong on both Linux and macOS — a fresh clone carries no local config, so
    # hooksPath is unset and the hook correctly repairs and says so. That is
    # one of the two breakages this hook exists for, and it is the common one.
    #
    # What must hold on any checkout: the end state is .husky, and a second run
    # has nothing left to do.
    save_real_hooks_path
    cd "$BASE_DIR"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]

    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

# The state this checkout was actually found in: an absolute value pointing at
# the real .husky. Ends on .husky, the state the test above leaves anyway.
@test "git-hooks-wire: on the real foundation an absolute hooksPath converges to .husky" {
    save_real_hooks_path
    cd "$BASE_DIR"
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}
