#!/usr/bin/env bash

# =============================================================================
# module.sh — foundation module management (add / remove / list)
#
# Spec: specs/foundation-modules/spec.md — US-2 (add), US-4 (remove), EF-212
# Phase 4 / T019.
#
# USAGE
#   module.sh add    <name> [--target DIR] [--dry-run] [--force] [--non-interactive]
#   module.sh remove <name> [--target DIR] [--dry-run]
#   module.sh list         [--target DIR]
#   module.sh --help | -h
#
# FOUNDATION_ROOT may be overridden (tests point it at the repo under test).
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOUNDATION_ROOT="${FOUNDATION_ROOT:-$(dirname "$SCRIPT_DIR")}"

source "$SCRIPT_DIR/lib/common.sh"

# Override module bundles dir to use our FOUNDATION_ROOT.
export MODULES_BUNDLES_DIR="$FOUNDATION_ROOT/scripts/lib/modules"

# =============================================================================
# Option defaults
# =============================================================================

CMD=""
MODULE_NAME=""
TARGET_DIR="${PWD}"
DRY_RUN=false
FORCE_UPDATE=false
NON_INTERACTIVE=false

# Counters (for summary)
_ADDED=0
_UPDATED=0
_SKIPPED=0
_IDENTICAL=0
_CONFLICTS=()

# =============================================================================
# Help
# =============================================================================

show_help() {
    local prog
    if [[ -n "${CLAUDE_BASE_DISPATCHER:-}" ]]; then
        prog="claude-base"
    else
        prog="$(basename "$0")"
    fi
    cat <<EOF
${BOLD}USAGE${NC}
    $prog add    <module> [OPTIONS] [path]
    $prog remove <module> [OPTIONS] [path]
    $prog modules         [OPTIONS] [path]

    [path] is the project directory (default: \$PWD) — same contract as
    init/update/validate. --target DIR is the equivalent explicit flag.

${BOLD}COMMANDS${NC}
    add     Install a foundation module into the project
    remove  Remove a foundation module from the project
    modules List available modules (and installation status if --target given)

${BOLD}OPTIONS${NC}
    -h, --help            Show this help message
    -n, --dry-run         Simulate — list what would happen, write nothing
    -f, --force           Overwrite user-modified files without prompting
    -y, --yes, --non-interactive
                          Non-interactive: skip prompts, list conflicts instead
    --target DIR          Project directory to operate on (default: \$PWD)

${BOLD}EXAMPLES${NC}
    $prog add legal .
    $prog add biz --dry-run ./my-project
    $prog remove growth --force
    $prog modules .
EOF
}

# =============================================================================
# Arg parsing
# =============================================================================

parse_args() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    case "$1" in
        add|remove|list|modules)
            CMD="$1"
            shift
            ;;
        --help|-h|help)
            show_help
            exit 0
            ;;
        --version|-v|version)
            local ver
            ver=$(cat "$FOUNDATION_ROOT/VERSION" 2>/dev/null || echo "unknown")
            echo "claude-base module v${ver}"
            exit 0
            ;;
        *)
            echo "${RED}[X]${NC} module.sh: unknown command '$1'" >&2
            echo "Run '$(basename "$0") --help' for usage." >&2
            exit 2
            ;;
    esac

    # Module name (first positional after command, for add/remove).
    if [[ "$CMD" == "add" || "$CMD" == "remove" ]]; then
        if [[ $# -gt 0 && "$1" != --* ]]; then
            MODULE_NAME="$1"
            shift
        fi
    fi

    # Remaining options + optional positional target dir (same CLI
    # contract as init/update/validate: 'claude-base add legal .').
    local positional_target=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target)
                shift
                TARGET_DIR="${1:?--target requires a directory}"
                ;;
            --target=*)
                TARGET_DIR="${1#--target=}"
                ;;
            --dry-run|-n)
                DRY_RUN=true
                ;;
            --force|-f)
                FORCE_UPDATE=true
                ;;
            --yes|-y|--non-interactive)
                NON_INTERACTIVE=true
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                echo "${RED}[X]${NC} module.sh: unknown option '$1'" >&2
                exit 2
                ;;
            *)
                if [[ -n "$positional_target" ]]; then
                    echo "${RED}[X]${NC} module.sh: unexpected extra argument '$1' (target already set to '$positional_target')" >&2
                    exit 2
                fi
                positional_target="$1"
                TARGET_DIR="$1"
                ;;
        esac
        shift
    done
}

# =============================================================================
# Guard: the target directory must be a foundation project (has manifest).
# =============================================================================

require_foundation_project() {
    local dir="$1"
    if [[ ! -f "$dir/.claude/foundation.json" ]]; then
        echo "${RED}[X]${NC} '$dir' is not a foundation project (no .claude/foundation.json)." >&2
        if [[ -f "$dir/.claude/.foundation-version" ]]; then
            # Legacy pre-manifest project: the migration path is update,
            # not init (EF-205 — update migrates the marker on first contact).
            echo "Legacy version marker detected — run 'claude-base update' to migrate this project first." >&2
        else
            echo "Run 'claude-base init' first to initialise a project." >&2
        fi
        exit 1
    fi
}

# =============================================================================
# install_bundle_file <src_file> <dest_file> <rel_path>
#
# Applies the same conflict resolution as update.sh update_directory():
#   - Identical → skip silently.
#   - Differs + --force → overwrite (backup in non-interactive mode).
#   - Differs + --non-interactive (no --force) → list as conflict, skip.
#   - Differs + interactive → prompt.
#   - Not present → copy (or dry-run announce).
# =============================================================================

install_bundle_file() {
    local src_file="$1"
    local dest_file="$2"
    local rel_path="$3"

    local dest_parent
    dest_parent="$(dirname "$dest_file")"

    if [[ -f "$dest_file" ]]; then
        # File already present — compare.
        if diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
            debug "$rel_path: identical"
            ((_IDENTICAL++)) || true
            return 0
        fi

        # File differs.
        if $FORCE_UPDATE; then
            if $DRY_RUN; then
                echo "${DIM}[DRY-RUN]${NC} Update: $rel_path"
            else
                # Backup before overwrite when non-interactive (update.sh convention).
                if $NON_INTERACTIVE; then
                    local backup_file
                backup_file="${dest_file}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$dest_file" "$backup_file"
                    success "Backup created: $(basename "$backup_file")"
                fi
                cp "$src_file" "$dest_file"
            fi
            ((_UPDATED++)) || true
        elif $NON_INTERACTIVE; then
            if $DRY_RUN; then
                _CONFLICTS+=("$rel_path")
            else
                warning "  $rel_path: skipped (user-modified — use --force to overwrite)"
                ((_SKIPPED++)) || true
            fi
        else
            echo ""
            prompt "$rel_path has been modified. What to do?"
            echo "  [y] Overwrite  [n] Skip  [d] View diff"
            read -r -n 1 choice
            echo
            case "$choice" in
                y|Y)
                    cp "$src_file" "$dest_file"
                    ((_UPDATED++)) || true
                    ;;
                d|D)
                    echo ""
                    echo "${DIM}--- Local${NC}"
                    echo "${DIM}+++ Foundation${NC}"
                    diff "$dest_file" "$src_file" || true
                    echo ""
                    prompt "Overwrite $rel_path? [y/N]"
                    read -r -n 1 overwrite
                    echo
                    if [[ "$overwrite" == "y" || "$overwrite" == "Y" ]]; then
                        cp "$src_file" "$dest_file"
                        ((_UPDATED++)) || true
                    else
                        warning "  $rel_path: skipped"
                        ((_SKIPPED++)) || true
                    fi
                    ;;
                *)
                    warning "  $rel_path: skipped"
                    ((_SKIPPED++)) || true
                    ;;
            esac
        fi
    else
        # New file.
        if $DRY_RUN; then
            echo "${DIM}[DRY-RUN]${NC} Add: $rel_path"
        else
            mkdir -p "$dest_parent"
            cp "$src_file" "$dest_file"
        fi
        ((_ADDED++)) || true
    fi
}

# =============================================================================
# cmd_add <module> — install the bundle into TARGET_DIR.
# =============================================================================

cmd_add() {
    local module_name="$1"

    # Validate module name.
    if ! module_exists "$module_name"; then
        echo "${RED}[X]${NC} Unknown module: '$module_name'" >&2
        echo "Available modules: $(modules_list | tr '\n' ' ')" >&2
        exit 1
    fi

    require_foundation_project "$TARGET_DIR"

    if $DRY_RUN; then
        info "[DRY-RUN] Would install module '${module_name}' into ${TARGET_DIR}"
    else
        info "Installing module '${module_name}' into ${TARGET_DIR}"
    fi

    # Reset counters for this run.
    _ADDED=0; _UPDATED=0; _SKIPPED=0; _IDENTICAL=0; _CONFLICTS=()

    # Iterate over every bundle path.
    local bundle_path src_file dest_file rel_path
    while IFS= read -r bundle_path; do
        [[ -z "$bundle_path" ]] && continue

        # Directory entry (trailing /) — recursively install all .md (and
        # other) files within it from the foundation root.
        if [[ "$bundle_path" == */ ]]; then
            local dir_path="${bundle_path%/}"
            local src_dir="$FOUNDATION_ROOT/$dir_path"
            if [[ ! -d "$src_dir" ]]; then
                warning "Bundle path not found in foundation: $dir_path/" >&2
                continue
            fi
            while IFS= read -r src_file; do
                [[ -f "$src_file" ]] || continue
                rel_path="${src_file#"$FOUNDATION_ROOT"/}"
                dest_file="$TARGET_DIR/$rel_path"
                install_bundle_file "$src_file" "$dest_file" "$rel_path"
            done < <(find "$src_dir" -type f 2>/dev/null | sort || true)
        else
            # Single file path.
            src_file="$FOUNDATION_ROOT/$bundle_path"
            if [[ ! -f "$src_file" ]]; then
                warning "Bundle file not found in foundation: $bundle_path" >&2
                continue
            fi
            dest_file="$TARGET_DIR/$bundle_path"
            install_bundle_file "$src_file" "$dest_file" "$bundle_path"
        fi
    done < <(module_bundle_paths "$module_name")

    # Record in manifest (idempotent — read current modules, merge, write).
    if ! $DRY_RUN; then
        local version preset current_modules new_modules
        version=$(jq -r '.version // "unknown"' "$TARGET_DIR/.claude/foundation.json" 2>/dev/null || echo "unknown")
        preset=$(manifest_preset "$TARGET_DIR" 2>/dev/null || true)
        # Collect existing modules, excluding this one to avoid duplicates.
        current_modules=()
        while IFS= read -r m; do
            [[ "$m" == "$module_name" ]] && continue
            current_modules+=("$m")
        done < <(manifest_modules "$TARGET_DIR" 2>/dev/null || true)
        new_modules=("${current_modules[@]}" "$module_name")
        write_foundation_manifest "$TARGET_DIR" "$version" "$preset" "${new_modules[@]}"
    fi

    # Surface dry-run conflicts if any.
    if $DRY_RUN && [[ "${#_CONFLICTS[@]}" -gt 0 ]]; then
        echo ""
        warning "Would conflict (user-modified, use --force to overwrite):"
        for c in "${_CONFLICTS[@]}"; do
            echo "  $c" >&2
        done
    fi

    # Summary.
    echo ""
    if $DRY_RUN; then
        info "[DRY-RUN] module '${module_name}': ${_ADDED} to add, ${_UPDATED} to update, ${_IDENTICAL} identical, ${_SKIPPED} to skip"
    else
        success "module '${module_name}': ${_ADDED} added, ${_UPDATED} updated, ${_IDENTICAL} identical, ${_SKIPPED} skipped"
    fi
}

# =============================================================================
# cmd_remove <module> — remove foundation-owned bundle files from TARGET_DIR.
# Note: removal is conservative — user-modified files are preserved with notice.
# =============================================================================

cmd_remove() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "${RED}[X]${NC} Unknown module: '$module_name'" >&2
        echo "Available modules: $(modules_list | tr '\n' ' ')" >&2
        exit 1
    fi

    require_foundation_project "$TARGET_DIR"

    if ! manifest_has_module "$TARGET_DIR" "$module_name" 2>/dev/null; then
        info "Module '$module_name' is not installed in this project. Nothing to do."
        exit 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] Would remove module '${module_name}' from ${TARGET_DIR}"
    else
        info "Removing module '${module_name}' from ${TARGET_DIR}"
    fi

    local removed=0 preserved=0 missing=0

    local bundle_path src_file dest_file
    while IFS= read -r bundle_path; do
        [[ -z "$bundle_path" ]] && continue

        if [[ "$bundle_path" == */ ]]; then
            local dir_path="${bundle_path%/}"
            local src_dir="$FOUNDATION_ROOT/$dir_path"
            while IFS= read -r src_file; do
                [[ -f "$src_file" ]] || continue
                local rel_path="${src_file#"$FOUNDATION_ROOT"/}"
                dest_file="$TARGET_DIR/$rel_path"
                if [[ ! -f "$dest_file" ]]; then
                    ((missing++)) || true
                elif diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
                    # Foundation-owned (identical) — safe to remove.
                    if $DRY_RUN; then
                        echo "${DIM}[DRY-RUN]${NC} Remove: $rel_path"
                    else
                        rm -f "$dest_file"
                        # Drop the parent once emptied — same contract as
                        # the init-time filter (no hollow module dirs).
                        rmdir "$(dirname "$dest_file")" 2>/dev/null || true
                    fi
                    ((removed++)) || true
                else
                    # User-modified — preserve with notice.
                    warning "  $rel_path: preserved (user-modified)"
                    ((preserved++)) || true
                fi
            done < <(find "$src_dir" -type f 2>/dev/null | sort || true)
        else
            src_file="$FOUNDATION_ROOT/$bundle_path"
            dest_file="$TARGET_DIR/$bundle_path"
            if [[ ! -f "$dest_file" ]]; then
                ((missing++)) || true
            elif diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
                if $DRY_RUN; then
                    echo "${DIM}[DRY-RUN]${NC} Remove: $bundle_path"
                else
                    rm -f "$dest_file"
                    # Drop the parent once emptied — same contract as
                    # the init-time filter (no hollow module dirs).
                    rmdir "$(dirname "$dest_file")" 2>/dev/null || true
                fi
                ((removed++)) || true
            else
                warning "  $bundle_path: preserved (user-modified)"
                ((preserved++)) || true
            fi
        fi
    done < <(module_bundle_paths "$module_name")

    # Unrecord from manifest.
    if ! $DRY_RUN; then
        local version preset current_modules
        version=$(jq -r '.version // "unknown"' "$TARGET_DIR/.claude/foundation.json" 2>/dev/null || echo "unknown")
        preset=$(manifest_preset "$TARGET_DIR" 2>/dev/null || true)
        current_modules=()
        while IFS= read -r m; do
            [[ "$m" == "$module_name" ]] && continue
            current_modules+=("$m")
        done < <(manifest_modules "$TARGET_DIR" 2>/dev/null || true)
        write_foundation_manifest "$TARGET_DIR" "$version" "$preset" "${current_modules[@]}"
    fi

    echo ""
    if $DRY_RUN; then
        info "[DRY-RUN] module '${module_name}': ${removed} to remove, ${preserved} preserved (user-modified), ${missing} already absent"
    else
        success "module '${module_name}': ${removed} removed, ${preserved} preserved (user-modified), ${missing} already absent"
        if [[ $preserved -gt 0 ]]; then
            info "Preserved files were user-modified and were not deleted."
        fi
    fi
}

# =============================================================================
# cmd_list — show available modules and installation status.
# =============================================================================

cmd_list() {
    local check_installed=false
    [[ -f "$TARGET_DIR/.claude/foundation.json" ]] && check_installed=true

    echo ""
    echo "${BOLD}Available foundation modules${NC}"
    echo ""

    local m
    while IFS= read -r m; do
        local status_str=""
        if $check_installed; then
            if manifest_has_module "$TARGET_DIR" "$m" 2>/dev/null; then
                status_str=" ${GREEN}[installed]${NC}"
            else
                status_str=" ${DIM}[not installed]${NC}"
            fi
        fi
        # Count bundle entries.
        local count
        count=$(module_bundle_paths "$m" | wc -l | tr -d ' ')
        printf "  %-10s %s items%s\n" "$m" "$count" "$status_str"
    done < <(modules_list)

    echo ""
    if $check_installed; then
        info "Use 'claude-base add <module>' to install a module."
    fi
}

# =============================================================================
# Main
# =============================================================================

parse_args "$@"

case "$CMD" in
    add)
        if [[ -z "$MODULE_NAME" ]]; then
            echo "${RED}[X]${NC} 'add' requires a module name." >&2
            echo "Available modules: $(modules_list | tr '\n' ' ')" >&2
            exit 2
        fi
        cmd_add "$MODULE_NAME"
        ;;
    remove)
        if [[ -z "$MODULE_NAME" ]]; then
            echo "${RED}[X]${NC} 'remove' requires a module name." >&2
            echo "Available modules: $(modules_list | tr '\n' ' ')" >&2
            exit 2
        fi
        cmd_remove "$MODULE_NAME"
        ;;
    list|modules)
        cmd_list
        ;;
    *)
        show_help
        exit 0
        ;;
esac
