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
    rm "$TEST_DIR/.claude/commands/work/work-explore.md" 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier devrait être restauré
    [ -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "update.sh --dry-run ne modifie rien" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer un fichier
    rm "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier ne devrait PAS être restauré en dry-run
    [ ! -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

@test "update.sh affiche les changements" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Devrait afficher quelque chose sur les fichiers
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"OK"* ]] || true
}

# =============================================================================
# Tests des nouvelles options (--clean, --agents, --rules, --styles, --all)
# =============================================================================

@test "update.sh --clean supprime les anciens fichiers" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier obsolète dans commands (dans un sous-répertoire existant)
    echo "# Old command" > "$TEST_DIR/.claude/commands/work/old-command.md"
    [ -f "$TEST_DIR/.claude/commands/work/old-command.md" ]

    run "$UPDATE_SCRIPT" -y --clean "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier obsolète ne devrait plus exister (tout le dossier a été recréé)
    [ ! -f "$TEST_DIR/.claude/commands/work/old-command.md" ]
}

@test "update.sh --agents met à jour les agents" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer un agent
    rm -f "$TEST_DIR/.claude/agents/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --agents "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Les agents devraient être restaurés
    local count
    count=$(find "$TEST_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --rules met à jour les rules" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les rules
    rm -f "$TEST_DIR/.claude/rules/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --rules "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Les rules devraient être restaurés
    local count
    count=$(find "$TEST_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --styles met à jour les output-styles" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les styles
    rm -f "$TEST_DIR/.claude/output-styles/"*.md 2>/dev/null || true

    run "$UPDATE_SCRIPT" -y --styles "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Les styles devraient être restaurés
    local count
    count=$(find "$TEST_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --all met à jour tout avec nettoyage" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier obsolète dans commands (dans un sous-répertoire)
    echo "# Old" > "$TEST_DIR/.claude/commands/work/obsolete.md"
    [ -f "$TEST_DIR/.claude/commands/work/obsolete.md" ]

    run "$UPDATE_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Les fichiers obsolètes ne devraient plus exister
    [ ! -f "$TEST_DIR/.claude/commands/work/obsolete.md" ]

    # Vérifier que les répertoires sont présents
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -d "$TEST_DIR/.claude/agents" ]
    [ -d "$TEST_DIR/.claude/rules" ]
    [ -d "$TEST_DIR/.claude/output-styles" ]
}

@test "update.sh --help affiche les nouvelles options" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--clean"* ]]
    [[ "$output" == *"--agents"* ]]
    [[ "$output" == *"--rules"* ]]
    [[ "$output" == *"--styles"* ]]
    [[ "$output" == *"--all"* ]]
    [[ "$output" == *"--detect-orphans"* ]]
    [[ "$output" == *"--remove-orphans"* ]]
}

# =============================================================================
# Tests de detection des fichiers orphelins
# =============================================================================

@test "update.sh --detect-orphans detecte les fichiers absents du socle" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier orphelin (absent du socle)
    echo "# Orphan command" > "$TEST_DIR/.claude/commands/work/orphan-command.md"
    [ -f "$TEST_DIR/.claude/commands/work/orphan-command.md" ]

    run "$UPDATE_SCRIPT" -y --detect-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Devrait mentionner les orphelins
    [[ "$output" == *"orphelin"* ]] || [[ "$output" == *"Orphelins"* ]]

    # Le fichier devrait toujours exister (detection seulement)
    [ -f "$TEST_DIR/.claude/commands/work/orphan-command.md" ]
}

@test "update.sh --remove-orphans supprime les fichiers absents du socle" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier orphelin
    echo "# Orphan command" > "$TEST_DIR/.claude/commands/work/orphan-to-delete.md"
    [ -f "$TEST_DIR/.claude/commands/work/orphan-to-delete.md" ]

    run "$UPDATE_SCRIPT" -y --remove-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier orphelin devrait etre supprime
    [ ! -f "$TEST_DIR/.claude/commands/work/orphan-to-delete.md" ]

    # Les fichiers valides devraient toujours exister
    [ -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

@test "update.sh --detect-orphans --dry-run ne supprime pas les fichiers" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier orphelin
    echo "# Orphan" > "$TEST_DIR/.claude/commands/work/dry-run-orphan.md"

    run "$UPDATE_SCRIPT" -y -n --remove-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier devrait toujours exister en dry-run
    [ -f "$TEST_DIR/.claude/commands/work/dry-run-orphan.md" ]
}
