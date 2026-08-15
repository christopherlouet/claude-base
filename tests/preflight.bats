#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/preflight.sh — the local mirror of CI's foundation gates,
# run by .husky/pre-push so local catches what CI catches (shellcheck, counts,
# manifest drift) BEFORE a push instead of after. Each gate command is overridable
# via env (PREFLIGHT_GATE_*) so these tests inject fakes; one integration test
# runs the REAL fast gates against the repo (green on a clean checkout).
# =============================================================================

load 'test_helper'

PF="$BASE_DIR/scripts/preflight.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# run_pf <args…> — run preflight with all fast gates overridden to no-ops unless
# the caller set one to fail.
run_pf() {
    run env \
        PREFLIGHT_GATE_SHELLCHECK="${G_SHELLCHECK:-true}" \
        PREFLIGHT_GATE_COUNTS="${G_COUNTS:-true}" \
        PREFLIGHT_GATE_MANIFEST="${G_MANIFEST:-true}" \
        PREFLIGHT_GATE_STRUCTURE="${G_STRUCTURE:-true}" \
        PREFLIGHT_GATE_FULL="${G_FULL:-true}" \
        bash "$PF" "$@"
}

@test "preflight: all fast gates pass → exit 0" {
    run_pf
    [ "$status" -eq 0 ]
}

@test "preflight: a failing gate → exit 1, names the gate" {
    G_COUNTS=false run_pf
    [ "$status" -eq 1 ]
    [[ "$output" == *"counts"* ]]
}

@test "preflight: shellcheck gate failure → exit 1" {
    G_SHELLCHECK=false run_pf
    [ "$status" -eq 1 ]
}

@test "preflight: manifest gate failure → exit 1" {
    G_MANIFEST=false run_pf
    [ "$status" -eq 1 ]
}

@test "preflight: structure gate failure → exit 1, names the gate" {
    G_STRUCTURE=false run_pf
    [ "$status" -eq 1 ]
    [[ "$output" == *"structure"* ]]
}

@test "preflight: --fast DOES run the structure gate" {
    # The point of putting policy-structure in --fast: a hook added without its
    # portability-map row used to pass --fast and fail only in the full suite,
    # costing a push/CI round-trip. Defining the gate is not enough — pin that
    # the FAST set actually runs it.
    G_STRUCTURE="touch $TEST_DIR/struct_ran" run_pf --fast
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/struct_ran" ]
}

@test "preflight: --fast does NOT run the full (slow) bats gate" {
    # the full gate writes a marker; --fast must not trigger it
    G_FULL="touch $TEST_DIR/full_ran" run_pf --fast
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/full_ran" ]
}

@test "preflight: --full runs the full bats gate" {
    G_FULL="touch $TEST_DIR/full_ran" run_pf --full
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/full_ran" ]
}

@test "preflight: SKIP_PREFLIGHT=1 skips all gates → exit 0" {
    G_COUNTS=false run env SKIP_PREFLIGHT=1 \
        PREFLIGHT_GATE_SHELLCHECK=true PREFLIGHT_GATE_COUNTS=false \
        PREFLIGHT_GATE_MANIFEST=true PREFLIGHT_GATE_STRUCTURE=true PREFLIGHT_GATE_FULL=true \
        bash "$PF"
    [ "$status" -eq 0 ]
}

@test "preflight: unknown flag → exit 2" {
    run_pf --bogus
    [ "$status" -eq 2 ]
}

# --- integration: the REAL fast gates pass on a clean checkout ---------------

@test "preflight: real --fast gates pass on the repo (integration)" {
    run bash "$PF" --fast
    [ "$status" -eq 0 ]
}
