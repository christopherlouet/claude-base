#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/base-integrity-check.sh — the PostToolUse advisory
# hook that reminds about stale counters when a .claude/ resource (skills|agents|
# commands|rules) or .claude/settings.json is edited. It is NON-BLOCKING: it
# never exits non-zero; when validate-counts.sh reports drift it emits a JSON
# `hookSpecificOutput.additionalContext` warning (tagged "[BASE-INTEGRITY]") on
# stdout and still exits 0.
#
# It only acts inside the foundation itself (guarded by the presence of both
# scripts/validate-counts.sh and scripts/audit-base.sh under CLAUDE_PROJECT_DIR),
# so consuming projects that don't maintain the counters are never nagged.
#
# Payload on STDIN as JSON (.tool_name, .tool_input.file_path /
# .tool_input.notebook_path). jq is required — absent jq → fail-open (exit 0).
# Disable with SKIP_BASE_INTEGRITY=1.
# =============================================================================

load 'test_helper'

HOOK="$BASE_DIR/scripts/hooks/base-integrity-check.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# Build a fake foundation project under $TEST_DIR: the two gate files the hook
# requires (audit-base.sh present, validate-counts.sh executable) plus the .claude
# tree. $1 = exit code the fake validate-counts.sh returns (0 clean / 1 drift).
make_fake_project() {
    mkdir -p "$TEST_DIR/scripts" "$TEST_DIR/.claude/skills/foo"
    : > "$TEST_DIR/scripts/audit-base.sh"           # presence gate only
    cat > "$TEST_DIR/scripts/validate-counts.sh" <<EOF
#!/usr/bin/env bash
echo "3 inconsistencies found (expected 5, found 3)"
exit ${1:-0}
EOF
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"
}

# bic <tool_name> <file_path> — feed a PostToolUse envelope on stdin, with
# CLAUDE_PROJECT_DIR pointed at the fake project.
bic() {
    local json
    json=$(jq -n --arg t "$1" --arg f "$2" '{tool_name:$t, tool_input:{file_path:$f}}')
    CLAUDE_PROJECT_DIR="$TEST_DIR" run bash -c "bash '$HOOK'" <<<"$json"
}

# --- Warning fires on a .claude/ edit when counts drift ----------------------

@test "base-integrity: drift + edit under .claude/skills → warning, exit 0" {
    make_fake_project 1
    bic Edit "$TEST_DIR/.claude/skills/foo/SKILL.md"
    [ "$status" -eq 0 ]
    [[ "$output" == *"BASE-INTEGRITY"* ]]
}

@test "base-integrity: drift + edit of .claude/settings.json → warning, exit 0" {
    make_fake_project 1
    bic Write "$TEST_DIR/.claude/settings.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"BASE-INTEGRITY"* ]]
}

@test "base-integrity: clean counts + .claude/ edit → silent, exit 0" {
    make_fake_project 0
    bic Edit "$TEST_DIR/.claude/rules/testing.md"
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

# --- Out of scope: unrelated file must never warn (even if counts drift) ------

@test "base-integrity: edit of an unrelated file → silent, exit 0" {
    make_fake_project 1                       # validate-counts WOULD fail…
    mkdir -p "$TEST_DIR/src"
    bic Edit "$TEST_DIR/src/index.ts"         # …but path is out of scope
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

@test "base-integrity: non-mutating tool (Read) → silent, exit 0" {
    make_fake_project 1
    bic Read "$TEST_DIR/.claude/skills/foo/SKILL.md"
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

# --- Opt-out ------------------------------------------------------------------

@test "base-integrity: SKIP_BASE_INTEGRITY=1 → silent, exit 0" {
    make_fake_project 1
    local json
    json=$(jq -n --arg f "$TEST_DIR/.claude/skills/foo/SKILL.md" \
        '{tool_name:"Edit", tool_input:{file_path:$f}}')
    SKIP_BASE_INTEGRITY=1 CLAUDE_PROJECT_DIR="$TEST_DIR" \
        run bash -c "bash '$HOOK'" <<<"$json"
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

# --- Fail-open: malformed / empty stdin, missing jq ---------------------------

@test "base-integrity: empty stdin → no crash, exit 0" {
    make_fake_project 1
    CLAUDE_PROJECT_DIR="$TEST_DIR" run bash -c "bash '$HOOK'" < /dev/null
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "base-integrity: malformed JSON stdin → no crash, exit 0" {
    make_fake_project 1
    CLAUDE_PROJECT_DIR="$TEST_DIR" run bash -c "bash '$HOOK'" <<<'not-valid-json{'
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

@test "base-integrity: missing jq → fail-open silent, exit 0" {
    # With jq off PATH the guard bails before any parsing — even a drift payload
    # that WOULD warn stays silent. Symlink only bash into the sandbox PATH.
    make_fake_project 1
    mkdir -p "$TEST_DIR/nojq"
    ln -s "$(command -v bash)" "$TEST_DIR/nojq/bash"
    local json
    json=$(jq -n --arg f "$TEST_DIR/.claude/skills/foo/SKILL.md" \
        '{tool_name:"Edit", tool_input:{file_path:$f}}')
    CLAUDE_PROJECT_DIR="$TEST_DIR" PATH="$TEST_DIR/nojq" \
        run bash "$HOOK" <<<"$json"
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

# --- Guard: outside the foundation (no audit-base.sh) → never warn ------------

@test "base-integrity: no audit-base.sh (consuming project) → silent, exit 0" {
    # validate-counts.sh present + failing, but audit-base.sh absent → the hook
    # treats this as a consuming project and does not nag.
    mkdir -p "$TEST_DIR/scripts" "$TEST_DIR/.claude/skills/foo"
    cat > "$TEST_DIR/scripts/validate-counts.sh" <<'EOF'
#!/usr/bin/env bash
echo "inconsistencies found"
exit 1
EOF
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"
    bic Edit "$TEST_DIR/.claude/skills/foo/SKILL.md"
    [ "$status" -eq 0 ]
    [[ "$output" != *"BASE-INTEGRITY"* ]]
}

# --- Self-application: run against the REAL foundation ------------------------
# Exercises the REAL validate-counts.sh + audit-base.sh gate + JSON wrapping on
# the actual repo (no fakes). Two tree-independent invariants hold whether the
# working tree's counts happen to be in sync or mid-edit (they legitimately drift
# while new files are being added, before the pre-commit self-heal):
#   1. the advisory hook is NON-BLOCKING → always exit 0, and
#   2. when it DOES warn, the payload is the documented, well-formed
#      hookSpecificOutput JSON tagged "[BASE-INTEGRITY]".
@test "self-application: real foundation — non-blocking, well-formed warning JSON" {
    local f="$BASE_DIR/.claude/rules/testing.md"
    [ -f "$f" ] || skip "real rule file missing"
    local json
    json=$(jq -n --arg f "$f" '{tool_name:"Edit", tool_input:{file_path:$f}}')
    CLAUDE_PROJECT_DIR="$BASE_DIR" run bash -c "bash '$HOOK'" <<<"$json"
    [ "$status" -eq 0 ]
    if [ -n "$output" ]; then
        echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
        [[ "$output" == *"BASE-INTEGRITY"* ]]
    fi
}
