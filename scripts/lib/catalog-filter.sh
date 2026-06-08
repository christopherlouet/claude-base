#!/usr/bin/env bash

# =============================================================================
# catalog-filter.sh — single source of truth for preset command/agent filtering
#
# Spec: specs/presets-commands-agents-filter/spec.md
# Plan: specs/presets-commands-agents-filter/plan.md (S1 — Phase 1)
#
# A "catalog" is either `commands` or `agents`. The two are laid out
# differently on disk, so domain resolution is catalog-aware:
#   commands : .claude/commands/<domain>/<name>.md  (domain = first segment)
#              plus domainless top-level commands (.claude/commands/<name>.md)
#   agents   : .claude/agents/<domain>-<name>.md     (domain = prefix before
#              the first '-'; every agent is prefixed)
#
# A filter list entry is either an exact item name (`ops-proxmox`) or a whole
# domain via the `domain:<name>` form. Mode is drop XOR keep (validated
# upstream, same rule as skills):
#   drop : removal set = matched \ floor
#   keep : removal set = (all \ matched) \ floor   (whitelist)
# The protected floor (EF-111) is the `work` domain + the `assistant` and
# `assistant-auto` command entry points; it is force-kept in BOTH modes.
#
# This lib only resolves/matches. Horizontal domains (biz/legal/growth) carry
# no special meaning here — their rejection lives in validate-presets (S3).
#
# Portability: macOS bash 3.2 — no associative arrays, no readarray. The hot
# path (catalog_removal_set) resolves each item once via _resolve into the
# _CF_DOMAIN/_CF_NAME globals and avoids per-item subshells.
# =============================================================================

# -----------------------------------------------------------------------------
# Internals
# -----------------------------------------------------------------------------

# _cf_valid_catalog <catalog> — 0 for a known catalog, else fail loud.
_cf_valid_catalog() {
    case "${1:-}" in
        commands|agents) return 0 ;;
        *)
            printf 'catalog-filter: unknown catalog: %s (expected: commands|agents)\n' \
                "${1:-<empty>}" >&2
            return 2
            ;;
    esac
}

# _resolve <catalog> <relpath> — set _CF_DOMAIN and _CF_NAME for the item.
# relpath is relative to the catalog root (e.g. `work/work-plan.md`,
# `assistant.md`, `wcag-audit.md`). No subshell — callers in the hot path
# read the globals directly.
_resolve() {
    local catalog="$1" relpath="$2"
    local base="${relpath##*/}"
    _CF_NAME="${base%.md}"
    if [[ "$catalog" == commands ]]; then
        if [[ "$relpath" == */* ]]; then
            _CF_DOMAIN="${relpath%%/*}"
        else
            _CF_DOMAIN=""
        fi
    else
        # agents: domain is the prefix before the first '-'.
        if [[ "$_CF_NAME" == *-* ]]; then
            _CF_DOMAIN="${_CF_NAME%%-*}"
        else
            _CF_DOMAIN=""
        fi
    fi
}

# _entry_matches <entry> — using the current _CF_DOMAIN/_CF_NAME, 0 if the
# entry (`domain:<name>` or an exact item name) matches the resolved item.
_entry_matches() {
    local entry="$1"
    case "$entry" in
        domain:*) [[ "$_CF_DOMAIN" == "${entry#domain:}" ]] ;;
        *)        [[ "$_CF_NAME" == "$entry" ]] ;;
    esac
}

# _is_floor <catalog> — using the current _CF_DOMAIN/_CF_NAME, 0 if the item
# belongs to the protected floor (EF-111).
_is_floor() {
    [[ "$_CF_DOMAIN" == work ]] && return 0
    if [[ "$1" == commands ]]; then
        [[ "$_CF_NAME" == assistant || "$_CF_NAME" == assistant-auto ]] && return 0
    fi
    return 1
}

# -----------------------------------------------------------------------------
# Public — item resolution
# -----------------------------------------------------------------------------

# catalog_item_domain <catalog> <relpath> — print the item's domain (empty for
# a domainless top-level command).
catalog_item_domain() {
    _cf_valid_catalog "$1" || return $?
    _resolve "$1" "$2"
    printf '%s\n' "$_CF_DOMAIN"
}

# catalog_item_name <catalog> <relpath> — print the item name (basename, no .md).
catalog_item_name() {
    _cf_valid_catalog "$1" || return $?
    _resolve "$1" "$2"
    printf '%s\n' "$_CF_NAME"
}

# catalog_entry_matches <catalog> <entry> <relpath> — 0 if entry matches item.
catalog_entry_matches() {
    _cf_valid_catalog "$1" || return $?
    _resolve "$1" "$3"
    _entry_matches "$2"
}

# -----------------------------------------------------------------------------
# Public — enumeration
# -----------------------------------------------------------------------------

# catalog_list_items <catalog> <root> — print item paths relative to <root>,
# one per line, sorted. Missing root → no output, exit 0.
catalog_list_items() {
    _cf_valid_catalog "$1" || return $?
    local catalog="$1" root="${2:-}"
    [[ -n "$root" && -d "$root" ]] || return 0
    root="${root%/}"
    local f
    if [[ "$catalog" == commands ]]; then
        while IFS= read -r f; do
            printf '%s\n' "${f#"$root"/}"
        done < <(find "$root" -type f -name '*.md' | LC_ALL=C sort)
    else
        while IFS= read -r f; do
            printf '%s\n' "${f#"$root"/}"
        done < <(find "$root" -maxdepth 1 -type f -name '*.md' | LC_ALL=C sort)
    fi
}

# catalog_list_domains <catalog> <root> — print the distinct domains present
# under <root> (domainless top-level items contribute nothing), sorted.
catalog_list_domains() {
    _cf_valid_catalog "$1" || return $?
    local catalog="$1" root="$2" relpath
    while IFS= read -r relpath; do
        [[ -z "$relpath" ]] && continue
        _resolve "$catalog" "$relpath"
        [[ -n "$_CF_DOMAIN" ]] && printf '%s\n' "$_CF_DOMAIN"
    done < <(catalog_list_items "$catalog" "$root") | LC_ALL=C sort -u
}

# -----------------------------------------------------------------------------
# Public — filter resolution
# -----------------------------------------------------------------------------

# catalog_removal_set <catalog> <root> <mode> [entry...] — print the item paths
# (relative to <root>) to remove, with the protected floor subtracted.
#   drop : remove items matching any entry
#   keep : remove items matching no entry (whitelist)
catalog_removal_set() {
    _cf_valid_catalog "$1" || return $?
    local catalog="$1" root="$2" mode="$3"
    case "$mode" in
        drop|keep) ;;
        *) printf 'catalog-filter: unknown mode: %s (expected: drop|keep)\n' \
               "${mode:-<empty>}" >&2; return 2 ;;
    esac
    shift 3
    local entries=("$@")
    local relpath entry matched remove
    while IFS= read -r relpath; do
        [[ -z "$relpath" ]] && continue
        _resolve "$catalog" "$relpath"
        matched=false
        for entry in ${entries[@]+"${entries[@]}"}; do
            if _entry_matches "$entry"; then
                matched=true
                break
            fi
        done
        if [[ "$mode" == drop ]]; then
            $matched && remove=true || remove=false
        else
            $matched && remove=false || remove=true
        fi
        if $remove && ! _is_floor "$catalog"; then
            printf '%s\n' "$relpath"
        fi
    done < <(catalog_list_items "$catalog" "$root")
}

# catalog_floor_violations <catalog> <root> <mode> [entry...] — print the
# entries that explicitly try to remove a floor item (EF-111). Only drop mode
# can violate the floor; keep mode force-keeps it, so it never violates.
catalog_floor_violations() {
    _cf_valid_catalog "$1" || return $?
    local catalog="$1" root="$2" mode="$3"
    shift 3
    [[ "$mode" == drop ]] || return 0
    local entry relpath
    for entry in "$@"; do
        case "$entry" in
            domain:work)
                printf '%s\n' "$entry"
                continue
                ;;
            domain:*)
                # No other domain is part of the floor.
                continue
                ;;
        esac
        # Exact name: flag it if it resolves to a floor item in this catalog.
        while IFS= read -r relpath; do
            _resolve "$catalog" "$relpath"
            if [[ "$_CF_NAME" == "$entry" ]] && _is_floor "$catalog"; then
                printf '%s\n' "$entry"
                break
            fi
        done < <(catalog_list_items "$catalog" "$root")
    done
}

# catalog_unknown_entries <catalog> <root> [entry...] — print the entries that
# match nothing in the catalog: a `domain:<name>` whose domain is absent, or an
# exact item name not present. Source for the EF-105 validation warning.
catalog_unknown_entries() {
    _cf_valid_catalog "$1" || return $?
    local catalog="$1" root="$2"
    shift 2
    local domains items entry dom
    domains="$(catalog_list_domains "$catalog" "$root")"
    items="$(catalog_list_items "$catalog" "$root")"
    for entry in "$@"; do
        case "$entry" in
            domain:*)
                dom="${entry#domain:}"
                case $'\n'"$domains"$'\n' in
                    *$'\n'"$dom"$'\n'*) ;;
                    *) printf '%s\n' "$entry" ;;
                esac
                ;;
            *)
                # Known if some item's name equals the entry.
                if ! _cf_items_have_name "$catalog" "$items" "$entry"; then
                    printf '%s\n' "$entry"
                fi
                ;;
        esac
    done
}

# _cf_items_have_name <catalog> <items-newline-list> <name> — 0 if any item in
# the list has the given name.
_cf_items_have_name() {
    local catalog="$1" items="$2" name="$3" relpath
    while IFS= read -r relpath; do
        [[ -z "$relpath" ]] && continue
        _resolve "$catalog" "$relpath"
        [[ "$_CF_NAME" == "$name" ]] && return 0
    done <<< "$items"
    return 1
}
