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

# --- Batched resolution cache for the outgoing-symlink guard ------------------
# emit_assert_within_root runs once per manifest entry (~154 on a full install)
# and each call forked realpath — the single biggest cost left in an emit. The
# resolutions are independent, so they are computed in ONE realpath call up
# front and looked up here.
#
# This is an optimisation ONLY. The cache never decides anything: a lookup miss
# falls through to the original per-entry resolve, so the guard's verdict and —
# just as important — the ORDER in which emit_manifest aborts are unchanged. A
# batch that comes back the wrong length (a realpath that does not take multiple
# operands) is discarded wholesale rather than trusted partially.
_EMIT_RES_N=0
_EMIT_RES_SRC=()
_EMIT_RES_OUT=()
_EMIT_RES_CURSOR=0

_emit_resolve_reset() { _EMIT_RES_N=0; _EMIT_RES_SRC=(); _EMIT_RES_OUT=(); _EMIT_RES_CURSOR=0; }

# _emit_resolve_batch <path>... — fill the cache in one realpath call.
# Silently leaves the cache empty when batching is not possible; callers then
# resolve per entry exactly as before.
_emit_resolve_batch() {
  [ "$#" -gt 0 ] || return 0
  command -v realpath >/dev/null 2>&1 || return 0
  local out n=0 line
  out=$(realpath -- "$@" 2>/dev/null) || return 0
  while IFS= read -r line; do
    _EMIT_RES_OUT[n]="$line"
    n=$((n + 1))
  done <<< "$out"
  # One output line per input, or the tool did not batch the way we assumed.
  if [ "$n" -ne "$#" ]; then _emit_resolve_reset; return 0; fi
  local i=0
  for line in "$@"; do
    _EMIT_RES_SRC[i]="$line"
    i=$((i + 1))
  done
  _EMIT_RES_N="$n"
}

# _emit_resolve_lookup <path> — set _EMIT_RES_HIT to the cached resolution.
# Returns 1 on a miss. Result travels through a variable, never stdout: a
# command substitution here would fork per entry and give back exactly the cost
# the batch exists to remove.
# The cursor exploits the fact that lookups arrive in the order the cache was
# filled; the linear scan is the correctness net, not the expected path.
_EMIT_RES_HIT=""
_emit_resolve_lookup() {
  local q="$1" i
  _EMIT_RES_HIT=""
  if [ "$_EMIT_RES_CURSOR" -lt "$_EMIT_RES_N" ] && [ "${_EMIT_RES_SRC[_EMIT_RES_CURSOR]}" = "$q" ]; then
    _EMIT_RES_HIT="${_EMIT_RES_OUT[_EMIT_RES_CURSOR]}"
    _EMIT_RES_CURSOR=$((_EMIT_RES_CURSOR + 1))
    return 0
  fi
  for (( i = 0; i < _EMIT_RES_N; i++ )); do
    if [ "${_EMIT_RES_SRC[i]}" = "$q" ]; then
      _EMIT_RES_HIT="${_EMIT_RES_OUT[i]}"
      _EMIT_RES_CURSOR=$((i + 1))
      return 0
    fi
  done
  return 1
}

# Verifies that the resolved source stays under <src_root> (blocks outgoing symlinks).
emit_assert_within_root() {
  local src_path="$1" src_root="$2"
  local resolved
  if _emit_resolve_lookup "$src_path"; then
    resolved="$_EMIT_RES_HIT"
  else
    resolved="$(cd "$src_root" && emit_resolve_path "$src_path" || true)"
  fi
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

  # Buffer the manifest: it may be stdin (readable once), and the symlink-guard
  # pre-pass below needs a second look at the same lines.
  local _buf=() _n=0
  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    _buf[_n]="$raw_line"
    _n=$((_n + 1))
  done < "$_input"

  # Pre-pass: resolve every existing source in ONE realpath call. Parsing here
  # is deliberately permissive — it collects candidates and reports nothing.
  # Every rejection (bad entry, missing path, escaping symlink) still happens in
  # the main loop below, in the same order as before, so a malformed manifest
  # aborts at exactly the entry it always did.
  _emit_resolve_reset
  local _pre=() _pn=0 _i _l _s
  for (( _i = 0; _i < _n; _i++ )); do
    _l="${_buf[_i]}"
    _l="${_l#"${_l%%[![:space:]]*}"}"
    _l="${_l%"${_l##*[![:space:]]}"}"
    _l="${_l%$'\r'}"
    [ -z "$_l" ] && continue
    case "$_l" in \#*) continue ;; esac
    _s="${_l%%:*}"
    _s="$src_root/${_s%/}"
    [ -e "$_s" ] || continue
    _pre[_pn]="$_s"
    _pn=$((_pn + 1))
  done
  [ "$_pn" -gt 0 ] && _emit_resolve_batch ${_pre[@]+"${_pre[@]}"}

  for (( _i = 0; _i < _n; _i++ )); do
    raw_line="${_buf[_i]}"
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

    # Parameter expansion, not dirname(1): this runs once per manifest entry
    # (~154 on a full install), and a fork a time is pure overhead. `%/*` on a
    # path with no slash yields the string unchanged, so fall back to "." the
    # way dirname would.
    dst_parent="${dst_path%/*}"
    [ "$dst_parent" = "$dst_path" ] && dst_parent="."
    # Entries share parents heavily (every .claude/commands/<ns>/*.md lands in
    # one of a handful of dirs), so test before forking mkdir. [ -d ] is a
    # builtin; mkdir is not.
    [ -d "$dst_parent" ] || mkdir -p "$dst_parent"

    if [ -d "$src_path" ]; then
      mkdir -p "$dst_path"
      cp -RP "$src_path/." "$dst_path/"
    else
      cp -P "$src_path" "$dst_path"
    fi

    EMIT_COUNT=$((EMIT_COUNT + 1))
  done
  return 0
}
