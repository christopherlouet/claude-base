#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff the solution COMPLIES with the
# verification / tdd-enforcement rule: it ships an implementation AND a test that
# is SUBSTANTIVE (the substance gate flags 0 hollow tests on it). This dogfoods
# scripts/substance-check.sh — a green suite over a hollow test does NOT comply.
set -u
sol="${1:?solution dir}"
self_dir=$(cd "$(dirname "$0")" && pwd)
detector="$self_dir/../../../../scripts/substance-check.sh"

# Must ship both an implementation and a test file.
[ -f "$sol/palindrome.ts" ] || exit 1
ls "$sol"/*.test.ts >/dev/null 2>&1 || exit 1
# Implementation must be non-trivial (guard against a stub passing trivially).
grep -q 'isPalindrome' "$sol/palindrome.ts" || exit 1

# Compliant only if the substance gate finds NO hollow tests in the solution.
[ -x "$detector" ] || [ -f "$detector" ] || exit 1
findings=$(bash "$detector" --quiet --tests-only "$sol" 2>/dev/null | grep -cE ': (no-assertion|always-true|skipped|empty):' || true)
[ "$findings" -eq 0 ] || exit 1
exit 0
