#!/usr/bin/env bats

# =============================================================================
# Tests for qa-loop aligned with the Anthropic 2026 pattern (code-review plugin)
#
# These tests verify:
# - Presence of the new qa-claudemd agent (Sonnet, read-only)
# - qa-loop redesign: parallel audit, VALIDATE phase, high-signal, auto-scope
# - --audit-only and --comment flags in agent + command
# =============================================================================

load 'test_helper'

QA_LOOP_AGENT="$SOCLE_DIR/.claude/agents/qa-loop.md"
QA_LOOP_CMD="$SOCLE_DIR/.claude/commands/qa/qa-loop.md"
QA_CLAUDEMD_AGENT="$SOCLE_DIR/.claude/agents/qa-claudemd.md"

# =============================================================================
# qa-claudemd agent (new)
# =============================================================================

@test "qa-claudemd: the agent exists" {
    [ -f "$QA_CLAUDEMD_AGENT" ]
}

@test "qa-claudemd: frontmatter contains correct name" {
    grep -qE "^name:\s*qa-claudemd\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: frontmatter declares model: sonnet" {
    grep -qE "^model:\s*sonnet\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: agent is read-only (permissionMode: plan)" {
    grep -qE "^permissionMode:\s*plan\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: blocks write tools (disallowedTools)" {
    grep -qE "^disallowedTools:.*(Edit|Write)" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: description mentions CLAUDE.md or compliance" {
    grep -qiE "(CLAUDE\.md|conformit|conventions)" "$QA_CLAUDEMD_AGENT"
}

# =============================================================================
# qa-loop: AUDIT phase in parallel (4 sub-agents)
# =============================================================================

@test "qa-loop agent: mentions the Task tool for parallelization" {
    grep -qE "Task" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatches qa-security as a sub-agent" {
    grep -qE "qa-security" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatches qa-perf as a sub-agent" {
    grep -qE "qa-perf" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatches wcag-audit as a sub-agent" {
    grep -qE "wcag-audit" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatches qa-claudemd as a sub-agent" {
    grep -qE "qa-claudemd" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: documents the parallel audit" {
    grep -qiE "(parallel|parallele|simultane)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop: VALIDATE phase
# =============================================================================

@test "qa-loop agent: VALIDATE phase between AUDIT and FIX" {
    grep -qE "VALIDATE" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: VALIDATE filters false positives" {
    grep -qiE "(faux positif|false positive|filtrer)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop: high-signal filter
# =============================================================================

@test "qa-loop agent: high-signal filter (excludes nitpicks/style)" {
    grep -qiE "(high.signal|nitpick|style)" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: P0 redefined (certain bug / vulnerability / breaking)" {
    grep -qiE "(bug certain|faille|breaking change|certain bug|vulnerability)" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: P1 redefined (measurable impact)" {
    grep -qiE "(impact mesurable|impact concret|measurable impact|concrete impact)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop: auto-scope
# =============================================================================

@test "qa-loop agent: auto-scope via git diff main...HEAD by default" {
    grep -qE "git diff main\.\.\.HEAD" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop: --audit-only and --comment flags
# =============================================================================

@test "qa-loop agent: documents the --audit-only flag" {
    grep -qE -- "--audit-only" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: documents the --comment flag" {
    grep -qE -- "--comment" "$QA_LOOP_AGENT"
}

@test "qa-loop command: documents the --audit-only flag" {
    grep -qE -- "--audit-only" "$QA_LOOP_CMD"
}

@test "qa-loop command: documents the --comment flag" {
    grep -qE -- "--comment" "$QA_LOOP_CMD"
}

@test "qa-loop command: --comment mentions gh pr comment" {
    grep -qiE "gh pr (comment|review)" "$QA_LOOP_CMD"
}

# =============================================================================
# Catalog + counters
# =============================================================================

@test "agents-catalog: lists qa-claudemd" {
    grep -qE "qa-claudemd" "$SOCLE_DIR/docs/reference/agents-catalog.md"
}
