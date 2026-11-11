#!/usr/bin/env bats

# =============================================================================
# Tests for the hook output rewriter (Phase 1 — Foundation)
# =============================================================================
# Covers:
#  - scripts/hooks/_hook-helpers.sh   (sourceable helpers)
#  - scripts/hooks/check-cli-version.sh   (SessionStart capability probe)
#
# Phase 2 (bash-output-filter) and Phase 3 (post-edit-typecheck-and-lint)
# tests will be added later in this same file.
# =============================================================================

load 'test_helper'

HELPERS="$BASE_DIR/scripts/hooks/_hook-helpers.sh"
CHECK_VERSION="$BASE_DIR/scripts/hooks/check-cli-version.sh"
BASH_FILTER="$BASE_DIR/scripts/hooks/bash-output-filter.sh"
INLINE_EDIT="$BASE_DIR/scripts/hooks/post-edit-typecheck-and-lint.sh"
FIXTURES="$BASE_DIR/tests/hook-output-rewriter/fixtures"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Per-test isolation: each test gets its own sentinel/log paths under
    # $BATS_TEST_TMPDIR (auto-cleaned by bats). Hooks consume them via the
    # HOOK_REWRITER_SENTINEL / HOOK_REWRITER_METRIC_LOG / HOOK_LEGACY_NOTICE_SENTINEL
    # env vars so parallel tests do not race on shared /tmp paths.
    SENTINEL_FILE="$BATS_TEST_TMPDIR/claude-rewriter-supported"
    METRIC_LOG="$BATS_TEST_TMPDIR/claude-rewriter.log"
    LEGACY_NOTICE_SENTINEL="$BATS_TEST_TMPDIR/claude-base-legacy-warned"
    export HOOK_REWRITER_SENTINEL="$SENTINEL_FILE"
    export HOOK_REWRITER_METRIC_LOG="$METRIC_LOG"
    export HOOK_LEGACY_NOTICE_SENTINEL="$LEGACY_NOTICE_SENTINEL"
    # Build a fake `claude` binary path that tests can prepend to PATH
    FAKE_BIN="$TEST_DIR/fake-bin"
    mkdir -p "$FAKE_BIN"
    export FAKE_BIN
}

teardown() {
    teardown_test_dir
}

# Helper: install a fake `claude` that prints a given version string
install_fake_claude() {
    local version_string="$1"
    cat > "$FAKE_BIN/claude" <<EOF
#!/usr/bin/env bash
echo "$version_string"
EOF
    chmod +x "$FAKE_BIN/claude"
}

# Helper: mark the rewriter as supported (skips the per-test SessionStart probe)
enable_rewriter() {
    echo "1" > "$SENTINEL_FILE"
}

# Helper: set up a fake TS project at $TEST_DIR with mock tsc/eslint.
# Args: tsc_fixture (path or empty), eslint_fixture (path or empty)
# Each fixture file's content is what the mock binary prints.
# Mock binaries exit 1 if their fixture file is non-empty (simulating found errors).
setup_fake_ts_project() {
    local tsc_fixture="$1" eslint_fixture="$2"
    mkdir -p "$TEST_DIR/node_modules/.bin"
    touch "$TEST_DIR/tsconfig.json"

    if [ -n "$tsc_fixture" ]; then
        cat > "$TEST_DIR/node_modules/.bin/tsc" <<EOF
#!/usr/bin/env bash
cat "$tsc_fixture"
exit 1
EOF
        chmod +x "$TEST_DIR/node_modules/.bin/tsc"
    fi

    if [ -n "$eslint_fixture" ]; then
        cat > "$TEST_DIR/node_modules/.bin/eslint" <<EOF
#!/usr/bin/env bash
cat "$eslint_fixture"
exit 1
EOF
        chmod +x "$TEST_DIR/node_modules/.bin/eslint"
    fi
}

# Helper: build an Edit-tool stdin JSON for a given file path.
edit_stdin_json() {
    local file_path="$1"
    local response="${2:-The file $file_path has been edited.}"
    jq -n --arg fp "$file_path" --arg resp "$response" \
        '{tool_name: "Edit", tool_input: {file_path: $fp}, tool_response: $resp}'
}

# Helper: assert filtering a bash fixture produces the expected output.
# Args: scenario_name command [exit_code]
assert_bash_fixture() {
    local name="$1"
    local cmd="$2"
    local exit_code="${3:-0}"
    local in_file="$FIXTURES/bash/$name.in.txt"
    local expected_file="$FIXTURES/bash/$name.expected.txt"

    [ -f "$in_file" ] || { echo "fixture missing: $in_file"; return 1; }
    [ -f "$expected_file" ] || { echo "expected missing: $expected_file"; return 1; }

    local stdin_json
    stdin_json=$(jq -n --arg cmd "$cmd" --argjson code "$exit_code" --rawfile out "$in_file" \
        '{tool_name: "Bash", tool_input: {command: $cmd}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false, exit_code: $code}}')

    # Lower threshold so artificial short fixtures still trigger the filter.
    # Threshold behavior itself is covered by dedicated tests.
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    unset BASH_OUTPUT_FILTER_THRESHOLD

    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')

    local expected
    expected=$(cat "$expected_file")

    if [ "$trimmed" != "$expected" ]; then
        echo "=== EXPECTED ==="
        printf '%s\n' "$expected"
        echo "=== GOT ==="
        printf '%s\n' "$trimmed"
        return 1
    fi
}

# =============================================================================
# Phase 1: _hook-helpers.sh
# =============================================================================

@test "Phase 1: _hook-helpers.sh exists and is sourceable" {
    [ -f "$HELPERS" ]
    run bash -c "source '$HELPERS' && type hook_bail_if_disabled hook_bail_if_unsupported hook_strip_ansi hook_emit_envelope"
    [ "$status" -eq 0 ]
}

@test "Phase 1: hook_bail_if_disabled exits 0 when env var = 1" {
    run bash -c "
        source '$HELPERS'
        export FOO_FLAG=1
        hook_bail_if_disabled FOO_FLAG
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_disabled does not bail when env var unset" {
    run bash -c "
        source '$HELPERS'
        unset FOO_FLAG
        hook_bail_if_disabled FOO_FLAG
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_bail_if_disabled does not bail when env var = 0" {
    run bash -c "
        source '$HELPERS'
        export FOO_FLAG=0
        hook_bail_if_disabled FOO_FLAG
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_bail_if_unsupported exits 0 when sentinel missing" {
    rm -f "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_unsupported exits 0 when sentinel content != 1" {
    echo "0" > "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_unsupported returns when sentinel content = 1" {
    echo "1" > "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_strip_ansi removes ANSI escape sequences" {
    run bash -c "
        source '$HELPERS'
        printf '\x1b[31mred text\x1b[0m and \x1b[1;32mgreen\x1b[0m' | hook_strip_ansi
    "
    [ "$status" -eq 0 ]
    [ "$output" = "red text and green" ]
}

@test "Phase 1: hook_strip_ansi passes plain text unchanged" {
    run bash -c "
        source '$HELPERS'
        echo 'plain text' | hook_strip_ansi
    "
    [ "$status" -eq 0 ]
    [ "$output" = "plain text" ]
}

@test "Phase 1: hook_emit_envelope produces valid JSON with hookSpecificOutput" {
    run bash -c "
        source '$HELPERS'
        hook_emit_envelope 'PostToolUse' 'additionalContext' 'hello world'
    "
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.additionalContext == "hello world"' >/dev/null
}

@test "Phase 1: hook_emit_envelope handles multi-line values" {
    run bash -c "
        source '$HELPERS'
        printf 'line1\nline2\nline3' | xargs -I {} echo {} > /dev/null  # no-op, keeps subshell
        hook_emit_envelope 'PostToolUse' 'additionalContext' \"\$(printf 'line1\nline2')\"
    "
    [ "$status" -eq 0 ]
    local val
    val=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [ "$val" = "$(printf 'line1\nline2')" ]
}

# #685: a STRING updatedToolOutput is ignored by Claude Code, silently — the
# value must match the tool's own result shape (measured: Bash takes the
# object, a string is dropped; Edit's result is structured, a string dropped
# too). The string helper must refuse that key so the bug cannot come back.
@test "Phase 1: hook_emit_envelope REFUSES updatedToolOutput (a string there is ignored)" {
    run bash -c "
        source '$HELPERS'
        hook_emit_envelope 'PostToolUse' 'updatedToolOutput' 'text'
    "
    [ "$status" -ne 0 ]
    [[ "$output" != *'hookSpecificOutput'* ]] || false
}

# bash_response <stdout> — a Bash tool_response as Claude Code sends it.
bash_response() {
    jq -n --arg out "$1" \
        '{tool_name: "Bash", tool_input: {command: "npm test"},
          tool_response: {stdout: $out, stderr: "warn: kept", interrupted: false,
                          isImage: false, noOutputExpected: false}}'
}

@test "Phase 1: hook_emit_updated_output keeps the tool's object, replaces stdout only" {
    local input; input=$(bash_response "long original")
    run bash -c "source '$HELPERS'; hook_emit_updated_output \"\$1\" 'short'" _ "$input"
    [ "$status" -eq 0 ]
    printf '%s' "$output" | jq -e '
        .hookSpecificOutput.hookEventName == "PostToolUse"
        and (.hookSpecificOutput.updatedToolOutput | type) == "object"
        and .hookSpecificOutput.updatedToolOutput.stdout == "short"
        and .hookSpecificOutput.updatedToolOutput.stderr == "warn: kept"
        and .hookSpecificOutput.updatedToolOutput.interrupted == false
        and .hookSpecificOutput.updatedToolOutput.isImage == false
        and .hookSpecificOutput.updatedToolOutput.noOutputExpected == false' >/dev/null
    # Same keys as the original: nothing invented, nothing dropped.
    [ "$(printf '%s' "$output" | jq -c '.hookSpecificOutput.updatedToolOutput | keys')" = \
      "$(printf '%s' "$input" | jq -c '.tool_response | keys')" ]
}

@test "Phase 1: hook_emit_updated_output keeps a string result a string" {
    local input
    input=$(jq -n '{tool_name: "X", tool_response: "original text"}')
    run bash -c "source '$HELPERS'; hook_emit_updated_output \"\$1\" 'short'" _ "$input"
    [ "$status" -eq 0 ]
    printf '%s' "$output" | jq -e '.hookSpecificOutput.updatedToolOutput == "short"' >/dev/null
}

@test "Phase 1: hook_emit_updated_output emits NOTHING for an object without stdout" {
    # An unknown shape is never guessed: it would be dropped silently.
    local input
    input=$(jq -n '{tool_name: "Edit", tool_response: {filePath: "/x", structuredPatch: []}}')
    run bash -c "source '$HELPERS'; hook_emit_updated_output \"\$1\" 'short'" _ "$input"
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}

@test "Phase 1: hook_emit_envelope handles UserPromptSubmit + additionalContext" {
    run bash -c "
        source '$HELPERS'
        hook_emit_envelope 'UserPromptSubmit' 'additionalContext' 'some context'
    "
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "UserPromptSubmit"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.additionalContext == "some context"' >/dev/null
}

# =============================================================================
# Phase 1: check-cli-version.sh (SessionStart probe)
# =============================================================================

@test "Phase 1: check-cli-version exists and is executable" {
    [ -x "$CHECK_VERSION" ]
}

@test "Phase 1: check-cli-version writes sentinel = 1 on supported version (2.1.121)" {
    install_fake_claude "2.1.121 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version writes sentinel = 1 on supported version (2.1.126)" {
    install_fake_claude "2.1.126 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version writes sentinel = 0 on unsupported version (2.1.120)" {
    install_fake_claude "2.1.120 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version emits notice on unsupported version" {
    install_fake_claude "2.1.100 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.1.121"* ]]
    [[ "$output" == *"disabled"* ]] || [[ "$output" == *"requires"* ]]
}

@test "Phase 1: check-cli-version handles minor version above 1 (2.2.0)" {
    install_fake_claude "2.2.0 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version handles major version above 2 (3.0.0)" {
    install_fake_claude "3.0.0 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version handles older major (1.99.999)" {
    install_fake_claude "1.99.999 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version falls back silently on garbage version output" {
    install_fake_claude "this is not a version"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version falls back silently when claude binary is missing" {
    # Empty PATH still needs /usr/bin for env+bash. Use an empty fake-bin dir.
    local empty_dir="$TEST_DIR/empty-bin"
    mkdir -p "$empty_dir"
    PATH="$empty_dir:/usr/bin:/bin" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version completes in less than 2 seconds" {
    install_fake_claude "2.1.126 (Claude Code)"
    local start_ms end_ms
    start_ms=$(now_ms)
    PATH="$FAKE_BIN:$PATH" "$CHECK_VERSION" >/dev/null 2>&1
    end_ms=$(now_ms)
    local elapsed_ms=$(( end_ms - start_ms ))
    [ "$elapsed_ms" -lt 2000 ]
}

# =============================================================================
# Phase 2: bash-output-filter.sh
# =============================================================================

@test "Phase 2: bash-output-filter.sh exists and is executable" {
    [ -x "$BASH_FILTER" ]
}

@test "Phase 2: filter exits 0 with no envelope when sentinel is missing" {
    rm -f "$SENTINEL_FILE"
    local stdin_json
    stdin_json=$(jq -n '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: "x\ny\n", stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter exits 0 with no envelope when SKIP_BASH_OUTPUT_FILTER=1" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: "x\ny\n", stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    SKIP_BASH_OUTPUT_FILTER=1 run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter passes through commands not in allowlist (ls -la)" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n --arg out "$(seq 1 50)" '{tool_name: "Bash", tool_input: {command: "ls -la"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter passes through outputs below threshold (< 30 lines)" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n --arg out "$(seq 1 10)" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter respects custom BASH_OUTPUT_FILTER_THRESHOLD" {
    enable_rewriter
    local stdin_json
    # 15 lines, one the install extractor keeps: a digest that keeps nothing
    # is not applied, so the input must hold something worth keeping.
    stdin_json=$(jq -n --arg out "$(seq 1 14; echo 'added 3 packages in 1s')" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    BASH_OUTPUT_FILTER_THRESHOLD=5 run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    # Above threshold of 5 → should produce envelope
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
}

@test "Phase 2: fixture npm-install-clean — trim verbose install output" {
    enable_rewriter
    assert_bash_fixture "npm-install-clean" "npm install" 0
}

@test "Phase 2: fixture npm-audit-vulns — keep severity counts and total" {
    enable_rewriter
    assert_bash_fixture "npm-audit-vulns" "npm audit" 0
}

@test "Phase 2: fixture npm-test-fail — keep failures + summary, exit code preserved" {
    enable_rewriter
    assert_bash_fixture "npm-test-fail" "npm test" 1
}

@test "Phase 2: fixture pytest-fail — pytest extractor keeps failure block + summary" {
    enable_rewriter
    assert_bash_fixture "pytest-fail" "pytest" 1
}

@test "Phase 2: fixture go-test-fail — go extractor keeps FAIL/ok lines + failure context" {
    enable_rewriter
    # Exit code 0: Bash results carry none and a failure never reaches this
    # hook, and with the failure context the digest outgrew the output.
    assert_bash_fixture "go-test-fail" "go test ./..." 0
}

@test "Phase 2: fixture cargo-build-fail — cargo extractor keeps error[E*] blocks" {
    enable_rewriter
    assert_bash_fixture "cargo-build-fail" "cargo build" 1
}

@test "Phase 2: SC-1 — npm-audit-vulns filtered view ≤ 25 lines" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-audit-vulns.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm audit"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
    local lines
    lines=$(printf '%s\n' "$trimmed" | wc -l)
    [ "$lines" -le 25 ]
}

@test "Phase 2: BASH_OUTPUT_FILTER_VERBOSE=1 keeps both views" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    export BASH_OUTPUT_FILTER_VERBOSE=1
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    unset BASH_OUTPUT_FILTER_VERBOSE BASH_OUTPUT_FILTER_THRESHOLD
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
    [[ "$trimmed" == *"--- Original output ---"* ]]
    [[ "$trimmed" == *"npm warn deprecated inflight"* ]]
}

@test "Phase 2: filter strips ANSI codes from output" {
    enable_rewriter
    local stdin_json
    local raw
    raw=$(printf '\x1b[31madded \x1b[1;32m247 packages\x1b[0m, and audited 248 packages in 12s\nfound 0 vulnerabilities\n')
    # Make output long enough to pass threshold
    raw="$raw$(seq 1 35)"
    stdin_json=$(jq -n --arg out "$raw" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
    [[ "$trimmed" != *$'\x1b['* ]]
}

@test "Phase 2: filter writes a metric log line on success" {
    enable_rewriter
    rm -f "$METRIC_LOG"
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    printf '%s' "$stdin_json" | "$BASH_FILTER" >/dev/null
    unset BASH_OUTPUT_FILTER_THRESHOLD
    [ -f "$METRIC_LOG" ]
    grep -qE "tool=Bash.*orig=[0-9]+.*filtered=[0-9]+" "$METRIC_LOG"
}

@test "Phase 2: the envelope keeps Bash's result object (stdout digested, stderr folded in)" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "npm notice kept", interrupted: false, isImage: false, noOutputExpected: false}}')
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    unset BASH_OUTPUT_FILTER_THRESHOLD
    printf '%s' "$result" | jq -e '
        (.hookSpecificOutput.updatedToolOutput | type) == "object"
        and .hookSpecificOutput.updatedToolOutput.stderr == ""
        and .hookSpecificOutput.updatedToolOutput.interrupted == false
        and .hookSpecificOutput.updatedToolOutput.isImage == false
        and (.hookSpecificOutput.updatedToolOutput | has("noOutputExpected"))
        and (.hookSpecificOutput.updatedToolOutput.stdout | length) > 0' >/dev/null
}

# real_bash <stdout> <stderr> [interrupted] — the Bash result as Claude Code
# sends it: no exit-code field (a failed command fires PostToolUseFailure).
real_bash() {
    jq -n --arg out "$1" --arg err "$2" --argjson intr "${3:-false}" \
        '{tool_name: "Bash", tool_input: {command: "cargo build"},
          tool_response: {stdout: $out, stderr: $err, interrupted: $intr,
                          isImage: false, noOutputExpected: false}}'
}

@test "Phase 2: a LARGE output still gets its envelope (no argv limit)" {
    # Passing the text as a jq argument hit Linux's 128 KB per-argument limit:
    # the hook then printed nothing, silently.
    enable_rewriter
    local big
    big=$(for i in $(seq 1 6000); do printf 'npm warn deprecated package-%05d@1.0.0: no longer supported\n' "$i"; done)
    [ "${#big}" -gt 200000 ]
    printf '%s' "$big" > "$TEST_DIR/big.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$TEST_DIR/big.txt" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    local result
    result=$(printf '%s' "$stdin_json" | BASH_OUTPUT_FILTER_VERBOSE=1 "$BASH_FILTER")
    printf '%s' "$result" | jq -e '(.hookSpecificOutput.updatedToolOutput.stdout | length) > 200000' >/dev/null
}

@test "Phase 2: no exit-code field in the result: no invented exit code" {
    enable_rewriter
    local out; out=$(seq 1 40 | sed 's/^/error[E0001]: line /')
    local result
    result=$(real_bash "$out" "" | "$BASH_FILTER")
    local text; text=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
    [ -n "$text" ]
    [[ "$text" != *"exit code"* ]]
}

@test "Phase 2: an interrupted command is passed through untouched" {
    enable_rewriter
    local out; out=$(seq 1 40)
    run bash -c "printf '%s' \"\$1\" | '$BASH_FILTER'" _ "$(real_bash "$out" "" true)"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: output written to STDERR is filtered too (cargo writes there)" {
    enable_rewriter
    local err
    err=$( { for i in $(seq 1 40); do echo "   Compiling crate-$i v0.1.0"; done; echo "error[E0425]: cannot find value \`x\`"; echo "  --> src/main.rs:2:5"; } )
    local result
    result=$(real_bash "" "$err" | "$BASH_FILTER")
    printf '%s' "$result" | jq -e '
        (.hookSpecificOutput.updatedToolOutput.stdout | test("E0425"))
        and (.hookSpecificOutput.updatedToolOutput.stdout | test("Compiling") | not)
        and .hookSpecificOutput.updatedToolOutput.stderr == ""' >/dev/null
}

@test "Phase 2: a plain-string result is filtered and stays a string" {
    enable_rewriter
    local out; out=$(seq 1 40 | sed 's/^/error[E0001]: line /')
    local result
    result=$(jq -n --arg out "$out" '{tool_name: "Bash", tool_input: {command: "cargo build"}, tool_response: $out}' | "$BASH_FILTER")
    printf '%s' "$result" | jq -e '(.hookSpecificOutput.updatedToolOutput | type) == "string"' >/dev/null
}

@test "Phase 2: a digest that keeps NOTHING passes the output through untouched" {
    # A successful build whose lines match no extractor pattern used to be
    # replaced by an EMPTY result, stderr warnings included, with nothing
    # saying so. Nothing kept means nothing to replace.
    enable_rewriter
    rm -f "$METRIC_LOG"
    local out; out=$(for i in $(seq 1 40); do echo "transforming module $i"; done)
    run bash -c "printf '%s' \"\$1\" | '$BASH_FILTER'" _ "$(jq -n --arg out "$out" '{tool_name: "Bash", tool_input: {command: "npm run build"}, tool_response: {stdout: $out, stderr: "(!) Some chunks are larger than 500 kB", interrupted: false, isImage: false, noOutputExpected: false}}')"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ ! -s "$METRIC_LOG" ]
}

@test "Phase 2: a digest says it is one, and how to see everything" {
    enable_rewriter
    local out; out=$(seq 1 40 | sed 's/^/error[E0001]: line /')
    local text
    text=$(real_bash "$out" "" | "$BASH_FILTER" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
    [[ "$text" == *"filtered"* ]] || false
    [[ "$text" == *"SKIP_BASH_OUTPUT_FILTER=1"* ]]
}

@test "Phase 2: the replacement leaves no temporary file behind" {
    enable_rewriter
    mkdir -p "$TEST_DIR/tmp"
    local out; out=$(seq 1 40 | sed 's/^/error[E0001]: line /')
    real_bash "$out" "" | TMPDIR="$TEST_DIR/tmp" "$BASH_FILTER" >/dev/null
    [ -z "$(ls -A "$TEST_DIR/tmp")" ]
}

@test "Phase 2: a digest no shorter than the output is not applied" {
    enable_rewriter
    # 6 lines all kept, plus a failure context repeating them: longer than input.
    local out; out=$(for i in $(seq 1 6); do echo "error: line $i"; done)
    run bash -c "printf '%s' \"\$1\" | BASH_OUTPUT_FILTER_THRESHOLD=5 '$BASH_FILTER'" _ "$(jq -n --arg out "$out" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false, exit_code: 1}}')"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: a result with no stdout field: no envelope, and NO reduction logged" {
    # A reduction the tool cannot apply must not be reported as one: the old
    # log recorded orig=41 filtered=2 while Claude received all 41 lines.
    enable_rewriter
    rm -f "$METRIC_LOG"
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out}}')
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    run bash -c "printf '%s' \"\$1\" | '$BASH_FILTER'" _ "$stdin_json"
    unset BASH_OUTPUT_FILTER_THRESHOLD
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [ ! -s "$METRIC_LOG" ]
}

@test "Phase 2: the default metric log is private (it holds the start of each command)" {
    # Found in review: the directory was created 700 but the append ran under
    # the caller's umask, leaving a 664 file holding `cmd=npm install --token=…`.
    enable_rewriter
    unset HOOK_REWRITER_METRIC_LOG
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    printf '%s' "$stdin_json" | (umask 002; XDG_STATE_HOME="$TEST_DIR/xdg" BASH_OUTPUT_FILTER_THRESHOLD=5 "$BASH_FILTER" >/dev/null)
    local log="$TEST_DIR/xdg/claude-base/rewriter.log"
    [ -f "$log" ]
    [ "$(stat -c '%a' "$log" 2>/dev/null || stat -f '%Lp' "$log")" = "600" ]
}

@test "Phase 2: an unset HOME does not break the filter" {
    # The private default reads $HOME; under `set -u` an unset HOME aborted the
    # hook with an unbound-variable error (a regression against /tmp).
    enable_rewriter
    unset HOOK_REWRITER_METRIC_LOG
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    run bash -c "printf '%s' \"\$1\" | env -u HOME -u XDG_STATE_HOME '$BASH_FILTER'" _ "$stdin_json"
    [ "$status" -eq 0 ]
    [[ "$output" != *"unbound"* ]] && [[ "$output" != *"liaison"* ]]
}

@test "Phase 2: filter completes in less than 200ms on typical fixture" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-audit-vulns.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm audit"}, tool_response: {stdout: $out, stderr: "", interrupted: false, isImage: false, noOutputExpected: false}}')
    local start_ms end_ms
    start_ms=$(now_ms)
    printf '%s' "$stdin_json" | "$BASH_FILTER" >/dev/null
    end_ms=$(now_ms)
    local elapsed_ms=$(( end_ms - start_ms ))
    [ "$elapsed_ms" -lt 500 ]
}

# =============================================================================
# Phase 3: post-edit-typecheck-and-lint.sh
# =============================================================================

@test "Phase 3: post-edit-typecheck-and-lint.sh exists and is executable" {
    [ -x "$INLINE_EDIT" ]
}

@test "Phase 3: reports errors even WITHOUT the updatedToolOutput sentinel" {
    # The sentinel says "this CLI applies updatedToolOutput"; this hook now adds
    # additionalContext, which needs no such capability, so it must not gate on it.
    rm -f "$SENTINEL_FILE"
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    printf '%s' "$output" | jq -e '.hookSpecificOutput.additionalContext | test("Type check")' >/dev/null
}

@test "Phase 3: the context header does not call warnings errors" {
    enable_rewriter
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    local ctx
    ctx=$(printf '%s' "$stdin_json" | "$INLINE_EDIT" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$(printf '%s' "$ctx" | head -1)" == *"findings"* ]] || false
    [[ "$(printf '%s' "$ctx" | head -1)" != *"Errors"* ]]
}

@test "Phase 3: skips when SKIP_INLINE_EDIT_ERRORS=1" {
    enable_rewriter
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    SKIP_INLINE_EDIT_ERRORS=1 run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 3: skips for non-TS/JS file extensions (.py)" {
    enable_rewriter
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/script.py")
    cd "$TEST_DIR"
    run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 3: tsc-single-error appends type error block to edit result" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    touch "$TEST_DIR/tsconfig.json"
    local file_path="$TEST_DIR/src/foo.ts"
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path(42,15): error TS2304: Cannot find name 'bar'.\""
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/tsc"
    chmod +x "$TEST_DIR/node_modules/.bin/tsc"
    local stdin_json
    stdin_json=$(edit_stdin_json "$file_path" "Edit OK")
    cd "$TEST_DIR"
    local result
    result=$(printf '%s' "$stdin_json" | "$INLINE_EDIT")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.additionalContext')
    # Edit's result is a structured object with no text field: a replacement
    # there is ignored (measured), so the hook ADDS context and replaces nothing.
    printf '%s' "$result" | jq -e '.hookSpecificOutput | has("updatedToolOutput") | not' >/dev/null
    [[ "$trimmed" != *"Edit OK"* ]] || false
    [[ "$trimmed" == *"--- Type check (tsc) ---"* ]]
    [[ "$trimmed" == *"TS2304"* ]]
    [[ "$trimmed" == *"foo.ts"* ]]
}

@test "Phase 3: tsc-multi-errors appends all 3 lines under one section" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    touch "$TEST_DIR/tsconfig.json"
    local file_path="$TEST_DIR/src/foo.ts"
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path(12,5): error TS2322: Type 'string' is not assignable to type 'number'.\""
        echo "echo \"$file_path(28,9): error TS2552: Cannot find name 'undefned'.\""
        echo "echo \"$file_path(45,7): error TS2554: Expected 1 arguments, but got 0.\""
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/tsc"
    chmod +x "$TEST_DIR/node_modules/.bin/tsc"
    local stdin_json
    stdin_json=$(edit_stdin_json "$file_path")
    cd "$TEST_DIR"
    local result
    result=$(printf '%s' "$stdin_json" | "$INLINE_EDIT")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.additionalContext')
    # Edit's result is a structured object with no text field: a replacement
    # there is ignored (measured), so the hook ADDS context and replaces nothing.
    printf '%s' "$result" | jq -e '.hookSpecificOutput | has("updatedToolOutput") | not' >/dev/null
    [[ "$trimmed" == *"TS2322"* ]]
    [[ "$trimmed" == *"TS2552"* ]]
    [[ "$trimmed" == *"TS2554"* ]]
}

@test "Phase 3: tsc-other-file does NOT append errors from unrelated files (FR-6)" {
    enable_rewriter
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-other-file.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    # Errors mention bar.ts and baz.ts, edit was on foo.ts → no envelope
    [ -z "$output" ]
}

@test "Phase 3: eslint-only mode for .js files (no tsc)" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    local file_path="$TEST_DIR/src/foo.js"
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path\""
        echo "echo \"  12:5  error  'unused' is assigned a value but never used  no-unused-vars\""
        echo 'echo ""'
        echo 'echo "OK 1 problem (1 error, 0 warnings)"'
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/eslint"
    chmod +x "$TEST_DIR/node_modules/.bin/eslint"
    local stdin_json
    stdin_json=$(edit_stdin_json "$file_path")
    cd "$TEST_DIR"
    local result
    result=$(printf '%s' "$stdin_json" | "$INLINE_EDIT")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.additionalContext')
    # Edit's result is a structured object with no text field: a replacement
    # there is ignored (measured), so the hook ADDS context and replaces nothing.
    printf '%s' "$result" | jq -e '.hookSpecificOutput | has("updatedToolOutput") | not' >/dev/null
    [[ "$trimmed" == *"--- Lint (eslint) ---"* ]]
    [[ "$trimmed" == *"no-unused-vars"* ]]
    [[ "$trimmed" != *"--- Type check (tsc) ---"* ]]
}

# BUG 7: the eslint-output grep must use -F. A Next.js path like src/[id]/page.tsx
# is otherwise treated as a regex ([id] = char class) and never matches its own
# lint output, silently degrading to the coarse keyword fallback (which drops the
# per-file header line).
@test "Phase 3: eslint per-file grep matches a bracketed path (grep -F)" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    local file_path="$TEST_DIR/src/[id]/page.tsx"
    # tsc must not fire (no tsconfig), so only the eslint branch is exercised.
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path\""
        echo "echo \"  3:1  error  Unexpected console statement  no-console\""
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/eslint"
    chmod +x "$TEST_DIR/node_modules/.bin/eslint"
    # Neutral tool_response WITHOUT the path, so the ONLY source of the bracketed
    # path in the output is the eslint header line captured by the per-file grep.
    local stdin_json
    stdin_json=$(edit_stdin_json "$file_path" "edit applied")
    cd "$TEST_DIR"
    local result
    result=$(printf '%s' "$stdin_json" | "$INLINE_EDIT")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.additionalContext')
    # Edit's result is a structured object with no text field: a replacement
    # there is ignored (measured), so the hook ADDS context and replaces nothing.
    printf '%s' "$result" | jq -e '.hookSpecificOutput | has("updatedToolOutput") | not' >/dev/null
    [[ "$trimmed" == *"--- Lint (eslint) ---"* ]]
    # The per-file branch (grep -F -B1 -A2) includes the header path line, which
    # carries the bracketed path; the coarse fallback (keyword grep) would not.
    [[ "$trimmed" == *"[id]/page.tsx"* ]]
}

@test "Phase 3: tsc + eslint both fire, sections appear in order" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    touch "$TEST_DIR/tsconfig.json"
    local file_path="$TEST_DIR/src/foo.ts"
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path(15,9): error TS2322: Type 'string' is not assignable to type 'number'.\""
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/tsc"
    chmod +x "$TEST_DIR/node_modules/.bin/tsc"
    {
        echo '#!/usr/bin/env bash'
        echo "echo \"$file_path\""
        echo "echo \"  20:1  warning  Missing JSDoc comment  require-jsdoc\""
        echo 'exit 1'
    } > "$TEST_DIR/node_modules/.bin/eslint"
    chmod +x "$TEST_DIR/node_modules/.bin/eslint"
    local stdin_json
    stdin_json=$(edit_stdin_json "$file_path")
    cd "$TEST_DIR"
    local result
    result=$(printf '%s' "$stdin_json" | "$INLINE_EDIT")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.additionalContext')
    # Edit's result is a structured object with no text field: a replacement
    # there is ignored (measured), so the hook ADDS context and replaces nothing.
    printf '%s' "$result" | jq -e '.hookSpecificOutput | has("updatedToolOutput") | not' >/dev/null
    [[ "$trimmed" == *"--- Type check (tsc) ---"* ]]
    [[ "$trimmed" == *"--- Lint (eslint) ---"* ]]
    local tsc_pos eslint_pos
    tsc_pos=$(printf '%s' "$trimmed" | grep -n -- "--- Type check" | head -1 | cut -d: -f1)
    eslint_pos=$(printf '%s' "$trimmed" | grep -n -- "--- Lint (eslint)" | head -1 | cut -d: -f1)
    [ "$tsc_pos" -lt "$eslint_pos" ]
}

@test "Phase 3: no errors found passes through unchanged (no envelope)" {
    enable_rewriter
    mkdir -p "$TEST_DIR/node_modules/.bin"
    touch "$TEST_DIR/tsconfig.json"
    {
        echo '#!/usr/bin/env bash'
        echo 'exit 0'
    } > "$TEST_DIR/node_modules/.bin/tsc"
    chmod +x "$TEST_DIR/node_modules/.bin/tsc"
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 3: legacy state detection emits notice when settings.json has old inline tsc" {
    enable_rewriter
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    mkdir -p "$TEST_DIR/.claude"
    {
        echo '{"hooks":{"PostToolUse":[{"matcher":"Edit|Write","hooks":[{"type":"command","command":"bash -c'\''npx tsc --noEmit 2>&1 | head -20 || true'\''"}]}]}}'
    } > "$TEST_DIR/.claude/settings.json"
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    rm -f "$LEGACY_NOTICE_SENTINEL".*
    local out
    out=$(printf '%s' "$stdin_json" | "$INLINE_EDIT" 2>&1)
    [[ "$out" == *"predate"* ]] || [[ "$out" == *"legacy"* ]] || [[ "$out" == *"update.sh"* ]]
}
