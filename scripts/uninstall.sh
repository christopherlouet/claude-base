#!/bin/bash

# =============================================================================
# Claude-Socle Uninstall Script
# Removes the Claude Code configuration from a project
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

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
KEEP_CLAUDE_MD=false
KEEP_BACKUP=true
FORCE=false
REMOVE_LOCAL_FILES=false

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Uninstall${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Removes the Claude Code configuration from a project.
    Creates a backup before removal by default.

${BOLD}ARGUMENTS${NC}
    PATH                Target directory (default: current directory)

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -y, --yes           Non-interactive mode (auto-confirm)
    -f, --force         Remove without asking for confirmation
    -n, --dry-run       Simulate removal without deleting anything
    -q, --quiet         Quiet mode
    --keep-claude-md    Keep the customized CLAUDE.md file
    --no-backup         Do not create a backup before removal

${BOLD}REMOVED FILES${NC}
    .claude/            Full directory (commands, skills, settings)
    CLAUDE.md           Instructions file (unless --keep-claude-md)
    CLAUDE.local.md     Local configuration
    CLAUDE.local.md.example

${BOLD}EXAMPLES${NC}
    # Interactive uninstall
    $(basename "$0") ./my-project

    # Keep customized CLAUDE.md
    $(basename "$0") --keep-claude-md ./my-project

    # See what would be removed
    $(basename "$0") --dry-run ./my-project

EOF
}

show_version() {
    echo "claude-socle uninstall v${VERSION}"
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
            -y|--yes)
                NON_INTERACTIVE=true
                shift
                ;;
            -f|--force)
                FORCE=true
                NON_INTERACTIVE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                export QUIET=true
                shift
                ;;
            --keep-claude-md)
                KEEP_CLAUDE_MD=true
                shift
                ;;
            --no-backup)
                KEEP_BACKUP=false
                shift
                ;;
            --all)
                REMOVE_LOCAL_FILES=true
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
# Uninstall
# =============================================================================

create_backup() {
    local backup_dir
    backup_dir="$TARGET_DIR/.claude-backup.$(date +%Y%m%d_%H%M%S)"

    info "Creating a backup..."

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Backup → $backup_dir"
        return
    fi

    mkdir -p "$backup_dir"

    # Back up .claude/
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        cp -r "$TARGET_DIR/.claude" "$backup_dir/"
    fi

    # Back up CLAUDE.md
    if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        cp "$TARGET_DIR/CLAUDE.md" "$backup_dir/"
    fi

    # Back up CLAUDE.local.md
    if [[ -f "$TARGET_DIR/CLAUDE.local.md" ]]; then
        cp "$TARGET_DIR/CLAUDE.local.md" "$backup_dir/"
    fi

    success "Backup created: $backup_dir"
}

remove_file() {
    local file="$1"
    local desc="$2"

    if [[ -f "$file" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Removing: $desc"
        else
            rm "$file"
            success "Removed: $desc"
        fi
    fi
}

remove_dir() {
    local dir="$1"
    local desc="$2"

    if [[ -d "$dir" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Removing: $desc"
        else
            rm -rf "$dir"
            success "Removed: $desc"
        fi
    fi
}

uninstall() {
    # Check the directory
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Directory '$TARGET_DIR' does not exist"
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Check that there is something to remove
    if [[ ! -d "$TARGET_DIR/.claude" ]] && [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        error "No Claude configuration found in '$TARGET_DIR'"
    fi

    title "Claude Code Uninstall"
    info "Project: $TARGET_DIR"
    $DRY_RUN && warning "Dry-run mode enabled"
    echo ""

    # Show what will be removed
    section "Files to remove"

    local files_to_remove=()

    if [[ -d "$TARGET_DIR/.claude" ]]; then
        local cmd_count
        local skills_count
        cmd_count=$(find "$TARGET_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        skills_count=$(count_dirs "$TARGET_DIR/.claude/skills")
        echo "  - .claude/ ($cmd_count commands, $skills_count skills)"
        files_to_remove+=(".claude/")
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.md" ]] && ! $KEEP_CLAUDE_MD; then
        echo "  - CLAUDE.md"
        files_to_remove+=("CLAUDE.md")
    elif [[ -f "$TARGET_DIR/CLAUDE.md" ]] && $KEEP_CLAUDE_MD; then
        echo -e "  - CLAUDE.md ${DIM}(kept)${NC}"
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.local.md" ]]; then
        if $REMOVE_LOCAL_FILES; then
            echo "  - CLAUDE.local.md"
            files_to_remove+=("CLAUDE.local.md")
        else
            echo -e "  - CLAUDE.local.md ${DIM}(kept)${NC}"
        fi
    fi

    if [[ -f "$TARGET_DIR/CLAUDE.local.md.example" ]]; then
        echo "  - CLAUDE.local.md.example"
        files_to_remove+=("CLAUDE.local.md.example")
    fi

    echo ""

    # Ask for confirmation
    if ! $FORCE && ! ${NON_INTERACTIVE:-false}; then
        warning "This action is irreversible!"
        if ! confirm "Remove the Claude Code configuration?" "n"; then
            info "Uninstall cancelled"
            exit 0
        fi
    fi

    # Create backup if requested
    if $KEEP_BACKUP; then
        create_backup
    fi

    # Remove the files
    section "Removal"

    remove_dir "$TARGET_DIR/.claude" ".claude/"

    if ! $KEEP_CLAUDE_MD; then
        remove_file "$TARGET_DIR/CLAUDE.md" "CLAUDE.md"
    fi

    if $REMOVE_LOCAL_FILES; then
        remove_file "$TARGET_DIR/CLAUDE.local.md" "CLAUDE.local.md"
    fi
    remove_file "$TARGET_DIR/CLAUDE.local.md.example" "CLAUDE.local.md.example"

    # Clean .gitignore if present
    if [[ -f "$TARGET_DIR/.gitignore" ]] && ! $DRY_RUN; then
        # Remove the Claude Code lines from .gitignore
        if grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            # Create a temporary file without the Claude lines
            grep -v "CLAUDE.local.md\|CLAUDE.md\|\.claude/\|.claude/settings.local.json\|# Claude Code" "$TARGET_DIR/.gitignore" > "$TARGET_DIR/.gitignore.tmp" 2>/dev/null || true
            mv "$TARGET_DIR/.gitignore.tmp" "$TARGET_DIR/.gitignore"
            success "Cleaned: .gitignore"
        fi
    fi

    # Summary
    echo ""
    separator "="
    success "Uninstall complete!"
    separator "="
    echo ""

    if $KEEP_CLAUDE_MD && [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
        info "CLAUDE.md was kept"
    fi

    if $KEEP_BACKUP && ! $DRY_RUN; then
        info "A backup was created in the project directory"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"
    uninstall
}

main "$@"
