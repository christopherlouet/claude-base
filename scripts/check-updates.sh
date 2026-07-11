#!/usr/bin/env bash

# =============================================================================
# Claude-Base Check Updates
# Checks available updates (Claude Code CLI, community skills)
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # BASE_DIR used by common.sh
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Enable the error handler and check prerequisites
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

# Results
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
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Base Check Updates${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Checks available updates for Claude Code CLI
    and new community skills on skills.sh.

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -q, --quiet         Quiet mode (output only if updates)
    --json              Output in JSON format
    --force             Ignore the cache and force the check
    --no-cli            Do not check Claude Code CLI
    --no-skills         Do not check skills.sh
    --timeout N         Network timeout in seconds (default: 10)

${BOLD}ENVIRONMENT VARIABLES${NC}
    GITHUB_TOKEN        GitHub token to increase API rate limit
    CHECK_UPDATES_TTL   Cache duration in seconds (default: 86400 = 24h)

${BOLD}EXIT CODES${NC}
    0   Everything is up to date
    1   Updates available
    2   Error during the check

${BOLD}EXAMPLES${NC}
    # Full check
    $(basename "$0")

    # JSON output for CI/CD
    $(basename "$0") --json

    # CLI only, without cache
    $(basename "$0") --no-skills --force

    # Quiet mode (for hooks)
    $(basename "$0") --quiet

EOF
}

show_version() {
    echo "claude-base check-updates v${VERSION}"
}

# =============================================================================
# Argument parsing
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
                    error "The --timeout option requires an argument"
                fi
                TIMEOUT="$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1\nUse --help for help."
                ;;
            *)
                error "Unexpected argument: $1\nUse --help for help."
                ;;
        esac
    done
}

# =============================================================================
# Claude Code CLI check [US1]
# =============================================================================

check_cli_version() {
    section "Claude Code CLI"

    # Local version
    if command_exists claude; then
        local raw_version
        raw_version=$(claude --version 2>/dev/null || echo "")
        # Extract the version number (format: "Claude Code vX.Y.Z" or "X.Y.Z")
        CLI_LOCAL_VERSION=$(echo "$raw_version" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
        if [[ -z "$CLI_LOCAL_VERSION" ]]; then
            CLI_LOCAL_VERSION="unknown"
        fi
        info "Local version: $CLI_LOCAL_VERSION"
    else
        CLI_STATUS="not_installed"
        warning "Claude Code CLI not installed"
        echo -e "    ${DIM}Installation: npm install -g @anthropic-ai/claude-code${NC}"
        ((ERRORS_COUNT++)) || true
        return 0
    fi

    # Remote version (cache or network)
    local cache_key="cli-version"

    if [[ "$FORCE_REFRESH" == "false" ]] && cache_valid "$cache_key" "$CACHE_TTL"; then
        CLI_REMOTE_VERSION=$(cache_read "$cache_key")
        debug "Remote version (cache): $CLI_REMOTE_VERSION"
    else
        debug "GitHub API request..."
        local curl_opts=(-s --max-time "$TIMEOUT" -L)

        # Use the GitHub token if available
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            curl_opts+=(-H "Authorization: Bearer $GITHUB_TOKEN")
        fi

        local response
        if response=$(curl "${curl_opts[@]}" "$GITHUB_API" 2>/dev/null); then
            # Extract tag_name from JSON
            CLI_REMOTE_VERSION=$(echo "$response" | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)

            if [[ -n "$CLI_REMOTE_VERSION" ]]; then
                cache_write "$cache_key" "$CLI_REMOTE_VERSION"
                debug "Remote version (network): $CLI_REMOTE_VERSION"
            else
                CLI_STATUS="error"
                warning "Unable to extract the version from GitHub"
                ((ERRORS_COUNT++)) || true
                return 0
            fi

            # Extract the release URL
            CLI_RELEASE_URL=$(echo "$response" | grep -oE '"html_url"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"html_url"[[:space:]]*:[[:space:]]*"//;s/"//' || true)
        else
            CLI_STATUS="error"
            warning "Unable to reach GitHub (offline or rate limit)"
            # Try the cache even if expired
            if CLI_REMOTE_VERSION=$(cache_read "$cache_key" 2>/dev/null); then
                info "Last known version (expired cache): $CLI_REMOTE_VERSION"
            fi
            ((ERRORS_COUNT++)) || true
            return 0
        fi
    fi

    # Comparison
    if [[ -z "$CLI_REMOTE_VERSION" || "$CLI_LOCAL_VERSION" == "unknown" ]]; then
        CLI_STATUS="error"
        ((ERRORS_COUNT++)) || true
        return 0
    fi

    if version_gte "$CLI_LOCAL_VERSION" "$CLI_REMOTE_VERSION"; then
        CLI_STATUS="up_to_date"
        success "Up to date ($CLI_LOCAL_VERSION)"
    else
        CLI_STATUS="update_available"
        warning "Update available: $CLI_LOCAL_VERSION -> $CLI_REMOTE_VERSION"
        if [[ -n "$CLI_RELEASE_URL" ]]; then
            echo -e "    ${DIM}Release: $CLI_RELEASE_URL${NC}"
        fi
        echo -e "    ${DIM}Command: npm update -g @anthropic-ai/claude-code${NC}"
        ((UPDATES_AVAILABLE++)) || true
    fi
}

# =============================================================================
# Community skills check [US3]
# =============================================================================

check_skills() {
    section "Community skills (skills.sh)"

    local cache_key="skills"
    local skills_url="https://skills.sh"

    if [[ "$FORCE_REFRESH" == "false" ]] && cache_valid "$cache_key" "$CACHE_TTL"; then
        debug "Skills (cache): using cache"
        SKILLS_STATUS="ok"
        info "Last check: cache valid (use --force to refresh)"
        return 0
    fi

    debug "skills.sh request..."
    local curl_opts=(-s --max-time "$TIMEOUT" -L)

    local response
    if response=$(curl "${curl_opts[@]}" "$skills_url" 2>/dev/null); then
        # Extract skills from the page (basic parsing)
        # Expected format: links to skills with names and descriptions
        local skills_count
        skills_count=$(echo "$response" | grep -ciE 'skill|claude' || true)

        if [[ "$skills_count" -gt 0 ]]; then
            SKILLS_STATUS="ok"
            cache_write "$cache_key" "checked"
            success "skills.sh reachable ($skills_count references found)"
            echo -e "    ${DIM}Browse: $skills_url${NC}"
            # Scored candidate proposals (trust + safety + advice-neutrality) come
            # from the curation discovery engine, not this reachability ping.
            echo -e "    ${DIM}Proposals: scripts/curation-discover.sh (monthly, budget-capped — see docs/recipes/curation-bot-deploy.md)${NC}"
        else
            SKILLS_STATUS="ok"
            cache_write "$cache_key" "checked"
            info "No new skill detected"
        fi
    else
        SKILLS_STATUS="error"
        warning "Unable to reach skills.sh"
        echo -e "    ${DIM}Check your connection or try again later${NC}"
        ((ERRORS_COUNT++)) || true
    fi
}

# =============================================================================
# Text report [US2]
# =============================================================================

print_report() {
    echo ""
    separator "="
    echo -e "  ${BOLD}Check summary${NC}"
    separator "="
    echo ""

    if [[ $UPDATES_AVAILABLE -eq 0 && $ERRORS_COUNT -eq 0 ]]; then
        success "Everything is up to date!"
    elif [[ $UPDATES_AVAILABLE -gt 0 ]]; then
        warning "$UPDATES_AVAILABLE update(s) available"
    fi

    if [[ $ERRORS_COUNT -gt 0 ]]; then
        error_no_exit "$ERRORS_COUNT check(s) in error"
    fi

    echo ""
    echo -e "  ${DIM}Cache: ${CACHE_DIR}${NC}"
    echo -e "  ${DIM}TTL: $((CACHE_TTL / 3600))h (--force to ignore)${NC}"
    echo ""
}

# =============================================================================
# JSON output [US5]
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
        title "Claude-Base Check Updates"
    fi

    # Checks
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

    # Output
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        print_json
    else
        print_report
    fi

    # Exit code
    if [[ $ERRORS_COUNT -gt 0 && $UPDATES_AVAILABLE -eq 0 ]]; then
        exit 2
    elif [[ $UPDATES_AVAILABLE -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
