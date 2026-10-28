#!/usr/bin/env bash
# =============================================================================
# gen-pristine-hashes.sh — record the sha256 of every version of the managed
# scripts the foundation ever shipped, so `update` can tell an UNMODIFIED copy
# of an older release from a customised one.
#
# Why: both simply differ from today's copy. update skipped both without
# --force, and --force overwrote real customisations along with them — so even
# `update --hook-scripts` left a v5.3.0 install's security libraries on their
# v5.3.0 rules (measured 2026-09-15). Installs are `git clone --depth 1`: the
# history is not there at update time, so the answer is computed here, from the
# full history, and shipped as scripts/lib/pristine-hashes.txt.
#
# Managed set: scripts/hooks/*.sh, scripts/substance-check.sh (the detector
# update refreshes alongside the hooks), and every file under the .claude/
# directories update refreshes: skills, agents, rules, commands, output-styles,
# templates. The same trap held there: a real v5.4.0 install had all 52 skills
# skipped as customised while each was byte-identical to a release (2026-09-27).
# Also the files init copies under another name (#657), keyed by their INSTALL
# path: templates/husky/<f> and, until #540 copied verbatim, the foundation's
# own .husky/<f> as .husky/<f>; .commitlintrc.json; templates/lint-staged/
# .lintstagedrc.mjs as .lintstagedrc.mjs; and .lintstagedrc.json, shipped
# before #654 and retired since (update replaces an unmodified one).
#
# Sources: every blob those paths held in any commit reachable from HEAD, plus
# the INDEX (so the pre-commit hook records a version before it is committed),
# plus every entry the table already lists. Append-only: a squash merge erases
# a branch's intermediate commits, so a rebuild from history alone dropped
# their entries on the next branch and the table churned on every PR (#662);
# some of those versions also reached fleet projects (an update run from a
# release branch), and forgetting one turns an unmodified copy into a
# "customisation". Nothing is ever removed, so no PR shows a deletion.
#
# Modes:
#   (default)  write the table
#   --check    READ-ONLY: exit 1 if any version in history is missing from the
#              committed table, or if an entry the table held where this
#              branch left origin/main or main was removed (append-only: put
#              it back, regenerating cannot). Warns when neither ref exists,
#              since that second check then has nothing to compare. Extra
#              entries are tolerated: the table keeps versions a squash merge
#              erased from history, and an entry for foundation-authored
#              content is harmless.
#
# Exit 0 ok · 1 --check found missing or removed entries · 2 shallow clone /
# usage error.
#
# Test seam: PRISTINE_ROOT (repo root; default: this script's parent dir).
# macOS bash 3.2 compatible.
# =============================================================================

set -euo pipefail

ROOT="${PRISTINE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TABLE="$ROOT/scripts/lib/pristine-hashes.txt"
MODE="${1:-write}"

case "$MODE" in
    write|--check) ;;
    *) echo "usage: $(basename "$0") [--check]" >&2; exit 2 ;;
esac

if [ "$(git -C "$ROOT" rev-parse --is-shallow-repository)" != "false" ]; then
    echo "[pristine-hashes] shallow clone: the history the table is derived from is not here. Run 'git fetch --unshallow' first." >&2
    exit 2
fi

sha256_stdin() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1
    else shasum -a 256 | cut -d' ' -f1
    fi
}

# Word-split on purpose: none of these paths holds a space.
MANAGED_PATHS="scripts/hooks scripts/substance-check.sh .claude/skills .claude/agents .claude/rules .claude/commands .claude/output-styles .claude/templates .husky templates/husky templates/lint-staged/.lintstagedrc.mjs .lintstagedrc.json .commitlintrc.json"

# install_path <path> — the path a file is installed at in a project.
install_path() {
    case "$1" in
        templates/husky/*) printf '%s\n' ".husky/${1#templates/husky/}" ;;
        templates/lint-staged/.lintstagedrc.mjs) printf '%s\n' ".lintstagedrc.mjs" ;;
        *) printf '%s\n' "$1" ;;
    esac
}

is_managed() {
    case "$1" in
        scripts/substance-check.sh) return 0 ;;
        scripts/hooks/*/*) return 1 ;;
        scripts/hooks/*.sh) return 0 ;;
        .claude/skills/*|.claude/agents/*|.claude/rules/*|.claude/commands/*) return 0 ;;
        .claude/output-styles/*|.claude/templates/*) return 0 ;;
        .husky/*/*) return 1 ;;
        .husky/*|.commitlintrc.json|.lintstagedrc.mjs|.lintstagedrc.json) return 0 ;;
    esac
    return 1
}

# "<blob> <path>" for every version of a managed path: the post-image of each
# change in history (renames split into delete + add, so a moved file keeps its
# versions under both paths; -m and --full-history so content that only a merge
# commit introduced, like a resolved conflict, is seen), then the index.
blob_paths() {
    if git -C "$ROOT" rev-parse -q --verify HEAD >/dev/null 2>&1; then
        # shellcheck disable=SC2086  # MANAGED_PATHS is a word list
        git -C "$ROOT" log -m --full-history --format= --raw --no-abbrev --no-renames HEAD -- $MANAGED_PATHS \
            | awk -F'\t' '{ split($1, m, " "); if (m[4] !~ /^0+$/) print m[4] " " $2 }'
    fi
    # shellcheck disable=SC2086  # MANAGED_PATHS is a word list
    git -C "$ROOT" ls-files -s -- $MANAGED_PATHS \
        | awk -F'\t' '{ split($1, m, " "); print m[2] " " $2 }'
}

generate() {
    local blob path
    blob_paths | sort -u | while read -r blob path; do
        path=$(install_path "$path")
        is_managed "$path" || continue
        printf '%s %s\n' "$(git -C "$ROOT" cat-file blob "$blob" | sha256_stdin)" "$path"
    done | LC_ALL=C sort -u
}

HEADER="# Generated by scripts/gen-pristine-hashes.sh - do not edit.
# sha256 of every version of scripts/hooks/*.sh, scripts/substance-check.sh, the
# .claude/ files update refreshes and the hook configs init installs (keyed by
# their install path), from every commit the table was ever generated on
# (release branches merged into main included). Append-only. update replaces a
# copy whose hash is listed for its path: it is an unmodified foundation copy,
# not a customisation."

# table_entries — the entries of the table on stdin: well-formed lines for a
# managed path (a path may hold a space). One definition for both modes.
table_entries() {
    local hash path
    { grep -E '^[0-9a-f]{64} .+$' || true; } | while read -r hash path; do
        if is_managed "$path"; then printf '%s %s\n' "$hash" "$path"; fi
    done
}

# base_tables — the table as committed where this branch left origin/main and
# main. The table is append-only, so every entry there must still be here.
base_tables() {
    local ref mb found=0
    for ref in refs/remotes/origin/main refs/heads/main; do
        mb=$(git -C "$ROOT" merge-base HEAD "$ref" 2>/dev/null) || continue
        found=1
        git -C "$ROOT" show "$mb:scripts/lib/pristine-hashes.txt" 2>/dev/null || true
    done
    if [ "$found" -eq 0 ]; then
        echo "[pristine-hashes] no origin/main or main: removed entries not checked." >&2
    fi
}

if [ "$MODE" = "--check" ]; then
    if [ ! -f "$TABLE" ]; then
        echo "[pristine-hashes] $TABLE is missing. Run scripts/gen-pristine-hashes.sh." >&2
        exit 1
    fi
    current=$(table_entries < "$TABLE" | LC_ALL=C sort -u)
    missing=$(generate | LC_ALL=C comm -23 - <(printf '%s\n' "$current"))
    if [ -n "$missing" ]; then
        echo "[pristine-hashes] shipped versions missing from the table - run scripts/gen-pristine-hashes.sh:" >&2
        printf '%s\n' "$missing" >&2
        exit 1
    fi
    lost=$(base_tables | table_entries | LC_ALL=C sort -u | LC_ALL=C comm -23 - <(printf '%s\n' "$current"))
    if [ -n "$lost" ]; then
        echo "[pristine-hashes] the table is append-only, but entries main's table lists were removed - restore them:" >&2
        printf '%s\n' "$lost" >&2
        exit 1
    fi
    exit 0
fi

mkdir -p "$(dirname "$TABLE")"
{
    printf '%s\n' "$HEADER"
    { generate; [ ! -f "$TABLE" ] || table_entries < "$TABLE"; } | LC_ALL=C sort -u
} > "$TABLE.tmp"
mv "$TABLE.tmp" "$TABLE"
