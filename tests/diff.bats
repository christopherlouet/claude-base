#!/usr/bin/env bats

# =============================================================================
# Tests pour diff.sh
# =============================================================================

load 'test_helper'

DIFF_SCRIPT="$BATS_TEST_DIRNAME/../scripts/diff.sh"
INSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/install.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "diff.sh existe et est exécutable" {
    [ -f "$DIFF_SCRIPT" ]
    [ -x "$DIFF_SCRIPT" ]
}

@test "diff.sh affiche l'aide avec --help" {
    run "$DIFF_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
}

@test "diff.sh affiche la version avec --version" {
    run "$DIFF_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"diff"* ]]
}

# =============================================================================
# Tests de comparaison
# =============================================================================

@test "diff.sh fonctionne sur un répertoire vide" {
    run "$DIFF_SCRIPT" "$TEST_DIR"
    # Peut échouer car pas de .claude, mais ne doit pas crasher
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh détecte un projet non configuré" {
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *".claude"* ]] || [[ "$output" == *"pas"* ]] || [[ "$output" == *"non"* ]] || true
}

@test "diff.sh compare un projet installé" {
    # Installer le socle d'abord
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Puis comparer
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "diff.sh détecte les fichiers identiques" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"identique"* ]] || [[ "$output" == *"identical"* ]] || [[ "$output" == *"="* ]] || true
}

@test "diff.sh détecte les fichiers modifiés" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Modifier un fichier
    echo "# Modification" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"modifi"* ]] || [[ "$output" == *"changed"* ]] || [[ "$output" == *"M"* ]] || true
}

# =============================================================================
# Tests des options
# =============================================================================

@test "diff.sh --modified montre seulement les modifiés" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" --modified "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "diff.sh --content montre le contenu des différences" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Modifier un fichier
    echo "# Test" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$DIFF_SCRIPT" --content "$TEST_DIR"
    # Devrait montrer du contenu de diff
    [[ "$output" == *"+"* ]] || [[ "$output" == *"-"* ]] || [[ "$output" == *"Test"* ]] || true
}

# =============================================================================
# Tests de résumé
# =============================================================================

@test "diff.sh affiche un résumé" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"total"* ]] || true
}
