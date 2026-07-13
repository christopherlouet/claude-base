#!/usr/bin/env bash

# =============================================================================
# Claude-Base Common Library
# Functions shared between all scripts
# =============================================================================

# Version read from the centralized VERSION file
_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_BASE_ROOT="$(dirname "$(dirname "$_COMMON_SCRIPT_DIR")")"
# shellcheck disable=SC2034  # Exported for use by other scripts
COMMON_LIB_VERSION=$(cat "$_BASE_ROOT/VERSION" 2>/dev/null || echo "1.0.0")

# Foundation modules: bundle registry + project manifest (.claude/foundation.json).
# Required by the versioning functions below (specs/foundation-modules).
# shellcheck source=scripts/lib/modules.sh
source "$_COMMON_SCRIPT_DIR/modules.sh"
# Preset command/agent filtering SSOT (specs/presets-commands-agents-filter):
# domain resolution + drop/keep removal sets + EF-111 floor. Consumed by
# new-project.sh (install), and later update.sh + validate-presets.sh.
# shellcheck source=scripts/lib/catalog-filter.sh
source "$_COMMON_SCRIPT_DIR/catalog-filter.sh"
unset _COMMON_SCRIPT_DIR _BASE_ROOT

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

    # jq is required on every install/update path since the project manifest
    # (.claude/foundation.json) replaced the legacy version marker
    # (specs/foundation-modules EF-204).
    if ! command_exists jq; then
        error "jq is required but is not installed"
    fi

    debug "Base requirements OK (bash $BASH_VERSION, git $(git --version | cut -d' ' -f3))"
}

# Returns the foundation path from the calling script
# Return: Absolute path of the foundation directory
get_base_dir() {
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
    find "$dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' ' || true
}

# Counts subdirectories
# Arguments:
#   $1 - Directory to scan
# Return: Number of directories
count_dirs() {
    local dir="$1"
    find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ' || true
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

# Returns the user-facing CLI name to print in hints / "Use: …" messages.
# When invoked through the unified dispatcher (`bin/claude-base`), the env
# var CLAUDE_BASE_DISPATCHER is set and we surface the dispatcher verb form
# (e.g. "claude-base init") instead of the underlying script name. When
# invoked directly (foundation contributor path), we keep the raw script
# name so the hint stays accurate.
#
# Usage :
#   # Most common : verb derived from $0 basename
#   info "Use: $(cli_usage init) --preset <name> <path>"
#   #   dispatcher  → "Use: claude-base init --preset <name> <path>"
#   #   direct      → "Use: ./scripts/new-project.sh --preset <name> <path>"
#
#   # When the hint suggests a different script than the caller :
#   # (e.g. diff.sh suggests `update`)
#   info "To sync: $(cli_usage update update.sh) --force $TARGET"
#   #   dispatcher  → "To sync: claude-base update --force $TARGET"
#   #   direct      → "To sync: ./scripts/update.sh --force $TARGET"
#
# Arguments :
#   $1 - Dispatcher verb emitted in dispatcher mode (e.g. "init", "update")
#   $2 - (optional) Script filename used in direct mode. Defaults to
#        the caller's $0 basename. Required when the suggested script
#        differs from the caller.
cli_usage() {
    local verb="${1:-}"
    local script="${2:-}"
    if [[ -n "${CLAUDE_BASE_DISPATCHER:-}" ]]; then
        if [[ -n "$verb" ]]; then
            echo "claude-base $verb"
        else
            echo "claude-base"
        fi
    else
        if [[ -n "$script" ]]; then
            echo "./scripts/$script"
        else
            echo "./scripts/$(basename "$0")"
        fi
    fi
}

# Writes stdin content to a file (simulation if DRY_RUN=true).
# Drop-in replacement for `cat > "$path" <<'EOF' ... EOF` that respects
# the DRY_RUN flag. In dry-run mode, the heredoc body is discarded.
# Arguments:
#   $1 - Destination file path
# Reads:
#   stdin
write_file() {
    local dest="$1"

    if $DRY_RUN; then
        # Drain stdin so the heredoc body doesn't leak to the next command
        cat >/dev/null
        echo -e "${DIM}[DRY-RUN]${NC} write $dest"
        return 0
    fi

    cat > "$dest"
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
get_foundation_version() {
    local base_dir="${1:-$(get_base_dir)}"
    local version_file="$base_dir/VERSION"

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

# Records the foundation version into a target project.
# Since specs/foundation-modules: writes .claude/foundation.json (EF-204),
# never the legacy .foundation-version marker (EF-205, direct replacement).
# - Existing manifest: only .version is updated (preset/modules preserved).
# - No manifest yet: created with no preset and modules_default_set
#   (conservative default — matches a full catalog install).
# - A stale legacy marker is removed either way.
# Idempotent: re-running with the same args produces an identical file.
# Arguments:
#   $1 - Target project directory (created with parents if missing)
#   $2 - Version string to write
# Return: 0 on success, 1 on missing arg or write failure
record_foundation_version() {
    local target_dir="$1"
    local version="$2"

    if [[ -z "$target_dir" || -z "$version" ]]; then
        return 1
    fi

    local manifest="$target_dir/.claude/foundation.json"
    if [[ -f "$manifest" ]]; then
        local tmp
        tmp="$(mktemp)" || return 1
        if ! jq --arg version "$version" '.version = $version' "$manifest" > "$tmp"; then
            rm -f "$tmp"
            return 1
        fi
        mv "$tmp" "$manifest" || return 1
    else
        local mods=()
        local m
        while IFS= read -r m; do
            mods+=("$m")
        done < <(modules_default_set)
        # Guard the array expansion: modules_default_set is empty since v3
        # (opt-in default), and "${mods[@]}" on an empty array aborts under
        # `set -u` on bash 3.2 (macOS) — use the empty-safe idiom.
        write_foundation_manifest "$target_dir" "$version" "" ${mods[@]+"${mods[@]}"} || return 1
    fi
    rm -f "$target_dir/.claude/.foundation-version"
    return 0
}

# Deprecated alias (renamed in S2 of specs/foundation-modules): the function
# has written the foundation.json manifest — not the legacy marker — since
# EF-204/EF-205 landed. Kept for downstream sourcers of this lib.
write_foundation_marker() {
    printf 'common: write_foundation_marker is deprecated, use record_foundation_version\n' >&2
    record_foundation_version "$@"
}

# Reads the foundation version from a target project.
# Manifest-first (.claude/foundation.json), legacy .foundation-version
# fallback (pre-modules installs — migration happens in update, not here).
# Pure read: never creates or removes any file.
# Arguments:
#   $1 - Target project directory
# Return: 0 always (caller checks output non-empty if needed)
read_foundation_marker_from_project() {
    local target_dir="$1"
    [[ -z "$target_dir" ]] && return 0

    local manifest="$target_dir/.claude/foundation.json"
    if [[ -f "$manifest" ]]; then
        jq -r '.version // empty' "$manifest" 2>/dev/null
        return 0
    fi

    local marker_file="$target_dir/.claude/.foundation-version"
    [[ -f "$marker_file" ]] || return 0
    head -n 1 "$marker_file"
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

# Counts the number of agents (.md files in .claude/agents/ and subdirectories)
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of agents
count_agents() {
    local base_dir="${1:-$(get_base_dir)}"
    find "$base_dir/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || true
}

# Counts the number of skills (directories in skills/)
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of skills
count_skills() {
    local base_dir="${1:-$(get_base_dir)}"
    count_dirs "$base_dir/.claude/skills"
}

# Counts the number of configured hooks
# Arguments:
#   $1 - Foundation path (optional)
# Return: Number of hooks (Pre + Post)
count_hooks() {
    local base_dir="${1:-$(get_base_dir)}"
    local settings_file="$base_dir/.claude/settings.json"

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
    local base_dir="${1:-$(get_base_dir)}"
    count_files "$base_dir/templates" "CLAUDE.*.md"
}

# Displays foundation statistics
# Arguments:
#   $1 - Foundation path (optional)
show_foundation_stats() {
    local base_dir="${1:-$(get_base_dir)}"

    local agents skills hooks templates
    agents=$(count_agents "$base_dir")
    skills=$(count_skills "$base_dir")
    hooks=$(count_hooks "$base_dir")
    templates=$(count_templates "$base_dir")

    echo "  Agents:    $agents"
    echo "  Skills:    $skills"
    echo "  Hooks:     $hooks"
    echo "  Templates: $templates"
}

# =============================================================================
# Persistent cache (~/.cache/claude-base/)
# =============================================================================

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-base"
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

# The .claude/ subdirectories managed by the foundation: the SINGLE list both
# clean_claude_dirs (what a clean wipes) and backup_claude_dirs (what a backup
# must therefore cover) iterate over. Keeping one list guarantees a clean can
# never wipe a directory the backup missed.
CLAUDE_MANAGED_SUBDIRS=("commands" "skills" "agents" "rules" "output-styles" "templates")

# Backs up every managed .claude/ subdirectory of a project into a single
# timestamped root: <dir>/.claude.backup.<ts>/<subdir>. MUST be called before
# clean_claude_dirs — it covers exactly the directories the clean wipes.
# Contract: stdout carries ONLY the backup root path (empty when there was
# nothing to back up); all diagnostics go to stderr, so callers can capture
# the path with BACKUP_ROOT=$(backup_claude_dirs ...).
# DRY_RUN: prints the would-be path, writes nothing.
# Arguments: $1=project directory
backup_claude_dirs() {
    local dir="$1"
    local backup_root
    backup_root="$dir/.claude.backup.$(date +%Y%m%d_%H%M%S)"

    local subdir found=false
    for subdir in "${CLAUDE_MANAGED_SUBDIRS[@]}"; do
        if [[ -d "$dir/.claude/$subdir" ]]; then
            found=true
            break
        fi
    done
    if ! $found; then
        return 0
    fi

    if ${DRY_RUN:-false}; then
        echo -e "${DIM}[DRY-RUN]${NC} Backup -> $backup_root" >&2
        echo "$backup_root"
        return 0
    fi

    mkdir -p "$backup_root" || return 1
    for subdir in "${CLAUDE_MANAGED_SUBDIRS[@]}"; do
        [[ -d "$dir/.claude/$subdir" ]] || continue
        cp -R "$dir/.claude/$subdir" "$backup_root/$subdir" || return 1
    done
    success "Backup created: $backup_root" >&2
    echo "$backup_root"
}

# Removes Claude subdirectories for clean reinstallation
# Arguments: $1=project directory
clean_claude_dirs() {
    local dir="$1"

    info "Cleaning up old Claude files..."

    local dirs_to_clean=("${CLAUDE_MANAGED_SUBDIRS[@]}")

    for subdir in "${dirs_to_clean[@]}"; do
        local target="$dir/.claude/$subdir"
        [[ -d "$target" ]] || continue

        # Remove the foundation-owned entries but PRESERVE symlinks. Vendor
        # skills (and any user-added wiring) are installed as symlinks into a
        # sibling vendor-skills/ tree; the foundation never ships symlinks, so
        # keeping them is always safe and stops --clean from silently breaking
        # the vendor skill wiring (which a bare `rm -rf` would delete).
        local entry
        for entry in "$target"/* "$target"/.[!.]*; do
            [[ -e "$entry" || -L "$entry" ]] || continue
            if [[ -L "$entry" ]]; then
                debug "Preserved symlink: $entry"
                continue
            fi
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} rm -rf $entry"
            else
                rm -rf "$entry"
            fi
        done
        debug "Cleaned: .claude/$subdir (symlinks preserved)"
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
# Security drift detection (downstream projects, #12)
# =============================================================================

# Returns 0 (true) if a hook script still reads its tool payload from the legacy
# TOOL_* environment contract instead of stdin JSON. Since CLI 2.1.76 (foundation
# PRs #330/#331) hooks receive their input as JSON on stdin (.tool_input.*); a
# stale script reading $TOOL_INPUT/$TOOL_CONTENT/... silently no-ops because the
# env var is never set — so a security hook (command-validator, gitleaks) becomes
# a dead pass-through. We classify a script as modern as soon as it reads stdin
# (jq / cat / /dev/stdin), which avoids false-positiving on modern scripts that
# merely *name* a variable TOOL_NAME after parsing it from stdin.
# Arguments: $1 - path to the hook script
hook_uses_legacy_contract() {
    local file="$1"
    [ -f "$file" ] || return 1
    # Strip comment-only lines so a stray mention in a comment can't flip the
    # classification (a `# jq ...` note must not make a legacy hook look modern).
    local code
    code=$(grep -vE '^[[:space:]]*#' "$file" 2>/dev/null || true)
    # Modern hooks read their JSON payload from stdin. Anchor on real stdin-read
    # idioms — NOT a bare "jq" (which can sit in a comment or a string and does
    # not by itself prove the input came from stdin).
    if printf '%s' "$code" | grep -qE '\$\(cat\b|/dev/stdin|mapfile\b|readarray\b'; then
        return 1
    fi
    # No stdin read, yet pulls the payload from a TOOL_* (or CLAUDE_TOOL_*) env
    # var → legacy contract that will silently no-op.
    if printf '%s' "$code" | grep -qE '\$\{?(CLAUDE_)?TOOL_(INPUT|CONTENT|FILE_PATH|FILE|NAME)\b'; then
        return 0
    fi
    return 1
}

# Scans a downstream project for security configuration that has drifted behind
# the foundation, printing one finding per line to stdout. Detects:
#   - hook scripts still on the legacy TOOL_* env contract (silent no-op)
#   - an mcp__* entry in permissions.allow (invalid: mcp__ wildcards don't belong
#     in allow rules)
# Returns 1 if any drift was found, 0 if the project is clean (or has nothing to
# scan). Read-only; never mutates the target.
# Arguments: $1 - target project directory
detect_security_drift() {
    local target="$1"
    local count=0
    local f

    local hooks_dir="$target/scripts/hooks"
    if [ -d "$hooks_dir" ]; then
        for f in "$hooks_dir"/*.sh; do
            [ -e "$f" ] || continue
            if hook_uses_legacy_contract "$f"; then
                printf 'hook-contract: %s reads tool input from a TOOL_* env var (pre-stdin contract) — it will silently no-op; re-sync with `update --hook-scripts --force`\n' "$(basename "$f")"
                count=$((count + 1))
            fi
        done
    fi

    local settings="$target/.claude/settings.json"
    if [ -f "$settings" ] && command_exists jq; then
        # Only the bare "mcp__*" wildcard is flagged: it grants EVERY tool of
        # EVERY MCP server in one rule (overly broad). Fully-qualified grants
        # like "mcp__github__create_issue" are the normal, valid form and must
        # NOT be flagged.
        local rule
        while IFS= read -r rule; do
            [ -z "$rule" ] && continue
            printf 'mcp-allow: bare "%s" wildcard in permissions.allow grants every MCP tool — scope it to specific mcp__server__tool entries\n' "$rule"
            count=$((count + 1))
        done < <(jq -r '[.permissions.allow[]? | select(. == "mcp__*")] | .[]' "$settings" 2>/dev/null || true)
    fi

    [ "$count" -eq 0 ]
}

# =============================================================================
# Function exports for subshells
# =============================================================================

export -f info success warning error error_no_exit debug prompt detected
export -f command_exists check_dependencies check_optional_dependencies check_base_requirements
export -f get_base_dir get_absolute_path count_files count_dirs confirm
export -f run_cmd copy_file copy_dir make_dir
export -f validate_json json_get
export -f get_foundation_version version_gte
export -f separator title section
export -f count_agents count_skills count_hooks count_templates show_foundation_stats
export -f on_error enable_error_handler
export -f cache_init cache_valid cache_read cache_write
export -f clean_claude_dirs backup_claude_dirs rewrite_claude_md_paths ensure_claude_md_imports
export -f hook_uses_legacy_contract detect_security_drift
