#!/usr/bin/env bats

# =============================================================================
# Tests for validate-counts.sh (Layer 1 + Layer 2 anti-drift scan)
#
# Isolation strategy: we build a fake foundation in TEST_DIR, copy the script
# + its common library into it, and execute it. The script uses
# `dirname(BASH_SOURCE)` so it scans TEST_DIR instead of the real repo.
# No risk of polluting the real repo.
# =============================================================================

load 'test_helper'

VALIDATE_COUNTS_SCRIPT_REAL="$BATS_TEST_DIRNAME/../scripts/validate-counts.sh"

setup() {
    setup_test_dir

    # Build a minimal fake foundation in TEST_DIR with known counts:
    # 3 commands, 2 agents, 1 skill, 4 rules, 5 tests, 1 test file
    mkdir -p "$TEST_DIR/.claude/commands/work"
    mkdir -p "$TEST_DIR/.claude/agents"
    mkdir -p "$TEST_DIR/.claude/skills/sample-skill"
    mkdir -p "$TEST_DIR/.claude/rules"
    mkdir -p "$TEST_DIR/scripts/lib"
    mkdir -p "$TEST_DIR/tests"
    mkdir -p "$TEST_DIR/website/src/pages"
    mkdir -p "$TEST_DIR/website/src/components"
    mkdir -p "$TEST_DIR/website/docs/intro"
    mkdir -p "$TEST_DIR/website/docs/reference"

    touch "$TEST_DIR/.claude/commands/work/cmd1.md" \
          "$TEST_DIR/.claude/commands/work/cmd2.md" \
          "$TEST_DIR/.claude/commands/work/cmd3.md"
    touch "$TEST_DIR/.claude/agents/agent1.md" \
          "$TEST_DIR/.claude/agents/agent2.md"
    touch "$TEST_DIR/.claude/skills/sample-skill/SKILL.md"
    touch "$TEST_DIR/.claude/rules/rule1.md" \
          "$TEST_DIR/.claude/rules/rule2.md" \
          "$TEST_DIR/.claude/rules/rule3.md" \
          "$TEST_DIR/.claude/rules/rule4.md"

    # 1 test file with 5 @test → ACTUAL_TESTS=5, ACTUAL_TEST_FILES=1
    # NB: do NOT use a heredoc with literal @test, because bats preprocesses
    # @test lines in .bats files even inside heredocs and breaks them.
    # printf avoids the collision with the bats preprocessor.
    {
        echo "#!/usr/bin/env bats"
        printf '@test "test%s" { :; }\n' 1 2 3 4 5
    } > "$TEST_DIR/tests/sample.bats"

    # Copy the script and its library (the script will resolve SOCLE_DIR=TEST_DIR)
    cp "$VALIDATE_COUNTS_SCRIPT_REAL" "$TEST_DIR/scripts/validate-counts.sh"
    cp -r "$BATS_TEST_DIRNAME/../scripts/lib/"* "$TEST_DIR/scripts/lib/"
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"

    # Path of the copied script for the tests
    VALIDATE_SCRIPT="$TEST_DIR/scripts/validate-counts.sh"
    export VALIDATE_SCRIPT
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests (smoke)
# =============================================================================

@test "validate-counts.sh exists and is executable" {
    [ -f "$VALIDATE_COUNTS_SCRIPT_REAL" ]
    [ -x "$VALIDATE_COUNTS_SCRIPT_REAL" ]
}

@test "validate-counts.sh shows help with --help" {
    run "$VALIDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"compteurs"* ]] || [[ "$output" == *"Validate"* ]]
}

@test "validate-counts.sh on a coherent fake foundation: exit 0" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}

@test "validate-counts.sh shows the actual counts in its output" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    # The fake foundation has 3 commands / 2 agents / 1 skill / 4 rules / 5 tests
    # Loose assertions (regex) because bats may normalize whitespace.
    [[ "$output" =~ Commands[[:space:]]*:[[:space:]]*3 ]]
    [[ "$output" =~ Agents[[:space:]]*:[[:space:]]*2 ]]
    [[ "$output" =~ Skills[[:space:]]*:[[:space:]]*1 ]]
    [[ "$output" =~ Rules[[:space:]]*:[[:space:]]*4 ]]
    [[ "$output" =~ Tests[[:space:]]*:[[:space:]]*5 ]]
}

# =============================================================================
# Layer 1 tests — Source-of-truth files
# =============================================================================

@test "validate-counts.sh detects a drift in CLAUDE.md (commands)" {
    # Create a CLAUDE.md with a wrong counter: "999 commandes" instead of 3
    cat > "$TEST_DIR/CLAUDE.md" <<'EOF'
# Test
Le socle a 999 commandes.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"999"* ]] || [[ "$output" == *"incohérence"* ]]
}

# =============================================================================
# Layer 2 tests — Global anti-drift scan (scan_drift)
# =============================================================================

@test "scan_drift Layer 2: detects the 'Skills (N)' markdown header pattern" {
    # We have 1 actual skill but declare 99 in a markdown heading
    cat > "$TEST_DIR/website/docs/intro/architecture.md" <<'EOF'
# Architecture

## Skills (99)
Les skills auto-declenches.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"99 skills"* ]]
    [[ "$output" == *"canonical: 1"* ]]
}

@test "scan_drift Layer 2: detects the 'N Sub-Agents' TS string literal pattern" {
    # We have 2 actual agents but declare 88 in a TSX literal
    cat > "$TEST_DIR/website/src/pages/index.tsx" <<'EOF'
const stats = ['88 Sub-Agents', '3 Commands'];
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]] || [[ "$output" == *"88 sub-agents"* ]]
}

@test "scan_drift Layer 2: detects the '| **Rules** | N |' bold table cell pattern" {
    # We have 4 actual rules but declare 77 in a markdown table
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Stats

| Composant | Nombre |
|-----------|--------|
| **Rules** | 77 |
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"77 rules"* ]]
}

@test "scan_drift Layer 2: detects the 'Skills disponibles (N)' pattern" {
    cat > "$TEST_DIR/.claude/skills/README.md" <<'EOF'
# Skills

## Skills disponibles (66)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"66 skills"* ]]
}

@test "scan_drift Layer 2: detects 'Commands (N available)' (text after digit)" {
    # Heading with extra text after the digit: '## Commands (55 available)'
    # The plain '## Label (N)' pattern would miss this because of the trailing
    # ' available'. The extended pattern accepts [^)]* after the digit.
    cat > "$TEST_DIR/docs/ARCHITECTURE.md" <<'EOF'
# Foundation

## Commands (55 available)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"55 commands"* ]]
}

@test "scan_drift Layer 2: detects multi-column table '| **Agents** | ... | ... | N |'" {
    # 4-column table with the bold label cell and the number cell separated
    # by intermediate cells. The plain adjacent pattern would miss this.
    cat > "$TEST_DIR/website/docs/intro/what-is-claude-code.md" <<'EOF'
# What

| Component | Trigger | Example | Count |
|-----------|---------|---------|-------|
| **Agents** | Via commands | Isolated autonomous sub-agents | 88 |
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]] || [[ "$output" == *"88 sub-agents"* ]]
}

# =============================================================================
# Layer 2 tests — scan_tests_drift (badges + Test layout)
# =============================================================================

@test "scan_tests_drift: detects the 'tests-N passing' badge pattern" {
    # We have 5 actual tests but the badge declares 200
    cat > "$TEST_DIR/README.md" <<'EOF'
# Test
[![Tests](https://img.shields.io/badge/tests-200%20passing-brightgreen)](./tests)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"tests-200"* ]]
    # canonical = ACTUAL_TESTS of the fake foundation (5)
    [[ "$output" =~ canonical:[[:space:]]*5 ]]
}

@test "scan_tests_drift: detects the '(N files, M tests)' Test layout pattern" {
    # We have 1 test file and 5 actual tests but declare 17 and 999
    cat > "$TEST_DIR/README.md" <<'EOF'
# Test
### Test layout (17 files, 999 tests)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"17 test files"* ]] || [[ "$output" == *"17"* ]]
    [[ "$output" == *"999 tests"* ]]
}

# =============================================================================
# Anti-false-positive tests
# =============================================================================

@test "scan_drift: does NOT flag numbers <= 5 (subset/example)" {
    # 1 actual skill, but we mention "3 skills" in a heading
    # The scan must ignore numbers <= 5 to avoid flagging examples
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Test

## Skills (3)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift: does NOT flag per-domain subtotals (WORK 15)" {
    # We declare "WORK (15)" which is a domain subtotal, not a canonical total
    # The scan must NOT flag because the label pattern is WORK, not Skills/Agents/Rules/Commands
    cat > "$TEST_DIR/website/sidebars.ts" <<'EOF'
const sidebars = {
  commands: [
    { label: 'WORK (15)' },
    { label: 'OPS (34)' }
  ]
};
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift: does NOT flag the CHANGELOG (history)" {
    # The CHANGELOG contains historical references to old counters
    # The scan must explicitly exclude it
    cat > "$TEST_DIR/CHANGELOG.md" <<'EOF'
# Changelog

## v0.1.0
- 41 skills released
- 21 rules added
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Integration tests: the real repo must always pass
# =============================================================================

@test "validate-counts.sh on the REAL repo: exit 0 (regression test)" {
    run "$VALIDATE_COUNTS_SCRIPT_REAL"
    [ "$status" -eq 0 ]
    [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}
