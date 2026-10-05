#!/usr/bin/env bats

# =============================================================================
# Tests for eval/rule-efficacy/run.sh — the GENERATION half of the rule-efficacy
# eval. No LLM is called: GEN_CMD is a fake generator that records the project
# it was handed (every file path) into tree.txt, so each arm's contents can be
# asserted directly.
#
# What is pinned here:
#   - control removes the task's RULE files, treatment keeps them;
#   - a task FIXTURE/ is copied into BOTH arms (a pre-existing project to work in);
#   - a task CANDIDATE/ is added to the TREATMENT arm only (a rule being
#     evaluated for promotion, which is not in the repo yet).
# =============================================================================

load 'test_helper'

RUN="$BATS_TEST_DIRNAME/../eval/rule-efficacy/run.sh"

setup() {
    setup_test_dir
    export RULE_EVAL_TASKS_DIR="$TEST_DIR/tasks"
    export RULE_EVAL_RUNS_DIR="$TEST_DIR/runs"
    T="$RULE_EVAL_TASKS_DIR/fake"
    mkdir -p "$T"
    printf 'do the thing\n' > "$T/PROMPT.md"
    printf 'tree.txt\n' > "$T/OUTPUTS"
    printf '.claude/rules/git.md\n' > "$T/RULE"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$T/verify.sh"
    GEN="$TEST_DIR/fake-gen.sh"
    printf '#!/usr/bin/env bash\nfind . -type f | sort > tree.txt\n' > "$GEN"
    chmod +x "$GEN"
    export GEN_CMD="$GEN"
}
teardown() { teardown_test_dir; }

tree_of() { cat "$RULE_EVAL_RUNS_DIR/fake/$1/sample-1/tree.txt"; }

@test "run: control drops the RULE file, treatment keeps it" {
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 0 ]
    ! tree_of control | grep -qx './.claude/rules/git.md' || false
    tree_of treatment | grep -qx './.claude/rules/git.md'
}

@test "run: FIXTURE files are copied into both arms" {
    mkdir -p "$T/FIXTURE/src"
    printf 'x\n' > "$T/FIXTURE/src/app.ts"
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 0 ]
    tree_of control | grep -qx './src/app.ts'
    tree_of treatment | grep -qx './src/app.ts'
}

@test "run: CANDIDATE files reach the treatment arm only" {
    mkdir -p "$T/CANDIDATE/.claude/rules"
    printf 'new rule\n' > "$T/CANDIDATE/.claude/rules/candidate.md"
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 0 ]
    tree_of treatment | grep -qx './.claude/rules/candidate.md'
    ! tree_of control | grep -qx './.claude/rules/candidate.md' || false
}

@test "run: dry-run names the fixture and the candidate it would use" {
    mkdir -p "$T/FIXTURE" "$T/CANDIDATE"
    run bash "$RUN" fake --samples 1
    [ "$status" -eq 0 ]
    [[ "$output" == *"Fixture:"* ]]
    [[ "$output" == *"Candidate (treatment only):"* ]]
    [ ! -d "$RULE_EVAL_RUNS_DIR/fake" ]
}
