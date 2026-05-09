#!/usr/bin/env bash

# =============================================================================
# Claude-Base Preset Recommendations Library
# Prints the recommendedVendorSkills list of an active preset. Called from
# both new-project.sh (at end of init) and update.sh (at end of update).
# Read-only — never installs anything; the user opts in manually via the
# install commands documented in docs/recipes/recommended-vendor-skills.md.
# =============================================================================

# Guard: common.sh must be sourced first (provides BOLD, NC, color helpers)
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

# print_recommended_vendor_skills <preset_file>
#
# Prints the preset's recommendedVendorSkills array, grouped into two
# sections: "always" recommendations (highly relevant for the stack) and
# conditional ones (apply only if the user uses the named tool). Each item
# shows id, rationale and URL. The section closes with a pointer to the
# canonical recipe.
#
# Silent (returns 0 with no output) when:
#   - the preset_file argument is empty
#   - the preset_file does not exist
#   - jq is unavailable
#   - the recommendedVendorSkills array is empty/missing
#
# Arguments:
#   $1 - Absolute path to the preset JSON manifest
# Return: 0 always
print_recommended_vendor_skills() {
    local preset_file="$1"

    [[ -z "$preset_file" || ! -f "$preset_file" ]] && return 0
    if ! command -v jq >/dev/null 2>&1; then
        return 0
    fi

    local count
    count=$(jq -r '.recommendedVendorSkills | length' "$preset_file" 2>/dev/null || echo 0)
    [[ "$count" = "0" || -z "$count" || "$count" = "null" ]] && return 0

    echo ""
    echo -e "${BOLD}📚 Recommended vendor skills for this stack (opt-in):${NC}"
    echo ""

    local i rid rurl rrat rcond
    local printed_always=0 printed_conditional=0

    # First pass: always recommendations
    for i in $(seq 0 $((count - 1))); do
        rcond=$(jq -r ".recommendedVendorSkills[$i].condition" "$preset_file")
        case "$rcond" in
            always*)
                if [[ "$printed_always" = "0" ]]; then
                    echo -e "  ${BOLD}Always pair with this preset:${NC}"
                    printed_always=1
                fi
                rid=$(jq -r ".recommendedVendorSkills[$i].id" "$preset_file")
                rurl=$(jq -r ".recommendedVendorSkills[$i].url" "$preset_file")
                rrat=$(jq -r ".recommendedVendorSkills[$i].rationale" "$preset_file")
                echo "    • $rid"
                echo "      $rrat"
                echo "      → $rurl"
                ;;
        esac
    done
    [[ "$printed_always" = "1" ]] && echo ""

    # Second pass: conditional recommendations
    for i in $(seq 0 $((count - 1))); do
        rcond=$(jq -r ".recommendedVendorSkills[$i].condition" "$preset_file")
        case "$rcond" in
            always*) ;;
            *)
                if [[ "$printed_conditional" = "0" ]]; then
                    echo -e "  ${BOLD}Add if your project uses these tools:${NC}"
                    printed_conditional=1
                fi
                rid=$(jq -r ".recommendedVendorSkills[$i].id" "$preset_file")
                rurl=$(jq -r ".recommendedVendorSkills[$i].url" "$preset_file")
                rrat=$(jq -r ".recommendedVendorSkills[$i].rationale" "$preset_file")
                echo "    • $rid — $rcond"
                echo "      $rrat"
                echo "      → $rurl"
                ;;
        esac
    done
    [[ "$printed_conditional" = "1" ]] && echo ""

    echo "  See docs/recipes/recommended-vendor-skills.md for install commands."
    echo ""
}
