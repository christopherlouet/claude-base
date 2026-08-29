#!/usr/bin/env bash
# =============================================================================
# guardrail-inventory.sh — enumerate everything in this repository that can
# refuse an action, or that runs unprompted, from ALL of its sources.
#
# THIS TOOL REPORTS. It refuses nothing, blocks nothing, and exits 0 whatever it
# finds — including when it finds nothing. That is deliberate. It serves the
# pass in specs/guardrail-cleanup/, whose whole thesis is that guardrails get
# added on the day they seem sensible; adding one in order to enumerate the
# others would be the pass contradicting itself on its first move. The drift
# guard that would keep the inventory true is deferred to the end of the pass
# (plan decision D1, task T604), so it can be judged by the same criteria as
# everything else it will sit beside.
#
# WHY FOUR SOURCES. The spec scopes the guardrails to "18 items, ten blocking
# and eight advisory". Measured, that is exactly right — for scripts/hooks/, one
# directory out of four. EF-001 requires completeness to be ESTABLISHED rather
# than asserted, and an inventory built from that directory alone would match
# the stated number while failing the stated requirement. It would also
# reproduce, at the level of the audit itself, the edge case the spec names:
# "a guardrail exists but is not listed anywhere".
#
#   1. scripts/hooks/*.sh       classified by whether the script can `exit 2`.
#                               Underscore-prefixed files are shared libraries,
#                               never declared as hooks — they are excluded, and
#                               that exclusion is what makes 10+8 come out right.
#   2. .claude/settings.json    every hook declaration, INCLUDING inline commands
#                               that have no script behind them. There are 31 of
#                               those today and they appear in no inventory; none
#                               can refuse (verified: no `exit 2`), but all of
#                               them run.
#   3. .husky/*                 the git hooks, and what they invoke — this is
#                               where private-names-check.sh lives, which is why
#                               it is absent from the spec's 18.
#   4. .github/workflows/*.yml  named steps. A CI gate refuses a merge, so by the
#                               spec's own criterion it qualifies (decision D2).
#
# Output: one row per item, `source | name | kind | invoked-from`, LC_ALL=C
# sorted so two runs differ only when the repository really changed.
#
# Usage: guardrail-inventory.sh [--root DIR] [--source hooks|settings|husky|ci]
# Exit:  0 always. A missing source is a row-less source, never an error.
#
# bash 3.2 safe (macOS): no mapfile, no associative arrays, no empty-array
# expansion under `set -u`.
# =============================================================================
set -euo pipefail

ROOT=""
ONLY=""
while [ $# -gt 0 ]; do
    case "$1" in
        --root) ROOT="${2:-}"; shift 2 ;;
        --source) ONLY="${2:-}"; shift 2 ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -nE '/^guardrail-inventory/,/^bash 3\.2/p'; exit 0 ;;
        *) echo "guardrail-inventory: unknown option: $1" >&2; exit 0 ;;
    esac
done

if [ -z "$ROOT" ]; then
    ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi
[ -d "$ROOT" ] || exit 0

wanted() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }
row() { printf '%s | %s | %s | %s\n' "$1" "$2" "$3" "$4"; }

emit_all() {

# --- 1. Claude Code hook scripts -------------------------------------------
# `exit 2` is how a hook refuses an action; anything else only advises. The
# underscore prefix marks a sourced library, not a hook — they are never
# declared in settings.json, which is the fact that justifies excluding them
# rather than a naming convention we hope holds.
if wanted hooks && [ -d "$ROOT/scripts/hooks" ]; then
    for f in "$ROOT"/scripts/hooks/*.sh; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        case "$base" in _*) continue ;; esac
        # The terminator is any NON-DIGIT (or end of line), not merely
        # whitespace: the real pre-commit-tests.sh writes `…; exit 2; }` inside a
        # brace group, and demanding whitespace silently demoted a blocking
        # guardrail to advisory. Comment lines are stripped first, so a script
        # that only DOCUMENTS how blocking works is not counted as blocking.
        if sed 's/#.*//' "$f" | grep -qE '(^|[[:space:]])exit[[:space:]]+2([^0-9]|$)'; then
            kind=blocking
        else
            kind=advisory
        fi
        events=""
        if [ -f "$ROOT/.claude/settings.json" ] \
           && grep -q "scripts/hooks/$base" "$ROOT/.claude/settings.json"; then
            events="settings.json"
        else
            events="not-declared"
        fi
        row "hooks" "$base" "$kind" "$events"
    done
fi

# --- 2. settings.json declarations, inline ones included --------------------
# An inline command has no file to grep, so it would be invisible to any
# script-based inventory. Counted here as one row per event, because that is the
# granularity at which it costs something.
if wanted settings && [ -f "$ROOT/.claude/settings.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$ROOT/.claude/settings.json" <<'PY' 2>/dev/null || true
import json, re, sys, collections
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
counts = collections.Counter()
for evt, arr in (d.get('hooks') or {}).items():
    for grp in arr or []:
        for h in grp.get('hooks') or []:
            cmd = h.get('command', '') or ''
            if 'scripts/hooks/' in cmd:
                continue          # already enumerated from source 1
            kind = 'blocking' if re.search(r'(^|\s)exit\s+2(\s|$)', cmd) else 'advisory'
            counts[(evt, kind)] += 1
for (evt, kind), n in sorted(counts.items()):
    label = f'inline:{evt}' + (f' (x{n})' if n > 1 else '')
    print(f'settings.json | {label} | {kind} | settings.json')
PY
fi

# --- 3. git hooks -----------------------------------------------------------
# Reported with what they invoke, because the refusal usually lives one level
# down: pre-commit itself decides nothing, private-names-check.sh does.
if wanted husky && [ -d "$ROOT/.husky" ]; then
    for f in "$ROOT"/.husky/*; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        case "$base" in _|_*) continue ;; esac
        invokes=$(grep -oE '(scripts/[a-zA-Z0-9._/-]+\.sh|npx [a-z@/-]+)' "$f" 2>/dev/null \
                  | LC_ALL=C sort -u | tr '\n' ',' | sed 's/,$//')
        [ -n "$invokes" ] || invokes="(nothing)"
        row "husky" "$base" "blocking" "$invokes"
    done
fi

# --- 4. CI gates ------------------------------------------------------------
# A CI step refuses a merge, so it qualifies under the spec's own criterion
# (decision D2: enumerate all, grade all). Infrastructure steps — checkout,
# setup, cache, artifact upload — are skipped: they can fail, but they guard
# nothing.
if wanted ci && [ -d "$ROOT/.github/workflows" ]; then
    for f in "$ROOT"/.github/workflows/*.yml; do
        [ -f "$f" ] || continue
        wf=$(basename "$f")
        grep -oE '^[[:space:]]*-[[:space:]]+name:[[:space:]]+.*' "$f" 2>/dev/null \
        | sed -E 's/^[[:space:]]*-[[:space:]]+name:[[:space:]]+//' \
        | while IFS= read -r step; do
            case "$step" in
                [Cc]heckout*|[Ss]etup*|[Ii]nstall*|[Cc]ache*|[Uu]pload*|[Dd]ownload*|[Cc]onfigure*)
                    continue ;;
            esac
            [ -n "$step" ] || continue
            row "ci" "$step" "blocking" "$wf"
        done
    done
fi

}

emit_all | LC_ALL=C sort
exit 0
