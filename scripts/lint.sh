#!/bin/bash

# =============================================================================
# Claude-Socle Lint Script
# Vérifie la qualité du code shell avec ShellCheck
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Activer le handler d'erreur
enable_error_handler

# =============================================================================
# Variables
# =============================================================================

VERSION=$(cat "$SOCLE_DIR/VERSION" 2>/dev/null || echo "unknown")
FIX_MODE=false
SEVERITY="warning"  # error, warning, info, style

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Lint${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Vérifie la qualité du code shell avec ShellCheck.
    Analyse tous les scripts .sh du projet.

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -s, --severity LVL  Niveau minimum (error|warning|info|style)
    --fix               Affiche les suggestions de correction
    -q, --quiet         Mode silencieux

${BOLD}PRÉREQUIS${NC}
    - shellcheck: apt install shellcheck / brew install shellcheck

${BOLD}EXEMPLES${NC}
    # Lint standard
    $(basename "$0")

    # Erreurs uniquement
    $(basename "$0") -s error

    # Avec suggestions
    $(basename "$0") --fix

EOF
}

# =============================================================================
# Vérification des dépendances
# =============================================================================

check_required_dependencies() {
    if ! command_exists shellcheck; then
        error "shellcheck n'est pas installé.
    
Installation:
  - Ubuntu/Debian: sudo apt install shellcheck
  - macOS: brew install shellcheck
  - Autres: https://github.com/koalaman/shellcheck#installing"
    fi
}

# =============================================================================
# Lint
# =============================================================================

run_lint() {
    local scripts=()
    local exit_code=0

    # Trouver tous les scripts shell
    while IFS= read -r -d '' script; do
        scripts+=("$script")
    done < <(find "$SOCLE_DIR/scripts" -name "*.sh" -type f -print0)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        warning "Aucun script trouvé"
        return 0
    fi

    title "Lint ShellCheck"
    info "Scripts à analyser: ${#scripts[@]}"
    info "Niveau minimum: $SEVERITY"
    echo ""

    local shellcheck_opts=(
        "--severity=$SEVERITY"
        "--shell=bash"
        "--external-sources"
    )

    $FIX_MODE && shellcheck_opts+=("--format=diff")

    for script in "${scripts[@]}"; do
        local relative_path="${script#$SOCLE_DIR/}"
        
        if shellcheck "${shellcheck_opts[@]}" "$script" 2>/dev/null; then
            success "$relative_path"
        else
            error_no_exit "$relative_path"
            exit_code=1
            
            # Afficher les détails si pas en mode quiet
            if ! $QUIET; then
                shellcheck "${shellcheck_opts[@]}" "$script" 2>/dev/null || true
                echo ""
            fi
        fi
    done

    echo ""
    separator "="
    
    if [[ $exit_code -eq 0 ]]; then
        success "Tous les scripts sont conformes!"
    else
        error_no_exit "Certains scripts ont des problèmes"
    fi

    return $exit_code
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
            -v|--version)
                echo "claude-socle lint v${VERSION}"
                exit 0
                ;;
            -s|--severity)
                SEVERITY="$2"
                shift 2
                ;;
            --fix)
                FIX_MODE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            *)
                error "Option inconnue: $1"
                ;;
        esac
    done

    check_required_dependencies
    run_lint
}

main "$@"
