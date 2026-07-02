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
        # Drift is silent killer #1 of bump-version: a file already stale
        # at version N-1 won't match the CURRENT_VERSION pattern, so the
        # bump becomes a no-op and the drift compounds every release.
        # Surface it so the maintainer can fix or override manually.
        warning "$rel_path: $label — pattern not found ('$old_pattern'). File may already drift; check manually."
    fi
}

# 1. VERSION file
info "1/2 VERSION file"
if $DRY_RUN; then
    info "[DRY-RUN] VERSION: $CURRENT_VERSION -> $NEW_VERSION"
else
    echo "$NEW_VERSION" > "$BASE_DIR/VERSION"
    success "VERSION: $CURRENT_VERSION -> $NEW_VERSION"
fi
CHANGES=$((CHANGES + 1))

# 1b. README "pin to a release" examples — the reproducible-install snippets
# live inside ```bash fences, so the `<!-- version -->` marker mechanism can't
# reach them (it would render literally in the code block). Self-heal them here
# instead so they always point at the just-released tag; bump_file surfaces a
# drift warning if a snippet was hand-edited and no longer matches.
info "1b/2 README release-pin examples"
# NB: lead the pattern with surrounding text — a pattern starting with `--` would
# be parsed by grep as an option and silently never match.
bump_file "$BASE_DIR/README.md" "bash -s -- --ref v$CURRENT_VERSION" "bash -s -- --ref v$NEW_VERSION" "install --ref pin"
bump_file "$BASE_DIR/README.md" "TAG=v$CURRENT_VERSION" "TAG=v$NEW_VERSION" "SHA256SUMS TAG pin"

# 2. Markdown version markers — handled by `npm --prefix website run generate`
# Files with `<!-- version -->X.Y.Z<!-- /version -->` markers (README badge,
# CHEATSHEET footer, quick-start, installation, learning-path, …) are kept in
# sync by website/scripts/inject-version-md.ts, which reads VERSION directly.
# No pattern-match sed needed here. Adding a new file to the marker list lives
# in inject-version-md.ts, not this script.
#
# Historical note : earlier versions of this script also patched a static
# `release-v${VER}-blue` badge URL and a "Versioning policy" table in README.
# Both were removed in PR #206 (README front-door rewrite) — the release
# badge is now dynamic via shields.io's GitHub-release endpoint, and the
# versioning-policy table was replaced by a generic CHANGELOG pointer.
info "2/2 Markdown version markers"
info "  (handled by 'npm --prefix website run generate' — run it after this script)"

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
