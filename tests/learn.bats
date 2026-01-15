#!/usr/bin/env bats

# =============================================================================
# Tests pour learn.sh (tutoriel interactif)
# =============================================================================

load 'test_helper'

LEARN_SCRIPT="$BATS_TEST_DIRNAME/../scripts/learn.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "learn.sh existe et est exécutable" {
    [[ -x "$LEARN_SCRIPT" ]]
}

@test "learn.sh --help affiche l'aide" {
    run "$LEARN_SCRIPT" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
    [[ "$output" == *"--quick"* ]]
    [[ "$output" == *"--agent"* ]]
}

@test "learn.sh --version affiche la version" {
    run "$LEARN_SCRIPT" --version
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Learn"* ]]
    [[ "$output" == *"v"* ]]
}

@test "learn.sh -h est équivalent à --help" {
    run "$LEARN_SCRIPT" -h
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
}

@test "learn.sh -v est équivalent à --version" {
    run "$LEARN_SCRIPT" -v
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Learn"* ]]
}

# =============================================================================
# Tests --list
# =============================================================================

@test "learn.sh --list affiche les agents disponibles" {
    run "$LEARN_SCRIPT" --list
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"AGENTS DISPONIBLES"* ]]
    [[ "$output" == *"Workflow"* ]]
    [[ "$output" == *"Développement"* ]]
    [[ "$output" == *"Qualité"* ]]
}

@test "learn.sh -l est équivalent à --list" {
    run "$LEARN_SCRIPT" -l
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"AGENTS DISPONIBLES"* ]]
}

# =============================================================================
# Tests --agent
# =============================================================================

@test "learn.sh --agent avec agent invalide échoue" {
    run "$LEARN_SCRIPT" --agent agent-inexistant
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"non trouvé"* ]] || [[ "$output" == *"--list"* ]]
}

# =============================================================================
# Tests --reset
# =============================================================================

@test "learn.sh --reset fonctionne" {
    run "$LEARN_SCRIPT" --reset
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"réinitialisée"* ]] || [[ "$output" == *"Progression"* ]]
}

# =============================================================================
# Tests d'erreur
# =============================================================================

@test "learn.sh avec option invalide échoue" {
    run "$LEARN_SCRIPT" --option-invalide
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"inconnue"* ]] || [[ "$output" == *"--help"* ]]
}

# =============================================================================
# Tests de structure
# =============================================================================

@test "learn.sh contient les fonctions de leçon" {
    grep -q "lesson_introduction" "$LEARN_SCRIPT"
    grep -q "lesson_workflow" "$LEARN_SCRIPT"
    grep -q "lesson_agents" "$LEARN_SCRIPT"
    grep -q "lesson_tdd" "$LEARN_SCRIPT"
    grep -q "lesson_commits" "$LEARN_SCRIPT"
}

@test "learn.sh contient les fonctions de quiz" {
    grep -q "ask_question" "$LEARN_SCRIPT"
    grep -q "ask_yes_no" "$LEARN_SCRIPT"
}

@test "learn.sh contient le mode quick" {
    grep -q "quick_tutorial" "$LEARN_SCRIPT"
}

@test "learn.sh source la librairie commune" {
    grep -q "source.*lib/common.sh" "$LEARN_SCRIPT"
}

@test "learn.sh utilise set -euo pipefail" {
    grep -q "set -euo pipefail" "$LEARN_SCRIPT"
}

# =============================================================================
# Tests de contenu pédagogique
# =============================================================================

@test "learn.sh mentionne le workflow principal" {
    grep -q "EXPLORE" "$LEARN_SCRIPT"
    grep -q "PLAN" "$LEARN_SCRIPT"
    grep -q "CODE" "$LEARN_SCRIPT"
    grep -q "COMMIT" "$LEARN_SCRIPT"
}

@test "learn.sh mentionne TDD" {
    grep -q "TDD" "$LEARN_SCRIPT"
    grep -q "Red.*Green.*Refactor" "$LEARN_SCRIPT" || grep -q "RED.*GREEN" "$LEARN_SCRIPT"
}

@test "learn.sh mentionne Conventional Commits" {
    grep -q "feat" "$LEARN_SCRIPT"
    grep -q "fix" "$LEARN_SCRIPT"
    grep -q "refactor" "$LEARN_SCRIPT"
}

@test "learn.sh mentionne les 79 agents" {
    grep -q "79" "$LEARN_SCRIPT"
}
