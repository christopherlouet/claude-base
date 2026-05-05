#!/usr/bin/env bash

# =============================================================================
# Claude-Base Bump Version Script
# Updates the version in all referenced files
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

enable_error_handler
check_base_requirements

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Base Bump Version${NC}

${BOLD}USAGE${NC}
    $(basename "$0") <new-version>

${BOLD}DESCRIPTION${NC}
    Updates the version in all foundation files:
    - VERSION (central file)
    - README.md (badge)
    - website/docs/intro/quick-start.md (verification message)

${BOLD}ARGUMENTS${NC}
    new-version    New version in semver format (e.g.: 1.16.0)

${BOLD}OPTIONS${NC}
    -h, --help     Display this help
    --dry-run      Show changes without applying them

${BOLD}EXAMPLES${NC}
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
# Argument parsing
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
                error "Unexpected argument: $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$NEW_VERSION" ]]; then
    error "Missing version. Usage: $(basename "$0") <new-version>"
fi

# Validate semver format
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Invalid version format: $NEW_VERSION (expected: X.Y.Z)"
fi

# =============================================================================
# Main
# =============================================================================

CURRENT_VERSION=$(cat "$BASE_DIR/VERSION" 2>/dev/null || echo "unknown")

info "Bump version: ${BOLD}$CURRENT_VERSION${NC} -> ${BOLD}$NEW_VERSION${NC}"
echo ""

CHANGES=0

# Helper function
bump_file() {
    local file="$1"
    local old_pattern="$2"
    local new_pattern="$3"
    local label="$4"

    local rel_path="${file#"$BASE_DIR"/}"

    if [[ ! -f "$file" ]]; then
        warning "File not found: $rel_path"
        return
    fi

    if grep -q "$old_pattern" "$file" 2>/dev/null; then
        if $DRY_RUN; then
            info "[DRY-RUN] $rel_path: $label"
        else
            # `-i.bak` works on both GNU sed and BSD sed (macOS).
            # Cleanup .bak after successful in-place edit.
            sed -i.bak "s|$old_pattern|$new_pattern|g" "$file" && rm -f "$file.bak"
            success "$rel_path: $label"
        fi
        CHANGES=$((CHANGES + 1))
    else
        debug "$rel_path: pattern not found ($old_pattern)"
    fi
}

# 1. VERSION file
info "1/4 VERSION file"
if $DRY_RUN; then
    info "[DRY-RUN] VERSION: $CURRENT_VERSION -> $NEW_VERSION"
else
    echo "$NEW_VERSION" > "$BASE_DIR/VERSION"
    success "VERSION: $CURRENT_VERSION -> $NEW_VERSION"
fi
CHANGES=$((CHANGES + 1))

# 2. README.md badge
info "2/4 README.md"
bump_file "$BASE_DIR/README.md" \
    "release-v${CURRENT_VERSION}-blue" \
    "release-v${NEW_VERSION}-blue" \
    "Version badge"

# 3. Website quick-start verification message
info "3/4 Website quick-start"
bump_file "$BASE_DIR/website/docs/intro/quick-start.md" \
    "Version: ${CURRENT_VERSION}" \
    "Version: ${NEW_VERSION}" \
    "Verification message"

# 4. README.md versioning policy
info "4/4 README.md versioning policy"
CURRENT_MINOR="${CURRENT_VERSION%.*}"
NEW_MINOR="${NEW_VERSION%.*}"
if [[ "$CURRENT_MINOR" != "$NEW_MINOR" ]]; then
    bump_file "$BASE_DIR/README.md" \
        "${CURRENT_MINOR}.x | Actuel" \
        "${NEW_MINOR}.x | Actuel" \
        "Versioning policy (current)"
fi

echo ""
if $DRY_RUN; then
    info "[DRY-RUN] ${BOLD}$CHANGES${NC} files would be modified"
else
    success "${BOLD}$CHANGES${NC} files updated to v$NEW_VERSION"
    echo ""
    info "Next steps:"
    echo "  1. Review the changes: git diff"
    echo "  2. Update CHANGELOG.md"
    echo "  3. Commit: git commit -am 'chore(release): v$NEW_VERSION'"
    echo "  4. Tag: git tag v$NEW_VERSION"
fi
