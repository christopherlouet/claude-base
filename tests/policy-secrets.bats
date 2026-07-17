#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/hooks/_policy-secrets.sh — the harness-neutral core
# of the secret gate. scan_content_for_secrets() is called on PLAIN CONTENT
# strings (no stdin JSON envelope, no exit-2): deny = return 1 + the full
# BLOCKED reason on stdout; clean = return 0, no output.
#
# tests/secret-scan.bats remains the Claude-Code-contract oracle for the shell.
# NOTE: test secrets are assembled at runtime from fragments (prefix var +
# body) so no full secret literal appears in this file — otherwise GitHub Push
# Protection (and the foundation's own secret gate) would block on our own
# fixtures.
# =============================================================================

load 'test_helper'

POLICY="$BASE_DIR/scripts/hooks/_policy-secrets.sh"

setup() {
    # Neutral cwd: no .gitleaks.toml, so the gitleaks helper is a no-op here.
    cd "$BATS_TEST_TMPDIR"
}

run_scan() {
    run bash -c ". '$POLICY'; scan_content_for_secrets \"\$1\"" _ "$1"
}

@test "policy-secrets: core file exists, sourceable, functions defined" {
    [ -f "$POLICY" ]
    run bash -c "set -euo pipefail; . '$POLICY'; declare -F scan_content_for_secrets >/dev/null && declare -F scan_content_with_gitleaks >/dev/null"
    [ "$status" -eq 0 ]
}

@test "policy-secrets: denies an AWS access key" {
    local a="AKIA"; a="${a}1234567890ABCDEF"
    run_scan "aws_key = '$a'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"BLOCKED"* ]]
    [[ "$output" == *"AWS"* ]]
}

@test "policy-secrets: denies a Stripe live key" {
    local k="sk_live_"; k="${k}4eC39HqLyjWDarjtT1zdp7dcKLMNOPQR"
    run_scan "const stripe = '$k';"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Stripe"* ]]
}

@test "policy-secrets: denies a GitHub token" {
    local g="ghp_"; g="${g}0123456789abcdefghijklmnopqrstuvwxyz"
    run_scan "token=$g"
    [ "$status" -eq 1 ]
}

@test "policy-secrets: denies a Slack token" {
    local t="xoxb-"; t="${t}012345678901234567890abcdef"
    run_scan "slack = '$t'"
    [ "$status" -eq 1 ]
}

@test "policy-secrets: denies a Google API key" {
    local k="AIza"; k="${k}0123456789abcdefghijklmnopqrstuvwxy"
    run_scan "gapi = '$k'"
    [ "$status" -eq 1 ]
}

@test "policy-secrets: denies a private key block" {
    # Assembled at runtime — the full marker must not appear in this file.
    local pk="-----BEGIN RSA "; pk="${pk}PRIVATE KEY-----"
    run_scan "$pk"
    [ "$status" -eq 1 ]
}

@test "policy-secrets: allows a self-declared placeholder value" {
    run_scan "aws_key = 'AKIAIOSFODNN7EXAMPLE'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "policy-secrets: allows ordinary code with no secrets" {
    run_scan "export function add(a, b) { return a + b; }"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "policy-secrets: a real key behind a same-line comment still denies" {
    # Keying the placeholder test on the whole LINE let a real key slip through
    # behind a '// example' comment — the placeholder word must be part of the
    # secret value itself.
    local a="AKIA"; a="${a}1234567890ABCDEF"
    run_scan "key = '$a' // example only"
    [ "$status" -eq 1 ]
}

@test "policy-secrets: empty content is allowed" {
    run_scan ""
    [ "$status" -eq 0 ]
}

@test "policy-secrets: the reason quotes the matched value" {
    local g="ghp_"; g="${g}0123456789abcdefghijklmnopqrstuvwxyz"
    run_scan "token=$g"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ghp_"* ]]
}

@test "policy-secrets: gitleaks helper is a clean no-op without config" {
    # No .gitleaks.toml in cwd → return 0 regardless of gitleaks presence.
    run bash -c ". '$POLICY'; scan_content_with_gitleaks 'anything'"
    [ "$status" -eq 0 ]
}

@test "policy-secrets: core file contains no harness plumbing" {
    ! grep -E 'tool_input|hookSpecificOutput|CLAUDE_PROJECT_DIR|exit 2' "$POLICY"
}
