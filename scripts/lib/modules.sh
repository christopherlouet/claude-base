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
