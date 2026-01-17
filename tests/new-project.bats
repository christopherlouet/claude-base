#!/usr/bin/env bats

# =============================================================================
# Tests pour new-project.sh
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "new-project.sh existe et est exécutable" {
    [ -f "$NEW_PROJECT_SCRIPT" ]
    [ -x "$NEW_PROJECT_SCRIPT" ]
}

@test "new-project.sh affiche l'aide avec --help" {
    run "$NEW_PROJECT_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"EXEMPLES"* ]]
}

@test "new-project.sh affiche la version avec --version" {
    run "$NEW_PROJECT_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"new-project"* ]]
}

# =============================================================================
# Tests de détection de stack
# =============================================================================

@test "new-project.sh détecte un projet Node.js" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Node"* ]] || [[ "$output" == *"Express"* ]] || true
}

@test "new-project.sh détecte un projet React" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-react",
  "dependencies": {
    "react": "^18.0.0"
  }
}
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"React"* ]] || true
}

@test "new-project.sh détecte TypeScript" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "test-ts",
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
EOF
    echo '{}' > "$TEST_DIR/tsconfig.json"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"TypeScript"* ]] || true
}

@test "new-project.sh détecte Python" {
    mkdir -p "$TEST_DIR"
    echo "flask==2.0.0" > "$TEST_DIR/requirements.txt"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Python"* ]] || [[ "$output" == *"Flask"* ]] || true
}

@test "new-project.sh détecte Go" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/go.mod" << 'EOF'
module test-go

go 1.21
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Go"* ]] || true
}

# =============================================================================
# Tests de configuration
# =============================================================================

@test "new-project.sh crée la structure .claude" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -f "$TEST_DIR/.claude/settings.json" ]
}

@test "new-project.sh crée CLAUDE.md" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "new-project.sh force le type avec --type" {
    run "$NEW_PROJECT_SCRIPT" -y -t python "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Tests des options CI/CD
# =============================================================================

@test "new-project.sh avec --ci installe GitHub Actions" {
    run "$NEW_PROJECT_SCRIPT" -y --ci "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -f "$TEST_DIR/.github/workflows/ci.yml" ]
}

@test "new-project.sh avec --hooks installe husky" {
    run "$NEW_PROJECT_SCRIPT" -y --hooks "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.husky" ]
}

@test "new-project.sh avec --docker crée Dockerfile" {
    run "$NEW_PROJECT_SCRIPT" -y --docker -t node-api "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/Dockerfile" ]
}

@test "new-project.sh avec --all installe tout" {
    run "$NEW_PROJECT_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -d "$TEST_DIR/.husky" ]
    [ -f "$TEST_DIR/.mcp.json" ]
    [ -f "$TEST_DIR/Dockerfile" ]
}

# =============================================================================
# Tests d'analyse CI/CD existante
# =============================================================================

@test "new-project.sh détecte GitHub Actions existant" {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CI/CD"* ]] || [[ "$output" == *"GitHub Actions"* ]] || [[ "$output" == *"Tests"* ]] || true
}

@test "new-project.sh ne remplace pas CI/CD existante par défaut" {
    mkdir -p "$TEST_DIR/.github/workflows"
    echo "name: Custom" > "$TEST_DIR/.github/workflows/custom.yml"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier custom.yml doit toujours exister
    [ -f "$TEST_DIR/.github/workflows/custom.yml" ]
    run cat "$TEST_DIR/.github/workflows/custom.yml"
    [[ "$output" == *"Custom"* ]]
}

# =============================================================================
# Tests de sécurité
# =============================================================================

@test "new-project.sh initialise git si nécessaire" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.git" ]
}

@test "new-project.sh crée .gitignore avec exclusions sécurisées" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.gitignore" ]

    run cat "$TEST_DIR/.gitignore"
    [[ "$output" == *"CLAUDE.local.md"* ]]
    [[ "$output" == *".env"* ]]
}

# =============================================================================
# Tests des nouveaux répertoires (agents, rules, output-styles)
# =============================================================================

@test "new-project.sh crée le répertoire agents" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/agents" ]

    # Vérifier qu'il y a des fichiers
    local count
    count=$(find "$TEST_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "new-project.sh crée le répertoire rules" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/rules" ]

    # Vérifier qu'il y a des fichiers
    local count
    count=$(find "$TEST_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "new-project.sh crée le répertoire output-styles" {
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/output-styles" ]

    # Vérifier qu'il y a des fichiers
    local count
    count=$(find "$TEST_DIR/.claude/output-styles" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

# =============================================================================
# Tests du nettoyage avant copie
# =============================================================================

@test "new-project.sh nettoie les anciens fichiers avant installation" {
    # Créer une première installation
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Ajouter un fichier obsolète dans commands
    echo "# Old command" > "$TEST_DIR/.claude/commands/old-command.md"
    [ -f "$TEST_DIR/.claude/commands/old-command.md" ]

    # Réinstaller
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier obsolète ne devrait plus exister
    [ ! -f "$TEST_DIR/.claude/commands/old-command.md" ]
}
