#!/usr/bin/env bash

# =============================================================================
# Claude-Base Test Runner
# Run bats tests to validate the foundation
# =============================================================================

set -euo pipefail

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$BASE_DIR/tests"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Variables
# =============================================================================

VERSION=$(cat "$BASE_DIR/VERSION" 2>/dev/null || echo "unknown")
VERBOSE=false
FILTER=""
DRY_RUN=false
SHARD_INDEX=""
SHARD_TOTAL=""

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Base Test Runner${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [FILTER]

${BOLD}DESCRIPTION${NC}
    Run bats tests to validate the claude-base foundation.
    Requires bats-core installed.

${BOLD}ARGUMENTS${NC}
    FILTER              Pattern to filter tests (e.g.: "validate")

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --verbose       Verbose mode
    --shard I/N         Run only shard I of N (balanced by test count).
                        Used by CI to split the suite across parallel runners.
    --dry-run           Print the test files that would run, then exit
                        (no bats execution). Honors --shard and FILTER.
    --install-bats      Install bats-core if missing

${BOLD}EXAMPLES${NC}
    # Run all tests
    $(basename "$0")

    # Run validation tests
    $(basename "$0") validate

    # Verbose mode
    $(basename "$0") -v

    # Run the second of four CI shards
    $(basename "$0") --shard 2/4

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

# Validate and split a "I/N" shard spec into SHARD_INDEX / SHARD_TOTAL.
parse_shard() {
    local spec="$1"
    if [[ ! "$spec" =~ ^[0-9]+/[0-9]+$ ]]; then
        error "Invalid --shard spec '$spec' (expected I/N, e.g. 1/4)"
    fi
    SHARD_INDEX="${spec%/*}"
    SHARD_TOTAL="${spec#*/}"
    if [[ "$SHARD_TOTAL" -lt 1 || "$SHARD_INDEX" -lt 1 || "$SHARD_INDEX" -gt "$SHARD_TOTAL" ]]; then
        error "Invalid --shard '$spec': require 1 <= I <= N and N >= 1"
    fi
}

# Print the files belonging to shard SHARD_INDEX of SHARD_TOTAL, one per line.
# Files are assigned greedily (heaviest-first) to the least-loaded shard, so
# wall-clock stays balanced and the split self-rebalances as the suite grows —
# no stored weight table to maintain. Weight = line count, which tracks real
# runtime better than @test count (heavy-per-test files like lint/preflight
# carry proportionally more setup lines). Deterministic across invocations:
# every shard computes the same full assignment and emits only its own bucket.
# bash-3.2-safe (indexed arrays only; no associative arrays).
select_shard() {
    local idx="$1" total="$2"
    shift 2
    local tab f c sorted
    tab="$(printf '\t')"
    sorted=$(
        for f in "$@"; do
            c=$(wc -l < "$f" 2>/dev/null || true)
            c=$(printf '%s' "$c" | tr -d '[:space:]')
            [[ -z "$c" ]] && c=0
            printf '%s\t%s\n' "$c" "$f"
        done | sort -t "$tab" -k1,1rn -k2,2
    )

    local i
    local loads=()
    for ((i = 0; i < total; i++)); do loads+=("0"); done

    local cnt file min
    while IFS="$tab" read -r cnt file; do
        [[ -z "$file" ]] && continue
        min=0
        for ((i = 1; i < total; i++)); do
            if [[ "${loads[$i]}" -lt "${loads[$min]}" ]]; then min=$i; fi
        done
        loads[$min]=$(( ${loads[$min]} + cnt ))
        if [[ "$min" -eq "$(( idx - 1 ))" ]]; then
            printf '%s\n' "$file"
        fi
    done <<EOF
$sorted
EOF
}

run_tests() {
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

    # Reduce to the requested shard, if any.
    if [[ -n "$SHARD_TOTAL" ]]; then
        local sharded=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && sharded+=("$line")
        done < <(select_shard "$SHARD_INDEX" "$SHARD_TOTAL" "${test_files[@]}")
        test_files=()
        [[ ${#sharded[@]} -gt 0 ]] && test_files=("${sharded[@]}")
    fi

    if [[ ${#test_files[@]} -eq 0 ]]; then
        error "No test file found"
    fi

    # Dry run: just list what would execute (used by CI/tests to inspect a shard).
    if $DRY_RUN; then
        printf '%s\n' "${test_files[@]}"
        return 0
    fi

    if ! command_exists bats; then
        error "bats is not installed. Use --install-bats or install it manually."
    fi

    title "Claude-Base Tests"
    info "Test files: ${#test_files[@]}"
    echo ""

    local bats_opts=()
    $VERBOSE && bats_opts+=("--verbose-run")

    # Parallelization: --jobs auto if GNU parallel or rush available, otherwise sequential.
    # ~4.3x speedup on multi-core machines (3min17 sequential → 46s with 8 jobs).
    # Tests within a file are also safe to parallelize: hook-output-rewriter.bats
    # isolates its sentinels under $BATS_TEST_TMPDIR via the HOOK_REWRITER_*
    # / HOOK_LEGACY_NOTICE_SENTINEL env vars (no shared /tmp paths).
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
                echo "claude-base test v${VERSION}"
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --shard)
                shift
                [[ $# -gt 0 ]] || error "--shard requires an argument (I/N, e.g. 1/4)"
                parse_shard "$1"
                shift
                ;;
            --shard=*)
                parse_shard "${1#*=}"
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
