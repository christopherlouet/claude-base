#!/bin/bash

# =============================================================================
# Claude-Socle Common Library
# Fonctions partagées entre tous les scripts
# =============================================================================

# Version lue depuis le fichier VERSION centralisé
_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_SOCLE_ROOT="$(dirname "$(dirname "$_COMMON_SCRIPT_DIR")")"
# shellcheck disable=SC2034  # Exported for use by other scripts
COMMON_LIB_VERSION=$(cat "$_SOCLE_ROOT/VERSION" 2>/dev/null || echo "1.0.0")
unset _COMMON_SCRIPT_DIR _SOCLE_ROOT

# =============================================================================
# Couleurs et styles (notation ANSI-C quoting pour compatibilité)
# =============================================================================

# Désactiver les couleurs si pas de terminal ou si NO_COLOR est défini
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    # shellcheck disable=SC2034  # Available for use by scripts
    MAGENTA=$'\033[0;35m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    NC=$'\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    # shellcheck disable=SC2034  # Available for use by scripts
    MAGENTA=''
    BOLD=''
    DIM=''
    NC=''
fi

# =============================================================================
# Variables globales
# =============================================================================

VERBOSE=${VERBOSE:-false}   # Mode verbeux
QUIET=${QUIET:-false}       # Mode silencieux
DRY_RUN=${DRY_RUN:-false}   # Mode simulation

# =============================================================================
# Fonctions de logging
# =============================================================================

# Affiche un message d'information
# Arguments:
#   $1 - Message à afficher
# Sortie: Rien si QUIET=true
info() {
    if ! $QUIET; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

# Affiche un message de succès
# Arguments:
#   $1 - Message à afficher
# Sortie: Rien si QUIET=true
success() {
    if ! $QUIET; then
        echo -e "${GREEN}[OK]${NC} $1"
    fi
}

# Affiche un avertissement (toujours sur stderr)
# Arguments:
#   $1 - Message à afficher
warning() {
    echo -e "${YELLOW}[!]${NC} $1" >&2
}

# Affiche une erreur et termine le script
# Arguments:
#   $1 - Message d'erreur
# Code de sortie: 1
error() {
    echo -e "${RED}[X]${NC} $1" >&2
    exit 1
}

# Affiche une erreur sans terminer le script
# Arguments:
#   $1 - Message d'erreur
error_no_exit() {
    echo -e "${RED}[X]${NC} $1" >&2
}

# Affiche un message de debug (seulement si VERBOSE=true)
# Arguments:
#   $1 - Message à afficher
debug() {
    if $VERBOSE; then
        echo -e "${DIM}[DEBUG]${NC} $1"
    fi
    return 0
}

# Affiche une invite de commande
# Arguments:
#   $1 - Message à afficher
prompt() {
    echo -e "${CYAN}[?]${NC} $1"
}

# Affiche un message de détection automatique
# Arguments:
#   $1 - Message à afficher
detected() {
    if ! $QUIET; then
        echo -e "${GREEN}[AUTO]${NC} $1"
    fi
}

# =============================================================================
# Fonctions utilitaires
# =============================================================================

# Vérifie si une commande existe dans le PATH
# Arguments:
#   $1 - Nom de la commande
# Retour: 0 si existe, 1 sinon
command_exists() {
    command -v "$1" &> /dev/null
}

# Vérifie les dépendances requises et échoue si manquantes
# Arguments:
#   $@ - Liste des commandes requises
# Code de sortie: 1 si dépendances manquantes
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Dependances manquantes: ${missing[*]}"
    fi
}

# Vérifie les dépendances optionnelles (avertissement seulement)
# Arguments:
#   $@ - Liste des commandes optionnelles
# Retour: 0 si toutes présentes, 1 sinon
check_optional_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Dependances optionnelles manquantes: ${missing[*]}"
        return 1
    fi
    return 0
}

# Vérifie les prérequis de base du socle (bash 4+, git)
# Appelée automatiquement ou manuellement au démarrage
# Code de sortie: 1 si prérequis non satisfaits
check_base_requirements() {
    # Vérifier la version de Bash (4.0 minimum pour les tableaux associatifs)
    local bash_version="${BASH_VERSION%%.*}"
    if [[ "$bash_version" -lt 4 ]]; then
        error "Bash 4.0+ requis (version actuelle: $BASH_VERSION)"
    fi

    # Vérifier que git est installé
    if ! command_exists git; then
        error "git est requis mais n'est pas installe"
    fi

    debug "Prerequis de base OK (bash $BASH_VERSION, git $(git --version | cut -d' ' -f3))"
}

# Retourne le chemin du socle depuis le script appelant
# Retour: Chemin absolu du répertoire socle
get_socle_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    echo "$(dirname "$script_dir")"
}

# Convertit un chemin relatif en chemin absolu
# Arguments:
#   $1 - Chemin à convertir
# Retour: Chemin absolu
get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Compte les fichiers correspondant à un pattern
# Arguments:
#   $1 - Répertoire à scanner
#   $2 - Pattern glob (défaut: *)
# Retour: Nombre de fichiers
count_files() {
    local dir="$1"
    local pattern="${2:-*}"
    find "$dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Compte les sous-répertoires
# Arguments:
#   $1 - Répertoire à scanner
# Retour: Nombre de répertoires
count_dirs() {
    local dir="$1"
    find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
}

# Demande une confirmation à l'utilisateur
# Arguments:
#   $1 - Message de confirmation (défaut: "Continuer?")
#   $2 - Réponse par défaut: "y" ou "n" (défaut: "n")
# Retour: 0 si oui, 1 si non
confirm() {
    local message="${1:-Continuer?}"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt "$message (Y/n)"
    else
        prompt "$message (y/N)"
    fi

    read -r -n 1 reply
    echo

    if [[ -z "$reply" ]]; then
        reply="$default"
    fi

    [[ "$reply" =~ ^[Yy]$ ]]
}

# =============================================================================
# Fonctions d'exécution (respectent DRY_RUN)
# =============================================================================

# Exécute une commande (simulation si DRY_RUN=true)
# Arguments:
#   $@ - Commande et arguments
# Retour: Code de sortie de la commande
run_cmd() {
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} $*"
        return 0
    fi

    $VERBOSE && debug "Execution: $*"
    "$@"
}

# Copie un fichier (simulation si DRY_RUN=true)
# Arguments:
#   $1 - Fichier source
#   $2 - Destination
copy_file() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp $src -> $dest"
        return 0
    fi

    cp "$src" "$dest"
}

# Copie un répertoire (simulation si DRY_RUN=true)
# Arguments:
#   $1 - Répertoire source
#   $2 - Destination
copy_dir() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $src -> $dest"
        return 0
    fi

    cp -r "$src" "$dest"
}

# Crée un répertoire (simulation si DRY_RUN=true)
# Arguments:
#   $1 - Chemin du répertoire
make_dir() {
    local dir="$1"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} mkdir -p $dir"
        return 0
    fi

    mkdir -p "$dir"
}

# =============================================================================
# Fonctions de validation JSON
# =============================================================================

# Valide la syntaxe d'un fichier JSON
# Arguments:
#   $1 - Chemin du fichier JSON
# Retour: 0 si valide, 1 sinon
validate_json() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    if command_exists jq; then
        if jq empty "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    elif command_exists python3; then
        # Use stdin to avoid command injection via filename
        if python3 -c "import json, sys; json.load(sys.stdin)" < "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    elif command_exists node; then
        # Use stdin to avoid command injection via filename
        if node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{JSON.parse(d)}catch(e){process.exit(1)}})" < "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        # Pas de validateur disponible, on considère valide
        return 0
    fi
}

# Extrait une valeur d'un fichier JSON
# Arguments:
#   $1 - Chemin du fichier JSON
#   $2 - Clé jq (ex: ".version" ou ".hooks.PreToolUse")
# Retour: Valeur extraite ou chaîne vide
json_get() {
    local file="$1"
    local key="$2"

    if command_exists jq; then
        jq -r "$key" "$file" 2>/dev/null
    elif command_exists python3; then
        # Use stdin to avoid command injection via filename
        # Convert jq-style key to Python dict access (e.g., ".version" -> "['version']")
        local py_key
        py_key=$(echo "$key" | sed 's/^\.//' | sed "s/\.\([^.]*\)/['\1']/g" | sed "s/^\([^[]*\)/['\1']/")
        python3 -c "import json, sys; data=json.load(sys.stdin); print(data$py_key)" < "$file" 2>/dev/null
    else
        echo ""
    fi
}

# =============================================================================
# Fonctions de validation d'input
# =============================================================================

# Supprime les caracteres de controle et trim les espaces
# Arguments:
#   $1 - Chaine a nettoyer
# Retour: Chaine nettoyee (stdout)
sanitize_input() {
    local input="${1:-}"
    # Remove control characters (except newline/tab) and trim whitespace
    printf '%s' "$input" | tr -d '\000-\010\013\014\016-\037' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Valide un input contre un pattern regex ERE
# Arguments:
#   $1 - Chaine a valider
#   $2 - Pattern regex ERE (ex: '^[a-zA-Z0-9_-]+$')
#   $3 - Nom du champ (pour le message d'erreur, optionnel)
# Retour: 0 si valide, 1 sinon (message d'erreur sur stderr)
validate_input() {
    local input="${1:-}"
    local pattern="${2:-}"
    local field_name="${3:-input}"

    if [[ -z "$input" ]]; then
        echo "Error: ${field_name} is empty" >&2
        return 1
    fi

    if [[ -z "$pattern" ]]; then
        echo "Error: validation pattern is empty" >&2
        return 1
    fi

    if ! echo "$input" | grep -qE "$pattern"; then
        echo "Error: ${field_name} does not match expected format" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# Fonctions de versioning
# =============================================================================

# Retourne la version du socle
# Arguments:
#   $1 - Chemin du socle (optionnel)
# Retour: Version ou "unknown"
get_socle_version() {
    local socle_dir="${1:-$(get_socle_dir)}"
    local version_file="$socle_dir/VERSION"

    if [[ -f "$version_file" ]]; then
        cat "$version_file"
    else
        echo "unknown"
    fi
}

# Compare deux versions sémantiques
# Arguments:
#   $1 - Version 1
#   $2 - Version 2
# Retour: 0 si v1 >= v2, 1 sinon
version_gte() {
    local v1="$1"
    local v2="$2"

    [[ "$(printf '%s\n' "$v2" "$v1" | sort -V | head -n1)" == "$v2" ]]
}

# =============================================================================
# Fonctions d'affichage
# =============================================================================

# Affiche une ligne de séparation
# Arguments:
#   $1 - Caractère (défaut: =)
#   $2 - Largeur (défaut: 60)
separator() {
    local char="${1:-=}"
    local width="${2:-60}"
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

# Affiche un titre encadré
# Arguments:
#   $1 - Texte du titre
title() {
    local text="$1"
    echo ""
    separator "="
    echo -e "  ${BOLD}$text${NC}"
    separator "="
    echo ""
}

# Affiche un en-tête de section
# Arguments:
#   $1 - Texte de la section
section() {
    local text="$1"
    echo ""
    echo -e "${BOLD}$text${NC}"
    separator "-" 40
}

# =============================================================================
# Statistiques du socle
# =============================================================================

# Compte le nombre d'agents (fichiers .md dans commands/ et sous-répertoires)
# Arguments:
#   $1 - Chemin du socle (optionnel)
# Retour: Nombre d'agents
count_agents() {
    local socle_dir="${1:-$(get_socle_dir)}"
    find "$socle_dir/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Compte le nombre de skills (répertoires dans skills/)
# Arguments:
#   $1 - Chemin du socle (optionnel)
# Retour: Nombre de skills
count_skills() {
    local socle_dir="${1:-$(get_socle_dir)}"
    count_dirs "$socle_dir/.claude/skills"
}

# Compte le nombre de hooks configurés
# Arguments:
#   $1 - Chemin du socle (optionnel)
# Retour: Nombre de hooks (Pre + Post)
count_hooks() {
    local socle_dir="${1:-$(get_socle_dir)}"
    local settings_file="$socle_dir/.claude/settings.json"

    if [[ -f "$settings_file" ]] && command_exists jq; then
        local pre post
        pre=$(jq '.hooks.PreToolUse // [] | length' "$settings_file" 2>/dev/null || echo 0)
        post=$(jq '.hooks.PostToolUse // [] | length' "$settings_file" 2>/dev/null || echo 0)
        echo $((pre + post))
    else
        echo "0"
    fi
}

# Compte le nombre de templates CLAUDE.*.md
# Arguments:
#   $1 - Chemin du socle (optionnel)
# Retour: Nombre de templates
count_templates() {
    local socle_dir="${1:-$(get_socle_dir)}"
    count_files "$socle_dir/templates" "CLAUDE.*.md"
}

# Affiche les statistiques du socle
# Arguments:
#   $1 - Chemin du socle (optionnel)
show_socle_stats() {
    local socle_dir="${1:-$(get_socle_dir)}"

    local agents skills hooks templates
    agents=$(count_agents "$socle_dir")
    skills=$(count_skills "$socle_dir")
    hooks=$(count_hooks "$socle_dir")
    templates=$(count_templates "$socle_dir")

    echo "  Agents:    $agents"
    echo "  Skills:    $skills"
    echo "  Hooks:     $hooks"
    echo "  Templates: $templates"
}

# =============================================================================
# Cache persistant (~/.cache/claude-socle/)
# =============================================================================

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-socle"
CACHE_DEFAULT_TTL=86400  # 24h

# Initialise le répertoire de cache
cache_init() {
    mkdir -p "$CACHE_DIR" 2>/dev/null || true
}

# Vérifie si une entrée cache est encore valide
# Arguments: $1=clé, $2=ttl en secondes (défaut: 86400)
# Retourne: 0 si valide, 1 sinon
cache_valid() {
    local key="$1"
    local ttl="${2:-$CACHE_DEFAULT_TTL}"
    local file="$CACHE_DIR/${key}.json"

    [[ -f "$file" ]] || return 1

    local timestamp
    timestamp=$(json_get "$file" ".timestamp" 2>/dev/null) || return 1
    [[ -z "$timestamp" ]] && return 1

    local now
    now=$(date +%s)
    (( now - timestamp < ttl ))
}

# Lit une valeur du cache
# Arguments: $1=clé
# Retourne: contenu du champ .data (stdout), 1 si absent
cache_read() {
    local key="$1"
    local file="$CACHE_DIR/${key}.json"

    [[ -f "$file" ]] || return 1
    json_get "$file" ".data" 2>/dev/null
}

# Écrit une valeur dans le cache
# Arguments: $1=clé, $2=données (string)
cache_write() {
    local key="$1"
    local data="$2"
    local now
    now=$(date +%s)

    cache_init

    cat > "$CACHE_DIR/${key}.json" << CACHEEOF
{"data": "$data", "timestamp": $now}
CACHEEOF
}

# =============================================================================
# Nettoyage des dossiers Claude
# =============================================================================

# Supprime les sous-dossiers Claude pour reinstallation propre
# Arguments: $1=repertoire projet
clean_claude_dirs() {
    local dir="$1"

    info "Nettoyage des anciens fichiers Claude..."

    local dirs_to_clean=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir/.claude/$subdir" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} rm -rf $dir/.claude/$subdir"
            else
                rm -rf "$dir/.claude/$subdir"
            fi
            debug "Supprimé: .claude/$subdir"
        fi
    done

    success "Anciens fichiers nettoyés"
}

# =============================================================================
# Gestion des erreurs
# =============================================================================

# Handler d'erreur global (appelé automatiquement si activé)
# Arguments:
#   $1 - Numéro de ligne
#   $2 - Code d'erreur
on_error() {
    local line="$1"
    local code="$2"
    error_no_exit "Erreur a la ligne $line (code: $code)"
}

# Active le handler d'erreur global
# À appeler au début du script principal si désiré
enable_error_handler() {
    trap 'on_error ${LINENO} $?' ERR
}

# =============================================================================
# Export des fonctions pour les sous-shells
# =============================================================================

export -f info success warning error error_no_exit debug prompt detected
export -f command_exists check_dependencies check_optional_dependencies check_base_requirements
export -f get_socle_dir get_absolute_path count_files count_dirs confirm
export -f run_cmd copy_file copy_dir make_dir
export -f validate_json json_get
export -f get_socle_version version_gte
export -f separator title section
export -f count_agents count_skills count_hooks count_templates show_socle_stats
export -f on_error enable_error_handler
export -f cache_init cache_valid cache_read cache_write
export -f clean_claude_dirs
