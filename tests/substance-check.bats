#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/substance-check.sh — the static substance gate (anti-hollow-
# test / anti-stub). Advisory, deterministic, offline. A finding is printed to
# stdout as `path:line: <kind>: <hint>` (kinds: no-assertion | always-true |
# skipped | empty | stub); exit is ALWAYS 0 in advisory mode (usage error = 2).
#
# Phase 1 pins the make-or-break constraint (EF-008): scanning the foundation's
# OWN bats suite must yield ZERO findings — while a genuinely hollow @test is
# still flagged (so the scanner isn't trivially empty).
# =============================================================================

load 'test_helper'

SC="$BASE_DIR/scripts/substance-check.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# count_findings — number of finding lines in $output.
count_findings() { printf '%s\n' "$output" | grep -cE ': (no-assertion|always-true|skipped|empty|stub):' || true; }

# --- EF-008: zero false positives on our own suite --------------------------

@test "substance-check: ZERO findings on the foundation's own tests/ (EF-008)" {
    run bash "$SC" "$BASE_DIR/tests"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: ZERO findings on the foundation's own scripts/ (no stubs)" {
    run bash "$SC" --code-only "$BASE_DIR/scripts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# --- the scanner is NOT trivially empty: a hollow @test IS flagged -----------

@test "substance-check: flags a bats @test with no assertion" {
    printf '@test "does nothing" {\n    run echo hi\n}\n' > "$TEST_DIR/hollow.bats"
    run bash "$SC" "$TEST_DIR/hollow.bats"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"no-assertion"* ]]
}

# v1 does NOT flag bats `skip`: it is overwhelmingly a legitimate conditional
# env-guard in real suites (skip_if_no_jq, "skip if root"). Flagging it would
# break EF-008. Genuine disables are caught for JS/Py/Go in Phase 2.
@test "substance-check: does NOT flag a bats @test that uses skip (env-guard)" {
    printf '@test "guarded" {\n    skip_if_no_jq\n    jq . file.json\n}\n' > "$TEST_DIR/skip.bats"
    run bash "$SC" "$TEST_DIR/skip.bats"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# --- a substantive bats @test is NOT flagged --------------------------------

@test "substance-check: does NOT flag a bats @test with a real status assertion" {
    printf '@test "checks exit code" {\n    run true\n    [ "$status" -eq 0 ]\n}\n' > "$TEST_DIR/ok.bats"
    run bash "$SC" "$TEST_DIR/ok.bats"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: does NOT flag a bats @test using assert_* helpers" {
    printf '@test "uses assert" {\n    run my_cmd\n    assert_success\n    assert_output --partial "ok"\n}\n' > "$TEST_DIR/assert.bats"
    run bash "$SC" "$TEST_DIR/assert.bats"
    [ "$(count_findings)" -eq 0 ]
}

# --- fail-safe + CLI ---------------------------------------------------------

@test "substance-check: unknown/unsupported file → no finding (fail-safe)" {
    echo "just some prose" > "$TEST_DIR/notes.md"
    run bash "$SC" "$TEST_DIR/notes.md"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: a non-test shell file is not scanned as tests" {
    printf '#!/usr/bin/env bash\necho hi\n' > "$TEST_DIR/helper.sh"
    run bash "$SC" "$TEST_DIR/helper.sh"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: --help exits 0" {
    run bash "$SC" --help
    [ "$status" -eq 0 ]
}

@test "substance-check: unknown flag → usage error (exit 2)" {
    run bash "$SC" --bogus
    [ "$status" -eq 2 ]
}
