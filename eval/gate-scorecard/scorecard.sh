#!/usr/bin/env bash
# =============================================================================
# scorecard.sh — score a produced project against claude-base's artifact-scorable
# gates, so you can COMPARE what a bare Claude (no config) ships vs what a
# claude-base session ships. Run the SAME task on both, point this at each output:
# the count of gates tripped is the value, gate by gate.
#
# Only the gates that can judge a static ARTIFACT are scored here (a bare project
# produced offline has no "action" to intercept). Action-time gates
# (config-protection, command-validator, main-branch) are proven separately by
# eval/value-proof/gate-demo. Deterministic, offline, dependency-light.
#
# Usage: scorecard.sh <project-dir>
#   prints a per-gate scorecard and the number of gates tripped; exit 0 always
#   (it's a measurement, not a gate), 2 on usage.
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

# --- gate scorers: each echoes an integer count of issues -------------------

g_secret() {
    grep -rhnE "$SECRET_RE" "$DIR" 2>/dev/null | grep -vE "$PLACEHOLDER" | grep -c . || true
}

g_substance() {  # hollow tests + stubs + focused .only
    if [ -x "$SUBSTANCE" ] || [ -f "$SUBSTANCE" ]; then
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
        if grep -qiE 'drop[[:space:]]+(table|column|database|schema)|truncate[[:space:]]' "$f" 2>/dev/null; then
            n=$((n+1))
        fi
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

tripped=0
row() { # <gate> <count> <what-it-means>
    local mark="CLEAN"
    if [ "$2" -gt 0 ]; then mark="TRIPPED ($2)"; tripped=$((tripped+1)); fi
    printf ' %-26s | %-14s | %s\n' "$1" "$mark" "$3"
}

echo "=================================================================================="
echo " Gate scorecard — $DIR"
echo "=================================================================================="
printf ' %-26s | %-14s | %s\n' "gate" "result" "failure it would have shipped"
echo "----------------------------------------------------------------------------------"
row "secret"               "$(g_secret)"                "hardcoded key/token"
row "substance"            "$(g_substance)"             "hollow test / stub / focused .only"
row "destructive-migration" "$(g_destructive_migration)" "unguarded DROP/TRUNCATE in a migration"
row "untested-module"      "$(g_untested_module)"       "logic module no test references"
echo "----------------------------------------------------------------------------------"
printf ' Gates tripped: %s / 4\n' "$tripped"
echo " Run on a bare-Claude output AND a claude-base output for the same task:"
echo " the gap is the value, gate by gate (action-time gates: see gate-demo)."
echo "=================================================================================="
