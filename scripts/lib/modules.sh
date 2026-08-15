#!/usr/bin/env bash

# =============================================================================
# modules.sh — foundation modules: bundle registry + project manifest helpers
#
# Spec: specs/foundation-modules/spec.md
# A module is a horizontal activity domain (biz, legal, growth) shipped as a
# bundle manifest under scripts/lib/modules/<name>.txt (same syntax as
# minimal-manifest.txt: one repo-relative path per line, # comments, empty
# lines ignored, trailing / means directory).
#
# Portability: the foundation requires bash 4+ (see check_base_requirements in
# common.sh); this lib still avoids associative arrays / readarray to stay simple.
# =============================================================================

# Resolve the bundles directory relative to this file, overridable for tests.
_MODULES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_BUNDLES_DIR="${MODULES_BUNDLES_DIR:-$_MODULES_LIB_DIR/modules}"

# -----------------------------------------------------------------------------
# Registry
# -----------------------------------------------------------------------------

# Print available module names, one per line, sorted.
modules_list() {
    local f name
    for f in "$MODULES_BUNDLES_DIR"/*.txt; do
        [[ -f "$f" ]] || continue
        name="$(basename "$f" .txt)"
        printf '%s\n' "$name"
    done | sort
}

# modules_default_set — the module set to record when no explicit choice
# exists (init without module flags, version recording on a manifest-less
# project). From v3.0.0 the horizontal domains (biz/legal/growth) are pure
# opt-in modules: absence of an explicit choice means NO modules (supersedes
# foundation-modules EF-210 "absence means all"). A default install ships the
# core only; `claude-base add <module>` or a preset's defaultModules opts in.
modules_default_set() {
    :  # empty set — opt-in by default
}

# module_exists <name> — 0 if <name> is a known module.
# Rejects empty names and anything that is not a plain lowercase word
# (defense against path traversal: the name is used to build a file path).
module_exists() {
    local name="${1:-}"
    [[ -n "$name" ]] || return 1
    case "$name" in
        *[!a-z0-9-]*) return 1 ;;
    esac
    [[ -f "$MODULES_BUNDLES_DIR/$name.txt" ]]
}

# -----------------------------------------------------------------------------
# Flattened registry cache (owner lookup)
#
# path_module is called once per catalog item by the select-then-emit installer
# (~200 times per install). Re-reading the registry on each call cost ~30 forks
# a time (modules_list = one basename fork per bundle + sort; then one
# module_bundle_paths process substitution per module) — ~120ms per call, ~24s
# per install. The registry cannot change under a running process, so flatten
# it once into two parallel indexed arrays and scan those instead.
#
# This mirrors the pattern update.sh already uses for the same problem (see
# "US-3 — module-aware filtering (precomputed once, zero forks per file)"):
# parallel indexed arrays loaded once, then a pure-bash lookup per item. The
# select-then-emit installer is the one path that did not adopt it.
#
# Indexed (not associative) arrays: directory entries match by PREFIX, so this
# is an ordered scan rather than a key lookup — and associative arrays are out
# anyway for macOS bash 3.2 portability, as update.sh notes at the same spot.
#
# The key is MODULES_BUNDLES_DIR, so a caller that swaps the registry (tests
# build a synthetic bundles dir) rebuilds instead of answering from the old one.
# -----------------------------------------------------------------------------
_MODULES_REG_KEY=""
_MODULES_REG_N=0
_MODULES_REG_NAME=()
_MODULES_REG_PATH=()
# Out-parameter of path_module_var. Initialised at load so a read under
# `set -u` before the first call is not a fatal unbound-variable error.
_MODULES_PATH_OWNER=""

_modules_registry_load() {
    [[ "$_MODULES_REG_KEY" == "$MODULES_BUNDLES_DIR" ]] && return 0
    _MODULES_REG_NAME=()
    _MODULES_REG_PATH=()
    _MODULES_REG_N=0
    local m p
    # Same traversal order as the pre-cache implementation (modules sorted,
    # then bundle-file order), so first-match wins identically.
    while IFS= read -r m; do
        while IFS= read -r p; do
            [[ -n "$p" ]] || continue
            _MODULES_REG_NAME[_MODULES_REG_N]="$m"
            _MODULES_REG_PATH[_MODULES_REG_N]="$p"
            _MODULES_REG_N=$((_MODULES_REG_N + 1))
        done < <(module_bundle_paths "$m")
    done < <(modules_list)
    _MODULES_REG_KEY="$MODULES_BUNDLES_DIR"
}

# path_module_var <repo-relative-path> — set _MODULES_PATH_OWNER to the module
# that owns <path>, or "" when the path is core.
#
# The variable form exists because the printing form can only be consumed via
# `owner=$(path_module ...)`, and a command substitution forks a subshell: the
# registry cache would be built in the child and thrown away on every item, so
# a caller looping over the catalogs pays a full registry reload per item (the
# #491 regression). Hot loops must call this; `path_module` stays the public
# printing wrapper for one-shot callers.
path_module_var() {
    _MODULES_PATH_OWNER=""
    local path="${1:-}"
    [[ -n "$path" ]] || return 0
    _modules_registry_load
    local i p
    for (( i = 0; i < _MODULES_REG_N; i++ )); do
        p="${_MODULES_REG_PATH[i]}"
        # Directory entry (trailing /): check if path starts with it.
        if [[ "$p" == */ ]]; then
            [[ "$path" == "${p%/}"/* || "$path" == "${p%/}" ]] && { _MODULES_PATH_OWNER="${_MODULES_REG_NAME[i]}"; return 0; }
        else
            [[ "$path" == "$p" ]] && { _MODULES_PATH_OWNER="${_MODULES_REG_NAME[i]}"; return 0; }
        fi
    done
    # Not owned by any module — it is a core path.
    return 0
}

# path_module <repo-relative-path> — print the module name that owns <path>,
# or print nothing (empty) if the path is a core foundation item not owned
# by any optional module bundle.
# Used by update.sh to decide whether a file should be skipped when its
# owning module is absent from the project manifest.
path_module() {
    path_module_var "${1:-}"
    [[ -n "$_MODULES_PATH_OWNER" ]] && printf '%s\n' "$_MODULES_PATH_OWNER"
    return 0
}

# remove_bundle_file <abs-path> — remove a bundle-owned file and drop its
# parent directory once emptied (a hollow module dir would shadow the real
# state). Owned here so every remover (claude-base remove, the init-time
# defaultModules filter) shares one contract. Best-effort rmdir: a
# non-empty parent is left alone.
remove_bundle_file() {
    local f="${1:?file path required}"
    rm -f "$f"
    rmdir "$(dirname "$f")" 2>/dev/null || true
}

# module_bundle_paths <name> — print the bundle's repo-relative paths,
# one per line, comments and empty lines stripped. Fails loud on unknown.
module_bundle_paths() {
    local name="${1:-}"
    if ! module_exists "$name"; then
        printf 'modules: unknown module: %s (available: %s)\n' \
            "$name" "$(modules_list | tr '\n' ' ')" >&2
        return 1
    fi
    local line
    while IFS= read -r line; do
        # Strip trailing whitespace, skip comments and empties.
        line="${line%%[[:space:]]}"
        [[ -z "$line" || "$line" == \#* ]] && continue
        printf '%s\n' "$line"
    done < "$MODULES_BUNDLES_DIR/$name.txt"
}

# module_owned_item_names <catalog> — print the item NAMES (basename without
# .md) owned by ANY module bundle for the given catalog (commands|agents), one
# per line, sorted-unique. This is the item-level companion to "module domains"
# (modules_list): a thematic module (module ≠ domain, EF-402) owns arbitrary
# cross-domain items, so the catalog filter consumes this set as CF_EXCLUDE_ITEMS
# to keep those items out of its jurisdiction (a `keep` whitelist must never
# sweep them up — EF-309 generalised). Directory/skill bundle entries are
# ignored: the catalog filter governs commands + agents only.
module_owned_item_names() {
    local catalog="${1:?catalog required}" m p base
    while IFS= read -r m; do
        while IFS= read -r p; do
            # Only .md files under .claude/<catalog>/ (case '*' spans '/').
            case "$p" in
                .claude/"$catalog"/*.md) ;;
                *) continue ;;
            esac
            base="${p##*/}"
            printf '%s\n' "${base%.md}"
        done < <(module_bundle_paths "$m")
    done < <(modules_list) | LC_ALL=C sort -u
}

# module_of_item <catalog> <name> — print the module that owns the <catalog>
# (commands|agents) item named <name>, or nothing if no module owns it. Used by
# validate-presets to name the owning module in a rejection message (EF-406).
module_of_item() {
    local catalog="${1:?catalog required}" name="${2:?name required}" m p base
    while IFS= read -r m; do
        while IFS= read -r p; do
            case "$p" in
                .claude/"$catalog"/*.md) ;;
                *) continue ;;
            esac
            base="${p##*/}"
            if [ "${base%.md}" = "$name" ]; then
                printf '%s\n' "$m"
                return 0
            fi
        done < <(module_bundle_paths "$m")
    done < <(modules_list)
    return 0
}

# -----------------------------------------------------------------------------
# Project manifest (.claude/foundation.json) — EF-204
# Single source of truth for a project's foundation state:
#   { "version": "...", "preset": "..."|null, "tier": "full"|"minimal", "modules": [...] }
# Replaces the legacy .claude/.foundation-version marker (EF-205).
# -----------------------------------------------------------------------------

# Internal: manifest path for a target project dir.
_manifest_path() {
    printf '%s/.claude/foundation.json' "${1:?target dir required}"
}

# write_foundation_manifest <dir> <version> <preset-or-empty> [modules...]
# Single jq invocation, atomic tmp+mv write: a failing jq can never leave a
# partial manifest behind, and a non-file squatting the destination path is
# refused instead of being silently written into.
# Install tier (C2 audit — minimal vs full): the manifest carries a "tier"
# field. It is NOT positional (modules are varargs); instead:
#   - MANIFEST_TIER env, when set, wins (used by init --minimal);
#   - else an existing manifest's tier is PRESERVED (so module add/remove and
#     version-stamp rewrites never silently graduate a minimal install);
#   - else it defaults to "full".
write_foundation_manifest() {
    local dir="${1:?target dir required}" version="${2:?version required}"
    local preset="${3:-}"
    shift 3 || shift $#
    local manifest
    manifest="$(_manifest_path "$dir")"
    if [[ -e "$manifest" && ! -f "$manifest" ]]; then
        printf 'modules: refusing to write manifest: %s exists and is not a regular file\n' \
            "$manifest" >&2
        return 1
    fi
    local tier="${MANIFEST_TIER:-}"
    if [[ -z "$tier" && -f "$manifest" ]]; then
        tier="$(jq -r '.tier // empty' "$manifest" 2>/dev/null)" || tier=""
    fi
    if [[ -z "$tier" ]]; then
        tier="full"
    fi
    # Project type (the stack the install picked its rules for). Same
    # non-positional mechanism as tier: MANIFEST_PROJECT_TYPE wins, else an
    # existing value is preserved, else the key is OMITTED — absent means
    # "legacy install, type unknown" and updates keep their old behaviour.
    local ptype="${MANIFEST_PROJECT_TYPE:-}"
    if [[ -z "$ptype" && -f "$manifest" ]]; then
        ptype="$(jq -r '.projectType // empty' "$manifest" 2>/dev/null)" || ptype=""
    fi
    mkdir -p "$dir/.claude" || return 1
    local tmp
    tmp="$(mktemp)" || return 1
    # Modules arrive as positional args ($ARGS.positional — safe escaping);
    # an empty preset maps to null.
    if ! jq -n \
        --arg version "$version" \
        --arg preset_str "$preset" \
        --arg tier "$tier" \
        --arg ptype "$ptype" \
        --args \
        '{version: $version,
          preset: (if $preset_str == "" then null else $preset_str end),
          tier: $tier,
          modules: ($ARGS.positional | map(select(length > 0)))}
         + (if $ptype == "" then {} else {projectType: $ptype} end)' \
        "$@" > "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    mv "$tmp" "$manifest" || { rm -f "$tmp"; return 1; }
}

# read_foundation_manifest <dir> — print the manifest JSON.
# Returns 1 (silent) if missing; fails loud on corrupted JSON with a
# repair hint (EF: corrupted manifest is a loud error, never silent).
read_foundation_manifest() {
    local dir="${1:?target dir required}"
    local file
    file="$(_manifest_path "$dir")"
    [[ -f "$file" ]] || return 1
    if ! jq . "$file" 2>/dev/null; then
        printf 'modules: corrupted manifest: %s\nRun a foundation update to regenerate it, or fix the JSON by hand.\n' \
            "$file" >&2
        return 2
    fi
}

# manifest_tier <dir> — print the recorded install tier ("minimal" or "full").
# Pre-tier manifests default to "full" (they were full installs by
# construction — export-minimal never wrote a manifest before the tier field).
# Propagates read_foundation_manifest's status (1 missing, 2 corrupted).
manifest_tier() {
    local json
    json="$(read_foundation_manifest "${1:?target dir required}")" || return $?
    jq -r '.tier // "full"' <<<"$json"
}

# set_manifest_tier <dir> <tier> — rewrite ONLY the .tier field (atomic).
# Used by update --graduate-full to record the deliberate minimal -> full
# conversion. Returns 1 if the manifest is missing or jq fails.
set_manifest_tier() {
    local dir="${1:?target dir required}" tier="${2:?tier required}"
    local manifest
    manifest="$(_manifest_path "$dir")"
    [[ -f "$manifest" ]] || return 1
    local tmp
    tmp="$(mktemp)" || return 1
    if ! jq --arg tier "$tier" '.tier = $tier' "$manifest" > "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    mv "$tmp" "$manifest" || { rm -f "$tmp"; return 1; }
}

# manifest_project_type <dir> — print the recorded stack type, empty when the
# field is absent (legacy install predating it). Callers MUST treat empty as
# "unknown" and fall back to their pre-existing behaviour, never as "generic".
manifest_project_type() {
    local json
    json="$(read_foundation_manifest "${1:?target dir required}")" || return $?
    jq -r '.projectType // empty' <<<"$json"
}

# manifest_preset <dir> — print the recorded preset name, empty if null/missing.
manifest_preset() {
    local json
    json="$(read_foundation_manifest "${1:?target dir required}")" || return $?
    jq -r '.preset // empty' <<<"$json"
}

# manifest_modules <dir> — print recorded modules, one per line, filtered to
# known modules. Unknown names emit a warning to stderr and are ignored
# (never fatal — a manifest written by a newer foundation must not brick
# an older one).
manifest_modules() {
    local dir="${1:?target dir required}"
    local json m
    json="$(read_foundation_manifest "$dir")" || return $?
    while IFS= read -r m; do
        [[ -z "$m" ]] && continue
        if module_exists "$m"; then
            printf '%s\n' "$m"
        else
            printf 'modules: warning: unknown module in manifest, ignored: %s\n' "$m" >&2
        fi
    done < <(jq -r '.modules[]? // empty' <<<"$json")
}

# manifest_has_module <dir> <name> — 0 if <name> is recorded in the manifest.
manifest_has_module() {
    local dir="${1:?target dir required}" name="${2:?module name required}"
    local m
    while IFS= read -r m; do
        [[ "$m" == "$name" ]] && return 0
    done < <(manifest_modules "$dir" 2>/dev/null)
    return 1
}

# -----------------------------------------------------------------------------
# Legacy marker migration — EF-205 (direct replacement, decided 2026-06-06)
# -----------------------------------------------------------------------------

# detect_legacy_modules <dir> — print the module set a legacy-marker
# migration would record, one per line. Pure read (no writes): lets a
# dry-run preview the exact post-migration filtering without migrating.
# Detectable state (EF-205): a module is recorded iff at least one of its
# bundle paths exists in the project (handles legacy minimal installs that
# never shipped biz/legal/growth). When nothing is detectable (no commands
# dir at all), assume the full default set — conservative: a legacy
# standard install shipped the whole catalog.
detect_legacy_modules() {
    local dir="${1:?target dir required}"
    local m p
    if [[ -d "$dir/.claude/commands" ]]; then
        while IFS= read -r m; do
            while IFS= read -r p; do
                if [[ -e "$dir/$p" ]]; then
                    printf '%s\n' "$m"
                    break
                fi
            done < <(module_bundle_paths "$m")
        done < <(modules_list)
    else
        modules_default_set
    fi
}

# migrate_legacy_marker <dir> — if no manifest exists but the legacy
# .claude/.foundation-version marker does, create the manifest from it
# (version from marker, no preset, modules from detect_legacy_modules)
# and remove the marker.
# No-op (status 0) when there is nothing to migrate or already migrated.
migrate_legacy_marker() {
    local dir="${1:?target dir required}"
    local marker="$dir/.claude/.foundation-version"
    local manifest
    manifest="$(_manifest_path "$dir")"
    if [[ -f "$manifest" ]]; then
        # Already on the manifest; drop a stale marker if one lingers.
        [[ -f "$marker" ]] && rm -f "$marker"
        return 0
    fi
    [[ -f "$marker" ]] || return 0
    local version
    version="$(head -n1 "$marker" | tr -d '[:space:]')"
    if [[ -z "$version" ]]; then
        # "unknown" would defeat version_gte comparisons downstream;
        # 0.0.0 sorts below every real release and stays honest.
        version="0.0.0"
        printf 'modules: warning: legacy marker has no readable version, migrating as 0.0.0\n' >&2
    fi
    local mods=()
    local m
    while IFS= read -r m; do
        mods+=("$m")
    done < <(detect_legacy_modules "$dir")
    # Empty-safe expansion: mods can be empty (detect_legacy_modules falls back
    # to modules_default_set, which is empty since v3) — "${mods[@]}" aborts
    # under `set -u` on bash < 4.4 (empty-array expansion bug, fixed in 4.4;
    # the foundation supports bash 4.0+, so the guard is still needed).
    write_foundation_manifest "$dir" "$version" "" ${mods[@]+"${mods[@]}"} || return 1
    rm -f "$marker"
    printf 'modules: migrated legacy version marker to .claude/foundation.json (v%s, modules: %s)\n' \
        "$version" "${mods[*]:-none}"
}
