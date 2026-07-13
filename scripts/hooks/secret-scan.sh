#!/usr/bin/env bash
# =============================================================================
# secret-scan.sh — PreToolUse hook (Edit|Write|MultiEdit): block writing a
# hardcoded secret. Works OUT OF THE BOX with no external tool: a built-in set of
# HIGH-CONFIDENCE secret patterns (near-zero false positives). If gitleaks + a
# .gitleaks.toml are present it ALSO runs gitleaks (richer rules); otherwise the
# built-in scan still protects a fresh project — the previous hook silently
# no-op'd when gitleaks was absent, which is most new projects.
#
# Why built-in matters (measured): even a security-aware Opus hardcodes a
# credential ~50% of the time when handed one (eval/value-proof triage); a
# deterministic gate catches it 100%, model-independently.
#
# Payload on STDIN as JSON; scans .tool_input.content (Write), .new_string (Edit)
# and .edits[].new_string (MultiEdit). Block = exit 2 with a stderr reason.
# Placeholders (EXAMPLE/PLACEHOLDER/DUMMY/...) are ignored to stay zero-FP.
# Disable with SKIP_SECRET_SCAN=1.
# =============================================================================
set -euo pipefail

[ "${SKIP_SECRET_SCAN:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || true)

# jq is the documented path. Absent jq → fail OPEN (do not block) so a missing
# tool cannot wedge every edit; the built-in scan needs the extracted content.
command -v jq >/dev/null 2>&1 || exit 0
# .new_source is NotebookEdit's content field (the matcher covers NotebookEdit
# since pass-3 — a secret written into an .ipynb cell was never scanned).
CONTENT=$(printf '%s' "$INPUT" | jq -r '
  [ .tool_input.content // empty,
    .tool_input.new_string // empty,
    .tool_input.new_source // empty,
    ( .tool_input.edits[]?.new_string // empty ) ] | join("\n")
' 2>/dev/null || true)
[ -z "$CONTENT" ] && exit 0

# A line is a placeholder (skip it) if it names itself as one. Keeps docs,
# .env.example and sample snippets from tripping the gate (zero-FP constraint).
PLACEHOLDER='([Ee][Xx][Aa][Mm][Pp][Ll][Ee]|PLACEHOLDER|placeholder|DUMMY|dummy|CHANGEME|changeme|REDACTED|redacted|[Yy][Oo][Uu][Rr][-_]|xxxx|XXXX|FAKE|fake|SAMPLE|sample)'

# High-confidence secret patterns (provider-specific → near-zero false positives).
# label<TAB>regex
PATTERNS='AWS access key	AKIA[0-9A-Z]{16}
Stripe live secret key	(sk|rk)_live_[0-9a-zA-Z]{24,}
GitHub token	gh[pousr]_[0-9A-Za-z]{36,}
Slack token	xox[baprs]-[0-9A-Za-z-]{10,}
Slack webhook	hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]{20,}
Google API key	AIza[0-9A-Za-z_-]{35}
Private key block	-----BEGIN [A-Z ]*PRIVATE KEY-----'

hit_label=""
hit_line=""
while IFS=$'\t' read -r label regex; do
    [ -n "$label" ] || continue
    # Extract the matched SECRET VALUE (-o), then drop it only if the value
    # ITSELF is a self-declared placeholder (e.g. AKIA…EXAMPLE). Keying on the
    # whole line let a real key slip through behind a same-line "// example"
    # comment — the placeholder word must be part of the secret, not elsewhere.
    # `--` before the pattern: the "Private key block" regex starts with `-----`,
    # which grep otherwise parses as (unknown) options → exit 2, never matching.
    match=$(printf '%s' "$CONTENT" | grep -oE -- "$regex" 2>/dev/null | grep -vE "$PLACEHOLDER" | head -n1 || true)
    if [ -n "$match" ]; then
        hit_label="$label"
        hit_line="$match"
        break
    fi
done <<EOF
$PATTERNS
EOF

if [ -n "$hit_label" ]; then
    echo >&2 "BLOCKED: possible hardcoded secret ($hit_label)."
    echo >&2 "  $(printf '%s' "$hit_line" | cut -c1-120)"
    echo >&2 "Move it to an environment variable / secret store. If this is a placeholder,"
    echo >&2 "name it so (EXAMPLE/PLACEHOLDER/...) or set SKIP_SECRET_SCAN=1 for this run."
    exit 2
fi

# Defense in depth: if the project opted into gitleaks, run it too (richer rules).
# Block on gitleaks' EXIT CODE, never on its log text: a CLEAN run prints
# "INF no leaks found", whose "leak" substring would false-block EVERY edit if
# grepped. `--exit-code 1` makes gitleaks return exactly 1 when it finds leaks;
# any other non-zero status is a tooling error (bad/removed flag, config) and we
# fail OPEN — the built-in scan above already covers the high-confidence secrets.
if command -v gitleaks >/dev/null 2>&1 && [ -f .gitleaks.toml ]; then
    # Capture the status WITHOUT tripping `set -e` (a non-zero gitleaks exit in a
    # bare `x=$(...)` assignment would abort the hook mid-scan).
    gl_out=$(printf '%s' "$CONTENT" | gitleaks detect --no-git --pipe --redact --exit-code 1 --config .gitleaks.toml 2>&1) && gl_status=0 || gl_status=$?
    if [ "${gl_status:-0}" -eq 1 ]; then
        echo >&2 "BLOCKED: secret detected by gitleaks."
        printf '%s\n' "$gl_out" | head -n 20 >&2
        exit 2
    fi
fi

exit 0
