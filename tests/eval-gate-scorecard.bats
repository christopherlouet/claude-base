#!/usr/bin/env bats

# Tests for eval/gate-scorecard/scorecard.sh — scores a produced project against
# the artifact-scorable gates so a bare-Claude output and a claude-base output can
# be compared on the same task. Offline, deterministic. (Fixture secret is
# assembled at runtime so no literal trips the secret gate / push protection.)

load 'test_helper'

SC="$BATS_TEST_DIRNAME/../eval/gate-scorecard/scorecard.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

@test "usage error without a project dir" {
    run bash "$SC"
    [ "$status" -eq 2 ]
}

@test "a careless project trips every offline gate" {
    mkdir -p "$TEST_DIR/p"
    local pre="sk_live_"
    printf 'const K = "%s%s";\nfunction charge(){ debugger; /* TODO */ }\n' "$pre" "4eC39HqLyjWDarjtT1zdp7dcKLMNOPQR" > "$TEST_DIR/p/pay.js"
    printf 'describe("x", () => { it.only("t", () => { const a = 1; }); });\n' > "$TEST_DIR/p/pay.test.js"
    printf '%s\n' "DROP TABLE legacy;" > "$TEST_DIR/p/0002_x.sql"
    printf 'API_TOKEN=supersecretvalue123\n' > "$TEST_DIR/p/.env"
    run bash "$SC" "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Gates tripped: 6 / 6 scored"* ]]
}

@test "a clean project trips no gate" {
    mkdir -p "$TEST_DIR/c/tests"
    printf 'const k = process.env.K;\nexport function add(a, b) { return a + b; }\n' > "$TEST_DIR/c/add.js"
    printf 'import { add } from "./add";\nimport { expect, it } from "vitest";\nit("a", () => { expect(add(1, 2)).toBe(3); });\n' > "$TEST_DIR/c/tests/add.test.js"
    printf 'API_TOKEN=your-token-here\n' > "$TEST_DIR/c/.env.example"
    run bash "$SC" "$TEST_DIR/c"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Gates tripped: 0 / 6 scored"* ]]
}

@test "toolchain gates SKIP when the project has no installed toolchain" {
    mkdir -p "$TEST_DIR/q"
    printf 'export const x = 1;\n' > "$TEST_DIR/q/a.ts"
    run bash "$SC" "$TEST_DIR/q"
    [[ "$output" == *"SKIP (no toolchain)"* ]]
}
