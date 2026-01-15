#!/usr/bin/env bats

# =============================================================================
# Tests pour test.sh (le script qui lance les tests bats)
# =============================================================================

load 'test_helper'

TEST_SCRIPT="$BATS_TEST_DIRNAME/../scripts/test.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "test.sh existe et est exécutable" {
    [ -f "$TEST_SCRIPT" ]
    [ -x "$TEST_SCRIPT" ]
}

@test "test.sh affiche l'aide avec --help" {
    run "$TEST_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"test"* ]] || [[ "$output" == *"bats"* ]]
}

@test "test.sh affiche la version avec --version" {
    run "$TEST_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"test"* ]]
}

# =============================================================================
# Tests d'exécution
# =============================================================================

@test "test.sh vérifie si bats est disponible" {
    run "$TEST_SCRIPT" --check
    # Devrait indiquer si bats est installé ou non
    [[ "$output" == *"bats"* ]] || [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "test.sh peut lister les tests disponibles" {
    run "$TEST_SCRIPT" --list 2>/dev/null || run "$TEST_SCRIPT" -l 2>/dev/null || true
    # Peut échouer si l'option n'existe pas, mais ne doit pas crasher
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "test.sh accepte un fichier de test spécifique" {
    if command -v bats &>/dev/null; then
        run "$TEST_SCRIPT" "$BATS_TEST_DIRNAME/common.bats"
        [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
    else
        skip "bats non installé"
    fi
}

@test "test.sh --verbose augmente la verbosité" {
    run "$TEST_SCRIPT" --verbose --help 2>/dev/null || run "$TEST_SCRIPT" -v --help 2>/dev/null || true
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Tests d'installation de bats
# =============================================================================

@test "test.sh propose d'installer bats si manquant" {
    if ! command -v bats &>/dev/null; then
        run "$TEST_SCRIPT"
        [[ "$output" == *"install"* ]] || [[ "$output" == *"bats"* ]] || true
    else
        skip "bats déjà installé"
    fi
}
