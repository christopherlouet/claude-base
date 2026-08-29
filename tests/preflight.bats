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

# --- the reporting contract: a gate that cannot run must say so --------------
#
# Measured 2026-08-29 (specs/guardrail-cleanup/inventory.md): with a PATH
# mirroring the real one minus a single tool, preflight's output was
# INDISTINGUISHABLE from a complete run — same line per gate, exit 0, and
# "OK all fast gates passed" while one gate had not executed. Skipping is the
# intended design (the macOS runner ships no shellcheck); reporting the skip as
# a pass is not. These arms pin the contract, and the first one exists to show
# the instrument can produce a positive before any absence is believed.

# make_path <stub…> — build a PATH holding ONLY the interpreters preflight needs
# plus the named stubs, so a tool's absence is a real absence rather than a mock
# of one. Everything else installed on the machine is invisible to the run.
make_path() {
    local bin="$TEST_DIR/bin" real stub
    mkdir -p "$bin"
    for real in bash dirname sed tail cat; do
        ln -sf "$(command -v "$real")" "$bin/$real"
    done
    for stub in "$@"; do
        printf '#!/bin/sh\nexit 0\n' > "$bin/$stub"
        chmod +x "$bin/$stub"
    done
    echo "$bin"
}

# run_on_path <bin> <args…> — preflight with the two tool-independent gates
# neutralised, so only the guarded ones (shellcheck, manifest, structure) decide.
run_on_path() {
    local bin="$1"; shift
    run env PATH="$bin" \
        PREFLIGHT_GATE_COUNTS="${G_COUNTS:-true}" \
        PREFLIGHT_GATE_CONFLICTS=true \
        bash "$PF" "$@"
}

@test "preflight: control — every tool present, nothing reported as skipped" {
    bin=$(make_path shellcheck bats)
    run_on_path "$bin" --fast
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK all fast gates passed"* ]]
    [[ "$output" != *"SKIPPED"* ]]
}

@test "preflight: an absent tool is reported as SKIPPED, named, on its own line" {
    bin=$(make_path bats)   # shellcheck deliberately absent
    run_on_path "$bin" --fast
    assert_skipped shellcheck
}

@test "preflight: a run with a skipped gate does NOT claim every gate passed" {
    bin=$(make_path bats)
    run_on_path "$bin" --fast
    [[ "$output" != *"OK all fast gates passed"* ]]
    [[ "$output" == *"did not run"* ]]
}

@test "preflight: a skipped gate does not block the push (exit 0)" {
    # Deliberate: a machine lacking a tool is not blocked on it — CI's Linux job
    # is the authoritative run. The defect was the silence, not the skip.
    bin=$(make_path bats)
    run_on_path "$bin" --fast
    [ "$status" -eq 0 ]
}

# assert_skipped <gate> — the gate name and the skip notice must sit on the SAME
# line. Asserting only that the name appears somewhere is hollow: preflight
# prints a line per gate either way, which is the very defect under repair.
assert_skipped() { printf '%s\n' "$output" | grep -q "$1.*SKIPPED"; }

@test "preflight: every guarded gate skipped is named individually" {
    bin=$(make_path)   # neither shellcheck nor bats
    run_on_path "$bin" --fast
    [ "$status" -eq 0 ]
    assert_skipped shellcheck
    assert_skipped manifest
    assert_skipped structure
}

@test "preflight: a failing gate does not hide a skipped one" {
    bin=$(make_path bats)
    G_COUNTS=false run_on_path "$bin" --fast
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAILED: counts"* ]]
    assert_skipped shellcheck
    [[ "$output" == *"did not run"* ]]
}

@test "preflight: --quiet still reports a gate that did not run" {
    # A quiet run must not be able to look like a complete one.
    bin=$(make_path bats)
    run_on_path "$bin" --fast --quiet
    [ "$status" -eq 0 ]
    [[ "$output" == *"SKIPPED"* ]]
}
