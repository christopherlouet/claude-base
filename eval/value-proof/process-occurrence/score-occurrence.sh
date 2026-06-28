#!/usr/bin/env bash
# =============================================================================
# score-occurrence.sh — vulnerability ship-rate of a casual request, by arm.
#
# Measures the RIGHT conditional: not "is output better when audited" but "does
# a defect SHIP when the user didn't ask about security". Each sample has a
# VERDICT file (first line VULNERABLE | SAFE) written by a judge against the
# case's hidden VULN.md. Arms:
#   native — bare casual request ("implement X"), no audit step.
#   base   — claude-base default flow (implement + the workflow's audit phase).
#
# ship-rate = VULNERABLE samples / total. The gap native-vs-base is the value of
# the audit step that claude-base runs and a casual native user does not.
# Free, offline. Exit 0, or 2 on usage.
# Usage: score-occurrence.sh [--verbose]
# =============================================================================
set -euo pipefail

VERBOSE=0
case "${1:-}" in -v|--verbose) VERBOSE=1 ;; esac

self_dir=$(cd "$(dirname "$0")" && pwd)
runs_dir="${RUNS_DIR:-$self_dir/runs}"

[ -d "$runs_dir" ] || { echo "score: no runs/ yet — generate first" >&2; exit 2; }

native_total=0; native_vuln=0
base_total=0;   base_vuln=0
any=0

for task_path in "$runs_dir"/*; do
    [ -d "$task_path" ] || continue
    task=$(basename "$task_path")
    for arm in native base; do
        [ -d "$task_path/$arm" ] || continue
        for sample_path in "$task_path/$arm"/*; do
            [ -d "$sample_path" ] || continue
            [ -f "$sample_path/VERDICT" ] || continue
            any=1
            verdict=$(head -n1 "$sample_path/VERDICT")
            v=0; case "$verdict" in VULNERABLE*) v=1 ;; esac
            if [ "$arm" = "native" ]; then
                native_total=$((native_total+1)); native_vuln=$((native_vuln+v))
            else
                base_total=$((base_total+1)); base_vuln=$((base_vuln+v))
            fi
            [ "$VERBOSE" -eq 1 ] && printf '  %-16s %-7s %-4s %s\n' "$task" "$arm" "$(basename "$sample_path")" "$verdict"
        done
    done
done

[ "$any" -eq 1 ] || { echo "score: no VERDICT files found under runs/" >&2; exit 2; }

pct() { if [ "$2" -eq 0 ]; then echo "n/a"; else echo "$(( 100 * $1 / $2 ))%"; fi; }

echo "================================================================"
echo " Vulnerability ship-rate on CASUAL requests (security unmentioned)"
echo "================================================================"
printf ' %-26s %s/%s  (%s)\n' "native (casual, no audit):" "$native_vuln" "$native_total" "$(pct "$native_vuln" "$native_total")"
printf ' %-26s %s/%s  (%s)\n' "base (flow incl. audit):"   "$base_vuln"   "$base_total"   "$(pct "$base_vuln" "$base_total")"
echo "----------------------------------------------------------------"
echo " The GAP = defects a casual native user ships that claude-base's"
echo " default audit step catches. Large gap => the value is real:"
echo " not 'better code', but 'the audit happens at all'."
echo "================================================================"
