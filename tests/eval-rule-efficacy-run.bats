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
# A negated grep over a missing tree passes vacuously — prove the tree is there first.
has_tree() { [ -s "$RULE_EVAL_RUNS_DIR/fake/$1/sample-1/tree.txt" ]; }

@test "run: control drops the RULE file, treatment keeps it" {
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 0 ]
    has_tree control
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
    has_tree control
    ! tree_of control | grep -qx './.claude/rules/candidate.md' || false
}

@test "run: dry-run names the fixture and the candidate it would use" {
    mkdir -p "$T/FIXTURE" "$T/CANDIDATE"
    run bash "$RUN" fake --samples 1
    [ "$status" -eq 0 ]
    [[ "$output" == *"Fixture:"*"/fake/FIXTURE"* ]]
    [[ "$output" == *"Candidate (treatment only):"*"/fake/CANDIDATE"* ]]
    [ ! -d "$RULE_EVAL_RUNS_DIR/fake" ]
}

@test "run: a FIXTURE that carries CLAUDE.md or rules is refused" {
    # Copied over the arm, it would overwrite the foundation's CLAUDE.md or put a
    # removed RULE back into the control arm — erasing the difference measured.
    mkdir -p "$T/FIXTURE/.claude/rules"
    printf 'sneaky\n' > "$T/FIXTURE/.claude/rules/git.md"
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 2 ]
    [[ "$output" == *"FIXTURE must not carry"* ]]
    [ ! -d "$RULE_EVAL_RUNS_DIR/fake/control" ]
}

@test "run: a FIXTURE with its own CLAUDE.md is refused" {
    mkdir -p "$T/FIXTURE"
    printf 'fixture\n' > "$T/FIXTURE/CLAUDE.md"
    run bash "$RUN" fake --samples 1 --execute
    [ "$status" -eq 2 ]
}

# --- blind-probe grader: right answers in any common form pass, wrong ones fail ---

BP_VERIFY="$BATS_TEST_DIRNAME/../eval/rule-efficacy/tasks/blind-probe/verify.sh"

grade() {
    mkdir -p "$TEST_DIR/r"
    printf "$1" > "$TEST_DIR/r/REPORT.md"
    bash "$BP_VERIFY" "$TEST_DIR/r"
}

@test "blind-probe grader: accepts the right answer in common forms" {
    grade 'SAFE TO DELETE: no\nsrc/components/UserCard.tsx:7\nsrc/hooks/useInvoices.tsx:7\n'
    grade 'SAFE TO DELETE: no\n- `./src/components/UserCard.tsx:7`\n- `./src/hooks/useInvoices.tsx:7`\n'
    grade 'SAFE TO DELETE: no\ncomponents/UserCard.tsx:7\nhooks/useInvoices.tsx:7\n'
    grade 'SAFE TO DELETE: no \r\nsrc/components/UserCard.tsx:7\r\nsrc/hooks/useInvoices.tsx:7\r\n'
    grade '**SAFE TO DELETE: no**\nsrc/components/UserCard.tsx:7\nsrc/hooks/useInvoices.tsx:7\n'
}

@test "blind-probe grader: rejects trusting, vague or wrong reports" {
    ! grade 'SAFE TO DELETE: yes\n' || false
    ! grade 'SAFE TO DELETE: no\nsrc/components/UserCard.tsx:2\nsrc/hooks/useInvoices.tsx:2\n' || false
    ! grade 'SAFE TO DELETE: no\nsrc/components/UserCard.tsx\nsrc/hooks/useInvoices.tsx\n' || false
    ! grade 'SAFE TO DELETE: no\nsrc/components/UserCard.tsx:7\nsrc/hooks/useInvoices.tsx:7\nsrc/components/OrderList.tsx:3\n' || false
    ! grade 'SAFE TO DELETE: no\nI did not look at src/components/UserCard.tsx or src/hooks/useInvoices.tsx.\n' || false
    ! grade 'SAFE TO DELETE: no\nsrc/components/UserCard.tsx:70\nsrc/hooks/useInvoices.tsx:7\n' || false
}
