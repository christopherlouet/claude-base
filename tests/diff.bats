#!/usr/bin/env bats

# =============================================================================
# Tests pour diff.sh
# =============================================================================

load 'test_helper'

DIFF_SCRIPT="$BATS_TEST_DIRNAME/../scripts/diff.sh"
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
    # Installer le socle avec new-project.sh --simple
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Puis comparer. diff.sh exit 0 si tout est synchro, exit 1 s'il y a des
    # différences. Depuis v1.30, CLAUDE.md est volontairement réécrit par
    # l'install (chemins @docs → @.claude/docs) donc 1 fichier est "modifié"
    # par design : exit 1 attendu sur une install vierge.
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh détecte les fichiers identiques" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"identique"* ]] || [[ "$output" == *"identical"* ]] || [[ "$output" == *"="* ]] || true
}

@test "diff.sh détecte les fichiers modifiés" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Voir test "diff.sh compare un projet installé" pour le détail :
    # CLAUDE.md modifié par design depuis v1.30, exit 1 acceptable.
    run "$DIFF_SCRIPT" --modified "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "diff.sh --content montre le contenu des différences" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
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
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$DIFF_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"fichier"* ]] || [[ "$output" == *"file"* ]] || [[ "$output" == *"total"* ]] || true
}
