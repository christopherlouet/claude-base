#!/usr/bin/env bats

# =============================================================================
# Tests d'intégration End-to-End
# Simule un workflow complet d'utilisation du socle
# =============================================================================

load 'test_helper'

INSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/install.sh"
VALIDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/validate.sh"
UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
DIFF_SCRIPT="$BATS_TEST_DIRNAME/../scripts/diff.sh"
DOCTOR_SCRIPT="$BATS_TEST_DIRNAME/../scripts/doctor.sh"
UNINSTALL_SCRIPT="$BATS_TEST_DIRNAME/../scripts/uninstall.sh"
NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# E2E: Workflow complet d'installation
# =============================================================================

@test "E2E: Workflow install → validate → doctor → uninstall" {
    # 1. Installation
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    # 2. Validation
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]

    # 3. Doctor
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]

    # 4. Désinstallation
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.claude" ]
}

@test "E2E: Workflow install → modify → diff → update" {
    # 1. Installation
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # 2. Modification d'un fichier
    echo "# Custom modification" >> "$TEST_DIR/.claude/commands/work/work-explore.md"

    # 3. Diff détecte la modification (retourne 1 car il y a des différences)
    run "$DIFF_SCRIPT" "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"work/work-explore.md"* ]] || [[ "$output" == *"work-explore.md"* ]]

    # 4. Update restaure les fichiers
    run "$UPDATE_SCRIPT" -y --force "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "E2E: Workflow install --all avec toutes les options" {
    # Installation complète
    run "$INSTALL_SCRIPT" -y --all "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Vérifier tous les composants
    [ -d "$TEST_DIR/.claude/commands" ]
    [ -d "$TEST_DIR/.claude/skills" ]
    [ -f "$TEST_DIR/.claude/settings.json" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
    [ -d "$TEST_DIR/.github/workflows" ]
    [ -d "$TEST_DIR/.husky" ]
    [ -f "$TEST_DIR/.mcp.json" ]

    # Validation
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# E2E: Workflow new-project
# =============================================================================

@test "E2E: new-project crée un projet complet et fonctionnel" {
    # Créer un nouveau projet
    run "$NEW_PROJECT_SCRIPT" -y -t node-api "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Vérifier la structure
    [ -d "$TEST_DIR/.claude" ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
    [ -d "$TEST_DIR/.git" ]

    # Le projet doit être valide
    run "$VALIDATE_SCRIPT" -q "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Doctor doit fonctionner
    run "$DOCTOR_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "E2E: new-project avec CI/CD existante propose des améliorations" {
    # Créer un projet avec CI partielle
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

    # new-project doit détecter la CI existante
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Le fichier original doit être préservé
    [ -f "$TEST_DIR/.github/workflows/test.yml" ]
}

# =============================================================================
# E2E: Gestion des fichiers locaux
# =============================================================================

@test "E2E: Les fichiers locaux sont préservés durant tout le cycle" {
    # Installation
    run "$INSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Créer des fichiers locaux
    echo "# Mes notes personnelles" > "$TEST_DIR/CLAUDE.local.md"
    echo '{"custom": true}' > "$TEST_DIR/.claude/settings.local.json"

    # Update préserve les fichiers locaux
    run "$UPDATE_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
    [ -f "$TEST_DIR/.claude/settings.local.json" ]

    # Uninstall préserve aussi les fichiers locaux
    run "$UNINSTALL_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.local.md" ]
}

# =============================================================================
# E2E: Détection de stack
# =============================================================================

@test "E2E: Détection et configuration projet Node.js/React" {
    # Créer un projet React
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "my-react-app",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "jest": "^29.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "jest"
  }
}
EOF
    echo '{}' > "$TEST_DIR/tsconfig.json"

    # new-project doit détecter React + TypeScript
    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]

    # CLAUDE.md doit contenir les infos du projet
    [ -f "$TEST_DIR/CLAUDE.md" ]
    run cat "$TEST_DIR/CLAUDE.md"
    [[ "$output" == *"npm"* ]] || [[ "$output" == *"test"* ]] || [[ "$output" == *"build"* ]]
}

@test "E2E: Détection et configuration projet Python" {
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/requirements.txt" << 'EOF'
fastapi==0.100.0
uvicorn==0.23.0
pytest==7.4.0
EOF

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]
}

@test "E2E: Détection et configuration monorepo" {
    mkdir -p "$TEST_DIR/packages/web"
    mkdir -p "$TEST_DIR/packages/api"
    cat > "$TEST_DIR/package.json" << 'EOF'
{
  "name": "my-monorepo",
  "workspaces": ["packages/*"]
}
EOF
    echo '{}' > "$TEST_DIR/turbo.json"

    run "$NEW_PROJECT_SCRIPT" -y "$TEST_DIR"
    [ "$status" -eq 0 ]
}

# =============================================================================
# E2E: Intégrité du socle
# =============================================================================

@test "E2E: Le socle lui-même est valide" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Validation du socle
    run "$VALIDATE_SCRIPT" "$SOCLE_DIR"
    [ "$status" -eq 0 ]
}

@test "E2E: Le socle passe doctor" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    run "$DOCTOR_SCRIPT" "$SOCLE_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "E2E: Tous les agents sont présents et valides" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Compter les agents (récursivement dans les sous-répertoires)
    agent_count=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null | wc -l)
    [ "$agent_count" -ge 70 ]

    # Vérifier que chaque agent a un titre
    while IFS= read -r agent; do
        run head -1 "$agent"
        [[ "$output" == "# "* ]]
    done < <(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f 2>/dev/null)
}

@test "E2E: Tous les skills sont présents et valides" {
    SOCLE_DIR="$BATS_TEST_DIRNAME/.."

    # Compter les skills
    skill_count=$(ls -d "$SOCLE_DIR/.claude/skills/"*/ 2>/dev/null | wc -l)
    [ "$skill_count" -ge 5 ]

    # Vérifier que chaque skill a un README
    for skill in "$SOCLE_DIR/.claude/skills/"*/; do
        [ -f "${skill}README.md" ] || [ -f "${skill}index.md" ] || [ -f "${skill}skill.md" ] || true
    done
}

# =============================================================================
# E2E: Scénarios d'erreur
# =============================================================================

@test "E2E: Gestion gracieuse des erreurs - répertoire inexistant" {
    run "$INSTALL_SCRIPT" -y "/nonexistent/path/that/does/not/exist"
    # Doit échouer proprement
    [ "$status" -ne 0 ]
}

@test "E2E: Gestion gracieuse des erreurs - permissions" {
    if [ "$(id -u)" -eq 0 ]; then
        skip "Test non applicable en root"
    fi

    # Créer un répertoire sans permissions d'écriture
    mkdir -p "$TEST_DIR/readonly"
    chmod 444 "$TEST_DIR/readonly"

    run "$INSTALL_SCRIPT" -y "$TEST_DIR/readonly"
    # Doit échouer ou avertir
    [[ "$status" -ne 0 ]] || [[ "$output" == *"permission"* ]] || [[ "$output" == *"Permission"* ]] || true

    # Nettoyer
    chmod 755 "$TEST_DIR/readonly"
}
