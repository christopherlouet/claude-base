#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/lib/selected-set.sh — the P2 installer seam
# (specs/agnostic-core/plan-p2.md S1).
#
# compute_selected_set <base_dir> <project_type> prints the SRC[:DST] manifest
# of everything the manifest-driven install ships (same grammar as
# scripts/lib/minimal-manifest.txt): per-file entries for commands/agents/rules,
# per-directory entries (trailing /) for skills/output-styles/templates/hooks,
# SRC:DST remaps for the docs relocation. Selection inputs are the same
# globals the orchestrators fill today (PRESET_*_MODE/ENTRIES, PRESET_SKILLS_*,
# SKIPPED_MODULES) plus the pure libs (catalog_removal_set, module_bundle_paths,
# get_rules_for_type — which moves into this lib).
# =============================================================================

load 'test_helper'

LIB="$BASE_DIR/scripts/lib/selected-set.sh"

setup() {
    setup_test_dir
}
teardown() { teardown_test_dir; }

# Build a small fixture catalog: 2 core command domains + 1 module-owned one,
# 2 agents, 3 skills, rules, styles/templates, hooks.
make_fixture() {
    local r="$TEST_DIR/base"
    mkdir -p "$r/.claude/commands/work" "$r/.claude/commands/qa" \
             "$r/.claude/agents" "$r/.claude/skills/alpha" "$r/.claude/skills/beta" \
             "$r/.claude/skills/gamma" "$r/.claude/rules" \
             "$r/.claude/output-styles" "$r/.claude/templates" \
             "$r/scripts/hooks" "$r/docs/reference" "$r/docs/guides"
    touch "$r/.claude/commands/work/work-explore.md" \
          "$r/.claude/commands/work/work-plan.md" \
          "$r/.claude/commands/qa/qa-review.md" \
          "$r/.claude/agents/dev-tdd.md" "$r/.claude/agents/qa-loop.md" \
          "$r/.claude/skills/alpha/SKILL.md" "$r/.claude/skills/beta/SKILL.md" \
          "$r/.claude/skills/gamma/SKILL.md" \
          "$r/.claude/rules/git.md" "$r/.claude/rules/python.md" \
          "$r/.claude/rules/typescript.md" "$r/.claude/rules/README.md" \
          "$r/.claude/settings.json" \
          "$r/.claude/output-styles/x.md" "$r/.claude/templates/t.md" \
          "$r/scripts/hooks/command-validator.sh" \
          "$r/scripts/substance-check.sh" \
          "$r/docs/reference/best-practices.md" "$r/docs/guides/g.md" \
          "$r/docs/STACK-RECIPES.md"
    echo "$r"
}

# run_set <base> <type> [pre-source setup...] — capture manifest lines.
run_set() {
    local base="$1" type="$2" pre="${3:-true}"
    run bash -c ". '$LIB'; $pre; compute_selected_set '$base' '$type'"
}

@test "selected-set: lib exists, sourceable under set -euo pipefail" {
    [ -f "$LIB" ]
    run bash -c "set -euo pipefail; . '$LIB'; declare -F compute_selected_set >/dev/null && declare -F get_rules_for_type >/dev/null"
    [ "$status" -eq 0 ]
}

@test "selected-set: no preset → every core command/agent file listed" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [ "$status" -eq 0 ]
    [[ "$output" == *".claude/commands/work/work-explore.md"* ]]
    [[ "$output" == *".claude/commands/qa/qa-review.md"* ]]
    [[ "$output" == *".claude/agents/dev-tdd.md"* ]]
}

@test "selected-set: skills are whole-directory entries (trailing slash)" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [[ "$output" == *".claude/skills/alpha/"* ]]
}

@test "selected-set: rules follow the type whitelist, not the full dir" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [[ "$output" == *".claude/rules/git.md"* ]]
    [[ "$output" == *".claude/rules/python.md"* ]]
    [[ "$output" == *".claude/rules/README.md"* ]]
    [[ "$output" != *".claude/rules/typescript.md"* ]]
}

@test "selected-set: docs are SRC:DST relocation remaps" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [[ "$output" == *"docs/reference/:.claude/docs/reference/"* ]]
    [[ "$output" == *"docs/guides/:.claude/docs/guides/"* ]]
    [[ "$output" == *"docs/STACK-RECIPES.md:.claude/docs/STACK-RECIPES.md"* ]]
}

@test "selected-set: hooks dir, settings.json and substance-check ship" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [[ "$output" == *"scripts/hooks/"* ]]
    [[ "$output" == *".claude/settings.json"* ]]
    [[ "$output" == *"scripts/substance-check.sh"* ]]
}

@test "selected-set: preset drop mode removes listed commands, keeps floor" {
    local base; base=$(make_fixture)
    run_set "$base" python "PRESET_COMMANDS_MODE=drop; PRESET_COMMANDS_ENTRIES=(domain:qa)"
    [[ "$output" != *".claude/commands/qa/qa-review.md"* ]]
    [[ "$output" == *".claude/commands/work/work-explore.md"* ]]
}

@test "selected-set: preset keep mode keeps only listed skills" {
    local base; base=$(make_fixture)
    run_set "$base" python "PRESET_SKILLS_KEEP=(alpha)"
    [[ "$output" == *".claude/skills/alpha/"* ]]
    [[ "$output" != *".claude/skills/beta/"* ]]
    [[ "$output" != *".claude/skills/gamma/"* ]]
}

@test "selected-set: preset skills drop removes listed dirs only" {
    local base; base=$(make_fixture)
    run_set "$base" python "PRESET_SKILLS_DROP=(beta)"
    [[ "$output" != *".claude/skills/beta/"* ]]
    [[ "$output" == *".claude/skills/alpha/"* ]]
    [[ "$output" == *".claude/skills/gamma/"* ]]
}

@test "selected-set: output is manifest-grammar clean (no blank, at most one colon, no ..)" {
    local base; base=$(make_fixture)
    run_set "$base" python
    [ "$status" -eq 0 ]
    ! printf '%s\n' "$output" | grep -E '^$|\.\.'
    ! printf '%s\n' "$output" | grep -E ':.*:'
}

@test "selected-set: deterministic (two runs identical)" {
    local base; base=$(make_fixture)
    local a b
    a=$(bash -c ". '$LIB'; compute_selected_set '$base' python")
    b=$(bash -c ". '$LIB'; compute_selected_set '$base' python")
    [ "$a" = "$b" ]
}

# --- Self-application on the real foundation ---------------------------------

@test "selected-set: real repo self-application — entries exist, unique, floor present" {
    run bash -c ". '$LIB'; compute_selected_set '$BASE_DIR' generic"
    [ "$status" -eq 0 ]
    # Floor spot-checks: the always-shipped anchors must be listed.
    [[ "$output" == *".claude/commands/work/work-explore.md"* ]]
    [[ "$output" == *".claude/settings.json"* ]]
    [[ "$output" == *".claude/rules/git.md"* ]]
    [[ "$output" == *"scripts/hooks/"* ]]
    # No duplicate lines.
    local dupes
    dupes=$(printf '%s\n' "$output" | sort | uniq -d)
    [ -z "$dupes" ]
    # The manifest names only files/dirs that actually exist in the repo.
    local missing=0 src
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        src="${line%%:*}"
        [ -e "$BASE_DIR/${src%/}" ] || { echo "missing: $src" >&2; missing=1; }
    done <<< "$output"
    [ "$missing" -eq 0 ]
}
