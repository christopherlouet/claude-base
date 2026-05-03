#!/bin/bash

# =============================================================================
# Claude-Socle Validation Script
# Validates the Claude Code configuration of a project
# =============================================================================

set -euo pipefail

VERSION="1.1.0"

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # Used by sourced scripts
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
OUTPUT_FORMAT="text"  # text, json, score
ERRORS=0
WARNINGS=0
SCORE=0
MAX_SCORE=0

# For JSON output
declare -a JSON_ERRORS=()
declare -a JSON_WARNINGS=()
declare -a JSON_SUCCESS=()

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Validate${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Validates the Claude Code configuration of a project.
    Checks the structure, files and consistency.

${BOLD}ARGUMENTS${NC}
    PATH                Directory to validate (default: current directory)

${BOLD}OPTIONS${NC}
    -h, --help          Display this help
    -v, --version       Display the version
    -q, --quiet         Quiet mode (exit code only)
    --json              JSON output format
    --score             Display only the maturity score
    --verbose           Verbose mode (debug)

${BOLD}EXAMPLES${NC}
    # Standard validation
    $(basename "$0") ./my-project

    # JSON output for CI/CD
    $(basename "$0") --json ./my-project

    # Score only
    $(basename "$0") --score ./my-project

${BOLD}EXIT CODES${NC}
    0   Valid configuration
    1   Errors detected
    2   Warnings only

EOF
}

show_version() {
    echo "claude-socle validate v${VERSION}"
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
            --score)
                OUTPUT_FORMAT="score"
                shift
                ;;
            --verbose)
                export VERBOSE=true
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
# Validation functions with tracking
# =============================================================================

add_error() {
    local message="$1"
    local category="${2:-general}"
    ((ERRORS++)) || true
    JSON_ERRORS+=("{\"category\": \"$category\", \"message\": \"$message\"}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && error_no_exit "$message"
    return 0
}

add_warning() {
    local message="$1"
    local category="${2:-general}"
    ((WARNINGS++)) || true
    JSON_WARNINGS+=("{\"category\": \"$category\", \"message\": \"$message\"}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && warning "$message"
    return 0
}

add_success() {
    local message="$1"
    local category="${2:-general}"
    local points="${3:-1}"
    ((SCORE += points)) || true
    JSON_SUCCESS+=("{\"category\": \"$category\", \"message\": \"$message\", \"points\": $points}")
    [[ "$OUTPUT_FORMAT" == "text" ]] && success "$message"
    return 0
}

add_check() {
    local points="${1:-1}"
    ((MAX_SCORE += points)) || true
}

# =============================================================================
# Validations
# =============================================================================

validate_structure() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "1. Base structure"

    # CLAUDE.md
    add_check 2
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        add_success "CLAUDE.md present" "structure" 1

        # Check minimum content
        add_check 1
        if grep -q "IMPORTANT" "$TARGET_DIR/CLAUDE.md" 2>/dev/null; then
            add_success "CLAUDE.md contains IMPORTANT directives" "structure" 1
        else
            add_warning "CLAUDE.md does not contain IMPORTANT directives" "structure"
        fi
    else
        add_error "CLAUDE.md missing" "structure"
    fi

    # .claude/
    add_check 1
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        add_success ".claude/ present" "structure" 1
    else
        add_error ".claude/ missing" "structure"
    fi

    # .claude/commands/
    add_check 2
    if [[ -d "$TARGET_DIR/.claude/commands" ]]; then
        # Use recursive find to count files in subdirectories
        local cmd_count
        cmd_count=$(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$cmd_count" -gt 0 ]]; then
            add_success ".claude/commands/ contains $cmd_count command(s)" "structure" 2
        else
            add_warning ".claude/commands/ is empty" "structure"
        fi
    else
        add_warning ".claude/commands/ missing" "structure"
    fi

    # .claude/settings.json
    add_check 2
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]]; then
        add_success ".claude/settings.json present" "structure" 1

        # Validate JSON
        if validate_json "$TARGET_DIR/.claude/settings.json"; then
            add_success ".claude/settings.json is valid JSON" "structure" 1
        else
            add_error ".claude/settings.json invalid JSON" "structure"
        fi
    else
        add_warning ".claude/settings.json missing" "structure"
    fi
}

validate_commands() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "2. Standard commands"

    # Commands are now in subdirectories by category
    local standard_commands=("work/work-explore" "work/work-plan" "work/work-commit" "qa/qa-review")

    for cmd in "${standard_commands[@]}"; do
        add_check 1
        local cmd_name
        cmd_name=$(basename "$cmd")
        if [[ -f "$TARGET_DIR/.claude/commands/$cmd.md" ]]; then
            add_success "Command $cmd_name present" "commands" 1
        else
            add_warning "Command $cmd_name missing (recommended)" "commands"
        fi
    done
}

validate_skills() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "3. Skills"

    add_check 2
    if [[ -d "$TARGET_DIR/.claude/skills" ]]; then
        local skills_count
        skills_count=$(find "$TARGET_DIR/.claude/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$skills_count" -gt 0 ]]; then
            add_success ".claude/skills/ contains $skills_count skill(s)" "skills" 2

            # Validate the YAML format of skills
            add_check 1
            local valid_skills=0
            local total_skills=0
            for skill_dir in "$TARGET_DIR/.claude/skills/"*/; do
                if [[ -d "$skill_dir" ]]; then
                    ((total_skills++)) || true
                    local skill_file="$skill_dir/SKILL.md"
                    if [[ -f "$skill_file" ]]; then
                        # Check for YAML frontmatter presence
                        if head -1 "$skill_file" | grep -q "^---"; then
                            ((valid_skills++)) || true
                        fi
                    fi
                fi
            done
            if [[ "$total_skills" -gt 0 ]] && [[ "$valid_skills" -eq "$total_skills" ]]; then
                add_success "All skills have valid YAML frontmatter" "skills" 1
            elif [[ "$valid_skills" -gt 0 ]]; then
                add_warning "$valid_skills/$total_skills skills with valid YAML frontmatter" "skills"
            fi
        else
            add_warning ".claude/skills/ is empty" "skills"
        fi
    else
        add_warning ".claude/skills/ missing" "skills"
    fi
}

validate_hooks() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "4. Hooks"

    add_check 2
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]] && command_exists jq; then
        local pre_hooks post_hooks session_hooks
        pre_hooks=$(jq '.hooks.PreToolUse // [] | length' "$TARGET_DIR/.claude/settings.json" 2>/dev/null || echo "0")
        post_hooks=$(jq '.hooks.PostToolUse // [] | length' "$TARGET_DIR/.claude/settings.json" 2>/dev/null || echo "0")
        session_hooks=$(jq '.hooks.SessionStart // [] | length' "$TARGET_DIR/.claude/settings.json" 2>/dev/null || echo "0")
        local hooks_count=$((pre_hooks + post_hooks + session_hooks))

        if [[ "$hooks_count" -gt 0 ]]; then
            add_success "$hooks_count hook(s) configured: $pre_hooks Pre, $post_hooks Post, $session_hooks SessionStart" "hooks" 2
        else
            add_warning "No hooks configured in settings.json" "hooks"
        fi

        # Check if SessionStart is configured
        add_check 1
        if [[ "$session_hooks" -gt 0 ]]; then
            add_success "SessionStart hook configured" "hooks" 1
        else
            add_warning "SessionStart hook not configured (recommended)" "hooks"
        fi
    fi
}

validate_agents() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "4b. Agents"

    add_check 2
    if [[ -d "$TARGET_DIR/.claude/agents" ]]; then
        local agents_count
        agents_count=$(find "$TARGET_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$agents_count" -gt 0 ]]; then
            add_success ".claude/agents/ contains $agents_count agent(s)" "agents" 1

            # Check the agents' frontmatter
            add_check 1
            local valid_agents=0
            while IFS= read -r agent_file; do
                if head -1 "$agent_file" | grep -q "^---"; then
                    # Check for required fields
                    if grep -q "^name:" "$agent_file" && grep -q "^tools:" "$agent_file"; then
                        ((valid_agents++)) || true
                    fi
                fi
            done < <(find "$TARGET_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null)

            if [[ "$valid_agents" -eq "$agents_count" ]]; then
                add_success "All agents have valid frontmatter" "agents" 1
            else
                add_warning "$valid_agents/$agents_count agents with valid frontmatter" "agents"
            fi
        else
            add_warning ".claude/agents/ is empty" "agents"
        fi
    else
        add_warning ".claude/agents/ missing" "agents"
    fi
}

validate_rules() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "4c. Rules"

    add_check 2
    if [[ -d "$TARGET_DIR/.claude/rules" ]]; then
        local rules_count
        rules_count=$(find "$TARGET_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$rules_count" -gt 0 ]]; then
            add_success ".claude/rules/ contains $rules_count rule(s)" "rules" 1

            # Check the rules' frontmatter (optional but recommended)
            add_check 1
            local rules_with_paths=0
            while IFS= read -r rule_file; do
                if head -5 "$rule_file" | grep -q "^paths:"; then
                    ((rules_with_paths++)) || true
                fi
            done < <(find "$TARGET_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null)

            if [[ "$rules_with_paths" -gt 0 ]]; then
                add_success "$rules_with_paths rule(s) with path filtering" "rules" 1
            else
                add_warning "No rule with path filtering configured" "rules"
            fi
        else
            add_warning ".claude/rules/ is empty" "rules"
        fi
    else
        add_warning ".claude/rules/ missing" "rules"
    fi
}

validate_output_styles() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "4d. Output Styles"

    add_check 1
    if [[ -d "$TARGET_DIR/.claude/output-styles" ]]; then
        local styles_count
        styles_count=$(find "$TARGET_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$styles_count" -gt 0 ]]; then
            add_success ".claude/output-styles/ contains $styles_count style(s)" "output-styles" 1
        else
            add_warning ".claude/output-styles/ is empty" "output-styles"
        fi
    else
        add_warning ".claude/output-styles/ missing" "output-styles"
    fi
}

validate_command_files() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "5. Command files validation"

    local checked=0
    local valid=0

    # Recursive search across all subdirectories
    while IFS= read -r cmd_file; do
        if [[ -f "$cmd_file" ]]; then
            ((checked++)) || true
            local filename
            filename=$(basename "$cmd_file")
            local is_valid=true

            # Check that the file is not empty
            if [[ ! -s "$cmd_file" ]]; then
                add_error "$filename is empty" "command_files"
                is_valid=false
                continue
            fi

            # Check for the presence of a title
            if ! head -1 "$cmd_file" | grep -q "^#"; then
                add_warning "$filename has no title (# ...)" "command_files"
                is_valid=false
            fi

            $is_valid && { ((valid++)) || true; }
        fi
    done < <(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null)

    add_check 2
    if [[ "$checked" -gt 0 ]]; then
        if [[ "$valid" -eq "$checked" ]]; then
            add_success "$checked valid command files" "command_files" 2
        else
            add_success "$valid/$checked valid command files" "command_files" 1
        fi
    fi
}

validate_security() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "6. Security"

    # Check .gitignore for Claude Code entries
    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_success "CLAUDE.local.md in .gitignore" "security" 1
        else
            add_warning "CLAUDE.local.md should be in .gitignore" "security"
        fi
    else
        add_warning ".gitignore missing" "security"
    fi

    # CLAUDE.local.md MUST be gitignored (local config, may contain secrets)
    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -q "CLAUDE\.local\.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_success "CLAUDE.local.md in .gitignore" "security" 1
        else
            add_warning "CLAUDE.local.md should be in .gitignore (local config)" "security"
        fi
    fi

    # settings.local.json MUST be gitignored (local permissions/env)
    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -q "settings\.local\.json" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_success ".claude/settings.local.json in .gitignore" "security" 1
        else
            add_warning ".claude/settings.local.json should be in .gitignore" "security"
        fi
    fi

    # .claude/ and CLAUDE.md MUST NOT be gitignored (shared team config)
    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -qE "^\.claude/?$" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_warning ".claude/ should NOT be in .gitignore (team config to version)" "security"
        else
            add_success ".claude/ versionable (not in .gitignore)" "security" 1
        fi
    fi

    add_check 1
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        if grep -q "^CLAUDE\.md$" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            add_warning "CLAUDE.md should NOT be in .gitignore (project config to version)" "security"
        else
            add_success "CLAUDE.md versionable (not in .gitignore)" "security" 1
        fi
    fi

    # Check dangerous permissions
    add_check 1
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]]; then
        if grep -q '"deny"' "$TARGET_DIR/.claude/settings.json" 2>/dev/null; then
            if grep -A10 '"deny"' "$TARGET_DIR/.claude/settings.json" | grep -q "rm -rf"; then
                add_success "rm -rf blocked in permissions" "security" 1
            else
                add_warning "rm -rf is not explicitly blocked" "security"
            fi
        else
            add_warning "No 'deny' list in permissions" "security"
        fi
    fi
}

validate_coherence() {
    [[ "$OUTPUT_FORMAT" == "text" ]] && section "7. Consistency CLAUDE.md ↔ Commands"

    add_check 2
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]] && [[ -d "$TARGET_DIR/.claude/commands" ]]; then
        # Extract only foundation commands mentioned in CLAUDE.md
        # Patterns: /work-*, /dev-*, /qa-*, /ops-*, /doc-*, /biz-*, /growth-*, /data-*, /legal-*, /assistant
        local mentioned_commands
        mentioned_commands=$(grep -oE '/(work|dev|qa|ops|doc|biz|growth|data|legal)-[a-z0-9-]+|/assistant' "$TARGET_DIR/CLAUDE.md" 2>/dev/null | sort -u || true)

        local missing=0
        local found=0
        for cmd in $mentioned_commands; do
            local cmd_name="${cmd#/}"
            # Search recursively in subdirectories
            if find "$TARGET_DIR/.claude/commands" -name "$cmd_name.md" -type f 2>/dev/null | grep -q .; then
                ((found++)) || true
            else
                ((missing++)) || true
                debug "Mentioned command but not found: $cmd_name"
            fi
        done

        if [[ "$missing" -eq 0 ]] && [[ "$found" -gt 0 ]]; then
            add_success "All documented commands exist ($found)" "coherence" 2
        elif [[ "$found" -gt 0 ]]; then
            add_warning "$missing command(s) mentioned in CLAUDE.md not found" "coherence"
            add_success "$found consistent commands" "coherence" 1
        fi
    fi
}

# =============================================================================
# Results output
# =============================================================================

output_text_summary() {
    echo ""
    separator "="
    echo "  Validation summary"
    separator "="
    echo ""

    # Maturity score
    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi

    echo -e "  Maturity score: ${BOLD}$SCORE/$MAX_SCORE${NC} ($percentage%)"
    echo ""

    # Progress bar
    local bar_width=40
    local filled=$((percentage * bar_width / 100))
    local empty=$((bar_width - filled))
    printf "  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]\n"
    echo ""

    if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        success "Valid configuration! No issues detected."
    elif [[ $ERRORS -eq 0 ]]; then
        warning "Valid configuration with $WARNINGS warning(s)"
    else
        error_no_exit "Invalid configuration: $ERRORS error(s), $WARNINGS warning(s)"
    fi

    echo ""
}

output_json() {
    local errors_json
    local warnings_json
    local success_json

    # Build the JSON arrays
    if [[ ${#JSON_ERRORS[@]} -gt 0 ]]; then
        errors_json=$(printf '%s,' "${JSON_ERRORS[@]}")
        errors_json="[${errors_json%,}]"
    else
        errors_json="[]"
    fi

    if [[ ${#JSON_WARNINGS[@]} -gt 0 ]]; then
        warnings_json=$(printf '%s,' "${JSON_WARNINGS[@]}")
        warnings_json="[${warnings_json%,}]"
    else
        warnings_json="[]"
    fi

    if [[ ${#JSON_SUCCESS[@]} -gt 0 ]]; then
        success_json=$(printf '%s,' "${JSON_SUCCESS[@]}")
        success_json="[${success_json%,}]"
    else
        success_json="[]"
    fi

    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi

    cat << EOF
{
  "valid": $([[ $ERRORS -eq 0 ]] && echo "true" || echo "false"),
  "errors_count": $ERRORS,
  "warnings_count": $WARNINGS,
  "score": $SCORE,
  "max_score": $MAX_SCORE,
  "percentage": $percentage,
  "errors": $errors_json,
  "warnings": $warnings_json,
  "success": $success_json
}
EOF
}

output_score() {
    local percentage=0
    if [[ "$MAX_SCORE" -gt 0 ]]; then
        percentage=$((SCORE * 100 / MAX_SCORE))
    fi
    echo "$SCORE/$MAX_SCORE ($percentage%)"
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"

    # Check the directory
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Directory '$TARGET_DIR' does not exist"
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Header (except JSON and score)
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        title "Validation Claude Code Configuration"
        info "Project: $TARGET_DIR"
    fi

    # Run the validations
    validate_structure
    validate_commands
    validate_skills
    validate_hooks
    validate_agents
    validate_rules
    validate_output_styles
    validate_command_files
    validate_security
    validate_coherence

    # Output according to format
    case "$OUTPUT_FORMAT" in
        json)
            output_json
            ;;
        score)
            output_score
            ;;
        text)
            output_text_summary
            ;;
    esac

    # Exit code
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        exit 0  # Warnings are not blocking
    else
        exit 0
    fi
}

main "$@"
