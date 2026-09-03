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
# WHY FIVE SOURCES. The spec scopes the guardrails to "18 items, ten blocking
# and eight advisory". Measured, that is exactly right — for scripts/hooks/, one
# of the five places a refusal can live. EF-001 requires completeness to be
# ESTABLISHED rather
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
#   5. permissions.deny         the native rules. They refuse before any hook is
#                               consulted, and no inventory listed them until
#                               2026-09-02 — the gap this file's own record
#                               named rather than quietly closed.
#
# WHY SOURCE 5 CARRIES A CLASS AND THE OTHERS DO NOT. The native rules are
# matched by a platform matcher whose behaviour had to be established
# empirically. Measured on 2026-09-01 (specs/guardrail-cleanup/native-coverage.md,
# T202): THE MATCHER IS TOKEN-BOUNDARY AWARE. `rm -rf node_modules` is refused
# while a rule whose prefix stops mid-token is not, on the same binary with the
# same flags. So a rule whose prefix ends on an incomplete path fragment covers
# its bare literal and nothing beyond it. Listing the rules without that class
# would name refusals without saying which can fire — the exact defect Phase 3
# found in this layer.
#
# Output: one row per item, `source | name | kind | invoked-from`, LC_ALL=C
# sorted so two runs differ only when the repository really changed.
#
# Usage: guardrail-inventory.sh [--root DIR]
#                              [--source hooks|settings|husky|ci|deny]
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


# --- 5. the native permissions.deny rules -----------------------------------
# Enumerated with the class the MEASURED matcher law assigns each rule, because
# a list of refusals that does not say which can fire is the defect this pass
# exists to remove. Three classes: two are the law, the third is its absence:
#
#   blocking               the prefix ends on a whole token, so every command
#                          it aims at continues with a SPACE and is matched.
#   blocking-literal-only  the prefix ends where a real target keeps going
#                          INSIDE the same token, so only the bare literal is
#                          ever refused.
#   blocking-unmodelled    the rule refuses, and no MEASURED model says how far.
#                          A non-Bash matcher nobody probed, or a rule this tool
#                          cannot parse. Reporting either as `blocking` would
#                          claim a coverage nothing established — the very
#                          failure mode this source exists to expose.
#
# Three routes reach the second class, and they are ordered by how much they
# claim. The first two are lexical, readable off the rule's own text; the third
# is a judgement about a tool's normal form, so it is a NAMED list with a reason
# per entry rather than a pattern, and each entry is pinned by a test.
#
# The law was measured on the BASH matcher, so a Read/Write/WebFetch rule is
# enumerated as unmodelled rather than as blocking: carrying a Bash finding to a
# matcher nobody probed would be the same overclaim in a new place.
#
# ONE ROUTE IS KNOWINGLY NOT MODELLED, and it is stated rather than smoothed
# over: a final token that is a SHORT FLAG CLUSTER can be continued the same
# way, so `chown -R` misses `chown -Rf`. Such a rule keeps the `blocking` class
# because the form it aims at — the flag followed by a space — really is
# matched, and calling it literal-only would understate it just as badly. This
# repository has already met the escape and worked around it by hand: the deny
# list carries BOTH `git clean -fd` and `git clean -fdx`, which is what adding a
# second rule for a longer cluster looks like.
if wanted deny && [ -f "$ROOT/.claude/settings.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$ROOT/.claude/settings.json" <<'PY' 2>/dev/null || true
import json, re, sys

# Command words whose NORMAL form carries a suffix, so a bare-word rule never
# meets them. One entry per measured miss; the value is the form that escapes.
SUFFIXABLE = {
    'mkfs': 'mkfs.ext4',   # mkfs.ext4 / mkfs.xfs are different tokens
}

# A token made only of these can always be continued within itself: `/`, `/*`,
# `.`, `..`, `~`.
PATH_PUNCT = '/.~*'


def is_path_prefix(tok):
    """Does a real target continue this token?

    Punctuation alone is the obvious case, but it is not the whole one: a rule
    naming a real directory is a prefix of everything under it, so `/etc` misses
    `/etc/passwd` exactly as `/` misses a whole home. A trailing slash is the
    same statement made out loud. Judged by SHAPE, so a bare word target such as
    `node_modules` — the one rule of that shape measured to fire — keeps the
    stronger class.
    """
    if tok.strip(PATH_PUNCT) == '':
        return True
    if tok.endswith('/'):
        return True
    return tok.startswith(('/', '~/', './', '../'))


def classify(rule):
    """(kind, note) for one deny rule. Claims nothing it cannot read."""
    m = re.match(r'^([A-Za-z_][A-Za-z_0-9]*)\((.*)\)$', rule, re.S)
    if not m:
        return 'blocking-unmodelled', 'not parsed as tool(pattern)'
    tool, payload = m.group(1), m.group(2)
    if tool != 'Bash':
        return 'blocking-unmodelled', 'the token law was measured on Bash only'
    if not payload.endswith(':*'):
        return 'blocking-literal-only', 'exact-match rule: no :* prefix wildcard'
    toks = payload[:-2].split()
    if not toks:
        return 'blocking-unmodelled', 'empty prefix'
    last = toks[-1]
    if is_path_prefix(last):
        return 'blocking-literal-only', ''
    if last in SUFFIXABLE:
        return ('blocking-literal-only',
                'normal form %s is a different token' % SUFFIXABLE[last])
    return 'blocking', ''


try:
    d = json.load(open(sys.argv[1]))
    rules = ((d.get('permissions') or {}).get('deny') or [])
except Exception:
    sys.exit(0)

# A `deny` that is not a list is malformed, and iterating it anyway is not
# harmless: a bare string yields ONE ROW PER CHARACTER, each announcing a
# refusal that does not exist. Measured on a planted fixture, 12 of them.
if not isinstance(rules, list):
    sys.exit(0)

for rule in rules:
    if not isinstance(rule, str) or not rule.strip():
        continue
    kind, note = classify(rule)
    where = 'permissions.deny'
    if note:
        where = '%s — %s' % (where, note)
    print('deny | %s | %s | %s' % (rule, kind, where))
PY
fi

}

emit_all | LC_ALL=C sort
exit 0
