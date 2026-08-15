#!/usr/bin/env bash
# =============================================================================
# validator-corpus.sh — run the command guard over the foundation's OWN commands
# =============================================================================
# Builds a corpus of REAL commands from two places where a false block is a
# self-contradiction, then reports which of them the dangerous-commands policy
# refuses:
#
#   what CI executes         .github/workflows/*.yml   run: blocks
#   what the docs prescribe  ```bash / ```sh fences in docs/, templates/,
#                            .claude/, README.md, CLAUDE.md
#
# Why: regex guards are tuned against invented examples and drift. Reviewing
# the patterns by eye does not measure anything — this does. Run it BEFORE
# widening a pattern to see the finding delta, and after, to see what the
# change cost in false blocks.
#
# Usage:
#   scripts/validator-corpus.sh            # report blocked commands (TSV)
#   scripts/validator-corpus.sh --list     # print the corpus, run nothing
#   scripts/validator-corpus.sh --summary  # counts only
#
# Exit code is always 0: this is a measurement tool, not a gate. The gate is
# tests/validator-corpus.bats, which pins the blocks to a reviewed set.
# macOS bash 3.2 compatible.
# =============================================================================

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-report}"

# --- extraction ---------------------------------------------------------------

# Emit "source<TAB>command" for every runnable-looking line.
_extract() {
    # CI: `run: <cmd>` and the bodies of `run: |` blocks.
    local f
    for f in "$REPO_ROOT"/.github/workflows/*.yml; do
        [ -f "$f" ] || continue
        awk -v src="ci:$(basename "$f")" '
            /^[[:space:]]*run:[[:space:]]*\|/ { inrun=1; ind=match($0,/[^ ]/); next }
            /^[[:space:]]*run:[[:space:]]*[^|[:space:]]/ {
                line=$0; sub(/^[[:space:]]*run:[[:space:]]*/,"",line); print src "\t" line; next }
            inrun {
                if ($0 ~ /^[[:space:]]*$/) next
                cur=match($0,/[^ ]/)
                if (cur <= ind) { inrun=0; next }
                line=$0; sub(/^[[:space:]]+/,"",line); print src "\t" line
            }
        ' "$f"
    done

    # Docs: the bodies of ```bash / ```sh / ```shell / ```console fences.
    local d
    for d in docs templates .claude README.md CLAUDE.md; do
        [ -e "$REPO_ROOT/$d" ] || continue
        while IFS= read -r f; do
            awk -v src="doc:${f#"$REPO_ROOT/"}" '
                /^[[:space:]]*```(bash|sh|shell|console)[[:space:]]*$/ { inf=1; next }
                inf && /^[[:space:]]*```/ { inf=0; next }
                inf {
                    line=$0; sub(/^[[:space:]]+/,"",line); sub(/[[:space:]]+$/,"",line)
                    if (line == "") next
                    print src "\t" line
                }
            ' "$f"
        done < <(find "$REPO_ROOT/$d" -name '*.md' -type f 2>/dev/null || true)
    done
}

# Drop what is not a standalone command: comments, prompts, prose, output,
# continuations and heredoc bodies.
_filter() {
    awk -F'\t' '
        {
            c=$2
            sub(/^\$[[:space:]]+/,"",c)                       # "$ cmd" prompt
            if (c ~ /^#/) next                                 # comment
            if (c ~ /\\$/) next                                # continuation
            if (c ~ /^(```|\/\/|<!--|-->|\|)/) next
            if (c !~ /^[A-Za-z_.\/$"'"'"'\[{(]/) next          # prose / output
            print $1 "\t" c
        }' | awk -F'\t' '!seen[$2]++'
}

CORPUS="$(_extract | _filter)"

if [ "$MODE" = "--list" ]; then
    printf '%s\n' "$CORPUS"
    exit 0
fi

# --- write-target extraction over the same corpus -----------------------------
# Second guard, same method. bash-write-guard's core turns a command into
# candidate write targets; a read-only command must yield none. Ground truth
# comes from an INDEPENDENT quote-stripper (sed here, versus the awk masker the
# core uses) — agreeing implementations are the point: a command with no write
# operator left after stripping quoted spans must produce no target.
#
# This is what found the third false positive of that class, one no amount of
# re-reading the regexes had surfaced: a quoted URL whose `<placeholder>` was
# parsed as a redirection.
if [ "$MODE" = "--write-targets" ]; then
    # shellcheck source=hooks/_policy-write-targets.sh
    . "$REPO_ROOT/scripts/hooks/_policy-write-targets.sh"
    spurious=0
    while IFS=$'\t' read -r src cmd; do
        [ -n "${cmd:-}" ] || continue
        tgt=$(extract_write_targets "$cmd" | tr '\n' ' ')
        tgt="${tgt% }"
        [ -n "$tgt" ] || continue
        bare=$(printf '%s' "$cmd" | sed -E "s/\"[^\"]*\"|'[^']*'/ /g")
        # Anchor on start-of-string OR a separator: a corpus line very often
        # BEGINS with the verb (`cp a b`), which a leading-space-only pattern
        # misses — that mistake reported twelve ordinary copies as spurious.
        if printf '%s' "$bare" | grep -qE '(>>?|(^|[[:space:]|&;(])(tee|cp|mv|install)[[:space:]]|(^|[[:space:]|&;(])sed[[:space:]][^|;&]*-i|(^|[[:space:]])of=)'; then
            continue
        fi
        spurious=$((spurious + 1))
        printf '%s\t%s\t%s\n' "$tgt" "$src" "$cmd"
    done <<EOF
$CORPUS
EOF
    exit 0
fi

# --- run the policy over it ----------------------------------------------------

# shellcheck source=hooks/_policy-dangerous-commands.sh
. "$REPO_ROOT/scripts/hooks/_policy-dangerous-commands.sh"

total=0
blocked=0
BLOCKS=""
while IFS=$'\t' read -r src cmd; do
    [ -n "${cmd:-}" ] || continue
    total=$((total + 1))
    if out=$(validate_command "$cmd" 2>&1); then
        continue
    fi
    blocked=$((blocked + 1))
    reason=$(printf '%s' "$out" | head -1 | sed 's/^BLOCKED: //')
    BLOCKS="${BLOCKS}${reason}"$'\t'"${src}"$'\t'"${cmd}"$'\n'
done <<EOF
$CORPUS
EOF

if [ "$MODE" = "--summary" ]; then
    printf 'corpus: %d commands, %d blocked\n' "$total" "$blocked"
    exit 0
fi

printf '%s' "$BLOCKS"
exit 0
