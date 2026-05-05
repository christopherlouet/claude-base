#!/usr/bin/env bash
# Exports a minimal Claude Code foundation configuration to a .tar.gz archive.
#
# Usage:
#   scripts/export-minimal.sh [--output PATH] [--dest-dir PATH] [--help]
#
# --output PATH   : path of the archive to produce (default: dist/claude-base-minimal.tar.gz)
# --dest-dir PATH : copy files directly into a target folder (no archive)
#                   (internal usage for `new-project.sh --minimal`)
# --help          : display this help

set -euo pipefail

# =============================================================================
# Paths and constants
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$SCRIPT_DIR/lib/minimal-manifest.txt"
CLAUDE_MD_TEMPLATE="$SCRIPT_DIR/lib/minimal-claude-md.template"
ARCHIVE_PREFIX="claude-base-minimal"
DEFAULT_OUTPUT="$REPO_ROOT/dist/${ARCHIVE_PREFIX}.tar.gz"

# =============================================================================
# Helpers
# =============================================================================

die() {
  printf '[error] %s\n' "$*" >&2
  exit 1
}

info() {
  printf '[info] %s\n' "$*"
}

show_help() {
  sed -nE 's/^# ?//p' "$0" | sed -nE '/^Usage/,/^$/p'
}

# Validates a path: absolute OK, relative OK, refuses .. in the path.
# Must not point outside the repo if relative.
validate_output_path() {
  local path="$1"
  if [[ "$path" =~ (^|/)\.\.($|/) ]]; then
    die "invalid --output path (path traversal detected): $path"
  fi
}

# Validates a manifest entry: no .., no absolute path.
validate_manifest_entry() {
  local entry="$1"
  if [[ "$entry" = /* ]]; then
    die "manifest: absolute path forbidden: $entry"
  fi
  if [[ "$entry" =~ (^|/)\.\.($|/) ]]; then
    die "manifest: path traversal forbidden: $entry"
  fi
}

# Resolves an absolute, symlink-resolved path. Portable across GNU/Linux
# (readlink -f) and macOS/BSD (no -f flag). Uses python3 as the most
# universally preinstalled fallback.
resolve_path() {
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

# Verifies that the resolved source stays under REPO_ROOT (blocks outgoing symlinks).
assert_within_repo() {
  local src_path="$1"
  local resolved
  resolved="$(cd "$REPO_ROOT" && resolve_path "$src_path" || true)"
  if [ -z "$resolved" ] || [[ "$resolved" != "$REPO_ROOT"/* && "$resolved" != "$REPO_ROOT" ]]; then
    die "source outside the repo (outgoing symlink?): $src_path -> ${resolved:-unresolved}"
  fi
}

# =============================================================================
# Args
# =============================================================================

OUTPUT=""
DEST_DIR=""
MANIFEST_OVERRIDE=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --output)
      [ $# -ge 2 ] || die "--output expects an argument"
      OUTPUT="$2"
      shift 2
      ;;
    --dest-dir)
      [ $# -ge 2 ] || die "--dest-dir expects an argument"
      DEST_DIR="$2"
      shift 2
      ;;
    --manifest)
      [ $# -ge 2 ] || die "--manifest expects an argument"
      MANIFEST_OVERRIDE="$2"
      shift 2
      ;;
    *)
      die "unknown argument: $1 (see --help)"
      ;;
  esac
done

if [ -n "$MANIFEST_OVERRIDE" ]; then
  MANIFEST_FILE="$MANIFEST_OVERRIDE"
fi

if [ -n "$OUTPUT" ] && [ -n "$DEST_DIR" ]; then
  die "--output and --dest-dir are mutually exclusive"
fi

if [ -z "$OUTPUT" ] && [ -z "$DEST_DIR" ]; then
  OUTPUT="$DEFAULT_OUTPUT"
fi

if [ -n "$OUTPUT" ]; then
  validate_output_path "$OUTPUT"
fi

# =============================================================================
# Sanity checks
# =============================================================================

[ -f "$MANIFEST_FILE" ] || die "manifest not found: $MANIFEST_FILE"
[ -f "$CLAUDE_MD_TEMPLATE" ] || die "CLAUDE.md template not found: $CLAUDE_MD_TEMPLATE"
command -v tar >/dev/null 2>&1 || die "tar missing from PATH"

# =============================================================================
# Staging dir (temp or final dest-dir)
# =============================================================================

STAGING=""
USE_TEMP_STAGING=false

cleanup_staging() {
  local rc=$?
  if $USE_TEMP_STAGING && [ -n "${STAGING:-}" ] && [ -d "$STAGING" ]; then
    rm -rf "$STAGING"
  fi
  exit "$rc"
}

if [ -n "$DEST_DIR" ]; then
  mkdir -p "$DEST_DIR"
  STAGING="$(cd "$DEST_DIR" && pwd)"
  info "staging: $STAGING"
else
  STAGING="$(mktemp -d -t "${ARCHIVE_PREFIX}-XXXXXX")"
  USE_TEMP_STAGING=true
  trap cleanup_staging EXIT INT TERM HUP
  info "staging: $STAGING"
fi

# =============================================================================
# Manifest parsing + copy
# =============================================================================

count=0
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
      die "manifest: more than one ':' in the line (ambiguous): $line"
    fi
    src="${line%%:*}"
    dst="${line#*:}"
  fi

  validate_manifest_entry "$src"
  validate_manifest_entry "$dst"

  src_path="$REPO_ROOT/$src"
  dst_path="$STAGING/${dst%/}"

  if [ ! -e "$src_path" ]; then
    die "manifest: path not found in the repo: $src"
  fi

  assert_within_repo "$src_path"

  dst_parent="$(dirname "$dst_path")"
  mkdir -p "$dst_parent"

  if [ -d "$src_path" ]; then
    mkdir -p "$dst_path"
    cp -RP "$src_path/." "$dst_path/"
  else
    cp -P "$src_path" "$dst_path"
  fi

  count=$((count + 1))
done < "$MANIFEST_FILE"

# Simplified CLAUDE.md (fixed template, not the repo's original)
cp "$CLAUDE_MD_TEMPLATE" "$STAGING/CLAUDE.md"
count=$((count + 1))

info "$count entries staged"

# =============================================================================
# Archive (if --output mode)
# =============================================================================

if [ -z "$DEST_DIR" ]; then
  mkdir -p "$(dirname "$OUTPUT")"

  parent_of_staging="$(dirname "$STAGING")"
  name_of_staging="$(basename "$STAGING")"

  # tar --transform renames the root on the fly (no mv, no TOCTOU window).
  # Reproducible options: uid/gid 0, fixed mtime, sort by name.
  tar \
    --owner=0 --group=0 --numeric-owner \
    --mtime='2024-01-01 00:00:00 UTC' \
    --sort=name \
    --transform "s,^${name_of_staging},${ARCHIVE_PREFIX}," \
    -czf "$OUTPUT" \
    -C "$parent_of_staging" "$name_of_staging"

  size_bytes=$(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT")
  size_kb=$((size_bytes / 1024))

  info "archive: $OUTPUT"
  info "size   : ${size_kb} KB (${size_bytes} bytes)"
  info "content: $count entries + simplified CLAUDE.md"
else
  info "files copied to $STAGING"
fi
