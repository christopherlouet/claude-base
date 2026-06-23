#!/usr/bin/env bats

# =============================================================================
# Tests for eval/minimal-code/eval.sh — the deterministic scorer/comparator of
# the minimal-code-discipline eval. Fully OFFLINE: a fixture "task" whose
# verify.sh is pure shell (no node/python), plus fixture solution dirs. No LLM.
# =============================================================================

load 'test_helper'

EVAL="$BATS_TEST_DIRNAME/../eval/minimal-code/eval.sh"

setup() {
    setup_test_dir
    # A fixture task: "correct" == answer.txt contains a line exactly "42".
    mkdir -p "$TEST_DIR/faketask"
    cat > "$TEST_DIR/faketask/verify.sh" <<'EOF'
#!/usr/bin/env bash
grep -qx 42 "$1/answer.txt" 2>/dev/null
EOF
}

teardown() { teardown_test_dir; }

# mk_solution <dir> <answer-first-line> <withTest:yes|no> [filler-lines]
mk_solution() {
    local dir="$1" answer="$2" withtest="$3" filler="${4:-0}" i
    mkdir -p "$dir"
    {
        printf '%s\n' "$answer"
        for ((i = 0; i < filler; i++)); do printf 'line%s\n' "$i"; done
    } > "$dir/answer.txt"
    [ "$withtest" = "yes" ] && printf '# a test\n' > "$dir/answer.test.sh"
    return 0
}

@test "eval score: reports loc, files, hasTests and correctness=pass" {
    mk_solution "$TEST_DIR/sol" 42 yes 9    # 10 source LOC, 1 source file, has a test, correct
    run "$EVAL" score "$TEST_DIR/sol" "$TEST_DIR/faketask"
    [ "$status" -eq 0 ]
    [ "$(printf '%s' "$output" | jq -r '.loc')" = "10" ]
    [ "$(printf '%s' "$output" | jq -r '.files')" = "1" ]
    [ "$(printf '%s' "$output" | jq -r '.hasTests')" = "true" ]
    [ "$(printf '%s' "$output" | jq -r '.correctness')" = "pass" ]
}

@test "eval score: test files are excluded from source loc/files but flip hasTests" {
    mk_solution "$TEST_DIR/sol" 42 yes 0    # answer.txt (1 line) + answer.test.sh
    run "$EVAL" score "$TEST_DIR/sol" "$TEST_DIR/faketask"
    [ "$(printf '%s' "$output" | jq -r '.loc')" = "1" ]
    [ "$(printf '%s' "$output" | jq -r '.files')" = "1" ]
    [ "$(printf '%s' "$output" | jq -r '.hasTests')" = "true" ]
}

@test "eval score: correctness=fail when the task's verify rejects the solution" {
    mk_solution "$TEST_DIR/sol" 0 no 0      # wrong answer
    run "$EVAL" score "$TEST_DIR/sol" "$TEST_DIR/faketask"
    [ "$(printf '%s' "$output" | jq -r '.correctness')" = "fail" ]
}

@test "eval compare: leaner + correct + tests kept → LEANER_AND_CORRECT (the win)" {
    mk_solution "$TEST_DIR/control"   42 yes 9   # 10 LOC, correct, tested
    mk_solution "$TEST_DIR/treatment" 42 yes 0   # 1 LOC,  correct, tested
    run "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/faketask"
    [ "$status" -eq 0 ]
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "LEANER_AND_CORRECT" ]
    [ "$(printf '%s' "$output" | jq -r '.deltaLocPct')" -lt 0 ]
}

@test "eval compare: leaner but BROKEN → TREATMENT_BROKEN (the feared regression)" {
    mk_solution "$TEST_DIR/control"   42 yes 9   # correct
    mk_solution "$TEST_DIR/treatment" 0  yes 0   # fewer lines but wrong
    run "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/faketask"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "TREATMENT_BROKEN" ]
}

@test "eval compare: leaner but tests dropped → TREATMENT_DROPPED_TESTS (the feared regression)" {
    mk_solution "$TEST_DIR/control"   42 yes 9   # correct + tested
    mk_solution "$TEST_DIR/treatment" 42 no  0   # correct, leaner, but NO test
    run "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/faketask"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "TREATMENT_DROPPED_TESTS" ]
}

@test "eval compare: a broken baseline is flagged inconclusive, not a win" {
    mk_solution "$TEST_DIR/control"   0  yes 9   # baseline itself fails
    mk_solution "$TEST_DIR/treatment" 42 yes 0   # treatment correct
    run "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/faketask"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "CONTROL_BROKEN" ]
}

@test "eval: bad usage exits non-zero" {
    run "$EVAL" score "$TEST_DIR/sol"
    [ "$status" -ne 0 ]
    run "$EVAL" bogus
    [ "$status" -ne 0 ]
}
