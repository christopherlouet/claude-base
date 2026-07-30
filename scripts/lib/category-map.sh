#!/usr/bin/env bash

# =============================================================================
# Claude-Base Category Map Library
# Spec: specs/preset-category-prompt/spec.md
#
# Defines the 8-entry intent taxonomy (locked enum) used by the
# pre-detection category prompt in new-project.sh, plus helper functions
# to render the prompt and parse the user's choice.
#
# Requires bash 4+ (associative arrays for _CATEGORY_TYPES_MAP).
# Enforced by common.sh:177 via the foundation's base requirements check.
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

# Locked taxonomy — 8 categories, in display order, mirrored by
# specs/presets/roadmap.md §"Category taxonomy" (drift-guard bats test
# enforces alignment).
_CATEGORY_SLUGS=(
    web-frontend
    api-backend
    mobile-desktop
    game-interactive-media
    data-database
    infra-devops
    cli-automation
    other-generic
)

_CATEGORY_LABELS=(
    "Web frontend"
    "API / Backend"
    "Mobile / Desktop"
    "Game / Interactive media"
    "Data / Database"
    "Infra / DevOps"
    "CLI / Automation"
    "Other / Generic"
)

# Category-to-standard-type-subset mapping. Each value is a
# space-separated list of slugs from _MENU_STD_TYPES (see lib/menu.sh).
# The "other-generic" entry lists ALL 11 standard types (regression-safe
# fallback to the unfiltered menu per spec EF-005).
declare -A _CATEGORY_TYPES_MAP=(
    [web-frontend]="react vue svelte astro fullstack generic"
    [api-backend]="node-api python php ruby csharp go rust java generic"
    [mobile-desktop]="flutter csharp generic"
    [game-interactive-media]="csharp generic"
    [data-database]="python generic"
    [infra-devops]="generic"
    [cli-automation]="python ruby go rust generic"
    [other-generic]="react vue node-api python go rust java fullstack flutter neovim svelte astro php ruby csharp generic"
)

# print_category_menu [default_choice]
#
# Render the 8-entry category prompt. Marks `other-generic` (entry 8) as
# the default per spec CP1 lock.
#
# Arguments:
#   $1 - (optional) the option number to mark as default with a "← default"
#        suffix. When omitted, entry 8 (other-generic) is marked.
# shellcheck disable=SC2120  # $1 is intentionally optional (default 8)
print_category_menu() {
    local default_choice="${1:-8}"
    local i opt

    for ((i = 0; i < ${#_CATEGORY_LABELS[@]}; i++)); do
        opt=$((i + 1))
        if [[ "$opt" == "$default_choice" ]]; then
            echo -e "  ${GREEN}${opt})${NC} ${BOLD}${_CATEGORY_LABELS[$i]}${NC} ${GREEN}← default${NC}"
        else
            echo "  ${opt}) ${_CATEGORY_LABELS[$i]}"
        fi
    done
}

# apply_category_choice <choice>
#
# Parse the user's numeric choice. Sets SELECTED_CATEGORY_SLUG to the
# matching slug from _CATEGORY_SLUGS. Empty or invalid input → falls
# back to "other-generic" per spec CP1.
#
# Arguments:
#   $1 - User's numeric choice (or empty string for default).
# Sets:
#   SELECTED_CATEGORY_SLUG — one of _CATEGORY_SLUGS or "other-generic".
apply_category_choice() {
    local choice="$1"
    local n=${#_CATEGORY_SLUGS[@]}

    # Empty input → default to other-generic (CP1 lock).
    if [[ -z "$choice" ]]; then
        SELECTED_CATEGORY_SLUG="other-generic"
        return 0
    fi

    # Non-numeric → fall back to other-generic.
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        SELECTED_CATEGORY_SLUG="other-generic"
        return 0
    fi

    # Out-of-range → fall back to other-generic.
    if (( choice < 1 || choice > n )); then
        SELECTED_CATEGORY_SLUG="other-generic"
        return 0
    fi

    SELECTED_CATEGORY_SLUG="${_CATEGORY_SLUGS[$((choice - 1))]}"
    return 0
}

# ask_category
#
# Interactive composite: renders the menu, reads stdin, applies the
# choice, prints the resulting slug to stdout.
#
# Note: the TTY guard is in the CALLER (scripts/new-project.sh::
# get_project_type), NOT here, so this function is testable by piping
# input directly. See spec EF-009.
#
# Outputs:
#   stdout: the selected category slug (e.g., "game-interactive-media").
ask_category() {
    # The caller captures stdout via $(...), so ONLY the resulting slug may go to
    # stdout. The menu, the question and the prompt go to stderr — otherwise they
    # are swallowed by the capture (the user sees nothing) AND pollute the slug.
    echo "" >&2
    echo "What are you building?" >&2
    echo "" >&2
    print_category_menu >&2
    echo "" >&2
    echo -n "Choice [1-8] (default: 8 = Other / Generic): " >&2
    local choice
    read -r choice
    apply_category_choice "$choice"
    echo "$SELECTED_CATEGORY_SLUG"
}

# category_types <category_slug>
#
# Print the space-separated list of standard-type slugs relevant to the
# given category. Used by lib/menu.sh::print_filtered_type_menu().
#
# Arguments:
#   $1 - Category slug (must be one of _CATEGORY_SLUGS).
# Outputs:
#   stdout: space-separated slugs from _MENU_STD_TYPES; empty if invalid.
category_types() {
    local slug="$1"
    echo "${_CATEGORY_TYPES_MAP[$slug]:-}"
}
