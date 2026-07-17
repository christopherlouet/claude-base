#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/hooks/_policy-write-targets.sh — the harness-neutral
# write-target extraction core of bash-write-guard.sh.
#
# extract_write_targets <cmd> prints one candidate write-target path per line
# (after message-value strip, quote-strip and package-manager-install
# neutralization); no verdict here — classifying targets (protected config,
# secret file) stays with _sensitive-paths.sh, and environment checks
# (existence, branch, tracked) stay in the shell.
# =============================================================================

load 'test_helper'

POLICY="$BASE_DIR/scripts/hooks/_policy-write-targets.sh"

run_extract() {
    run bash -c ". '$POLICY'; extract_write_targets \"\$1\"" _ "$1"
}

@test "policy-wt: core file exists, sourceable, function defined" {
    [ -f "$POLICY" ]
    run bash -c "set -euo pipefail; . '$POLICY'; declare -F extract_write_targets >/dev/null"
    [ "$status" -eq 0 ]
}

@test "policy-wt: extracts a redirect target" {
    run_extract "echo x > .env"
    [ "$status" -eq 0 ]
    [[ "$output" == *".env"* ]]
}

@test "policy-wt: extracts an append-redirect target" {
    run_extract "echo rule >> .eslintrc.json"
    [[ "$output" == *".eslintrc.json"* ]]
}

@test "policy-wt: extracts a tee target" {
    run_extract "cat cfg | tee .prettierrc"
    [[ "$output" == *".prettierrc"* ]]
}

@test "policy-wt: extracts a sed -i target" {
    run_extract "sed -i 's/error/off/' .eslintrc.json"
    [[ "$output" == *".eslintrc.json"* ]]
}

@test "policy-wt: extracts a cp destination" {
    run_extract "cp .env.example .env"
    [[ "$output" == *".env"* ]]
}

@test "policy-wt: extracts a dd of= plain-file target" {
    run_extract "dd if=/dev/zero of=.env bs=1"
    [[ "$output" == *".env"* ]]
}

@test "policy-wt: quoted target is still extracted (quote-stripped copy)" {
    run_extract 'echo x > ".env"'
    [[ "$output" == *".env"* ]]
}

@test "policy-wt: pip install is NOT read as a file write" {
    run_extract "pip install -r requirements.txt"
    [[ "$output" != *"requirements.txt"* ]]
}

@test "policy-wt: npm install with flags is NOT read as a file write" {
    run_extract "npm install --save-dev typescript"
    [[ "$output" != *"typescript"* ]]
}

@test "policy-wt: coreutils install SRC DST still yields the DST" {
    run_extract "install -m 644 myfile /tmp/dest"
    [[ "$output" == *"/tmp/dest"* ]]
}

@test "policy-wt: a pip install with a redirect still yields the redirect target" {
    run_extract "pip install x > install.log"
    [[ "$output" == *"install.log"* ]]
}

@test "policy-wt: message payload naming a cp is not a write" {
    run_extract 'git commit -m "chore: cp .env.example .env"'
    [[ "$output" != *".env"* ]]
}

@test "policy-wt: no write constructs yields no output, exit 0" {
    run_extract "ls -la && npm test"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "policy-wt: empty command yields no output, exit 0" {
    run_extract ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "policy-wt: fd-dup redirect (2>&1) produces no file token" {
    run_extract "npm test 2>&1"
    [ -z "$output" ]
}

@test "policy-wt: core file contains no harness plumbing" {
    ! grep -E 'tool_input|hookSpecificOutput|CLAUDE_PROJECT_DIR|exit 2' "$POLICY"
}
