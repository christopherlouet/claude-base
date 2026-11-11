#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/branches.sh prune-auto — removes the feature/auto-* branches
# main-branch-guard.sh leaves behind, once their content is already in main.
#
# Deleting a branch is the one thing this script does that cannot be undone
# from the branch list, so most cases below are branches it must KEEP: a commit
# of its own (the planted witness), the current branch, a worktree's branch,
# an upstream carrying work main does not have.
# =============================================================================

load 'test_helper'

SCRIPT="$BATS_TEST_DIRNAME/../scripts/branches.sh"
DISPATCHER="$BATS_TEST_DIRNAME/../bin/claude-base"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# init_repo <dir> [base] — a repo with one commit on <base> (default main).
init_repo() {
    local dir="$1" base="${2:-main}"
    git init -q -b "$base" "$dir"
    # The user's global hooks would run on every test commit: slow, and not
    # what these tests are about.
    mkdir -p "$TEST_DIR/no-hooks"
    git -C "$dir" config core.hooksPath "$TEST_DIR/no-hooks"
    git -C "$dir" config user.email t@t.t
    git -C "$dir" config user.name t
    echo x > "$dir/f.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -qm init
}

# commit_on <dir> <file> <content> — commit one file change on the current branch.
commit_on() {
    echo "$3" > "$1/$2"
    git -C "$1" add -A
    git -C "$1" commit -qm "edit $2"
}

has_branch() { git -C "$1" show-ref -q --verify "refs/heads/$2"; }

R() { echo "$TEST_DIR/repo"; }

# --- Listing (the default never deletes) ------------------------------------

@test "prune-auto: default run lists an empty auto branch and deletes nothing" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto "$(R)" </dev/null
    [ "$status" -eq 0 ]
    [[ "$output" == *"delete"*"feature/auto-20260101-000000"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: only feature/auto-* branches are considered" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/x
    git -C "$(R)" branch auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/x
    has_branch "$(R)" auto-20260101-000000
}

@test "prune-auto: no auto branch at all → says so, exit 0" {
    init_repo "$(R)"
    run bash "$SCRIPT" prune-auto "$(R)" </dev/null
    [ "$status" -eq 0 ]
    [[ "$output" == *"no feature/auto-"* ]]
}

# --- Deletion, only after confirmation --------------------------------------

@test "prune-auto: --apply + yes deletes an empty auto branch" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: --apply + no deletes nothing" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"n"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: --apply with no answer (closed stdin) deletes nothing" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" </dev/null
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: one confirmation PER repository" {
    init_repo "$TEST_DIR/a"; init_repo "$TEST_DIR/b"
    git -C "$TEST_DIR/a" branch feature/auto-20260101-000000
    git -C "$TEST_DIR/b" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$TEST_DIR/a" "$TEST_DIR/b" <<<$'y\nn'
    [ "$status" -eq 0 ]
    ! has_branch "$TEST_DIR/a" feature/auto-20260101-000000 || false
    has_branch "$TEST_DIR/b" feature/auto-20260101-000000
}

# --- "Merged" covers every way work reaches main ----------------------------

@test "prune-auto: a branch merged with a merge commit is deletable" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" g.txt g
    git -C "$(R)" checkout -q main
    git -C "$(R)" merge -q --no-ff -m merge feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: a rebase/cherry-picked commit is deletable (patch-id)" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" g.txt g
    git -C "$(R)" checkout -q main
    commit_on "$(R)" other.txt o   # main moved on, so the pick gets a new id
    git -C "$(R)" cherry-pick feature/auto-20260101-000000 >/dev/null
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: a SQUASH-merged multi-commit branch is deletable" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" g.txt g1
    commit_on "$(R)" g.txt g2
    commit_on "$(R)" h.txt h
    git -C "$(R)" checkout -q main
    git -C "$(R)" merge -q --squash feature/auto-20260101-000000
    git -C "$(R)" commit -qm squashed
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

# --- What it must KEEP ------------------------------------------------------

@test "prune-auto: PLANTED WITNESS — an auto branch with a unique commit is kept" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000          # empty: goes
    git -C "$(R)" checkout -q -b feature/auto-20260102-000000  # witness: stays
    commit_on "$(R)" unique.txt only-here
    git -C "$(R)" checkout -q main
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"keep"*"feature/auto-20260102-000000"* ]]
    has_branch "$(R)" feature/auto-20260102-000000
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: a branch with MANY unmerged commits is kept (no SIGPIPE inversion)" {
    # `git cherry | grep -q` under pipefail: grep exits on the first match,
    # cherry dies of SIGPIPE once its output passes a pipe buffer (~96
    # lines), and the negated pipeline then read "nothing unmerged".
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    local i
    for i in $(seq 1 150); do
        echo "$i" > "$(R)/n.txt"
        git -C "$(R)" add n.txt
        git -C "$(R)" commit -qm "c$i"
    done
    git -C "$(R)" checkout -q main
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"keep"*"150 commit(s) not in main"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a tag with the same name does not hide the branch" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    git -C "$(R)" tag feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"deleted feature/auto-20260101-000000"* ]]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: a deletion that fails is reported and the run fails" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    # A held ref lock makes `git branch -D` fail.
    mkdir -p "$(R)/.git/refs/heads/feature"
    : > "$(R)/.git/refs/heads/feature/auto-20260101-000000.lock"
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -ne 0 ]
    [[ "$output" == *"FAILED"*"feature/auto-20260101-000000"* ]]
    [[ "$output" != *"deleted feature/auto-20260101-000000"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: work living only in a MERGE commit is kept" {
    # git cherry skips merge commits: an evil merge's content is invisible to
    # patch-ids, so "every patch already in main" deleted it.
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b side
    commit_on "$(R)" side.txt s
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000 main
    git -C "$(R)" merge -q --no-ff --no-commit side
    echo evil > "$(R)/evil.txt"; git -C "$(R)" add -A; git -C "$(R)" commit -qm "merge side"
    git -C "$(R)" checkout -q main
    commit_on "$(R)" other.txt o   # main moved on: the pick gets a new id
    git -C "$(R)" cherry-pick side >/dev/null
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a patch main took then REVERTED is kept" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" g.txt g
    git -C "$(R)" checkout -q main
    commit_on "$(R)" other.txt o
    git -C "$(R)" cherry-pick feature/auto-20260101-000000 >/dev/null
    git -C "$(R)" revert --no-edit HEAD >/dev/null
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a change main has only up to WHITESPACE is kept" {
    init_repo "$(R)"
    printf 'def f():\n  x()\n' > "$(R)/p.py"; git -C "$(R)" add -A; git -C "$(R)" commit -qm py
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    printf 'def f():\n    x()\n' > "$(R)/p.py"; git -C "$(R)" commit -qam spaces
    git -C "$(R)" checkout -q main
    printf 'def f():\n\tx()\n' > "$(R)/p.py"; git -C "$(R)" commit -qam tab
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a TAG named main does not stand in for the main branch" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" unique.txt only-here
    git -C "$(R)" tag main     # the tag holds the work; the branch main does not
    git -C "$(R)" checkout -q -f refs/heads/main 2>/dev/null || git -C "$(R)" symbolic-ref HEAD refs/heads/main
    git -C "$(R)" reset -q --hard refs/heads/main
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a branch that MOVES while the prompt waits is not deleted" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    git -C "$(R)" checkout -q -b side
    commit_on "$(R)" late.txt committed-during-the-prompt
    git -C "$(R)" checkout -q main
    run bash -c "{ sleep 2; git -C '$(R)' update-ref refs/heads/feature/auto-20260101-000000 refs/heads/side; echo y; } | bash '$SCRIPT' prune-auto --apply '$(R)' 2>&1"
    [ "$status" -ne 0 ]
    [[ "$output" == *"FAILED"*"feature/auto-20260101-000000"* ]]
    [ "$(git -C "$(R)" rev-parse feature/auto-20260101-000000)" = "$(git -C "$(R)" rev-parse side)" ]
}

@test "prune-auto: a squash that took only PART of the branch keeps it" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" g.txt g
    commit_on "$(R)" late.txt after-the-squash
    git -C "$(R)" checkout -q main
    echo g > "$(R)/g.txt"; git -C "$(R)" add -A; git -C "$(R)" commit -qm "partial squash"
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: the current branch is kept even when empty" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"keep"*"current"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a branch checked out in another worktree is kept" {
    init_repo "$(R)"
    git -C "$(R)" worktree add -q "$TEST_DIR/wt" -b feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"keep"*"worktree"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: run FROM a linked worktree, the main checkout's branch is kept" {
    init_repo "$(R)"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    git -C "$(R)" worktree add -q "$TEST_DIR/wt" -b side main
    run bash "$SCRIPT" prune-auto --apply "$TEST_DIR/wt" <<<"y"
    [ "$status" -eq 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: an upstream carrying work main lacks keeps the branch" {
    init_repo "$(R)"
    git init -q --bare "$TEST_DIR/origin.git"
    git -C "$(R)" remote add origin "$TEST_DIR/origin.git"
    git -C "$(R)" checkout -q -b feature/auto-20260101-000000
    commit_on "$(R)" pushed.txt only-on-the-remote
    git -C "$(R)" push -q -u origin feature/auto-20260101-000000
    git -C "$(R)" checkout -q main
    git -C "$(R)" branch -f feature/auto-20260101-000000 main   # local now empty
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    [[ "$output" == *"keep"*"upstream"* ]]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: an upstream already in main does not hold the branch" {
    init_repo "$(R)"
    git init -q --bare "$TEST_DIR/origin.git"
    git -C "$(R)" remote add origin "$TEST_DIR/origin.git"
    git -C "$(R)" push -q origin main
    git -C "$(R)" branch feature/auto-20260101-000000
    git -C "$(R)" push -q -u origin feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
    # The remote branch is never touched: deleting it is a separate decision.
    git -C "$TEST_DIR/origin.git" show-ref -q --verify refs/heads/feature/auto-20260101-000000
}

# --- Base branch and errors -------------------------------------------------

@test "prune-auto: works on a master-based repository" {
    init_repo "$(R)" master
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -eq 0 ]
    ! has_branch "$(R)" feature/auto-20260101-000000 || false
}

@test "prune-auto: no main nor master → refuses, deletes nothing" {
    init_repo "$(R)" trunk
    git -C "$(R)" branch feature/auto-20260101-000000
    run bash "$SCRIPT" prune-auto --apply "$(R)" <<<"y"
    [ "$status" -ne 0 ]
    has_branch "$(R)" feature/auto-20260101-000000
}

@test "prune-auto: a path that is not a git repository fails" {
    mkdir -p "$TEST_DIR/plain"
    run bash "$SCRIPT" prune-auto "$TEST_DIR/plain" </dev/null
    [ "$status" -ne 0 ]
    [[ "$output" == *"not a git repository"* ]]
}

@test "branches: unknown subcommand and unknown option fail" {
    run bash "$SCRIPT" frobnicate
    [ "$status" -eq 2 ]
    run bash "$SCRIPT" prune-auto --bogus
    [ "$status" -eq 2 ]
}

@test "branches: reachable through the dispatcher" {
    init_repo "$(R)"
    git -C "$(R)" branch feature/auto-20260101-000000
    run "$DISPATCHER" branches prune-auto "$(R)" </dev/null
    [ "$status" -eq 0 ]
    [[ "$output" == *"feature/auto-20260101-000000"* ]]
}

# --- Self-application: the real foundation ----------------------------------

@test "prune-auto: on the real foundation, the default run changes no ref" {
    local before after
    before=$(git -C "$BASE_DIR" for-each-ref --format='%(refname) %(objectname)' refs/heads)
    run bash "$SCRIPT" prune-auto "$BASE_DIR" </dev/null
    [ "$status" -eq 0 ]
    after=$(git -C "$BASE_DIR" for-each-ref --format='%(refname) %(objectname)' refs/heads)
    [ "$before" = "$after" ]
}
