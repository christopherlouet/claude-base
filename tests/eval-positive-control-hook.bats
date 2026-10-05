#!/usr/bin/env bats

# =============================================================================
# Tests for the positive-control hook evaluated by eval/rule-efficacy
# (tasks/blind-probe-hook): it speaks after a query-like Bash command answers
# "nothing", and stays silent on findings, non-queries and the structural
# shapes whose empty answer is not a finding. Advisory: always exits 0.
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../eval/rule-efficacy/tasks/blind-probe-hook/CANDIDATE/.claude/hooks/positive-control.sh"

# fire <command> <output> [background] — prints the advisory, or nothing.
fire() {
    jq -nc --arg c "$1" --arg o "$2" --argjson b "${3:-false}" \
        '{tool_name:"Bash",tool_input:{command:$c,run_in_background:$b},tool_response:{stdout:$o,stderr:""}}' \
        | bash "$HOOK" | jq -r '.hookSpecificOutput.additionalContext // empty'
}

@test "positive-control: speaks on an empty search" {
    [[ "$(fire 'grep -rn "fetch(" src' '')" == *"Positive control"* ]]
}

@test "positive-control: speaks on a bare 0 count" {
    [[ "$(fire 'grep -c foo x.txt' '0')" == *"answered \"0\""* ]]
}

@test "positive-control: speaks on a check that says OK behind npm's banner" {
    out=$'\n> orders-dashboard@ check:deprecated\n> bash scripts/check-deprecated.sh\n\nOK: no remaining call to deprecated helpers.'
    [[ "$(fire 'npm run check:deprecated 2>&1' "$out")" == *"no remaining call"* ]]
}

@test "positive-control: speaks when zsh swallows the search (no matches found)" {
    [[ "$(fire 'grep -rn x --include=*.md docs/' '(eval):1: no matches found: --include=*.md')" == *"Positive control"* ]]
}

@test "positive-control: silent when the search finds something" {
    [ -z "$(fire 'grep -rn foo src' 'src/a.ts:3: foo')" ]
    [ -z "$(fire 'npm run check:deprecated' $'\n> x\n> y\n\nsrc/a.ts:3: legacyFetch(')" ]
}

@test "positive-control: silent on a non-query command" {
    [ -z "$(fire 'mkdir -p a/b' '')" ]
}

@test "positive-control: silent on structural shapes (background, wait loop, heredoc, redirect)" {
    [ -z "$(fire 'grep -rn foo src' '' true)" ]
    [ -z "$(fire 'until gh pr checks 1 | grep -q pass; do sleep 5; done' '')" ]
    [ -z "$(fire "$(printf 'cat >> m.md <<EOF\nx\nEOF\ngrep -c x m.md; echo ok')" 'ok')" ]
    [ -z "$(fire 'bats tests/x.bats > out.txt 2>&1' '')" ]
}

@test "positive-control: SKIP_POSITIVE_CONTROL=1 silences it, and it always exits 0" {
    run bash -c "jq -nc '{tool_name:\"Bash\",tool_input:{command:\"grep -r x .\"},tool_response:{stdout:\"\",stderr:\"\"}}' | SKIP_POSITIVE_CONTROL=1 bash '$HOOK'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run bash -c "printf 'not json' | bash '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "positive-control: binary output does not warn" {
    setup_test_dir
    # A real NUL in the JSON string (\u0000): jq -r emits it raw.
    printf '%s' '{"tool_name":"Bash","tool_input":{"command":"grep -c x f"},"tool_response":{"stdout":"0\u0000","stderr":""}}' > "$TEST_DIR/p.json"
    [ "$(jq -r .tool_response.stdout "$TEST_DIR/p.json" | tr -cd '\000' | wc -c | tr -d ' ')" = 1 ]
    run bash -c "bash '$HOOK' < '$TEST_DIR/p.json' 2>&1 >/dev/null"
    teardown_test_dir
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
