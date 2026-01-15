#!/usr/bin/env bats

# =============================================================================
# Tests pour install.sh
# =============================================================================

load 'test_helper'

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

@test "install.sh existe et est exécutable" {
    [ -f "$INSTALL_SCRIPT" ]
    [ -x "$INSTALL_SCRIPT" ]
}

@test "install.sh affiche l'aide avec --help" {
    run "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
}

@test "install.sh affiche la version avec --version" {
    run "$INSTALL_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"install"* ]]
}

# =============================================================================
# Tests d'installation
# =============================================================================

@test "install.sh crée la structure .claude en mode dry-run" {
    run "$INSTALL_SCRIPT" -y -n "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY-RUN"* ]] || [[ "$output" == *"dry"* ]] || true
}

@test "install.sh installe les commandes Claude" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/commands" ]
}

@test "install.sh installe les skills" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/skills" ]
}

@test "install.sh crée settings.json" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/settings.json" ]
}

@test "install.sh crée CLAUDE.md" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "install.sh ne réécrit pas CLAUDE.md existant" {
    mkdir -p "$TEST_DIR"
    echo "# Mon projet existant" > "$TEST_DIR/CLAUDE.md"

    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Vérifier que le contenu original est préservé
    run cat "$TEST_DIR/CLAUDE.md"
    [[ "$output" == *"Mon projet existant"* ]]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "install.sh avec --ci installe GitHub Actions" {
    run "$INSTALL_SCRIPT" -y --ci "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
}

@test "install.sh avec --hooks installe husky" {
    run "$INSTALL_SCRIPT" -y --hooks "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.husky" ]
}

@test "install.sh avec --mcp installe la config MCP" {
    run "$INSTALL_SCRIPT" -y --mcp "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.mcp.json" ]
}

@test "install.sh avec --all installe tout" {
    run "$INSTALL_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -d "$TEST_DIR/.husky" ]
    [ -f "$TEST_DIR/.mcp.json" ]
}

# =============================================================================
# Tests de sécurité
# =============================================================================

@test "install.sh met à jour .gitignore avec CLAUDE.local.md" {
    mkdir -p "$TEST_DIR"
    echo "node_modules/" > "$TEST_DIR/.gitignore"

    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    run cat "$TEST_DIR/.gitignore"
    [[ "$output" == *"CLAUDE.local.md"* ]]
}

@test "install.sh crée CLAUDE.local.md.example" {
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.local.md.example" ]
}
