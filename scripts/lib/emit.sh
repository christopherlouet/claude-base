#!/usr/bin/env bash
# =============================================================================
# emit.sh — manifest-driven copy emitter (P2 seam S2, specs/agnostic-core/)
# =============================================================================
# Extracted verbatim from export-minimal.sh so BOTH the minimal export and the
# full install consume one emitter. Grammar (minimal-manifest.txt): one
# repo-relative path per line, `#` comments, blank lines, trailing `/` = whole
# directory (recursive `cp -RP src/.`), `SRC:DST` remap with exactly one `:`,
# no absolute paths, no `..`, sources must resolve inside <src_root> (blocks
# outgoing symlinks).
#
#   emit_manifest <manifest-file|-> <src_root> <dest_root>
#     '-' reads the manifest from stdin (the generated selected-set pipes in).
#     Success: return 0, EMIT_COUNT holds the number of entries copied.
#     Failure: '[error] …' on stderr, return 1 (a set -e caller dies, matching
#     the old inline die()).
#
# Installer-side library — not shipped to target projects, not a hook.
# macOS bash 3.2 compatible.
# =============================================================================

if [ -n "${EMIT_LIB_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
EMIT_LIB_LOADED=1

EMIT_COUNT=0

_emit_err() {
  printf '[error] %s\n' "$*" >&2
  return 1
}

# Validates a manifest entry: no .., no absolute path.
emit_validate_entry() {
  local entry="$1"
  if [[ "$entry" = /* ]]; then
    _emit_err "manifest: absolute path forbidden: $entry"
    return 1
  fi
  if [[ "$entry" =~ (^|/)\.\.($|/) ]]; then
    _emit_err "manifest: path traversal forbidden: $entry"
    return 1
  fi
}

# Resolves an absolute, symlink-resolved path. Portable across GNU/Linux
# (readlink -f) and macOS/BSD (no -f flag). Uses python3 as the most
# universally preinstalled fallback.
emit_resolve_path() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath -- "$p" 2>/dev/null
  elif readlink -f -- "$p" >/dev/null 2>&1; then
    readlink -f -- "$p"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$p" 2>/dev/null
  else
    # Last resort: manual cd/pwd. Works for existing files/dirs only.
    if [ -d "$p" ]; then
      (cd "$p" && pwd -P)
    elif [ -f "$p" ]; then
      printf '%s/%s\n' "$(cd "$(dirname "$p")" && pwd -P)" "$(basename "$p")"
    fi
  fi
}

# Verifies that the resolved source stays under <src_root> (blocks outgoing symlinks).
emit_assert_within_root() {
  local src_path="$1" src_root="$2"
  local resolved
  resolved="$(cd "$src_root" && emit_resolve_path "$src_path" || true)"
  if [ -z "$resolved" ] || [[ "$resolved" != "$src_root"/* && "$resolved" != "$src_root" ]]; then
    _emit_err "source outside the repo (outgoing symlink?): $src_path -> ${resolved:-unresolved}"
    return 1
  fi
}

emit_manifest() {
  local manifest="$1" src_root="${2%/}" dest_root="${3%/}"
  local raw_line line src dst colons_only src_path dst_path dst_parent
  EMIT_COUNT=0

  local _input="$manifest"
  if [ "$manifest" = "-" ]; then
    _input=/dev/stdin
  elif [ ! -f "$manifest" ]; then
    _emit_err "manifest not found: $manifest"
    return 1
  fi

  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    line="${raw_line#"${raw_line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [ -z "$line" ] && continue
    case "$line" in
      \#*) continue ;;
    esac

    # Reject CRLF
    line="${line%$'\r'}"

    src="$line"
    dst="$line"
    if [[ "$line" == *:* ]]; then
      # Reject more than one ":" to avoid smuggling an intermediate segment.
      colons_only="${line//[^:]/}"
      if [ "${#colons_only}" -gt 1 ]; then
        _emit_err "manifest: more than one ':' in the line (ambiguous): $line"
        return 1
      fi
      src="${line%%:*}"
      dst="${line#*:}"
    fi

    emit_validate_entry "$src" || return 1
    emit_validate_entry "$dst" || return 1

    src_path="$src_root/${src%/}"
    dst_path="$dest_root/${dst%/}"

    if [ ! -e "$src_path" ]; then
      _emit_err "manifest: path not found in the repo: $src"
      return 1
    fi

    emit_assert_within_root "$src_path" "$src_root" || return 1

    dst_parent="$(dirname "$dst_path")"
    mkdir -p "$dst_parent"

    if [ -d "$src_path" ]; then
      mkdir -p "$dst_path"
      cp -RP "$src_path/." "$dst_path/"
    else
      cp -P "$src_path" "$dst_path"
    fi

    EMIT_COUNT=$((EMIT_COUNT + 1))
  done < "$_input"
  return 0
}
