#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/main-branch-guard.sh — PreToolUse (Edit|Write) hook
# that keeps edits off main/master by auto-creating a feature branch first.
# Extracted from an inline settings.json `bash -c` gate (ZERO coverage) and
# fixed: the inline version `exit 0`'d even when `git checkout -b` FAILED, so
# an edit would then land directly on main. The extracted hook BLOCKS (exit 2)
# when the auto-branch cannot be created.
# =============================================================================

load 'test_helper'

GUARD="$BATS_TEST_DIRNAME/../scripts/hooks/main-branch-guard.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# init_repo <dir> <branch> — a minimal git repo with one commit on <branch>.
init_repo() {
    local dir="$1" branch="$2"
    git init -q -b "$branch" "$dir"
    git -C "$dir" config user.email t@t.t
    git -C "$dir" config user.name t
    echo x > "$dir/f.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -qm init
}

@test "main-branch-guard: on main → auto-creates a feature branch and allows (exit 0)" {
    init_repo "$TEST_DIR/repo" main
    run bash -c "cd '$TEST_DIR/repo' && bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 0 ]
    local cur
    cur=$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)
    [[ "$cur" == feature/auto-* ]]
}

@test "main-branch-guard: also triggers on master" {
    init_repo "$TEST_DIR/repo" master
    run bash -c "cd '$TEST_DIR/repo' && bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 0 ]
    local cur
    cur=$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)
    [[ "$cur" == feature/auto-* ]]
}

@test "main-branch-guard: on a feature branch → no-op (exit 0, no new branch)" {
    init_repo "$TEST_DIR/repo" main
    git -C "$TEST_DIR/repo" checkout -q -b feature/x
    run bash -c "cd '$TEST_DIR/repo' && bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 0 ]
    local cur
    cur=$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)
    [ "$cur" = "feature/x" ]
}

@test "main-branch-guard: ALLOW_MAIN_EDIT=1 bypasses even on main (stays on main)" {
    init_repo "$TEST_DIR/repo" main
    run bash -c "cd '$TEST_DIR/repo' && ALLOW_MAIN_EDIT=1 bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 0 ]
    local cur
    cur=$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)
    [ "$cur" = "main" ]
}

@test "main-branch-guard: BLOCKS (exit 2) when on main and branch creation fails" {
    # Fake git: reports 'main' for rev-parse but fails 'checkout -b'.
    local fake="$TEST_DIR/bin"; mkdir -p "$fake"
    cat > "$fake/git" <<'SH'
#!/usr/bin/env bash
[ "$1" = "rev-parse" ] && { echo main; exit 0; }
[ "$1" = "checkout" ] && exit 1
exit 0
SH
    chmod +x "$fake/git"
    run bash -c "PATH=\"$fake:\$PATH\" bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "main-branch-guard: no git available → exit 0 (nothing to guard)" {
    local fake="$TEST_DIR/nogit"; mkdir -p "$fake"
    local b
    for b in bash cat; do ln -sf "$(command -v "$b")" "$fake/$b"; done
    run bash -c "PATH='$fake' bash '$GUARD' </dev/null 2>&1"
    [ "$status" -eq 0 ]
}

# --- Target scoping ---------------------------------------------------------
# The guard fires on the TOOL, not on the path. An edit aimed outside the
# working tree (a dotfile in $HOME, a second project) branched the repo for a
# change it will never contain, leaving an empty feature/auto-* the user had to
# notice and delete. A guard that reacts to what it does not guard is one the
# user learns to ignore. The tests above deliberately keep feeding an EMPTY
# stdin: an unreadable target must still guard, so they pin that fallback.

# guard_on <repo> <file-path> — feed a PreToolUse Edit envelope on stdin.
guard_on() {
    local json
    json=$(jq -n --arg f "$2" '{tool_name:"Edit", tool_input:{file_path:$f}}')
    printf '%s' "$json" > "$TEST_DIR/in.json"
    run bash -c "cd '$1' && bash '$GUARD' < '$TEST_DIR/in.json' 2>&1"
}

@test "main-branch-guard: editing a file INSIDE the repo still branches" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    guard_on "$TEST_DIR/repo" "$TEST_DIR/repo/f.txt"
    [ "$status" -eq 0 ]
    [[ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" == feature/auto-* ]]
}

@test "main-branch-guard: a not-yet-existing path inside the repo still branches" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    guard_on "$TEST_DIR/repo" "$TEST_DIR/repo/sub/new.py"
    [ "$status" -eq 0 ]
    [[ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" == feature/auto-* ]]
}

@test "main-branch-guard: a relative path resolves against the repo and branches" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    guard_on "$TEST_DIR/repo" "f.txt"
    [ "$status" -eq 0 ]
    [[ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" == feature/auto-* ]]
}

@test "main-branch-guard: a relative path ignores CLAUDE_PROJECT_DIR" {
    # The dangerous direction: the hook reads the branch and switches it in the
    # repo at $PWD, so a relative target must resolve against that same root.
    # Resolving against CLAUDE_PROJECT_DIR put an IN-repo path outside the tree
    # whenever the two differ (worktree, sub-repo, second project) and the
    # guard fell silent on the edit it exists to catch. Green in any shell
    # where CLAUDE_PROJECT_DIR is unset — which is every shell except the one
    # the hook actually runs in.
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    mkdir -p "$TEST_DIR/another-project"
    local json
    json=$(jq -n '{tool_name:"Edit", tool_input:{file_path:"f.txt"}}')
    printf '%s' "$json" > "$TEST_DIR/in.json"
    run bash -c "cd '$TEST_DIR/repo' && CLAUDE_PROJECT_DIR='$TEST_DIR/another-project' bash '$GUARD' < '$TEST_DIR/in.json' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" == feature/auto-* ]]
}

@test "main-branch-guard: editing a file OUTSIDE the repo leaves the branch alone" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    mkdir -p "$TEST_DIR/elsewhere"
    echo x > "$TEST_DIR/elsewhere/dotfile"
    guard_on "$TEST_DIR/repo" "$TEST_DIR/elsewhere/dotfile"
    [ "$status" -eq 0 ]
    [ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" = "main" ]
}

@test "main-branch-guard: a path climbing out with .. is outside" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    guard_on "$TEST_DIR/repo" "$TEST_DIR/repo/../elsewhere.txt"
    [ "$status" -eq 0 ]
    [ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" = "main" ]
}

@test "main-branch-guard: a sibling sharing a name prefix is outside" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    mkdir -p "$TEST_DIR/repo-notes"
    echo x > "$TEST_DIR/repo-notes/note.md"
    guard_on "$TEST_DIR/repo" "$TEST_DIR/repo-notes/note.md"
    [ "$status" -eq 0 ]
    [ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" = "main" ]
}

@test "main-branch-guard: an envelope with no path still guards" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    printf '%s' '{"tool_name":"Edit","tool_input":{}}' > "$TEST_DIR/in.json"
    run bash -c "cd '$TEST_DIR/repo' && bash '$GUARD' < '$TEST_DIR/in.json' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" == feature/auto-* ]]
}

@test "main-branch-guard: NotebookEdit's notebook_path is read too" {
    skip_if_no_jq
    init_repo "$TEST_DIR/repo" main
    mkdir -p "$TEST_DIR/elsewhere"
    jq -n --arg f "$TEST_DIR/elsewhere/n.ipynb" \
        '{tool_name:"NotebookEdit", tool_input:{notebook_path:$f}}' > "$TEST_DIR/in.json"
    run bash -c "cd '$TEST_DIR/repo' && bash '$GUARD' < '$TEST_DIR/in.json' 2>&1"
    [ "$status" -eq 0 ]
    [ "$(git -C "$TEST_DIR/repo" rev-parse --abbrev-ref HEAD)" = "main" ]
}
