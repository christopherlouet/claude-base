#!/bin/bash

# =============================================================================
# Test Helper - Fonctions utilitaires pour les tests bats
# =============================================================================

# Charger la librairie commune du socle
SOCLE_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
source "$SOCLE_DIR/scripts/lib/common.sh"

# Créer un répertoire temporaire pour les tests
setup_test_dir() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

# Nettoyer le répertoire temporaire
teardown_test_dir() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Créer une structure de projet minimale
create_minimal_project() {
    local dir="${1:-$TEST_DIR}"
    mkdir -p "$dir/.claude/commands"
    mkdir -p "$dir/.claude/skills"
    echo '{}' > "$dir/.claude/settings.json"
    echo "# Test Project" > "$dir/CLAUDE.md"
}

# Créer un fichier de commande de test
create_test_command() {
    local name="$1"
    local dir="${2:-$TEST_DIR}"
    cat > "$dir/.claude/commands/$name.md" << EOF
# Agent $name

Description de test pour $name.

## Instructions

Faire quelque chose.
EOF
}

# Vérifier si gitleaks est installé
skip_if_no_gitleaks() {
    if ! command -v gitleaks &>/dev/null; then
        skip "gitleaks n'est pas installé"
    fi
}

# Vérifier si jq est installé
skip_if_no_jq() {
    if ! command -v jq &>/dev/null; then
        skip "jq n'est pas installé"
    fi
}
