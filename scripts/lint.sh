#!/usr/bin/env bash

# =============================================================================
# Claude-Socle Lint Script
# Check shell code quality with ShellCheck
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Enable the error handler
enable_error_handler

# =============================================================================
# Variables
# =============================================================================

VERSION=$(cat "$SOCLE_DIR/VERSION" 2>/dev/null || echo "unknown")
FIX_MODE=false
SEVERITY="warning"  # error, warning, info, style

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Lint${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Check shell code quality with ShellCheck.
    Analyzes all .sh scripts in the project.

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -s, --severity LVL  Minimum level (error|warning|info|style)
    --fix               Show fix suggestions
    -q, --quiet         Quiet mode

${BOLD}PREREQUISITES${NC}
    - shellcheck: apt install shellcheck / brew install shellcheck

${BOLD}EXAMPLES${NC}
    # Standard lint
    $(basename "$0")

    # Errors only
    $(basename "$0") -s error

    # With suggestions
    $(basename "$0") --fix

EOF
}

# =============================================================================
# Dependency check
# =============================================================================

check_required_dependencies() {
    if ! command_exists shellcheck; then
        error "shellcheck is not installed.
    
Installation:
  - Ubuntu/Debian: sudo apt install shellcheck
  - macOS: brew install shellcheck
  - Other: https://github.com/koalaman/shellcheck#installing"
    fi
}

# =============================================================================
# Lint
# =============================================================================

run_lint() {
    local scripts=()
    local exit_code=0

    # Find all shell scripts
    while IFS= read -r -d '' script; do
        scripts+=("$script")
    done < <(find "$SOCLE_DIR/scripts" -name "*.sh" -type f -print0)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        warning "No script found"
        return 0
    fi

    title "ShellCheck Lint"
    info "Scripts to analyze: ${#scripts[@]}"
    info "Minimum level: $SEVERITY"
    echo ""

    local shellcheck_opts=(
        "--severity=$SEVERITY"
        "--shell=bash"
        "--external-sources"
    )

    $FIX_MODE && shellcheck_opts+=("--format=diff")

    for script in "${scripts[@]}"; do
        local relative_path="${script#$SOCLE_DIR/}"
        
        if shellcheck "${shellcheck_opts[@]}" "$script" 2>/dev/null; then
            success "$relative_path"
        else
            error_no_exit "$relative_path"
            exit_code=1
            
            # Show details if not in quiet mode
            if ! $QUIET; then
                shellcheck "${shellcheck_opts[@]}" "$script" 2>/dev/null || true
                echo ""
            fi
        fi
    done

    echo ""
    separator "="
    
    if [[ $exit_code -eq 0 ]]; then
        success "All scripts are compliant!"
    else
        error_no_exit "Some scripts have issues"
    fi

    return $exit_code
}

# =============================================================================
# Main
# =============================================================================

main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "claude-socle lint v${VERSION}"
                exit 0
                ;;
            -s|--severity)
                SEVERITY="$2"
                shift 2
                ;;
            --fix)
                FIX_MODE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    check_required_dependencies
    run_lint
}

main "$@"
