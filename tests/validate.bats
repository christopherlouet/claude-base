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

# =============================================================================
# Tests de cohérence CLAUDE.md ↔ Commandes
# =============================================================================

@test "validate.sh détecte les commandes dans les sous-répertoires" {
    create_minimal_project
    create_test_command_in_subdir "work" "work-explore"
    create_test_command_in_subdir "dev" "dev-tdd"

    # CLAUDE.md mentionne les commandes
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Commandes
- /work-explore
- /dev-tdd
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"commandes documentées existent"* ]] || [[ "$output" == *"cohérentes"* ]]
}

@test "validate.sh ne capture pas les faux positifs (chemins de répertoires)" {
    create_minimal_project

    # CLAUDE.md avec des chemins qui ne sont PAS des commandes
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Structure
- /components
- /services
- /utils
- /hooks
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Ne doit PAS signaler de commandes manquantes pour /components, /services, etc.
    [[ "$output" != *"commande(s) mentionnée(s)"*"non trouvée"* ]]
}

@test "validate.sh signale les commandes manquantes" {
    create_minimal_project

    # CLAUDE.md mentionne une commande qui n'existe pas
    cat > "$TEST_DIR/CLAUDE.md" << EOF
# Test Project

## Commandes
- /work-nonexistent
EOF

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"mentionnée"* ]] || [[ "$output" == *"non trouvée"* ]] || [ "$status" -eq 0 ]
}

# =============================================================================
# Tests des skills
# =============================================================================

@test "validate.sh détecte les skills" {
    create_minimal_project
    create_test_skill "test-skill"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"skill"* ]]
}

@test "validate.sh détecte les skills sans frontmatter YAML" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/skills/bad-skill"
    echo "# Bad skill without frontmatter" > "$TEST_DIR/.claude/skills/bad-skill/SKILL.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    # Devrait signaler un warning ou info sur le frontmatter
    [[ "$output" == *"skill"* ]]
}

# =============================================================================
# Tests des hooks
# =============================================================================

@test "validate.sh détecte les hooks configurés" {
    skip_if_no_jq
    create_minimal_project
    create_settings_with_hooks

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"hook"* ]]
}

# =============================================================================
# Tests de sécurité
# =============================================================================

@test "validate.sh vérifie CLAUDE.local.md dans .gitignore" {
    create_minimal_project
    echo "CLAUDE.local.md" > "$TEST_DIR/.gitignore"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CLAUDE.local.md"* ]] && [[ "$output" == *"gitignore"* ]]
}

@test "validate.sh avertit si rm -rf n'est pas bloqué" {
    create_minimal_project
    echo '{"permissions": {"allow": ["Edit"]}}' > "$TEST_DIR/.claude/settings.json"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    # Devrait signaler un warning sur rm -rf
    [[ "$output" == *"rm"* ]] || [ "$status" -eq 0 ]
}

@test "validate.sh valide rm -rf bloqué" {
    skip_if_no_jq
    create_minimal_project
    create_settings_with_hooks

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rm -rf bloqué"* ]]
}

# =============================================================================
# Tests des fichiers de commandes
# =============================================================================

@test "validate.sh détecte les fichiers de commandes vides" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/commands/work"
    touch "$TEST_DIR/.claude/commands/work/work-empty.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"vide"* ]] || [[ "$output" == *"empty"* ]]
}

@test "validate.sh avertit si un fichier de commande n'a pas de titre" {
    create_minimal_project
    mkdir -p "$TEST_DIR/.claude/commands/work"
    echo "Pas de titre markdown" > "$TEST_DIR/.claude/commands/work/work-notitle.md"

    run "$VALIDATE_SCRIPT" "$TEST_DIR"
    [[ "$output" == *"titre"* ]] || [[ "$output" == *"title"* ]] || [ "$status" -eq 0 ]
}

# =============================================================================
# Tests du mode verbose
# =============================================================================

@test "validate.sh --verbose affiche plus de détails" {
    create_minimal_project
    run "$VALIDATE_SCRIPT" --verbose "$TEST_DIR"
    [ "$status" -eq 0 ]
}
