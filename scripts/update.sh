#!/bin/bash

# =============================================================================
# Claude-Socle Update Script
# Met à jour les commandes Claude depuis le socle
# =============================================================================

set -euo pipefail

VERSION="1.2.0"

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
UPDATE_AGENTS=false
UPDATE_RULES=false
UPDATE_STYLES=false
UPDATE_TEMPLATES=false
CLEAN_BEFORE_UPDATE=false
DETECT_ORPHANS=false
REMOVE_ORPHANS=false
# shellcheck disable=SC2034  # Reserved for future implementation
SHOW_CHANGELOG=false

# Compteurs
UPDATED=0
ADDED=0
SKIPPED=0
ORPHANS_FOUND=0
ORPHANS_REMOVED=0

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
    --clean             Supprime les anciens fichiers avant mise à jour
    --detect-orphans    Detecte les fichiers absents du socle (orphelins)
    --remove-orphans    Supprime les fichiers orphelins (implique --detect-orphans)
    --settings          Met aussi à jour settings.json
    --skills            Met aussi à jour le répertoire skills/
    --agents            Met aussi à jour le répertoire agents/
    --rules             Met aussi à jour le répertoire rules/
    --styles            Met aussi à jour le répertoire output-styles/
    --templates         Met aussi à jour le répertoire templates/
    --all               Met à jour tout (commandes, settings, skills, agents, rules, styles, templates)
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

    # Detecter les fichiers orphelins
    $(basename "$0") --detect-orphans ./mon-projet

    # Supprimer les fichiers orphelins
    $(basename "$0") --remove-orphans ./mon-projet

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
                export QUIET=true
                shift
                ;;
            --verbose)
                export VERBOSE=true
                shift
                ;;
            --backup-only)
                BACKUP_ONLY=true
                shift
                ;;
            --clean)
                CLEAN_BEFORE_UPDATE=true
                shift
                ;;
            --detect-orphans)
                DETECT_ORPHANS=true
                shift
                ;;
            --remove-orphans)
                DETECT_ORPHANS=true
                REMOVE_ORPHANS=true
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
            --agents)
                UPDATE_AGENTS=true
                shift
                ;;
            --rules)
                UPDATE_RULES=true
                shift
                ;;
            --styles)
                UPDATE_STYLES=true
                shift
                ;;
            --templates)
                UPDATE_TEMPLATES=true
                shift
                ;;
            --all)
                UPDATE_SETTINGS=true
                UPDATE_SKILLS=true
                UPDATE_AGENTS=true
                UPDATE_RULES=true
                UPDATE_STYLES=true
                UPDATE_TEMPLATES=true
                CLEAN_BEFORE_UPDATE=true
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
    local backup_dir
    backup_dir="$TARGET_DIR/.claude/commands.backup.$(date +%Y%m%d_%H%M%S)"

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
    local rel_path="$2"  # Chemin relatif depuis commands/ (ex: work/work-explore.md)
    local filename
    filename=$(basename "$src")
    local dest="$TARGET_DIR/.claude/commands/$rel_path"

    # Créer le sous-répertoire si nécessaire
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]] && ! $DRY_RUN; then
        mkdir -p "$dest_dir"
    fi

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
            ((UPDATED++)) || true
        elif ${NON_INTERACTIVE:-false}; then
            # Mode non-interactif sans force: ignorer
            warning "  $filename ignoré (utilisez --force pour écraser)"
            ((SKIPPED++)) || true
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
                        ((UPDATED++)) || true
                    else
                        warning "  $filename ignoré"
                        ((SKIPPED++)) || true
                    fi
                    ;;
                y|Y)
                    cp "$src" "$dest"
                    success "  $filename mis à jour"
                    ((UPDATED++)) || true
                    ;;
                *)
                    warning "  $filename ignoré"
                    ((SKIPPED++)) || true
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
        ((ADDED++)) || true
    fi
}

update_commands() {
    section "Mise à jour des commandes"

    # Créer le répertoire s'il n'existe pas
    if [[ ! -d "$TARGET_DIR/.claude/commands" ]]; then
        make_dir "$TARGET_DIR/.claude/commands"
    fi

    local before
    before=$(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    # Parcourir récursivement les commandes du socle
    local socle_commands_dir="$SOCLE_DIR/.claude/commands"
    while IFS= read -r cmd; do
        if [[ -f "$cmd" ]]; then
            # Calculer le chemin relatif depuis commands/
            local rel_path="${cmd#$socle_commands_dir/}"
            update_command_file "$cmd" "$rel_path"
        fi
    done < <(find "$socle_commands_dir" -name "*.md" -type f 2>/dev/null || true)

    local after
    after=$(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

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

update_agents() {
    section "Mise à jour des agents"

    local src_dir="$SOCLE_DIR/.claude/agents"
    local dest_dir="$TARGET_DIR/.claude/agents"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire agents source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        make_dir "$dest_dir"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Copie agents/"
        else
            cp -r "$src_dir/"* "$dest_dir/"
        fi
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Agents mis à jour ($count agents)"
    elif [[ -d "$dest_dir" ]]; then
        if confirm "Mettre à jour .claude/agents/?" "n"; then
            cp -r "$src_dir/"* "$dest_dir/"
            success "Agents mis à jour"
        else
            warning "Agents ignorés"
        fi
    else
        make_dir "$dest_dir"
        cp -r "$src_dir/"* "$dest_dir/"
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Agents créés ($count agents)"
    fi
}

update_rules() {
    section "Mise à jour des rules"

    local src_dir="$SOCLE_DIR/.claude/rules"
    local dest_dir="$TARGET_DIR/.claude/rules"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire rules source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        make_dir "$dest_dir"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Copie rules/"
        else
            cp -r "$src_dir/"* "$dest_dir/"
        fi
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Rules mis à jour ($count rules)"
    elif [[ -d "$dest_dir" ]]; then
        if confirm "Mettre à jour .claude/rules/?" "n"; then
            cp -r "$src_dir/"* "$dest_dir/"
            success "Rules mis à jour"
        else
            warning "Rules ignorés"
        fi
    else
        make_dir "$dest_dir"
        cp -r "$src_dir/"* "$dest_dir/"
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Rules créés ($count rules)"
    fi
}

update_styles() {
    section "Mise à jour des output-styles"

    local src_dir="$SOCLE_DIR/.claude/output-styles"
    local dest_dir="$TARGET_DIR/.claude/output-styles"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire output-styles source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        make_dir "$dest_dir"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Copie output-styles/"
        else
            cp -r "$src_dir/"* "$dest_dir/"
        fi
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Output-styles mis à jour ($count styles)"
    elif [[ -d "$dest_dir" ]]; then
        if confirm "Mettre à jour .claude/output-styles/?" "n"; then
            cp -r "$src_dir/"* "$dest_dir/"
            success "Output-styles mis à jour"
        else
            warning "Output-styles ignorés"
        fi
    else
        make_dir "$dest_dir"
        cp -r "$src_dir/"* "$dest_dir/"
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Output-styles créés ($count styles)"
    fi
}

update_templates() {
    section "Mise à jour des templates"

    local src_dir="$SOCLE_DIR/.claude/templates"
    local dest_dir="$TARGET_DIR/.claude/templates"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire templates source non trouvé"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        make_dir "$dest_dir"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Copie templates/"
        else
            cp -r "$src_dir/"* "$dest_dir/"
        fi
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Templates mis à jour ($count templates)"
    elif [[ -d "$dest_dir" ]]; then
        if confirm "Mettre à jour .claude/templates/?" "n"; then
            cp -r "$src_dir/"* "$dest_dir/"
            success "Templates mis à jour"
        else
            warning "Templates ignorés"
        fi
    else
        make_dir "$dest_dir"
        cp -r "$src_dir/"* "$dest_dir/"
        local count
        count=$(find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        success "Templates créés ($count templates)"
    fi
}

detect_orphan_files() {
    local subdir="$1"
    local target_dir="$TARGET_DIR/.claude/$subdir"
    local socle_dir="$SOCLE_DIR/.claude/$subdir"

    if [[ ! -d "$target_dir" ]]; then
        return
    fi

    # Trouver les fichiers .md dans le target
    while IFS= read -r target_file; do
        if [[ -f "$target_file" ]]; then
            # Calculer le chemin relatif
            local rel_path="${target_file#$target_dir/}"
            local socle_file="$socle_dir/$rel_path"

            # Verifier si le fichier existe dans le socle
            if [[ ! -f "$socle_file" ]]; then
                ((ORPHANS_FOUND++)) || true
                local filename
                filename=$(basename "$target_file")

                if $REMOVE_ORPHANS; then
                    if $DRY_RUN; then
                        echo -e "${DIM}[DRY-RUN]${NC} Suppression orphelin: $subdir/$rel_path"
                    else
                        rm -f "$target_file"
                        ((ORPHANS_REMOVED++)) || true
                    fi
                    warning "  $filename supprime (orphelin)"
                elif ${NON_INTERACTIVE:-false}; then
                    warning "  $filename est orphelin (absent du socle)"
                else
                    echo ""
                    prompt "$filename est absent du socle. Que faire?"
                    echo "  [d] Supprimer  [k] Garder"
                    read -r -n 1 choice
                    echo

                    case "$choice" in
                        d|D)
                            if ! $DRY_RUN; then
                                rm -f "$target_file"
                                ((ORPHANS_REMOVED++)) || true
                            fi
                            warning "  $filename supprime"
                            ;;
                        *)
                            info "  $filename conserve"
                            ;;
                    esac
                fi
            fi
        fi
    done < <(find "$target_dir" -name "*.md" -type f 2>/dev/null || true)

    # Nettoyer les repertoires vides
    if $REMOVE_ORPHANS && ! $DRY_RUN; then
        find "$target_dir" -type d -empty -delete 2>/dev/null || true
    fi
}

detect_all_orphans() {
    section "Detection des fichiers orphelins"

    local dirs_to_check=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_check[@]}"; do
        if [[ -d "$TARGET_DIR/.claude/$subdir" ]]; then
            debug "Verification de .claude/$subdir"
            detect_orphan_files "$subdir"
        fi
    done

    if [[ $ORPHANS_FOUND -eq 0 ]]; then
        success "Aucun fichier orphelin detecte"
    else
        if $REMOVE_ORPHANS; then
            success "$ORPHANS_REMOVED/$ORPHANS_FOUND fichiers orphelins supprimes"
        else
            warning "$ORPHANS_FOUND fichiers orphelins detectes"
            info "Utilisez --remove-orphans pour les supprimer"
        fi
    fi
}

clean_claude_dirs() {
    section "Nettoyage des anciens fichiers"

    # Liste des sous-dossiers à nettoyer
    local dirs_to_clean=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_clean[@]}"; do
        if [[ -d "$TARGET_DIR/.claude/$subdir" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Suppression: .claude/$subdir"
            else
                rm -rf "$TARGET_DIR/.claude/$subdir"
                debug "Supprimé: .claude/$subdir"
            fi
        fi
    done

    success "Anciens fichiers nettoyés"
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
    if $DETECT_ORPHANS; then
        echo "  Orphelins:  $ORPHANS_FOUND (${ORPHANS_REMOVED} supprimés)"
    fi
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

    # Nettoyage des anciens fichiers si demandé
    if $CLEAN_BEFORE_UPDATE; then
        clean_claude_dirs
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

    # Mise à jour optionnelle des agents
    if $UPDATE_AGENTS; then
        update_agents
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/agents/?" "n"; then
            update_agents
        fi
    fi

    # Mise à jour optionnelle des rules
    if $UPDATE_RULES; then
        update_rules
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/rules/?" "n"; then
            update_rules
        fi
    fi

    # Mise à jour optionnelle des output-styles
    if $UPDATE_STYLES; then
        update_styles
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/output-styles/?" "n"; then
            update_styles
        fi
    fi

    # Mise à jour optionnelle des templates
    if $UPDATE_TEMPLATES; then
        update_templates
    elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
        echo ""
        if confirm "Mettre à jour .claude/templates/?" "n"; then
            update_templates
        fi
    fi

    # Detection des fichiers orphelins
    if $DETECT_ORPHANS; then
        detect_all_orphans
    fi

    # Résumé
    print_summary
}

main "$@"
