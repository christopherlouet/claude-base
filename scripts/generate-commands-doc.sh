#!/bin/bash

# =============================================================================
# Claude-Socle Generate Commands Documentation
# Genere docs/reference/commands.md depuis les fichiers .claude/commands/
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$SOCLE_DIR/.claude/commands"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

enable_error_handler
check_base_requirements

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Generate Commands Doc${NC}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Genere la documentation des commandes disponibles a partir
    des fichiers dans .claude/commands/.
    Par defaut, affiche sur stdout.

${BOLD}OPTIONS${NC}
    -h, --help         Afficher cette aide
    -o, --output FILE  Ecrire dans un fichier
    --check            Comparer avec le fichier existant (exit 1 si different)

${BOLD}EXEMPLES${NC}
    $(basename "$0")
    $(basename "$0") --output docs/reference/commands.md
    $(basename "$0") --check
EOF
}

# =============================================================================
# Variables
# =============================================================================

OUTPUT_FILE=""
CHECK_MODE=false

# =============================================================================
# Parsing arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --check)
            CHECK_MODE=true
            shift
            ;;
        *)
            error "Option inconnue: $1"
            ;;
    esac
done

# =============================================================================
# Categories et labels
# =============================================================================

# Ordered list of categories with display names
declare -a CATEGORY_ORDER=("root" "work" "dev" "qa" "ops" "doc" "biz" "growth" "data" "legal")

declare -A CATEGORY_LABELS=(
    ["root"]="Orchestrateurs"
    ["work"]="Work"
    ["dev"]="Dev"
    ["qa"]="QA"
    ["ops"]="Ops"
    ["doc"]="Doc"
    ["biz"]="Biz"
    ["growth"]="Growth"
    ["data"]="Data"
    ["legal"]="Legal"
)

# =============================================================================
# Functions
# =============================================================================

# Extract description from a command file (first non-empty line after the title)
# Arguments:
#   $1 - Path to the command file
# Output: Description string
extract_description() {
    local file="$1"
    # Line 3 is typically the description (line 1 = title, line 2 = empty)
    local desc
    desc=$(sed -n '3p' "$file" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ -z "$desc" ]]; then
        # Fallback: first non-empty, non-heading line
        desc=$(grep -m 1 -v '^#\|^$\|^---' "$file" 2>/dev/null | sed 's/^[[:space:]]*//' || echo "")
    fi
    echo "$desc"
}

# Get command name from filename and category
# Arguments:
#   $1 - filename (without .md)
#   $2 - category (or "root")
# Output: Command name like /work:work-explore or /assistant
get_command_name() {
    local name="$1"
    local category="$2"

    if [[ "$category" == "root" ]]; then
        echo "/$name"
    else
        echo "/$category:$name"
    fi
}

# Generate markdown for a single category
# Arguments:
#   $1 - category key
# Output: Markdown section
generate_category() {
    local category="$1"
    local label="${CATEGORY_LABELS[$category]}"
    local dir

    if [[ "$category" == "root" ]]; then
        dir="$COMMANDS_DIR"
    else
        dir="$COMMANDS_DIR/$category"
    fi

    if [[ ! -d "$dir" ]]; then
        return
    fi

    # Collect command files
    local files=()
    if [[ "$category" == "root" ]]; then
        while IFS= read -r f; do
            files+=("$f")
        done < <(find "$dir" -maxdepth 1 -name "*.md" -not -name "README.md" -type f | sort)
    else
        while IFS= read -r f; do
            files+=("$f")
        done < <(find "$dir" -maxdepth 1 -name "*.md" -not -name "README.md" -type f | sort)
    fi

    local count=${#files[@]}
    if [[ "$count" -eq 0 ]]; then
        return
    fi

    echo "## $label ($count)"
    echo ""
    echo "| Commande | Description |"
    echo "|----------|-------------|"

    for file in "${files[@]}"; do
        local basename_no_ext
        basename_no_ext=$(basename "$file" .md)
        local cmd_name
        cmd_name=$(get_command_name "$basename_no_ext" "$category")
        local description
        description=$(extract_description "$file")
        echo "| \`$cmd_name\` | $description |"
    done

    echo ""
}

# =============================================================================
# Main
# =============================================================================

# Count total commands
TOTAL_COMMANDS=$(find "$COMMANDS_DIR" -name "*.md" -not -name "README.md" -type f | wc -l | tr -d ' ')

# Generate the full document
generate_doc() {
    echo "# Commandes disponibles ($TOTAL_COMMANDS)"
    echo ""

    for category in "${CATEGORY_ORDER[@]}"; do
        generate_category "$category"
    done
}

if $CHECK_MODE; then
    DEFAULT_FILE="$SOCLE_DIR/docs/reference/commands.md"
    if [[ ! -f "$DEFAULT_FILE" ]]; then
        error "Fichier de reference introuvable: docs/reference/commands.md"
    fi

    GENERATED=$(generate_doc)
    EXISTING=$(cat "$DEFAULT_FILE")

    if [[ "$GENERATED" == "$EXISTING" ]]; then
        success "docs/reference/commands.md est a jour"
        exit 0
    else
        error_no_exit "docs/reference/commands.md n'est pas a jour"
        info "Relancez: $(basename "$0") --output docs/reference/commands.md"
        exit 1
    fi
elif [[ -n "$OUTPUT_FILE" ]]; then
    # Handle relative paths
    if [[ "$OUTPUT_FILE" != /* ]]; then
        OUTPUT_FILE="$SOCLE_DIR/$OUTPUT_FILE"
    fi
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    generate_doc > "$OUTPUT_FILE"
    success "Documentation generee dans $OUTPUT_FILE"
else
    generate_doc
fi
