#!/usr/bin/env bats

# Tests smoke pour le mode export minimal du socle.
# Couvre : manifest integrity, --minimal flag de new-project.sh, export-minimal.sh archive.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  MANIFEST="$REPO_ROOT/scripts/lib/minimal-manifest.txt"
  EXPORT_SCRIPT="$REPO_ROOT/scripts/export-minimal.sh"
  NEW_PROJECT="$REPO_ROOT/scripts/new-project.sh"
  TMP_DIR="$(mktemp -d -t socle-minimal-test-XXXXXX)"
}

teardown() {
  if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

# =============================================================================
# Manifest
# =============================================================================

@test "manifest: fichier existe" {
  [ -f "$MANIFEST" ]
}

@test "manifest: contient au moins 20 entrees non-commentaires" {
  local count
  count=$(grep -cvE '^\s*(#|$)' "$MANIFEST")
  [ "$count" -ge 20 ]
}

@test "manifest: chaque chemin existe dans le repo" {
  local missing=()
  while IFS= read -r line; do
    [[ "$line" =~ ^\s*$ ]] && continue
    [[ "$line" =~ ^\s*# ]] && continue
    # Supporter la syntaxe SRC:DST — ne valider que SRC dans le repo
    local src="${line%%:*}"
    src="${src%/}"
    if [ ! -e "$REPO_ROOT/$src" ]; then
      missing+=("$src")
    fi
  done < "$MANIFEST"

  if [ "${#missing[@]}" -gt 0 ]; then
    printf 'Missing paths:\n'
    printf '  %s\n' "${missing[@]}"
    return 1
  fi
}

@test "manifest: contient les commandes essentielles" {
  grep -qE '^\.claude/commands/assistant\.md$' "$MANIFEST"
  grep -qE '^\.claude/commands/work/work-explore\.md$' "$MANIFEST"
  grep -qE '^\.claude/commands/dev/dev-tdd\.md$' "$MANIFEST"
  grep -qE '^\.claude/commands/qa/qa-audit\.md$' "$MANIFEST"
}

@test "manifest: contient les rules essentielles" {
  grep -qE '^\.claude/rules/workflow\.md$' "$MANIFEST"
  grep -qE '^\.claude/rules/tdd-enforcement\.md$' "$MANIFEST"
  grep -qE '^\.claude/rules/security\.md$' "$MANIFEST"
}

@test "manifest: inclut au moins un skill (dir avec SKILL.md)" {
  grep -qE '^\.claude/skills/[a-z-]+/?$' "$MANIFEST"
}

# =============================================================================
# export-minimal.sh
# =============================================================================

@test "export-minimal.sh: script executable" {
  [ -x "$EXPORT_SCRIPT" ]
}

@test "export-minimal.sh: --help retourne 0 et affiche usage" {
  run "$EXPORT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ [Uu]sage ]]
}

@test "export-minimal.sh: produit une archive .tar.gz" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIR/test.tar.gz" ]
  [ -s "$TMP_DIR/test.tar.gz" ]
}

@test "export-minimal.sh: archive taille < 500 KB" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  local size
  size=$(stat -c%s "$TMP_DIR/test.tar.gz" 2>/dev/null || stat -f%z "$TMP_DIR/test.tar.gz")
  [ "$size" -lt 512000 ]
}

@test "export-minimal.sh: archive contient CLAUDE.md en racine" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '^claude-socle-minimal/CLAUDE\.md$'
}

@test "export-minimal.sh: archive contient .claude/commands/assistant.md" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '^claude-socle-minimal/\.claude/commands/assistant\.md$'
}

@test "export-minimal.sh: archive contient .claude/settings.json" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '^claude-socle-minimal/\.claude/settings\.json$'
}

@test "export-minimal.sh: archive contient au moins un skill complet (SKILL.md)" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '^claude-socle-minimal/\.claude/skills/[a-z-]+/SKILL\.md$'
}

@test "export-minimal.sh: archive n'inclut PAS les domaines exclus (biz, growth, legal)" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/test.tar.gz"
  [ "$status" -eq 0 ]
  ! tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '\.claude/commands/(biz|growth|legal)/'
  ! tar -tzf "$TMP_DIR/test.tar.gz" | grep -qE '\.claude/agents/biz-'
}

@test "export-minimal.sh: idempotent (2 runs consécutifs produisent la même liste de fichiers)" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/a.tar.gz"
  [ "$status" -eq 0 ]
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/b.tar.gz"
  [ "$status" -eq 0 ]
  diff <(tar -tzf "$TMP_DIR/a.tar.gz" | sort) <(tar -tzf "$TMP_DIR/b.tar.gz" | sort)
}

@test "export-minimal.sh: --output avec path traversal rejeté" {
  run "$EXPORT_SCRIPT" --output "../../../etc/evil.tar.gz"
  [ "$status" -ne 0 ]
}

@test "export-minimal.sh: archive bit-reproducible (mtime fixe)" {
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/a.tar.gz"
  [ "$status" -eq 0 ]
  sleep 1
  run "$EXPORT_SCRIPT" --output "$TMP_DIR/b.tar.gz"
  [ "$status" -eq 0 ]
  local sum_a sum_b
  sum_a=$(sha256sum "$TMP_DIR/a.tar.gz" | awk '{print $1}')
  sum_b=$(sha256sum "$TMP_DIR/b.tar.gz" | awk '{print $1}')
  [ "$sum_a" = "$sum_b" ]
}

@test "export-minimal.sh: manifest avec plus d'un ':' rejeté" {
  local fake_manifest="$TMP_DIR/bad-manifest.txt"
  echo 'CLAUDE.md:foo:bar' > "$fake_manifest"
  run "$EXPORT_SCRIPT" --manifest "$fake_manifest" --output "$TMP_DIR/out.tar.gz"
  [ "$status" -ne 0 ]
  [[ "$output" =~ ambig ]]
}

@test "export-minimal.sh: manifest avec chemin absolu rejeté" {
  local fake_manifest="$TMP_DIR/abs-manifest.txt"
  echo '/etc/passwd' > "$fake_manifest"
  run "$EXPORT_SCRIPT" --manifest "$fake_manifest" --output "$TMP_DIR/out.tar.gz"
  [ "$status" -ne 0 ]
  [[ "$output" =~ absolu ]]
}

@test "export-minimal.sh: manifest avec symlink sortant rejeté" {
  # Creer un fake symlink sortant DANS le repo
  local link="$REPO_ROOT/_test-bad-symlink-$$"
  ln -s /etc/passwd "$link"
  local fake_manifest="$TMP_DIR/link-manifest.txt"
  echo "_test-bad-symlink-$$" > "$fake_manifest"
  run "$EXPORT_SCRIPT" --manifest "$fake_manifest" --output "$TMP_DIR/out.tar.gz"
  rm -f "$link"
  [ "$status" -ne 0 ]
  [[ "$output" =~ symlink ]] || [[ "$output" =~ hors ]]
}

# =============================================================================
# new-project.sh --minimal
# =============================================================================

@test "new-project.sh: --minimal présent dans --help" {
  run "$NEW_PROJECT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ --minimal ]]
}

@test "new-project.sh: --minimal installe dans un dossier cible" {
  run "$NEW_PROJECT" --minimal -y "$TMP_DIR/proj"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIR/proj/CLAUDE.md" ]
  [ -f "$TMP_DIR/proj/.claude/commands/assistant.md" ]
  [ -f "$TMP_DIR/proj/.claude/settings.json" ]
  [ -d "$TMP_DIR/proj/.claude/skills/work-quick" ]
}

@test "new-project.sh: --minimal n'installe PAS les domaines exclus" {
  run "$NEW_PROJECT" --minimal -y "$TMP_DIR/proj"
  [ "$status" -eq 0 ]
  [ ! -d "$TMP_DIR/proj/.claude/commands/biz" ]
  [ ! -d "$TMP_DIR/proj/.claude/commands/growth" ]
  [ ! -f "$TMP_DIR/proj/.claude/agents/biz-mvp.md" ]
}
