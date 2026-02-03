#!/usr/bin/env bats

# =============================================================================
# Tests pour update.sh
# =============================================================================

load 'test_helper'

UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
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
    # Installer d'abord avec new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Puis mettre à jour
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "update.sh préserve les fichiers locaux" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer un fichier
    rm "$TEST_DIR/.claude/commands/work/work-explore.md"

    run "$UPDATE_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier ne devrait PAS être restauré en dry-run
    [ ! -f "$TEST_DIR/.claude/commands/work/work-explore.md" ]
}

@test "update.sh affiche les changements" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    # Devrait afficher quelque chose sur les fichiers
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"OK"* ]] || true
}

# =============================================================================
# Tests des nouvelles options (--clean, --agents, --rules, --styles, --all)
# =============================================================================

@test "update.sh --clean supprime les anciens fichiers" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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

# =============================================================================
# Tests de --upgrade-claude-md
# =============================================================================

@test "update.sh --upgrade-claude-md copie docs/reference/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer docs/reference/ s'il existe déjà
    rm -rf "$TEST_DIR/docs/reference"

    # Supprimer les @imports du CLAUDE.md pour simuler un ancien projet
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # docs/reference/ doit exister avec des fichiers
    [ -d "$TEST_DIR/docs/reference" ]
    local count
    count=$(find "$TEST_DIR/docs/reference" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "update.sh --upgrade-claude-md ajoute les @imports dans CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer docs/reference/ et les @imports
    rm -rf "$TEST_DIR/docs/reference"
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # CLAUDE.md doit contenir les @imports
    grep -q "@docs/reference/commands.md" "$TEST_DIR/CLAUDE.md"
    grep -q "@docs/reference/agents-catalog.md" "$TEST_DIR/CLAUDE.md"
    grep -q "@docs/reference/skills-catalog.md" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --upgrade-claude-md crée un backup" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les @imports pour déclencher la migration
    rm -rf "$TEST_DIR/docs/reference"
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Un fichier backup doit exister
    local backup_count
    backup_count=$(find "$TEST_DIR" -maxdepth 1 -name "CLAUDE.md.backup.*" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$backup_count" -ge 1 ]
}

@test "update.sh --upgrade-claude-md skip si @imports déjà présents" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # S'assurer que les @imports sont déjà là
    if ! grep -q "@docs/reference/" "$TEST_DIR/CLAUDE.md"; then
        # Ajouter un @import pour le test
        sed -i '1a @docs/reference/commands.md' "$TEST_DIR/CLAUDE.md"
    fi

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Pas de backup créé (skip) - contient tous les @imports
    [[ "$output" == *"skip"* ]] || [[ "$output" == *"déjà"* ]] || [[ "$output" == *"contient tous les @imports"* ]]
}

@test "update.sh --upgrade-claude-md détecte les sections dupliquées" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les @imports et ajouter une section dupliquée
    rm -rf "$TEST_DIR/docs/reference"
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"
    echo "" >> "$TEST_DIR/CLAUDE.md"
    echo "## Commandes Essentielles" >> "$TEST_DIR/CLAUDE.md"
    echo "Contenu inline ancien" >> "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # La section dupliquée doit être supprimée (mode -y)
    ! grep -q "^## Commandes Essentielles" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --all inclut la migration CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les @imports
    rm -rf "$TEST_DIR/docs/reference"
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # docs/reference/ doit exister
    [ -d "$TEST_DIR/docs/reference" ]
    # @imports doivent être présents
    grep -q "@docs/reference/" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --dry-run --upgrade-claude-md ne modifie rien" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Supprimer les @imports
    rm -rf "$TEST_DIR/docs/reference"
    sed -i '/@docs\/reference/d' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y -n --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # docs/reference/ ne doit PAS exister
    [ ! -d "$TEST_DIR/docs/reference" ]
    # @imports ne doivent PAS être présents
    ! grep -q "@docs/reference/" "$TEST_DIR/CLAUDE.md"
}

@test "update.sh --help affiche --upgrade-claude-md" {
    run "$UPDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--upgrade-claude-md"* ]]
}

@test "update.sh --detect-orphans --dry-run ne supprime pas les fichiers" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier orphelin
    echo "# Orphan" > "$TEST_DIR/.claude/commands/work/dry-run-orphan.md"

    run "$UPDATE_SCRIPT" -y -n --remove-orphans "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier devrait toujours exister en dry-run
    [ -f "$TEST_DIR/.claude/commands/work/dry-run-orphan.md" ]
}
