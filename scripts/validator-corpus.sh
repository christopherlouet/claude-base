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
#   scripts/validator-corpus.sh --transcripts [--summary]
#       the agent's OWN Bash commands, from Claude Code transcripts
#       ($CLAUDE_TRANSCRIPTS_DIR, default ~/.claude/projects), each judged
#       WHOLE as the hook sees it — multi-line commands and heredoc bodies
#       included, which the two sources above drop by construction. Personal
#       data: a local measurement, never a CI input. CORPUS_JOBS sets the
#       worker count (default: the CPU count; the policy costs ~60 ms a command).
#
# Exit code is 0: this is a measurement tool, not a gate (2 when the
# transcripts dir or jq is missing — no input is not a clean result). The gate
# is tests/validator-corpus.bats, which pins the blocks to a reviewed set.
# macOS bash 3.2 compatible.
# =============================================================================

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-report}"

# --- transcripts ----------------------------------------------------------------

if [ "$MODE" = "--transcripts" ]; then
    MODE="${2:-report}"
    TDIR="${CLAUDE_TRANSCRIPTS_DIR:-$HOME/.claude/projects}"
    if [ ! -d "$TDIR" ]; then
        echo "validator-corpus: no transcripts dir: $TDIR" >&2
        exit 2
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "validator-corpus: --transcripts needs jq" >&2
        exit 2
    fi
    # Separators and their escapes as variables: `$'\n'` inside `${v//…}` and a
    # backslash in the replacement differ between bash 3.2 and 5.2.
    TAB=$'\t'; NL=$'\n'; ESC_TAB='\t'; ESC_NL='\n'
    JOBS="${CORPUS_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
    # A count that starts no worker would judge nothing and still print
    # "0 blocked" — the one output this tool must never fake.
    case "$JOBS" in
        ''|*[!0-9]*|0*)
            echo "validator-corpus: CORPUS_JOBS must be a positive integer, got '$JOBS'" >&2
            exit 2 ;;
    esac
    # ABSOLUTE paths: every project dir starts with "-", and a relative glob
    # hands it to jq as an option.
    set -- "$TDIR"/*/*.jsonl
    if [ ! -e "$1" ]; then
        echo "validator-corpus: no transcript (*/*.jsonl) under $TDIR" >&2
        exit 2
    fi
    WORK=$(mktemp -d)
    trap 'rm -rf "$WORK"' EXIT

    # One NUL-terminated "project<TAB>command" record per Bash call. Line by line
    # with fromjson?, so one truncated line does not end the stream. A NUL inside
    # a command is dropped, as the hook's $(…) drops it — kept, it would split
    # the record in two.
    if ! jq -Rj 'fromjson? | select(.type == "assistant")
            | .message.content[]? | select(type == "object")
            | select(.type == "tool_use" and .name == "Bash")
            | .input.command? | select(type == "string" and . != "")
            | gsub("\u0000"; "") as $c
            | (input_filename | split("/") | .[-2]) + "\t" + $c + "\u0000"' \
        "$@" > "$WORK/corpus"; then
        echo "validator-corpus: jq failed reading $TDIR" >&2
        exit 2
    fi
    total=$(tr -cd '\0' < "$WORK/corpus" | wc -c | tr -d ' ')
    # Transcripts but no Bash command: most likely a format change that blinds
    # the extractor, not a clean history.
    if [ "$total" -eq 0 ]; then
        echo "validator-corpus: no Bash command found in $# transcript(s) under $TDIR" >&2
        exit 2
    fi

    # Worker k judges records k, k+JOBS, … — each sources the policy once.
    pids=""
    k=0
    while [ "$k" -lt "$JOBS" ]; do
        (
            # shellcheck source=hooks/_policy-dangerous-commands.sh
            . "$REPO_ROOT/scripts/hooks/_policy-dangerous-commands.sh"
            i=0
            while IFS= read -r -d '' rec; do
                if [ $((i % JOBS)) -eq "$k" ]; then
                    src=${rec%%"$TAB"*}
                    cmd=${rec#*"$TAB"}
                    if ! out=$(validate_command "$cmd" 2>&1); then
                        reason=$(printf '%s' "$out" | head -1 | sed 's/^BLOCKED: //')
                        cmd=${cmd//"$TAB"/$ESC_TAB}
                        printf '%s\t%s\t%s\n' "$reason" "$src" "${cmd//"$NL"/$ESC_NL}"
                    fi
                fi
                i=$((i + 1))
            done < "$WORK/corpus" > "$WORK/out.$k"
        ) &
        pids="$pids $!"
        k=$((k + 1))
    done
    # A bare `wait` returns 0 whatever the workers did.
    for pid in $pids; do
        if ! wait "$pid"; then
            echo "validator-corpus: a worker failed; the result would be partial" >&2
            exit 2
        fi
    done
    cat "$WORK"/out.* | LC_ALL=C sort > "$WORK/blocks"

    if [ "$MODE" = "--summary" ]; then
        printf 'transcripts: %d commands, %d blocked\n' \
            "$total" "$(grep -c . "$WORK/blocks" || true)"
        cut -f1 "$WORK/blocks" | sort | uniq -c | sort -rn
    else
        cat "$WORK/blocks"
    fi
    exit 0
fi

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
        # TRACKED files only. `find` walks the disk and so descends into
        # gitignored paths — a worktree under .claude/worktrees/ (the location
        # this foundation documents), a .claude/commands.backup.<ts>/ left by
        # update.sh, node_modules — and re-reads a second copy of this repo,
        # reporting its docs as if they were ours. Ignored means "not repo
        # content". Pinned by tests/validator-corpus.bats.
        done < <(git -C "$REPO_ROOT" ls-files -- "$d" 2>/dev/null \
                 | grep -E '\.md$' \
                 | sed "s|^|$REPO_ROOT/|" || true)
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
