#!/usr/bin/env bash

# =============================================================================
# Claude-Base Type Menu Library
# Renders the project-type menu in interactive mode and parses user choice.
# When MATCHED_PRESETS is non-empty, the matching presets are prepended as
# additional menu entries (one per preset) before the standard 11 type
# options. See specs/presets-detection-and-e2e/spec.md US-4.
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

# Standard project types in menu order. Index 0 → option (n_presets + 1).
_MENU_STD_TYPES=(react vue node-api python go rust java fullstack flutter neovim generic)
_MENU_STD_LABELS=(
    "React / Next.js"
    "Vue.js"
    "Node.js API"
    "Python"
    "Go"
    "Rust"
    "Java / Spring Boot"
    "Fullstack (Monorepo)"
    "Flutter / Mobile"
    "Neovim / Lua"
    "Other / Generic"
)

# print_type_menu [default_choice]
#
# Print the type menu to stdout. When MATCHED_PRESETS is non-empty, each
# matching preset appears as an additional menu entry placed at the top
# (options 1..N, where N = number of matches), visually distinguished
# from the standard 11 type options that follow (options N+1..N+11).
#
# Arguments:
#   $1 - (optional) the option number to mark as default with a "← detected"
#        suffix. When omitted, no option is marked.
# Sets:
#   _TYPE_MENU_TOTAL — total number of menu entries (n_presets + 11).
print_type_menu() {
    local default_choice="${1:-}"
    local n=${#MATCHED_PRESETS[@]}
    local i opt

    if [[ $n -gt 0 ]]; then
        for ((i = 0; i < n; i++)); do
            opt=$((i + 1))
            if [[ "$opt" == "$default_choice" ]]; then
                echo -e "  ${GREEN}${opt})${NC} ${BOLD}Use preset: ${MATCHED_PRESETS[$i]}${NC} ${GREEN}← detected${NC}"
            else
                echo -e "  ${opt}) ${BOLD}Use preset: ${MATCHED_PRESETS[$i]}${NC}"
            fi
        done
        echo ""
    fi

    for ((i = 0; i < ${#_MENU_STD_LABELS[@]}; i++)); do
        opt=$((n + i + 1))
        if [[ "$opt" == "$default_choice" ]]; then
            echo -e "  ${GREEN}${opt})${NC} ${BOLD}${_MENU_STD_LABELS[$i]}${NC} ${GREEN}← detected${NC}"
        else
            echo "  ${opt}) ${_MENU_STD_LABELS[$i]}"
        fi
    done

    _TYPE_MENU_TOTAL=$((n + ${#_MENU_STD_LABELS[@]}))
}

# print_filtered_type_menu <category_slug>
#
# Render a category-filtered type menu. When the slug is "other-generic",
# this falls back to the unfiltered print_type_menu() behavior (regression-
# safe per spec EF-005). Otherwise:
#   - Filters _MENU_STD_TYPES to only those in _CATEGORY_TYPES_MAP[slug]
#   - Scans .claude/presets/*.json for presets whose categories[] field
#     includes the slug, listing them first (just like MATCHED_PRESETS does
#     in the unfiltered menu)
#   - Prints a banner pointing to the roadmap when zero presets match
#
# Sets:
#   _TYPE_MENU_TOTAL — total number of menu entries.
#   _FILTERED_PRESETS — array of preset names in the filtered menu
#                       (consumed by apply_filtered_type_choice).
#   _FILTERED_STD_TYPES — array of standard-type slugs in the filtered
#                         menu (also consumed by the choice handler).
#
# Requires lib/category-map.sh to be sourced first.
print_filtered_type_menu() {
    local slug="$1"

    # Reset state.
    _FILTERED_PRESETS=()
    _FILTERED_STD_TYPES=()

    # When the user picked "Other / Generic", fall back to the unfiltered
    # menu — same behavior as today's flow.
    if [[ "$slug" = "other-generic" ]]; then
        print_type_menu ""
        # Populate the filtered arrays with the full lists so the choice
        # handler can resolve any pick.
        local sk
        if [[ -d "$BASE_DIR/.claude/presets" ]]; then
            while IFS= read -r sk; do
                _FILTERED_PRESETS+=("$(basename "$sk" .json)")
            done < <(find "$BASE_DIR/.claude/presets" -maxdepth 2 -name "*.json" -type f 2>/dev/null | sort)
        fi
        _FILTERED_STD_TYPES=("${_MENU_STD_TYPES[@]}")
        return 0
    fi

    # Filter presets: scan all manifests, collect those whose categories[]
    # contains the slug.
    local file pname pcats
    if [[ -d "$BASE_DIR/.claude/presets" ]] && command -v jq >/dev/null 2>&1; then
        while IFS= read -r file; do
            pname=$(jq -r '.name // empty' "$file" 2>/dev/null)
            [[ -z "$pname" ]] && continue
            pcats=$(jq -r '.categories // [] | join(",")' "$file" 2>/dev/null)
            if [[ ",$pcats," == *",$slug,"* ]]; then
                _FILTERED_PRESETS+=("$pname")
            fi
        done < <(find "$BASE_DIR/.claude/presets" -maxdepth 2 -name "*.json" -type f 2>/dev/null | sort)
    fi

    # Filter standard types: keep only those listed in the category-to-types
    # map for this slug.
    local relevant_types
    relevant_types=$(category_types "$slug")
    local i st
    for ((i = 0; i < ${#_MENU_STD_TYPES[@]}; i++)); do
        st="${_MENU_STD_TYPES[$i]}"
        if [[ " $relevant_types " == *" $st "* ]]; then
            _FILTERED_STD_TYPES+=("$i")
        fi
    done

    # Empty-category banner (spec US-8): when no preset declares this
    # category, print a one-line pointer to the roadmap.
    if [[ ${#_FILTERED_PRESETS[@]} -eq 0 ]]; then
        echo -e "  ${DIM}(No preset yet for this category — see specs/presets/roadmap.md for community-wanted candidates.)${NC}"
        echo ""
    fi

    # Render presets first (options 1..N), then filtered standard types.
    local n=${#_FILTERED_PRESETS[@]}
    local opt
    if [[ $n -gt 0 ]]; then
        for ((i = 0; i < n; i++)); do
            opt=$((i + 1))
            echo -e "  ${opt}) ${BOLD}Use preset: ${_FILTERED_PRESETS[$i]}${NC}"
        done
        echo ""
    fi

    local std_count=${#_FILTERED_STD_TYPES[@]}
    local std_i type_idx
    for ((std_i = 0; std_i < std_count; std_i++)); do
        opt=$((n + std_i + 1))
        type_idx="${_FILTERED_STD_TYPES[$std_i]}"
        echo "  ${opt}) ${_MENU_STD_LABELS[$type_idx]}"
    done

    _TYPE_MENU_TOTAL=$((n + std_count))
}

# apply_filtered_type_choice <choice>
#
# Parse the user's numeric choice from a filtered type menu. Sets
# PRESET_NAME (if choice maps to a filtered preset) or PROJECT_TYPE
# (if choice maps to a filtered standard type). Returns 1 on invalid
# input — caller falls back to default.
apply_filtered_type_choice() {
    local choice="$1"
    local n=${#_FILTERED_PRESETS[@]}
    [[ "$choice" =~ ^[0-9]+$ ]] || return 1

    if (( choice >= 1 && choice <= n )); then
        # shellcheck disable=SC2034  # consumed by new-project.sh::main
        PRESET_NAME="${_FILTERED_PRESETS[$((choice - 1))]}"
        return 0
    fi

    local std_pos=$((choice - n - 1))
    local std_total=${#_FILTERED_STD_TYPES[@]}
    if (( std_pos < 0 || std_pos >= std_total )); then
        return 1
    fi
    local type_idx="${_FILTERED_STD_TYPES[$std_pos]}"
    # shellcheck disable=SC2034  # consumed by new-project.sh::main
    PROJECT_TYPE="${_MENU_STD_TYPES[$type_idx]}"
    return 0
}

# apply_type_choice <choice>
#
# Parse the user's numeric choice from the type menu. If the choice falls
# in the preset range (1..n_presets), set PRESET_NAME to the corresponding
# preset; otherwise map to the standard project type at the offset position
# and set PROJECT_TYPE.
#
# Arguments:
#   $1 - User's numeric choice
# Returns:
#   0 on success (PRESET_NAME or PROJECT_TYPE set)
#   1 on invalid input (caller falls back to default)
apply_type_choice() {
    local choice="$1"
    local n=${#MATCHED_PRESETS[@]}
    [[ "$choice" =~ ^[0-9]+$ ]] || return 1

    if (( choice >= 1 && choice <= n )); then
        # shellcheck disable=SC2034  # consumed by new-project.sh::main
        PRESET_NAME="${MATCHED_PRESETS[$((choice - 1))]}"
        return 0
    fi

    local std_idx=$((choice - n - 1))
    if (( std_idx < 0 || std_idx >= ${#_MENU_STD_TYPES[@]} )); then
        return 1
    fi
    # shellcheck disable=SC2034  # consumed by new-project.sh::main
    PROJECT_TYPE="${_MENU_STD_TYPES[$std_idx]}"
    return 0
}
