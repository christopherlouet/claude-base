#!/usr/bin/env bats

# =============================================================================
# Wall-clock budgets on the foundation's hot paths.
#
# Why this file exists — the #491 story. The select-then-emit installer refactor
# (v5.3.0) made a `--simple` install 12x slower (2.2s -> 26.5s) and the local
# bats suite 16x slower (~46s -> 12min40). It shipped GREEN: it was validated on
# "all 1787 tests still pass", and nothing in the suite measured cost. The
# regression then lived undetected for weeks, taxing every test run.
#
# Correctness tests cannot catch that class: the installer kept producing a
# byte-identical manifest the whole time. Only a clock can.
#
# Scope and honesty about it: a wall-clock assertion inside a parallel suite
# cannot be tight without flaking, so these budgets catch ORDER-OF-MAGNITUDE
# regressions — the #491 class — not a 2x drift. Tighter, contention-immune
# guards belong next to their unit (see the compute_selected_set budget in
# tests/modules.bats).
#
# When a budget fails, do NOT raise the number to make it green. Profile first;
# the number is the alarm, not the problem.
# =============================================================================

load 'test_helper'

REPO_ROOT="$BATS_TEST_DIRNAME/.."
NEW_PROJECT_SCRIPT="$REPO_ROOT/scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# elapsed_ms <start> <end> — EPOCHREALTIME honours LC_NUMERIC, and a comma
# decimal separator (fr_FR and friends) makes awk truncate to whole seconds.
# Forcing LC_ALL=C here is what keeps the measurement meaningful off en_US.
elapsed_ms() {
    LC_ALL=C awk -v a="$1" -v b="$2" 'BEGIN{printf "%d", (b-a)*1000}'
}

@test "perf: a --simple install stays under budget (the #491 guard)" {
    # Budget rationale, measured on the reference machine at the time of
    # writing: ~2.3s solo, ~1.2s under 8-way contention (concurrent installs
    # warm the page cache, so parallelism does not hurt here). 15s leaves a CI
    # runner roughly 6x headroom while still catching the 26.5s regression that
    # prompted this file.
    local budget=15000 t0 t1 ms
    t0=$EPOCHREALTIME
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/proj"
    t1=$EPOCHREALTIME
    ms=$(elapsed_ms "$t0" "$t1")

    # The install must have actually happened. Without this, a fast FAILURE —
    # the installer dying in 50ms — would sail under the budget and the guard
    # would report success while measuring nothing.
    [ "$status" -eq 0 ]
    local files
    files=$(find "$TEST_DIR/proj" -type f | wc -l)
    echo "install: ${ms}ms, ${files} files (budget ${budget}ms)"
    [ "$files" -gt 200 ]

    [ "$ms" -lt "$budget" ]
}

@test "perf: a --minimal install stays under budget" {
    # Guards the minimal manifest path, which ships separately (export-minimal)
    # and could regress on its own.
    #
    # Known limit, measured rather than assumed: under #491 this path went
    # 0.33s -> 1.52s, a 4.6x regression this budget does NOT catch. Catching it
    # would need ~1s, i.e. 3x headroom over the current 0.33s — too tight for a
    # slow runner. So this is a gross-regression smoke guard; the full-install
    # budget above is the one that holds the #491 class.
    local budget=5000 t0 t1 ms
    t0=$EPOCHREALTIME
    run "$NEW_PROJECT_SCRIPT" -y --minimal "$TEST_DIR/mini"
    t1=$EPOCHREALTIME
    ms=$(elapsed_ms "$t0" "$t1")

    [ "$status" -eq 0 ]
    local files
    files=$(find "$TEST_DIR/mini" -type f | wc -l)
    echo "minimal install: ${ms}ms, ${files} files (budget ${budget}ms)"
    [ "$files" -gt 10 ]

    [ "$ms" -lt "$budget" ]
}
