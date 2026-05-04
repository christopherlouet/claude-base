#!/usr/bin/env bash

# =============================================================================
# Claude-Socle Doctor Script
# Complete diagnostic of the Claude Code environment
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Enable the error handler and check prerequisites
enable_error_handler
check_base_requirements

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
FIX_ISSUES=false
OUTPUT_FORMAT="text"
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Doctor${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Performs a complete diagnostic of the Claude Code environment.
    Checks dependencies, permissions, and configuration.

${BOLD}ARGUMENTS${NC}
    PATH                Directory to diagnose (default: current directory)

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -q, --quiet         Quiet mode
    --fix               Attempt to fix detected issues
    --json              Output in JSON format

${BOLD}CHECKS PERFORMED${NC}
    - System environment (OS, shell, permissions)
    - Dependencies (git, jq, node, etc.)
    - Claude Code CLI
    - Project configuration
    - claude-socle foundation

${BOLD}EXAMPLES${NC}
    # Simple diagnostic
    $(basename "$0")

    # Diagnose a specific project
    $(basename "$0") ./my-project

    # Attempt to fix issues
    $(basename "$0") --fix

EOF
}

show_version() {
    echo "claude-socle doctor v${VERSION}"
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
            --fix)
                # shellcheck disable=SC2034  # Reserved for future implementation
                FIX_ISSUES=true
                shift
                ;;
            --json)
                # shellcheck disable=SC2034  # Used in output formatting
                OUTPUT_FORMAT="json"
                shift
                ;;
            -*)
                error "Unknown option: $1\nUse --help for help"
                ;;
            *)
                if [[ -z "$TARGET_DIR" ]]; then
                    TARGET_DIR="$1"
                else
                    error "Too many arguments: $1"
                fi
                shift
                ;;
        esac
    done

    TARGET_DIR="${TARGET_DIR:-.}"
}

# =============================================================================
# Check functions
# =============================================================================

check_pass() {
    local message="$1"
    ((CHECKS_PASSED++)) || true
    success "$message"
}

check_fail() {
    local message="$1"
    local fix_hint="${2:-}"
    ((CHECKS_FAILED++)) || true
    error_no_exit "$message"
    [[ -n "$fix_hint" ]] && echo -e "    ${DIM}Fix: $fix_hint${NC}"
    return 0
}

check_warn() {
    local message="$1"
    local hint="${2:-}"
    ((CHECKS_WARNED++)) || true
    warning "$message"
    [[ -n "$hint" ]] && echo -e "    ${DIM}$hint${NC}"
    return 0
}

# =============================================================================
# Diagnostics
# =============================================================================

check_system() {
    section "1. System environment"

    # OS
    local os_name
    os_name=$(uname -s)
    check_pass "Operating system: $os_name"

    # Shell
    local shell_name
    shell_name=$(basename "$SHELL")
    if [[ "$shell_name" =~ ^(bash|zsh|fish)$ ]]; then
        check_pass "Shell: $shell_name"
    else
        check_warn "Shell: $shell_name" "bash or zsh recommended"
    fi

    # Bash version
    if command_exists bash; then
        local bash_version
        bash_version=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if version_gte "$bash_version" "4.0"; then
            check_pass "Bash version: $bash_version"
        else
            check_warn "Bash version: $bash_version" "Version 4.0+ recommended"
        fi
    fi

    # Directory permissions
    if [[ -w "$TARGET_DIR" ]]; then
        check_pass "Write permissions: OK"
    else
        check_fail "Write permissions: NO" "chmod +w $TARGET_DIR"
    fi
}

check_dependencies() {
    section "2. Dependencies"

    # Git (required)
    if command_exists git; then
        local git_version
        git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        check_pass "git: $git_version"
    else
        check_fail "git: not installed" "Install git"
    fi

    # jq (recommended)
    if command_exists jq; then
        local jq_version
        jq_version=$(jq --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "unknown")
        check_pass "jq: $jq_version"
    else
        check_warn "jq: not installed" "Install jq for better JSON validation"
    fi

    # Node.js (optional but recommended)
    if command_exists node; then
        local node_version
        node_version=$(node --version | tr -d 'v')
        if version_gte "$node_version" "18.0"; then
            check_pass "Node.js: $node_version"
        else
            check_warn "Node.js: $node_version" "Version 18+ recommended"
        fi
    else
        check_warn "Node.js: not installed" "Recommended for some features"
    fi

    # npm
    if command_exists npm; then
        local npm_version
        npm_version=$(npm --version)
        check_pass "npm: $npm_version"
    fi

    # Python (optional)
    if command_exists python3; then
        local python_version
        python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        check_pass "Python: $python_version"
    fi

    # diff/colordiff
    if command_exists colordiff; then
        check_pass "colordiff: installed"
    elif command_exists diff; then
        check_pass "diff: installed"
    fi
}

check_claude_code() {
    section "3. Claude Code CLI"

    # Check if Claude Code is installed
    if command_exists claude; then
        local claude_version
        claude_version=$(claude --version 2>/dev/null || echo "unknown")
        check_pass "Claude Code CLI: installed ($claude_version)"

        # Check the global configuration
        local global_config="$HOME/.claude/settings.json"
        if [[ -f "$global_config" ]]; then
            check_pass "Global configuration: present"
        else
            check_warn "Global configuration: missing" "Run 'claude' to initialize it"
        fi
    else
        check_fail "Claude Code CLI: not installed" "npm install -g @anthropic-ai/claude-code"
    fi
}

check_project_config() {
    section "4. Project configuration"

    local target
    target="$(get_absolute_path "$TARGET_DIR")"

    # .claude/
    if [[ -d "$target/.claude" ]]; then
        check_pass ".claude/ present"

        # commands/
        if [[ -d "$target/.claude/commands" ]]; then
            local cmd_count
            cmd_count=$(find "$target/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$cmd_count" -gt 0 ]]; then
                check_pass ".claude/commands/: $cmd_count commands"
            else
                check_warn ".claude/commands/: empty"
            fi
        else
            check_warn ".claude/commands/: missing"
        fi

        # skills/
        if [[ -d "$target/.claude/skills" ]]; then
            local skills_count
            skills_count=$(count_dirs "$target/.claude/skills")
            if [[ "$skills_count" -gt 0 ]]; then
                check_pass ".claude/skills/: $skills_count skills"
            else
                check_warn ".claude/skills/: empty"
            fi
        else
            check_warn ".claude/skills/: missing"
        fi

        # settings.json
        if [[ -f "$target/.claude/settings.json" ]]; then
            if validate_json "$target/.claude/settings.json"; then
                check_pass ".claude/settings.json: valid JSON"

                # Check the hooks
                if command_exists jq; then
                    local hooks_count
                    hooks_count=$(jq '.hooks | ((.PreToolUse // []) | length) + ((.PostToolUse // []) | length)' "$target/.claude/settings.json" 2>/dev/null || echo "0")
                    check_pass "Hooks configured: $hooks_count"
                fi
            else
                check_fail ".claude/settings.json: invalid JSON"
            fi
        else
            check_warn ".claude/settings.json: missing"
        fi
    else
        check_warn ".claude/: missing" "Run install.sh to configure"
    fi

    # CLAUDE.md
    if [[ -f "$target/CLAUDE.md" ]]; then
        local lines
        lines=$(wc -l < "$target/CLAUDE.md" | tr -d ' ')
        check_pass "CLAUDE.md: present ($lines lines)"

        # Check IMPORTANT directives
        if grep -q "IMPORTANT" "$target/CLAUDE.md" 2>/dev/null; then
            check_pass "CLAUDE.md: contains IMPORTANT directives"
        else
            check_warn "CLAUDE.md: no IMPORTANT directives"
        fi
    else
        check_warn "CLAUDE.md: missing"
    fi

    # .gitignore
    if [[ -f "$target/.gitignore" ]]; then
        # CLAUDE.local.md MUST be gitignored (local config)
        if grep -q "CLAUDE.local.md" "$target/.gitignore" 2>/dev/null; then
            check_pass ".gitignore: CLAUDE.local.md included"
        else
            check_warn ".gitignore: CLAUDE.local.md not included" "Add CLAUDE.local.md to .gitignore (local config)"
        fi
        # settings.local.json MUST be gitignored
        if grep -q "settings\.local\.json" "$target/.gitignore" 2>/dev/null; then
            check_pass ".gitignore: .claude/settings.local.json included"
        else
            check_warn ".gitignore: .claude/settings.local.json not included" "Add .claude/settings.local.json to .gitignore"
        fi
        # .claude/ MUST NOT be gitignored (shared team config)
        if grep -qE "^\.claude/?$" "$target/.gitignore" 2>/dev/null; then
            check_warn ".gitignore: .claude/ IS included (should be versioned)" "Remove .claude/ from .gitignore — team config to share in git"
        else
            check_pass ".gitignore: .claude/ versionable (shared team config)"
        fi
        # CLAUDE.md MUST NOT be gitignored
        if grep -q "^CLAUDE\.md$" "$target/.gitignore" 2>/dev/null; then
            check_warn ".gitignore: CLAUDE.md IS included (should be versioned)" "Remove CLAUDE.md from .gitignore — project config to share in git"
        else
            check_pass ".gitignore: CLAUDE.md versionable (shared project config)"
        fi
    fi
}

check_socle() {
    section "5. claude-socle foundation"

    if [[ -d "$SOCLE_DIR/.claude/commands" ]]; then
        check_pass "Foundation found: $SOCLE_DIR"

        # Statistics
        local agents
        local skills
        local hooks
        local templates
        agents=$(count_agents "$SOCLE_DIR")
        skills=$(count_skills "$SOCLE_DIR")
        hooks=$(count_hooks "$SOCLE_DIR")
        templates=$(count_templates "$SOCLE_DIR")

        check_pass "Agents available: $agents"
        check_pass "Skills available: $skills"
        check_pass "Hooks configured: $hooks"
        check_pass "Templates available: $templates"
    else
        check_fail "Foundation not found" "Check the installation path"
    fi
}

print_summary() {
    echo ""
    separator "="
    echo "  Diagnostic summary"
    separator "="
    echo ""

    # shellcheck disable=SC2034  # Used for display calculation
    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))

    echo -e "  ${GREEN}✓ Passed:${NC}      $CHECKS_PASSED"
    echo -e "  ${YELLOW}! Warnings:${NC} $CHECKS_WARNED"
    echo -e "  ${RED}✗ Failed:${NC}      $CHECKS_FAILED"
    echo ""

    if [[ $CHECKS_FAILED -eq 0 ]]; then
        if [[ $CHECKS_WARNED -eq 0 ]]; then
            success "Perfect environment! Everything is correctly configured."
        else
            warning "Functional environment with some warnings."
        fi
    else
        error_no_exit "Some issues need to be resolved."
        echo ""
        info "Run with --fix to attempt automatic fixes"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

print_json() {
    cat << EOF
{
  "target": "$TARGET_DIR",
  "checks": {
    "passed": $CHECKS_PASSED,
    "failed": $CHECKS_FAILED,
    "warned": $CHECKS_WARNED
  },
  "success": $([ $CHECKS_FAILED -eq 0 ] && echo "true" || echo "false")
}
EOF
}

main() {
    parse_args "$@"

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        # JSON mode: redirect stdout and stderr to /dev/null
        exec 3>&1 4>&2 1>/dev/null 2>/dev/null
    fi

    title "Claude Code Diagnostic"
    info "Directory: $TARGET_DIR"
    echo ""

    check_system
    check_dependencies
    check_claude_code
    check_project_config
    check_socle

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        # Restore stdout and stderr, then print the JSON
        exec 1>&3 2>&4 3>&- 4>&-
        print_json
    else
        print_summary
    fi

    # Exit code
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
