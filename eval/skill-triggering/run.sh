#!/usr/bin/env bash
# =============================================================================
# run.sh — does each foundation skill trigger on the right prompt, and stay
# quiet on a neighbouring one?
# =============================================================================
# `claude plugin eval` evaluates a plugin, not a .claude/ tree, so this wraps
# the CURRENT .claude/skills into a throwaway plugin (scratch dir: nothing is
# written under .claude/, which ships to users) together with cases/, and runs
# the suite there with the with-plugin arm only — a "skill fired" check has no
# meaning without the plugin.
#
# What it does NOT load: CLAUDE.md, rules, hooks, the routing hint. It measures
# triggering from the skill descriptions alone.
#
# COST: every run is a real `claude -p` session on your account. Runs locally,
# by hand, never in CI (maintainer decision 2026-09-27).
#
# Usage:
#   eval/skill-triggering/run.sh [--max-cost-usd N] [--extra-skills DIR]
#                                [extra plugin eval args]
#     --extra-skills: also install each DIR/<skill>/ (vendor skills
#     fetched at their pinned ref), to measure foundation-vs-vendor triggering.
#     default ceiling: 3 USD. Model: your Claude Code default (pass --model
#     to override). Results: eval/skill-triggering/results/<timestamp>/
# =============================================================================

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

command -v claude >/dev/null 2>&1 || { echo "run.sh: claude CLI not found" >&2; exit 2; }

MAX_COST="3"
EXTRA_SKILLS=""
while [ $# -gt 0 ]; do
    case "$1" in
        --max-cost-usd) MAX_COST="${2:?--max-cost-usd needs a value}"; shift 2 ;;
        --extra-skills) EXTRA_SKILLS="${2:?--extra-skills needs a directory}"; shift 2 ;;
        *) break ;;
    esac
done
if [ -n "$EXTRA_SKILLS" ] && [ ! -d "$EXTRA_SKILLS" ]; then
    echo "run.sh: --extra-skills: not a directory: $EXTRA_SKILLS" >&2
    exit 2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
PLUGIN="$WORK/claude-base-skills"
mkdir -p "$PLUGIN/.claude-plugin"
printf '{ "name": "claude-base-skills", "version": "0.0.0", "description": "claude-base skills under eval" }\n' \
    > "$PLUGIN/.claude-plugin/plugin.json"
cp -R "$ROOT/.claude/skills" "$PLUGIN/skills"
cp -R "$HERE/cases" "$PLUGIN/evals"

# --extra-skills: install third-party skills next to ours (each DIR/<skill>/
# holding a SKILL.md — one level only, so a template SKILL.md nested inside a
# skill is not mistaken for a skill), to measure which side fires when both are
# present. A name already taken aborts: one would shadow the other.
if [ -n "$EXTRA_SKILLS" ]; then
    n=0
    while IFS= read -r skill_md; do
        src="$(dirname "$skill_md")"
        dest="$PLUGIN/skills/$(basename "$src")"
        if [ -e "$dest" ]; then
            echo "run.sh: --extra-skills: $(basename "$src") collides with an installed skill" >&2
            exit 2
        fi
        cp -R "$src" "$dest"
        n=$((n + 1))
    done < <(find "$EXTRA_SKILLS" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)
    [ "$n" -gt 0 ] || { echo "run.sh: --extra-skills: no <skill>/SKILL.md under $EXTRA_SKILLS" >&2; exit 2; }
    echo "run.sh: $n extra skill(s) installed next to the foundation's" >&2
else
    # The vendor-*-coexist cases expect a vendor skill to fire: without one
    # installed they can only fail, so they are left out of the suite.
    rm -rf "$PLUGIN"/evals/vendor-*-coexist
fi

OUT="$HERE/results/$(date +%Y%m%dT%H%M%S)"
mkdir -p "$OUT"

# Our own code, copied into a dir we just created: --trust-plugin answers the
# first-run prompt the non-interactive run cannot show.
claude plugin eval "$PLUGIN" \
    --ablation none \
    --trust-plugin \
    --no-publish \
    --max-cost-usd "$MAX_COST" \
    --output-dir "$OUT" \
    --report "$OUT/report.html" \
    --json "$OUT/result.json" \
    --keep-temp \
    --scaffold \
    "$@"
# --scaffold: runs each case's scaffold_script (fixture files) as you. Only the
# cases under cases/, written in this repository, are copied into the suite.
# --keep-temp: the traces (the only record of which model ran and what Claude
# did instead of firing the skill) live in /tmp/claude-eval-*/ and are deleted
# otherwise — measured on the pilot, where neither the JSON nor the report
# names the model.
