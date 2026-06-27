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

# A line starting with an inert word but PIPING/CHAINING into a command is a real
# check in bats (a non-zero tail fails the test) — must not read as no-assertion.
@test "substance-check: does NOT flag a bats @test whose check is a pipeline" {
    printf '@test "pipe" {\n    run mycmd\n    echo "$output" | grep -q expected\n}\n' \
        > "$TEST_DIR/pipe.bats"
    run bash "$SC" "$TEST_DIR/pipe.bats"
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: does NOT flag a bats @test chaining with &&" {
    printf '@test "chain" {\n    cd "$dir" && [ -f result.txt ]\n}\n' \
        > "$TEST_DIR/chain.bats"
    run bash "$SC" "$TEST_DIR/chain.bats"
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

# --- Phase 2: TS/JS hollow-test scanner -------------------------------------
# Fixtures are written into $TEST_DIR (bats temp, OUTSIDE the repo tree) so they
# never reach the EF-008 self-scan. JS tests are recognized by a *.test.*/*.spec.*
# name or the presence of an it()/test() call.

@test "substance-check: flags a JS test with no assertion" {
    printf '%s\n' "import { it } from 'node:test';" \
        "it('does work', () => {" \
        "  const x = compute();" \
        "  doSomething(x);" \
        "});" > "$TEST_DIR/noassert.test.ts"
    run bash "$SC" "$TEST_DIR/noassert.test.ts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"no-assertion"* ]]
}

@test "substance-check: flags a JS test whose only assertion is always-true" {
    printf '%s\n' "it('tautology', () => {" \
        "  expect(true).toBe(true);" \
        "});" > "$TEST_DIR/taut.test.js"
    run bash "$SC" "$TEST_DIR/taut.test.js"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"always-true"* ]]
}

@test "substance-check: flags a skipped/disabled JS test" {
    printf '%s\n' "it.skip('later', () => {" \
        "  expect(foo()).toBe(1);" \
        "});" > "$TEST_DIR/skip.test.ts"
    run bash "$SC" "$TEST_DIR/skip.test.ts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"skipped"* ]]
}

@test "substance-check: flags an empty JS test body" {
    printf '%s\n' "it('todo: implement', () => {" \
        "});" > "$TEST_DIR/empty.test.ts"
    run bash "$SC" "$TEST_DIR/empty.test.ts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"empty"* ]]
}

# --- substantive JS tests are NOT flagged (CS-002) --------------------------

@test "substance-check: does NOT flag a JS test using node:test assert" {
    printf '%s\n' "import assert from 'node:assert/strict';" \
        "it('computes', () => {" \
        "  const out = fn(2);" \
        "  assert.equal(out, 4);" \
        "});" > "$TEST_DIR/real.test.ts"
    run bash "$SC" "$TEST_DIR/real.test.ts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# edge-6: not.toThrow() has no value literal but IS substantive.
@test "substance-check: does NOT flag expect().not.toThrow()" {
    printf '%s\n' "it('parses', () => {" \
        "  expect(() => parse('x')).not.toThrow();" \
        "});" > "$TEST_DIR/nothrow.test.ts"
    run bash "$SC" "$TEST_DIR/nothrow.test.ts"
    [ "$(count_findings)" -eq 0 ]
}

# edge-2: snapshot assertion is implicit in toMatchSnapshot().
@test "substance-check: does NOT flag a snapshot test" {
    printf '%s\n' "it('renders', () => {" \
        "  expect(render()).toMatchSnapshot();" \
        "});" > "$TEST_DIR/snap.test.ts"
    run bash "$SC" "$TEST_DIR/snap.test.ts"
    [ "$(count_findings)" -eq 0 ]
}

# edge-3: table-driven/parametrized — assertion lives inside it.each().
@test "substance-check: does NOT flag a table-driven it.each test" {
    printf '%s\n' "it.each([[1, 2], [2, 3]])('adds to %i', (a, b) => {" \
        "  expect(a + 1).toBe(b);" \
        "});" > "$TEST_DIR/table.test.ts"
    run bash "$SC" "$TEST_DIR/table.test.ts"
    [ "$(count_findings)" -eq 0 ]
}

# An unbalanced brace inside a string literal must not close the block early and
# hide the real assertion on a later line.
@test "substance-check: does NOT flag a JS test with a brace inside a string" {
    printf '%s\n' "it('handles a close brace in a string', () => {" \
        "  const t = \"}\";" \
        "  expect(compute(t)).toBe(42);" \
        "});" > "$TEST_DIR/brace.test.ts"
    run bash "$SC" "$TEST_DIR/brace.test.ts"
    [ "$(count_findings)" -eq 0 ]
}

# edge-8: a minified/bundled file is generated code — never scanned as a test,
# even though minified identifiers like `it(` appear in it.
@test "substance-check: does NOT scan a minified JS file (generated code)" {
    { printf 'var it=function(){};it("x",function(){});'; \
      for _ in $(seq 1 120); do printf 'var aaaaaaaaaa=1;'; done; printf '\n'; } \
        > "$TEST_DIR/bundle.min.js"
    run bash "$SC" "$TEST_DIR/bundle.min.js"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# edge-8: generated/vendored dirs (node_modules, build, dist…) are pruned.
@test "substance-check: prunes generated dirs (node_modules) when scanning a tree" {
    mkdir -p "$TEST_DIR/proj/node_modules/pkg"
    printf '%s\n' "it('lib internal', () => { doStuff(); });" \
        > "$TEST_DIR/proj/node_modules/pkg/index.test.js"
    run bash "$SC" "$TEST_DIR/proj"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# --- Phase 2: Python hollow-test scanner ------------------------------------

@test "substance-check: flags a Python test with no assertion" {
    printf '%s\n' "def test_x():" "    y = compute()" "    use(y)" \
        > "$TEST_DIR/test_noassert.py"
    run bash "$SC" "$TEST_DIR/test_noassert.py"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"no-assertion"* ]]
}

@test "substance-check: flags a Python test whose only assertion is always-true" {
    printf '%s\n' "def test_taut():" "    assert True" \
        > "$TEST_DIR/test_taut.py"
    run bash "$SC" "$TEST_DIR/test_taut.py"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"always-true"* ]]
}

@test "substance-check: flags a skipped Python test (mark.skip decorator)" {
    printf '%s\n' "@pytest.mark.skip(reason='later')" "def test_skipped():" \
        "    assert foo() == 1" > "$TEST_DIR/test_skip.py"
    run bash "$SC" "$TEST_DIR/test_skip.py"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"skipped"* ]]
}

@test "substance-check: flags an empty (pass-only) Python test" {
    printf '%s\n' "def test_todo():" "    pass" > "$TEST_DIR/test_empty.py"
    run bash "$SC" "$TEST_DIR/test_empty.py"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"empty"* ]]
}

@test "substance-check: does NOT flag a Python test with a real assert" {
    printf '%s\n' "def test_real():" "    assert add(2, 2) == 4" \
        > "$TEST_DIR/test_real.py"
    run bash "$SC" "$TEST_DIR/test_real.py"
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: does NOT flag a Python test using pytest.raises" {
    printf '%s\n' "def test_raises():" "    with pytest.raises(ValueError):" \
        "        parse('x')" > "$TEST_DIR/test_raises.py"
    run bash "$SC" "$TEST_DIR/test_raises.py"
    [ "$(count_findings)" -eq 0 ]
}

# conditional skipif is a legit env-guard (like bats skip) — NOT flagged.
@test "substance-check: does NOT flag a conditional skipif Python test" {
    printf '%s\n' "@pytest.mark.skipif(sys.platform == 'win32', reason='posix')" \
        "def test_posix():" "    assert run() == 0" > "$TEST_DIR/test_skipif.py"
    run bash "$SC" "$TEST_DIR/test_skipif.py"
    [ "$(count_findings)" -eq 0 ]
}

# --- Phase 2: Go hollow-test scanner ----------------------------------------

@test "substance-check: flags a Go test with no assertion" {
    printf '%s\n' "func TestNoAssert(t *testing.T) {" "	x := Compute()" "	_ = x" "}" \
        > "$TEST_DIR/noassert_test.go"
    run bash "$SC" "$TEST_DIR/noassert_test.go"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"no-assertion"* ]]
}

@test "substance-check: flags a skipped Go test (t.Skip)" {
    printf '%s\n' "func TestSkipped(t *testing.T) {" "	t.Skip(\"later\")" \
        "	if got != want { t.Error(\"x\") }" "}" > "$TEST_DIR/skip_test.go"
    run bash "$SC" "$TEST_DIR/skip_test.go"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"skipped"* ]]
}

@test "substance-check: flags an empty Go test body" {
    printf '%s\n' "func TestEmpty(t *testing.T) {" "}" > "$TEST_DIR/empty_test.go"
    run bash "$SC" "$TEST_DIR/empty_test.go"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"empty"* ]]
}

@test "substance-check: does NOT flag a Go test using t.Errorf" {
    printf '%s\n' "func TestReal(t *testing.T) {" "	if Add(2, 2) != 4 {" \
        "		t.Errorf(\"bad sum\")" "	}" "}" > "$TEST_DIR/real_test.go"
    run bash "$SC" "$TEST_DIR/real_test.go"
    [ "$(count_findings)" -eq 0 ]
}

@test "substance-check: does NOT flag a Go test using testify assert" {
    printf '%s\n' "func TestAssert(t *testing.T) {" "	assert.Equal(t, 4, Add(2, 2))" "}" \
        > "$TEST_DIR/assert_test.go"
    run bash "$SC" "$TEST_DIR/assert_test.go"
    [ "$(count_findings)" -eq 0 ]
}

# A brace inside a Go string/rune literal must not close the block early.
@test "substance-check: does NOT flag a Go test with a brace inside a string" {
    printf '%s\n' "func TestParse(t *testing.T) {" "	s := \"}\"" \
        "	if Parse(s) != 0 { t.Errorf(\"bad\") }" "}" > "$TEST_DIR/brace_test.go"
    run bash "$SC" "$TEST_DIR/brace_test.go"
    [ "$(count_findings)" -eq 0 ]
}

# --- Phase 3: stub scanner (delivered, non-test code) -----------------------

@test "substance-check: flags a JS not-implemented throw stub" {
    printf '%s\n' "export function getUser(id) {" \
        "  throw new Error('not implemented');" "}" > "$TEST_DIR/service.ts"
    run bash "$SC" "$TEST_DIR/service.ts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"stub"* ]]
}

@test "substance-check: flags a Python raise NotImplementedError stub" {
    printf '%s\n' "def fetch(url):" "    raise NotImplementedError" \
        > "$TEST_DIR/client.py"
    run bash "$SC" "$TEST_DIR/client.py"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"stub"* ]]
}

@test "substance-check: flags a Go panic TODO stub" {
    printf '%s\n' "func Handle(r *Request) {" "	panic(\"TODO: implement\")" "}" \
        > "$TEST_DIR/handler.go"
    run bash "$SC" "$TEST_DIR/handler.go"
    [ "$(count_findings)" -ge 1 ]
    [[ "$output" == *"stub"* ]]
}

@test "substance-check: does NOT flag a real implementation" {
    printf '%s\n' "export function add(a, b) {" "  return a + b;" "}" \
        > "$TEST_DIR/math.ts"
    run bash "$SC" "$TEST_DIR/math.ts"
    [ "$(count_findings)" -eq 0 ]
}

# edge-7: a real error throw (not a stub marker) must NOT be flagged.
@test "substance-check: does NOT flag a genuine error throw" {
    printf '%s\n' "export function load(p) {" \
        "  if (!exists(p)) throw new Error('file not found: ' + p);" \
        "  return read(p);" "}" > "$TEST_DIR/loader.ts"
    run bash "$SC" "$TEST_DIR/loader.ts"
    [ "$(count_findings)" -eq 0 ]
}

# edge-7: an inline substance:ignore opt-out suppresses the stub finding.
@test "substance-check: respects an inline substance:ignore opt-out" {
    printf '%s\n' "export function later() {" \
        "  throw new Error('not implemented'); // substance:ignore" "}" \
        > "$TEST_DIR/wip.ts"
    run bash "$SC" "$TEST_DIR/wip.ts"
    [ "$(count_findings)" -eq 0 ]
}

# Self-application (rule #413): the repo's REAL non-test source must be stub-free.
@test "substance-check: ZERO stub findings on the repo's own website/scripts" {
    run bash "$SC" --code-only "$BASE_DIR/website/scripts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# Self-application (rule #413): the repo's REAL node:test suite must be clean.
@test "substance-check: ZERO findings on the repo's own website/scripts tests" {
    run bash "$SC" "$BASE_DIR/website/scripts"
    [ "$status" -eq 0 ]
    [ "$(count_findings)" -eq 0 ]
}

# CS-006: a finding is human/agent-actionable — kind AND a non-empty hint.
@test "substance-check: a finding carries both a kind and a corrective hint" {
    printf '%s\n' "it('x', () => {" "  doStuff();" "});" > "$TEST_DIR/shape.test.ts"
    run bash "$SC" --quiet "$TEST_DIR/shape.test.ts"
    [ "$status" -eq 0 ]
    # shape: path:line: <kind>: <non-empty hint>
    [[ "$output" =~ shape\.test\.ts:[0-9]+:\ (no-assertion|always-true|skipped|empty|stub):\ [^[:space:]] ]]
}

@test "substance-check: --help exits 0" {
    run bash "$SC" --help
    [ "$status" -eq 0 ]
}

@test "substance-check: unknown flag → usage error (exit 2)" {
    run bash "$SC" --bogus
    [ "$status" -eq 2 ]
}
