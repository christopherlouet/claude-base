#!/bin/bash

# =============================================================================
# Claude-Socle Uninstall Script
# Supprime la configuration Claude Code d'un projet
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # Used by sourced scripts
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
KEEP_CLAUDE_MD=false
KEEP_BACKUP=true
FORCE=false
REMOVE_LOCAL_FILES=false

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Uninstall${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Supprime la configuration Claude Code d'un projet.
    Crée une sauvegarde avant suppression par défaut.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire cible (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -y, --yes           Mode non-interactif (confirme automatiquement)
    -f, --force         Supprime sans demander de confirmation
    -n, --dry-run       Simule la suppression sans rien effacer
    -q, --quiet         Mode silencieux
    --keep-claude-md    Conserve le fichier CLAUDE.md personnalisé
    --no-backup         Ne crée pas de sauvegarde avant suppression

${BOLD}FICHIERS SUPPRIMÉS${NC}
    .claude/            Répertoire complet (commands, skills, settings)
    CLAUDE.md           Fichier d'instructions (sauf avec --keep-claude-md)
    CLAUDE.local.md     Configuration locale
    CLAUDE.local.md.example

${BOLD}EXEMPLES${NC}
    # Désinstallation interactive
    $(basename "$0") ./mon-projet

    # Garder CLAUDE.md personnalisé
    $(basename "$0") --keep-claude-md ./mon-projet

    # Voir ce qui serait supprimé
    $(basename "$0") --dry-run ./mon-projet

EOF
}

show_version() {
    echo "claude-socle uninstall v${VERSION}"
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
            -f|--force)
                FORCE=true
                NON_INTERACTIVE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                export QUIET=true
                shift
                ;;
            --keep-claude-md)
                KEEP_CLAUDE_MD=true
                shift
                ;;
            --no-backup)
                KEEP_BACKUP=false
                shift
                ;;
            --all)
                REMOVE_LOCAL_FILES=true
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

    TARGET_DIR="${TARGET_DIR:-.}"
}

# =============================================================================
# Désinstallation
# =============================================================================

create_backup() {
    local backup_dir
    backup_dir="$TARGET_DIR/.claude-backup.$(date +%Y%m%d_%H%M%S)"

    info "Création d'une sauvegarde..."

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Backup → $backup_dir"
        return
    fi

    mkdir -p "$backup_dir"

    # Sauvegarder .claude/
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        cp -r "$TARGET_DIR/.claude" "$backup_dir/"
    fi

    # Sauvegarder CLAUDE.md
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        cp "$TARGET_DIR/CLAUDE.md" "$backup_dir/"
    fi

    # Sauvegarder CLAUDE.local.md
    if [[ -f "$TARGET_DIR/CLAUDE.local.md" ]]; then
        cp "$TARGET_DIR/CLAUDE.local.md" "$backup_dir/"
    fi

    success "Sauvegarde créée: $backup_dir"
}

remove_file() {
    local file="$1"
    local desc="$2"

    if [[ -f "$file" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Suppression: $desc"
        else
            rm "$file"
            success "Supprimé: $desc"
        fi
    fi
}

remove_dir() {
    local dir="$1"
    local desc="$2"

    if [[ -d "$dir" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Suppression: $desc"
        else
            rm -rf "$dir"
            success "Supprimé: $desc"
        fi
    fi
}

uninstall() {
    # Vérifier le répertoire
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Le répertoire '$TARGET_DIR' n'existe pas"
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Vérifier qu'il y a quelque chose à supprimer
    if [[ ! -d "$TARGET_DIR/.claude" ]] && [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        error "Pas de configuration Claude trouvée dans '$TARGET_DIR'"
    fi

    title "Désinstallation Claude Code"
    info "Projet: $TARGET_DIR"
    $DRY_RUN && warning "Mode dry-run activé"
    echo ""

    # Afficher ce qui sera supprimé
    section "Fichiers à supprimer"

    local files_to_remove=()

    if [[ -d "$TARGET_DIR/.claude" ]]; then
        local cmd_count
        local skills_count
        cmd_count=$(count_files "$TARGET_DIR/.claude/commands" "*.md")
        skills_count=$(count_dirs "$TARGET_DIR/.claude/skills")
        echo "  - .claude/ ($cmd_count commandes, $skills_count skills)"
        files_to_remove+=(".claude/")
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.md" ]] && ! $KEEP_CLAUDE_MD; then
        echo "  - CLAUDE.md"
        files_to_remove+=("CLAUDE.md")
    elif [[ -f "$TARGET_DIR/CLAUDE.md" ]] && $KEEP_CLAUDE_MD; then
        echo -e "  - CLAUDE.md ${DIM}(conservé)${NC}"
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.local.md" ]]; then
        if $REMOVE_LOCAL_FILES; then
            echo "  - CLAUDE.local.md"
            files_to_remove+=("CLAUDE.local.md")
        else
            echo -e "  - CLAUDE.local.md ${DIM}(conservé)${NC}"
        fi
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.local.md.example" ]]; then
        echo "  - CLAUDE.local.md.example"
        files_to_remove+=("CLAUDE.local.md.example")
    fi

    echo ""

    # Demander confirmation
    if ! $FORCE && ! ${NON_INTERACTIVE:-false}; then
        warning "Cette action est irréversible!"
        if ! confirm "Supprimer la configuration Claude Code?" "n"; then
            info "Désinstallation annulée"
            exit 0
        fi
    fi

    # Créer backup si demandé
    if $KEEP_BACKUP; then
        create_backup
    fi

    # Supprimer les fichiers
    section "Suppression"

    remove_dir "$TARGET_DIR/.claude" ".claude/"

    if ! $KEEP_CLAUDE_MD; then
        remove_file "$TARGET_DIR/CLAUDE.md" "CLAUDE.md"
    fi

    if $REMOVE_LOCAL_FILES; then
        remove_file "$TARGET_DIR/CLAUDE.local.md" "CLAUDE.local.md"
    fi
    remove_file "$TARGET_DIR/CLAUDE.local.md.example" "CLAUDE.local.md.example"

    # Nettoyer .gitignore si présent
    if [[ -f "$TARGET_DIR/.gitignore" ]] && ! $DRY_RUN; then
        # Supprimer les lignes Claude Code du .gitignore
        if grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            # Créer un fichier temporaire sans les lignes Claude
            grep -v "CLAUDE.local.md\|.claude/settings.local.json\|# Claude Code" "$TARGET_DIR/.gitignore" > "$TARGET_DIR/.gitignore.tmp" 2>/dev/null || true
            mv "$TARGET_DIR/.gitignore.tmp" "$TARGET_DIR/.gitignore"
            success "Nettoyé: .gitignore"
        fi
    fi

    # Résumé
    echo ""
    separator "="
    success "Désinstallation terminée!"
    separator "="
    echo ""

    if $KEEP_CLAUDE_MD && [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        info "CLAUDE.md a été conservé"
    fi

    if $KEEP_BACKUP && ! $DRY_RUN; then
        info "Une sauvegarde a été créée dans le répertoire du projet"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"
    uninstall
}

main "$@"
