#!/usr/bin/env bats

# =============================================================================
# Tests for eval/rule-efficacy/eval.sh — the deterministic scorer/comparator of
# the rule-efficacy eval. Fully OFFLINE: a fixture "task" whose verify.sh is pure
# shell (compliant iff result.txt == "compliant"), plus fixture sample dirs. No
# LLM is ever invoked here — generation (control/treatment arms) is the manual,
# billing-gated half (see README.md).
#
# The eval answers "does a rule actually change agent behavior?" via the
# 4-way verdict: EFFECTIVE / REDUNDANT / INERT / HARMFUL (compliance of the
# control arm = rule absent, vs the treatment arm = rule present).
# =============================================================================

load 'test_helper'

EVAL="$BATS_TEST_DIRNAME/../eval/rule-efficacy/eval.sh"

setup() {
    setup_test_dir
    # Fixture task: a solution is "compliant" iff result.txt holds exactly "compliant".
    mkdir -p "$TEST_DIR/task"
    cat > "$TEST_DIR/task/verify.sh" <<'EOF'
#!/usr/bin/env bash
grep -qx compliant "$1/result.txt" 2>/dev/null
EOF
}
teardown() { teardown_test_dir; }

# mk_sample <arm-dir> <name> <compliant|violation>
mk_sample() {
    mkdir -p "$1/$2"
    printf '%s\n' "$3" > "$1/$2/result.txt"
}

# mk_arm <arm-dir> <n_compliant> <n_violation>
mk_arm() {
    local arm="$1" c="$2" v="$3" i
    for ((i=1;i<=c;i++)); do mk_sample "$arm" "ok$i" compliant; done
    for ((i=1;i<=v;i++)); do mk_sample "$arm" "bad$i" violation; done
}

# --- score: a single solution's compliance ----------------------------------

@test "rule-efficacy: score reports compliant:true on a compliant solution" {
    mkdir -p "$TEST_DIR/sol"; printf 'compliant\n' > "$TEST_DIR/sol/result.txt"
    run bash "$EVAL" score "$TEST_DIR/sol" "$TEST_DIR/task"
    [ "$status" -eq 0 ]
    [ "$(printf '%s' "$output" | jq -r '.compliant')" = "true" ]
}

@test "rule-efficacy: score reports compliant:false on a violating solution" {
    mkdir -p "$TEST_DIR/sol"; printf 'violation\n' > "$TEST_DIR/sol/result.txt"
    run bash "$EVAL" score "$TEST_DIR/sol" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.compliant')" = "false" ]
}

# --- rate: compliance across the samples of an arm --------------------------

@test "rule-efficacy: rate aggregates compliance over sample subdirs" {
    mk_arm "$TEST_DIR/arm" 2 1     # 2 compliant, 1 violation -> 2/3
    run bash "$EVAL" rate "$TEST_DIR/arm" "$TEST_DIR/task"
    [ "$status" -eq 0 ]
    [ "$(printf '%s' "$output" | jq -r '.samples')" = "3" ]
    [ "$(printf '%s' "$output" | jq -r '.compliant')" = "2" ]
}

@test "rule-efficacy: rate treats a bare solution dir (no subdirs) as one sample" {
    mkdir -p "$TEST_DIR/single"; printf 'compliant\n' > "$TEST_DIR/single/result.txt"
    run bash "$EVAL" rate "$TEST_DIR/single" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.samples')" = "1" ]
    [ "$(printf '%s' "$output" | jq -r '.compliant')" = "1" ]
}

# --- compare: the 4-way verdict ---------------------------------------------

@test "rule-efficacy: EFFECTIVE when the rule lifts compliance (low -> high)" {
    mk_arm "$TEST_DIR/control" 0 3      # 0/3
    mk_arm "$TEST_DIR/treatment" 3 0    # 3/3
    run bash "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/task"
    [ "$status" -eq 0 ]
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "EFFECTIVE" ]
}

@test "rule-efficacy: REDUNDANT when both arms already comply" {
    mk_arm "$TEST_DIR/control" 3 0      # 3/3
    mk_arm "$TEST_DIR/treatment" 3 0    # 3/3
    run bash "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "REDUNDANT" ]
}

@test "rule-efficacy: INERT when neither arm complies (rule moves nothing)" {
    mk_arm "$TEST_DIR/control" 0 3      # 0/3
    mk_arm "$TEST_DIR/treatment" 0 3    # 0/3
    run bash "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "INERT" ]
}

@test "rule-efficacy: HARMFUL when the rule lowers compliance" {
    mk_arm "$TEST_DIR/control" 3 0      # 3/3
    mk_arm "$TEST_DIR/treatment" 0 3    # 0/3
    run bash "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.verdict')" = "HARMFUL" ]
}

@test "rule-efficacy: compare reports the per-arm rates and a delta" {
    mk_arm "$TEST_DIR/control" 1 3      # 1/4 = 0.25
    mk_arm "$TEST_DIR/treatment" 3 1    # 3/4 = 0.75
    run bash "$EVAL" compare "$TEST_DIR/control" "$TEST_DIR/treatment" "$TEST_DIR/task"
    [ "$(printf '%s' "$output" | jq -r '.control.rate')" = "0.25" ]
    [ "$(printf '%s' "$output" | jq -r '.treatment.rate')" = "0.75" ]
    [ "$(printf '%s' "$output" | jq -r '.deltaPct')" = "50" ]
}

# --- CLI fail-safes ----------------------------------------------------------

@test "rule-efficacy: bad subcommand exits 2" {
    run bash "$EVAL" bogus
    [ "$status" -eq 2 ]
}

@test "rule-efficacy: missing args exits 2" {
    run bash "$EVAL" compare "$TEST_DIR/control"
    [ "$status" -eq 2 ]
}
