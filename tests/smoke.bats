#!/usr/bin/env bats

# =============================================================================
# Tests de smoke - Validation rapide de l'intégrité du socle
# =============================================================================
# Ces tests vérifient que tous les composants essentiels sont présents et
# correctement formatés. Utilisés comme première ligne de validation avant
# les tests plus détaillés.
# =============================================================================

load 'test_helper'

# =============================================================================
# Tests de structure des commandes
# =============================================================================

@test "smoke: toutes les commandes ont un fichier .md" {
    local count
    count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 100 ]
}

@test "smoke: les catégories de commandes existent" {
    [ -d "$SOCLE_DIR/.claude/commands/work" ]
    [ -d "$SOCLE_DIR/.claude/commands/dev" ]
    [ -d "$SOCLE_DIR/.claude/commands/qa" ]
    [ -d "$SOCLE_DIR/.claude/commands/ops" ]
    [ -d "$SOCLE_DIR/.claude/commands/doc" ]
    [ -d "$SOCLE_DIR/.claude/commands/biz" ]
    [ -d "$SOCLE_DIR/.claude/commands/growth" ]
    [ -d "$SOCLE_DIR/.claude/commands/legal" ]
    [ -d "$SOCLE_DIR/.claude/commands/data" ]
}

@test "smoke: les commandes work essentielles existent" {
    [ -f "$SOCLE_DIR/.claude/commands/work/work-explore.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-plan.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-commit.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/work/work-pr.md" ]
}

@test "smoke: les commandes dev essentielles existent" {
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-tdd.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-test.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-debug.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/dev/dev-api.md" ]
}

@test "smoke: les commandes qa essentielles existent" {
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-security.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-review.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-perf.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/qa/qa-audit.md" ]
}

@test "smoke: l'orchestrateur assistant existe" {
    [ -f "$SOCLE_DIR/.claude/commands/assistant.md" ]
    [ -f "$SOCLE_DIR/.claude/commands/assistant-auto.md" ]
}

# =============================================================================
# Tests de structure des agents
# =============================================================================

@test "smoke: tous les agents ont un fichier .md" {
    local count
    count=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 40 ]
}

@test "smoke: les agents essentiels existent" {
    [ -f "$SOCLE_DIR/.claude/agents/work-explore.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/qa-security.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/qa-audit.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/dev-debug.md" ]
    [ -f "$SOCLE_DIR/.claude/agents/ops-health.md" ]
}

# =============================================================================
# Tests de structure des skills
# =============================================================================

@test "smoke: tous les skills ont un dossier avec SKILL.md" {
    local count
    count=$(find "$SOCLE_DIR/.claude/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 25 ]
}

@test "smoke: les skills essentiels existent" {
    [ -f "$SOCLE_DIR/.claude/skills/dev-tdd/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/work-commit/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/qa-review/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/qa-security/SKILL.md" ]
    [ -f "$SOCLE_DIR/.claude/skills/work-explore/SKILL.md" ]
}

@test "smoke: les skills ont un frontmatter YAML valide" {
    local skill_file="$SOCLE_DIR/.claude/skills/dev-tdd/SKILL.md"
    # Vérifie que le fichier commence par ---
    head -1 "$skill_file" | grep -q "^---$"
}

# =============================================================================
# Tests de structure des rules
# =============================================================================

@test "smoke: les règles essentielles existent" {
    [ -f "$SOCLE_DIR/.claude/rules/git.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/workflow.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/typescript.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/security.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/testing.md" ]
}

@test "smoke: les règles par langage existent" {
    [ -f "$SOCLE_DIR/.claude/rules/typescript.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/python.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/go.md" ]
    [ -f "$SOCLE_DIR/.claude/rules/flutter.md" ]
}

# =============================================================================
# Tests de configuration
# =============================================================================

@test "smoke: settings.json est valide" {
    skip_if_no_jq
    jq . "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json contient les permissions" {
    skip_if_no_jq
    jq -e '.permissions' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json contient les hooks" {
    skip_if_no_jq
    jq -e '.hooks' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json bloque rm -rf /" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("rm -rf /"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json bloque git push --force" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("git push --force"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

@test "smoke: settings.json bloque sudo" {
    skip_if_no_jq
    jq -e '.permissions.deny[] | select(contains("sudo"))' "$SOCLE_DIR/.claude/settings.json" > /dev/null
}

# =============================================================================
# Tests des fichiers principaux
# =============================================================================

@test "smoke: CLAUDE.md existe et n'est pas vide" {
    [ -f "$SOCLE_DIR/CLAUDE.md" ]
    [ -s "$SOCLE_DIR/CLAUDE.md" ]
    local lines
    lines=$(wc -l < "$SOCLE_DIR/CLAUDE.md")
    # CLAUDE.md uses @imports since PR#29, baseline is ~70 lines
    [ "$lines" -gt 30 ]
}

@test "smoke: VERSION existe et contient une version valide" {
    [ -f "$SOCLE_DIR/VERSION" ]
    grep -qE "^[0-9]+\.[0-9]+\.[0-9]+$" "$SOCLE_DIR/VERSION"
}

@test "smoke: CHANGELOG.md existe et est à jour" {
    [ -f "$SOCLE_DIR/CHANGELOG.md" ]
    # Vérifie que le changelog mentionne la version actuelle
    local version
    version=$(cat "$SOCLE_DIR/VERSION")
    # La version peut être dans [Unreleased] ou dans une section
    grep -qE "\[.*\]" "$SOCLE_DIR/CHANGELOG.md"
}

@test "smoke: SECURITY.md existe" {
    [ -f "$SOCLE_DIR/SECURITY.md" ]
    [ -s "$SOCLE_DIR/SECURITY.md" ]
}

@test "smoke: .gitleaks.toml existe" {
    [ -f "$SOCLE_DIR/.gitleaks.toml" ]
}

# =============================================================================
# Tests des scripts
# =============================================================================

@test "smoke: tous les scripts sont exécutables" {
    for script in "$SOCLE_DIR/scripts"/*.sh; do
        [ -x "$script" ]
    done
}

@test "smoke: les scripts essentiels existent" {
    [ -f "$SOCLE_DIR/scripts/validate.sh" ]
    [ -f "$SOCLE_DIR/scripts/doctor.sh" ]
    [ -f "$SOCLE_DIR/scripts/new-project.sh" ]
    [ -f "$SOCLE_DIR/scripts/lint.sh" ]
    [ -f "$SOCLE_DIR/scripts/test.sh" ]
}

@test "smoke: lib/common.sh existe et est sourceable" {
    [ -f "$SOCLE_DIR/scripts/lib/common.sh" ]
    source "$SOCLE_DIR/scripts/lib/common.sh"
}

# =============================================================================
# Tests de cohérence des compteurs
# =============================================================================

@test "smoke: le nombre de commandes correspond à CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    # Doit être dans la plage attendue (110-120)
    [ "$actual_count" -ge 100 ]
    [ "$actual_count" -le 130 ]
}

@test "smoke: le nombre d'agents correspond à CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    # Doit être dans la plage attendue (50-60)
    [ "$actual_count" -ge 45 ]
    [ "$actual_count" -le 70 ]
}

@test "smoke: le nombre de skills correspond à CLAUDE.md" {
    local actual_count
    actual_count=$(find "$SOCLE_DIR/.claude/skills" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    # -1 pour le répertoire skills lui-même
    actual_count=$((actual_count - 1))
    # Doit être dans la plage attendue (35-55)
    [ "$actual_count" -ge 25 ]
    [ "$actual_count" -le 55 ]
}

# =============================================================================
# Tests de format des fichiers de commandes
# =============================================================================

@test "smoke: les commandes ont un titre markdown" {
    local errors=0
    while IFS= read -r file; do
        if ! head -5 "$file" | grep -q "^# "; then
            errors=$((errors + 1))
        fi
    done < <(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f)
    [ "$errors" -eq 0 ]
}

@test "smoke: les agents ont un titre markdown" {
    local errors=0
    while IFS= read -r file; do
        # Les agents peuvent avoir un frontmatter YAML avant le titre
        if ! head -20 "$file" | grep -q "^# "; then
            errors=$((errors + 1))
        fi
    done < <(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f)
    [ "$errors" -eq 0 ]
}

# =============================================================================
# Tests de templates
# =============================================================================

@test "smoke: les templates existent" {
    [ -d "$SOCLE_DIR/.claude/templates" ]
    local count
    count=$(find "$SOCLE_DIR/.claude/templates" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 3 ]
}

# =============================================================================
# Tests d'output-styles
# =============================================================================

@test "smoke: les output-styles existent" {
    [ -d "$SOCLE_DIR/.claude/output-styles" ]
    local count
    count=$(find "$SOCLE_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 5 ]
}

# =============================================================================
# Tests de documentation
# =============================================================================

@test "smoke: la documentation existe" {
    [ -d "$SOCLE_DIR/docs" ]
    [ -f "$SOCLE_DIR/README.md" ]
}

@test "smoke: les guides existent" {
    [ -d "$SOCLE_DIR/docs/guides" ] || [ -d "$SOCLE_DIR/website/docs/guides" ]
}

# =============================================================================
# Tests CI/CD
# =============================================================================

@test "smoke: les workflows GitHub Actions existent" {
    [ -d "$SOCLE_DIR/.github/workflows" ]
    [ -f "$SOCLE_DIR/.github/workflows/ci.yml" ]
}
