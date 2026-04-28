#!/usr/bin/env bats

# =============================================================================
# US1 — Install simple places socle docs under .claude/docs/
# Spec: specs/docs-under-claude/spec.md (US1, P1, MVP)
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# T004 — Reference docs land under .claude/docs/reference/
# -----------------------------------------------------------------------------

@test "[US1] --simple creates .claude/docs/reference/ with multiple files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/docs/reference" ]

    local count
    count=$(find "$TEST_DIR/.claude/docs/reference" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 7 ]
}

@test "[US1] --simple creates .claude/docs/guides/ with multiple files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/docs/guides" ]

    local count
    count=$(find "$TEST_DIR/.claude/docs/guides" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 5 ]
}

# -----------------------------------------------------------------------------
# T005 — No socle pollution under user's docs/
# -----------------------------------------------------------------------------

@test "[US1] --simple does NOT create docs/reference/ in target" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/docs/reference" ]
}

@test "[US1] --simple does NOT create docs/guides/ in target" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/docs/guides" ]
}

@test "[US1] --simple does NOT install docs/ARCHITECTURE.md from socle" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/docs/ARCHITECTURE.md" ]
    [ ! -f "$TEST_DIR/.claude/docs/ARCHITECTURE.md" ]
}

@test "[US1] --simple does NOT install docs/WORKFLOWS.md from socle" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/docs/WORKFLOWS.md" ]
    [ ! -f "$TEST_DIR/.claude/docs/WORKFLOWS.md" ]
}

# -----------------------------------------------------------------------------
# T006 — CLAUDE.md @imports rewritten to .claude/docs/
# -----------------------------------------------------------------------------

@test "[US1] --simple CLAUDE.md @imports point to .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    grep -q '@\.claude/docs/reference/best-practices\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '@\.claude/docs/reference/project-structures\.md' "$TEST_DIR/CLAUDE.md"
}

@test "[US1] --simple CLAUDE.md does NOT contain legacy @docs/reference/ imports" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run grep -E '^@docs/reference/' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

@test "[US1] --simple CLAUDE.md table refs use .claude/docs/ paths" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    grep -q '\.claude/docs/reference/commands\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '\.claude/docs/guides/WEB-GUIDE\.md' "$TEST_DIR/CLAUDE.md"
}

@test "[US1] --simple CLAUDE.md does NOT mention removed ARCHITECTURE/WORKFLOWS rows" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run grep -F 'docs/ARCHITECTURE.md' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]

    run grep -F 'docs/WORKFLOWS.md' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# T007 — Pre-existing user docs/ARCHITECTURE.md preserved (pve-home scenario)
# -----------------------------------------------------------------------------

@test "[US1] --simple preserves pre-existing user docs/ARCHITECTURE.md byte-identical" {
    mkdir -p "$TEST_DIR/docs"
    cat > "$TEST_DIR/docs/ARCHITECTURE.md" <<'EOF'
# My Project Architecture

User-owned doc that documents the user's project, NOT the socle.
The socle install must not touch this file.

```mermaid
graph TB
    A[User VM] --> B[Proxmox]
```
EOF
    local checksum_before
    checksum_before=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)

    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/docs/ARCHITECTURE.md" ]

    local checksum_after
    checksum_after=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)
    [ "$checksum_before" = "$checksum_after" ]
}

@test "[US1] --simple preserves pre-existing user docs/WORKFLOWS.md byte-identical" {
    mkdir -p "$TEST_DIR/docs"
    echo "# User's own workflows doc" > "$TEST_DIR/docs/WORKFLOWS.md"

    local checksum_before
    checksum_before=$(sha256sum "$TEST_DIR/docs/WORKFLOWS.md" | cut -d' ' -f1)

    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    local checksum_after
    checksum_after=$(sha256sum "$TEST_DIR/docs/WORKFLOWS.md" | cut -d' ' -f1)
    [ "$checksum_before" = "$checksum_after" ]
}
