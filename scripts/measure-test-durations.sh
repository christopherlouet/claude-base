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
# Usage: scripts/measure-test-durations.sh [--jobs N] [--from-report FILE] [--out FILE]
#   --jobs N            bats parallelism for the timed run (default: 8)
#   --from-report FILE  parse an existing bats JUnit report instead of running
#                       the suite (e.g. one downloaded from a CI run)
#   --out FILE          where to write the table (default: scripts/test-durations.tsv)
# =============================================================================
set -euo pipefail
# mawk follows LC_NUMERIC: under fr_FR it reads "0.7" as 0 and prints "1,2".
export LC_ALL=C

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/scripts/test-durations.tsv"
JOBS=8
REPORT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --jobs) JOBS="${2:?--jobs needs a number}"; shift 2 ;;
        --from-report) REPORT="${2:?--from-report needs a file}"; shift 2 ;;
        --out) OUT="${2:?--out needs a file}"; shift 2 ;;
        *) echo "measure-test-durations: unknown option $1" >&2; exit 2 ;;
    esac
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"; rm -f "$OUT.tmp"' EXIT

if [ -z "$REPORT" ]; then
    command -v bats >/dev/null 2>&1 || { echo "measure-test-durations: bats not found" >&2; exit 2; }
    # The suite must pass: a failing or aborted file would be timed short.
    if ! bats --jobs "$JOBS" --report-formatter junit -o "$WORK" "$ROOT"/tests/*.bats > "$WORK/tap.txt" 2>&1; then
        echo "measure-test-durations: the run failed — fix the suite (or install GNU parallel for --jobs) before timing it" >&2
        grep '^not ok' "$WORK/tap.txt" | head -5 >&2 || true
        exit 1
    fi
    REPORT="$WORK/report.xml"
fi
[ -f "$REPORT" ] || { echo "measure-test-durations: no report at $REPORT" >&2; exit 1; }

# <testsuite name="x.bats" ...> then <testcase ... time="1.234" ...>: sum per suite.
# ` name=` (with the space) so `hostname=` cannot match first.
awk '
    /<testsuite / {
        if (match($0, / name="[^"]*"/)) suite = substr($0, RSTART + 7, RLENGTH - 8)
    }
    /<testcase / {
        if (match($0, / time="[^"]*"/)) t[suite] += substr($0, RSTART + 7, RLENGTH - 8)
    }
    END { for (s in t) printf "%s\t%.1f\n", s, t[s] }
' "$REPORT" | sort -t "$(printf '\t')" -k2,2rn -k1,1 > "$OUT.tmp"

# Every value must be a plain dot decimal: a locale-mangled "1,2" would be read
# as 1 by the shard weighting and pass a line count unnoticed.
if grep -qvE "^[^$(printf '\t')]+$(printf '\t')[0-9]+\.[0-9]\$" "$OUT.tmp" || [ ! -s "$OUT.tmp" ]; then
    echo "measure-test-durations: malformed table, not written" >&2
    head -3 "$OUT.tmp" >&2 || true
    exit 1
fi

n=$(wc -l < "$OUT.tmp" | tr -d ' ')
if [ "$REPORT" = "$WORK/report.xml" ]; then
    expected=$(find "$ROOT/tests" -maxdepth 1 -name '*.bats' | wc -l | tr -d ' ')
    if [ "$n" -ne "$expected" ]; then
        echo "measure-test-durations: timed $n files, expected $expected — report not parsed?" >&2
        exit 1
    fi
fi
mv "$OUT.tmp" "$OUT"
echo "measure-test-durations: $n files, $(awk -F'\t' '{s += $2} END {printf "%.0f", s}' "$OUT") s total -> $OUT"
