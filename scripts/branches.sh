#!/usr/bin/env bash

# =============================================================================
# scripts/branches.sh — housekeeping for branches the foundation creates
#
#   prune-auto [--apply] [REPO...]
#       main-branch-guard.sh moves an edit made on main/master to a fresh
#       feature/auto-<timestamp> branch, and nothing removed those branches
#       afterwards: dozens per repository, most of them empty. This lists the
#       feature/auto-* branches whose content is already in main (or master)
#       and, with --apply, deletes them after ONE confirmation per repository.
#       REPO defaults to the current directory.
#
#   A branch is deletable when its CONTENT is in the base:
#     - its tip is an ancestor of the base (empty, fast-forward, merge commit);
#     - or merging it into the base would change nothing (rebase, cherry-pick,
#       squash merge): `git merge-tree --write-tree` gives the base's tree.
#   Patch-ids (`git cherry`) are deliberately NOT a criterion: they skip merge
#   commits (an evil merge's content), ignore whitespace, and still match a
#   patch the base took and then reverted — three ways to delete real work.
#   The merge test is conservative: if the base has since changed the same
#   lines, the merge conflicts and the branch is kept; on git < 2.38 it is
#   unavailable and only the ancestor test applies.
#
#   Never deleted, whatever their content:
#     - the current branch, and any branch checked out in a worktree;
#     - a branch whose upstream holds work the base does not have;
#     - anything not named feature/auto-*.
#   Only LOCAL branches are deleted; a remote branch is left in place.
# =============================================================================

set -euo pipefail

usage() {
    cat <<'EOF'
USAGE
    claude-base branches prune-auto [--apply] [REPO...]

    Lists the feature/auto-* branches whose content is already in main (or
    master). With --apply, deletes them after one confirmation per repository.
    "Already in main" is judged on CONTENT: a rebased, cherry-picked or
    squash-merged branch counts as merged even though main lacks its commits.
    Kept: the current branch, worktree branches, branches whose upstream holds
    unmerged work, and any branch with content main does not have.
    The LOCAL main is the reference: pull it first, or branches merged on the
    remote since are reported as unmerged.
EOF
}

# in_base <base-ref> <base-tree> <ref> — succeeds when <ref>'s content is
# already in the base; prints how on stdout. Every git failure answers "not in
# base". The base is a FULL ref: a tag named main would win over the branch.
in_base() {
    local base="$1" tree="$2" ref="$3" merged
    if git merge-base --is-ancestor "$ref" "$base" 2>/dev/null; then
        echo "contained in ${base#refs/heads/}"
        return 0
    fi
    if merged=$(git merge-tree --write-tree "$base" "$ref" 2>/dev/null) &&
        [ "${merged%%$'\n'*}" = "$tree" ]; then
        echo "content already in ${base#refs/heads/} (rebase or squash)"
        return 0
    fi
    return 1
}

# prune_repo <dir> <apply:0|1> — returns non-zero on a repository error.
prune_repo() {
    local dir="$1" apply="$2"
    local base ref tree current held sha b up reason ahead failed=0
    local deletable="" n_delete=0 n_keep=0

    if ! git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
        echo "$dir: not a git repository" >&2
        return 1
    fi
    cd "$dir" || return 1

    if git show-ref -q --verify refs/heads/main; then
        base=main
    elif git show-ref -q --verify refs/heads/master; then
        base=master
    else
        echo "$dir: no main nor master branch to compare against" >&2
        return 1
    fi

    echo "== $dir (base: $base)"
    # Full ref from here on: a TAG named main resolves before the branch.
    ref="refs/heads/$base"
    tree=$(git rev-parse "$ref^{tree}")

    current=$(git symbolic-ref -q --short HEAD 2>/dev/null || true)
    held=$(git worktree list --porcelain 2>/dev/null |
        sed -n 's|^branch refs/heads/||p')

    # One query: tip, upstream and name, ':'-separated (a ref name cannot hold
    # one). lstrip=2, never :short, which prefixes "heads/" when a tag shares
    # the name. The tip is kept so the deletion can refuse a branch that moved.
    while IFS=: read -r sha up b; do
        [ -n "$b" ] || continue
        if [ "$b" = "$current" ]; then
            echo "  keep    $b  (current branch)"
            n_keep=$((n_keep + 1))
            continue
        fi
        # A shell match, not `printf | grep -q`: under pipefail that pipe can
        # die of SIGPIPE and read "not held".
        case "
$held
" in *"
$b
"*)
            echo "  keep    $b  (checked out in a worktree)"
            n_keep=$((n_keep + 1))
            continue
            ;;
        esac
        if [ -n "$up" ] && git rev-parse -q --verify "$up" >/dev/null &&
            ! in_base "$ref" "$tree" "$up" >/dev/null; then
            echo "  keep    $b  (upstream ${up#refs/remotes/} has work not in $base)"
            n_keep=$((n_keep + 1))
            continue
        fi
        if reason=$(in_base "$ref" "$tree" "$sha"); then
            echo "  delete  $b  ($reason)"
            deletable="$deletable$sha $b
"
            n_delete=$((n_delete + 1))
        else
            ahead=$(git rev-list --count "$ref..$sha")
            echo "  keep    $b  ($ahead commit(s) not in $base)"
            n_keep=$((n_keep + 1))
        fi
    done <<EOF
$(git for-each-ref --format='%(objectname):%(upstream):%(refname:lstrip=2)' 'refs/heads/feature/auto-*')
EOF

    if [ $((n_delete + n_keep)) -eq 0 ]; then
        echo "  no feature/auto-* branch"
        return 0
    fi
    echo "  $n_delete to delete, $n_keep kept"

    [ "$apply" = "1" ] && [ "$n_delete" -gt 0 ] || return 0

    local answer=""
    printf 'Delete %s branch(es) in %s? [y/N] ' "$n_delete" "$dir"
    read -r answer || answer=""
    echo
    case "$answer" in
        y | Y | yes | YES) ;;
        *)
            echo "  nothing deleted"
            return 0
            ;;
    esac

    # The prompt may wait for minutes while another session works: re-check
    # every branch at deletion time. Its tip must still be the one judged
    # above (a commit landed meanwhile), and `git branch -D` — not update-ref,
    # which bypasses it — refuses a branch any worktree has checked out,
    # rebases or bisects (the guard may have switched onto it meanwhile).
    # Checked one by one: set -e does not hold in a subshell whose status the
    # caller tests, so an unchecked failure would still print "deleted". The
    # old tip is printed: the branch's reflog goes with it.
    while IFS=' ' read -r sha b; do
        [ -n "$b" ] || continue
        if [ "$(git rev-parse -q --verify "refs/heads/$b" 2>/dev/null || true)" != "$sha" ]; then
            echo "  FAILED to delete $b (moved since the scan)" >&2
            failed=1
        elif git branch -q -D "$b" 2>/dev/null; then
            echo "  deleted $b (was $(git rev-parse --short "$sha"))"
        else
            echo "  FAILED to delete $b (in use, or locked)" >&2
            failed=1
        fi
    done <<EOF
$deletable
EOF
    return "$failed"
}

cmd_prune_auto() {
    local apply=0 rc=0 dir
    local dirs=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --apply) apply=1 ;;
            -h | --help)
                usage
                return 0
                ;;
            -*)
                echo "branches prune-auto: unknown option '$1'" >&2
                return 2
                ;;
            *) dirs="$dirs$1
" ;;
        esac
        shift
    done
    [ -n "$dirs" ] || dirs="$PWD
"
    # The list is read on fd 3: stdin stays free for each confirmation, which
    # would otherwise consume the next repository's path as its answer.
    while IFS= read -r dir <&3; do
        [ -n "$dir" ] || continue
        # A subshell per repository: prune_repo changes directory, and one
        # repository's failure must not stop the next one.
        (prune_repo "$dir" "$apply") || rc=1
    done 3<<EOF
$dirs
EOF
    return "$rc"
}

main() {
    local sub="${1:-}"
    shift || true
    case "$sub" in
        prune-auto) cmd_prune_auto "$@" ;;
        -h | --help | help | "") usage ;;
        *)
            echo "branches: unknown subcommand '$sub'" >&2
            usage >&2
            return 2
            ;;
    esac
}

# Sourcing loads the functions without running the CLI.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
