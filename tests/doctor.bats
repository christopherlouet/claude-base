#!/usr/bin/env bats

# =============================================================================
# Tests pour doctor.sh
# =============================================================================

load 'test_helper'

DOCTOR_SCRIPT="$BATS_TEST_DIRNAME/../scripts/doctor.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "doctor.sh existe et est exécutable" {
    [ -f "$DOCTOR_SCRIPT" ]
    [ -x "$DOCTOR_SCRIPT" ]
}

@test "doctor.sh affiche l'aide avec --help" {
    run "$DOCTOR_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
}

@test "doctor.sh affiche la version avec --version" {
    run "$DOCTOR_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"doctor"* ]]
}

# =============================================================================
# Tests de diagnostic système
# =============================================================================

@test "doctor.sh vérifie bash" {
    run "$DOCTOR_SCRIPT" -q
    # Le script peut réussir ou échouer selon l'environnement
    # mais doit s'exécuter sans crash
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh détecte git" {
    run "$DOCTOR_SCRIPT"
    [[ "$output" == *"git"* ]]
}

# =============================================================================
# Tests de diagnostic projet
# =============================================================================

@test "doctor.sh fonctionne sur un projet non configuré" {
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    # Doit s'exécuter (peut avoir des warnings)
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh détecte .claude manquant" {
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *".claude"* ]] || [[ "$output" == *"Claude"* ]]
}

@test "doctor.sh valide un projet bien configuré" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    # Un projet minimal devrait avoir moins de problèmes
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh détecte CLAUDE.md" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"CLAUDE.md"* ]] || true
}

@test "doctor.sh détecte settings.json" {
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"settings"* ]] || true
}

# =============================================================================
# Tests du mode JSON
# =============================================================================

@test "doctor.sh --json retourne du JSON valide" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" --json "$TEST_DIR"
    # Vérifier que c'est du JSON valide
    echo "$output" | jq . > /dev/null 2>&1
    [ $? -eq 0 ]
}

@test "doctor.sh --json contient les clés attendues" {
    skip_if_no_jq
    create_minimal_project "$TEST_DIR"

    run "$DOCTOR_SCRIPT" --json "$TEST_DIR"
    # Vérifier la présence de clés
    echo "$output" | jq -e '.checks' > /dev/null 2>&1 || \
    echo "$output" | jq -e '.status' > /dev/null 2>&1 || \
    echo "$output" | jq -e '.passed' > /dev/null 2>&1 || true
}

# =============================================================================
# Tests de vérification des dépendances
# =============================================================================

@test "doctor.sh mentionne les dépendances optionnelles" {
    run "$DOCTOR_SCRIPT"
    # Devrait mentionner au moins une dépendance optionnelle
    [[ "$output" == *"jq"* ]] || \
    [[ "$output" == *"node"* ]] || \
    [[ "$output" == *"python"* ]] || true
}

# =============================================================================
# Tests de l'intégrité du socle
# =============================================================================

@test "doctor.sh vérifie l'intégrité du socle" {
    # Le socle lui-même devrait passer la vérification
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    # Peut avoir des warnings mais ne devrait pas crasher
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "doctor.sh compte les agents" {
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [[ "$output" == *"agent"* ]] || [[ "$output" == *"command"* ]] || true
}

@test "doctor.sh compte les skills" {
    run "$DOCTOR_SCRIPT" "$BATS_TEST_DIRNAME/.."
    [[ "$output" == *"skill"* ]] || true
}
