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
    # migration-safety is universal for the same reason as deploy-safety: its
    # target paths span the stacks (package.json/tsconfig/next.config AND
    # pyproject.toml AND go.mod), so it is cross-cutting, not web-specific.
    local rules=("git.md" "workflow.md" "self-improvement.md" "vendor-precedence.md" "tdd-enforcement.md" "verification.md" "security.md" "testing.md" "lsp.md" "deploy-safety.md" "migration-safety.md" "research.md" "README.md")

    # The web bundle — shared by every JS/TS-flavoured type. service-worker
    # belongs here (paths: sw.js, service-worker*) and nowhere else.
    local web_rules=("typescript.md" "react.md" "nextjs.md" "accessibility.md" "performance.md" "api.md" "design-style.md" "service-worker.md")

    # Rules specific to the project type
    case "$project_type" in
        vue)
            # Vue gets the web bundle PLUS its own rule — omitting vue.md meant
            # a detected Vue project never received its framework rule.
            rules+=("${web_rules[@]}" "vue.md")
            ;;
        react|node-api|fullstack|generic)
            rules+=("${web_rules[@]}")
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
        rules+=("${web_rules[@]}")
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

# skill_excluded_by_preset <name> — 0 if the preset skill filter excludes it.
# PRESET_SKILLS_KEEP non-empty → keep exactly those; else drop PRESET_SKILLS_DROP.
# One test for BOTH the core enumeration and the module-bundle re-adds: the
# old apply_preset_filter ran on every INSTALLED skill unconditionally, so a
# selected module's skill outside the keep list was removed too — the bundle
# loop must not bypass the filter.
#
# PUBLIC: update.sh consumes this too, so the keep/drop rule has ONE definition
# rather than one per install/update path. Callers fill the two arrays; the
# predicate itself is pure (no preset file read, no filesystem access).
skill_excluded_by_preset() {
    local name="$1" k nkeep=0
    for k in ${PRESET_SKILLS_KEEP[@]+"${PRESET_SKILLS_KEEP[@]}"}; do nkeep=$((nkeep+1)); done
    if [ "$nkeep" -gt 0 ]; then
        for k in ${PRESET_SKILLS_KEEP[@]+"${PRESET_SKILLS_KEEP[@]}"}; do
            [ "$k" = "$name" ] && return 1
        done
        return 0
    fi
    for k in ${PRESET_SKILLS_DROP[@]+"${PRESET_SKILLS_DROP[@]}"}; do
        [ "$k" = "$name" ] && return 0
    done
    return 1
}

# _selset_skills <base> — whole-directory entries for the selected skills,
# plus the top-level files of .claude/skills/ (README.md — the old
# `cp -r skills/*` always shipped them and no filter ever removed a file).
_selset_skills() {
    local base="$1" d f name
    [ -d "$base/.claude/skills" ] || return 0
    for f in "$base"/.claude/skills/*; do
        [ -f "$f" ] && printf '.claude/skills/%s\n' "$(basename "$f")"
    done
    for d in "$base"/.claude/skills/*/; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        skill_excluded_by_preset "$name" && continue
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

        # Selected module bundles. Two guards mirroring the old pipeline:
        #   - [ -e ]: the old deletion path guarded every bundle entry with
        #     [[ -e ]]; a stale registry entry must not hard-fail the emit;
        #   - skill entries still pass the preset skill filter (the old
        #     apply_preset_filter ran on every installed skill, module-owned
        #     included — the bundle loop must not resurrect an excluded one).
        local m p pname
        for m in ${SELECTED_MODULES[@]+"${SELECTED_MODULES[@]}"}; do
            while IFS= read -r p; do
                [ -n "$p" ] || continue
                [ -e "$base/${p%/}" ] || continue
                case "$p" in
                    .claude/skills/*/|.claude/skills/*)
                        pname="${p#.claude/skills/}"
                        pname="${pname%%/*}"
                        [ -n "$pname" ] && skill_excluded_by_preset "$pname" && continue
                        ;;
                esac
                printf '%s\n' "$p"
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
