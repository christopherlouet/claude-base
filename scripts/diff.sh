#!/usr/bin/env bash

# =============================================================================
# Claude-Socle Diff Script
# Compares a project's configuration with the foundation
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
SHOW_ONLY="all"  # all, new, modified, deleted
USE_COLOR=true
SHOW_CONTENT=false

# Counters
NEW_FILES=0
MODIFIED_FILES=0
DELETED_FILES=0
IDENTICAL_FILES=0

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Diff${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Compares a project's Claude Code configuration with the foundation.
    Displays the differences between local files and the foundation.

${BOLD}ARGUMENTS${NC}
    PATH                Directory to compare (default: current directory)

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -q, --quiet         Quiet mode (summary only)
    --new               Show only new files (in foundation)
    --modified          Show only modified files
    --deleted           Show only deleted files (not in foundation)
    --content           Show the content of the differences
    --no-color          Disable colors

${BOLD}LEGEND${NC}
    ${GREEN}+${NC} New in the foundation (to add)
    ${YELLOW}~${NC} Modified (different from the foundation)
    ${RED}-${NC} Deleted from the foundation (local only)
    ${DIM}=${NC} Identical

${BOLD}EXAMPLES${NC}
    # See all differences
    $(basename "$0") ./my-project

    # See only modified files
    $(basename "$0") --modified ./my-project

    # See the content of the differences
    $(basename "$0") --content ./my-project

EOF
}

show_version() {
    echo "claude-socle diff v${VERSION}"
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
                QUIET=true
                shift
                ;;
            --new)
                SHOW_ONLY="new"
                shift
                ;;
            --modified)
                SHOW_ONLY="modified"
                shift
                ;;
            --deleted)
                SHOW_ONLY="deleted"
                shift
                ;;
            --content)
                SHOW_CONTENT=true
                shift
                ;;
            --no-color)
                USE_COLOR=false
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
# Comparison functions
# =============================================================================

show_diff_content() {
    local file1="$1"
    local file2="$2"

    if command_exists colordiff && $USE_COLOR; then
        colordiff "$file1" "$file2" 2>/dev/null || true
    else
        diff "$file1" "$file2" 2>/dev/null || true
    fi
}

compare_file() {
    local socle_file="$1"
    local local_file="$2"
    local filename="$3"
    # shellcheck disable=SC2034  # Reserved for future category-based filtering
    local category="$4"

    if [[ -f "$local_file" ]]; then
        if [[ -f "$socle_file" ]]; then
            # Both files exist
            if diff -q "$socle_file" "$local_file" > /dev/null 2>&1; then
                # Identical
                ((IDENTICAL_FILES++)) || true
                if [[ "$SHOW_ONLY" == "all" ]] && ! $QUIET; then
                    echo -e "  ${DIM}= $filename${NC}"
                fi
            else
                # Modified
                ((MODIFIED_FILES++)) || true
                if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "modified" ]]; then
                    echo -e "  ${YELLOW}~ $filename${NC}"
                    if $SHOW_CONTENT; then
                        echo ""
                        show_diff_content "$local_file" "$socle_file"
                        echo ""
                    fi
                fi
            fi
        else
            # Deleted from the foundation (exists locally but not in foundation)
            ((DELETED_FILES++)) || true
            if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "deleted" ]]; then
                echo -e "  ${RED}- $filename${NC} ${DIM}(local only)${NC}"
            fi
        fi
    elif [[ -f "$socle_file" ]]; then
        # New in the foundation
        ((NEW_FILES++)) || true
        if [[ "$SHOW_ONLY" == "all" ]] || [[ "$SHOW_ONLY" == "new" ]]; then
            echo -e "  ${GREEN}+ $filename${NC} ${DIM}(new)${NC}"
        fi
    fi
}

compare_commands() {
    section "Commands (.claude/commands/)"

    local socle_dir="$SOCLE_DIR/.claude/commands"
    local local_dir="$TARGET_DIR/.claude/commands"

    # Build a unique list of all files with relative paths
    local all_files=()

    # Foundation files (recursive)
    if [[ -d "$socle_dir" ]]; then
        while IFS= read -r f; do
            # Compute the relative path
            local rel_path="${f#$socle_dir/}"
            all_files+=("$rel_path")
        done < <(find "$socle_dir" -name "*.md" -type f 2>/dev/null)
    fi

    # Local files (recursive)
    if [[ -d "$local_dir" ]]; then
        while IFS= read -r f; do
            # Compute the relative path
            local rel_path="${f#$local_dir/}"
            all_files+=("$rel_path")
        done < <(find "$local_dir" -name "*.md" -type f 2>/dev/null)
    fi

    # Deduplicate and sort
    local unique_files
    unique_files=$(printf '%s\n' "${all_files[@]}" | sort -u)

    # Compare each file
    for rel_path in $unique_files; do
        compare_file "$socle_dir/$rel_path" "$local_dir/$rel_path" "$rel_path" "commands"
    done
}

compare_skills() {
    section "Skills (.claude/skills/)"

    local socle_dir="$SOCLE_DIR/.claude/skills"
    local local_dir="$TARGET_DIR/.claude/skills"

    # Build a unique list of all skills
    local all_skills=()

    # Foundation skills
    if [[ -d "$socle_dir" ]]; then
        for d in "$socle_dir/"*/; do
            [[ -d "$d" ]] && all_skills+=("$(basename "$d")")
        done
    fi

    # Local skills
    if [[ -d "$local_dir" ]]; then
        for d in "$local_dir/"*/; do
            [[ -d "$d" ]] && all_skills+=("$(basename "$d")")
        done
    fi

    # Deduplicate and sort
    local unique_skills
    unique_skills=$(printf '%s\n' "${all_skills[@]}" | sort -u)

    # Compare each skill
    for skillname in $unique_skills; do
        local socle_skill="$socle_dir/$skillname/SKILL.md"
        local local_skill="$local_dir/$skillname/SKILL.md"
        compare_file "$socle_skill" "$local_skill" "$skillname/SKILL.md" "skills"
    done
}

compare_settings() {
    section "Configuration"

    # settings.json
    compare_file \
        "$SOCLE_DIR/.claude/settings.json" \
        "$TARGET_DIR/.claude/settings.json" \
        "settings.json" \
        "config"

    # CLAUDE.md
    compare_file \
        "$SOCLE_DIR/CLAUDE.md" \
        "$TARGET_DIR/CLAUDE.md" \
        "CLAUDE.md" \
        "config"
}

print_summary() {
    echo ""
    separator "="
    echo "  Summary of differences"
    separator "="
    echo ""

    # shellcheck disable=SC2034  # Used for summary display
    local total=$((NEW_FILES + MODIFIED_FILES + DELETED_FILES + IDENTICAL_FILES))

    echo -e "  ${GREEN}+ New:${NC}         $NEW_FILES file(s) to add"
    echo -e "  ${YELLOW}~ Modified:${NC}    $MODIFIED_FILES different file(s)"
    echo -e "  ${RED}- Deleted:${NC}     $DELETED_FILES local-only file(s)"
    echo -e "  ${DIM}= Identical:${NC}   $IDENTICAL_FILES file(s)"
    echo ""

    if [[ $NEW_FILES -gt 0 ]] || [[ $MODIFIED_FILES -gt 0 ]]; then
        info "To synchronize: ./scripts/update.sh --force $TARGET_DIR"
    else
        success "Configuration up to date with the foundation!"
    fi

    echo ""
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

    # Check that there is a configuration
    if [[ ! -d "$TARGET_DIR/.claude" ]]; then
        error "No Claude configuration found in '$TARGET_DIR'"
    fi

    title "Comparison with the foundation"
    info "Project:    $TARGET_DIR"
    info "Foundation: $SOCLE_DIR"
    echo ""

    # Legend
    if [[ "$SHOW_ONLY" == "all" ]] && ! $QUIET; then
        echo -e "  ${DIM}Legend: ${GREEN}+ new${NC}  ${YELLOW}~ modified${NC}  ${RED}- deleted${NC}  ${DIM}= identical${NC}"
        echo ""
    fi

    # Compare
    compare_commands
    compare_skills
    compare_settings

    # Summary
    print_summary

    # Exit code
    if [[ $NEW_FILES -gt 0 ]] || [[ $MODIFIED_FILES -gt 0 ]]; then
        exit 1  # Differences exist
    else
        exit 0  # Synchronized
    fi
}

main "$@"
