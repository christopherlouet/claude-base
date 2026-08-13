#!/usr/bin/env bash
# =============================================================================
# _policy-secrets.sh — Harness-neutral core of the secret gate
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/). Holds the
# high-confidence secret patterns, the placeholder allowlist and the gitleaks
# defense-in-depth helper; contains NO harness plumbing. The Claude Code shell
# is scripts/hooks/secret-scan.sh.
#
# Verdict contract:
#   scan_content_for_secrets <content>
#     clean → return 0, no output
#     hit   → return 1, full human-readable BLOCKED reason on stdout
#   scan_content_with_gitleaks <content>
#     clean / not configured / tooling error → return 0
#     leak found (gitleaks exit 1)           → return 1, reason on stdout
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only, no top-level side effects.
# =============================================================================

# Avoid double-sourcing
if [ -n "${POLICY_SECRETS_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
POLICY_SECRETS_LOADED=1

# A line is a placeholder (skip it) if it names itself as one. Keeps docs,
# .env.example and sample snippets from tripping the gate (zero-FP constraint).
POLICY_SECRETS_PLACEHOLDER='([Ee][Xx][Aa][Mm][Pp][Ll][Ee]|PLACEHOLDER|placeholder|DUMMY|dummy|CHANGEME|changeme|REDACTED|redacted|[Yy][Oo][Uu][Rr][-_]|xxxx|XXXX|FAKE|fake|SAMPLE|sample)'

# High-confidence secret patterns (provider-specific → near-zero false positives).
# label<TAB>regex
POLICY_SECRETS_PATTERNS='AWS access key	AKIA[0-9A-Z]{16}
Stripe live secret key	(sk|rk)_live_[0-9a-zA-Z]{24,}
GitHub token	gh[pousr]_[0-9A-Za-z]{36,}
Slack token	xox[baprs]-[0-9A-Za-z-]{10,}
Slack webhook	hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]{20,}
Google API key	AIza[0-9A-Za-z_-]{35}
Private key block	-----BEGIN [A-Z ]*PRIVATE KEY-----'

scan_content_for_secrets() {
    local CONTENT="$1"
    [ -z "$CONTENT" ] && return 0

    local hit_label="" hit_line="" label regex match
    while IFS=$'\t' read -r label regex; do
        [ -n "$label" ] || continue
        # Extract the matched SECRET VALUE (-o), then drop it only if the value
        # ITSELF is a self-declared placeholder (e.g. AKIA…EXAMPLE). Keying on the
        # whole line let a real key slip through behind a same-line "// example"
        # comment — the placeholder word must be part of the secret, not elsewhere.
        # `--` before the pattern: the "Private key block" regex starts with `-----`,
        # which grep otherwise parses as (unknown) options → grep exits 2, never matching.
        match=$(printf '%s' "$CONTENT" | grep -oE -- "$regex" 2>/dev/null | grep -vE "$POLICY_SECRETS_PLACEHOLDER" | head -n1 || true)
        if [ -n "$match" ]; then
            hit_label="$label"
            hit_line="$match"
            break
        fi
    done <<EOF
$POLICY_SECRETS_PATTERNS
EOF

    if [ -n "$hit_label" ]; then
        printf '%s\n' "BLOCKED: possible hardcoded secret ($hit_label)."
        printf '%s\n' "  $(printf '%s' "$hit_line" | cut -c1-120)"
        printf '%s\n' "Move it to an environment variable / secret store. If this is a placeholder,"
        printf '%s\n' "name it so (EXAMPLE/PLACEHOLDER/...) or set SKIP_SECRET_SCAN=1 for this run."
        return 1
    fi
    return 0
}

# Defense in depth: if the project opted into gitleaks, run it too (richer rules).
# Block on gitleaks' EXIT CODE, never on its log text: a CLEAN run prints
# "INF no leaks found", whose "leak" substring would false-block EVERY edit if
# grepped. `--exit-code 1` makes gitleaks return exactly 1 when it finds leaks;
# any other non-zero status is a tooling error (bad/removed flag, config) and we
# fail OPEN — the built-in scan above already covers the high-confidence secrets.
scan_content_with_gitleaks() {
    local CONTENT="$1"
    [ -z "$CONTENT" ] && return 0
    command -v gitleaks >/dev/null 2>&1 || return 0
    [ -f .gitleaks.toml ] || return 0

    # `stdin` is the subcommand that actually reads the pipe. `detect --no-git
    # --pipe` silently IGNORES --pipe and walks the working directory instead:
    # the gate then blocked every write in any project holding a secret on disk
    # (terraform.tfvars, .env), while reporting findings the write never
    # contained. The shimmed tests could not see it -- their fake gitleaks
    # ignores stdin, and a real-binary case only reproduces it from a cwd that
    # is not empty.
    #
    # Capture the status WITHOUT tripping a caller's `set -e` (a non-zero
    # gitleaks exit in a bare `x=$(...)` assignment would abort mid-scan).
    local gl_out gl_status
    gl_out=$(printf '%s' "$CONTENT" | gitleaks stdin --redact --exit-code 1 --config .gitleaks.toml 2>&1) && gl_status=0 || gl_status=$?
    if [ "${gl_status:-0}" -eq 1 ]; then
        printf '%s\n' "BLOCKED: secret detected by gitleaks."
        printf '%s\n' "$gl_out" | head -n 20
        return 1
    fi
    return 0
}
