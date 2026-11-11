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
#   A branch is deletable when its content is in the base by any route:
#     - its tip is an ancestor of the base (empty, fast-forward, merge commit);
#     - every commit has an equivalent patch in the base (rebase, cherry-pick);
#     - merging it into the base would change nothing (squash merge).
#   The last test is conservative: if the base has since changed the same
#   lines, the merge conflicts and the branch is kept.
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
EOF
}

# in_base <base> <base-tree> <ref> — succeeds when <ref>'s content is already
# in <base>; prints how on stdout. Every git failure answers "not in base".
in_base() {
    local base="$1" tree="$2" ref="$3" cherry merged
    if git merge-base --is-ancestor "$ref" "$base" 2>/dev/null; then
        echo "contained in $base"
        return 0
    fi
    # Capture first, test after. `git cherry | grep -q '^+'` under pipefail
    # inverted on a long branch: grep exits on the first match, cherry dies
    # of SIGPIPE past one pipe buffer (~96 commits), and the negated pipeline
    # read "nothing unmerged" — a branch full of work listed for deletion.
    if cherry=$(git cherry "$base" "$ref" 2>/dev/null) && [ -n "$cherry" ]; then
        case "
$cherry" in
            *"
+"*) ;;
            *)
                echo "every patch already in $base"
                return 0
                ;;
        esac
    fi
    # merge-tree --write-tree needs git >= 2.38; an older git fails here and
    # the branch is kept, which is the safe direction.
    if merged=$(git merge-tree --write-tree "$base" "$ref" 2>/dev/null) &&
        [ "$(printf '%s\n' "$merged" | head -n1)" = "$tree" ]; then
        echo "content already in $base (squash)"
        return 0
    fi
    return 1
}

# prune_repo <dir> <apply:0|1> — returns non-zero on a repository error.
prune_repo() {
    local dir="$1" apply="$2"
    local base tree current held b up reason ahead failed=0
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
    tree=$(git rev-parse "$base^{tree}")

    current=$(git symbolic-ref -q --short HEAD 2>/dev/null || true)
    held=$(git worktree list --porcelain 2>/dev/null |
        sed -n 's|^branch refs/heads/||p')

    while IFS= read -r b; do
        [ -n "$b" ] || continue
        if [ "$b" = "$current" ]; then
            echo "  keep    $b  (current branch)"
            n_keep=$((n_keep + 1))
            continue
        fi
        if printf '%s\n' "$held" | grep -qxF -- "$b"; then
            echo "  keep    $b  (checked out in a worktree)"
            n_keep=$((n_keep + 1))
            continue
        fi
        # %(upstream) of the full ref: `<name>@{upstream}` is ambiguous when a
        # tag shares the name, and `refs/heads/<name>@{upstream}` never resolves.
        up=$(git for-each-ref --format='%(upstream)' "refs/heads/$b")
        if [ -n "$up" ] && git rev-parse -q --verify "$up" >/dev/null &&
            ! in_base "$base" "$tree" "$up" >/dev/null; then
            echo "  keep    $b  (upstream ${up#refs/remotes/} has work not in $base)"
            n_keep=$((n_keep + 1))
            continue
        fi
        if reason=$(in_base "$base" "$tree" "refs/heads/$b"); then
            echo "  delete  $b  ($reason)"
            deletable="$deletable$b
"
            n_delete=$((n_delete + 1))
        else
            ahead=$(git rev-list --count "$base..refs/heads/$b")
            echo "  keep    $b  ($ahead commit(s) not in $base)"
            n_keep=$((n_keep + 1))
        fi
    done <<EOF
$(git for-each-ref --format='%(refname:lstrip=2)' 'refs/heads/feature/auto-*')
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

    # Checked one by one: set -e does not hold in a subshell whose status the
    # caller tests, so an unchecked failure would still print "deleted".
    while IFS= read -r b; do
        [ -n "$b" ] || continue
        if git branch -q -D "$b"; then
            echo "  deleted $b"
        else
            echo "  FAILED to delete $b" >&2
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

main "$@"
