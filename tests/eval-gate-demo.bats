#!/usr/bin/env bats

# Tests for eval/value-proof/gate-demo/demo.sh — the deterministic-gates proof
# matrix. Runs the real gates against planted violations + clean controls and
# asserts every row passes (gate catches the violation AND spares the clean case).

load 'test_helper'

DEMO="$BATS_TEST_DIRNAME/../eval/value-proof/gate-demo/demo.sh"

@test "every deterministic gate catches its violation and spares the clean control" {
    run bash "$DEMO"
    [ "$status" -eq 0 ]
    [[ "$output" == *"0 failed"* ]]
    [[ "$output" == *"commit gate-bypass flag"* ]]
    [[ "$output" == *"hollow test (no assertion)"* ]]
}
