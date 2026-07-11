#!/usr/bin/env bats

# =============================================================================
# Tests for check-updates.sh
# =============================================================================
# check-updates.sh runs under `set -euo pipefail`. The GitHub API can return a
# body with no tag_name (anonymous rate-limit is routine) and skills.sh can
# return a keyword-less page. Neither must abort the script mid-run: the
# error-status fallbacks must be reachable and the documented exit codes
# (0 up-to-date, 1 updates-available, 2 error) must hold.
# =============================================================================

load 'test_helper'

CHECK_UPDATES="$BATS_TEST_DIRNAME/../scripts/check-updates.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    FAKEBIN="$TEST_DIR/fakebin"
    mkdir -p "$FAKEBIN"
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME"
}

teardown() {
    teardown_test_dir
}

# Install a fake `claude` that reports a version (so the CLI local-version
# branch is exercised, reaching the remote-version grep).
fake_claude() {
    local version="$1"
    cat > "$FAKEBIN/claude" <<EOF
#!/usr/bin/env bash
echo "Claude Code v$version"
EOF
    chmod +x "$FAKEBIN/claude"
}

# Install a fake `curl` that always prints the given body and exits 0
# (curl "succeeds" — the HTTP body is what carries the rate-limit / empty page).
fake_curl() {
    local body="$1"
    cat > "$FAKEBIN/curl" <<EOF
#!/usr/bin/env bash
cat <<'BODY'
$body
BODY
EOF
    chmod +x "$FAKEBIN/curl"
}

# =============================================================================
# BUG 1: rate-limit body (no tag_name) must not abort the script
# =============================================================================

@test "check-updates: rate-limit body (no tag_name) reports error status, not a crash" {
    fake_claude "2.0.0"
    fake_curl '{"message":"API rate limit exceeded for 1.2.3.4","documentation_url":"https://docs.github.com"}'

    run env PATH="$FAKEBIN:$PATH" "$CHECK_UPDATES" --no-skills --force
    # Documented exit code for "error during the check" is 2 — NOT 1
    # (which is reserved for "updates available") and NOT a set -e crash.
    [ "$status" -eq 2 ]
    # The error-status fallback path must be reached and reported.
    [[ "$output" == *"in error"* ]]
    # A set -e abort would print the ERR-trap line instead of the summary.
    [[ "$output" != *"Error at line"* ]]
}

# =============================================================================
# BUG 1: keyword-less skills.sh response must not double-emit "0\n0"
# =============================================================================

@test "check-updates: keyword-less skills response does not trigger an arithmetic error" {
    fake_curl '<html><body>nothing relevant here</body></html>'

    run env PATH="$FAKEBIN:$PATH" "$CHECK_UPDATES" --no-cli --force
    # No CLI check, no updates, no errors -> up to date, exit 0.
    [ "$status" -eq 0 ]
    [[ "$output" != *"Error at line"* ]]
    # The '0\n0' double-emit makes bash raise a locale-independent arithmetic
    # diagnostic prefixed with '[[:'. It must not appear.
    [[ "$output" != *"[[:"* ]]
}
