#!/bin/bash

# =============================================================================
# Claude-Socle Common Library
# Functions shared between all scripts
# =============================================================================

# Version read from the centralized VERSION file
_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_SOCLE_ROOT="$(dirname "$(dirname "$_COMMON_SCRIPT_DIR")")"
# shellcheck disable=SC2034  # Exported for use by other scripts
COMMON_LIB_VERSION=$(cat "$_SOCLE_ROOT/VERSION" 2>/dev/null || echo "1.0.0")
unset _COMMON_SCRIPT_DIR _SOCLE_ROOT

# =============================================================================
# Colors and styles (ANSI-C quoting notation for compatibility)
# =============================================================================

# Disable colors if no terminal or if NO_COLOR is set
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    # shellcheck disable=SC2034  # Available for use by scripts
    MAGENTA=$'\033[0;35m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    NC=$'\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    # shellcheck disable=SC2034  # Available for use by scripts
    MAGENTA=''
    BOLD=''
    DIM=''
    NC=''
fi

# =============================================================================
# Global variables
# =============================================================================

VERBOSE=${VERBOSE:-false}   # Verbose mode
QUIET=${QUIET:-false}       # Silent mode
DRY_RUN=${DRY_RUN:-false}   # Simulation mode

# =============================================================================
# Logging functions
# =============================================================================

# Displays an information message
# Arguments:
#   $1 - Message to display
# Output: Nothing if QUIET=true
info() {
    if ! $QUIET; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

# Displays a success message
# Arguments:
#   $1 - Message to display
# Output: Nothing if QUIET=true
success() {
    if ! $QUIET; then
        echo -e "${GREEN}[OK]${NC} $1"
    fi
}

# Displays a warning (always to stderr)
# Arguments:
#   $1 - Message to display
warning() {
    echo -e "${YELLOW}[!]${NC} $1" >&2
}

# Displays an error and terminates the script
# Arguments:
#   $1 - Error message
# Exit code: 1
error() {
    echo -e "${RED}[X]${NC} $1" >&2
    exit 1
}

# Displays an error without terminating the script
# Arguments:
#   $1 - Error message
error_no_exit() {
    echo -e "${RED}[X]${NC} $1" >&2
}

# Displays a debug message (only if VERBOSE=true)
# Arguments:
#   $1 - Message to display
debug() {
    if $VERBOSE; then
        echo -e "${DIM}[DEBUG]${NC} $1"
    fi
    return 0
}

# Displays a command prompt
# Arguments:
#   $1 - Message to display
prompt() {
    echo -e "${CYAN}[?]${NC} $1"
}

# Displays an automatic detection message
# Arguments:
#   $1 - Message to display
detected() {
    if ! $QUIET; then
        echo -e "${GREEN}[AUTO]${NC} $1"
    fi
}

# =============================================================================
# Utility functions
# =============================================================================

# Checks if a command exists in PATH
# Arguments:
#   $1 - Command name
# Return: 0 if exists, 1 otherwise
command_exists() {
    command -v "$1" &> /dev/null
}

# Checks required dependencies and fails if missing
# Arguments:
#   $@ - List of required commands
# Exit code: 1 if dependencies missing
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}"
    fi
}

# Checks optional dependencies (warning only)
# Arguments:
#   $@ - List of optional commands
# Return: 0 if all present, 1 otherwise
check_optional_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Missing optional dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

# Checks the foundation's base requirements (bash 4+, git)
# Called automatically or manually at startup
# Exit code: 1 if requirements not met
check_base_requirements() {
    # Check Bash version (4.0 minimum for associative arrays)
    local bash_version="${BASH_VERSION%%.*}"
    if [[ "$bash_version" -lt 4 ]]; then
        error "Bash 4.0+ required (current version: $BASH_VERSION)"
    fi

    # Check that git is installed
    if ! command_exists git; then
        error "git is required but is not installed"
    fi

    debug "Base requirements OK (bash $BASH_VERSION, git $(git --version | cut -d' ' -f3))"
}

# Returns the foundation path from the calling script
# Return: Absolute path of the foundation directory
get_socle_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    echo "$(dirname "$script_dir")"
}

# Converts a relative path to an absolute path
# Arguments:
#   $1 - Path to convert
# Return: Absolute path
get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Counts files matching a pattern
# Arguments:
#   $1 - Directory to scan
#   $2 - Glob pattern (default: *)
# Return: Number of files
count_files() {
    local dir="$1"
    local pattern="${2:-*}"
    find "$dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Counts subdirectories
# Arguments:
#   $1 - Directory to scan
# Return: Number of directories
count_dirs() {
    local dir="$1"
    find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
}

# Asks the user for confirmation
# Arguments:
#   $1 - Confirmation message (default: "Continue?")
#   $2 - Default answer: "y" or "n" (default: "n")
# Return: 0 if yes, 1 if no
confirm() {
    local message="${1:-Continue?}"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt "$message (Y/n)"
    else
        prompt "$message (y/N)"
    fi

    read -r -n 1 reply
    echo

    if [[ -z "$reply" ]]; then
        reply="$default"
    fi

    [[ "$reply" =~ ^[Yy]$ ]]
}

# =============================================================================
# Execution functions (respect DRY_RUN)
# =============================================================================

# Executes a command (simulation if DRY_RUN=true)
# Arguments:
#   $@ - Command and arguments
# Return: Exit code of the command
run_cmd() {
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} $*"
        return 0
    fi

    $VERBOSE && debug "Execution: $*"
    "$@"
}

# Copies a file (simulation if DRY_RUN=true)
# Arguments:
#   $1 - Source file
#   $2 - Destination
copy_file() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp $src -> $dest"
        return 0
    fi

    cp "$src" "$dest"
}

# Copies a directory (simulation if DRY_RUN=true)
# Arguments:
#   $1 - Source directory
#   $2 - Destination
copy_dir() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $src -> $dest"
        return 0
    fi

    cp -r "$src" "$dest"
}

# Creates a directory (simulation if DRY_RUN=true)
# Arguments:
#   $1 - Directory path
make_dir() {
    local dir="$1"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} mkdir -p $dir"
        return 0
    fi

    mkdir -p "$dir"
}

# =============================================================================
# JSON validation functions
# =============================================================================

# Validates the syntax of a JSON file
# Arguments:
#   $1 - JSON file path
# Return: 0 if valid, 1 otherwise
validate_json() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    if command_exists jq; then
        if jq empty "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    elif command_exists python3; then
        # Use stdin to avoid command injection via filename
        if python3 -c "import json, sys; json.load(sys.stdin)" < "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    elif command_exists node; then
        # Use stdin to avoid command injection via filename
        if node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{JSON.parse(d)}catch(e){process.exit(1)}})" < "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        # No validator available, considered valid
        return 0
    fi
}

# Extracts a value from a JSON file
# Arguments:
#   $1 - JSON file path
#   $2 - jq key (e.g., ".version" or ".hooks.PreToolUse")
# Return: Extracted value or empty string
json_get() {
    local file="$1"
    local key="$2"

    if command_exists jq; then
        jq -r "$key" "$file" 2>/dev/null
    elif command_exists python3; then
        # Use stdin to avoid command injection via filename
        # Convert jq-style key to Python dict access (e.g., ".version" -> "['version']")
        local py_key
        py_key=$(echo "$key" | sed 's/^\.//' | sed "s/\.\([^.]*\)/['\1']/g" | sed "s/^\([^[]*\)/['\1']/")
        python3 -c "import json, sys; data=json.load(sys.stdin); print(data$py_key)" < "$file" 2>/dev/null
    else
        echo ""
    fi
}

# =============================================================================
# Input validation functions
# =============================================================================

# Removes control characters and trims whitespace
# Arguments:
#   $1 - String to clean
# Return: Cleaned string (stdout)
sanitize_input() {
    local input="${1:-}"
    # Remove control characters (except newline/tab) and trim whitespace
    printf '%s' "$input" | tr -d '\000-\010\013\014\016-\037' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Validates an input against an ERE regex pattern
# Arguments:
#   $1 - String to validate
#   $2 - ERE regex pattern (e.g., '^[a-zA-Z0-9_-]+$')
#   $3 - Field name (for error message, optional)
# Return: 0 if valid, 1 otherwise (error message on stderr)
validate_input() {
    local input="${1:-}"
    local pattern="${2:-}"
    local field_name="${3:-input}"

    if [[ -z "$input" ]]; then
        echo "Error: ${field_name} is empty" >&2
        return 1
    fi

    if [[ -z "$pattern" ]]; then
        echo "Error: validation pattern is empty" >&2
        return 1
    fi

    if ! echo "$input" | grep -qE "$pattern"; then
        echo "Error: ${field_name} does not match expected format" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# Versioning functions
# =============================================================================

# Returns the foundation version
# Arguments:
#   $1 - Foundation path (optional)
# Return: Version or "unknown"
get_socle_version() {
    local socle_dir="${1:-$(get_socle_dir)}"
    local version_file="$socle_dir/VERSION"

    if [[ -f "$version_file" ]]; then
        cat "$version_file"
    else
        echo "unknown"
    fi
}

# Compares two semantic versions
# Arguments:
#   $1 - Version 1
#   $2 - Version 2
# Return: 0 if v1 >= v2, 1 otherwise
version_gte() {
    local v1="$1"
    local v2="$2"

    [[ "$(printf '%s\n' "$v2" "$v1" | sort -V | head -n1)" == "$v2" ]]
}

# =============================================================================
# Display functions
# =============================================================================

# Displays a separator line
# Arguments:
#   $1 - Character (default: =)
#   $2 - Width (default: 60)
separator() {
    local char="${1:-=}"
    local width="${2:-60}"
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

# Displays a framed title
# Arguments:
#   $1 - Title text
title() {
    local text="$1"
    echo ""
    separator "="
    echo -e "  ${BOLD}$text${NC}"
    separator "="
    echo ""
}

# Displays a section header
# Arguments:
#   $1 - Section text
section() {
    local text="$1"
    echo ""
    echo -e "${BOLD}$text${NC}"
    separator "-" 40
}

# =============================================================================
# Foundation statistics
# =============================================================================

# Counts the number of agents (.md files in commands/ and subdirectories)
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of agents
count_agents() {
    local socle_dir="${1:-$(get_socle_dir)}"
    find "$socle_dir/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Counts the number of skills (directories in skills/)
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of skills
count_skills() {
    local socle_dir="${1:-$(get_socle_dir)}"
    count_dirs "$socle_dir/.claude/skills"
}

# Counts the number of configured hooks
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of hooks (Pre + Post)
count_hooks() {
    local socle_dir="${1:-$(get_socle_dir)}"
    local settings_file="$socle_dir/.claude/settings.json"

    if [[ -f "$settings_file" ]] && command_exists jq; then
        local pre post
        pre=$(jq '.hooks.PreToolUse // [] | length' "$settings_file" 2>/dev/null || echo 0)
        post=$(jq '.hooks.PostToolUse // [] | length' "$settings_file" 2>/dev/null || echo 0)
        echo $((pre + post))
    else
        echo "0"
    fi
}

# Counts the number of CLAUDE.*.md templates
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of templates
count_templates() {
    local socle_dir="${1:-$(get_socle_dir)}"
    count_files "$socle_dir/templates" "CLAUDE.*.md"
}

# Displays foundation statistics
# Arguments:
#   $1 - Foundation path (optional)
show_socle_stats() {
    local socle_dir="${1:-$(get_socle_dir)}"

    local agents skills hooks templates
    agents=$(count_agents "$socle_dir")
    skills=$(count_skills "$socle_dir")
    hooks=$(count_hooks "$socle_dir")
    templates=$(count_templates "$socle_dir")

    echo "  Agents:    $agents"
    echo "  Skills:    $skills"
    echo "  Hooks:     $hooks"
    echo "  Templates: $templates"
}

# =============================================================================
# Persistent cache (~/.cache/claude-socle/)
# =============================================================================

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-socle"
CACHE_DEFAULT_TTL=86400  # 24h

# Initializes the cache directory
cache_init() {
    mkdir -p "$CACHE_DIR" 2>/dev/null || true
}

# Checks if a cache entry is still valid
# Arguments: $1=key, $2=ttl in seconds (default: 86400)
# Returns: 0 if valid, 1 otherwise
cache_valid() {
    local key="$1"
    local ttl="${2:-$CACHE_DEFAULT_TTL}"
    local file="$CACHE_DIR/${key}.json"

    [[ -f "$file" ]] || return 1

    local timestamp
    timestamp=$(json_get "$file" ".timestamp" 2>/dev/null) || return 1
    [[ -z "$timestamp" ]] && return 1

    local now
    now=$(date +%s)
    (( now - timestamp < ttl ))
}

# Reads a value from the cache
# Arguments: $1=key
# Returns: content of the .data field (stdout), 1 if absent
cache_read() {
    local key="$1"
    local file="$CACHE_DIR/${key}.json"

    [[ -f "$file" ]] || return 1
    json_get "$file" ".data" 2>/dev/null
}

# Writes a value to the cache
# Arguments: $1=key, $2=data (string)
cache_write() {
    local key="$1"
    local data="$2"
    local now
    now=$(date +%s)

    cache_init

    cat > "$CACHE_DIR/${key}.json" << CACHEEOF
{"data": "$data", "timestamp": $now}
CACHEEOF
}

# =============================================================================
# Cleanup of Claude directories
# =============================================================================

# Removes Claude subdirectories for clean reinstallation
# Arguments: $1=project directory
clean_claude_dirs() {
    local dir="$1"

    info "Cleaning up old Claude files..."

    local dirs_to_clean=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir/.claude/$subdir" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} rm -rf $dir/.claude/$subdir"
            else
                rm -rf "$dir/.claude/$subdir"
            fi
            debug "Removed: .claude/$subdir"
        fi
    done

    success "Old files cleaned up"
}

# Rewrites docs/ paths to .claude/docs/ in a user project's CLAUDE.md.
# Idempotent: applying multiple times does not break the result.
# Also removes table lines pointing to docs/ARCHITECTURE.md or docs/WORKFLOWS.md
# (these files are no longer copied to user projects since v1.30).
# Arguments:
#   $1 - Path of the CLAUDE.md to rewrite
rewrite_claude_md_paths() {
    local claude_md="$1"

    [[ -f "$claude_md" ]] || return 0

    # `-i.bak` works on both GNU sed (Linux) and BSD sed (macOS).
    # Cleanup the .bak file after the successful in-place edit.
    sed -i.bak \
        -e 's|^@docs/reference/|@.claude/docs/reference/|g' \
        -e 's|`docs/reference/|`.claude/docs/reference/|g' \
        -e 's|`docs/guides/|`.claude/docs/guides/|g' \
        -e 's|`docs/STACK-RECIPES\.md`|`.claude/docs/STACK-RECIPES.md`|g' \
        -e '/| Architecture |.*`docs\/ARCHITECTURE\.md`/d' \
        -e '/| Workflows visuels |.*`docs\/WORKFLOWS\.md`/d' \
        "$claude_md" && rm -f "$claude_md.bak"
}

# Ensures the presence of the 7 canonical @imports in CLAUDE.md.
# Idempotent: only adds missing @imports after the last existing
# @import. Used by new-project.sh and update.sh to avoid
# asymmetry: both scripts produce the same complete CLAUDE.md.
# Arguments:
#   $1 - Path of the CLAUDE.md to check/complete
ensure_claude_md_imports() {
    local claude_md="$1"

    [[ -f "$claude_md" ]] || return 0

    local all_imports=(
        "@.claude/docs/reference/best-practices.md"
        "@.claude/docs/reference/project-structures.md"
        "@.claude/docs/reference/commands.md"
        "@.claude/docs/reference/agents-catalog.md"
        "@.claude/docs/reference/hooks-reference.md"
        "@.claude/docs/reference/skills-catalog.md"
        "@.claude/docs/reference/advanced-features.md"
    )

    local missing_imports=()
    local import
    for import in "${all_imports[@]}"; do
        if ! grep -qF "$import" "$claude_md" 2>/dev/null; then
            missing_imports+=("$import")
        fi
    done

    if [[ ${#missing_imports[@]} -eq 0 ]]; then
        return 0
    fi

    # Find the last existing @import and insert after.
    # `|| true` required for compatibility with `set -euo pipefail`:
    # grep returns 1 if 0 matches, which would crash the calling script.
    local last_import_line
    last_import_line=$(grep -n "^@\.claude/docs/reference/" "$claude_md" 2>/dev/null | tail -1 | cut -d: -f1 || true)

    if [[ -z "$last_import_line" ]]; then
        # No existing @import: insert after the first empty line (after title)
        last_import_line=$(grep -n "^$" "$claude_md" 2>/dev/null | head -1 | cut -d: -f1 || true)
        [[ -z "$last_import_line" ]] && last_import_line=1
    fi

    local tmp_file
    tmp_file=$(mktemp)
    head -n "$last_import_line" "$claude_md" > "$tmp_file"
    for import in "${missing_imports[@]}"; do
        echo "$import" >> "$tmp_file"
    done
    tail -n +"$((last_import_line + 1))" "$claude_md" >> "$tmp_file" 2>/dev/null || true
    mv "$tmp_file" "$claude_md"
}

# =============================================================================
# Error handling
# =============================================================================

# Global error handler (called automatically if enabled)
# Arguments:
#   $1 - Line number
#   $2 - Error code
on_error() {
    local line="$1"
    local code="$2"
    error_no_exit "Error at line $line (code: $code)"
}

# Enables the global error handler
# To call at the start of the main script if desired
enable_error_handler() {
    trap 'on_error ${LINENO} $?' ERR
}

# =============================================================================
# Function exports for subshells
# =============================================================================

export -f info success warning error error_no_exit debug prompt detected
export -f command_exists check_dependencies check_optional_dependencies check_base_requirements
export -f get_socle_dir get_absolute_path count_files count_dirs confirm
export -f run_cmd copy_file copy_dir make_dir
export -f validate_json json_get
export -f get_socle_version version_gte
export -f separator title section
export -f count_agents count_skills count_hooks count_templates show_socle_stats
export -f on_error enable_error_handler
export -f cache_init cache_valid cache_read cache_write
export -f clean_claude_dirs rewrite_claude_md_paths ensure_claude_md_imports
