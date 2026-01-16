#!/bin/bash

# =============================================================================
# Test Helper - Fonctions utilitaires pour les tests bats
# =============================================================================

# Charger la librairie commune du socle
SOCLE_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
source "$SOCLE_DIR/scripts/lib/common.sh"

# Créer un répertoire temporaire pour les tests
setup_test_dir() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

# Nettoyer le répertoire temporaire
teardown_test_dir() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Créer une structure de projet minimale
create_minimal_project() {
    local dir="${1:-$TEST_DIR}"
    mkdir -p "$dir/.claude/commands"
    mkdir -p "$dir/.claude/skills"
    echo '{}' > "$dir/.claude/settings.json"
    echo "# Test Project" > "$dir/CLAUDE.md"
}

# Créer un fichier de commande de test
create_test_command() {
    local name="$1"
    local dir="${2:-$TEST_DIR}"
    cat > "$dir/.claude/commands/$name.md" << EOF
# Agent $name

Description de test pour $name.

## Instructions

Faire quelque chose.
EOF
}

# Créer un fichier de commande dans un sous-répertoire (nouvelle structure)
create_test_command_in_subdir() {
    local category="$1"
    local name="$2"
    local dir="${3:-$TEST_DIR}"
    mkdir -p "$dir/.claude/commands/$category"
    cat > "$dir/.claude/commands/$category/$name.md" << EOF
# Agent $name

Description de test pour $name.

## Instructions

Faire quelque chose.
EOF
}

# Créer un skill de test
create_test_skill() {
    local name="$1"
    local dir="${2:-$TEST_DIR}"
    mkdir -p "$dir/.claude/skills/$name"
    cat > "$dir/.claude/skills/$name/SKILL.md" << EOF
---
name: $name
description: Skill de test
---

# Skill $name

Instructions du skill.
EOF
}

# Créer un settings.json avec hooks
create_settings_with_hooks() {
    local dir="${1:-$TEST_DIR}"
    cat > "$dir/.claude/settings.json" << EOF
{
  "permissions": {
    "allow": ["Edit", "Write"],
    "deny": ["Bash(rm -rf:*)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "command": "echo pre-edit"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "command": "echo post-edit"
      }
    ]
  }
}
EOF
}

# Vérifier si gitleaks est installé
skip_if_no_gitleaks() {
    if ! command -v gitleaks &>/dev/null; then
        skip "gitleaks n'est pas installé"
    fi
}

# Vérifier si jq est installé
skip_if_no_jq() {
    if ! command -v jq &>/dev/null; then
        skip "jq n'est pas installé"
    fi
}
