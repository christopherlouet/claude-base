#!/bin/bash

# =============================================================================
# Claude-Socle Update Script
# Met à jour les commandes Claude depuis le socle
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
FORCE_UPDATE=false
BACKUP_ONLY=false
UPDATE_SETTINGS=false
UPDATE_SKILLS=false
SHOW_CHANGELOG=false

# Compteurs
UPDATED=0
ADDED=0
SKIPPED=0

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Update${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Met à jour les commandes et configuration Claude Code d'un projet.
    Crée automatiquement une sauvegarde avant la mise à jour.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire à mettre à jour (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -y, --yes           Mode non-interactif (répond oui aux questions)
    -f, --force         Force la mise à jour (écrase tous les fichiers)
    -n, --dry-run       Simule la mise à jour sans rien modifier
    -q, --quiet         Mode silencieux
    --verbose           Mode verbeux (debug)
    --backup-only       Crée uniquement un backup sans mettre à jour
    --settings          Met aussi à jour settings.json
    --skills            Met aussi à jour le répertoire skills/
    --all               Met à jour tout (commandes, settings, skills)
    --changelog         Affiche les nouveautés du socle

${BOLD}EXEMPLES${NC}
    # Mise à jour interactive
    $(basename "$0") ./mon-projet

    # Mise à jour forcée de tout
    $(basename "$0") -f --all ./mon-projet

    # Backup seulement
    $(basename "$0") --backup-only ./mon-projet

    # Voir ce qui serait mis à jour
    $(basename "$0") --dry-run ./mon-projet

${BOLD}STATISTIQUES DU SOCLE${NC}
    Agents:    $(count_agents "$SOCLE_DIR")
    Skills:    $(count_skills "$SOCLE_DIR")
    Hooks:     $(count_hooks "$SOCLE_DIR")

EOF
}

show_version() {
    echo "claude-socle update v${VERSION}"
}

show_changelog() {
    local changelog_file="$SOCLE_DIR/CHANGELOG.md"
    if [[ -f "$changelog_file" ]]; then
        # Afficher les 50 premières lignes du changelog
        head -50 "$changelog_file"
    else
        info "Pas de changelog disponible"
    fi
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
                FORCE_UPDATE=true
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
            --backup-only)
                BACKUP_ONLY=true
                shift
                ;;
            --settings)
                UPDATE_SETTINGS=true
                shift
                ;;
            --skills)
                UPDATE_SKILLS=true
                shift
                ;;
            --all)
                UPDATE_SETTINGS=true
                UPDATE_SKILLS=true
                shift
                ;;
            --changelog)
                show_changelog
                exit 0
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
# Fonctions de mise à jour
# =============================================================================

create_backup() {
    local backup_dir="$TARGET_DIR/.claude/commands.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d "$TARGET_DIR/.claude/commands" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Backup → $backup_dir"
        else
            cp -r "$TARGET_DIR/.claude/commands" "$backup_dir"
            success "Backup créé: $backup_dir"
        fi
        echo "$backup_dir"
    fi
}

update_command_file() {
    local src="$1"
    local filename
    filename=$(basename "$src")
    local dest="$TARGET_DIR/.claude/commands/$filename"

    if [[ -f "$dest" ]]; then
        # Le fichier existe, vérifier s'il a changé
        if diff -q "$src" "$dest" > /dev/null 2>&1; then
            # Identique, rien à faire
            debug "$filename: identique"
            return
        fi

        # Fichier différent
        if $FORCE_UPDATE; then
            # Mode force: écraser
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Mise à jour: $filename"
            else
                cp "$src" "$dest"
            fi
            success "  $filename mis à jour"
            ((UPDATED++))
        elif ${NON_INTERACTIVE:-false}; then
            # Mode non-interactif sans force: ignorer
            warning "  $filename ignoré (utilisez --force pour écraser)"
            ((SKIPPED++))
        else
            # Mode interactif: demander
            echo ""
            prompt "$filename a été modifié. Que faire?"
            echo "  [y] Écraser  [n] Ignorer  [d] Voir le diff"
            read -r -n 1 choice
            echo

            case "$choice" in
                d|D)
                    echo ""
                    echo -e "${DIM}--- Local${NC}"
                    echo -e "${DIM}+++ Socle${NC}"
                    diff "$dest" "$src" || true
                    echo ""
                    if confirm "Écraser $filename?" "n"; then
                        cp "$src" "$dest"
                        success "  $filename mis à jour"
                        ((UPDATED++))
                    else
                        warning "  $filename ignoré"
                        ((SKIPPED++))
                    fi
                    ;;
                y|Y)
                    cp "$src" "$dest"
                    success "  $filename mis à jour"
                    ((UPDATED++))
                    ;;
                *)
                    warning "  $filename ignoré"
                    ((SKIPPED++))
                    ;;
            esac
        fi
    else
        # Nouveau fichier
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Ajout: $filename"
        else
            cp "$src" "$dest"
        fi
        success "  $filename ajouté (nouveau)"
        ((ADDED++))
    fi
}

update_commands() {
    section "Mise à jour des commandes"

    local before
    before=$(count_files "$TARGET_DIR/.claude/commands" "*.md")

    for cmd in "$SOCLE_DIR/.claude/commands/"*.md; do
        if [[ -f "$cmd" ]]; then
            update_command_file "$cmd"
        fi
    done

    local after
    after=$(count_files "$TARGET_DIR/.claude/commands" "*.md")

    info "Commandes: $before → $after"
}

update_settings() {
    section "Mise à jour de settings.json"

    local src="$SOCLE_DIR/.claude/settings.json"
    local dest="$TARGET_DIR/.claude/settings.json"

    if [[ ! -f "$src" ]]; then
        warning "settings.json source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        copy_file "$src" "$dest"
        success "settings.json mis à jour"
    elif [[ -f "$dest" ]]; then
        if confirm "Mettre à jour .claude/settings.json?" "n"; then
            copy_file "$src" "$dest"
            success "settings.json mis à jour"
        else
            warning "settings.json ignoré"
        fi
    else
        copy_file "$src" "$dest"
        success "settings.json créé"
    fi
}

update_skills() {
    section "Mise à jour des skills"

    local src_dir="$SOCLE_DIR/.claude/skills"
    local dest_dir="$TARGET_DIR/.claude/skills"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire skills source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        make_dir "$dest_dir"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Copie skills/"
        else
            cp -r "$src_dir/"* "$dest_dir/"
        fi
        success "Skills mis à jour ($(count_skills "$SOCLE_DIR") skills)"
    elif [[ -d "$dest_dir" ]]; then
        if confirm "Mettre à jour .claude/skills/?" "n"; then
            cp -r "$src_dir/"* "$dest_dir/"
            success "Skills mis à jour"
        else
            warning "Skills ignorés"
        fi
    else
        make_dir "$dest_dir"
        cp -r "$src_dir/"* "$dest_dir/"
        success "Skills créés ($(count_skills "$SOCLE_DIR") skills)"
    fi
}

print_summary() {
    echo ""
    separator "="
    success "Mise à jour terminée!"
    separator "="
    echo ""

    info "Résumé:"
    echo "  Ajoutés:    $ADDED"
    echo "  Mis à jour: $UPDATED"
    echo "  Ignorés:    $SKIPPED"
    echo ""

    if [[ -n "${BACKUP_DIR:-}" ]] && [[ -d "${BACKUP_DIR:-}" ]]; then
        info "Backup disponible: $BACKUP_DIR"
        echo ""
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"

    # Vérifications
    if [[ ! -d "$TARGET_DIR/.claude" ]]; then
        error "Pas de configuration Claude trouvée dans '$TARGET_DIR'. Utilisez install.sh d'abord."
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    title "Mise à jour Claude Code"
    info "Projet: $TARGET_DIR"
    $DRY_RUN && warning "Mode dry-run activé"
    echo ""

    # Créer le backup
    BACKUP_DIR=$(create_backup)

    # Mode backup-only
    if $BACKUP_ONLY; then
        success "Backup créé avec succès"
        exit 0
    fi

    # Mise à jour des commandes
    update_commands

    # Mise à jour optionnelle de settings.json
    if $UPDATE_SETTINGS; then
        update_settings
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/settings.json?" "n"; then
            update_settings
        fi
    fi

    # Mise à jour optionnelle des skills
    if $UPDATE_SKILLS; then
        update_skills
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/skills/?" "n"; then
            update_skills
        fi
    fi

    # Résumé
    print_summary
}

main "$@"
