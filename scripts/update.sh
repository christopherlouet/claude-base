#!/bin/bash

# =============================================================================
# Claude-Socle Update Script
# Updates Claude commands from the foundation
# =============================================================================

set -euo pipefail

# Load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# Version read from the VERSION file
VERSION=$(cat "$SCRIPT_DIR/../VERSION" 2>/dev/null || echo "unknown")

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Enable error handler and check prerequisites
enable_error_handler
check_base_requirements

# =============================================================================
# Path constants
# =============================================================================

COMMANDS_SUBDIR=".claude/commands"
SKILLS_SUBDIR=".claude/skills"
AGENTS_SUBDIR=".claude/agents"
RULES_SUBDIR=".claude/rules"
STYLES_SUBDIR=".claude/output-styles"
TEMPLATES_SUBDIR=".claude/templates"
HOOK_SCRIPTS_SUBDIR="scripts/hooks"

# =============================================================================
# Variables
# =============================================================================

TARGET_DIR=""
FORCE_UPDATE=false
BACKUP_ONLY=false
ADD_HOOK=""
UPDATE_SETTINGS=false
UPDATE_SKILLS=false
UPDATE_AGENTS=false
UPDATE_RULES=false
UPDATE_STYLES=false
UPDATE_TEMPLATES=false
UPDATE_HOOK_SCRIPTS=false
CLEAN_BEFORE_UPDATE=false
DETECT_ORPHANS=false
REMOVE_ORPHANS=false
UPGRADE_CLAUDE_MD=false
RESTORE_BACKUP=""

# Counters
UPDATED=0
ADDED=0
SKIPPED=0
ORPHANS_FOUND=0
ORPHANS_REMOVED=0

# Temp files tracking for cleanup
_TEMP_FILES=()

# =============================================================================
# Cleanup trap
# =============================================================================

cleanup_temp_files() {
    for f in "${_TEMP_FILES[@]}"; do
        rm -f "$f" 2>/dev/null || true
    done
}
trap cleanup_temp_files EXIT

# Safe mktemp wrapper with error checking
safe_mktemp() {
    local tmp
    tmp=$(mktemp) || error "Cannot create temp file"
    _TEMP_FILES+=("$tmp")
    echo "$tmp"
}

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Update${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Updates the Claude Code commands and configuration of a project.
    Automatically creates a backup before updating.

${BOLD}ARGUMENTS${NC}
    PATH                Directory to update (default: current directory)

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -y, --yes           Non-interactive mode (answers yes to questions)
    -f, --force         Force update (overwrites all files)
    -n, --dry-run       Simulate the update without modifying anything
    -q, --quiet         Quiet mode
    --verbose           Verbose mode (debug)
    --backup-only       Create only a backup without updating
    --clean             Delete old files before updating
    --detect-orphans    Detect files absent from the foundation (orphans)
    --remove-orphans    Remove orphan files (implies --detect-orphans)
    --settings          Also update settings.json
    --skills            Also update the skills/ directory
    --agents            Also update the agents/ directory
    --rules             Also update the rules/ directory
    --styles            Also update the output-styles/ directory
    --templates         Also update the templates/ directory
    --hook-scripts      Also update the scripts in scripts/hooks/ (referenced by settings.json)
    --all               Update everything (commands, settings, skills, agents, rules, styles, templates, hook-scripts)
    --upgrade-claude-md Migrate CLAUDE.md to @imports (copies .claude/docs/reference/)
    --changelog         Show what's new in the foundation
    --restore BACKUP    Restore from a previous backup
    --add-hook HOOK     Add a hook to the existing settings.json without overwriting (e.g., rtk)

${BOLD}AVAILABLE HOOKS${NC}
    rtk                 RTK token optimizer (reduces tokens by 60-90%, requires: brew install rtk)

${BOLD}EXAMPLES${NC}
    # Interactive update
    $(basename "$0") ./my-project

    # Forced update of everything
    $(basename "$0") -f --all ./my-project

    # Backup only
    $(basename "$0") --backup-only ./my-project

    # See what would be updated
    $(basename "$0") --dry-run ./my-project

    # Detect orphan files
    $(basename "$0") --detect-orphans ./my-project

    # Remove orphan files
    $(basename "$0") --remove-orphans ./my-project

    # Restore from a backup
    $(basename "$0") --restore .claude/commands.backup.20240101_120000 ./my-project

    # Add the RTK hook (token optimizer) without overwriting settings.json
    $(basename "$0") --add-hook rtk ./my-project

${BOLD}FOUNDATION STATISTICS${NC}
    Agents:    $(count_agents "$SOCLE_DIR")
    Skills:    $(count_skills "$SOCLE_DIR")
    Hooks:     $(count_hooks "$SOCLE_DIR")

EOF
}

show_version() {
    echo "claude-socle update v${VERSION}"
}

show_changelog() {
    local changelog_file="$SOCLE_DIR/CHANGELOG.md"
    if [[ -f "$changelog_file" ]]; then
        # Show the first 50 lines of the changelog
        head -50 "$changelog_file"
    else
        info "No changelog available"
    fi
}

# =============================================================================
# Argument parsing
# =============================================================================

# shellcheck disable=SC2034
# UPDATE_* and UPGRADE_* variables are used via ${!flag_name} indirection in main()
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
                FORCE_UPDATE=true
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
            --verbose)
                export VERBOSE=true
                shift
                ;;
            --backup-only)
                BACKUP_ONLY=true
                shift
                ;;
            --clean)
                CLEAN_BEFORE_UPDATE=true
                shift
                ;;
            --detect-orphans)
                DETECT_ORPHANS=true
                shift
                ;;
            --remove-orphans)
                DETECT_ORPHANS=true
                REMOVE_ORPHANS=true
                shift
                ;;
            --settings)       UPDATE_SETTINGS=true;    shift ;;
            --skills)         UPDATE_SKILLS=true;      shift ;;
            --agents)         UPDATE_AGENTS=true;      shift ;;
            --rules)          UPDATE_RULES=true;       shift ;;
            --styles)         UPDATE_STYLES=true;      shift ;;
            --templates)      UPDATE_TEMPLATES=true;   shift ;;
            --hook-scripts)   UPDATE_HOOK_SCRIPTS=true; shift ;;
            --upgrade-claude-md) UPGRADE_CLAUDE_MD=true; shift ;;
            --all)
                UPDATE_SETTINGS=true
                UPDATE_SKILLS=true
                UPDATE_AGENTS=true
                UPDATE_RULES=true
                UPDATE_STYLES=true
                UPDATE_TEMPLATES=true
                UPDATE_HOOK_SCRIPTS=true
                UPGRADE_CLAUDE_MD=true
                CLEAN_BEFORE_UPDATE=true
                shift
                ;;
            --changelog)
                show_changelog
                exit 0
                ;;
            --add-hook)
                if [[ -z "${2:-}" ]]; then
                    error "Option --add-hook requires an argument (hook name, e.g., rtk)"
                fi
                ADD_HOOK="$2"
                shift 2
                ;;
            --restore)
                if [[ -z "${2:-}" ]]; then
                    error "Option --restore requires an argument (backup path)"
                fi
                RESTORE_BACKUP="$2"
                shift 2
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
# Update functions
# =============================================================================

create_backup() {
    local backup_dir
    backup_dir="$TARGET_DIR/$COMMANDS_SUBDIR.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Backup → $backup_dir"
            # Set BACKUP_DIR even in DRY_RUN so downstream code doesn't break
            echo "$backup_dir"
        else
            cp -r "$TARGET_DIR/$COMMANDS_SUBDIR" "$backup_dir"
            success "Backup created: $backup_dir"
            echo "$backup_dir"
        fi
    fi
}

restore_backup() {
    local backup_path="$1"

    # Resolve relative to TARGET_DIR if not absolute
    if [[ "$backup_path" != /* ]]; then
        backup_path="$TARGET_DIR/$backup_path"
    fi

    if [[ ! -d "$backup_path" ]]; then
        # List available backups
        info "Available backups:"
        local found=false
        while IFS= read -r bdir; do
            if [[ -d "$bdir" ]]; then
                echo "  $(basename "$bdir")"
                found=true
            fi
        done < <(find "$TARGET_DIR/$COMMANDS_SUBDIR".backup.* -maxdepth 0 -type d 2>/dev/null | sort -r || true)

        if ! $found; then
            info "  (no backup found)"
        fi

        error "Backup not found: $backup_path"
    fi

    section "Restore from backup"
    info "Source: $backup_path"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Restore $backup_path to $TARGET_DIR/$COMMANDS_SUBDIR"
        return
    fi

    if [[ -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        # Create a safety backup before restoring
        local safety_backup
        safety_backup="$TARGET_DIR/$COMMANDS_SUBDIR.pre-restore.$(date +%Y%m%d_%H%M%S)"
        cp -r "$TARGET_DIR/$COMMANDS_SUBDIR" "$safety_backup"
        info "Safety backup: $safety_backup"
    fi

    rm -rf "${TARGET_DIR:?}/${COMMANDS_SUBDIR:?}"
    cp -r "$backup_path" "$TARGET_DIR/$COMMANDS_SUBDIR"
    success "Restore completed from $(basename "$backup_path")"
}

update_command_file() {
    local src="$1"
    local rel_path="$2"  # Relative path from commands/ (e.g., work/work-explore.md)
    local filename
    filename=$(basename "$src")
    local dest="$TARGET_DIR/$COMMANDS_SUBDIR/$rel_path"

    # Create the subdirectory if needed
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]] && ! $DRY_RUN; then
        mkdir -p "$dest_dir"
    fi

    if [[ -f "$dest" ]]; then
        # The file exists, check if it has changed
        if diff -q "$src" "$dest" > /dev/null 2>&1; then
            # Identical, nothing to do
            debug "$filename: identical"
            return
        fi

        # File differs
        if $FORCE_UPDATE; then
            # Force mode: overwrite
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Update: $filename"
            else
                cp "$src" "$dest"
            fi
            success "  $filename updated"
            ((UPDATED++)) || true
        elif ${NON_INTERACTIVE:-false}; then
            # Non-interactive mode without force: skip
            warning "  $filename skipped (use --force to overwrite)"
            ((SKIPPED++)) || true
        else
            # Interactive mode: ask
            echo ""
            prompt "$filename has been modified. What to do?"
            echo "  [y] Overwrite  [n] Skip  [d] View diff"
            read -r -n 1 choice
            echo

            case "$choice" in
                d|D)
                    echo ""
                    echo -e "${DIM}--- Local${NC}"
                    echo -e "${DIM}+++ Foundation${NC}"
                    diff "$dest" "$src" || true
                    echo ""
                    if confirm "Overwrite $filename?" "n"; then
                        cp "$src" "$dest"
                        success "  $filename updated"
                        ((UPDATED++)) || true
                    else
                        warning "  $filename skipped"
                        ((SKIPPED++)) || true
                    fi
                    ;;
                y|Y)
                    cp "$src" "$dest"
                    success "  $filename updated"
                    ((UPDATED++)) || true
                    ;;
                *)
                    warning "  $filename skipped"
                    ((SKIPPED++)) || true
                    ;;
            esac
        fi
    else
        # New file
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Add: $filename"
        else
            cp "$src" "$dest"
        fi
        success "  $filename added (new)"
        ((ADDED++)) || true
    fi
}

update_commands() {
    section "Updating commands"

    # Create the directory if it doesn't exist
    if [[ ! -d "$TARGET_DIR/$COMMANDS_SUBDIR" ]]; then
        make_dir "$TARGET_DIR/$COMMANDS_SUBDIR"
    fi

    local before
    before=$(find "$TARGET_DIR/$COMMANDS_SUBDIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    # Recursively iterate over the commands of the foundation
    local socle_commands_dir="$SOCLE_DIR/$COMMANDS_SUBDIR"
    while IFS= read -r cmd; do
        if [[ -f "$cmd" ]]; then
            # Compute the relative path from commands/
            local rel_path="${cmd#"$socle_commands_dir"/}"
            update_command_file "$cmd" "$rel_path"
        fi
    done < <(find "$socle_commands_dir" -name "*.md" -type f 2>/dev/null || true)

    local after
    after=$(find "$TARGET_DIR/$COMMANDS_SUBDIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    info "Commands: $before → $after"
}

add_hook() {
    local hook_name="$1"
    local settings_file="$TARGET_DIR/.claude/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        error "settings.json not found in $TARGET_DIR/.claude/"
    fi

    if ! command -v jq &>/dev/null; then
        error "jq is required for --add-hook. Install it: https://jqlang.github.io/jq/download/"
    fi

    case "$hook_name" in
        rtk)
            section "Adding RTK hook (token optimizer)"

            # Check if hook already exists
            if jq -e '.hooks.PreToolUse[]? | select(.description | test("RTK"))' "$settings_file" >/dev/null 2>&1; then
                success "RTK hook already present in settings.json"
                return
            fi

            local rtk_hook
            rtk_hook=$(cat <<'HOOKJSON'
{
    "description": "RTK token optimizer - rewrites commands to reduce tokens by 60-90% (install rtk: brew install rtk)",
    "matcher": "Bash",
    "hooks": [
        {
            "type": "command",
            "command": "bash -c 'command -v rtk >/dev/null 2>&1 || exit 0; command -v jq >/dev/null 2>&1 || exit 0; INPUT=$(cat); CMD=$(echo \"$INPUT\" | jq -r \".tool_input.command // empty\"); [ -z \"$CMD\" ] && exit 0; REWRITTEN=$(rtk rewrite \"$CMD\" 2>/dev/null) || exit 0; [ \"$CMD\" = \"$REWRITTEN\" ] && exit 0; ORIGINAL_INPUT=$(echo \"$INPUT\" | jq -c \".tool_input\"); UPDATED_INPUT=$(echo \"$ORIGINAL_INPUT\" | jq --arg cmd \"$REWRITTEN\" \".command = \\$cmd\"); jq -n --argjson updated \"$UPDATED_INPUT\" \"{\\\"hookSpecificOutput\\\":{\\\"hookEventName\\\":\\\"PreToolUse\\\",\\\"permissionDecision\\\":\\\"allow\\\",\\\"permissionDecisionReason\\\":\\\"RTK auto-rewrite\\\",\\\"updatedInput\\\":\\$updated}}\"'",
            "timeout": 5000,
            "onFailure": "ignore"
        }
    ]
}
HOOKJSON
)

            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Add RTK hook to settings.json"
                return
            fi

            local tmp
            tmp=$(safe_mktemp)
            jq --argjson hook "$rtk_hook" '.hooks.PreToolUse += [$hook]' "$settings_file" > "$tmp"
            cp "$tmp" "$settings_file"
            rm -f "$tmp"
            success "RTK hook added to settings.json"
            info "Install RTK: brew install rtk (or cargo install --git https://github.com/rtk-ai/rtk)"
            ;;
        *)
            error "Unknown hook: $hook_name. Available hooks: rtk"
            ;;
    esac
}

update_settings() {
    section "Updating settings.json"

    local src="$SOCLE_DIR/.claude/settings.json"
    local dest="$TARGET_DIR/.claude/settings.json"

    if [[ ! -f "$src" ]]; then
        warning "Source settings.json not found"
        return
    fi

    if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
        copy_file "$src" "$dest"
        success "settings.json updated"
    elif [[ -f "$dest" ]]; then
        if confirm "Update .claude/settings.json?" "n"; then
            copy_file "$src" "$dest"
            success "settings.json updated"
        else
            warning "settings.json skipped"
        fi
    else
        copy_file "$src" "$dest"
        success "settings.json created"
    fi
}

# =============================================================================
# Generic directory update function (replaces update_skills/agents/rules/styles/templates)
# =============================================================================

# Count files in a source directory for a given type
_count_dir_files() {
    local src_dir="$1"
    local name="$2"

    case "$name" in
        templates)
            find "$src_dir" -type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) 2>/dev/null | wc -l | tr -d ' '
            ;;
        skills)
            count_dirs "$src_dir"
            ;;
        hook_scripts)
            find "$src_dir" -type f -name "*.sh" 2>/dev/null | wc -l | tr -d ' '
            ;;
        *)
            find "$src_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
            ;;
    esac
}

# Generic update for a .claude/ subdirectory
# Uses per-file diff checking to avoid overwriting user customizations.
# Arguments:
#   $1 - name: internal identifier (skills, agents, rules, styles, templates)
#   $2 - src_subdir: relative path from socle root (.claude/skills, etc.)
#   $3 - label: display name for messages (Skills, Agents, etc.)
update_directory() {
    local name="$1"
    local src_subdir="$2"
    local label="$3"

    section "Updating $label"

    local src_dir="$SOCLE_DIR/$src_subdir"
    local dest_dir="$TARGET_DIR/$src_subdir"

    if [[ ! -d "$src_dir" ]]; then
        warning "Source $label directory not found"
        return
    fi

    make_dir "$dest_dir"

    local dir_updated=0
    local dir_added=0
    local dir_skipped=0
    local dir_identical=0

    # Find all files in source directory
    local find_pattern
    case "$name" in
        templates)
            find_pattern='-type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \)'
            ;;
        hook_scripts)
            find_pattern='-type f -name "*.sh"'
            ;;
        *)
            find_pattern='-type f -name "*.md"'
            ;;
    esac

    while IFS= read -r src_file; do
        if [[ ! -f "$src_file" ]]; then
            continue
        fi

        local rel_path="${src_file#"$src_dir"/}"
        local dest_file="$dest_dir/$rel_path"
        local filename
        filename=$(basename "$src_file")

        # Create subdirectory if needed
        local file_dest_dir
        file_dest_dir=$(dirname "$dest_file")
        if [[ ! -d "$file_dest_dir" ]] && ! $DRY_RUN; then
            mkdir -p "$file_dest_dir"
        fi

        if [[ -f "$dest_file" ]]; then
            # File exists — check if identical
            if diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
                debug "$rel_path: identical"
                ((dir_identical++)) || true
                continue
            fi

            # File differs
            if $FORCE_UPDATE; then
                if $DRY_RUN; then
                    echo -e "${DIM}[DRY-RUN]${NC} Update: $rel_path"
                else
                    cp "$src_file" "$dest_file"
                fi
                debug "  $rel_path updated"
                ((dir_updated++)) || true
            elif ${NON_INTERACTIVE:-false}; then
                warning "  $rel_path skipped (use --force to overwrite)"
                ((dir_skipped++)) || true
            else
                echo ""
                prompt "$rel_path has been modified. What to do?"
                echo "  [y] Overwrite  [n] Skip  [d] View diff"
                read -r -n 1 choice
                echo

                case "$choice" in
                    d|D)
                        echo ""
                        echo -e "${DIM}--- Local${NC}"
                        echo -e "${DIM}+++ Foundation${NC}"
                        diff "$dest_file" "$src_file" || true
                        echo ""
                        if confirm "Overwrite $rel_path?" "n"; then
                            cp "$src_file" "$dest_file"
                            debug "  $rel_path updated"
                            ((dir_updated++)) || true
                        else
                            warning "  $rel_path skipped"
                            ((dir_skipped++)) || true
                        fi
                        ;;
                    y|Y)
                        cp "$src_file" "$dest_file"
                        debug "  $rel_path updated"
                        ((dir_updated++)) || true
                        ;;
                    *)
                        warning "  $rel_path skipped"
                        ((dir_skipped++)) || true
                        ;;
                esac
            fi
        else
            # New file
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} Add: $rel_path"
            else
                cp "$src_file" "$dest_file"
            fi
            debug "  $rel_path added (new)"
            ((dir_added++)) || true
        fi
    done < <(eval "find \"$src_dir\" $find_pattern 2>/dev/null" || true)

    # Ensure hook scripts are executable after copy
    if [[ "$name" == "hook_scripts" ]] && ! $DRY_RUN; then
        find "$dest_dir" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
    fi

    # Copy non-md files for skills (SKILL.md subdirs may have examples/, etc.)
    if [[ "$name" == "skills" ]]; then
        while IFS= read -r src_file; do
            local rel_path="${src_file#"$src_dir"/}"
            local dest_file="$dest_dir/$rel_path"
            local file_dest_dir
            file_dest_dir=$(dirname "$dest_file")
            if [[ ! -d "$file_dest_dir" ]] && ! $DRY_RUN; then
                mkdir -p "$file_dest_dir"
            fi
            if [[ ! -f "$dest_file" ]] || $FORCE_UPDATE; then
                if ! $DRY_RUN; then
                    cp "$src_file" "$dest_file"
                fi
            fi
        done < <(find "$src_dir" -type f ! -name "*.md" 2>/dev/null || true)
    fi

    success "$label: $dir_added added, $dir_updated updated, $dir_identical identical, $dir_skipped skipped"
}


# =============================================================================
# CLAUDE.md upgrade
# =============================================================================

# Escape a string for safe use in awk comparisons
# Uses grep+sed instead of awk -v to avoid awk injection
_remove_section_from_file() {
    local file="$1"
    local section_title="$2"
    local tmp_cleaned
    tmp_cleaned=$(safe_mktemp)

    # Use grep -n to find the section start line, then sed to remove the block
    local start_line
    start_line=$(grep -nF "$section_title" "$file" | head -1 | cut -d: -f1)

    if [[ -z "$start_line" ]]; then
        # Section not found, copy as-is
        cp "$file" "$tmp_cleaned"
        echo "$tmp_cleaned"
        return
    fi

    # Find the next ## heading after start_line
    local end_line
    end_line=$(tail -n +"$((start_line + 1))" "$file" | grep -n "^## " | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        # end_line is relative to start_line+1, convert to absolute
        end_line=$((start_line + end_line))
        # Keep lines before section and from next section onward
        head -n "$((start_line - 1))" "$file" > "$tmp_cleaned"
        tail -n +"$end_line" "$file" >> "$tmp_cleaned"
    else
        # No next section: remove from start_line to end of file
        head -n "$((start_line - 1))" "$file" > "$tmp_cleaned"
    fi

    echo "$tmp_cleaned"
}

# Migrates a legacy install (docs/reference/, @docs/reference/) to the
# .claude/docs/ layout introduced in v1.30. Idempotent: no-op if nothing to migrate.
# Preserves user-customized guides.
# Arguments: none (uses $TARGET_DIR)
migrate_legacy_docs() {
    local claude_md="$TARGET_DIR/CLAUDE.md"

    local has_legacy_dir=false
    local has_legacy_imports=false

    [[ -d "$TARGET_DIR/docs/reference" ]] && has_legacy_dir=true
    if [[ -f "$claude_md" ]] && grep -qE '^@docs/reference/' "$claude_md" 2>/dev/null; then
        has_legacy_imports=true
    fi

    if ! $has_legacy_dir && ! $has_legacy_imports; then
        return 0
    fi

    info "Legacy migration detected: docs/ → .claude/docs/"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Migrate docs/reference/ → .claude/docs/reference/"
        echo -e "${DIM}[DRY-RUN]${NC} Migrate docs/guides/ → .claude/docs/guides/ (if present)"
        echo -e "${DIM}[DRY-RUN]${NC} Rewrite @docs/reference/ → @.claude/docs/reference/ in CLAUDE.md"
        return 0
    fi

    if [[ -d "$TARGET_DIR/docs/reference" ]]; then
        make_dir "$TARGET_DIR/.claude/docs/reference"
        cp -r "$TARGET_DIR/docs/reference/"* "$TARGET_DIR/.claude/docs/reference/" 2>/dev/null || true
        rm -rf "$TARGET_DIR/docs/reference"
        success "Migrated: docs/reference/ → .claude/docs/reference/"
    fi

    if [[ -d "$TARGET_DIR/docs/guides" ]]; then
        make_dir "$TARGET_DIR/.claude/docs/guides"
        cp -r "$TARGET_DIR/docs/guides/"* "$TARGET_DIR/.claude/docs/guides/" 2>/dev/null || true
        rm -rf "$TARGET_DIR/docs/guides"
        success "Migrated: docs/guides/ → .claude/docs/guides/"
    fi

    if [[ -f "$claude_md" ]] && $has_legacy_imports; then
        local backup_file
        backup_file="${claude_md}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$claude_md" "$backup_file"
        rewrite_claude_md_paths "$claude_md"
        success "Rewrote @docs/reference/ → @.claude/docs/reference/ in CLAUDE.md"
    fi

    for f in "docs/ARCHITECTURE.md" "docs/WORKFLOWS.md"; do
        if [[ -f "$TARGET_DIR/$f" ]]; then
            warning "$f exists (from a previous foundation install or your project) — not managed by the foundation, keep or remove manually."
        fi
    done

    # Clean up the docs/ folder if it is now empty
    if [[ -d "$TARGET_DIR/docs" ]] && [[ -z "$(ls -A "$TARGET_DIR/docs" 2>/dev/null)" ]]; then
        rmdir "$TARGET_DIR/docs"
    fi
}

upgrade_claude_md() {
    section "Migrating CLAUDE.md to @imports"

    local claude_md="$TARGET_DIR/CLAUDE.md"

    # Verify CLAUDE.md exists
    if [[ ! -f "$claude_md" ]]; then
        warning "CLAUDE.md not found in $TARGET_DIR"
        return
    fi

    # Backup BEFORE any modification (migrate_legacy_docs may rewrite CLAUDE.md)
    # We only remove it at the end of the function if final CLAUDE.md == backup.
    local backup_file=""
    if ! $DRY_RUN; then
        backup_file="${claude_md}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$claude_md" "$backup_file"
    fi

    # Legacy migration if needed (moves docs/* → .claude/docs/*)
    migrate_legacy_docs

    # Copy docs/reference/ from the foundation to .claude/docs/reference/ (always, to update)
    local src_ref="$SOCLE_DIR/docs/reference"
    local dest_ref="$TARGET_DIR/.claude/docs/reference"

    if [[ ! -d "$src_ref" ]]; then
        warning "docs/reference/ not found in the foundation"
        return
    fi

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Copy docs/reference/ → .claude/docs/reference/"
        echo -e "${DIM}[DRY-RUN]${NC} Copy docs/guides/ → .claude/docs/guides/"
        echo -e "${DIM}[DRY-RUN]${NC} Check missing @imports"
        echo -e "${DIM}[DRY-RUN]${NC} Backup CLAUDE.md if modifications"
        return
    fi

    make_dir "$dest_ref"
    cp -r "$src_ref/"* "$dest_ref/"
    local ref_count
    ref_count=$(find "$dest_ref" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    success ".claude/docs/reference/ copied ($ref_count files)"

    # Copy docs/guides/ to .claude/docs/guides/ — only new files
    # Existing guides are preserved (potentially customized)
    if [[ -d "$SOCLE_DIR/docs/guides" ]]; then
        make_dir "$TARGET_DIR/.claude/docs/guides"
        local guides_added=0
        local guides_skipped=0
        while IFS= read -r guide_file; do
            local guide_rel="${guide_file#"$SOCLE_DIR"/docs/guides/}"
            local guide_dest="$TARGET_DIR/.claude/docs/guides/$guide_rel"
            if [[ -f "$guide_dest" ]]; then
                debug "Preserved (existing): .claude/docs/guides/$guide_rel"
                ((guides_skipped++)) || true
            else
                local guide_dest_dir
                guide_dest_dir=$(dirname "$guide_dest")
                [[ -d "$guide_dest_dir" ]] || mkdir -p "$guide_dest_dir"
                cp "$guide_file" "$guide_dest"
                debug "Added: .claude/docs/guides/$guide_rel"
                ((guides_added++)) || true
            fi
        done < <(find "$SOCLE_DIR/docs/guides" -name "*.md" -type f 2>/dev/null || true)
        if [[ $guides_added -gt 0 ]]; then
            success ".claude/docs/guides/: $guides_added added, $guides_skipped preserved"
        else
            info ".claude/docs/guides/: $guides_skipped existing file(s) preserved"
        fi
    fi

    # Copy docs/STACK-RECIPES.md (consolidation of legacy stack guides)
    if [[ -f "$SOCLE_DIR/docs/STACK-RECIPES.md" ]]; then
        cp "$SOCLE_DIR/docs/STACK-RECIPES.md" "$TARGET_DIR/.claude/docs/STACK-RECIPES.md"
        debug "STACK-RECIPES.md synced to .claude/docs/"
    fi

    # Count @imports before to report what was added
    # (grep -c returns 1 if 0 matches, hence the `|| true` for set -e)
    local imports_before
    imports_before=$(grep -cE "^@\.claude/docs/reference/" "$claude_md" 2>/dev/null || true)
    imports_before=${imports_before:-0}

    # Guarantee the 7 canonical @imports (factored in lib/common.sh)
    ensure_claude_md_imports "$claude_md"

    local imports_after
    imports_after=$(grep -cE "^@\.claude/docs/reference/" "$claude_md" 2>/dev/null || true)
    imports_after=${imports_after:-0}
    local added=$((imports_after - imports_before))

    if [[ $added -gt 0 ]]; then
        success "Added $added missing @import(s) in CLAUDE.md"
    fi

    # Check if CLAUDE.md was modified (by migrate_legacy_docs or ensure_imports).
    # If identical to backup, remove the backup (nothing to save).
    if [[ -n "$backup_file" ]] && [[ -f "$backup_file" ]]; then
        if cmp -s "$claude_md" "$backup_file"; then
            rm -f "$backup_file"
            success "CLAUDE.md already contains the 7 canonical @imports"
        else
            success "Backup created: $(basename "$backup_file")"
        fi
    fi

    # Detect and offer to remove duplicate sections
    local -a duplicate_sections=(
        "## Commandes Essentielles"
        "## Structure Recommandée"
        "## Structure Clean Architecture"
        "## Agents Recommandés"
    )

    local found_duplicates=false
    for section_title in "${duplicate_sections[@]}"; do
        if grep -qF "$section_title" "$claude_md" 2>/dev/null; then
            found_duplicates=true

            if $FORCE_UPDATE || ${NON_INTERACTIVE:-false}; then
                # Automatically remove the section
                local cleaned_file
                cleaned_file=$(_remove_section_from_file "$claude_md" "$section_title")
                cp "$cleaned_file" "$claude_md"
                success "Section removed: $section_title"
            else
                warning "Duplicate section detected: $section_title"
                if confirm "Remove this section (replaced by @imports)?" "y"; then
                    local cleaned_file
                    cleaned_file=$(_remove_section_from_file "$claude_md" "$section_title")
                    cp "$cleaned_file" "$claude_md"
                    success "Section removed: $section_title"
                else
                    info "Section preserved: $section_title"
                fi
            fi
        fi
    done

    if ! $found_duplicates; then
        info "No duplicate section detected"
    fi
}

# =============================================================================
# Orphan detection
# =============================================================================

detect_orphan_files() {
    local subdir="$1"
    local target_dir="$TARGET_DIR/.claude/$subdir"
    local socle_dir="$SOCLE_DIR/.claude/$subdir"

    if [[ ! -d "$target_dir" ]]; then
        return
    fi

    # Find files in the target (md, tf, yaml, yml, json)
    while IFS= read -r target_file; do
        if [[ -f "$target_file" ]]; then
            # Compute the relative path
            local rel_path="${target_file#"$target_dir"/}"
            local socle_file="$socle_dir/$rel_path"

            # Check if the file exists in the foundation (also check for renames by basename)
            if [[ ! -f "$socle_file" ]]; then
                ((ORPHANS_FOUND++)) || true
                local filename
                filename=$(basename "$target_file")

                # Check if the file might have been renamed (same basename exists elsewhere in socle)
                local possible_rename=""
                if [[ -d "$socle_dir" ]]; then
                    possible_rename=$(find "$socle_dir" -name "$filename" -type f 2>/dev/null | head -1 || true)
                fi

                if [[ -n "$possible_rename" ]]; then
                    local socle_rel="${possible_rename#"$socle_dir"/}"
                    info "  $filename may have been moved to $socle_rel in the foundation"
                fi

                if $REMOVE_ORPHANS; then
                    if $DRY_RUN; then
                        echo -e "${DIM}[DRY-RUN]${NC} Remove orphan: $subdir/$rel_path"
                    else
                        rm -f "$target_file"
                        ((ORPHANS_REMOVED++)) || true
                    fi
                    warning "  $filename removed (orphan)"
                elif ${NON_INTERACTIVE:-false}; then
                    warning "  $filename is an orphan (absent from the foundation)"
                else
                    echo ""
                    prompt "$filename is absent from the foundation. What to do?"
                    echo "  [d] Delete  [k] Keep"
                    read -r -n 1 choice
                    echo

                    case "$choice" in
                        d|D)
                            if ! $DRY_RUN; then
                                rm -f "$target_file"
                                ((ORPHANS_REMOVED++)) || true
                            fi
                            warning "  $filename removed"
                            ;;
                        *)
                            info "  $filename kept"
                            ;;
                    esac
                fi
            fi
        fi
    done < <(find "$target_dir" -type f \( -name "*.md" -o -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) 2>/dev/null || true)

    # Clean up empty directories (including non-empty orphan dirs with only orphan files already removed)
    if $REMOVE_ORPHANS && ! $DRY_RUN; then
        find "$target_dir" -type d -empty -delete 2>/dev/null || true
    fi
}

detect_all_orphans() {
    section "Detecting orphan files"

    local dirs_to_check=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_check[@]}"; do
        if [[ -d "$TARGET_DIR/.claude/$subdir" ]]; then
            debug "Checking .claude/$subdir"
            detect_orphan_files "$subdir"
        fi
    done

    if [[ $ORPHANS_FOUND -eq 0 ]]; then
        success "No orphan file detected"
    else
        if $REMOVE_ORPHANS; then
            success "$ORPHANS_REMOVED/$ORPHANS_FOUND orphan file(s) removed"
        else
            warning "$ORPHANS_FOUND orphan file(s) detected"
            info "Use --remove-orphans to remove them"
        fi
    fi
}

print_summary() {
    echo ""
    separator "="
    success "Update completed!"
    separator "="
    echo ""

    info "Summary:"
    if $CLEAN_BEFORE_UPDATE; then
        echo "  Synced:     $ADDED  (re-copied from the foundation after --clean)"
    else
        echo "  Added:      $ADDED"
    fi
    echo "  Updated:    $UPDATED"
    echo "  Skipped:    $SKIPPED"
    if $DETECT_ORPHANS; then
        echo "  Orphans:    $ORPHANS_FOUND (${ORPHANS_REMOVED} removed)"
    fi
    echo ""

    if [[ -n "${BACKUP_DIR:-}" ]] && [[ -d "${BACKUP_DIR:-}" ]]; then
        info "Backup available: $BACKUP_DIR"
        echo ""
    fi
}

# =============================================================================
# Main — data-driven optional updates
# =============================================================================

main() {
    parse_args "$@"

    # Checks
    if [[ ! -d "$TARGET_DIR/.claude" ]]; then
        error "No Claude configuration found in '$TARGET_DIR'. Use install.sh first."
    fi

    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    # Handle --restore
    if [[ -n "$RESTORE_BACKUP" ]]; then
        restore_backup "$RESTORE_BACKUP"
        exit 0
    fi

    # Handle --add-hook
    if [[ -n "$ADD_HOOK" ]]; then
        add_hook "$ADD_HOOK"
        exit 0
    fi

    title "Claude Code Update"
    info "Project: $TARGET_DIR"
    $DRY_RUN && warning "Dry-run mode enabled"
    echo ""

    # Create the backup
    BACKUP_DIR=$(create_backup)

    # Backup-only mode
    if $BACKUP_ONLY; then
        success "Backup created successfully"
        exit 0
    fi

    # Clean up old files if requested
    if $CLEAN_BEFORE_UPDATE; then
        clean_claude_dirs "$TARGET_DIR"
    fi

    # Update commands
    update_commands

    # Add CLAUDE.md if absent
    if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} Add: CLAUDE.md"
        else
            cp "$SOCLE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
            rewrite_claude_md_paths "$TARGET_DIR/CLAUDE.md"
        fi
        success "CLAUDE.md added (absent from the project)"
    fi

    # Data-driven optional updates
    # Format: flag_name|type|confirm_message|args...
    # type=settings: calls update_settings
    # type=dir: calls update_directory with remaining args (name|subdir|label)
    # type=claude_md: calls upgrade_claude_md
    local -a update_entries=(
        "UPDATE_SETTINGS|settings|Update .claude/settings.json?"
        "UPDATE_SKILLS|dir|Update .claude/skills/?|skills|$SKILLS_SUBDIR|Skills"
        "UPDATE_AGENTS|dir|Update .claude/agents/?|agents|$AGENTS_SUBDIR|Agents"
        "UPDATE_RULES|dir|Update .claude/rules/?|rules|$RULES_SUBDIR|Rules"
        "UPDATE_STYLES|dir|Update .claude/output-styles/?|styles|$STYLES_SUBDIR|Output-styles"
        "UPDATE_TEMPLATES|dir|Update .claude/templates/?|templates|$TEMPLATES_SUBDIR|Templates"
        "UPDATE_HOOK_SCRIPTS|dir|Update scripts/hooks/?|hook_scripts|$HOOK_SCRIPTS_SUBDIR|Hook Scripts"
        "UPGRADE_CLAUDE_MD|claude_md|Migrate CLAUDE.md to @imports (docs/reference/)?"
    )

    for entry in "${update_entries[@]}"; do
        IFS='|' read -r flag_name entry_type confirm_msg arg1 arg2 arg3 <<< "$entry"
        local flag_value="${!flag_name}"
        local should_run=false

        if [[ "$flag_value" == "true" ]]; then
            should_run=true
        elif ! ${NON_INTERACTIVE:-false} && ! $FORCE_UPDATE; then
            echo ""
            if confirm "$confirm_msg" "n"; then
                should_run=true
            fi
        fi

        if $should_run; then
            case "$entry_type" in
                settings)  update_settings ;;
                dir)       update_directory "$arg1" "$arg2" "$arg3" ;;
                claude_md) upgrade_claude_md ;;
            esac
        fi
    done

    # Detect orphan files
    if $DETECT_ORPHANS; then
        detect_all_orphans
    fi

    # Summary
    print_summary
}

main "$@"
