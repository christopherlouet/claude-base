#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/setup-deps.sh — the SessionStart/init dependency
# bootstrap. This suite covers ONLY its git-hooks wiring, the portability-
# sensitive part: it must set a RELATIVE core.hooksPath (=.husky), never an
# absolute one. History: an absolute core.hooksPath left over from a repo
# directory rename SILENTLY disables every git hook — so this guards that a
# relative value is written and that a stale absolute one is REPAIRED.
#
# The dependency-install blocks are skipped by construction: the fixture repo
# contains no package.json / pyproject.toml / go.mod / etc., so the script falls
# straight through to the git-hooks block (no npm/pip/network).
# =============================================================================

load 'test_helper'

SETUP="$BASE_DIR/scripts/hooks/setup-deps.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# --- Wiring: relative core.hooksPath -----------------------------------------

@test "setup-deps: wires a RELATIVE core.hooksPath (.husky)" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    run bash "$SETUP"
    [ "$status" -eq 0 ]
    local hp; hp=$(git config --local core.hooksPath)
    [ "$hp" = ".husky" ]
    # Never absolute — the rename-incident regression guard.
    [[ "$hp" != /* ]]
    # The wiring is delegated to git-hooks-wire.sh (one definition, shared with
    # the SessionStart registration); assert it announced the repair without
    # pinning its exact prose. The behaviour itself is pinned above, and in
    # tests/git-hooks-wire.bats.
    [[ "$output" == *"wired to .husky"* ]]
}

@test "setup-deps: REPAIRS a stale ABSOLUTE core.hooksPath (rename incident)" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    # Simulate the historical breakage: an absolute path left by a dir rename.
    git config --local core.hooksPath /old/renamed/checkout/.husky
    run bash "$SETUP"
    [ "$status" -eq 0 ]
    local hp; hp=$(git config --local core.hooksPath)
    [ "$hp" = ".husky" ]
    [[ "$hp" != /* ]]
}

@test "setup-deps: idempotent — second run is a no-op, stays relative" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    bash "$SETUP" >/dev/null
    run bash "$SETUP"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
    # Already correct → the wiring branch must not re-fire.
    [[ "$output" != *"git hooks wired"* ]]
}

# --- Guards: no work tree / no .husky ----------------------------------------

@test "setup-deps: no .husky dir → skips wiring, exit 0, hooksPath unset" {
    cd "$TEST_DIR"
    git init -q
    run bash "$SETUP"
    [ "$status" -eq 0 ]
    run git config --local core.hooksPath
    [ "$status" -ne 0 ]                 # unset
}

@test "setup-deps: not a git work tree → no crash, no wiring, exit 0" {
    cd "$TEST_DIR"
    mkdir .husky                        # .husky present but no git repo
    run bash "$SETUP"
    [ "$status" -eq 0 ]
    [[ "$output" != *"git hooks wired"* ]]
}
