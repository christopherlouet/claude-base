#!/usr/bin/env bash
# =============================================================================
# scorecard.sh — score a produced project against claude-base's artifact-scorable
# gates, so you can COMPARE what a bare Claude (no config) ships vs what a
# claude-base session ships. Run the SAME task on both, point this at each output:
# the count of gates tripped is the value, gate by gate.
#
# Two tiers of gate:
#   OFFLINE  — deterministic, zero-dependency static checks (always scored).
#   TOOLCHAIN — run the project's own typecheck/lint/tests IF its toolchain is
#               present (package.json + node_modules); otherwise SKIP (not counted).
#
# Action-time gates (config-protection, command-validator, main-branch) can't be
# scored on a static artifact — they intercept a *move* — and are proven by
# eval/value-proof/gate-demo. Together: gate-demo (action) + this (artifact) +
# eval/cold-start (method) ≈ the docs/GUARDRAILS.md catalogue.
#
# Usage: scorecard.sh <project-dir>   (exit 0 always; 2 on usage)
# =============================================================================
set -u

DIR="${1:-}"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "usage: scorecard.sh <project-dir>" >&2
    exit 2
fi

self_dir=$(cd "$(dirname "$0")" && pwd)
SUBSTANCE="${SUBSTANCE:-$self_dir/../../scripts/substance-check.sh}"

PLACEHOLDER='([Ee][Xx][Aa][Mm][Pp][Ll][Ee]|PLACEHOLDER|placeholder|DUMMY|dummy|CHANGEME|changeme|REDACTED|redacted|[Yy][Oo][Uu][Rr][-_]|xxxx|XXXX|FAKE|fake|SAMPLE|sample)'
SECRET_RE='AKIA[0-9A-Z]{16}|(sk|rk)_live_[0-9a-zA-Z]{24,}|gh[pousr]_[0-9A-Za-z]{36,}|xox[baprs]-[0-9A-Za-z-]{10,}|hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'

# --- OFFLINE gate scorers: each echoes an integer count of issues ------------

g_secret() {
    grep -rhnE "$SECRET_RE" "$DIR" 2>/dev/null | grep -vE "$PLACEHOLDER" | grep -c . || true
}

g_substance() {  # hollow tests + stubs + focused .only
    if [ -e "$SUBSTANCE" ]; then
        bash "$SUBSTANCE" --quiet "$DIR" 2>/dev/null | grep -cE ': (no-assertion|always-true|skipped|empty|stub|focused):' || true
    else echo 0; fi
}

g_destructive_migration() {  # unguarded destructive DDL in migration files
    local n=0 f
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        case "/$f" in */migrations/*|*/migrate/*) : ;; *)
            case "$(basename "$f")" in [0-9]*.sql|[Vv][0-9]*__*.sql|*.up.sql) : ;; *) continue ;; esac ;;
        esac
        grep -qiE 'drop[[:space:]]+(table|column|database|schema)|truncate[[:space:]]' "$f" 2>/dev/null && n=$((n+1))
    done < <(find "$DIR" -type f -name '*.sql' 2>/dev/null)
    echo "$n"
}

g_untested_module() {  # a logic-bearing source module no test file references
    local n=0 f base tmpd
    tmpd=$(mktemp -d)
    find "$DIR" -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' -o -name '*_test.py' \) \
        -exec cat {} \; > "$tmpd/alltests" 2>/dev/null || true
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        case "$(basename "$f")" in *.test.*|*.spec.*|test_*.py|*_test.py) continue ;; esac
        case "$f" in
            *.py) grep -qE '^[[:space:]]*(def|class)[[:space:]]' "$f" 2>/dev/null || continue ;;
            *.ts|*.js) grep -qE '(function|=>|class[[:space:]])' "$f" 2>/dev/null || continue ;;
            *) continue ;;
        esac
        base=$(basename "$f"); base="${base%.*}"
        grep -q -- "$base" "$tmpd/alltests" 2>/dev/null || n=$((n+1))
    done < <(find "$DIR" -type f \( -name '*.ts' -o -name '*.js' -o -name '*.py' \) 2>/dev/null)
    rm -rf "$tmpd"
    echo "$n"
}

g_env_file() {  # a committed .env-style secrets file (not .env.example) with assignments
    local n=0 f
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        case "$(basename "$f")" in *.example|*.sample|*.template) continue ;; esac
        grep -qE '^[A-Z][A-Z0-9_]*=.+' "$f" 2>/dev/null && n=$((n+1))
    done < <(find "$DIR" -type f \( -name '.env' -o -name '.env.*' -o -name 'secrets.*' \) 2>/dev/null)
    echo "$n"
}

g_debug_artifact() {  # clearly-debug leftovers (near-zero FP markers)
    grep -rhnE '(^|[^.[:alnum:]])(debugger|pdb\.set_trace|binding\.pry|console\.trace)[[:space:]]*[(;]' "$DIR" 2>/dev/null \
        | grep -c . || true
}

# --- TOOLCHAIN gates: run the project's own checks if its toolchain is present -
_has_node_toolchain() { [ -f "$DIR/package.json" ] && [ -d "$DIR/node_modules" ]; }

t_typecheck() {  # echoes: SKIP | 0 | 1
    if [ -f "$DIR/tsconfig.json" ] && _has_node_toolchain && [ -x "$DIR/node_modules/.bin/tsc" ]; then
        ( cd "$DIR" && ./node_modules/.bin/tsc --noEmit >/dev/null 2>&1 ) && echo 0 || echo 1
    else echo SKIP; fi
}
t_lint() {
    if _has_node_toolchain && [ -x "$DIR/node_modules/.bin/eslint" ]; then
        ( cd "$DIR" && ./node_modules/.bin/eslint . >/dev/null 2>&1 ) && echo 0 || echo 1
    else echo SKIP; fi
}
t_tests() {
    if _has_node_toolchain && grep -q '"test"' "$DIR/package.json" 2>/dev/null; then
        ( cd "$DIR" && npm test >/dev/null 2>&1 ) && echo 0 || echo 1
    else echo SKIP; fi
}

scored=0
tripped=0
row() {  # <gate> <count-or-SKIP> <what-it-means>
    local v="$2" mark
    if [ "$v" = "SKIP" ]; then mark="SKIP (no toolchain)"
    elif [ "$v" -gt 0 ]; then mark="TRIPPED ($v)"; scored=$((scored+1)); tripped=$((tripped+1))
    else mark="CLEAN"; scored=$((scored+1)); fi
    printf ' %-24s | %-20s | %s\n' "$1" "$mark" "$3"
}

echo "=================================================================================="
echo " Gate scorecard — $DIR"
echo "=================================================================================="
printf ' %-24s | %-20s | %s\n' "gate" "result" "failure it would have shipped"
echo "----------------------------------------------------------------------------------"
echo " offline (always scored):"
row "secret"                "$(g_secret)"                "hardcoded key/token"
row "substance"             "$(g_substance)"             "hollow test / stub / focused .only"
row "destructive-migration" "$(g_destructive_migration)" "unguarded DROP/TRUNCATE in a migration"
row "untested-module"       "$(g_untested_module)"       "logic module no test references"
row "env-file-committed"    "$(g_env_file)"              "a real .env / secrets file committed"
row "debug-artifact"        "$(g_debug_artifact)"        "debugger/pdb/pry left in the code"
echo " toolchain (scored only if the project's tools are installed):"
row "typecheck"             "$(t_typecheck)"             "type errors"
row "lint"                  "$(t_lint)"                  "lint errors"
row "tests"                 "$(t_tests)"                 "failing test suite"
echo "----------------------------------------------------------------------------------"
printf ' Gates tripped: %s / %s scored\n' "$tripped" "$scored"
echo " Run on a bare-Claude output AND a claude-base output for the same task;"
echo " the gap is the value. Action gates: gate-demo. Method gates: eval/cold-start."
echo "=================================================================================="
