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
        PRESET_NAME="${MATCHED_PRESETS[$((choice - 1))]}"
        return 0
    fi

    local std_idx=$((choice - n - 1))
    if (( std_idx < 0 || std_idx >= ${#_MENU_STD_TYPES[@]} )); then
        return 1
    fi
    PROJECT_TYPE="${_MENU_STD_TYPES[$std_idx]}"
    return 0
}
