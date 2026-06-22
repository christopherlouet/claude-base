#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lessons.sh — deterministic helpers for the personal
# lessons referential (bootstrap scan + prune budget). The model-judgment parts
# (generalize / sanitize / confirm) live in the /lessons command, not here.
# =============================================================================

load 'test_helper'

LESSONS="$BATS_TEST_DIRNAME/../scripts/lessons.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Write a memory file with the given metadata type.
_write_memory() {
    local file="$1" name="$2" type="$3" desc="$4"
    mkdir -p "$(dirname "$file")"
    cat > "$file" <<EOF
---
name: $name
description: "$desc"
metadata:
  node_type: memory
  type: $type
---

Body for $name.
EOF
}

# =============================================================================
# Basic invariants
# =============================================================================

@test "lessons.sh exists and is executable" {
    [ -f "$LESSONS" ]
    [ -x "$LESSONS" ]
}

@test "lessons.sh fails on an unknown subcommand" {
    run "$LESSONS" not-a-subcommand
    [ "$status" -ne 0 ]
}

# =============================================================================
# bootstrap-scan
# =============================================================================

@test "bootstrap-scan lists feedback memories across all projects" {
    local root="$TEST_DIR/cl"
    _write_memory "$root/projects/proj-a/memory/prefer-edit.md" "prefer-edit" "feedback" "Use Edit not sed -i"
    _write_memory "$root/projects/proj-b/memory/english-artifacts.md" "english-artifacts" "feedback" "Versioned artifacts in English"
    run "$LESSONS" bootstrap-scan "$root"
    [ "$status" -eq 0 ]
    [[ "$output" == *"prefer-edit"* ]]
    [[ "$output" == *"english-artifacts"* ]]
}

@test "bootstrap-scan skips non-feedback memories (project/user/reference)" {
    local root="$TEST_DIR/cl"
    _write_memory "$root/projects/proj-a/memory/prefer-edit.md" "prefer-edit" "feedback" "Use Edit not sed -i"
    _write_memory "$root/projects/proj-a/memory/some-plan.md" "some-plan" "project" "Ongoing roadmap detail"
    _write_memory "$root/projects/proj-a/memory/a-link.md" "a-link" "reference" "A dashboard URL"
    run "$LESSONS" bootstrap-scan "$root"
    [ "$status" -eq 0 ]
    [[ "$output" == *"prefer-edit"* ]]
    [[ "$output" != *"some-plan"* ]]
    [[ "$output" != *"a-link"* ]]
}

@test "bootstrap-scan ignores the MEMORY.md index file" {
    local root="$TEST_DIR/cl"
    mkdir -p "$root/projects/proj-a/memory"
    printf '# Project Memory\n- [prefer-edit](prefer-edit.md) — type: feedback hint in the index\n' > "$root/projects/proj-a/memory/MEMORY.md"
    _write_memory "$root/projects/proj-a/memory/prefer-edit.md" "prefer-edit" "feedback" "Use Edit not sed -i"
    run "$LESSONS" bootstrap-scan "$root"
    [ "$status" -eq 0 ]
    # Exactly one candidate (the real feedback file), not the index line.
    [ "$(printf '%s\n' "$output" | grep -c 'prefer-edit')" -eq 1 ]
}

@test "bootstrap-scan preserves a description containing a colon" {
    local root="$TEST_DIR/cl"
    _write_memory "$root/projects/proj-a/memory/colon.md" "colon-lesson" "feedback" "Rule: always do X before Y"
    run "$LESSONS" bootstrap-scan "$root"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Rule: always do X before Y"* ]]
}

@test "bootstrap-scan on an empty/absent memory tree is a clean no-op" {
    run "$LESSONS" bootstrap-scan "$TEST_DIR/nope"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "bootstrap-scan defaults the memory root to ~/.claude when omitted" {
    # Override HOME so the default path resolves into the sandbox, never the real ~.
    HOME="$TEST_DIR/home"
    _write_memory "$TEST_DIR/home/.claude/projects/proj-a/memory/x.md" "x-lesson" "feedback" "A general lesson"
    HOME="$TEST_DIR/home" run "$LESSONS" bootstrap-scan
    [ "$status" -eq 0 ]
    [[ "$output" == *"x-lesson"* ]]
}

# =============================================================================
# prune-check
# =============================================================================

@test "prune-check reports OK when the store is within budget" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- Always do X.\n- Never do Y.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
}

@test "prune-check reports OVER when the store exceeds budget" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- Always do X.\n- Never do Y.\n- A third lesson line.\n' > "$store"
    run "$LESSONS" prune-check "$store" 20
    [ "$status" -ne 0 ]
    [[ "$output" == *"OVER"* ]]
}

@test "prune-check flags duplicate lesson lines" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- Always validate inputs.\n- Always validate inputs.\n- Something else.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [[ "$output" == *"Always validate inputs."* ]]
    [[ "$output" == *"DUP"* ]] || [[ "$output" == *"duplicate"* ]]
}

@test "prune-check reports a 3+-times duplicate only once" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- Same lesson.\n- Same lesson.\n- Same lesson.\n- Other.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [ "$(printf '%s\n' "$output" | grep -c 'DUP:')" -eq 1 ]
}

@test "prune-check over budget with duplicates prints DUP then OVER and exits non-zero" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- Dup line here.\n- Dup line here.\n- A longer third lesson line.\n' > "$store"
    run "$LESSONS" prune-check "$store" 20
    [ "$status" -ne 0 ]
    [[ "$output" == *"DUP:"* ]]
    [[ "$output" == *"OVER"* ]]
}

@test "prune-check on a missing store is OK (empty store)" {
    run "$LESSONS" prune-check "$TEST_DIR/absent-lessons.md" 2000
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
}

# =============================================================================
# prune-check — Phase 3: topic grouping (US-8) + recurrence signal (US-9)
# =============================================================================

@test "prune-check: a grouped store with topic headings is clean (headings not lessons)" {
    local store="$TEST_DIR/lessons.md"
    printf -- '## Git\n- Rebase feature branches.\n\n## Testing\n- Cover edge cases.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [ "$status" -eq 0 ]
    [[ "$output" != *"DUP:"* ]]
}

@test "prune-check: identical topic headings are not reported as duplicates" {
    local store="$TEST_DIR/lessons.md"
    # A heading repeated (e.g. after a sloppy sync merge) must not be a DUP — only
    # lessons are deduped, never section headings.
    printf -- '## Traps\n- First lesson.\n## Traps\n- Second lesson.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [[ "$output" != *"DUP:"* ]]
}

@test "prune-check: a lesson and its recurrence-marked twin dedupe to one (DUP)" {
    local store="$TEST_DIR/lessons.md"
    # "foo" and "foo (seen N times)" are the SAME lesson — flag so the user merges
    # them into a single recurrence-bumped line rather than keeping both.
    printf -- '- Quote variable strips.\n- Quote variable strips. (seen 2 times)\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [[ "$output" == *"DUP:"* ]]
    [[ "$output" == *"Quote variable strips."* ]]
}

@test "prune-check: surfaces recurrence-marked lessons with a RECUR signal" {
    local store="$TEST_DIR/lessons.md"
    printf -- '- A common trap. (seen 4 times)\n- A plain lesson.\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [ "$status" -eq 0 ]
    [[ "$output" == *"RECUR 4:"* ]]
    [[ "$output" == *"common trap"* ]]
}

@test "prune-check: a store of only headings (no lessons) is a clean no-op" {
    local store="$TEST_DIR/lessons.md"
    printf -- '## Git\n## Testing\n' > "$store"
    run "$LESSONS" prune-check "$store" 100000
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
    [[ "$output" != *"DUP:"* ]]
}
