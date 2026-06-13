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

# detect_skill_install_status <skill_id> [project_dir]
#
# Reports whether a recommended vendor skill is already present in the
# user-global Claude config or (optionally) the given project. Pure
# filesystem check — no network, no Claude CLI invocation, honors the
# foundation's "observe, never install" supply-chain rule.
#
# Outputs one of:
#   - "installed"     a directory exists at $HOME/.claude/skills/<id> or
#                     <project_dir>/.claude/skills/<id> (empty dir counts;
#                     filesystem presence is the truth, not validity)
#   - "not_installed" no such directory in either location
#   - "unknown"       skill_id contains '@' (marketplace plugin handle —
#                     plugins live elsewhere and aren't FS-observable here)
#
# Arguments:
#   $1 - skill id (e.g. "vercel-react-best-practices",
#        "frontend-design@claude-plugins-official")
#   $2 - optional project directory (skipped when empty/unset)
# Return: 0 always
detect_skill_install_status() {
    local skill_id="$1"
    local project_dir="${2:-}"

    case "$skill_id" in
        *@*)
            echo "unknown"
            return 0
            ;;
    esac

    if [[ -d "${HOME:-}/.claude/skills/$skill_id" ]]; then
        echo "installed"
        return 0
    fi

    if [[ -n "$project_dir" && -d "$project_dir/.claude/skills/$skill_id" ]]; then
        echo "installed"
        return 0
    fi

    echo "not_installed"
    return 0
}

# Internal: format an install-status marker with color. Emits one of
# [OK] / [--] / [?] wrapped in ANSI color codes (or plain text when colors
# are disabled — common.sh handles NO_COLOR / non-TTY by emptying the vars).
_format_install_marker() {
    case "$1" in
        installed)     printf '%s[OK]%s' "${GREEN:-}" "${NC:-}" ;;
        not_installed) printf '%s[--]%s' "${DIM:-}" "${NC:-}" ;;
        unknown|*)     printf '%s[?]%s'  "${YELLOW:-}" "${NC:-}" ;;
    esac
}

# Internal: emit an install-pointer line for an item, aligned with
# docs/recipes/recommended-vendor-skills.md. Patterns recognised:
#   - id contains '@'  → marketplace plugin → `claude plugin install <id>`
#   - id contains '/'  → GitHub vendor repo → `git clone --depth 1 <url>`
#   - otherwise        → no pointer (URL line above is enough)
# Args: $1=id, $2=url. Writes the line to stdout (or nothing).
_format_install_pointer() {
    local id="$1"
    local url="$2"
    case "$id" in
        *@*)
            printf '      $ claude plugin install %s' "$id"
            ;;
        */*)
            printf '      $ git clone --depth 1 %s' "$url"
            ;;
    esac
}

# print_recommended_vendor_skills <preset_file> [project_dir]
#
# Prints the preset's recommendedVendorSkills array, grouped into two
# sections: "always" recommendations (highly relevant for the stack) and
# conditional ones (apply only if the user uses the named tool). Each item
# is prefixed with an install-status marker:
#   - [OK]   already installed (user-global or project-scope)
#   - [--]   not installed (the user can opt in)
#   - [?]    unknown — marketplace plugin handles ('@' in id) live outside
#            the .claude/skills/ filesystem layout
# Items also show id, rationale and URL. Section closes with a pointer to
# the canonical recipe.
#
# Silent (returns 0 with no output) when:
#   - the preset_file argument is empty
#   - the preset_file does not exist
#   - jq is unavailable
#   - the recommendedVendorSkills array is empty/missing
#
# Arguments:
#   $1 - Absolute path to the preset JSON manifest
#   $2 - Optional project directory (forwarded to detect_skill_install_status
#        for the project-scope check). Empty / unset → user-global only.
# Return: 0 always
print_recommended_vendor_skills() {
    local preset_file="$1"
    local project_dir="${2:-}"

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

    local i rid rurl rrat rcond rstatus rmarker rpointer
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
                rstatus=$(detect_skill_install_status "$rid" "$project_dir")
                rmarker=$(_format_install_marker "$rstatus")
                echo -e "    $rmarker • $rid"
                echo "      $rrat"
                echo "      → $rurl"
                rpointer=$(_format_install_pointer "$rid" "$rurl")
                [[ -n "$rpointer" ]] && echo "$rpointer"
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
                rstatus=$(detect_skill_install_status "$rid" "$project_dir")
                rmarker=$(_format_install_marker "$rstatus")
                echo -e "    $rmarker • $rid — $rcond"
                echo "      $rrat"
                echo "      → $rurl"
                rpointer=$(_format_install_pointer "$rid" "$rurl")
                [[ -n "$rpointer" ]] && echo "$rpointer"
                ;;
        esac
    done
    [[ "$printed_conditional" = "1" ]] && echo ""

    echo "  See docs/recipes/recommended-vendor-skills.md for install commands."
    echo ""
}

# =============================================================================
# Recommendation drift (US-9, specs/marketplace-curation-engine)
#
# Snapshot the preset's recommendedVendorSkills set into the project manifest
# (.claude/foundation.json → .recommendations) at install/update, then diff the
# current preset against that snapshot so a changed recommendation set (added /
# removed / re-pinned) surfaces as a TRACKED change on the next update instead of
# silently drifting. Pure jq; never installs anything (observe-never-install).
# =============================================================================

# recommendations_snapshot_from_preset <preset_file>
# stdout: JSON array [{id, pinnedRef}] sorted by id (stable diff). [] if none.
recommendations_snapshot_from_preset() {
    local pf="$1"
    [ -f "$pf" ] || { echo '[]'; return 0; }
    jq -c '[.recommendedVendorSkills[]? | {id: .id, pinnedRef: (.pinnedRef // "")}] | sort_by(.id)' \
        "$pf" 2>/dev/null || echo '[]'
}

# _recommendation_diff_lines <old-json-array> <new-json-array>
# stdout: human lines (+ added / - removed / ~ repinned). Empty if identical.
_recommendation_diff_lines() {
    jq -rn --argjson old "$1" --argjson new "$2" '
        ($old | map({(.id): .pinnedRef}) | add // {}) as $o
        | ($new | map({(.id): .pinnedRef}) | add // {}) as $n
        | ( [ $n | to_entries[] | select($o[.key] == null) | "+ added: \(.key) @ \(.value)" ]
          + [ $o | to_entries[] | select($n[.key] == null) | "- removed: \(.key)" ]
          + [ $n | to_entries[] | select($o[.key] != null and $o[.key] != .value)
                | "~ repinned: \(.key) \($o[.key]) → \(.value)" ]
          ) | .[]'
}

# recommendation_drift <preset_file> <target_dir>
# stdout: drift lines vs the manifest's stored snapshot. Empty (exit 0) when there
# is no prior snapshot (first run — no false drift) or no change.
recommendation_drift() {
    local pf="$1" dir="$2"
    local manifest="$dir/.claude/foundation.json"
    [ -f "$manifest" ] || return 0
    local old new
    old=$(jq -c '.recommendations // empty' "$manifest" 2>/dev/null)
    [ -n "$old" ] || return 0
    new=$(recommendations_snapshot_from_preset "$pf")
    _recommendation_diff_lines "$old" "$new"
}

# record_recommendations_snapshot <preset_file> <target_dir>
# Persist the current snapshot into .claude/foundation.json (.recommendations),
# preserving the other manifest fields. No-op (exit 0) when no manifest exists.
record_recommendations_snapshot() {
    local pf="$1" dir="$2"
    local manifest="$dir/.claude/foundation.json"
    [ -f "$manifest" ] || return 0
    local snap tmp
    snap=$(recommendations_snapshot_from_preset "$pf")
    tmp=$(mktemp) || return 1
    if jq --argjson rec "$snap" '.recommendations = $rec' "$manifest" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$manifest"
    else
        rm -f "$tmp"
        return 1
    fi
}
