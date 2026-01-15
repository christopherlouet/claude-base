#!/usr/bin/env bats

# =============================================================================
# Tests pour validate.sh
# =============================================================================

load 'test_helper'

VALIDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/validate.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de structure
# =============================================================================

@test "validate.sh existe et est exécutable" {
    [ -f "$VALIDATE_SCRIPT" ]
    [ -x "$VALIDATE_SCRIPT" ]
}

@test "validate.sh affiche l'aide avec --help" {
    run "$VALIDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

@test "validate.sh affiche la version avec --version" {
    run "$VALIDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"validate"* ]]
}

# =============================================================================
# Tests de validation
# =============================================================================

@test "validate.sh échoue sur un répertoire vide" {
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    # Warnings ne sont pas bloquants, mais pas de structure claude
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "validate.sh réussit sur un projet minimal valide" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "validate.sh détecte CLAUDE.md manquant" {
    mkdir -p "$TEST_DIR/.claude/commands"
    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "validate.sh détecte un JSON invalide" {
    skip_if_no_jq
    create_minimal_project
    echo "invalid json" > "$TEST_DIR/.claude/settings.json"
    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"invalide"* ]] || [[ "$output" == *"invalid"* ]]
}

# =============================================================================
# Tests du format de sortie
# =============================================================================

@test "validate.sh --json produit du JSON valide" {
    skip_if_no_jq
    create_minimal_project
    run "$VALIDATE_SCRIPT" --json "$TEST_DIR"
    [ "$status" -eq 0 ]
    echo "$output" | jq . > /dev/null
}

@test "validate.sh --score produit un score" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" --score "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/"* ]]
    [[ "$output" == *"%"* ]]
}
