#!/usr/bin/env bash
# =============================================================================
# selected-set.sh — P2 installer seam: selection as data (select-then-emit)
# =============================================================================
# Computes the explicit SRC[:DST] manifest of everything the manifest-driven
# part of an install ships (specs/agnostic-core/plan-p2.md). Grammar matches
# scripts/lib/minimal-manifest.txt: one repo-relative path per line, trailing
# `/` = whole directory, `SRC:DST` = relocation remap, `#` comments allowed by
# the consumer. Pure: no filesystem writes, deterministic (sorted, unique).
#
# Selection inputs are the same globals the init orchestrators fill today:
#   PRESET_COMMANDS_MODE / PRESET_COMMANDS_ENTRIES[]   (drop|keep)
#   PRESET_AGENTS_MODE   / PRESET_AGENTS_ENTRIES[]
#   PRESET_SKILLS_KEEP[] / PRESET_SKILLS_DROP[]        (keep wins if non-empty)
#   SELECTED_MODULES[]                                  (module bundles to ADD)
# plus the pure libs: catalog_list_items / catalog_removal_set
# (catalog-filter.sh), module_bundle_paths / path_module (modules.sh), and
# get_rules_for_type (moved here — single canonical copy for init and, later,
# update).
#
# NOT shipped to target projects; installer-side only.
# macOS bash 3.2 compatible.
# =============================================================================

if [ -n "${SELECTED_SET_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
SELECTED_SET_LOADED=1

_selset_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=catalog-filter.sh
[ -f "$_selset_dir/catalog-filter.sh" ] && . "$_selset_dir/catalog-filter.sh"
# shellcheck source=modules.sh
[ -f "$_selset_dir/modules.sh" ] && . "$_selset_dir/modules.sh"

# get_rules_for_type <project_type> — the rules whitelist for a stack type.
# Single canonical copy (moved from new-project.sh; init sources this lib).
get_rules_for_type() {
    local project_type="$1"

    # Universal rules (always copied) — applicable to all projects
    # regardless of language/framework. Includes deploy-safety (Docker/env files)
    # and research (check native before building custom) since these are
    # cross-cutting concerns, not stack-specific.
    # The 4 global (path-less) rules — git, workflow, self-improvement,
    # vendor-precedence — apply regardless of file type and must ALL ship, else
    # the copied rules/README.md references rules absent from disk.
    local rules=("git.md" "workflow.md" "self-improvement.md" "vendor-precedence.md" "tdd-enforcement.md" "verification.md" "security.md" "testing.md" "lsp.md" "deploy-safety.md" "research.md" "README.md")

    # Rules specific to the project type
    case "$project_type" in
        react|vue|node-api|fullstack|generic)
            rules+=("typescript.md" "react.md" "nextjs.md" "accessibility.md" "performance.md" "api.md" "design-style.md")
            ;;
        flutter)
            rules+=("flutter.md" "design-style.md")
            ;;
        python)
            rules+=("python.md")
            ;;
        go)
            rules+=("go.md")
            ;;
        rust)
            rules+=("rust.md")
            ;;
        java)
            rules+=("java.md")
            ;;
    esac

    # If type is unknown or generic, add TS/web by default (most common case)
    if [[ "$project_type" == "generic" || -z "$project_type" ]]; then
        rules+=("typescript.md" "react.md" "accessibility.md" "performance.md" "api.md" "design-style.md")
    fi

    # Deduplicate and return
    printf '%s\n' "${rules[@]}" | sort -u
}

# _selset_module_selected <name> — 0 if <name> is in SELECTED_MODULES.
_selset_module_selected() {
    local m
    for m in ${SELECTED_MODULES[@]+"${SELECTED_MODULES[@]}"}; do
        [ "$m" = "$1" ] && return 0
    done
    return 1
}

# _selset_owned_by_unselected <repo-relative-path> — 0 if the path belongs to
# a module bundle that is NOT selected (so it must not ship as core).
_selset_owned_by_unselected() {
    local owner=""
    if declare -F path_module >/dev/null 2>&1; then
        owner=$(path_module "$1" 2>/dev/null || true)
    fi
    [ -n "$owner" ] || return 1
    _selset_module_selected "$owner" && return 1
    return 0
}

# _selset_catalog <catalog> <root-rel> <base> <mode> <entries...>
# Emit the selected per-file entries of one catalog (commands|agents):
# full listing minus the removal set minus unselected-module-owned items.
_selset_catalog() {
    local catalog="$1" root_rel="$2" base="$3" mode="$4"
    shift 4
    local root="$base/$root_rel"
    [ -d "$root" ] || return 0

    local removal="" rel
    if [ -n "$mode" ]; then
        removal=$(catalog_removal_set "$catalog" "$root" "$mode" ${1+"$@"})
    fi
    while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        if [ -n "$removal" ]; then
            case "$removal" in
                "$rel"|"$rel"$'\n'*|*$'\n'"$rel"|*$'\n'"$rel"$'\n'*) continue ;;
            esac
        fi
        _selset_owned_by_unselected "$root_rel/$rel" && continue
        printf '%s\n' "$root_rel/$rel"
    done < <(catalog_list_items "$catalog" "$root")
}

# _selset_skills <base> — whole-directory entries for the selected skills.
# PRESET_SKILLS_KEEP non-empty → keep exactly those; else drop PRESET_SKILLS_DROP.
_selset_skills() {
    local base="$1" d name k keep_mode=0
    [ -d "$base/.claude/skills" ] || return 0
    local nkeep=0
    for k in ${PRESET_SKILLS_KEEP[@]+"${PRESET_SKILLS_KEEP[@]}"}; do nkeep=$((nkeep+1)); done
    [ "$nkeep" -gt 0 ] && keep_mode=1
    for d in "$base"/.claude/skills/*/; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        if [ "$keep_mode" -eq 1 ]; then
            local found=1
            for k in ${PRESET_SKILLS_KEEP[@]+"${PRESET_SKILLS_KEEP[@]}"}; do
                [ "$k" = "$name" ] && { found=0; break; }
            done
            [ "$found" -eq 0 ] || continue
        else
            local dropped=1
            for k in ${PRESET_SKILLS_DROP[@]+"${PRESET_SKILLS_DROP[@]}"}; do
                [ "$k" = "$name" ] && { dropped=0; break; }
            done
            [ "$dropped" -eq 0 ] && continue
        fi
        _selset_owned_by_unselected ".claude/skills/$name" && continue
        printf '.claude/skills/%s/\n' "$name"
    done
}

# compute_selected_set <base_dir> <project_type> — print the full manifest.
compute_selected_set() {
    local base="${1%/}" project_type="$2"
    {
        # Fixed manifest-driven artifacts (only those present in the source).
        [ -f "$base/.claude/settings.json" ]      && printf '%s\n' ".claude/settings.json"
        [ -d "$base/scripts/hooks" ]              && printf '%s\n' "scripts/hooks/"
        [ -f "$base/scripts/substance-check.sh" ] && printf '%s\n' "scripts/substance-check.sh"
        [ -d "$base/.claude/output-styles" ]      && printf '%s\n' ".claude/output-styles/"
        [ -d "$base/.claude/templates" ]          && printf '%s\n' ".claude/templates/"

        # Docs relocation remaps (dir remaps keep the recursive copy semantics).
        [ -d "$base/docs/reference" ]      && printf '%s\n' "docs/reference/:.claude/docs/reference/"
        [ -d "$base/docs/guides" ]         && printf '%s\n' "docs/guides/:.claude/docs/guides/"
        [ -f "$base/docs/STACK-RECIPES.md" ] && printf '%s\n' "docs/STACK-RECIPES.md:.claude/docs/STACK-RECIPES.md"

        # Catalogs (core = listing − removal − unselected-module-owned).
        _selset_catalog commands ".claude/commands" "$base" "${PRESET_COMMANDS_MODE:-}" \
            ${PRESET_COMMANDS_ENTRIES[@]+"${PRESET_COMMANDS_ENTRIES[@]}"}
        _selset_catalog agents ".claude/agents" "$base" "${PRESET_AGENTS_MODE:-}" \
            ${PRESET_AGENTS_ENTRIES[@]+"${PRESET_AGENTS_ENTRIES[@]}"}

        # Skills (whole directories).
        _selset_skills "$base"

        # Selected module bundles, verbatim from their manifests.
        local m p
        for m in ${SELECTED_MODULES[@]+"${SELECTED_MODULES[@]}"}; do
            while IFS= read -r p; do
                [ -n "$p" ] && printf '%s\n' "$p"
            done < <(module_bundle_paths "$m")
        done

        # Rules: positive whitelist per stack type.
        local rule
        while IFS= read -r rule; do
            [ -z "$rule" ] && continue
            [ -f "$base/.claude/rules/$rule" ] && printf '.claude/rules/%s\n' "$rule"
        done < <(get_rules_for_type "$project_type")
    } | LC_ALL=C sort -u
    return 0
}
