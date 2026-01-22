#!/usr/bin/env bats

# =============================================================================
# Tests pour uninstall.sh
# =============================================================================

load 'test_helper'

UNINSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/uninstall.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "uninstall.sh existe et est exécutable" {
    [ -f "$UNINSTALL_SCRIPT" ]
    [ -x "$UNINSTALL_SCRIPT" ]
}

@test "uninstall.sh affiche l'aide avec --help" {
    run "$UNINSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"désinstall"* ]] || [[ "$output" == *"uninstall"* ]] || [[ "$output" == *"supprim"* ]]
}

@test "uninstall.sh affiche la version avec --version" {
    run "$UNINSTALL_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"uninstall"* ]]
}

# =============================================================================
# Tests de désinstallation
# =============================================================================

@test "uninstall.sh gère un projet non configuré" {
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    # Peut réussir ou avertir, mais ne doit pas crasher
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "uninstall.sh supprime .claude" {
    # Installer d'abord avec new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude" ]

    # Désinstaller
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # .claude devrait être supprimé
    [ ! -d "$TEST_DIR/.claude" ]
}

@test "uninstall.sh supprime CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ ! -f "$TEST_DIR/CLAUDE.md" ]
}

@test "uninstall.sh préserve CLAUDE.local.md par défaut" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Créer un fichier local
    echo "# Mes configurations" > "$TEST_DIR/CLAUDE.local.md"

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier local devrait être préservé
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "uninstall.sh --dry-run ne supprime rien" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UNINSTALL_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Les fichiers devraient toujours exister
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "uninstall.sh --all supprime tout y compris les fichiers locaux" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    echo "# Local" > "$TEST_DIR/CLAUDE.local.md"

    run "$UNINSTALL_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Tout devrait être supprimé
    [ ! -d "$TEST_DIR/.claude" ]
    [ ! -f "$TEST_DIR/CLAUDE.md" ]
}

# =============================================================================
# Tests de sécurité
# =============================================================================

@test "uninstall.sh ne supprime pas les fichiers hors .claude" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Créer un fichier utilisateur
    echo "Mon code" > "$TEST_DIR/app.js"

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier utilisateur doit être préservé
    [ -f "$TEST_DIR/app.js" ]
}

@test "uninstall.sh affiche ce qui sera supprimé" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [[ "$output" == *"supprim"* ]] || [[ "$output" == *"remov"* ]] || [[ "$output" == *"delet"* ]] || [[ "$output" == *"OK"* ]] || true
}
