#!/bin/bash

# =============================================================================
# Claude-Socle Test Runner
# Lance les tests bats pour valider le socle
# =============================================================================

set -euo pipefail

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SOCLE_DIR/tests"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Variables
# =============================================================================

VERSION=$(cat "$SOCLE_DIR/VERSION" 2>/dev/null || echo "unknown")
VERBOSE=false
FILTER=""

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Test Runner${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [FILTER]

${BOLD}DESCRIPTION${NC}
    Lance les tests bats pour valider le socle claude-socle.
    Requiert bats-core installé.

${BOLD}ARGUMENTS${NC}
    FILTER              Pattern pour filtrer les tests (ex: "validate")

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --verbose       Mode verbeux
    --install-bats      Installe bats-core si manquant

${BOLD}EXEMPLES${NC}
    # Lancer tous les tests
    $(basename "$0")

    # Lancer les tests de validation
    $(basename "$0") validate

    # Mode verbeux
    $(basename "$0") -v

${BOLD}PRÉREQUIS${NC}
    - bats-core: npm install -g bats
    - gitleaks (optionnel): brew install gitleaks

EOF
}

# =============================================================================
# Fonctions
# =============================================================================

install_bats() {
    info "Installation de bats-core..."
    if command_exists npm; then
        npm install -g bats
        success "bats installé via npm"
    elif command_exists brew; then
        brew install bats-core
        success "bats installé via brew"
    else
        error "Impossible d'installer bats. Installez npm ou brew d'abord."
    fi
}

run_tests() {
    if ! command_exists bats; then
        error "bats n'est pas installé. Utilisez --install-bats ou installez-le manuellement."
    fi

    local test_files=()

    if [[ -n "$FILTER" ]]; then
        # Filtrer les fichiers de test
        for f in "$TESTS_DIR"/*.bats; do
            if [[ "$(basename "$f")" == *"$FILTER"* ]]; then
                test_files+=("$f")
            fi
        done
    else
        # Tous les fichiers de test
        test_files=("$TESTS_DIR"/*.bats)
    fi

    if [[ ${#test_files[@]} -eq 0 ]]; then
        error "Aucun fichier de test trouvé"
    fi

    title "Tests Claude-Socle"
    info "Fichiers de test: ${#test_files[@]}"
    echo ""

    local bats_opts=()
    $VERBOSE && bats_opts+=("--verbose-run")

    bats "${bats_opts[@]}" "${test_files[@]}"
}

# =============================================================================
# Main
# =============================================================================

main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --install-bats)
                install_bats
                exit 0
                ;;
            -*)
                error "Option inconnue: $1"
                ;;
            *)
                FILTER="$1"
                shift
                ;;
        esac
    done

    run_tests
}

main "$@"
