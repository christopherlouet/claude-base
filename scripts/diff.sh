#!/bin/bash

# =============================================================================
# Claude-Socle Diff Script
# Compare la configuration d'un projet avec le socle
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
SHOW_ONLY="all"  # all, new, modified, deleted
USE_COLOR=true
SHOW_CONTENT=false

# Compteurs
NEW_FILES=0
MODIFIED_FILES=0
DELETED_FILES=0
IDENTICAL_FILES=0

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Diff${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Compare la configuration Claude Code d'un projet avec le socle.
    Affiche les différences entre les fichiers locaux et le socle.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire à comparer (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -q, --quiet         Mode silencieux (résumé uniquement)
    --new               Affiche uniquement les nouveaux fichiers (dans socle)
    --modified          Affiche uniquement les fichiers modifiés
    --deleted           Affiche uniquement les fichiers supprimés (pas dans socle)
    --content           Affiche le contenu des différences
    --no-color          Désactive les couleurs

${BOLD}LÉGENDE${NC}
    ${GREEN}+${NC} Nouveau dans le socle (à ajouter)
    ${YELLOW}~${NC} Modifié (différent du socle)
    ${RED}-${NC} Supprimé du socle (local uniquement)
    ${DIM}=${NC} Identique

${BOLD}EXEMPLES${NC}
    # Voir toutes les différences
    $(basename "$0") ./mon-projet

    # Voir uniquement les fichiers modifiés
    $(basename "$0") --modified ./mon-projet

    # Voir le contenu des différences
    $(basename "$0") --content ./mon-projet

EOF
}

show_version() {
    echo "claude-socle diff v${VERSION}"
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
            -q|--quiet)
                QUIET=true
                shift
                ;;
            --new)
                SHOW_ONLY="new"
                shift
                ;;
            --modified)
                SHOW_ONLY="modified"
                shift
                ;;
            --deleted)
                SHOW_ONLY="deleted"
                shift
                ;;
            --content)
                SHOW_CONTENT=true
                shift
                ;;
            --no-color)
                USE_COLOR=false
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
# Fonctions de comparaison
# =============================================================================

show_diff_content() {
    local file1="$1"
    local file2="$2"

    if command_exists colordiff && $USE_COLOR; then
        colordiff "$file1" "$file2" 2>/dev/null || true
    else
        diff "$file1" "$file2" 2>/dev/null || true
    fi
}

compare_file() {
    local socle_file="$1"
    local local_file="$2"
    local filename="$3"
    # shellcheck disable=SC2034  # Reserved for future category-based filtering
    local category="$4"

    if [[ -f "$local_file" ]]; then
        if [[ -f "$socle_file" ]]; then
            # Les deux fichiers existent
            if diff -q "$socle_file" "$local_file" > /dev/null 2>&1; then
                # Identiques
                ((IDENTICAL_FILES++)) || true
                if [[ "$SHOW_ONLY" == "all" ]] && ! $QUIET; then
                    echo -e "  ${DIM}= $filename${NC}"
                fi
            else
                # Modifiés
                ((MODIFIED_FILES++)) || true
                if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "modified" ]]; then
                    echo -e "  ${YELLOW}~ $filename${NC}"
                    if $SHOW_CONTENT; then
                        echo ""
                        show_diff_content "$local_file" "$socle_file"
                        echo ""
                    fi
                fi
            fi
        else
            # Supprimé du socle (existe localement mais pas dans socle)
            ((DELETED_FILES++)) || true
            if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "deleted" ]]; then
                echo -e "  ${RED}- $filename${NC} ${DIM}(local uniquement)${NC}"
            fi
        fi
    elif [[ -f "$socle_file" ]]; then
        # Nouveau dans le socle
        ((NEW_FILES++)) || true
        if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "new" ]]; then
            echo -e "  ${GREEN}+ $filename${NC} ${DIM}(nouveau)${NC}"
        fi
    fi
}

compare_commands() {
    section "Commandes (.claude/commands/)"

    local socle_dir="$SOCLE_DIR/.claude/commands"
    local local_dir="$TARGET_DIR/.claude/commands"

    # Créer une liste unique de tous les fichiers avec chemins relatifs
    local all_files=()

    # Fichiers du socle (récursif)
    if [[ -d "$socle_dir" ]]; then
        while IFS= read -r f; do
            # Calculer le chemin relatif
            local rel_path="${f#$socle_dir/}"
            all_files+=("$rel_path")
        done < <(find "$socle_dir" -name "*.md" -type f 2>/dev/null)
    fi

    # Fichiers locaux (récursif)
    if [[ -d "$local_dir" ]]; then
        while IFS= read -r f; do
            # Calculer le chemin relatif
            local rel_path="${f#$local_dir/}"
            all_files+=("$rel_path")
        done < <(find "$local_dir" -name "*.md" -type f 2>/dev/null)
    fi

    # Dédupliquer et trier
    local unique_files
    unique_files=$(printf '%s\n' "${all_files[@]}" | sort -u)

    # Comparer chaque fichier
    for rel_path in $unique_files; do
        compare_file "$socle_dir/$rel_path" "$local_dir/$rel_path" "$rel_path" "commands"
    done
}

compare_skills() {
    section "Skills (.claude/skills/)"

    local socle_dir="$SOCLE_DIR/.claude/skills"
    local local_dir="$TARGET_DIR/.claude/skills"

    # Créer une liste unique de tous les skills
    local all_skills=()

    # Skills du socle
    if [[ -d "$socle_dir" ]]; then
        for d in "$socle_dir/"*/; do
            [[ -d "$d" ]] && all_skills+=("$(basename "$d")")
        done
    fi

    # Skills locaux
    if [[ -d "$local_dir" ]]; then
        for d in "$local_dir/"*/; do
            [[ -d "$d" ]] && all_skills+=("$(basename "$d")")
        done
    fi

    # Dédupliquer et trier
    local unique_skills
    unique_skills=$(printf '%s\n' "${all_skills[@]}" | sort -u)

    # Comparer chaque skill
    for skillname in $unique_skills; do
        local socle_skill="$socle_dir/$skillname/SKILL.md"
        local local_skill="$local_dir/$skillname/SKILL.md"
        compare_file "$socle_skill" "$local_skill" "$skillname/SKILL.md" "skills"
    done
}

compare_settings() {
    section "Configuration"

    # settings.json
    compare_file \
        "$SOCLE_DIR/.claude/settings.json" \
        "$TARGET_DIR/.claude/settings.json" \
        "settings.json" \
        "config"

    # CLAUDE.md
    compare_file \
        "$SOCLE_DIR/CLAUDE.md" \
        "$TARGET_DIR/CLAUDE.md" \
        "CLAUDE.md" \
        "config"
}

print_summary() {
    echo ""
    separator "="
    echo "  Résumé des différences"
    separator "="
    echo ""

    # shellcheck disable=SC2034  # Used for summary display
    local total=$((NEW_FILES + MODIFIED_FILES + DELETED_FILES + IDENTICAL_FILES))

    echo -e "  ${GREEN}+ Nouveaux:${NC}    $NEW_FILES fichier(s) à ajouter"
    echo -e "  ${YELLOW}~ Modifiés:${NC}    $MODIFIED_FILES fichier(s) différent(s)"
    echo -e "  ${RED}- Supprimés:${NC}   $DELETED_FILES fichier(s) locaux uniquement"
    echo -e "  ${DIM}= Identiques:${NC}  $IDENTICAL_FILES fichier(s)"
    echo ""

    if [[ $NEW_FILES -gt 0 ]] || [[ $MODIFIED_FILES -gt 0 ]]; then
        info "Pour synchroniser: ./scripts/update.sh --force $TARGET_DIR"
    else
        success "Configuration à jour avec le socle!"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"

    # Vérifier le répertoire
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Le répertoire '$TARGET_DIR' n'existe pas"
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Vérifier qu'il y a une configuration
    if [[ ! -d "$TARGET_DIR/.claude" ]]; then
        error "Pas de configuration Claude trouvée dans '$TARGET_DIR'"
    fi

    title "Comparaison avec le socle"
    info "Projet: $TARGET_DIR"
    info "Socle:  $SOCLE_DIR"
    echo ""

    # Légende
    if [[ "$SHOW_ONLY" == "all" ]] && ! $QUIET; then
        echo -e "  ${DIM}Légende: ${GREEN}+ nouveau${NC}  ${YELLOW}~ modifié${NC}  ${RED}- supprimé${NC}  ${DIM}= identique${NC}"
        echo ""
    fi

    # Comparer
    compare_commands
    compare_skills
    compare_settings

    # Résumé
    print_summary

    # Code de sortie
    if [[ $NEW_FILES -gt 0 ]] || [[ $MODIFIED_FILES -gt 0 ]]; then
        exit 1  # Des différences existent
    else
        exit 0  # Synchronisé
    fi
}

main "$@"
