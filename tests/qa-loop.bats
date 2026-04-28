#!/usr/bin/env bats

# =============================================================================
# Tests pour qa-loop aligne sur le pattern Anthropic 2026 (plugin code-review)
#
# Ces tests verifient :
# - Presence du nouvel agent qa-claudemd (Sonnet, lecture seule)
# - Refonte de qa-loop : audit parallele, phase VALIDATE, high-signal, auto-scope
# - Flags --audit-only et --comment dans agent + commande
# =============================================================================

load 'test_helper'

QA_LOOP_AGENT="$SOCLE_DIR/.claude/agents/qa-loop.md"
QA_LOOP_CMD="$SOCLE_DIR/.claude/commands/qa/qa-loop.md"
QA_CLAUDEMD_AGENT="$SOCLE_DIR/.claude/agents/qa-claudemd.md"

# =============================================================================
# Agent qa-claudemd (nouveau)
# =============================================================================

@test "qa-claudemd: l'agent existe" {
    [ -f "$QA_CLAUDEMD_AGENT" ]
}

@test "qa-claudemd: frontmatter contient name correct" {
    grep -qE "^name:\s*qa-claudemd\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: frontmatter declare model: sonnet" {
    grep -qE "^model:\s*sonnet\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: agent en lecture seule (permissionMode: plan)" {
    grep -qE "^permissionMode:\s*plan\s*$" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: bloque les outils d'ecriture (disallowedTools)" {
    grep -qE "^disallowedTools:.*(Edit|Write)" "$QA_CLAUDEMD_AGENT"
}

@test "qa-claudemd: description mentionne CLAUDE.md ou conformite" {
    grep -qiE "(CLAUDE\.md|conformit|conventions)" "$QA_CLAUDEMD_AGENT"
}

# =============================================================================
# qa-loop : phase AUDIT en parallele (4 sub-agents)
# =============================================================================

@test "qa-loop agent: mentionne le tool Task pour la parallelisation" {
    grep -qE "Task" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatche qa-security en sub-agent" {
    grep -qE "qa-security" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatche qa-perf en sub-agent" {
    grep -qE "qa-perf" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatche wcag-audit en sub-agent" {
    grep -qE "wcag-audit" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: dispatche qa-claudemd en sub-agent" {
    grep -qE "qa-claudemd" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: documente l'audit en parallele" {
    grep -qiE "(parallel|parallele|simultane)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop : phase VALIDATE
# =============================================================================

@test "qa-loop agent: phase VALIDATE entre AUDIT et FIX" {
    grep -qE "VALIDATE" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: VALIDATE filtre les faux positifs" {
    grep -qiE "(faux positif|false positive|filtrer)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop : high-signal filter
# =============================================================================

@test "qa-loop agent: filtre high-signal (exclut nitpicks/style)" {
    grep -qiE "(high.signal|nitpick|style)" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: P0 redefini (bug certain / faille / breaking)" {
    grep -qiE "(bug certain|faille|breaking change)" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: P1 redefini (impact mesurable)" {
    grep -qiE "(impact mesurable|impact concret)" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop : auto-scope
# =============================================================================

@test "qa-loop agent: auto-scope via git diff main...HEAD par defaut" {
    grep -qE "git diff main\.\.\.HEAD" "$QA_LOOP_AGENT"
}

# =============================================================================
# qa-loop : flags --audit-only et --comment
# =============================================================================

@test "qa-loop agent: documente le flag --audit-only" {
    grep -qE -- "--audit-only" "$QA_LOOP_AGENT"
}

@test "qa-loop agent: documente le flag --comment" {
    grep -qE -- "--comment" "$QA_LOOP_AGENT"
}

@test "qa-loop commande: documente le flag --audit-only" {
    grep -qE -- "--audit-only" "$QA_LOOP_CMD"
}

@test "qa-loop commande: documente le flag --comment" {
    grep -qE -- "--comment" "$QA_LOOP_CMD"
}

@test "qa-loop commande: --comment mentionne gh pr comment" {
    grep -qiE "gh pr (comment|review)" "$QA_LOOP_CMD"
}

# =============================================================================
# Catalogue + compteurs
# =============================================================================

@test "agents-catalog: liste qa-claudemd" {
    grep -qE "qa-claudemd" "$SOCLE_DIR/docs/reference/agents-catalog.md"
}
