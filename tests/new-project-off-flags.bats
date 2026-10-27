#!/usr/bin/env bats

# =============================================================================
# Tests for the --no-ci / --no-hooks / --no-mcp / --no-docker flags (#655).
#
# A preset's `defaults` used to be OR-ed in: nothing could switch an option it
# turns on back off. An explicit --no-* now wins over a preset default and
# over --all, in either order, on the -y, --simple and interactive paths.
# Every "off" test is paired with a control that installs the same option
# without the flag, so a fixture that never installs it cannot pass silently.
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    PRESET_DIR="$TEST_DIR/synthetic-presets"
    mkdir -p "$PRESET_DIR"
    # Every default on: the preset alone would install all four options.
    cat > "$PRESET_DIR/all-on.json" << 'EOF'
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "all-on",
  "displayName": "Synthetic all-on",
  "description": "Synthetic preset for testing --no-* flags: turns every option on.",
  "version": "1.0.0",
  "status": "community",
  "appliesToTypes": ["node-api"],
  "detect": {"combinator": "anyOf", "files": ["all-on.marker"]},
  "foundation": {"skills": {"keep": ["dev-tdd"]}},
  "marketplacePlugins": [],
  "recommendedVendorSkills": [],
  "defaults": {"ci": true, "hooks": true, "mcp": true, "docker": true}
}
EOF
}

teardown() {
    teardown_test_dir
}

# Arguments: project dir, then the flags to pass after --preset all-on.
init_all_on() {
    local proj="$1"; shift
    run "$NEW_PROJECT" -y --preset all-on --presets-dir "$PRESET_DIR" "$@" "$proj"
}

@test "off-flags: control - the all-on preset installs every option without a --no-* flag" {
    local proj="$TEST_DIR/control"
    init_all_on "$proj"
    [ "$status" -eq 0 ]
    [ -d "$proj/.husky" ]
    [ -d "$proj/.github/workflows" ]
    [ -f "$proj/.mcp.json" ]
    [ -f "$proj/Dockerfile" ]
}

@test "off-flags: --no-hooks wins over a preset default and leaves the other options on" {
    local proj="$TEST_DIR/no-hooks"
    init_all_on "$proj" --no-hooks
    [ "$status" -eq 0 ]
    [ ! -e "$proj/.husky" ]
    [ ! -e "$proj/.commitlintrc.json" ]
    [[ "$output" != *"Installing pre-commit hooks"* ]] || false
    [ -d "$proj/.github/workflows" ]
}

@test "off-flags: --no-ci wins over a preset default" {
    local proj="$TEST_DIR/no-ci"
    init_all_on "$proj" --no-ci
    [ "$status" -eq 0 ]
    [ ! -e "$proj/.github/workflows" ]
    [ -d "$proj/.husky" ]
}

@test "off-flags: --no-mcp and --no-docker win over preset defaults" {
    local proj="$TEST_DIR/no-mcp-docker"
    init_all_on "$proj" --no-mcp --no-docker
    [ "$status" -eq 0 ]
    [ ! -e "$proj/.mcp.json" ]
    [ ! -e "$proj/Dockerfile" ]
    [ -d "$proj/.husky" ]
}

@test "off-flags: --simple honours --no-hooks and --no-ci" {
    local proj="$TEST_DIR/simple"
    init_all_on "$proj" --simple --no-hooks --no-ci
    [ "$status" -eq 0 ]
    [ ! -e "$proj/.husky" ]
    [ ! -e "$proj/.github/workflows" ]
    [ -f "$proj/.mcp.json" ]
}

@test "off-flags: --no-docker wins over --all, whichever comes first" {
    local before="$TEST_DIR/before" after="$TEST_DIR/after"
    run "$NEW_PROJECT" -y -t node-api --no-docker --all "$before"
    [ "$status" -eq 0 ]
    [ ! -e "$before/Dockerfile" ]
    [ -d "$before/.husky" ]
    run "$NEW_PROJECT" -y -t node-api --all --no-docker "$after"
    [ "$status" -eq 0 ]
    [ ! -e "$after/Dockerfile" ]
    [ -d "$after/.husky" ]
}

@test "off-flags: an option and its --no-* together are refused" {
    run "$NEW_PROJECT" -y --hooks --no-hooks "$TEST_DIR/both"
    [ "$status" -ne 0 ]
    [[ "$output" == *"--hooks"*"--no-hooks"* ]] || false
    [ ! -e "$TEST_DIR/both/.claude" ]
    run "$NEW_PROJECT" -y --no-ci --ci "$TEST_DIR/both"
    [ "$status" -ne 0 ]
}

@test "off-flags: --no-ci with --ci-existing is refused" {
    run "$NEW_PROJECT" -y --no-ci --ci-existing merge "$TEST_DIR/both"
    [ "$status" -ne 0 ]
    [[ "$output" == *"--ci-existing"* ]] || false
}

@test "off-flags: --no-ci on a project with CI leaves its workflows untouched" {
    local proj="$TEST_DIR/has-ci"
    mkdir -p "$proj/.github/workflows"
    echo "name: own" > "$proj/.github/workflows/own.yml"
    init_all_on "$proj" --no-ci
    [ "$status" -eq 0 ]
    [ "$(ls "$proj/.github/workflows")" = "own.yml" ]
}

# interactive_options <answers> <flags...> — parse the flags, run the interactive
# get_options on <answers>, and print the prompts followed by a STATE line.
# EXISTING=false switches to the new-project wording ("Include …?").
interactive_options() {
    local answers="$1"; shift
    local proj="$TEST_DIR/interactive"
    mkdir -p "$proj"
    run env BASE_DIR="$BASE_DIR" proj="$proj" answers="$answers" existing="${EXISTING:-true}" bash -c '
        source "$BASE_DIR/scripts/new-project.sh"
        parse_args "${@}" "$proj"
        PROJECT_PATH="$proj"; PROJECT_TYPE="node-api"; EXISTING_PROJECT="$existing"
        get_options <<< "$answers" 2>&1
        echo "HOOKS=$INCLUDE_HOOKS CI=$INCLUDE_CICD MCP=$INCLUDE_MCP DOCKER=$INCLUDE_DOCKER"
    ' _ "$@"
}

@test "off-flags: interactive options skip the prompt of an option turned off" {
    # Four 'y' answers would turn every option on; --no-hooks must consume none.
    interactive_options "yyyy" --no-hooks
    [ "$status" -eq 0 ]
    [[ "$output" == *"HOOKS=false CI=true MCP=true DOCKER=true"* ]] || false
    [[ "$output" == *"left out (--no-hooks)"* ]] || false
    [[ "$output" != *"pre-commit hooks (husky)?"* ]]
}

@test "off-flags: control - interactive answers turn each option on or off" {
    interactive_options "yyyy"
    [ "$status" -eq 0 ]
    [[ "$output" == *"HOOKS=true CI=true MCP=true DOCKER=true"* ]] || false
    interactive_options "nnnn"
    [ "$status" -eq 0 ]
    [[ "$output" == *"HOOKS=false CI=false MCP=false DOCKER=false"* ]] || false
    [[ "$output" == *"pre-commit hooks (husky)?"* ]] || false
}

@test "off-flags: interactive options do not ask what --all already decided (#664)" {
    # The old prompts asked, then ignored an 'n'. Four 'n' must change nothing.
    local existing
    for existing in true false; do
        EXISTING=$existing interactive_options "nnnn" --all
        [ "$status" -eq 0 ]
        [[ "$output" == *"HOOKS=true CI=true MCP=true DOCKER=true"* ]] || false
        [[ "$output" != *"(CI/CD)?"* && "$output" != *"(husky)?"* ]] || false
        [[ "$output" != *"MCP configuration?"* && "$output" != *"Dockerfile?"* ]] || false
        [ "$(grep -c 'included (--all)' <<< "$output")" -eq 4 ]
    done
}

@test "off-flags: control - the new-project wording is asked without a flag" {
    EXISTING=false interactive_options "nnnn"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Include GitHub Actions (CI/CD)?"* ]] || false
    [[ "$output" == *"Include pre-commit hooks (husky)?"* ]] || false
    [[ "$output" == *"Include Dockerfile?"* ]]
}

@test "off-flags: a single flag skips only its own prompt" {
    # --hooks decided; the three remaining answers go to CI, MCP, Docker.
    interactive_options "nyn" --hooks
    [ "$status" -eq 0 ]
    [[ "$output" == *"HOOKS=true CI=false MCP=true DOCKER=false"* ]] || false
    [[ "$output" != *"(husky)?"* ]] || false
    [[ "$output" == *"Pre-commit hooks included (--hooks)"* ]] || false
    [[ "$output" == *"(CI/CD)?"* ]]
}

@test "off-flags: --all with a --no-* flag asks nothing for either" {
    interactive_options "" --all --no-docker
    [ "$status" -eq 0 ]
    [[ "$output" == *"HOOKS=true CI=true MCP=true DOCKER=false"* ]] || false
    [[ "$output" != *"?"* ]]
}

@test "off-flags: --help documents the four --no-* flags" {
    run "$NEW_PROJECT" --help
    [ "$status" -eq 0 ]
    local f
    for f in --no-ci --no-hooks --no-mcp --no-docker; do
        [[ "$output" == *"$f"* ]] || false
    done
}
