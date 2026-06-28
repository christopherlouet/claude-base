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
CONTENT=$(printf '%s' "$INPUT" | jq -r '
  [ .tool_input.content // empty,
    .tool_input.new_string // empty,
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
    # Find a matching line that is NOT a self-declared placeholder.
    match=$(printf '%s' "$CONTENT" | grep -nE "$regex" 2>/dev/null | grep -vE "$PLACEHOLDER" | head -n1 || true)
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
if command -v gitleaks >/dev/null 2>&1 && [ -f .gitleaks.toml ]; then
    result=$(printf '%s' "$CONTENT" | gitleaks detect --no-git --pipe --config .gitleaks.toml 2>&1 || true)
    if printf '%s' "$result" | grep -qiE 'secret|leak|finding'; then
        echo >&2 "BLOCKED: secret detected by gitleaks."
        echo >&2 "$result" | head -n 20
        exit 2
    fi
fi

exit 0
