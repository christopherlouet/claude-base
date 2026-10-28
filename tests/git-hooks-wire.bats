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

# The script reads EVERY config layer, so the developer's own global or system
# hooksPath must not leak into these repos.
setup() {
    setup_test_dir
    export GIT_CONFIG_GLOBAL="$TEST_DIR/global.gitconfig" GIT_CONFIG_NOSYSTEM=1
    : > "$GIT_CONFIG_GLOBAL"
}

teardown() { teardown_test_dir; }

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
    [[ "$output" == *"(was: /gone/old/checkout/.husky)"* ]]   # the local layer goes unnamed
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
# makes it relative before the move instead of after — when .husky is TRACKED,
# the condition for it to exist in the linked worktrees that share the config.

# Creates .husky with one committed hook in the repo of the current directory.
track_husky() {
    mkdir -p .husky
    echo 'exit 0' > .husky/pre-commit
    git add .husky
    git -c user.email=t@example.invalid -c user.name=t commit -qm husky
}

@test "git-hooks-wire: an ABSOLUTE hooksPath to the repo's own .husky becomes relative" {
    cd "$TEST_DIR"
    git init -q
    track_husky
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
    [[ "$output" == *"made relative (.husky)"* ]]
}

# ONLY .husky is relativised. Another dir inside the repo may be untracked,
# and the config is shared by every linked worktree while a relative path
# resolves per worktree (see the worktree cases below): left alone.
@test "git-hooks-wire: an ABSOLUTE hooksPath to another dir INSIDE the repo is left alone" {
    cd "$TEST_DIR"
    git init -q
    # Both TRACKED, so only the "ONLY .husky" rule keeps it, not the tracked
    # check or the inode one.
    track_husky
    mkdir .githooks
    echo 'exit 0' > .githooks/pre-commit
    git add .githooks
    git -c user.email=t@example.invalid -c user.name=t commit -qm githooks
    local abs; abs="$(git rev-parse --show-toplevel)/.githooks"
    git config --local core.hooksPath "$abs"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$abs" ]
    [ -z "$output" ]
}

# What husky v9 itself points at: generated and untracked, so the same rule.
@test "git-hooks-wire: an ABSOLUTE hooksPath to husky v9's .husky/_ is left alone" {
    cd "$TEST_DIR"
    git init -q
    mkdir -p .husky/_
    local abs; abs="$(git rev-parse --show-toplevel)/.husky/_"
    git config --local core.hooksPath "$abs"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$abs" ]
}

# --- Linked worktrees share one config ---------------------------------------
#
# Makes a repo in $TEST_DIR/main with a TRACKED .husky and an untracked
# .localhooks, plus a linked worktree at $TEST_DIR/wt.
make_repo_with_worktree() {
    mkdir "$TEST_DIR/main"
    cd "$TEST_DIR/main"
    git init -q
    mkdir .husky .localhooks
    echo 'exit 0' > .husky/pre-commit
    git add .husky
    git -c user.email=t@example.invalid -c user.name=t commit -qm init
    git worktree add -q "$TEST_DIR/wt" -b wt
}

# Reproduced in review against a version that relativised any in-repo dir: the
# main session wrote `.localhooks`, absent from the worktree, whose next
# session declared it stale and wrote .husky into the SHARED config.
@test "git-hooks-wire: an untracked in-repo hooksPath survives sessions in main AND a worktree" {
    make_repo_with_worktree
    git config --local core.hooksPath "$TEST_DIR/main/.localhooks"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    cd "$TEST_DIR/wt"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git -C "$TEST_DIR/main" config --local core.hooksPath)" = "$TEST_DIR/main/.localhooks" ]
}

# Decided from the main checkout only: a worktree's own index would speak for
# a config every other checkout shares.
@test "git-hooks-wire: from a linked worktree, an absolute .husky is not rewritten" {
    make_repo_with_worktree
    git config --local core.hooksPath "$TEST_DIR/wt/.husky"
    cd "$TEST_DIR/wt"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$TEST_DIR/wt/.husky" ]
    [ -z "$output" ]
}

# The tracked .husky exists in every worktree whose branch has it, so the
# relative value holds there. (A worktree on a branch WITHOUT .husky then runs
# no hooks — the accepted trade-off, the state a fresh clone gets anyway.)
@test "git-hooks-wire: the absolute .husky made relative in main stays quiet in a worktree" {
    make_repo_with_worktree
    git config --local core.hooksPath "$TEST_DIR/main/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
    cd "$TEST_DIR/wt"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
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

# A bare ~ is the home directory too.
@test "git-hooks-wire: a bare ~ hooksPath is left alone" {
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME" "$TEST_DIR/repo"
    cd "$TEST_DIR/repo"
    git init -q
    mkdir .husky
    git config --local core.hooksPath '~'
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = '~' ]
    [ -z "$output" ]
}

# git expands ~user/ and %(prefix)/ too (#662); read raw they looked relative
# to the repo, and a working directory was declared stale and replaced.
@test "git-hooks-wire: a ~user hooksPath to an existing dir is left alone" {
    local v; v="~$(id -un)"
    [ -d "$(git config --type=path --file /dev/stdin core.hooksPath <<<"[core]
hooksPath = $v")" ]                             # control: git resolves it to a real dir
    cd "$TEST_DIR"; git init -q; mkdir .husky
    git config --local core.hooksPath "$v"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$v" ]
    [ -z "$output" ]
}

@test "git-hooks-wire: a %(prefix)/ hooksPath to an existing dir is left alone" {
    local v='%(prefix)/'
    [ -d "$(git config --type=path --file /dev/stdin core.hooksPath <<<"[core]
hooksPath = $v")" ]                             # control: git resolves it to a real dir
    cd "$TEST_DIR"; git init -q; mkdir .husky
    git config --local core.hooksPath "$v"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$v" ]
    [ -z "$output" ]
}

# A global hooksPath (a secret scanner in ~/.githooks) is the user's choice for
# every repo; a local .husky would silently take it over.
# Left alone, but not silently: the .husky pre-commit then does not run here.
@test "git-hooks-wire: a working GLOBAL hooksPath is left alone, and said so" {
    mkdir -p "$TEST_DIR/global-hooks" "$TEST_DIR/repo"
    git config --global core.hooksPath "$TEST_DIR/global-hooks"
    cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"global config"*"do not run"*"instead of those"* ]]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

@test "git-hooks-wire: an EMPTY global hooksPath is named as empty" {
    mkdir -p "$TEST_DIR/repo"
    git config --global core.hooksPath ''
    cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"global config (empty)"* ]]
}

# Not the local layer: making it relative would mean a LOCAL write over the
# user's global choice, announced as if the global value had changed.
@test "git-hooks-wire: an ABSOLUTE global hooksPath to this repo's .husky is left alone" {
    make_repo_with_worktree
    git config --global core.hooksPath "$TEST_DIR/main/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

# Pointing at this repo's own .husky, the global value runs those hooks.
@test "git-hooks-wire: a GLOBAL hooksPath that is this repo's .husky stays quiet" {
    mkdir -p "$TEST_DIR/repo"
    git config --global core.hooksPath .husky
    cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git-hooks-wire: a working SYSTEM hooksPath is left alone, and said so" {
    mkdir -p "$TEST_DIR/system-hooks" "$TEST_DIR/repo"
    unset GIT_CONFIG_NOSYSTEM
    export GIT_CONFIG_SYSTEM="$TEST_DIR/system.gitconfig"
    git config --system core.hooksPath "$TEST_DIR/system-hooks"
    cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"system config"*"do not run"* ]]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

# A value from an [include]d file outranks the write, which lands before the
# include: claiming a repair would repeat, false, on every session.
@test "git-hooks-wire: a repair git does not read back is a warning, not a claim" {
    cd "$TEST_DIR"; git init -q; mkdir .husky
    printf '[core]\n\thooksPath = /gone\n' > "$TEST_DIR/shared.gitconfig"
    git config --local include.path "$TEST_DIR/shared.gitconfig"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"*"could not be repaired"* ]]
    [[ "$output" != *"wired to .husky"* ]] || false
}

# git -c / GIT_CONFIG_* outrank every file: a --local write changes nothing,
# and announcing a repair would be false on every session.
@test "git-hooks-wire: a command-line hooksPath is not 'repaired'" {
    cd "$TEST_DIR"; git init -q; mkdir .husky
    export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/gone
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

# An explicitly empty value is set, not unset: locally it cancels a global
# value (git resolves it to the work tree).
@test "git-hooks-wire: an explicitly EMPTY hooksPath is left alone" {
    cd "$TEST_DIR"; git init -q; mkdir .husky
    git config --local core.hooksPath ''
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = '' ]
}

# A git older than --show-scope (2.26) still gets the local repairs.
@test "git-hooks-wire: without --show-scope it falls back to the local value" {
    local real; real=$(command -v git)
    mkdir "$TEST_DIR/bin"
    printf '#!/bin/sh\nfor a; do [ "$a" = --show-scope ] && exit 129; done\nexec "%s" "$@"\n' "$real" > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/git"
    mkdir "$TEST_DIR/repo"; cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    git config --local core.hooksPath /gone/old/.husky
    PATH="$TEST_DIR/bin:$PATH" run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stale"* ]]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

@test "git-hooks-wire: without --show-scope a working global value is not taken over" {
    local real; real=$(command -v git)
    mkdir "$TEST_DIR/bin" "$TEST_DIR/global-hooks"
    printf '#!/bin/sh\nfor a; do [ "$a" = --show-scope ] && exit 129; done\nexec "%s" "$@"\n' "$real" > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/git"
    git config --global core.hooksPath "$TEST_DIR/global-hooks"
    mkdir "$TEST_DIR/repo"; cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    PATH="$TEST_DIR/bin:$PATH" run bash "$WIRE"
    [ "$status" -eq 0 ]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

@test "git-hooks-wire: a STALE global hooksPath gets the local .husky" {
    mkdir -p "$TEST_DIR/repo"
    git config --global core.hooksPath "$TEST_DIR/gone"
    cd "$TEST_DIR/repo"; git init -q; mkdir .husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stale"* ]]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}

# With extensions.worktreeConfig, a config.worktree value overrides the common
# one: a repair written to --local would not change the hooks git runs.
@test "git-hooks-wire: a stale per-worktree hooksPath is repaired in that layer" {
    cd "$TEST_DIR"; git init -q; mkdir .husky
    git config --local extensions.worktreeConfig true
    git config --worktree core.hooksPath /gone/old/.husky
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stale"* ]]
    [ "$(git config core.hooksPath)" = ".husky" ]      # the EFFECTIVE value
    [ "$(git config --worktree core.hooksPath)" = ".husky" ]
}

@test "git-hooks-wire: a working per-worktree hooksPath is left alone" {
    cd "$TEST_DIR"; git init -q; mkdir .husky .wthooks
    git config --local extensions.worktreeConfig true
    git config --worktree core.hooksPath .wthooks
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run git config --local core.hooksPath
    [ "$status" -eq 1 ]
}

# Absolute or relative is git's call, per platform: on Windows C:/x is
# absolute, here it is relative to the work tree. Asking git keeps both right.
# Run from a subdirectory: judged against the cwd, the dir would look missing.
@test "git-hooks-wire: a drive-letter hooksPath is resolved the way git resolves it" {
    cd "$TEST_DIR"; git init -q; mkdir -p .husky 'C:/hooks' sub
    git config --local core.hooksPath 'C:/hooks'
    cd sub
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = 'C:/hooks' ]
}

# Untracked (or gitignored) .husky is missing in every linked worktree, so
# relativising it would turn their hooks off: the absolute value is kept.
@test "git-hooks-wire: an ABSOLUTE hooksPath to an UNTRACKED .husky is left alone" {
    cd "$TEST_DIR"
    git init -q
    mkdir .husky
    local abs; abs="$(git rev-parse --show-toplevel)/.husky"
    git config --local core.hooksPath "$abs"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = "$abs" ]
    [ -z "$output" ]
}

# Same directory reached through a symlink and a trailing slash: a string
# comparison would miss it, the inode comparison does not.
@test "git-hooks-wire: the repo's own .husky is recognised through a symlink" {
    mkdir "$TEST_DIR/real"
    ln -s "$TEST_DIR/real" "$TEST_DIR/link"
    cd "$TEST_DIR/real"
    git init -q
    track_husky
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
    track_husky
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
    #
    # On a throwaway clone (#662): the real checkout's config is shared by its
    # linked worktrees, and a killed run would have left it rewritten.
    # safe.directory: a CI image may own the checkout as another user, and the
    # isolated global config no longer says it is trusted.
    git -c safe.directory='*' clone -q "$BASE_DIR" "$TEST_DIR/foundation"
    cd "$TEST_DIR/foundation"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]

    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]

    # Then from the state a real checkout was found in: an absolute value
    # pointing at its own .husky.
    git config --local core.hooksPath "$(git rev-parse --show-toplevel)/.husky"
    run bash "$WIRE"
    [ "$status" -eq 0 ]
    [ "$(git config --local core.hooksPath)" = ".husky" ]
}
