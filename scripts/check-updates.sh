#!/bin/bash

# =============================================================================
# Claude-Socle Check Updates
# Verifie les mises a jour disponibles (Claude Code CLI, skills communautaires)
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # SOCLE_DIR used by common.sh
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Activer le handler d'erreur et verifier les prerequis
enable_error_handler
check_base_requirements

# =============================================================================
# Variables
# =============================================================================

OUTPUT_FORMAT="text"
FORCE_REFRESH=false
CHECK_CLI=true
CHECK_SKILLS=true
TIMEOUT=10
CACHE_TTL="${CHECK_UPDATES_TTL:-$CACHE_DEFAULT_TTL}"

# Resultats
CLI_LOCAL_VERSION=""
CLI_REMOTE_VERSION=""
CLI_STATUS=""  # up_to_date | update_available | error | not_installed
CLI_RELEASE_URL=""
# shellcheck disable=SC2034  # Reserved for future use
SKILLS_NEW=()
SKILLS_STATUS=""  # ok | error | skipped

UPDATES_AVAILABLE=0
ERRORS_COUNT=0

# GitHub API
GITHUB_API="https://api.github.com/repos/anthropics/claude-code/releases/latest"

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Check Updates${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Verifie les mises a jour disponibles pour Claude Code CLI
    et les nouveaux skills communautaires sur skills.sh.

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -q, --quiet         Mode silencieux (affiche uniquement si mises a jour)
    --json              Sortie au format JSON
    --force             Ignorer le cache et forcer la verification
    --no-cli            Ne pas verifier Claude Code CLI
    --no-skills         Ne pas verifier skills.sh
    --timeout N         Timeout reseau en secondes (defaut: 10)

${BOLD}VARIABLES D'ENVIRONNEMENT${NC}
    GITHUB_TOKEN        Token GitHub pour augmenter le rate limit API
    CHECK_UPDATES_TTL   Duree du cache en secondes (defaut: 86400 = 24h)

${BOLD}CODES DE RETOUR${NC}
    0   Tout est a jour
    1   Mises a jour disponibles
    2   Erreur lors de la verification

${BOLD}EXEMPLES${NC}
    # Verification complete
    $(basename "$0")

    # Sortie JSON pour CI/CD
    $(basename "$0") --json

    # CLI uniquement, sans cache
    $(basename "$0") --no-skills --force

    # Mode silencieux (pour hooks)
    $(basename "$0") --quiet

EOF
}

show_version() {
    echo "claude-socle check-updates v${VERSION}"
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
            --force)
                FORCE_REFRESH=true
                shift
                ;;
            --no-cli)
                CHECK_CLI=false
                shift
                ;;
            --no-skills)
                CHECK_SKILLS=false
                shift
                ;;
            --timeout)
                if [[ -z "${2:-}" ]]; then
                    error "L'option --timeout necessite un argument"
                fi
                TIMEOUT="$2"
                shift 2
                ;;
            -*)
                error "Option inconnue: $1\nUtilisez --help pour l'aide."
                ;;
            *)
                error "Argument inattendu: $1\nUtilisez --help pour l'aide."
                ;;
        esac
    done
}

# =============================================================================
# Verification Claude Code CLI [US1]
# =============================================================================

check_cli_version() {
    section "Claude Code CLI"

    # Version locale
    if command_exists claude; then
        local raw_version
        raw_version=$(claude --version 2>/dev/null || echo "")
        # Extraire le numero de version (format: "Claude Code vX.Y.Z" ou "X.Y.Z")
        CLI_LOCAL_VERSION=$(echo "$raw_version" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [[ -z "$CLI_LOCAL_VERSION" ]]; then
            CLI_LOCAL_VERSION="inconnu"
        fi
        info "Version locale: $CLI_LOCAL_VERSION"
    else
        CLI_STATUS="not_installed"
        warning "Claude Code CLI non installe"
        echo -e "    ${DIM}Installation: npm install -g @anthropic-ai/claude-code${NC}"
        ((ERRORS_COUNT++)) || true
        return 0
    fi

    # Version distante (cache ou reseau)
    local cache_key="cli-version"

    if [[ "$FORCE_REFRESH" == "false" ]] && cache_valid "$cache_key" "$CACHE_TTL"; then
        CLI_REMOTE_VERSION=$(cache_read "$cache_key")
        debug "Version distante (cache): $CLI_REMOTE_VERSION"
    else
        debug "Requete GitHub API..."
        local curl_opts=(-s --max-time "$TIMEOUT" -L)

        # Utiliser le token GitHub si disponible
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            curl_opts+=(-H "Authorization: Bearer $GITHUB_TOKEN")
        fi

        local response
        if response=$(curl "${curl_opts[@]}" "$GITHUB_API" 2>/dev/null); then
            # Extraire tag_name du JSON
            CLI_REMOTE_VERSION=$(echo "$response" | grep -oE '"tag_name"\s*:\s*"[^"]*"' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

            if [[ -n "$CLI_REMOTE_VERSION" ]]; then
                cache_write "$cache_key" "$CLI_REMOTE_VERSION"
                debug "Version distante (reseau): $CLI_REMOTE_VERSION"
            else
                CLI_STATUS="error"
                warning "Impossible d'extraire la version depuis GitHub"
                ((ERRORS_COUNT++)) || true
                return 0
            fi

            # Extraire l'URL de release
            CLI_RELEASE_URL=$(echo "$response" | grep -oE '"html_url"\s*:\s*"[^"]*"' | head -1 | sed 's/"html_url"\s*:\s*"//;s/"//')
        else
            CLI_STATUS="error"
            warning "Impossible de contacter GitHub (hors ligne ou rate limit)"
            # Tenter le cache meme expire
            if CLI_REMOTE_VERSION=$(cache_read "$cache_key" 2>/dev/null); then
                info "Derniere version connue (cache expire): $CLI_REMOTE_VERSION"
            fi
            ((ERRORS_COUNT++)) || true
            return 0
        fi
    fi

    # Comparaison
    if [[ -z "$CLI_REMOTE_VERSION" || "$CLI_LOCAL_VERSION" == "inconnu" ]]; then
        CLI_STATUS="error"
        ((ERRORS_COUNT++)) || true
        return 0
    fi

    if version_gte "$CLI_LOCAL_VERSION" "$CLI_REMOTE_VERSION"; then
        CLI_STATUS="up_to_date"
        success "A jour ($CLI_LOCAL_VERSION)"
    else
        CLI_STATUS="update_available"
        warning "Mise a jour disponible: $CLI_LOCAL_VERSION -> $CLI_REMOTE_VERSION"
        if [[ -n "$CLI_RELEASE_URL" ]]; then
            echo -e "    ${DIM}Release: $CLI_RELEASE_URL${NC}"
        fi
        echo -e "    ${DIM}Commande: npm update -g @anthropic-ai/claude-code${NC}"
        ((UPDATES_AVAILABLE++)) || true
    fi
}

# =============================================================================
# Verification skills communautaires [US3]
# =============================================================================

check_skills() {
    section "Skills communautaires (skills.sh)"

    local cache_key="skills"
    local skills_url="https://skills.sh"

    if [[ "$FORCE_REFRESH" == "false" ]] && cache_valid "$cache_key" "$CACHE_TTL"; then
        debug "Skills (cache): utilisation du cache"
        SKILLS_STATUS="ok"
        info "Derniere verification: cache valide (utilisez --force pour rafraichir)"
        return 0
    fi

    debug "Requete skills.sh..."
    local curl_opts=(-s --max-time "$TIMEOUT" -L)

    local response
    if response=$(curl "${curl_opts[@]}" "$skills_url" 2>/dev/null); then
        # Extraire les skills de la page (parsing basique)
        # Format attendu: liens vers des skills avec noms et descriptions
        local skills_count
        skills_count=$(echo "$response" | grep -ciE 'skill|claude' || echo "0")

        if [[ "$skills_count" -gt 0 ]]; then
            SKILLS_STATUS="ok"
            cache_write "$cache_key" "checked"
            success "skills.sh accessible ($skills_count references trouvees)"
            echo -e "    ${DIM}Parcourir: $skills_url${NC}"
        else
            SKILLS_STATUS="ok"
            cache_write "$cache_key" "checked"
            info "Aucun nouveau skill detecte"
        fi
    else
        SKILLS_STATUS="error"
        warning "Impossible de contacter skills.sh"
        echo -e "    ${DIM}Verifiez votre connexion ou reessayez plus tard${NC}"
        ((ERRORS_COUNT++)) || true
    fi
}

# =============================================================================
# Rapport texte [US2]
# =============================================================================

print_report() {
    echo ""
    separator "="
    echo -e "  ${BOLD}Resume de la verification${NC}"
    separator "="
    echo ""

    if [[ $UPDATES_AVAILABLE -eq 0 && $ERRORS_COUNT -eq 0 ]]; then
        success "Tout est a jour!"
    elif [[ $UPDATES_AVAILABLE -gt 0 ]]; then
        warning "$UPDATES_AVAILABLE mise(s) a jour disponible(s)"
    fi

    if [[ $ERRORS_COUNT -gt 0 ]]; then
        error_no_exit "$ERRORS_COUNT verification(s) en erreur"
    fi

    echo ""
    echo -e "  ${DIM}Cache: ${CACHE_DIR}${NC}"
    echo -e "  ${DIM}TTL: $((CACHE_TTL / 3600))h (--force pour ignorer)${NC}"
    echo ""
}

# =============================================================================
# Sortie JSON [US5]
# =============================================================================

print_json() {
    local status="up_to_date"
    if [[ $UPDATES_AVAILABLE -gt 0 ]]; then
        status="updates_available"
    elif [[ $ERRORS_COUNT -gt 0 ]]; then
        status="error"
    fi

    local now
    now=$(date +%s)

    cat << JSONEOF
{
  "status": "$status",
  "timestamp": $now,
  "updates_available": $UPDATES_AVAILABLE,
  "errors": $ERRORS_COUNT,
  "cli": {
    "local_version": "${CLI_LOCAL_VERSION:-null}",
    "remote_version": "${CLI_REMOTE_VERSION:-null}",
    "status": "${CLI_STATUS:-skipped}",
    "release_url": "${CLI_RELEASE_URL:-null}"
  },
  "skills": {
    "status": "${SKILLS_STATUS:-skipped}"
  }
}
JSONEOF
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"
    cache_init

    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        title "Claude-Socle Check Updates"
    fi

    # Verifications
    if [[ "$CHECK_CLI" == "true" ]]; then
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            check_cli_version > /dev/null 2>&1 || true
        else
            check_cli_version
        fi
    fi

    if [[ "$CHECK_SKILLS" == "true" ]]; then
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            check_skills > /dev/null 2>&1 || true
        else
            check_skills
        fi
    fi

    # Sortie
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        print_json
    else
        print_report
    fi

    # Code de retour
    if [[ $ERRORS_COUNT -gt 0 && $UPDATES_AVAILABLE -eq 0 ]]; then
        exit 2
    elif [[ $UPDATES_AVAILABLE -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
