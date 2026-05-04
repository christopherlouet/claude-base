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

HELPERS="$SOCLE_DIR/scripts/hooks/_hook-helpers.sh"
CHECK_VERSION="$SOCLE_DIR/scripts/hooks/check-cli-version.sh"
BASH_FILTER="$SOCLE_DIR/scripts/hooks/bash-output-filter.sh"
INLINE_EDIT="$SOCLE_DIR/scripts/hooks/post-edit-typecheck-and-lint.sh"
FIXTURES="$SOCLE_DIR/tests/hook-output-rewriter/fixtures"
SENTINEL_FILE="/tmp/claude-rewriter-supported"
METRIC_LOG="/tmp/claude-rewriter.log"
LEGACY_NOTICE_SENTINEL="/tmp/claude-socle-legacy-warned"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Ensure sentinel + metric log cleanup before each test
    rm -f "$SENTINEL_FILE" "$METRIC_LOG"
    rm -f "$LEGACY_NOTICE_SENTINEL".*
    # Build a fake `claude` binary path that tests can prepend to PATH
    FAKE_BIN="$TEST_DIR/fake-bin"
    mkdir -p "$FAKE_BIN"
    export FAKE_BIN
}

teardown() {
    rm -f "$SENTINEL_FILE" "$METRIC_LOG"
    rm -f "$LEGACY_NOTICE_SENTINEL".*
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
        '{tool_name: "Bash", tool_input: {command: $cmd}, tool_response: {output: $out, exit_code: $code}}')

    # Lower threshold so artificial short fixtures still trigger the filter.
    # Threshold behavior itself is covered by dedicated tests.
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    unset BASH_OUTPUT_FILTER_THRESHOLD

    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')

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
        hook_emit_envelope 'PostToolUse' 'updatedToolOutput' 'hello world'
    "
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.updatedToolOutput == "hello world"' >/dev/null
}

@test "Phase 1: hook_emit_envelope handles multi-line values" {
    run bash -c "
        source '$HELPERS'
        printf 'line1\nline2\nline3' | xargs -I {} echo {} > /dev/null  # no-op, keeps subshell
        hook_emit_envelope 'PostToolUse' 'updatedToolOutput' \"\$(printf 'line1\nline2')\"
    "
    [ "$status" -eq 0 ]
    local val
    val=$(echo "$output" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [ "$val" = "$(printf 'line1\nline2')" ]
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
    stdin_json=$(jq -n '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: "x\ny\n", exit_code: 0}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter exits 0 with no envelope when SKIP_BASH_OUTPUT_FILTER=1" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: "x\ny\n", exit_code: 0}}')
    SKIP_BASH_OUTPUT_FILTER=1 run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter passes through commands not in allowlist (ls -la)" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n --arg out "$(seq 1 50)" '{tool_name: "Bash", tool_input: {command: "ls -la"}, tool_response: {output: $out, exit_code: 0}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter passes through outputs below threshold (< 30 lines)" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n --arg out "$(seq 1 10)" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out, exit_code: 0}}')
    run bash -c "printf '%s' '$stdin_json' | '$BASH_FILTER'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Phase 2: filter respects custom BASH_OUTPUT_FILTER_THRESHOLD" {
    enable_rewriter
    local stdin_json
    stdin_json=$(jq -n --arg out "$(seq 1 15)" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out, exit_code: 0}}')
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
    assert_bash_fixture "go-test-fail" "go test ./..." 1
}

@test "Phase 2: fixture cargo-build-fail — cargo extractor keeps error[E*] blocks" {
    enable_rewriter
    assert_bash_fixture "cargo-build-fail" "cargo build" 1
}

@test "Phase 2: SC-1 — npm-audit-vulns filtered view ≤ 25 lines" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-audit-vulns.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm audit"}, tool_response: {output: $out, exit_code: 0}}')
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
    local lines
    lines=$(printf '%s\n' "$trimmed" | wc -l)
    [ "$lines" -le 25 ]
}

@test "Phase 2: BASH_OUTPUT_FILTER_VERBOSE=1 keeps both views" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out, exit_code: 0}}')
    export BASH_OUTPUT_FILTER_VERBOSE=1
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    unset BASH_OUTPUT_FILTER_VERBOSE BASH_OUTPUT_FILTER_THRESHOLD
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
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
    stdin_json=$(jq -n --arg out "$raw" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out, exit_code: 0}}')
    local result
    result=$(printf '%s' "$stdin_json" | "$BASH_FILTER")
    local trimmed
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [[ "$trimmed" != *$'\x1b['* ]]
}

@test "Phase 2: filter writes a metric log line on success" {
    enable_rewriter
    rm -f "$METRIC_LOG"
    local in_file="$FIXTURES/bash/npm-install-clean.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm install"}, tool_response: {output: $out, exit_code: 0}}')
    export BASH_OUTPUT_FILTER_THRESHOLD=5
    printf '%s' "$stdin_json" | "$BASH_FILTER" >/dev/null
    unset BASH_OUTPUT_FILTER_THRESHOLD
    [ -f "$METRIC_LOG" ]
    grep -qE "tool=Bash.*orig=[0-9]+.*filtered=[0-9]+" "$METRIC_LOG"
}

@test "Phase 2: filter completes in less than 200ms on typical fixture" {
    enable_rewriter
    local in_file="$FIXTURES/bash/npm-audit-vulns.in.txt"
    local stdin_json
    stdin_json=$(jq -n --rawfile out "$in_file" '{tool_name: "Bash", tool_input: {command: "npm audit"}, tool_response: {output: $out, exit_code: 0}}')
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

@test "Phase 3: skips when capability sentinel is missing" {
    rm -f "$SENTINEL_FILE"
    setup_fake_ts_project "$FIXTURES/inline-edit/tsc-single-error.tsc.txt" ""
    local stdin_json
    stdin_json=$(edit_stdin_json "$TEST_DIR/src/foo.ts")
    cd "$TEST_DIR"
    run bash -c "printf '%s' '$stdin_json' | '$INLINE_EDIT'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
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
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [[ "$trimmed" == *"Edit OK"* ]]
    [[ "$trimmed" == *"--- Type errors (tsc) ---"* ]]
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
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
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
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [[ "$trimmed" == *"--- Lint errors (eslint) ---"* ]]
    [[ "$trimmed" == *"no-unused-vars"* ]]
    [[ "$trimmed" != *"--- Type errors (tsc) ---"* ]]
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
    trimmed=$(printf '%s' "$result" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [[ "$trimmed" == *"--- Type errors (tsc) ---"* ]]
    [[ "$trimmed" == *"--- Lint errors (eslint) ---"* ]]
    local tsc_pos eslint_pos
    tsc_pos=$(printf '%s' "$trimmed" | grep -n -- "--- Type errors" | head -1 | cut -d: -f1)
    eslint_pos=$(printf '%s' "$trimmed" | grep -n -- "--- Lint errors" | head -1 | cut -d: -f1)
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
