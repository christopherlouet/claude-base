#!/usr/bin/env bash
# =============================================================================
# native-deny-corpus.sh — price a change to the NATIVE permissions.deny layer
# =============================================================================
# #540 removed three deny rules that could never fire and stopped there:
# replacing `dd if=` with `dd` would have WIDENED the layer, and the only
# corpus instrument this repository owns — validator-corpus.sh — measures the
# HOOK, not the native list. With nothing to measure the cost, the decision was
# recorded as deferred rather than taken. This is the missing instrument.
#
# It answers one question: over the commands this repository really runs and
# really prescribes, which ones would the native deny layer refuse — today, and
# under a candidate rule?
#
# THIS TOOL REPORTS. It refuses nothing and exits 0 whatever it finds. The gate
# is tests/native-deny-corpus.bats.
#
# ---------------------------------------------------------------------------
# WHAT IT MEASURES, AND WHAT IT CANNOT
# ---------------------------------------------------------------------------
# The native matcher belongs to the platform and no script can invoke it. What
# runs here is a MODEL of that matcher, and a model is worth exactly its arms.
# Six properties, each observed as a live tool call on 2026-09-02 and 09-04 —
# every one either an observed refusal or an observed execution:
#
#   prefix followed by a space matches      `chmod 777 <dir>`         refused
#   the bare literal matches                `git checkout .`          refused
#   a continuation INSIDE the last token    `git checkout ./<path>`   ran
#   …the same, on the rule that names `/`   `rm -rf /home/<probe>`    ran
#   the rule text in an ARGUMENT position   `echo chmod 777 <dir>`    ran
#   `&&` and `;` split the command          `true; chmod 777 <dir>`   refused
#
# DERIVED, NOT MEASURED: that `|`, `||` and a newline separate the same way.
# The model treats them as separators, so it reports MORE refusals than it can
# prove — the conservative direction for a tool whose job is to price a
# widening. Stated here rather than smoothed over.
#
# ---------------------------------------------------------------------------
# THE ZERO THAT MEANS NOTHING
# ---------------------------------------------------------------------------
# "0 new refusals" is evidence only if the corpus holds commands the candidate
# rule could have caught. Measured 2026-09-04: the corpus contains ZERO commands
# whose command word is `dd`, `mkfs`, `rm` or `chown` — the foundation's CI and
# docs simply never invoke them. For those families this instrument is BLIND,
# and a blind zero read as a green light is the failure this whole pass is
# about. So every candidate is reported with its SUPPORT, and a support of zero
# is named as blindness, not as a cost of nothing.
#
# SUPPORT IS COUNTED AT THE RULE'S GRANULARITY — the commands ONE TOKEN away
# from matching, not the ones merely sharing a command word. The difference is
# not academic: counted by word, a candidate about `git clean` reported a
# support of 82 over a corpus holding zero `git clean` commands, and so kept
# quiet precisely where it was blind.
#
# Usage:
#   scripts/native-deny-corpus.sh                     # TSV: rule, source, command
#   scripts/native-deny-corpus.sh --summary           # counts only
#   scripts/native-deny-corpus.sh --with-rule 'Bash(dd:*)'   # price a candidate
#   scripts/native-deny-corpus.sh --stdin             # read "source<TAB>cmd" instead
#   scripts/native-deny-corpus.sh --root DIR          # another checkout
#
# Exit: 0 always. bash 3.2 safe (macOS).
# =============================================================================
set -euo pipefail

ROOT=""
MODE="report"
USE_STDIN=0
CANDIDATES=""

while [ $# -gt 0 ]; do
    case "$1" in
        # `shift 2` on a lone argument returns non-zero, and `set -e` then
        # aborts before any exit — measured rc=1 with no output at all, against
        # a header promising "Exit: 0 always".
        --root)
            [ $# -ge 2 ] || { echo "native-deny-corpus: --root needs a value" >&2; exit 0; }
            ROOT="$2"; shift 2 ;;
        --stdin) USE_STDIN=1; shift ;;
        --summary) MODE="summary"; shift ;;
        --with-rule)
            [ $# -ge 2 ] || { echo "native-deny-corpus: --with-rule needs a value" >&2; exit 0; }
            CANDIDATES="${CANDIDATES}${2}
"
            shift 2 ;;
        -h|--help)
            sed -nE 's/^# ?//p' "$0" | sed -nE '/^native-deny-corpus/,/^Exit:/p'; exit 0 ;;
        *) echo "native-deny-corpus: unknown option: $1" >&2; exit 0 ;;
    esac
done

# A candidate always wins the mode. MODE used to be last-writer-wins, so
# `--with-rule X --summary` quietly answered a different question: the reader
# prices a widening, reads a count, and has priced nothing.
if [ -n "$CANDIDATES" ]; then
    MODE="candidate"
fi

if [ -z "$ROOT" ]; then
    ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi
[ -d "$ROOT" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

# The corpus is defined in ONE place. validator-corpus.sh already decides what
# counts as a real command of this repository — which files to read, what to
# drop as prose or output — and duplicating that here would give the two
# instruments two different ideas of the same corpus.
corpus() {
    if [ "$USE_STDIN" -eq 1 ]; then
        cat
    elif [ -x "$ROOT/scripts/validator-corpus.sh" ]; then
        bash "$ROOT/scripts/validator-corpus.sh" --list
    else
        # The one path that could print a reassuring zero with no warning
        # attached: a root without the corpus builder measures nothing and
        # reports "0 refused", which reads like a clean bill of health.
        echo "native-deny-corpus: no corpus source at" \
             "$ROOT/scripts/validator-corpus.sh — the count below is 0 for want" \
             "of input, not for want of refusals." >&2
    fi
}

# The program goes in through -c, never through stdin: `python3 -` reads its
# SOURCE from stdin, so piping the corpus into it leaves the pipe with no
# reader and the tool dies on SIGPIPE (exit 141) before printing a thing.
MODEL=$(cat <<'PY'
import json, os, re, sys

settings, mode = sys.argv[1], sys.argv[2]

# Segment separators: `&&` and `;` are measured, `||`, `|` and a newline are
# derived by analogy and deliberately kept, since over-reporting refusals is
# the safe direction for a tool that prices a widening.
#
# QUOTES ARE HONOURED, and that is not a refinement. A regex split cut inside
# string literals, so `grep -E "foo|chmod 777 bar" file` came back refused by
# the chmod rule — contradicting the model's own measured law that the rule
# text in an argument position does not match. Those refusals feed the
# reviewed-exception gate, so one such line in a docs fence would have failed
# CI over a command nothing refuses. Escapes are honoured too: a naive
# stripper unpairs on a backslashed quote, which this repository has already
# been bitten by once.
def segments(cmd):
    out, buf = [], []
    quote = None
    i, n = 0, len(cmd)
    while i < n:
        ch = cmd[i]
        if quote is not None:
            buf.append(ch)
            if ch == '\\' and quote == '"' and i + 1 < n:
                buf.append(cmd[i + 1])
                i += 2
                continue
            if ch == quote:
                quote = None
            i += 1
            continue
        if ch in ('"', "'"):
            quote = ch
            buf.append(ch)
            i += 1
            continue
        if ch == '\\' and i + 1 < n:
            buf.append(ch)
            buf.append(cmd[i + 1])
            i += 2
            continue
        if ch in (';', '\n'):
            out.append(''.join(buf))
            buf = []
            i += 1
            continue
        if ch == '&' and i + 1 < n and cmd[i + 1] == '&':
            out.append(''.join(buf))
            buf = []
            i += 2
            continue
        if ch == '|':
            step = 2 if (i + 1 < n and cmd[i + 1] == '|') else 1
            out.append(''.join(buf))
            buf = []
            i += step
            continue
        buf.append(ch)
        i += 1
    out.append(''.join(buf))
    return [seg.strip() for seg in out if seg.strip()]


def parse(rules):
    """(rule, prefix, is_prefix_rule) for every Bash rule."""
    out = []
    for r in rules:
        if not isinstance(r, str):
            continue
        m = re.match(r'^Bash\((.*)\)$', r, re.S)
        if not m:
            continue          # a non-Bash matcher: the law was not measured there
        p = m.group(1)
        if p.endswith(':*'):
            out.append((r, p[:-2], True))
        else:
            out.append((r, p, False))
    return out


def refusal(cmd, parsed):
    """The first rule that refuses this command, or None.

    A prefix rule matches a segment that IS the prefix, or that continues it
    after a SPACE. It never matches a segment continuing the prefix inside its
    final token, and never matches the text in an argument position — both
    measured.
    """
    for seg in segments(cmd):
        for rule, prefix, is_prefix in parsed:
            if seg == prefix:
                return rule
            if is_prefix and seg.startswith(prefix + ' '):
                return rule
    return None


def load_rules():
    try:
        with open(settings) as fh:
            return ((json.load(fh).get('permissions') or {}).get('deny') or [])
    except Exception:
        return []


rules = load_rules()
if not isinstance(rules, list):
    rules = []
parsed = parse(rules)

corpus = []
for line in sys.stdin:
    line = line.rstrip('\n')
    if '\t' not in line:
        continue
    src, cmd = line.split('\t', 1)
    if cmd.strip():
        corpus.append((src, cmd))

hits = [(refusal(c, parsed), s, c) for s, c in corpus]
hits = [h for h in hits if h[0]]

if mode == 'summary':
    print('corpus: %d commands, %d refused by the modelled native deny layer'
          % (len(corpus), len(hits)))
    sys.exit(0)

if mode == 'candidate':
    cand = [r for r in os.environ.get('CANDIDATE_RULES', '').split('\n') if r.strip()]
    after = parse(rules + cand)
    n_after = len([1 for s, c in corpus if refusal(c, after)])
    print('corpus:         %d commands' % len(corpus))
    print('current:        %d refused' % len(hits))
    print('with candidate: %d refused   (delta +%d)' % (n_after, n_after - len(hits)))
    parsed_cand = parse(cand)
    for rule in cand:
        if not any(r == rule for r, _p, _w in parsed_cand):
            # A non-Bash matcher, or a rule this model cannot read. Its delta is
            # 0 because nothing was measured, and a bare 0 reads as "free".
            print('support: not covered by the model  [%s] — the token law was '
                  'measured on the Bash matcher only, so this candidate was '
                  'priced at nothing because nothing was priced.' % rule)
    for rule, prefix, _ in parsed_cand:
        # Support is the set of commands ONE TOKEN away from matching, not the
        # set sharing a command word. Counting the word made a rule about
        # `git clean` report the support of every `git` command in the corpus —
        # 82 against 0 real ones — so it stayed silent exactly where it was
        # blind, which is the single thing this figure exists to prevent.
        toks = prefix.split()
        if len(toks) <= 1:
            stem = toks[0] if toks else ''
            support = len([1 for _s, c in corpus
                           if any(seg.split(' ')[0] == stem for seg in segments(c))])
        else:
            stem = ' '.join(toks[:-1])
            support = len([1 for _s, c in corpus
                           if any(seg == stem or seg.startswith(stem + ' ')
                                  for seg in segments(c))])
        print('support: %d command(s) in the corpus beginning with `%s`  [%s]'
              % (support, stem, rule))
        if support == 0:
            print('  ^ the corpus is blind to this rule: a delta of 0 here is an '
                  'ABSENCE OF MEASUREMENT, not a cost of nothing.')
    sys.exit(0)

for rule, src, cmd in hits:
    print('%s\t%s\t%s' % (rule, src, cmd))
PY
)

corpus | CANDIDATE_RULES="$CANDIDATES" python3 -c "$MODEL" "$ROOT/.claude/settings.json" "$MODE"
exit 0
