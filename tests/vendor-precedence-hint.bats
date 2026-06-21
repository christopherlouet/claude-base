#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/_vendor-precedence-hint.sh
# Pure-shell, self-contained (no jq, no registry), fail-safe detector: emits a
# vendor-precedence markdown bullet for each INSTALLED vendor skill whose
# foundation pointer it supersedes. Uses synthetic .claude/skills dirs in
# $TEST_DIR so the tests stay decoupled from the host machine.
# =============================================================================

load 'test_helper'

VPREC_LIB="$BASE_DIR/scripts/hooks/_vendor-precedence-hint.sh"

setup() {
    setup_test_dir
    [ -f "$VPREC_LIB" ]
    # shellcheck source=/dev/null
    source "$VPREC_LIB"
    # Isolated fake HOME so global-scope checks don't read the real machine.
    FAKE_HOME="$TEST_DIR/home"
    mkdir -p "$FAKE_HOME"
    PROJECT="$TEST_DIR/project"
    mkdir -p "$PROJECT"
}

teardown() {
    teardown_test_dir
}

install_skill() {  # <root> <dir>  e.g. install_skill "$PROJECT/.claude/skills" prisma-cli
    mkdir -p "$1/$2"
}

# -----------------------------------------------------------------------------
# Installed → hint
# -----------------------------------------------------------------------------

@test "vprec: prisma installed in project .claude/skills emits a hint" {
    install_skill "$PROJECT/.claude/skills" prisma-cli
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"prisma/skills"* ]]
    [[ "$output" == *"dev-prisma"* ]]
    [[ "$output" == *"vendor-precedence T3"* ]]
}

@test "vprec: supabase installed via secondary sentinel dir emits a hint" {
    install_skill "$PROJECT/.claude/skills" supabase-postgres-best-practices
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"supabase/agent-skills"* ]]
}

@test "vprec: detects install in global \$HOME/.claude/skills" {
    install_skill "$FAKE_HOME/.claude/skills" shadcn
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"shadcn-ui/ui/skills/shadcn"* ]]
}

@test "vprec: detects the .agents/skills layout (npx skills #851 fallback)" {
    install_skill "$PROJECT/.agents/skills" prisma-cli
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"prisma/skills"* ]]
}

@test "vprec: two vendors installed emit two bullets" {
    install_skill "$PROJECT/.claude/skills" prisma-cli
    install_skill "$PROJECT/.claude/skills" shadcn
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [ "$(printf '%s\n' "$output" | grep -c 'prefer it')" -eq 2 ]
}

# -----------------------------------------------------------------------------
# Not installed → silent
# -----------------------------------------------------------------------------

@test "vprec: nothing installed → empty output" {
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "vprec: an unrelated skill dir does not produce a false hint" {
    install_skill "$PROJECT/.claude/skills" my-random-skill
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# -----------------------------------------------------------------------------
# Self-contained: no external deps
# -----------------------------------------------------------------------------

@test "vprec: works with jq absent (pure shell, no jq dependency)" {
    install_skill "$PROJECT/.claude/skills" prisma-cli
    # The helper is already sourced and uses only shell builtins; stripping
    # PATH proves it needs no external binary to detect + emit the hint.
    local saved_path="$PATH"
    PATH="/nonexistent"
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    PATH="$saved_path"
    [ "$status" -eq 0 ]
    [[ "$output" == *"prisma/skills"* ]]
}

@test "vprec: a global-scope vendor in fake HOME is detected (not the real one)" {
    install_skill "$FAKE_HOME/.agents/skills" supabase
    run vendor_precedence_hints "$PROJECT" "$FAKE_HOME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"supabase/agent-skills"* ]]
}
