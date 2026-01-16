#!/bin/bash

# =============================================================================
# Claude-Socle Validation Script
# Valide la configuration Claude Code d'un projet
# =============================================================================

set -euo pipefail

VERSION="1.1.0"

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
OUTPUT_FORMAT="text"  # text, json, score
ERRORS=0
WARNINGS=0
SCORE=0
MAX_SCORE=0

# Pour la sortie JSON
declare -a JSON_ERRORS=()
declare -a JSON_WARNINGS=()
declare -a JSON_SUCCESS=()

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Validate${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Valide la configuration Claude Code d'un projet.
    Vérifie la structure, les fichiers et la cohérence.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire à valider (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -q, --quiet         Mode silencieux (code de sortie uniquement)
    --json              Sortie au format JSON
    --score             Affiche uniquement le score de maturité
    --verbose           Mode verbeux (debug)

${BOLD}EXEMPLES${NC}
    # Validation standard
    $(basename "$0") ./mon-projet

    # Sortie JSON pour CI/CD
    $(basename "$0") --json ./mon-projet

    # Score uniquement
    $(basename "$0") --score ./mon-projet

${BOLD}CODES DE SORTIE${NC}
    0   Configuration valide
    1   Erreurs détectées
    2   Avertissements uniquement

EOF
}

show_version() {
    echo "claude-socle validate v${VERSION}"
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
                export QUIET=true
                shift
                ;;
            --json)
                OUTPUT_FORMAT="json"
                shift
                ;;
            --score)
                OUTPUT_FORMAT="score"
                shift
                ;;
            --verbose)
                export VERBOSE=true
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
# Fonctions de validation avec tracking
# =============================================================================

add_error() {
    local message="$1"
    local category="${2:-general}"
    ((ERRORS++)) || true
    JSON_ERRORS+=("{\"category\": \"$category\", \"message\": \"$message\"}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && error_no_exit "$message"
    return 0
}

add_warning() {
    local message="$1"
    local category="${2:-general}"
    ((WARNINGS++)) || true
    JSON_WARNINGS+=("{\"category\": \"$category\", \"message\": \"$message\"}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && warning "$message"
    return 0
}

add_success() {
    local message="$1"
    local category="${2:-general}"
    local points="${3:-1}"
    ((SCORE += points)) || true
    JSON_SUCCESS+=("{\"category\": \"$category\", \"message\": \"$message\", \"points\": $points}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && success "$message"
    return 0
}

add_check() {
    local points="${1:-1}"
    ((MAX_SCORE += points)) || true
}

# =============================================================================
# Validations
# =============================================================================

validate_structure() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "1. Structure de base"

    # CLAUDE.md
    add_check 2
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        add_success "CLAUDE.md présent" "structure" 1

        # Vérifier le contenu minimum
        add_check 1
        if grep -q "IMPORTANT" "$TARGET_DIR/CLAUDE.md" 2>/dev/null; then
            add_success "CLAUDE.md contient des directives IMPORTANT" "structure" 1
        else
            add_warning "CLAUDE.md ne contient pas de directives IMPORTANT" "structure"
        fi
    else
        add_error "CLAUDE.md manquant" "structure"
    fi

    # .claude/
    add_check 1
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        add_success ".claude/ présent" "structure" 1
    else
        add_error ".claude/ manquant" "structure"
    fi

    # .claude/commands/
    add_check 2
    if [[ -d "$TARGET_DIR/.claude/commands" ]]; then
        # Utiliser find récursif pour compter les fichiers dans les sous-répertoires
        local cmd_count
        cmd_count=$(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$cmd_count" -gt 0 ]]; then
            add_success ".claude/commands/ contient $cmd_count commande(s)" "structure" 2
        else
            add_warning ".claude/commands/ est vide" "structure"
        fi
    else
        add_warning ".claude/commands/ manquant" "structure"
    fi

    # .claude/settings.json
    add_check 2
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]]; then
        add_success ".claude/settings.json présent" "structure" 1

        # Valider JSON
        if validate_json "$TARGET_DIR/.claude/settings.json"; then
            add_success ".claude/settings.json est un JSON valide" "structure" 1
        else
            add_error ".claude/settings.json JSON invalide" "structure"
        fi
    else
        add_warning ".claude/settings.json manquant" "structure"
    fi
}

validate_commands() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "2. Commandes standard"

    # Les commandes sont maintenant dans des sous-répertoires par catégorie
    local standard_commands=("work/work-explore" "work/work-plan" "work/work-commit" "qa/qa-review")

    for cmd in "${standard_commands[@]}"; do
        add_check 1
        local cmd_name
        cmd_name=$(basename "$cmd")
        if [[ -f "$TARGET_DIR/.claude/commands/$cmd.md" ]]; then
            add_success "Commande $cmd_name présente" "commands" 1
        else
            add_warning "Commande $cmd_name manquante (recommandée)" "commands"
        fi
    done
}

validate_skills() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "3. Skills"

    add_check 2
    if [[ -d "$TARGET_DIR/.claude/skills" ]]; then
        local skills_count
        skills_count=$(find "$TARGET_DIR/.claude/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$skills_count" -gt 0 ]]; then
            add_success ".claude/skills/ contient $skills_count skill(s)" "skills" 2

            # Valider le format YAML des skills
            add_check 1
            local valid_skills=0
            local total_skills=0
            for skill_dir in "$TARGET_DIR/.claude/skills/"*/; do
                if [[ -d "$skill_dir" ]]; then
                    ((total_skills++)) || true
                    local skill_file="$skill_dir/SKILL.md"
                    if [[ -f "$skill_file" ]]; then
                        # Vérifier la présence du frontmatter YAML
                        if head -1 "$skill_file" | grep -q "^---"; then
                            ((valid_skills++)) || true
                        fi
                    fi
                fi
            done
            if [[ "$total_skills" -gt 0 ]] && [[ "$valid_skills" -eq "$total_skills" ]]; then
                add_success "Tous les skills ont un frontmatter YAML valide" "skills" 1
            elif [[ "$valid_skills" -gt 0 ]]; then
                add_warning "$valid_skills/$total_skills skills avec frontmatter YAML valide" "skills"
            fi
        else
            add_warning ".claude/skills/ est vide" "skills"
        fi
    else
        add_warning ".claude/skills/ manquant" "skills"
    fi
}

validate_hooks() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "4. Hooks"

    add_check 2
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]] && command_exists jq; then
        local hooks_count
        hooks_count=$(jq '.hooks | ((.PreToolUse // []) | length) + ((.PostToolUse // []) | length)' "$TARGET_DIR/.claude/settings.json" 2>/dev/null || echo "0")
        if [[ "$hooks_count" -gt 0 ]]; then
            add_success "$hooks_count hook(s) configuré(s) dans settings.json" "hooks" 2
        else
            add_warning "Aucun hook configuré dans settings.json" "hooks"
        fi
    fi
}

validate_command_files() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "5. Validation des fichiers de commandes"

    local checked=0
    local valid=0

    # Recherche récursive dans tous les sous-répertoires
    while IFS= read -r cmd_file; do
        if [[ -f "$cmd_file" ]]; then
            ((checked++)) || true
            local filename
            filename=$(basename "$cmd_file")
            local is_valid=true

            # Vérifier que le fichier n'est pas vide
            if [[ ! -s "$cmd_file" ]]; then
                add_error "$filename est vide" "command_files"
                is_valid=false
                continue
            fi

            # Vérifier la présence d'un titre
            if ! head -1 "$cmd_file" | grep -q "^#"; then
                add_warning "$filename n'a pas de titre (# ...)" "command_files"
                is_valid=false
            fi

            $is_valid && { ((valid++)) || true; }
        fi
    done < <(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null)

    add_check 2
    if [[ "$checked" -gt 0 ]]; then
        if [[ "$valid" -eq "$checked" ]]; then
            add_success "$checked fichiers de commandes valides" "command_files" 2
        else
            add_success "$valid/$checked fichiers de commandes valides" "command_files" 1
        fi
    fi
}

validate_security() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "6. Sécurité"

    # Vérifier .gitignore pour CLAUDE.local.md
    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_success "CLAUDE.local.md dans .gitignore" "security" 1
        else
            add_warning "CLAUDE.local.md devrait être dans .gitignore" "security"
        fi
    else
        add_warning ".gitignore manquant" "security"
    fi

    # Vérifier les permissions dangereuses
    add_check 1
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]]; then
        if grep -q '"deny"' "$TARGET_DIR/.claude/settings.json" 2>/dev/null; then
            if grep -A10 '"deny"' "$TARGET_DIR/.claude/settings.json" | grep -q "rm -rf"; then
                add_success "rm -rf bloqué dans les permissions" "security" 1
            else
                add_warning "rm -rf n'est pas explicitement bloqué" "security"
            fi
        else
            add_warning "Pas de liste 'deny' dans les permissions" "security"
        fi
    fi
}

validate_coherence() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "7. Cohérence CLAUDE.md ↔ Commandes"

    add_check 2
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]] && [[ -d "$TARGET_DIR/.claude/commands" ]]; then
        # Extraire uniquement les commandes du socle mentionnées dans CLAUDE.md
        # Patterns: /work-*, /dev-*, /qa-*, /ops-*, /doc-*, /biz-*, /growth-*, /data-*, /legal-*, /assistant
        local mentioned_commands
        mentioned_commands=$(grep -oE '/(work|dev|qa|ops|doc|biz|growth|data|legal)-[a-z0-9-]+|/assistant' "$TARGET_DIR/CLAUDE.md" 2>/dev/null | sort -u || true)

        local missing=0
        local found=0
        for cmd in $mentioned_commands; do
            local cmd_name="${cmd#/}"
            # Chercher récursivement dans les sous-répertoires
            if find "$TARGET_DIR/.claude/commands" -name "$cmd_name.md" -type f 2>/dev/null | grep -q .; then
                ((found++)) || true
            else
                ((missing++)) || true
                debug "Commande mentionnée mais non trouvée: $cmd_name"
            fi
        done

        if [[ "$missing" -eq 0 ]] && [[ "$found" -gt 0 ]]; then
            add_success "Toutes les commandes documentées existent ($found)" "coherence" 2
        elif [[ "$found" -gt 0 ]]; then
            add_warning "$missing commande(s) mentionnée(s) dans CLAUDE.md non trouvée(s)" "coherence"
            add_success "$found commandes cohérentes" "coherence" 1
        fi
    fi
}

# =============================================================================
# Sortie des résultats
# =============================================================================

output_text_summary() {
    echo ""
    separator "="
    echo "  Résumé de la validation"
    separator "="
    echo ""

    # Score de maturité
    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi

    echo -e "  Score de maturité: ${BOLD}$SCORE/$MAX_SCORE${NC} ($percentage%)"
    echo ""

    # Barre de progression
    local bar_width=40
    local filled=$((percentage * bar_width / 100))
    local empty=$((bar_width - filled))
    printf "  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]\n"
    echo ""

    if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        success "Configuration valide! Aucun problème détecté."
    elif [[ $ERRORS -eq 0 ]]; then
        warning "Configuration valide avec $WARNINGS avertissement(s)"
    else
        error_no_exit "Configuration invalide: $ERRORS erreur(s), $WARNINGS avertissement(s)"
    fi

    echo ""
}

output_json() {
    local errors_json
    local warnings_json
    local success_json

    # Construire les tableaux JSON
    if [[ ${#JSON_ERRORS[@]} -gt 0 ]]; then
        errors_json=$(printf '%s,' "${JSON_ERRORS[@]}")
        errors_json="[${errors_json%,}]"
    else
        errors_json="[]"
    fi

    if [[ ${#JSON_WARNINGS[@]} -gt 0 ]]; then
        warnings_json=$(printf '%s,' "${JSON_WARNINGS[@]}")
        warnings_json="[${warnings_json%,}]"
    else
        warnings_json="[]"
    fi

    if [[ ${#JSON_SUCCESS[@]} -gt 0 ]]; then
        success_json=$(printf '%s,' "${JSON_SUCCESS[@]}")
        success_json="[${success_json%,}]"
    else
        success_json="[]"
    fi

    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi

    cat << EOF
{
  "valid": $([[ $ERRORS -eq 0 ]] && echo "true" || echo "false"),
  "errors_count": $ERRORS,
  "warnings_count": $WARNINGS,
  "score": $SCORE,
  "max_score": $MAX_SCORE,
  "percentage": $percentage,
  "errors": $errors_json,
  "warnings": $warnings_json,
  "success": $success_json
}
EOF
}

output_score() {
    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi
    echo "$SCORE/$MAX_SCORE ($percentage%)"
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

    # En-tête (sauf JSON et score)
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        title "Validation Claude Code Configuration"
        info "Projet: $TARGET_DIR"
    fi

    # Exécuter les validations
    validate_structure
    validate_commands
    validate_skills
    validate_hooks
    validate_command_files
    validate_security
    validate_coherence

    # Sortie selon le format
    case "$OUTPUT_FORMAT" in
        json)
            output_json
            ;;
        score)
            output_score
            ;;
        text)
            output_text_summary
            ;;
    esac

    # Code de sortie
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        exit 0  # Warnings ne sont pas bloquants
    else
        exit 0
    fi
}

main "$@"
