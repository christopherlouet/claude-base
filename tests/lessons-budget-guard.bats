#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/lessons-budget-guard.sh (PreToolUse on Edit|Write|
# MultiEdit). Refuses (exit 2) a write that takes the personal lessons store
# (~/.claude/rules/lessons.md) OVER its byte budget AND makes it grow — so the
# bound refuses at write time instead of being an advisory prune-check, while a
# store already over budget can still be shrunk one edit at a time (#504).
# Budget = $LESSONS_BUDGET, else 4000 — the same resolution as prune-check.
# =============================================================================

load 'test_helper'

HOOK="$BASE_DIR/scripts/hooks/lessons-budget-guard.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    export HOME="$TEST_DIR/home"
    STORE="$HOME/.claude/rules/lessons.md"
    mkdir -p "$HOME/.claude/rules"
    unset LESSONS_BUDGET SKIP_LESSONS_BUDGET_GUARD
}
teardown() { teardown_test_dir; }

# _store <bytes> — a store of exactly <bytes> bytes (one long lesson line).
_store() {
    printf -- '- %s\n' "$(head -c "$(( $1 - 3 ))" /dev/zero | tr '\0' 'a')" > "$STORE"
    [ "$(wc -c < "$STORE" | tr -d ' ')" -eq "$1" ]
}

# _run <json-tool_input> [tool_name]
_run() {
    jq -n --argjson i "$1" --arg t "${2:-Edit}" '{tool_name:$t, tool_input:$i}' > "$TEST_DIR/in.json"
    run bash -c "bash '$HOOK' < '$TEST_DIR/in.json' 2>&1"
}

_write()  { _run "$(jq -n --arg f "$1" --arg c "$2" '{file_path:$f, content:$c}')" Write; }
_edit()   { _run "$(jq -n --arg f "$1" --arg o "$2" --arg n "$3" --argjson a "${4:-false}" \
                '{file_path:$f, old_string:$o, new_string:$n, replace_all:$a}')" Edit; }

# --- Write ------------------------------------------------------------------

@test "lessons-budget-guard: blocks a Write that creates an over-budget store" {
    rm -f "$STORE"
    export LESSONS_BUDGET=10
    _write "$STORE" "- a lesson longer than ten bytes"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
    [[ "$output" == *"/10"* ]]
}

@test "lessons-budget-guard: allows a Write that stays within budget" {
    export LESSONS_BUDGET=100
    _write "$STORE" "- short lesson"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: counts BYTES, like prune-check (multibyte content)" {
    rm -f "$STORE"
    export LESSONS_BUDGET=10
    # 6 characters, 12 bytes.
    _write "$STORE" "éééééé"
    [ "$status" -eq 2 ]
}

@test "lessons-budget-guard: a Write that shrinks an over-budget store is allowed" {
    _store 200
    export LESSONS_BUDGET=100
    _write "$STORE" "$(head -c 150 /dev/zero | tr '\0' 'b')"
    [ "$status" -eq 0 ]
}

# --- Edit -------------------------------------------------------------------

@test "lessons-budget-guard: blocks an Edit that grows the store past the budget" {
    _store 95
    export LESSONS_BUDGET=100
    _edit "$STORE" "- a" "- a much longer opening"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "lessons-budget-guard: allows an Edit that grows the store within budget" {
    _store 50
    export LESSONS_BUDGET=100
    _edit "$STORE" "- a" "- a bit more"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: an Edit that shrinks an over-budget store is allowed" {
    _store 200
    export LESSONS_BUDGET=100
    _edit "$STORE" "- aaaaaaaaaa" "- "
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: a same-size Edit of an over-budget store is allowed" {
    _store 200
    export LESSONS_BUDGET=100
    _edit "$STORE" "- a" "- b"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: replace_all is measured on EVERY occurrence" {
    printf -- '- x\n- x\n- x\n' > "$STORE"   # 12 bytes
    export LESSONS_BUDGET=20
    # One replacement: 12 + 4 = 16, fits.
    _edit "$STORE" "x" "xxxxx" false
    [ "$status" -eq 0 ]
    # Every replacement: 12 + 3*4 = 24, over.
    _edit "$STORE" "x" "xxxxx" true
    [ "$status" -eq 2 ]
}

@test "lessons-budget-guard: an old_string not found literally counts as applied once" {
    # The Edit tool also matches after quote normalisation (curly vs straight),
    # so a literal miss is not proof the edit will not apply.
    printf -- '- it\xe2\x80\x99s a lesson\n' > "$STORE"
    export LESSONS_BUDGET=30
    _edit "$STORE" "it's" "it's a much longer lesson now"
    [ "$status" -eq 2 ]
    # Shrinking through the same miss still passes.
    _edit "$STORE" "it's a lesson" "it"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: an Edit with an empty old_string that creates the store is measured" {
    rm -f "$STORE"
    export LESSONS_BUDGET=10
    _edit "$STORE" "" "- a lesson longer than ten bytes"
    [ "$status" -eq 2 ]
}

@test "lessons-budget-guard: a recurrence bump always passes, even over budget" {
    printf -- '- a lesson (seen 9 times)\n- other\n' > "$STORE"
    export LESSONS_BUDGET=10
    _edit "$STORE" "(seen 9 times)" "(seen 10 times)"
    [ "$status" -eq 0 ]
    _edit "$STORE" "- other" "- other (seen 2 times)"
    [ "$status" -eq 0 ]
    # Control: a bump that smuggles in new text is still measured.
    _edit "$STORE" "- other" "- other, plus a new clause (seen 2 times)"
    [ "$status" -eq 2 ]
}

@test "lessons-budget-guard: sizes the store with wc -c, like prune-check (invalid UTF-8)" {
    # 0xFF is one byte on disk; jq would read it as U+FFFD (three).
    printf -- '- \xff\xff\xff\xff\n' > "$STORE"   # 7 bytes
    export LESSONS_BUDGET=9
    _edit "$STORE" "- " "- ab"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: an unset HOME fails open, never exits outside 0/2" {
    _run "$(jq -n '{file_path:"/x/.claude/rules/lessons.md", content:"x"}')" Write
    run bash -c "env -u HOME bash '$HOOK' < '$TEST_DIR/in.json'"
    [ "$status" -eq 0 ]
}

# --- MultiEdit --------------------------------------------------------------

@test "lessons-budget-guard: MultiEdit edits are applied in sequence" {
    printf -- '- one\n' > "$STORE"   # 6 bytes
    export LESSONS_BUDGET=12
    # one -> two (6), then two -> twotwotwo (12): fits.
    _run "$(jq -n --arg f "$STORE" '{file_path:$f, edits:[{old_string:"one",new_string:"two"},{old_string:"two",new_string:"twotwotwo"}]}')" MultiEdit
    [ "$status" -eq 0 ]
    # The second edit only matches because the first ran: 6 -> 6 -> 15, over.
    _run "$(jq -n --arg f "$STORE" '{file_path:$f, edits:[{old_string:"one",new_string:"two"},{old_string:"two",new_string:"twotwotwotwo"}]}')" MultiEdit
    [ "$status" -eq 2 ]
}

# --- Scope ------------------------------------------------------------------

@test "lessons-budget-guard: ignores any file other than the store" {
    export LESSONS_BUDGET=10
    _write "$TEST_DIR/notes.md" "$(head -c 500 /dev/zero | tr '\0' 'd')"
    [ "$status" -eq 0 ]
    # A path-scoped lessons file is not the always-loaded store.
    _write "$HOME/.claude/rules/lessons-shell.md" "$(head -c 500 /dev/zero | tr '\0' 'd')"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: recognises the store through a symlinked path" {
    _store 95
    export LESSONS_BUDGET=100
    ln -s "$HOME/.claude" "$TEST_DIR/link"
    _edit "$TEST_DIR/link/rules/lessons.md" "- a" "- a much longer opening"
    [ "$status" -eq 2 ]
}

@test "lessons-budget-guard: an unreadable store fails open, never exits outside 0/2" {
    [ "$(id -u)" -ne 0 ] || skip "root reads a mode-000 file"
    _store 95
    chmod 000 "$STORE"
    export LESSONS_BUDGET=100
    _write "$STORE" "$(head -c 500 /dev/zero | tr '\0' 'e')"
    chmod 600 "$STORE"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: recognises a non-normalised path before the store exists" {
    rm -f "$STORE"
    export LESSONS_BUDGET=10
    for f in "$HOME/.claude//rules/lessons.md" "$HOME/.claude/./rules/lessons.md" \
             "$HOME/.claude/rules/../rules/lessons.md"; do
        _write "$f" "- a lesson longer than ten bytes"
        [ "$status" -eq 2 ] || { echo "not blocked: $f" >&2; return 1; }
    done
}

@test "lessons-budget-guard: extra markers or padding are growth, not a bump" {
    printf -- '- a lesson (seen 9 times)\n' > "$STORE"
    export LESSONS_BUDGET=10
    # A second marker on the same line.
    _edit "$STORE" "(seen 9 times)" "(seen 9 times) (seen 1 times)"
    [ "$status" -eq 2 ]
    # Padding before the marker.
    _edit "$STORE" " (seen 9 times)" "          (seen 9 times)"
    [ "$status" -eq 2 ]
    # A runaway count.
    _edit "$STORE" "(seen 9 times)" "(seen 99999999 times)"
    [ "$status" -eq 2 ]
}

# --- Budget resolution and bypass -------------------------------------------

@test "lessons-budget-guard: defaults to 4000 bytes without LESSONS_BUDGET" {
    _store 3990
    _edit "$STORE" "- a" "- a longer opening"
    [ "$status" -eq 2 ]
    [[ "$output" == *"/4000"* ]]
}

@test "lessons-budget-guard: an invalid LESSONS_BUDGET fails open" {
    _store 95
    export LESSONS_BUDGET=lots
    _edit "$STORE" "- a" "- a much longer opening"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: SKIP_LESSONS_BUDGET_GUARD=1 disables it" {
    _store 95
    export LESSONS_BUDGET=100 SKIP_LESSONS_BUDGET_GUARD=1
    _edit "$STORE" "- a" "- a much longer opening"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: the message names the way out" {
    _store 95
    export LESSONS_BUDGET=100
    _edit "$STORE" "- a" "- a much longer opening"
    [ "$status" -eq 2 ]
    [[ "$output" == *"/lessons --prune"* ]]
    [[ "$output" == *"SKIP_LESSONS_BUDGET_GUARD=1"* ]]
}

# --- Wiring (self-application) ----------------------------------------------

@test "lessons-budget-guard: the real settings.json wires it on Edit|Write|MultiEdit, blocking" {
    run jq -e '.hooks.PreToolUse[] | select(.hooks[].command | test("lessons-budget-guard.sh"))
               | select(.matcher == "Edit|Write|MultiEdit") | select(.hooks[].onFailure == "block")' \
        "$BASE_DIR/.claude/settings.json"
    [ "$status" -eq 0 ]
}

@test "lessons-budget-guard: passes an ordinary edit of a real foundation file" {
    export LESSONS_BUDGET=10
    _edit "$BASE_DIR/README.md" "claude-base" "claude-base and much more text than ten bytes"
    [ "$status" -eq 0 ]
}
