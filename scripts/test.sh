#!/bin/bash

# =============================================================================
# Claude-Socle Test Runner
# Run bats tests to validate the foundation
# =============================================================================

set -euo pipefail

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SOCLE_DIR/tests"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Variables
# =============================================================================

VERSION=$(cat "$SOCLE_DIR/VERSION" 2>/dev/null || echo "unknown")
VERBOSE=false
FILTER=""

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Test Runner${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [FILTER]

${BOLD}DESCRIPTION${NC}
    Run bats tests to validate the claude-socle foundation.
    Requires bats-core installed.

${BOLD}ARGUMENTS${NC}
    FILTER              Pattern to filter tests (e.g.: "validate")

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --verbose       Verbose mode
    --install-bats      Install bats-core if missing

${BOLD}EXAMPLES${NC}
    # Run all tests
    $(basename "$0")

    # Run validation tests
    $(basename "$0") validate

    # Verbose mode
    $(basename "$0") -v

${BOLD}PREREQUISITES${NC}
    - bats-core: npm install -g bats
    - gitleaks (optional): brew install gitleaks

EOF
}

# =============================================================================
# Functions
# =============================================================================

install_bats() {
    info "Installing bats-core..."
    if command_exists npm; then
        npm install -g bats
        success "bats installed via npm"
    elif command_exists brew; then
        brew install bats-core
        success "bats installed via brew"
    else
        error "Cannot install bats. Install npm or brew first."
    fi
}

run_tests() {
    if ! command_exists bats; then
        error "bats is not installed. Use --install-bats or install it manually."
    fi

    local test_files=()

    if [[ -n "$FILTER" ]]; then
        # Filter test files
        for f in "$TESTS_DIR"/*.bats; do
            if [[ "$(basename "$f")" == *"$FILTER"* ]]; then
                test_files+=("$f")
            fi
        done
    else
        # All test files
        test_files=("$TESTS_DIR"/*.bats)
    fi

    if [[ ${#test_files[@]} -eq 0 ]]; then
        error "No test file found"
    fi

    title "Claude-Socle Tests"
    info "Test files: ${#test_files[@]}"
    echo ""

    local bats_opts=()
    $VERBOSE && bats_opts+=("--verbose-run")

    # Parallelization: --jobs auto if GNU parallel or rush available, otherwise sequential.
    # ~4.3x speedup on multi-core machines (3min17 sequential → 46s with 8 jobs).
    if command -v parallel >/dev/null 2>&1 || command -v rush >/dev/null 2>&1; then
        local cores
        cores=$(nproc 2>/dev/null || echo "4")
        local jobs=$((cores > 8 ? 8 : cores))
        bats_opts+=("--jobs" "$jobs")
    fi

    bats "${bats_opts[@]}" "${test_files[@]}"
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
            --version)
                echo "claude-socle test v${VERSION}"
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --install-bats)
                install_bats
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                FILTER="$1"
                shift
                ;;
        esac
    done

    run_tests
}

main "$@"
