#!/usr/bin/env bash

# =============================================================================
# eval/minimal-code/eval.sh — measure whether the minimal-code/YAGNI discipline
# (the `research` rule, #391/#392) ACTUALLY improves generated code, instead of
# assuming it. Compares a CONTROL solution (rule absent) vs a TREATMENT solution
# (rule present) for the same task, on LOC **and** the metrics that guard against
# the failure mode the discipline could cause: fewer lines that are BROKEN or
# UNTESTED.
#
# This script is the DETERMINISTIC, offline half (scoring + verdict) — it never
# calls an LLM, so it is unit-tested in tests/eval-minimal-code.bats. The
# code-GENERATION half (running an agent control/treatment) spends metered LLM
# credit and is therefore MANUAL/opt-in — see README.md. You hand this script
# already-generated solution directories.
#
#   eval.sh score   <solution-dir> <task-dir>
#       → JSON {task, loc, files, hasTests, correctness:"pass"|"fail"}
#   eval.sh compare <control-dir> <treatment-dir> <task-dir>
#       → JSON {control, treatment, deltaLocPct, verdict}
#
# A task dir holds PROMPT.md (the agent prompt) + verify.sh (exit 0 == the
# solution is correct; receives the solution dir as $1). LOC counts non-blank
# lines of SOURCE files (test/spec files excluded but counted via hasTests).
# =============================================================================

set -euo pipefail

# _is_test_file <path> — heuristic: a test/spec file, not production source.
_is_test_file() {
    case "$(basename "$1")" in
        *test* | *spec*) return 0 ;;   # covers foo.test.js, foo_test.py, test_foo, *.spec.*
        *) return 1 ;;
    esac
}

# _source_files <dir> — list regular, non-hidden, non-test files (newline-sep).
_source_files() {
    local dir="$1" f
    [ -d "$dir" ] || return 0
    while IFS= read -r f; do
        case "$f" in */.*) continue ;; esac          # skip dotfiles
        _is_test_file "$f" && continue
        printf '%s\n' "$f"
    done < <(find "$dir" -type f 2>/dev/null | sort)
}

_loc() {
    local dir="$1" total=0 f n
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        n=$(grep -cvE '^[[:space:]]*$' "$f" 2>/dev/null || true)
        total=$((total + n))
    done < <(_source_files "$dir")
    printf '%s' "$total"
}

_file_count() { _source_files "$1" | grep -c . || true; }

_has_tests() {
    local dir="$1" f
    [ -d "$dir" ] || { printf 'false'; return 0; }
    while IFS= read -r f; do
        case "$f" in */.*) continue ;; esac
        if _is_test_file "$f"; then printf 'true'; return 0; fi
    done < <(find "$dir" -type f 2>/dev/null)
    printf 'false'
}

# _correctness <solution-dir> <task-dir> — run the task's verify.sh; pass|fail.
_correctness() {
    local sol="$1" task="$2"
    [ -x "$task/verify.sh" ] || [ -f "$task/verify.sh" ] || { printf 'fail'; return 0; }
    if bash "$task/verify.sh" "$sol" >/dev/null 2>&1; then printf 'pass'; else printf 'fail'; fi
}

cmd_score() {
    local sol="$1" task="$2" name
    name=$(basename "$task")
    jq -cn \
        --arg task "$name" \
        --argjson loc "$(_loc "$sol")" \
        --argjson files "$(_file_count "$sol")" \
        --argjson hasTests "$(_has_tests "$sol")" \
        --arg correctness "$(_correctness "$sol" "$task")" \
        '{task:$task, loc:$loc, files:$files, hasTests:$hasTests, correctness:$correctness}'
}

cmd_compare() {
    local control="$1" treatment="$2" task="$3" c t
    c=$(cmd_score "$control" "$task")
    t=$(cmd_score "$treatment" "$task")
    jq -cn --argjson c "$c" --argjson t "$t" '
        ($c.loc) as $cl | ($t.loc) as $tl |
        # Verdict — the order matters: the FEARED regressions are checked first,
        # so a leaner-but-worse treatment can never read as a win.
        (if $t.correctness != "pass" then "TREATMENT_BROKEN"            # fewer/other lines but wrong → the fear
         elif $c.correctness != "pass" then "CONTROL_BROKEN"           # baseline failed → inconclusive
         elif ($c.hasTests and ($t.hasTests | not)) then "TREATMENT_DROPPED_TESTS"  # leaner by cutting tests → the fear
         elif $tl < $cl then "LEANER_AND_CORRECT"                      # the win we want
         elif $tl > $cl then "HEAVIER"
         else "SAME_SIZE" end) as $verdict |
        {control:$c, treatment:$t,
         deltaLocPct: (if $cl > 0 then (($tl - $cl) * 100 / $cl | round) else 0 end),
         verdict:$verdict}'
}

usage() {
    cat >&2 <<'EOF'
Usage:
  eval.sh score   <solution-dir> <task-dir>
  eval.sh compare <control-dir> <treatment-dir> <task-dir>
EOF
}

main() {
    local sub="${1:-}"; shift || true
    case "$sub" in
        score)   [ $# -eq 2 ] || { usage; return 2; }; cmd_score "$1" "$2" ;;
        compare) [ $# -eq 3 ] || { usage; return 2; }; cmd_compare "$1" "$2" "$3" ;;
        -h|--help) usage ;;
        *) usage; return 2 ;;
    esac
}

main "$@"
