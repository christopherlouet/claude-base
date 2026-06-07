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
# Portability: macOS bash 3.2 — no associative arrays, no readarray.
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
# project, legacy migration fallback). Full catalog at v1; preset
# defaultModules (US-5) will hook in here so every call site inherits it.
modules_default_set() {
    modules_list
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

# path_module <repo-relative-path> — print the module name that owns <path>,
# or print nothing (empty) if the path is a core foundation item not owned
# by any optional module bundle.
# Used by update.sh to decide whether a file should be skipped when its
# owning module is absent from the project manifest.
path_module() {
    local path="${1:-}"
    [[ -n "$path" ]] || return 0
    local m
    while IFS= read -r m; do
        local p
        while IFS= read -r p; do
            # Directory entry (trailing /): check if path starts with it.
            if [[ "$p" == */ ]]; then
                [[ "$path" == "${p%/}"/* || "$path" == "${p%/}" ]] && { printf '%s\n' "$m"; return 0; }
            else
                [[ "$path" == "$p" ]] && { printf '%s\n' "$m"; return 0; }
            fi
        done < <(module_bundle_paths "$m")
    done < <(modules_list)
    # Not owned by any module — it is a core path.
    return 0
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

# -----------------------------------------------------------------------------
# Project manifest (.claude/foundation.json) — EF-204
# Single source of truth for a project's foundation state:
#   { "version": "...", "preset": "..."|null, "modules": [...] }
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
    mkdir -p "$dir/.claude" || return 1
    local tmp
    tmp="$(mktemp)" || return 1
    # Modules arrive as positional args ($ARGS.positional — safe escaping);
    # an empty preset maps to null.
    if ! jq -n \
        --arg version "$version" \
        --arg preset_str "$preset" \
        --args \
        '{version: $version,
          preset: (if $preset_str == "" then null else $preset_str end),
          modules: ($ARGS.positional | map(select(length > 0)))}' \
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
    write_foundation_manifest "$dir" "$version" "" "${mods[@]}" || return 1
    rm -f "$marker"
    printf 'modules: migrated legacy version marker to .claude/foundation.json (v%s, modules: %s)\n' \
        "$version" "${mods[*]:-none}"
}
