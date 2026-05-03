#!/bin/bash

# =============================================================================
# Test Helper - Utility functions for bats tests
# =============================================================================

# Load the foundation's common library
SOCLE_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
source "$SOCLE_DIR/scripts/lib/common.sh"

# Create a temporary directory for tests
setup_test_dir() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

# Clean up the temporary directory
teardown_test_dir() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Create a minimal project structure
create_minimal_project() {
    local dir="${1:-$TEST_DIR}"
    mkdir -p "$dir/.claude/commands"
    mkdir -p "$dir/.claude/skills"
    echo '{}' > "$dir/.claude/settings.json"
    echo "# Test Project" > "$dir/CLAUDE.md"
}

# Create a test command file
create_test_command() {
    local name="$1"
    local dir="${2:-$TEST_DIR}"
    cat > "$dir/.claude/commands/$name.md" << EOF
# Agent $name

Test description for $name.

## Instructions

Do something.
EOF
}

# Create a command file in a subdirectory (new structure)
create_test_command_in_subdir() {
    local category="$1"
    local name="$2"
    local dir="${3:-$TEST_DIR}"
    mkdir -p "$dir/.claude/commands/$category"
    cat > "$dir/.claude/commands/$category/$name.md" << EOF
# Agent $name

Test description for $name.

## Instructions

Do something.
EOF
}

# Create a test skill
create_test_skill() {
    local name="$1"
    local dir="${2:-$TEST_DIR}"
    mkdir -p "$dir/.claude/skills/$name"
    cat > "$dir/.claude/skills/$name/SKILL.md" << EOF
---
name: $name
description: Test skill
---

# Skill $name

Skill instructions.
EOF
}

# Create a settings.json with hooks
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

# Check if gitleaks is installed
skip_if_no_gitleaks() {
    if ! command -v gitleaks &>/dev/null; then
        skip "gitleaks is not installed"
    fi
}

# Check if jq is installed
skip_if_no_jq() {
    if ! command -v jq &>/dev/null; then
        skip "jq is not installed"
    fi
}
