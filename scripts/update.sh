#!/bin/bash

# =============================================================================
# Claude-Socle Update Script
# Met à jour les commandes Claude depuis le socle
# =============================================================================

set -euo pipefail

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# Version lue depuis le fichier VERSION
VERSION=$(cat "$SCRIPT_DIR/../VERSION" 2>/dev/null || echo "unknown")

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Activer le handler d'erreur et vérifier les prérequis
enable_error_handler
check_base_requirements

# =============================================================================
# Path constants
# =============================================================================

COMMANDS_SUBDIR=".claude/commands"
SKILLS_SUBDIR=".claude/skills"
AGENTS_SUBDIR=".claude/agents"
RULES_SUBDIR=".claude/rules"
STYLES_SUBDIR=".claude/output-styles"
TEMPLATES_SUBDIR=".claude/templates"

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
FORCE_UPDATE=false
BACKUP_ONLY=false
ADD_HOOK=""
UPDATE_SETTINGS=false
UPDATE_SKILLS=false
UPDATE_AGENTS=false
UPDATE_RULES=false
UPDATE_STYLES=false
UPDATE_TEMPLATES=false
CLEAN_BEFORE_UPDATE=false
DETECT_ORPHANS=false
REMOVE_ORPHANS=false
UPGRADE_CLAUDE_MD=false
RESTORE_BACKUP=""

# Compteurs
UPDATED=0
ADDED=0
SKIPPED=0
ORPHANS_FOUND=0
ORPHANS_REMOVED=0

# Temp files tracking for cleanup
_TEMP_FILES=()

# =============================================================================
# Cleanup trap
# =============================================================================

cleanup_temp_files() {
    for f in "${_TEMP_FILES[@]}"; do
        rm -f "$f" 2>/dev/null || true
    done
}
trap cleanup_temp_files EXIT

# Safe mktemp wrapper with error checking
safe_mktemp() {
    local tmp
    tmp=$(mktemp) || error "Cannot create temp file"
    _TEMP_FILES+=("$tmp")
    echo "$tmp"
}

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
    --upgrade-claude-md Migrer CLAUDE.md vers @imports (copie docs/reference/)
    --changelog         Affiche les nouveautés du socle
    --restore BACKUP    Restaure depuis un backup précédent
    --add-hook HOOK     Ajoute un hook au settings.json existant sans ecraser (ex: rtk)

${BOLD}HOOKS DISPONIBLES${NC}
    rtk                 RTK token optimizer (reduit les tokens de 60-90%, necessite: brew install rtk)

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

    # Restaurer depuis un backup
    $(basename "$0") --restore .claude/commands.backup.20240101_120000 ./mon-projet

    # Ajouter le hook RTK (token optimizer) sans ecraser settings.json
    $(basename "$0") --add-hook rtk ./mon-projet

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

# shellcheck disable=SC2034
# UPDATE_* and UPGRADE_* variables are used via ${!flag_name} indirection in main()
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
            --settings)       UPDATE_SETTINGS=true;    shift ;;
            --skills)         UPDATE_SKILLS=true;      shift ;;
            --agents)         UPDATE_AGENTS=true;      shift ;;
            --rules)          UPDATE_RULES=true;       shift ;;
            --styles)         UPDATE_STYLES=true;      shift ;;
            --templates)      UPDATE_TEMPLATES=true;   shift ;;
            --upgrade-claude-md) UPGRADE_CLAUDE_MD=true; shift ;;
            --all)
                UPDATE_SETTINGS=true
                UPDATE_SKILLS=true
                UPDATE_AGENTS=true
                UPDATE_RULES=true
                UPDATE_STYLES=true
                UPDATE_TEMPLATES=true
                UPGRADE_CLAUDE_MD=true
                CLEAN_BEFORE_UPDATE=true
                shift
                ;;
            --changelog)
                show_changelog
                exit 0
                ;;
            --add-hook)
                if [[ -z "${2:-}" ]]; then
                    error "Option --add-hook requiert un argument (nom du hook, ex: rtk)"
                fi
                ADD_HOOK="$2"
                shift 2
                ;;
            --restore)
                if [[ -z "${2:-}" ]]; then
                    error "Option --restore requiert un argument (chemin du backup)"
                fi
                RESTORE_BACKUP="$2"
                shift 2
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
    backup_dir="$TARGET_DIR/$COMMANDS_SUBDIR.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Backup → $backup_dir"
            # Set BACKUP_DIR even in DRY_RUN so downstream code doesn't break
            echo "$backup_dir"
        else
            cp -r "$TARGET_DIR/$COMMANDS_SUBDIR" "$backup_dir"
            success "Backup créé: $backup_dir"
            echo "$backup_dir"
        fi
    fi
}

restore_backup() {
    local backup_path="$1"

    # Resolve relative to TARGET_DIR if not absolute
    if [[ "$backup_path" != /* ]]; then
        backup_path="$TARGET_DIR/$backup_path"
    fi

    if [[ ! -d "$backup_path" ]]; then
        # List available backups
        info "Backups disponibles:"
        local found=false
        while IFS= read -r bdir; do
            if [[ -d "$bdir" ]]; then
                echo "  $(basename "$bdir")"
                found=true
            fi
        done < <(find "$TARGET_DIR/$COMMANDS_SUBDIR".backup.* -maxdepth 0 -type d 2>/dev/null | sort -r || true)

        if ! $found; then
            info "  (aucun backup trouvé)"
        fi

        error "Backup non trouvé: $backup_path"
    fi

    section "Restauration depuis backup"
    info "Source: $backup_path"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Restauration de $backup_path vers $TARGET_DIR/$COMMANDS_SUBDIR"
        return
    fi

    if [[ -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        # Create a safety backup before restoring
        local safety_backup
        safety_backup="$TARGET_DIR/$COMMANDS_SUBDIR.pre-restore.$(date +%Y%m%d_%H%M%S)"
        cp -r "$TARGET_DIR/$COMMANDS_SUBDIR" "$safety_backup"
        info "Backup de sécurité: $safety_backup"
    fi

    rm -rf "${TARGET_DIR:?}/${COMMANDS_SUBDIR:?}"
    cp -r "$backup_path" "$TARGET_DIR/$COMMANDS_SUBDIR"
    success "Restauration terminée depuis $(basename "$backup_path")"
}

update_command_file() {
    local src="$1"
    local rel_path="$2"  # Chemin relatif depuis commands/ (ex: work/work-explore.md)
    local filename
    filename=$(basename "$src")
    local dest="$TARGET_DIR/$COMMANDS_SUBDIR/$rel_path"

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
    if [[ ! -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        make_dir "$TARGET_DIR/$COMMANDS_SUBDIR"
    fi

    local before
    before=$(find "$TARGET_DIR/$COMMANDS_SUBDIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    # Parcourir récursivement les commandes du socle
    local socle_commands_dir="$SOCLE_DIR/$COMMANDS_SUBDIR"
    while IFS= read -r cmd; do
        if [[ -f "$cmd" ]]; then
            # Calculer le chemin relatif depuis commands/
            local rel_path="${cmd#"$socle_commands_dir"/}"
            update_command_file "$cmd" "$rel_path"
        fi
    done < <(find "$socle_commands_dir" -name "*.md" -type f 2>/dev/null || true)

    local after
    after=$(find "$TARGET_DIR/$COMMANDS_SUBDIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    info "Commandes: $before → $after"
}

add_hook() {
    local hook_name="$1"
    local settings_file="$TARGET_DIR/.claude/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        error "settings.json non trouve dans $TARGET_DIR/.claude/"
    fi

    if ! command -v jq &>/dev/null; then
        error "jq est requis pour --add-hook. Installez-le: https://jqlang.github.io/jq/download/"
    fi

    case "$hook_name" in
        rtk)
            section "Ajout du hook RTK (token optimizer)"

            # Check if hook already exists
            if jq -e '.hooks.PreToolUse[]? | select(.description | test("RTK"))' "$settings_file" >/dev/null 2>&1; then
                success "Hook RTK deja present dans settings.json"
                return
            fi

            local rtk_hook
            rtk_hook=$(cat <<'HOOKJSON'
{
    "description": "RTK token optimizer - reecrit les commandes pour reduire les tokens de 60-90% (installer rtk: brew install rtk)",
    "matcher": "Bash",
    "hooks": [
        {
            "type": "command",
            "command": "bash -c 'command -v rtk >/dev/null 2>&1 || exit 0; command -v jq >/dev/null 2>&1 || exit 0; INPUT=$(cat); CMD=$(echo \"$INPUT\" | jq -r \".tool_input.command // empty\"); [ -z \"$CMD\" ] && exit 0; REWRITTEN=$(rtk rewrite \"$CMD\" 2>/dev/null) || exit 0; [ \"$CMD\" = \"$REWRITTEN\" ] && exit 0; ORIGINAL_INPUT=$(echo \"$INPUT\" | jq -c \".tool_input\"); UPDATED_INPUT=$(echo \"$ORIGINAL_INPUT\" | jq --arg cmd \"$REWRITTEN\" \".command = \\$cmd\"); jq -n --argjson updated \"$UPDATED_INPUT\" \"{\\\"hookSpecificOutput\\\":{\\\"hookEventName\\\":\\\"PreToolUse\\\",\\\"permissionDecision\\\":\\\"allow\\\",\\\"permissionDecisionReason\\\":\\\"RTK auto-rewrite\\\",\\\"updatedInput\\\":\\$updated}}\"'",
            "timeout": 5000,
            "onFailure": "ignore"
        }
    ]
}
HOOKJSON
)

            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Ajout du hook RTK dans settings.json"
                return
            fi

            local tmp
            tmp=$(safe_mktemp)
            jq --argjson hook "$rtk_hook" '.hooks.PreToolUse += [$hook]' "$settings_file" > "$tmp"
            cp "$tmp" "$settings_file"
            rm -f "$tmp"
            success "Hook RTK ajoute a settings.json"
            info "Installez RTK: brew install rtk (ou cargo install --git https://github.com/rtk-ai/rtk)"
            ;;
        *)
            error "Hook inconnu: $hook_name. Hooks disponibles: rtk"
            ;;
    esac
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

# =============================================================================
# Generic directory update function (replaces update_skills/agents/rules/styles/templates)
# =============================================================================

# Count files in a source directory for a given type
_count_dir_files() {
    local src_dir="$1"
    local name="$2"

    case "$name" in
        templates)
            find "$src_dir" -type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) 2>/dev/null | wc -l | tr -d ' '
            ;;
        skills)
            count_dirs "$src_dir"
            ;;
        *)
            find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
            ;;
    esac
}

# Generic update for a .claude/ subdirectory
# Uses per-file diff checking to avoid overwriting user customizations.
# Arguments:
#   $1 - name: internal identifier (skills, agents, rules, styles, templates)
#   $2 - src_subdir: relative path from socle root (.claude/skills, etc.)
#   $3 - label: display name for messages (Skills, Agents, etc.)
update_directory() {
    local name="$1"
    local src_subdir="$2"
    local label="$3"

    section "Mise à jour des $label"

    local src_dir="$SOCLE_DIR/$src_subdir"
    local dest_dir="$TARGET_DIR/$src_subdir"

    if [[ ! -d "$src_dir" ]]; then
        warning "Répertoire $label source non trouvé"
        return
    fi

    make_dir "$dest_dir"

    local dir_updated=0
    local dir_added=0
    local dir_skipped=0
    local dir_identical=0

    # Find all files in source directory
    local find_pattern
    case "$name" in
        templates)
            find_pattern='-type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \)'
            ;;
        *)
            find_pattern='-type f -name "*.md"'
            ;;
    esac

    while IFS= read -r src_file; do
        if [[ ! -f "$src_file" ]]; then
            continue
        fi

        local rel_path="${src_file#"$src_dir"/}"
        local dest_file="$dest_dir/$rel_path"
        local filename
        filename=$(basename "$src_file")

        # Create subdirectory if needed
        local file_dest_dir
        file_dest_dir=$(dirname "$dest_file")
        if [[ ! -d "$file_dest_dir" ]] && ! $DRY_RUN; then
            mkdir -p "$file_dest_dir"
        fi

        if [[ -f "$dest_file" ]]; then
            # File exists — check if identical
            if diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
                debug "$rel_path: identique"
                ((dir_identical++)) || true
                continue
            fi

            # File differs
            if $FORCE_UPDATE; then
                if $DRY_RUN; then
                    echo -e "${DIM}[DRY-RUN]${NC} Mise à jour: $rel_path"
                else
                    cp "$src_file" "$dest_file"
                fi
                debug "  $rel_path mis à jour"
                ((dir_updated++)) || true
            elif ${NON_INTERACTIVE:-false}; then
                warning "  $rel_path ignoré (utilisez --force pour écraser)"
                ((dir_skipped++)) || true
            else
                echo ""
                prompt "$rel_path a été modifié. Que faire?"
                echo "  [y] Écraser  [n] Ignorer  [d] Voir le diff"
                read -r -n 1 choice
                echo

                case "$choice" in
                    d|D)
                        echo ""
                        echo -e "${DIM}--- Local${NC}"
                        echo -e "${DIM}+++ Socle${NC}"
                        diff "$dest_file" "$src_file" || true
                        echo ""
                        if confirm "Écraser $rel_path?" "n"; then
                            cp "$src_file" "$dest_file"
                            debug "  $rel_path mis à jour"
                            ((dir_updated++)) || true
                        else
                            warning "  $rel_path ignoré"
                            ((dir_skipped++)) || true
                        fi
                        ;;
                    y|Y)
                        cp "$src_file" "$dest_file"
                        debug "  $rel_path mis à jour"
                        ((dir_updated++)) || true
                        ;;
                    *)
                        warning "  $rel_path ignoré"
                        ((dir_skipped++)) || true
                        ;;
                esac
            fi
        else
            # New file
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Ajout: $rel_path"
            else
                cp "$src_file" "$dest_file"
            fi
            debug "  $rel_path ajouté (nouveau)"
            ((dir_added++)) || true
        fi
    done < <(eval "find \"$src_dir\" $find_pattern 2>/dev/null" || true)

    # Copy non-md files for skills (SKILL.md subdirs may have examples/, etc.)
    if [[ "$name" == "skills" ]]; then
        while IFS= read -r src_file; do
            local rel_path="${src_file#"$src_dir"/}"
            local dest_file="$dest_dir/$rel_path"
            local file_dest_dir
            file_dest_dir=$(dirname "$dest_file")
            if [[ ! -d "$file_dest_dir" ]] && ! $DRY_RUN; then
                mkdir -p "$file_dest_dir"
            fi
            if [[ ! -f "$dest_file" ]] || $FORCE_UPDATE; then
                if ! $DRY_RUN; then
                    cp "$src_file" "$dest_file"
                fi
            fi
        done < <(find "$src_dir" -type f ! -name "*.md" 2>/dev/null || true)
    fi

    local total=$((dir_added + dir_updated + dir_skipped + dir_identical))
    success "$label: $dir_added ajouté(s), $dir_updated mis à jour, $dir_identical identique(s), $dir_skipped ignoré(s)"
}


# =============================================================================
# CLAUDE.md upgrade
# =============================================================================

# Escape a string for safe use in awk comparisons
# Uses grep+sed instead of awk -v to avoid awk injection
_remove_section_from_file() {
    local file="$1"
    local section_title="$2"
    local tmp_cleaned
    tmp_cleaned=$(safe_mktemp)

    # Use grep -n to find the section start line, then sed to remove the block
    local start_line
    start_line=$(grep -nF "$section_title" "$file" | head -1 | cut -d: -f1)

    if [[ -z "$start_line" ]]; then
        # Section not found, copy as-is
        cp "$file" "$tmp_cleaned"
        echo "$tmp_cleaned"
        return
    fi

    # Find the next ## heading after start_line
    local end_line
    end_line=$(tail -n +"$((start_line + 1))" "$file" | grep -n "^## " | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        # end_line is relative to start_line+1, convert to absolute
        end_line=$((start_line + end_line))
        # Keep lines before section and from next section onward
        head -n "$((start_line - 1))" "$file" > "$tmp_cleaned"
        tail -n +"$end_line" "$file" >> "$tmp_cleaned"
    else
        # No next section: remove from start_line to end of file
        head -n "$((start_line - 1))" "$file" > "$tmp_cleaned"
    fi

    echo "$tmp_cleaned"
}

upgrade_claude_md() {
    section "Migration CLAUDE.md vers @imports"

    local claude_md="$TARGET_DIR/CLAUDE.md"

    # Vérifier que CLAUDE.md existe
    if [[ ! -f "$claude_md" ]]; then
        warning "CLAUDE.md non trouvé dans $TARGET_DIR"
        return
    fi

    # Copier docs/reference/ du socle vers le projet (toujours, pour mettre à jour)
    local src_ref="$SOCLE_DIR/docs/reference"
    local dest_ref="$TARGET_DIR/docs/reference"

    if [[ ! -d "$src_ref" ]]; then
        warning "docs/reference/ non trouvé dans le socle"
        return
    fi

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Copie docs/reference/"
        echo -e "${DIM}[DRY-RUN]${NC} Copie docs/ARCHITECTURE.md, docs/WORKFLOWS.md"
        echo -e "${DIM}[DRY-RUN]${NC} Copie docs/guides/"
        echo -e "${DIM}[DRY-RUN]${NC} Vérification @imports manquants"
        echo -e "${DIM}[DRY-RUN]${NC} Backup CLAUDE.md si modifications"
        return
    fi

    make_dir "$TARGET_DIR/docs"
    make_dir "$dest_ref"
    cp -r "$src_ref/"* "$dest_ref/"
    local ref_count
    ref_count=$(find "$dest_ref" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    success "docs/reference/ copié ($ref_count fichiers)"

    # Copier les docs supplementaires UNIQUEMENT si elles n'existent pas
    # Ces fichiers deviennent specifiques au projet une fois crees
    for doc_file in "docs/ARCHITECTURE.md" "docs/WORKFLOWS.md"; do
        if [[ -f "$SOCLE_DIR/$doc_file" ]]; then
            if [[ -f "$TARGET_DIR/$doc_file" ]]; then
                debug "Conservé (spécifique au projet): $doc_file"
            else
                cp "$SOCLE_DIR/$doc_file" "$TARGET_DIR/$doc_file"
                success "Créé (nouveau): $doc_file"
            fi
        fi
    done

    # Copier docs/guides/ — uniquement les nouveaux fichiers
    # Les guides existants sont conserves (potentiellement personnalises)
    if [[ -d "$SOCLE_DIR/docs/guides" ]]; then
        make_dir "$TARGET_DIR/docs/guides"
        local guides_added=0
        local guides_skipped=0
        while IFS= read -r guide_file; do
            local guide_rel="${guide_file#"$SOCLE_DIR"/docs/guides/}"
            local guide_dest="$TARGET_DIR/docs/guides/$guide_rel"
            if [[ -f "$guide_dest" ]]; then
                debug "Conservé (existant): docs/guides/$guide_rel"
                ((guides_skipped++)) || true
            else
                local guide_dest_dir
                guide_dest_dir=$(dirname "$guide_dest")
                [[ -d "$guide_dest_dir" ]] || mkdir -p "$guide_dest_dir"
                cp "$guide_file" "$guide_dest"
                debug "Ajouté: docs/guides/$guide_rel"
                ((guides_added++)) || true
            fi
        done < <(find "$SOCLE_DIR/docs/guides" -name "*.md" -type f 2>/dev/null || true)
        if [[ $guides_added -gt 0 ]]; then
            success "docs/guides/: $guides_added ajouté(s), $guides_skipped conservé(s)"
        else
            info "docs/guides/: $guides_skipped fichier(s) existant(s) conservé(s)"
        fi
    fi

    # Vérifier si @imports déjà présents
    if grep -q "@docs/reference/" "$claude_md" 2>/dev/null; then
        # Vérifier les @imports manquants et les ajouter
        local missing_imports=()
        local all_imports=(
            "@docs/reference/commands.md"
            "@docs/reference/project-structures.md"
            "@docs/reference/agents-catalog.md"
            "@docs/reference/hooks-reference.md"
            "@docs/reference/skills-catalog.md"
            "@docs/reference/advanced-features.md"
            "@docs/reference/best-practices.md"
        )

        for import in "${all_imports[@]}"; do
            if ! grep -qF "$import" "$claude_md" 2>/dev/null; then
                missing_imports+=("$import")
            fi
        done

        if [[ ${#missing_imports[@]} -eq 0 ]]; then
            success "CLAUDE.md contient tous les @imports"
            return
        fi

        # Ajouter les imports manquants
        info "Ajout de ${#missing_imports[@]} @import(s) manquant(s)..."

        # Backup
        local backup_file
        backup_file="${claude_md}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$claude_md" "$backup_file"

        # Trouver le dernier @import existant et ajouter après
        local last_import_line
        last_import_line=$(grep -n "@docs/reference/" "$claude_md" | tail -1 | cut -d: -f1)

        if [[ -n "$last_import_line" ]]; then
            local tmp_file
            tmp_file=$(safe_mktemp)
            head -n "$last_import_line" "$claude_md" > "$tmp_file"
            for import in "${missing_imports[@]}"; do
                echo "$import" >> "$tmp_file"
            done
            tail -n +"$((last_import_line + 1))" "$claude_md" >> "$tmp_file"
            mv "$tmp_file" "$claude_md"
            success "Ajouté: ${missing_imports[*]}"
        fi
        return
    fi

    # Créer un backup
    local backup_file
    backup_file="${claude_md}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$claude_md" "$backup_file"
    success "Backup créé: $backup_file"

    # Insérer les @imports après la première ligne vide (après le titre)
    local imports_block
    imports_block="@docs/reference/commands.md
@docs/reference/project-structures.md
@docs/reference/agents-catalog.md
@docs/reference/hooks-reference.md
@docs/reference/skills-catalog.md
@docs/reference/advanced-features.md
@docs/reference/best-practices.md"

    # Trouver la première ligne vide et insérer après
    local tmp_file
    tmp_file=$(safe_mktemp)
    local inserted=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        echo "$line" >> "$tmp_file"
        if [[ "$inserted" == false ]] && [[ -z "$line" ]]; then
            echo "$imports_block" >> "$tmp_file"
            echo "" >> "$tmp_file"
            inserted=true
        fi
    done < "$claude_md"

    # Si pas de ligne vide trouvée, ajouter à la fin
    if [[ "$inserted" == false ]]; then
        echo "" >> "$tmp_file"
        echo "$imports_block" >> "$tmp_file"
    fi

    cp "$tmp_file" "$claude_md"
    success "@imports insérés dans CLAUDE.md"

    # Détecter et proposer de supprimer les sections dupliquées
    local -a duplicate_sections=(
        "## Commandes Essentielles"
        "## Structure Recommandée"
        "## Structure Clean Architecture"
        "## Agents Recommandés"
    )

    local found_duplicates=false
    for section_title in "${duplicate_sections[@]}"; do
        if grep -qF "$section_title" "$claude_md" 2>/dev/null; then
            found_duplicates=true

            if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
                # Supprimer automatiquement la section
                local cleaned_file
                cleaned_file=$(_remove_section_from_file "$claude_md" "$section_title")
                cp "$cleaned_file" "$claude_md"
                success "Section supprimée: $section_title"
            else
                warning "Section dupliquée détectée: $section_title"
                if confirm "Supprimer cette section (remplacée par @imports)?" "y"; then
                    local cleaned_file
                    cleaned_file=$(_remove_section_from_file "$claude_md" "$section_title")
                    cp "$cleaned_file" "$claude_md"
                    success "Section supprimée: $section_title"
                else
                    info "Section conservée: $section_title"
                fi
            fi
        fi
    done

    if ! $found_duplicates; then
        info "Aucune section dupliquée détectée"
    fi
}

# =============================================================================
# Orphan detection
# =============================================================================

detect_orphan_files() {
    local subdir="$1"
    local target_dir="$TARGET_DIR/.claude/$subdir"
    local socle_dir="$SOCLE_DIR/.claude/$subdir"

    if [[ ! -d "$target_dir" ]]; then
        return
    fi

    # Trouver les fichiers dans le target (md, tf, yaml, yml, json)
    while IFS= read -r target_file; do
        if [[ -f "$target_file" ]]; then
            # Calculer le chemin relatif
            local rel_path="${target_file#"$target_dir"/}"
            local socle_file="$socle_dir/$rel_path"

            # Verifier si le fichier existe dans le socle (also check for renames by basename)
            if [[ ! -f "$socle_file" ]]; then
                ((ORPHANS_FOUND++)) || true
                local filename
                filename=$(basename "$target_file")

                # Check if the file might have been renamed (same basename exists elsewhere in socle)
                local possible_rename=""
                if [[ -d "$socle_dir" ]]; then
                    possible_rename=$(find "$socle_dir" -name "$filename" -type f 2>/dev/null | head -1 || true)
                fi

                if [[ -n "$possible_rename" ]]; then
                    local socle_rel="${possible_rename#"$socle_dir"/}"
                    info "  $filename peut-être déplacé vers $socle_rel dans le socle"
                fi

                if $REMOVE_ORPHANS; then
                    if $DRY_RUN; then
                        echo -e "${DIM}[DRY-RUN]${NC} Suppression orphelin: $subdir/$rel_path"
                    else
                        rm -f "$target_file"
                        ((ORPHANS_REMOVED++)) || true
                    fi
                    warning "  $filename supprimé (orphelin)"
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
                            warning "  $filename supprimé"
                            ;;
                        *)
                            info "  $filename conservé"
                            ;;
                    esac
                fi
            fi
        fi
    done < <(find "$target_dir" -type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) 2>/dev/null || true)

    # Nettoyer les repertoires vides (including non-empty orphan dirs with only orphan files already removed)
    if $REMOVE_ORPHANS && ! $DRY_RUN; then
        find "$target_dir" -type d -empty -delete 2>/dev/null || true
    fi
}

detect_all_orphans() {
    section "Détection des fichiers orphelins"

    local dirs_to_check=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_check[@]}"; do
        if [[ -d "$TARGET_DIR/.claude/$subdir" ]]; then
            debug "Vérification de .claude/$subdir"
            detect_orphan_files "$subdir"
        fi
    done

    if [[ $ORPHANS_FOUND -eq 0 ]]; then
        success "Aucun fichier orphelin détecté"
    else
        if $REMOVE_ORPHANS; then
            success "$ORPHANS_REMOVED/$ORPHANS_FOUND fichier(s) orphelin(s) supprimé(s)"
        else
            warning "$ORPHANS_FOUND fichier(s) orphelin(s) détecté(s)"
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
        echo "  Orphelins:  $ORPHANS_FOUND (${ORPHANS_REMOVED} supprimé(s))"
    fi
    echo ""

    if [[ -n "${BACKUP_DIR:-}" ]] && [[ -d "${BACKUP_DIR:-}" ]]; then
        info "Backup disponible: $BACKUP_DIR"
        echo ""
    fi
}

# =============================================================================
# Main — data-driven optional updates
# =============================================================================

main() {
    parse_args "$@"

    # Vérifications
    if [[ ! -d "$TARGET_DIR/.claude" ]]; then
        error "Pas de configuration Claude trouvée dans '$TARGET_DIR'. Utilisez install.sh d'abord."
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Handle --restore
    if [[ -n "$RESTORE_BACKUP" ]]; then
        restore_backup "$RESTORE_BACKUP"
        exit 0
    fi

    # Handle --add-hook
    if [[ -n "$ADD_HOOK" ]]; then
        add_hook "$ADD_HOOK"
        exit 0
    fi

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

    # Ajouter CLAUDE.md s'il est absent
    if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Ajout: CLAUDE.md"
        else
            cp "$SOCLE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        fi
        success "CLAUDE.md ajouté (absent du projet)"
    fi

    # Data-driven optional updates
    # Format: flag_name|type|confirm_message|args...
    # type=settings: calls update_settings
    # type=dir: calls update_directory with remaining args (name|subdir|label)
    # type=claude_md: calls upgrade_claude_md
    local -a update_entries=(
        "UPDATE_SETTINGS|settings|Mettre à jour .claude/settings.json?"
        "UPDATE_SKILLS|dir|Mettre à jour .claude/skills/?|skills|$SKILLS_SUBDIR|Skills"
        "UPDATE_AGENTS|dir|Mettre à jour .claude/agents/?|agents|$AGENTS_SUBDIR|Agents"
        "UPDATE_RULES|dir|Mettre à jour .claude/rules/?|rules|$RULES_SUBDIR|Rules"
        "UPDATE_STYLES|dir|Mettre à jour .claude/output-styles/?|styles|$STYLES_SUBDIR|Output-styles"
        "UPDATE_TEMPLATES|dir|Mettre à jour .claude/templates/?|templates|$TEMPLATES_SUBDIR|Templates"
        "UPGRADE_CLAUDE_MD|claude_md|Migrer CLAUDE.md vers @imports (docs/reference/)?"
    )

    for entry in "${update_entries[@]}"; do
        IFS='|' read -r flag_name entry_type confirm_msg arg1 arg2 arg3 <<< "$entry"
        local flag_value="${!flag_name}"
        local should_run=false

        if [[ "$flag_value" == "true" ]]; then
            should_run=true
        elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
            echo ""
            if confirm "$confirm_msg" "n"; then
                should_run=true
            fi
        fi

        if $should_run; then
            case "$entry_type" in
                settings)  update_settings ;;
                dir)       update_directory "$arg1" "$arg2" "$arg3" ;;
                claude_md) upgrade_claude_md ;;
            esac
        fi
    done

    # Detection des fichiers orphelins
    if $DETECT_ORPHANS; then
        detect_all_orphans
    fi

    # Résumé
    print_summary
}

main "$@"
