#!/usr/bin/env bash
# =============================================================================
# measure-test-durations.sh — regenerate scripts/test-durations.tsv
# =============================================================================
# Runs the whole bats suite once with the JUnit reporter and writes, per test
# file, the summed time of its tests. scripts/test.sh --shard weights files by
# this table: line count (the previous weight) predicted runtime badly —
# measured 2026-10-04, line-balanced shards took 194/862/395/378 s, the slowest
# one setting every CI run's wall time.
#
# A stale table degrades gracefully: a file missing from it is weighted by its
# line count scaled to the table's seconds-per-line, never dropped. Rerun this
# when the suite's shape changes (a new heavy file, a slow test made fast).
#
# Usage: scripts/measure-test-durations.sh [--jobs N]   (default: 8)
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/scripts/test-durations.tsv"
JOBS=8
if [ "${1:-}" = "--jobs" ]; then
    JOBS="${2:?--jobs needs a number}"
fi

command -v bats >/dev/null 2>&1 || { echo "measure-test-durations: bats not found" >&2; exit 2; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The suite must pass: a failing or aborted file would be timed short.
if ! bats --jobs "$JOBS" --report-formatter junit -o "$WORK" "$ROOT"/tests/*.bats > "$WORK/tap.txt" 2>&1; then
    echo "measure-test-durations: the suite failed — fix it before timing it" >&2
    grep '^not ok' "$WORK/tap.txt" | head -5 >&2 || true
    exit 1
fi

# <testsuite name="x.bats" ...> then <testcase ... time="1.234" ...>: sum per suite.
awk '
    /<testsuite / {
        if (match($0, /name="[^"]*"/)) suite = substr($0, RSTART + 6, RLENGTH - 7)
    }
    /<testcase / {
        if (match($0, /time="[^"]*"/)) t[suite] += substr($0, RSTART + 6, RLENGTH - 7)
    }
    END { for (s in t) printf "%s\t%.1f\n", s, t[s] }
' "$WORK/report.xml" | sort -t "$(printf '\t')" -k2,2rn -k1,1 > "$OUT.tmp"

n=$(wc -l < "$OUT.tmp" | tr -d ' ')
expected=$(find "$ROOT/tests" -maxdepth 1 -name '*.bats' | wc -l | tr -d ' ')
if [ "$n" -ne "$expected" ]; then
    echo "measure-test-durations: timed $n files, expected $expected — report not parsed?" >&2
    rm -f "$OUT.tmp"
    exit 1
fi
mv "$OUT.tmp" "$OUT"
echo "measure-test-durations: $n files, $(awk -F'\t' '{s += $2} END {printf "%.0f", s}' "$OUT") s total -> ${OUT#"$ROOT"/}"
