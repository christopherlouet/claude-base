#!/usr/bin/env bash
# Exporte une configuration minimale du socle Claude Code vers une archive .tar.gz.
#
# Usage:
#   scripts/export-minimal.sh [--output PATH] [--dest-dir PATH] [--help]
#
# --output PATH   : chemin de l'archive a produire (defaut: dist/claude-socle-minimal.tar.gz)
# --dest-dir PATH : copie directement les fichiers dans un dossier cible (pas d'archive)
#                   (usage interne pour `new-project.sh --minimal`)
# --help          : affiche cette aide

set -euo pipefail

# =============================================================================
# Paths et constantes
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$SCRIPT_DIR/lib/minimal-manifest.txt"
CLAUDE_MD_TEMPLATE="$SCRIPT_DIR/lib/minimal-claude-md.template"
ARCHIVE_PREFIX="claude-socle-minimal"
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

# Valide un chemin : absolu OK, relatif OK, refuse les .. dans le chemin.
# Ne doit pas pointer hors du repo si relatif.
validate_output_path() {
  local path="$1"
  if [[ "$path" =~ (^|/)\.\.($|/) ]]; then
    die "chemin --output invalide (path traversal detecte) : $path"
  fi
}

# Valide une entree du manifest : pas de .., pas de chemin absolu.
validate_manifest_entry() {
  local entry="$1"
  if [[ "$entry" = /* ]]; then
    die "manifest : chemin absolu interdit : $entry"
  fi
  if [[ "$entry" =~ (^|/)\.\.($|/) ]]; then
    die "manifest : path traversal interdit : $entry"
  fi
}

# Verifie que la source resolue reste sous REPO_ROOT (blocage symlinks sortants).
assert_within_repo() {
  local src_path="$1"
  local resolved
  resolved="$(cd "$REPO_ROOT" && readlink -f -- "$src_path" 2>/dev/null || true)"
  if [ -z "$resolved" ] || [[ "$resolved" != "$REPO_ROOT"/* && "$resolved" != "$REPO_ROOT" ]]; then
    die "source hors du repo (symlink sortant ?) : $src_path -> ${resolved:-unresolved}"
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
      [ $# -ge 2 ] || die "--output attend un argument"
      OUTPUT="$2"
      shift 2
      ;;
    --dest-dir)
      [ $# -ge 2 ] || die "--dest-dir attend un argument"
      DEST_DIR="$2"
      shift 2
      ;;
    --manifest)
      [ $# -ge 2 ] || die "--manifest attend un argument"
      MANIFEST_OVERRIDE="$2"
      shift 2
      ;;
    *)
      die "argument inconnu : $1 (voir --help)"
      ;;
  esac
done

if [ -n "$MANIFEST_OVERRIDE" ]; then
  MANIFEST_FILE="$MANIFEST_OVERRIDE"
fi

if [ -n "$OUTPUT" ] && [ -n "$DEST_DIR" ]; then
  die "--output et --dest-dir sont mutuellement exclusifs"
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

[ -f "$MANIFEST_FILE" ] || die "manifest introuvable : $MANIFEST_FILE"
[ -f "$CLAUDE_MD_TEMPLATE" ] || die "template CLAUDE.md introuvable : $CLAUDE_MD_TEMPLATE"
command -v tar >/dev/null 2>&1 || die "tar absent du PATH"

# =============================================================================
# Staging dir (temp ou dest-dir final)
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
  info "staging : $STAGING"
else
  STAGING="$(mktemp -d -t "${ARCHIVE_PREFIX}-XXXXXX")"
  USE_TEMP_STAGING=true
  trap cleanup_staging EXIT INT TERM HUP
  info "staging : $STAGING"
fi

# =============================================================================
# Parsing du manifest + copie
# =============================================================================

count=0
while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  line="${raw_line#"${raw_line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [ -z "$line" ] && continue
  case "$line" in
    \#*) continue ;;
  esac

  # Rejet CRLF
  line="${line%$'\r'}"

  src="$line"
  dst="$line"
  if [[ "$line" == *:* ]]; then
    # Refuser plus d'un ":" pour eviter le smuggling d'un segment intermediaire.
    colons_only="${line//[^:]/}"
    if [ "${#colons_only}" -gt 1 ]; then
      die "manifest : plus d'un ':' dans la ligne (ambigue) : $line"
    fi
    src="${line%%:*}"
    dst="${line#*:}"
  fi

  validate_manifest_entry "$src"
  validate_manifest_entry "$dst"

  src_path="$REPO_ROOT/$src"
  dst_path="$STAGING/${dst%/}"

  if [ ! -e "$src_path" ]; then
    die "manifest : chemin introuvable dans le repo : $src"
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

# CLAUDE.md simplifie (template fixe, pas l'original du repo)
cp "$CLAUDE_MD_TEMPLATE" "$STAGING/CLAUDE.md"
count=$((count + 1))

info "$count entrees stagees"

# =============================================================================
# Archive (si mode --output)
# =============================================================================

if [ -z "$DEST_DIR" ]; then
  mkdir -p "$(dirname "$OUTPUT")"

  parent_of_staging="$(dirname "$STAGING")"
  name_of_staging="$(basename "$STAGING")"

  # tar --transform renomme la racine a la volee (pas de mv, pas de fenetre TOCTOU).
  # Options reproductibles : uid/gid 0, mtime fixe, tri par nom.
  tar \
    --owner=0 --group=0 --numeric-owner \
    --mtime='2024-01-01 00:00:00 UTC' \
    --sort=name \
    --transform "s,^${name_of_staging},${ARCHIVE_PREFIX}," \
    -czf "$OUTPUT" \
    -C "$parent_of_staging" "$name_of_staging"

  size_bytes=$(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT")
  size_kb=$((size_bytes / 1024))

  info "archive : $OUTPUT"
  info "taille  : ${size_kb} KB (${size_bytes} octets)"
  info "contenu : $count entrees + CLAUDE.md simplifie"
else
  info "fichiers copies dans $STAGING"
fi
