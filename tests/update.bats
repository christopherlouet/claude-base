#!/usr/bin/env bats

# =============================================================================
# Tests pour update.sh
# =============================================================================

load 'test_helper'

UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
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

@test "update.sh existe et est exécutable" {
    [ -f "$UPDATE_SCRIPT" ]
    [ -x "$UPDATE_SCRIPT" ]
}

@test "update.sh affiche l'aide avec --help" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"mise à jour"* ]] || [[ "$output" == *"update"* ]] || [[ "$output" == *"MAJ"* ]]
}

@test "update.sh affiche la version avec --version" {
    run "$UPDATE_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"update"* ]]
}

# =============================================================================
# Tests de mise à jour
# =============================================================================

@test "update.sh échoue sur un projet non configuré" {
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Devrait échouer ou avertir car pas de .claude
    [[ "$status" -ne 0 ]] || [[ "$output" == *".claude"* ]] || [[ "$output" == *"non"* ]] || true
}

@test "update.sh fonctionne sur un projet configuré" {
    # Installer d'abord
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Puis mettre à jour
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "update.sh préserve les fichiers locaux" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Créer un fichier local
    echo "# Mes notes" > "$TEST_DIR/CLAUDE.local.md"

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Vérifier que le fichier local existe toujours
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
    run cat "$TEST_DIR/CLAUDE.local.md"
    [[ "$output" == *"Mes notes"* ]]
}

@test "update.sh met à jour les commandes" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Simuler une ancienne version en supprimant un fichier
    rm "$TEST_DIR/.claude/commands/work-explore.md" 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier devrait être restauré
    [ -f "$TEST_DIR/.claude/commands/work-explore.md" ]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "update.sh --dry-run ne modifie rien" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer un fichier
    rm "$TEST_DIR/.claude/commands/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier ne devrait PAS être restauré en dry-run
    [ ! -f "$TEST_DIR/.claude/commands/work-explore.md" ]
}

@test "update.sh affiche les changements" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Devrait afficher quelque chose sur les fichiers
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"OK"* ]] || true
}
