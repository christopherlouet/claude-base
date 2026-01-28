#!/bin/bash

# =============================================================================
# Claude-Socle Bump Version Script
# Met a jour la version dans tous les fichiers references
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

enable_error_handler
check_base_requirements

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Bump Version${NC}

${BOLD}USAGE${NC}
    $(basename "$0") <new-version>

${BOLD}DESCRIPTION${NC}
    Met a jour la version dans tous les fichiers du socle :
    - VERSION (fichier central)
    - README.md (badge)
    - website/docs/intro/quick-start.md (verification message)

${BOLD}ARGUMENTS${NC}
    new-version    Nouvelle version au format semver (ex: 1.16.0)

${BOLD}OPTIONS${NC}
    -h, --help     Afficher cette aide
    --dry-run      Afficher les changements sans les appliquer

${BOLD}EXEMPLES${NC}
    $(basename "$0") 1.16.0
    $(basename "$0") --dry-run 2.0.0
EOF
}

# =============================================================================
# Variables
# =============================================================================

NEW_VERSION=""
DRY_RUN=false

# =============================================================================
# Parsing arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [[ -z "$NEW_VERSION" ]]; then
                NEW_VERSION="$1"
            else
                error "Argument inattendu: $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$NEW_VERSION" ]]; then
    error "Version manquante. Usage: $(basename "$0") <new-version>"
fi

# Validate semver format
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Format de version invalide: $NEW_VERSION (attendu: X.Y.Z)"
fi

# =============================================================================
# Main
# =============================================================================

CURRENT_VERSION=$(cat "$SOCLE_DIR/VERSION" 2>/dev/null || echo "unknown")

info "Bump version: ${BOLD}$CURRENT_VERSION${NC} -> ${BOLD}$NEW_VERSION${NC}"
echo ""

CHANGES=0

# Helper function
bump_file() {
    local file="$1"
    local old_pattern="$2"
    local new_pattern="$3"
    local label="$4"

    local rel_path="${file#"$SOCLE_DIR"/}"

    if [[ ! -f "$file" ]]; then
        warning "Fichier non trouve: $rel_path"
        return
    fi

    if grep -q "$old_pattern" "$file" 2>/dev/null; then
        if $DRY_RUN; then
            info "[DRY-RUN] $rel_path: $label"
        else
            sed -i "s|$old_pattern|$new_pattern|g" "$file"
            success "$rel_path: $label"
        fi
        CHANGES=$((CHANGES + 1))
    else
        debug "$rel_path: pattern non trouve ($old_pattern)"
    fi
}

# 1. VERSION file
info "1/4 Fichier VERSION"
if $DRY_RUN; then
    info "[DRY-RUN] VERSION: $CURRENT_VERSION -> $NEW_VERSION"
else
    echo "$NEW_VERSION" > "$SOCLE_DIR/VERSION"
    success "VERSION: $CURRENT_VERSION -> $NEW_VERSION"
fi
CHANGES=$((CHANGES + 1))

# 2. README.md badge
info "2/4 README.md"
bump_file "$SOCLE_DIR/README.md" \
    "release-v${CURRENT_VERSION}-blue" \
    "release-v${NEW_VERSION}-blue" \
    "Badge version"

# 3. Website quick-start verification message
info "3/4 Website quick-start"
bump_file "$SOCLE_DIR/website/docs/intro/quick-start.md" \
    "Version socle: ${CURRENT_VERSION}" \
    "Version socle: ${NEW_VERSION}" \
    "Verification message"

# 4. README.md versioning policy
info "4/4 README.md versioning policy"
CURRENT_MINOR="${CURRENT_VERSION%.*}"
NEW_MINOR="${NEW_VERSION%.*}"
if [[ "$CURRENT_MINOR" != "$NEW_MINOR" ]]; then
    bump_file "$SOCLE_DIR/README.md" \
        "${CURRENT_MINOR}.x | Actuel" \
        "${NEW_MINOR}.x | Actuel" \
        "Versioning policy (current)"
fi

echo ""
if $DRY_RUN; then
    info "[DRY-RUN] ${BOLD}$CHANGES${NC} fichiers seraient modifies"
else
    success "${BOLD}$CHANGES${NC} fichiers mis a jour vers v$NEW_VERSION"
    echo ""
    info "Prochaines etapes:"
    echo "  1. Verifier les changements: git diff"
    echo "  2. Mettre a jour CHANGELOG.md"
    echo "  3. Commiter: git commit -am 'chore(release): v$NEW_VERSION'"
    echo "  4. Tagger: git tag v$NEW_VERSION"
fi
