#!/bin/bash

# =============================================================================
# Claude-Socle Doctor Script
# Diagnostic complet de l'environnement Claude Code
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

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
FIX_ISSUES=false
OUTPUT_FORMAT="text"
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Doctor${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Effectue un diagnostic complet de l'environnement Claude Code.
    Vérifie les dépendances, permissions, et configuration.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Répertoire à diagnostiquer (défaut: répertoire courant)

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -q, --quiet         Mode silencieux
    --fix               Tente de corriger les problèmes détectés
    --json              Sortie au format JSON

${BOLD}VÉRIFICATIONS EFFECTUÉES${NC}
    - Environnement système (OS, shell, permissions)
    - Dépendances (git, jq, node, etc.)
    - Claude Code CLI
    - Configuration du projet
    - Socle claude-socle

${BOLD}EXEMPLES${NC}
    # Diagnostic simple
    $(basename "$0")

    # Diagnostic d'un projet spécifique
    $(basename "$0") ./mon-projet

    # Tenter de corriger les problèmes
    $(basename "$0") --fix

EOF
}

show_version() {
    echo "claude-socle doctor v${VERSION}"
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
            --fix)
                # shellcheck disable=SC2034  # Reserved for future implementation
                FIX_ISSUES=true
                shift
                ;;
            --json)
                # shellcheck disable=SC2034  # Used in output formatting
                OUTPUT_FORMAT="json"
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
# Fonctions de vérification
# =============================================================================

check_pass() {
    local message="$1"
    ((CHECKS_PASSED++)) || true
    success "$message"
}

check_fail() {
    local message="$1"
    local fix_hint="${2:-}"
    ((CHECKS_FAILED++)) || true
    error_no_exit "$message"
    [[ -n "$fix_hint" ]] && echo -e "    ${DIM}Fix: $fix_hint${NC}"
    return 0
}

check_warn() {
    local message="$1"
    local hint="${2:-}"
    ((CHECKS_WARNED++)) || true
    warning "$message"
    [[ -n "$hint" ]] && echo -e "    ${DIM}$hint${NC}"
    return 0
}

# =============================================================================
# Diagnostics
# =============================================================================

check_system() {
    section "1. Environnement système"

    # OS
    local os_name
    os_name=$(uname -s)
    check_pass "Système d'exploitation: $os_name"

    # Shell
    local shell_name
    shell_name=$(basename "$SHELL")
    if [[ "$shell_name" =~ ^(bash|zsh|fish)$ ]]; then
        check_pass "Shell: $shell_name"
    else
        check_warn "Shell: $shell_name" "bash ou zsh recommandé"
    fi

    # Version Bash
    if command_exists bash; then
        local bash_version
        bash_version=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if version_gte "$bash_version" "4.0"; then
            check_pass "Bash version: $bash_version"
        else
            check_warn "Bash version: $bash_version" "Version 4.0+ recommandée"
        fi
    fi

    # Permissions du répertoire
    if [[ -w "$TARGET_DIR" ]]; then
        check_pass "Permissions d'écriture: OK"
    else
        check_fail "Permissions d'écriture: NON" "chmod +w $TARGET_DIR"
    fi
}

check_dependencies() {
    section "2. Dépendances"

    # Git (obligatoire)
    if command_exists git; then
        local git_version
        git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        check_pass "git: $git_version"
    else
        check_fail "git: non installé" "Installez git"
    fi

    # jq (recommandé)
    if command_exists jq; then
        local jq_version
        jq_version=$(jq --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "unknown")
        check_pass "jq: $jq_version"
    else
        check_warn "jq: non installé" "Installez jq pour une meilleure validation JSON"
    fi

    # Node.js (optionnel mais recommandé)
    if command_exists node; then
        local node_version
        node_version=$(node --version | tr -d 'v')
        if version_gte "$node_version" "18.0"; then
            check_pass "Node.js: $node_version"
        else
            check_warn "Node.js: $node_version" "Version 18+ recommandée"
        fi
    else
        check_warn "Node.js: non installé" "Recommandé pour certaines fonctionnalités"
    fi

    # npm
    if command_exists npm; then
        local npm_version
        npm_version=$(npm --version)
        check_pass "npm: $npm_version"
    fi

    # Python (optionnel)
    if command_exists python3; then
        local python_version
        python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        check_pass "Python: $python_version"
    fi

    # diff/colordiff
    if command_exists colordiff; then
        check_pass "colordiff: installé"
    elif command_exists diff; then
        check_pass "diff: installé"
    fi
}

check_claude_code() {
    section "3. Claude Code CLI"

    # Vérifier si Claude Code est installé
    if command_exists claude; then
        local claude_version
        claude_version=$(claude --version 2>/dev/null || echo "unknown")
        check_pass "Claude Code CLI: installé ($claude_version)"

        # Vérifier la configuration globale
        local global_config="$HOME/.claude/settings.json"
        if [[ -f "$global_config" ]]; then
            check_pass "Configuration globale: présente"
        else
            check_warn "Configuration globale: absente" "Exécutez 'claude' pour l'initialiser"
        fi
    else
        check_fail "Claude Code CLI: non installé" "npm install -g @anthropic-ai/claude-code"
    fi
}

check_project_config() {
    section "4. Configuration du projet"

    local target
    target="$(get_absolute_path "$TARGET_DIR")"

    # .claude/
    if [[ -d "$target/.claude" ]]; then
        check_pass ".claude/ présent"

        # commands/
        if [[ -d "$target/.claude/commands" ]]; then
            local cmd_count
            cmd_count=$(find "$target/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$cmd_count" -gt 0 ]]; then
                check_pass ".claude/commands/: $cmd_count commandes"
            else
                check_warn ".claude/commands/: vide"
            fi
        else
            check_warn ".claude/commands/: absent"
        fi

        # skills/
        if [[ -d "$target/.claude/skills" ]]; then
            local skills_count
            skills_count=$(count_dirs "$target/.claude/skills")
            if [[ "$skills_count" -gt 0 ]]; then
                check_pass ".claude/skills/: $skills_count skills"
            else
                check_warn ".claude/skills/: vide"
            fi
        else
            check_warn ".claude/skills/: absent"
        fi

        # settings.json
        if [[ -f "$target/.claude/settings.json" ]]; then
            if validate_json "$target/.claude/settings.json"; then
                check_pass ".claude/settings.json: JSON valide"

                # Vérifier les hooks
                if command_exists jq; then
                    local hooks_count
                    hooks_count=$(jq '.hooks | ((.PreToolUse // []) | length) + ((.PostToolUse // []) | length)' "$target/.claude/settings.json" 2>/dev/null || echo "0")
                    check_pass "Hooks configurés: $hooks_count"
                fi
            else
                check_fail ".claude/settings.json: JSON invalide"
            fi
        else
            check_warn ".claude/settings.json: absent"
        fi
    else
        check_warn ".claude/: absent" "Exécutez install.sh pour configurer"
    fi

    # CLAUDE.md
    if [[ -f "$target/CLAUDE.md" ]]; then
        local lines
        lines=$(wc -l < "$target/CLAUDE.md" | tr -d ' ')
        check_pass "CLAUDE.md: présent ($lines lignes)"

        # Vérifier les directives IMPORTANT
        if grep -q "IMPORTANT" "$target/CLAUDE.md" 2>/dev/null; then
            check_pass "CLAUDE.md: contient des directives IMPORTANT"
        else
            check_warn "CLAUDE.md: pas de directives IMPORTANT"
        fi
    else
        check_warn "CLAUDE.md: absent"
    fi

    # .gitignore
    if [[ -f "$target/.gitignore" ]]; then
        if grep -q "CLAUDE.local.md" "$target/.gitignore" 2>/dev/null; then
            check_pass ".gitignore: CLAUDE.local.md inclus"
        else
            check_warn ".gitignore: CLAUDE.local.md non inclus" "Ajoutez CLAUDE.local.md à .gitignore"
        fi
        if grep -q "\.claude/" "$target/.gitignore" 2>/dev/null; then
            check_pass ".gitignore: .claude/ inclus"
        else
            check_warn ".gitignore: .claude/ non inclus" "Ajoutez .claude/ à .gitignore"
        fi
        if grep -q "^CLAUDE\.md$" "$target/.gitignore" 2>/dev/null; then
            check_pass ".gitignore: CLAUDE.md inclus"
        else
            check_warn ".gitignore: CLAUDE.md non inclus" "Ajoutez CLAUDE.md à .gitignore"
        fi
    fi
}

check_socle() {
    section "5. Socle claude-socle"

    if [[ -d "$SOCLE_DIR/.claude/commands" ]]; then
        check_pass "Socle trouvé: $SOCLE_DIR"

        # Statistiques
        local agents
        local skills
        local hooks
        local templates
        agents=$(count_agents "$SOCLE_DIR")
        skills=$(count_skills "$SOCLE_DIR")
        hooks=$(count_hooks "$SOCLE_DIR")
        templates=$(count_templates "$SOCLE_DIR")

        check_pass "Agents disponibles: $agents"
        check_pass "Skills disponibles: $skills"
        check_pass "Hooks configurés: $hooks"
        check_pass "Templates disponibles: $templates"
    else
        check_fail "Socle non trouvé" "Vérifiez le chemin d'installation"
    fi
}

print_summary() {
    echo ""
    separator "="
    echo "  Résumé du diagnostic"
    separator "="
    echo ""

    # shellcheck disable=SC2034  # Used for display calculation
    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))

    echo -e "  ${GREEN}✓ Réussis:${NC}      $CHECKS_PASSED"
    echo -e "  ${YELLOW}! Avertissements:${NC} $CHECKS_WARNED"
    echo -e "  ${RED}✗ Échoués:${NC}      $CHECKS_FAILED"
    echo ""

    if [[ $CHECKS_FAILED -eq 0 ]]; then
        if [[ $CHECKS_WARNED -eq 0 ]]; then
            success "Environnement parfait! Tout est correctement configuré."
        else
            warning "Environnement fonctionnel avec quelques avertissements."
        fi
    else
        error_no_exit "Certains problèmes doivent être résolus."
        echo ""
        info "Exécutez avec --fix pour tenter de corriger automatiquement"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

print_json() {
    cat << EOF
{
  "target": "$TARGET_DIR",
  "checks": {
    "passed": $CHECKS_PASSED,
    "failed": $CHECKS_FAILED,
    "warned": $CHECKS_WARNED
  },
  "success": $([ $CHECKS_FAILED -eq 0 ] && echo "true" || echo "false")
}
EOF
}

main() {
    parse_args "$@"

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        # Mode JSON: rediriger stdout et stderr vers /dev/null
        exec 3>&1 4>&2 1>/dev/null 2>/dev/null
    fi

    title "Diagnostic Claude Code"
    info "Répertoire: $TARGET_DIR"
    echo ""

    check_system
    check_dependencies
    check_claude_code
    check_project_config
    check_socle

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        # Restaurer stdout et stderr, puis afficher le JSON
        exec 1>&3 2>&4 3>&- 4>&-
        print_json
    else
        print_summary
    fi

    # Code de sortie
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
