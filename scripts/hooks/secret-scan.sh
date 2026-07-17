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
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): patterns
# and verdicts live in _policy-secrets.sh (directly tested by
# tests/policy-secrets.bats); this shell reads the stdin envelope, calls the
# core, and translates a hit into stderr + exit 2.
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

# Source the policy core. This gate fails OPEN on a missing dependency (same
# philosophy as the jq check above — an absent file cannot wedge every edit);
# the install manifest + fresh-install self-application test guard shipping.
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-secrets.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-secrets.sh" ]; then
  . "$_dir/_policy-secrets.sh"
else
  exit 0
fi

# Verdict translation: hit (return 1, reason on stdout) → stderr + exit 2.
if ! _reason=$(scan_content_for_secrets "$CONTENT"); then
  printf '%s\n' "$_reason" >&2
  exit 2
fi
if ! _reason=$(scan_content_with_gitleaks "$CONTENT"); then
  printf '%s\n' "$_reason" >&2
  exit 2
fi

exit 0
