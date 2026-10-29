#!/usr/bin/env bash
# lessons-budget-guard.sh — PreToolUse hook (Edit|Write|MultiEdit).
#
# Refuses a write that takes the personal lessons store (~/.claude/rules/
# lessons.md, loaded into every session of every project) OVER its byte budget
# AND makes it grow. The bound used to be advisory — `prune-check` reported
# OVER and nothing refused the next append, so the store drifted (#504). Now an
# over-budget capture must consolidate first: merge or drop a lesson. A write
# that keeps the size or shrinks it always passes, so a store already over
# budget can be pruned one edit at a time; so does a write that changes nothing
# but (seen N times) markers, the bump the capture rule asks for instead of a
# new line (one marker per line, N of at most four digits).
#
# The resulting size is in BYTES like prune-check: the store's own size is
# `wc -c`, jq only measures the change. Write = .content; Edit = the store with
# old_string replaced (every occurrence under replace_all; an empty old_string
# on an absent or empty store creates it); MultiEdit = its edits in sequence.
# An old_string the store does not contain literally still counts as applied
# once: the Edit tool also matches through quote normalisation, and refusing an
# edit the tool would reject anyway costs nothing.
#
# Budget = $LESSONS_BUDGET (settings.json "env"), else 4000 — resolved by
# _lessons-store.sh, shared with prune-check. A Bash write to the store cannot
# be measured before it runs; bash-write-guard.sh refuses those.
#
# Payload arrives on STDIN as JSON. Block = exit 2 with a stderr reason.
# Fails OPEN (exit 0) without jq, without its helper, without a HOME, on an
# unreadable store, or on an invalid budget. Disable with SKIP_LESSONS_BUDGET_GUARD=1.

set -euo pipefail

[ "${SKIP_LESSONS_BUDGET_GUARD:-0}" = "1" ] && exit 0

_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=scripts/hooks/_lessons-store.sh
{ [ -n "$_dir" ] && [ -f "$_dir/_lessons-store.sh" ] && . "$_dir/_lessons-store.sh"; } || exit 0

command -v jq >/dev/null 2>&1 || exit 0
INPUT=$(cat 2>/dev/null || true)
# Every Edit/Write of every project lands here: skip jq unless the payload can
# name the store.
case "$INPUT" in *lessons.md*) ;; *) exit 0 ;; esac

FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
[ -n "$FILE" ] && is_lessons_store "$FILE" || exit 0

BUDGET=$(lessons_budget) || exit 0
STORE=$(lessons_store_path) || exit 0

CURRENT=/dev/null BEFORE=0
if [ -f "$STORE" ]; then
    [ -r "$STORE" ] || exit 0
    CURRENT=$STORE
    BEFORE=$(wc -c < "$STORE" | tr -d '[:space:]')
fi

# jq prints "<mode> <bytes> <markers-only>": mode "set" gives the new size
# outright (Write), "add" a change to BEFORE (Edit/MultiEdit). The edit state
# is {s: text, d: bytes}, d holding the size of an edit missed literally. The
# first occurrence is replaced by splitting on old_string, so no offset is
# computed (jq's string index changed unit between 1.6 and 1.7).
RESULT=$(printf '%s' "$INPUT" | jq -r --rawfile cur "$CURRENT" '
    def bytes: utf8bytelength;
    # A bump is one " (seen N times)" per line, N of at most four digits;
    # anything else around it (padding, a second marker) is growth.
    def unmarked: gsub(" \\(seen [0-9]{1,4} times\\)"; "");
    def one_per_line: [split("\n")[] | [match("\\(seen [0-9]+ times\\)"; "g")] | length] | all(. <= 1);
    def edit($e):
        ($e.old_string // "") as $o | ($e.new_string // "") as $n
        | if $o == "" then (if .s == "" then .s = $n else . end)
          elif (.s | contains($o)) then
              if ($e.replace_all // false) then .s |= (split($o) | join($n))
              else .s |= (split($o) as $p | $p[0] + $n + ($p[1:] | join($o)))
              end
          else .d += ($n | bytes) - ($o | bytes)
          end;
    .tool_input as $i
    | if $i.content != null then
          "set \($i.content | bytes) \(($i.content | unmarked) == ($cur | unmarked) and ($i.content | one_per_line))"
      else
          (if $i.edits != null then reduce $i.edits[] as $e ({s: $cur, d: 0}; edit($e))
           else {s: $cur, d: 0} | edit($i) end) as $r
          | "add \(($r.s | bytes) - ($cur | bytes) + $r.d) \($r.d == 0 and ($r.s | unmarked) == ($cur | unmarked) and ($r.s | one_per_line))"
      end
' 2>/dev/null) || exit 0
read -r MODE SIZE MARKERS_ONLY <<EOF
$RESULT
EOF
case "$MODE" in
    set) AFTER=$SIZE ;;
    add) AFTER=$((BEFORE + SIZE)) ;;
    *)   exit 0 ;;
esac

[ "$MARKERS_ONLY" = true ] && exit 0
if [ "$AFTER" -gt "$BUDGET" ] && [ "$AFTER" -gt "$BEFORE" ]; then
    echo >&2 "BLOCKED: this write takes the lessons store to $AFTER/$BUDGET bytes (now $BEFORE) - consolidate first: merge or drop a lesson (/lessons --prune); a bump of an existing (seen N times) marker always passes. (Bypass: SKIP_LESSONS_BUDGET_GUARD=1.)"
    exit 2
fi

exit 0
