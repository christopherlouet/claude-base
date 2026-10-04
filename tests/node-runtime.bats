#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/_node-runtime.sh and its use by the two test gates
# (pre-commit-tests.sh, pre-push-ci.sh). A hook inherits Claude Code's Node,
# which can be older than the project's own (mise.toml, engines.node): the gate
# then ran the suite under the wrong runtime and blocked a green project
# (seen: 1,212 tests green under Node 24, 105 workers crashing under Node 20).
#
# A stub `mise` stands in for the real one: `mise exec -- CMD` runs CMD with
# MISE_MARK=1 in its environment, and answers `node -v` with v99.0.0. The
# project's own test script checks MISE_MARK, so a pass proves the suite went
# through mise. The real npm is kept (npm itself runs on node).
# =============================================================================

load 'test_helper'

HELPER="$BATS_TEST_DIRNAME/../scripts/hooks/_node-runtime.sh"
COMMIT_HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/pre-commit-tests.sh"
PUSH_HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/pre-push-ci.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/bin"
    export MISE_AUTOINSTALL_FLAG="$TEST_DIR/autoinstall-allowed"
}
teardown() { teardown_test_dir; }

# stub_mise [fail] — a mise on PATH; with "fail", every `exec` errors out
# the way an untrusted config does.
stub_mise() {
    if [ "${1:-}" = "fail" ]; then
        printf '#!/usr/bin/env bash\necho "mise ERROR: config not trusted" >&2\nexit 1\n' > "$TEST_DIR/bin/mise"
    else
        cat > "$TEST_DIR/bin/mise" <<'EOF'
#!/usr/bin/env bash
[ "$1" = exec ] || exit 1
shift; [ "$1" = -- ] && shift
if [ "$1" = node ] && [ "${2:-}" = -v ]; then
    [ "${MISE_AUTO_INSTALL:-}" = 0 ] && [ "${MISE_EXEC_AUTO_INSTALL:-}" = 0 ] || touch "$MISE_AUTOINSTALL_FLAG"
    echo "${MISE_NODE_VERSION:-v99.0.0}"; exit 0
fi
[ "${MISE_AUTO_INSTALL:-}" = 0 ] && [ "${MISE_EXEC_AUTO_INSTALL:-}" = 0 ] || touch "$MISE_AUTOINSTALL_FLAG"
MISE_MARK=1 exec "$@"
EOF
    fi
    chmod +x "$TEST_DIR/bin/mise"
}

# mk_project <dir> <test-script> [engines-node] — package.json with a test
# script, an optional engines.node, and a mise.toml.
mk_project() {
    mkdir -p "$1"
    if [ -n "${3:-}" ]; then
        jq -n --arg t "$2" --arg e "$3" '{name:"fx",version:"1.0.0",scripts:{test:$t},engines:{node:$e}}' > "$1/package.json"
    else
        jq -n --arg t "$2" '{name:"fx",version:"1.0.0",scripts:{test:$t}}' > "$1/package.json"
    fi
    printf '[tools]\nnode = "24"\n' > "$1/mise.toml"
}

run_gate() {
    local hook="$1" dir="$2" cmd="$3" json
    json=$(jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$dir' && PATH='$TEST_DIR/bin':\"\$PATH\" bash '$hook' < '$TEST_DIR/input.json' 2>&1"
}

node_major() { node -v | sed -E 's/^v([0-9]+).*/\1/'; }

# --- the helper ----------------------------------------------------------------

@test "node-runtime: engines.node minimum major is parsed from common forms" {
    # shellcheck source=/dev/null
    . "$HELPER"
    [ "$(node_engines_min_major '>=24')" = 24 ]
    [ "$(node_engines_min_major '^20.1.0')" = 20 ]
    [ "$(node_engines_min_major '18.x')" = 18 ]
    [ "$(node_engines_min_major '>=18 <21')" = 18 ]
    [ "$(node_engines_min_major '~22.3')" = 22 ]
    [ "$(node_engines_min_major ' >= v16 ')" = 16 ]
    [ -z "$(node_engines_min_major '*')" ]
    [ -z "$(node_engines_min_major 'lts/*')" ]
    [ -z "$(node_engines_min_major '')" ]
    # An alternation's first number is not its minimum: never guess.
    [ -z "$(node_engines_min_major '>=22 || ^18.19')" ]
    [ -z "$(node_engines_min_major '^18 || >=20')" ]
}

@test "node-runtime: mise is never allowed to auto-install a tool (probe or run)" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]'
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
    [ ! -e "$MISE_AUTOINSTALL_FLAG" ]
}

@test "node-runtime: the skip reason names mise's Node when mise's own Node is too old" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise
    mk_project "$TEST_DIR/proj" 'exit 1' ">=100"
    MISE_NODE_VERSION=v99.0.0 run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
    [[ "$output" == *"skipped"* ]]
    [[ "$output" == *"mise"*"99"* ]]
    [[ "$output" != *"finds no project runtime"* ]]
}

# --- pre-commit-tests ----------------------------------------------------------

@test "pre-commit-tests: with a mise config, the suite runs through mise" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]'
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
}

@test "pre-commit-tests: control — the same suite outside mise fails and blocks" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]'
    rm "$TEST_DIR/proj/mise.toml"
    stub_mise
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 2 ]
}

@test "pre-commit-tests: mise that refuses (untrusted config) falls back to the shell's Node" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise fail
    mk_project "$TEST_DIR/proj" 'exit 0'
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
    [[ "$output" == *"mise"* ]]
}

@test "pre-commit-tests: engines.node above the Node it can run → skips with the reason, never blocks" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    need=$(( $(node_major) + 1 ))
    mk_project "$TEST_DIR/proj" 'exit 1' ">=$need"
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
    [[ "$output" == *"skipped"* ]]
    [[ "$output" == *">=$need"* ]]
    [[ "$output" != *"Running tests"* ]]
}

@test "pre-commit-tests: engines.node satisfied → the suite still runs and still blocks when red" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_project "$TEST_DIR/proj" 'exit 1' ">=$(node_major)"
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 2 ]
}

@test "pre-commit-tests: mise's own Node satisfies engines.node that the shell's does not" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]' ">=$(( $(node_major) + 1 ))"
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 0 ]
    [[ "$output" != *"skipped"* ]]
}

# --- pre-push-ci ---------------------------------------------------------------

@test "pre-push-ci: with a mise config, the suite runs through mise" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    stub_mise
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]'
    run_gate "$PUSH_HOOK" "$TEST_DIR/proj" 'git push'
    [ "$status" -eq 0 ]
}

@test "pre-push-ci: control — the same suite outside mise fails and blocks" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_project "$TEST_DIR/proj" '[ "$MISE_MARK" = 1 ]'
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$PUSH_HOOK" "$TEST_DIR/proj" 'git push'
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: engines.node above the Node it can run → skips the npm checks, never blocks" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    need=$(( $(node_major) + 1 ))
    mk_project "$TEST_DIR/proj" 'exit 1' ">=$need"
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$PUSH_HOOK" "$TEST_DIR/proj" 'git push'
    [ "$status" -eq 0 ]
    [[ "$output" == *"skipped"* ]]
}

@test "pre-push-ci: the bypass hint says where the variable must be set" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_project "$TEST_DIR/proj" 'exit 1'
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$PUSH_HOOK" "$TEST_DIR/proj" 'git push'
    [ "$status" -eq 2 ]
    [[ "$output" == *"SKIP_PRE_PUSH_CI=1"* ]]
    [[ "$output" == *"environment"* ]]
}

@test "pre-commit-tests: the bypass hint says where the variable must be set" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_project "$TEST_DIR/proj" 'exit 1'
    rm "$TEST_DIR/proj/mise.toml"
    run_gate "$COMMIT_HOOK" "$TEST_DIR/proj" 'git commit -m wip'
    [ "$status" -eq 2 ]
    [[ "$output" == *"SKIP_PRE_COMMIT_TESTS=1"* ]]
    [[ "$output" == *"environment"* ]]
}

# --- self-application: the helper on the real foundation ----------------------

@test "node-runtime: on the real foundation (root and website/) the npm checks are not skipped" {
    # shellcheck source=/dev/null
    . "$HELPER"
    for d in "$BATS_TEST_DIRNAME/.." "$BATS_TEST_DIRNAME/../website"; do
        run bash -c "cd '$d' && . '$HELPER' && node_runtime_select self && echo \"prefix=[\${NODE_RUN[*]-}]\""
        [ "$status" -eq 0 ]
        [[ "$output" == *"prefix=["* ]]
        [[ "$output" != *"skipped"* ]]
    done
}
