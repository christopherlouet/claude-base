#!/bin/bash

# =============================================================================
# Claude-Socle Installation Script
# Installe la configuration Claude Code dans un projet existant
# =============================================================================

set -euo pipefail

VERSION="1.1.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Activer le handler d'erreur et vérifier les prérequis
enable_error_handler
check_base_requirements

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
NON_INTERACTIVE=false
INCLUDE_CICD=false
INCLUDE_HOOKS=false
INCLUDE_MCP=false
SKIP_PROMPTS=false

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Install${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Installe la configuration Claude Code dans un projet existant.
    Copie les agents, skills, hooks et fichiers de configuration.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire cible (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -y, --yes           Mode non-interactif (répond oui à tout)
    -n, --dry-run       Simule l'installation sans rien copier
    -q, --quiet         Mode silencieux (erreurs uniquement)
    --verbose           Mode verbeux (debug)
    --ci                Inclut GitHub Actions
    --hooks             Inclut pre-commit hooks (husky)
    --mcp               Inclut configuration MCP
    --all               Inclut toutes les options
    --skip-prompts      Saute les questions optionnelles

${BOLD}EXEMPLES${NC}
    # Installation interactive
    $(basename "$0") ./mon-projet

    # Installation silencieuse avec tout
    $(basename "$0") -y --all ./mon-projet

    # Voir ce qui serait installé
    $(basename "$0") --dry-run ./mon-projet

${BOLD}FICHIERS INSTALLÉS${NC}
    .claude/commands/   $(count_agents "$SOCLE_DIR") agents
    .claude/skills/     $(count_skills "$SOCLE_DIR") skills
    .claude/settings.json ($(count_hooks "$SOCLE_DIR") hooks)
    CLAUDE.md
    CLAUDE.local.md.example

EOF
}

show_version() {
    echo "claude-socle install v${VERSION}"
}

# =============================================================================
# Parsing des arguments
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -y|--yes)
                NON_INTERACTIVE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --ci)
                INCLUDE_CICD=true
                shift
                ;;
            --hooks)
                INCLUDE_HOOKS=true
                shift
                ;;
            --mcp)
                INCLUDE_MCP=true
                shift
                ;;
            --all)
                INCLUDE_CICD=true
                INCLUDE_HOOKS=true
                INCLUDE_MCP=true
                shift
                ;;
            --skip-prompts)
                SKIP_PROMPTS=true
                shift
                ;;
            -*)
                error "Option inconnue: $1\nUtilisez --help pour l'aide"
                ;;
            *)
                if [[ -z "$TARGET_DIR" ]]; then
                    TARGET_DIR="$1"
                else
                    error "Trop d'arguments: $1"
                fi
                shift
                ;;
        esac
    done

    # Répertoire par défaut
    TARGET_DIR="${TARGET_DIR:-.}"
}

# =============================================================================
# Installation
# =============================================================================

install_claude_config() {
    # Vérifier le répertoire cible
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Le répertoire cible '$TARGET_DIR' n'existe pas"
    fi

    # Convertir en chemin absolu
    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    info "Installation de claude-socle dans: $TARGET_DIR"
    $DRY_RUN && warning "Mode dry-run activé - aucune modification ne sera effectuée"
    echo ""

    # Demander confirmation si le répertoire n'est pas vide
    if [[ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]] && ! $NON_INTERACTIVE; then
        if ! confirm "Le répertoire n'est pas vide. Continuer?" "n"; then
            info "Installation annulée"
            exit 0
        fi
    fi

    # Créer la structure de base
    info "Création de la structure..."
    make_dir "$TARGET_DIR/.claude/commands"
    make_dir "$TARGET_DIR/.claude/skills"

    # Copier les fichiers de configuration Claude
    info "Copie des fichiers de configuration Claude..."

    # Copier .claude/commands/
    debug "Copie des commandes..."
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/commands/* → $TARGET_DIR/.claude/commands/"
    else
        cp -r "$SOCLE_DIR/.claude/commands/"* "$TARGET_DIR/.claude/commands/"
    fi

    # Copier settings.json
    copy_file "$SOCLE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"

    # Copier les skills
    if [[ -d "$SOCLE_DIR/.claude/skills" ]]; then
        debug "Copie des skills..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/skills/* → $TARGET_DIR/.claude/skills/"
        else
            cp -r "$SOCLE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
        fi
    fi

    success "Commandes, skills et configuration copiées"

    # Copier CLAUDE.md (si n'existe pas)
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        warning "CLAUDE.md existe déjà, ignoré"
    else
        copy_file "$SOCLE_DIR/CLAUDE.md" "$TARGET_DIR/"
        success "CLAUDE.md copié"
    fi

    # Copier CLAUDE.local.md.example
    copy_file "$SOCLE_DIR/CLAUDE.local.md.example" "$TARGET_DIR/"
    success "CLAUDE.local.md.example copié"

    # Options supplémentaires
    if ! $SKIP_PROMPTS; then
        install_optional_components
    else
        # Installer les composants spécifiés en ligne de commande
        install_specified_components
    fi

    # Mettre à jour .gitignore
    update_gitignore

    # Résumé
    print_summary
}

install_optional_components() {
    echo ""

    # CI/CD
    if $INCLUDE_CICD || ($NON_INTERACTIVE && false) || (! $NON_INTERACTIVE && confirm "Installer la configuration CI/CD (GitHub Actions)?" "n"); then
        install_cicd
    fi

    # Hooks
    if $INCLUDE_HOOKS || (! $NON_INTERACTIVE && confirm "Installer les hooks pre-commit (husky)?" "n"); then
        install_hooks
    fi

    # MCP
    if $INCLUDE_MCP || (! $NON_INTERACTIVE && confirm "Installer la configuration MCP?" "n"); then
        install_mcp
    fi
}

install_specified_components() {
    $INCLUDE_CICD && install_cicd
    $INCLUDE_HOOKS && install_hooks
    $INCLUDE_MCP && install_mcp
}

install_cicd() {
    make_dir "$TARGET_DIR/.github/workflows"
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.github/workflows/* → $TARGET_DIR/.github/workflows/"
    else
        cp -r "$SOCLE_DIR/.github/workflows/"* "$TARGET_DIR/.github/workflows/"
    fi
    success "GitHub Actions installés"
}

install_hooks() {
    make_dir "$TARGET_DIR/.husky"
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r husky + config files"
    else
        cp -r "$SOCLE_DIR/.husky/"* "$TARGET_DIR/.husky/"
        cp "$SOCLE_DIR/.pre-commit-config.yaml" "$TARGET_DIR/" 2>/dev/null || true
        cp "$SOCLE_DIR/.lintstagedrc.json" "$TARGET_DIR/"
        cp "$SOCLE_DIR/.commitlintrc.json" "$TARGET_DIR/"
        chmod +x "$TARGET_DIR/.husky/"* 2>/dev/null || true
    fi
    success "Hooks pre-commit installés"

    info "Pour activer husky, exécutez:"
    echo "  cd $TARGET_DIR && npm install husky lint-staged @commitlint/cli @commitlint/config-conventional --save-dev"
    echo "  npx husky install"
}

install_mcp() {
    copy_file "$SOCLE_DIR/.mcp.json" "$TARGET_DIR/"
    success ".mcp.json installé"
}

update_gitignore() {
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if ! grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            if ! $DRY_RUN; then
                echo "" >> "$TARGET_DIR/.gitignore"
                echo "# Claude Code local config" >> "$TARGET_DIR/.gitignore"
                echo "CLAUDE.local.md" >> "$TARGET_DIR/.gitignore"
                echo ".claude/settings.local.json" >> "$TARGET_DIR/.gitignore"
            fi
            success ".gitignore mis à jour"
        fi
    else
        copy_file "$SOCLE_DIR/.gitignore" "$TARGET_DIR/"
        success ".gitignore créé"
    fi
}

print_summary() {
    echo ""
    separator "="
    success "Installation terminée!"
    separator "="
    echo ""

    info "Fichiers installés:"
    echo "  - .claude/commands/ ($(count_agents "$SOCLE_DIR") agents)"
    echo "  - .claude/skills/ ($(count_skills "$SOCLE_DIR") skills)"
    echo "  - .claude/settings.json ($(count_hooks "$SOCLE_DIR") hooks)"
    echo "  - CLAUDE.md"
    echo "  - CLAUDE.local.md.example"
    echo ""

    info "Prochaines étapes:"
    echo "  1. Personnalisez CLAUDE.md selon votre projet"
    echo "  2. Copiez CLAUDE.local.md.example en CLAUDE.local.md"
    echo "  3. Lancez Claude Code: cd $TARGET_DIR && claude"
    echo ""

    info "Commandes disponibles:"
    echo "  /project:explore, /project:plan, /project:commit, etc."
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"
    install_claude_config
}

main "$@"
