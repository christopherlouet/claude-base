#!/usr/bin/env bash
# =============================================================================
# score-regression.sh — run a solution's full test suite + the hidden acceptance
# oracle, and report PASS/FAIL. PASS iff every existing test AND every acceptance
# test is green (feature works, integer-cents invariant held, no regression).
#
# Usage: score-regression.sh <solution-dir> <case-dir>
#   <solution-dir> : a dir containing the (agent-modified) seed project
#   <case-dir>     : the case dir holding oracle/acceptance.test.js (default: the
#                    regression-cents case next to this script)
# Exit 0 = PASS, 1 = FAIL, 2 = usage.
# =============================================================================
set -u

sol="${1:-}"
self_dir=$(cd "$(dirname "$0")" && pwd)
case_dir="${2:-$self_dir/cases/regression-cents}"

if [ -z "$sol" ] || [ ! -d "$sol" ]; then
    echo "usage: score-regression.sh <solution-dir> [case-dir]" >&2
    exit 2
fi
if ! command -v node >/dev/null 2>&1; then
    echo "score-regression: node not found" >&2
    exit 2
fi
oracle="$case_dir/oracle/acceptance.test.js"
[ -f "$oracle" ] || { echo "score-regression: oracle not found at $oracle" >&2; exit 2; }
[ -f "$sol/run-tests.js" ] || { echo "score-regression: $sol has no run-tests.js" >&2; exit 1; }
mkdir -p "$sol/tests"

cp "$oracle" "$sol/tests/_acceptance.test.js"
( cd "$sol" && node run-tests.js )
rc=$?
rm -f "$sol/tests/_acceptance.test.js"

if [ "$rc" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL"; fi
exit "$rc"
