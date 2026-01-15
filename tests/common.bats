#!/usr/bin/env bats

# =============================================================================
# Tests pour lib/common.sh
# =============================================================================

load 'test_helper'

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests des fonctions utilitaires
# =============================================================================

@test "command_exists retourne 0 pour une commande existante" {
    run command_exists bash
    [ "$status" -eq 0 ]
}

@test "command_exists retourne 1 pour une commande inexistante" {
    run command_exists commande_inexistante_xyz
    [ "$status" -eq 1 ]
}

@test "get_absolute_path convertit un chemin relatif" {
    cd "$TEST_DIR"
    mkdir -p subdir
    run get_absolute_path "subdir"
    [ "$status" -eq 0 ]
    [[ "$output" == "$TEST_DIR/subdir" ]]
}

@test "count_files compte correctement les fichiers" {
    touch "$TEST_DIR/file1.md"
    touch "$TEST_DIR/file2.md"
    touch "$TEST_DIR/file3.txt"
    run count_files "$TEST_DIR" "*.md"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

@test "count_dirs compte correctement les répertoires" {
    mkdir -p "$TEST_DIR/dir1"
    mkdir -p "$TEST_DIR/dir2"
    touch "$TEST_DIR/file.txt"
    run count_dirs "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

# =============================================================================
# Tests des fonctions de validation JSON
# =============================================================================

@test "validate_json retourne 0 pour un JSON valide" {
    skip_if_no_jq
    echo '{"key": "value"}' > "$TEST_DIR/valid.json"
    run validate_json "$TEST_DIR/valid.json"
    [ "$status" -eq 0 ]
}

@test "validate_json retourne 1 pour un JSON invalide" {
    skip_if_no_jq
    echo '{key: value}' > "$TEST_DIR/invalid.json"
    run validate_json "$TEST_DIR/invalid.json"
    [ "$status" -eq 1 ]
}

@test "validate_json retourne 1 pour un fichier inexistant" {
    run validate_json "$TEST_DIR/nonexistent.json"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests des fonctions de versioning
# =============================================================================

@test "version_gte retourne 0 si v1 >= v2" {
    run version_gte "2.0.0" "1.5.0"
    [ "$status" -eq 0 ]
}

@test "version_gte retourne 0 si v1 == v2" {
    run version_gte "1.5.0" "1.5.0"
    [ "$status" -eq 0 ]
}

@test "version_gte retourne 1 si v1 < v2" {
    run version_gte "1.0.0" "2.0.0"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests des statistiques du socle
# =============================================================================

@test "count_agents compte les fichiers .md dans commands" {
    create_minimal_project
    create_test_command "test-agent"
    run count_agents "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
}

@test "count_skills compte les répertoires dans skills" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/skills/skill1"
    mkdir -p "$TEST_DIR/.claude/skills/skill2"
    run count_skills "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}
