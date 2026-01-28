#!/bin/bash

# =============================================================================
# Claude-Socle Validate Counts Script
# Verifie que les compteurs (commands, agents, skills, rules) sont coherents
# entre les fichiers reels et la documentation
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

enable_error_handler
check_base_requirements

# =============================================================================
# Aide
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Validate Counts${NC}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Verifie que les compteurs de commands, agents, skills et rules
    sont coherents entre les fichiers reels et la documentation.

${BOLD}OPTIONS${NC}
    -h, --help     Afficher cette aide
    -v, --verbose  Mode verbeux
    --fix          Afficher les commandes de correction

${BOLD}EXEMPLES${NC}
    $(basename "$0")
    $(basename "$0") --verbose
    $(basename "$0") --fix
EOF
}

# =============================================================================
# Variables
# =============================================================================

ERRORS=0
WARNINGS=0
SHOW_FIX=false

# =============================================================================
# Parsing arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --fix)
            SHOW_FIX=true
            shift
            ;;
        *)
            error "Option inconnue: $1"
            ;;
    esac
done

# =============================================================================
# Count actual files
# =============================================================================

info "Comptage des fichiers reels..."
echo ""

# Count commands (md files in commands/ subdirectories)
ACTUAL_COMMANDS=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -type f | wc -l)

# Count agents
ACTUAL_AGENTS=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l)

# Count skills (directories with SKILL.md)
ACTUAL_SKILLS=$(find "$SOCLE_DIR/.claude/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l)

# Count rules
ACTUAL_RULES=$(find "$SOCLE_DIR/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l)

echo "  Commands : $ACTUAL_COMMANDS"
echo "  Agents   : $ACTUAL_AGENTS"
echo "  Skills   : $ACTUAL_SKILLS"
echo "  Rules    : $ACTUAL_RULES"
echo ""

# =============================================================================
# Check documentation files
# =============================================================================

check_count() {
    local file="$1"
    local pattern="$2"
    local expected="$3"
    local label="$4"

    local rel_path="${file#"$SOCLE_DIR"/}"

    if [[ ! -f "$file" ]]; then
        debug "Fichier non trouve: $rel_path"
        return
    fi

    local found
    found=$(grep -oP "$pattern" "$file" 2>/dev/null | head -1 || echo "")

    if [[ -z "$found" ]]; then
        debug "$rel_path: pattern non trouve pour $label"
        return
    fi

    local count
    count=$(echo "$found" | grep -oP '[0-9]+' | head -1)

    if [[ "$count" != "$expected" ]]; then
        error_no_exit "$rel_path: $label = $count (attendu: $expected)"
        ERRORS=$((ERRORS + 1))
    else
        if $VERBOSE; then
            success "$rel_path: $label = $count"
        fi
    fi
}

info "Verification de la documentation..."
echo ""

# --- CLAUDE.md ---
info "CLAUDE.md"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ commandes" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ sub-agents" "$ACTUAL_AGENTS" "agents"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ skills" "$ACTUAL_SKILLS" "skills"

# --- README.md ---
info "README.md"
check_count "$SOCLE_DIR/README.md" \
    "Commandes Disponibles \([0-9]+\)" "$ACTUAL_COMMANDS" "commands header"
check_count "$SOCLE_DIR/README.md" \
    "\*\*118 commandes\*\*" "$ACTUAL_COMMANDS" "commands inline"

# --- Website index.tsx ---
info "website/src/pages/index.tsx"
check_count "$SOCLE_DIR/website/src/pages/index.tsx" \
    "'[0-9]+ Commands'" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/website/src/pages/index.tsx" \
    "'[0-9]+ Sub-Agents'" "$ACTUAL_AGENTS" "agents"
check_count "$SOCLE_DIR/website/src/pages/index.tsx" \
    "'[0-9]+ Skills'" "$ACTUAL_SKILLS" "skills"
check_count "$SOCLE_DIR/website/src/pages/index.tsx" \
    "'[0-9]+ Rules'" "$ACTUAL_RULES" "rules"

# --- Website architecture ---
info "website/docs/intro/architecture.md"
check_count "$SOCLE_DIR/website/docs/intro/architecture.md" \
    "Commands \([0-9]+\)" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/website/docs/intro/architecture.md" \
    "Agents \([0-9]+\)" "$ACTUAL_AGENTS" "agents"
check_count "$SOCLE_DIR/website/docs/intro/architecture.md" \
    "Skills \([0-9]+\)" "$ACTUAL_SKILLS" "skills"
check_count "$SOCLE_DIR/website/docs/intro/architecture.md" \
    "Rules \([0-9]+\)" "$ACTUAL_RULES" "rules"

# --- Website intro/index.md ---
info "website/docs/intro/index.md"
check_count "$SOCLE_DIR/website/docs/intro/index.md" \
    "Commands.*[0-9]+" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/website/docs/intro/index.md" \
    "Agents.*[0-9]+" "$ACTUAL_AGENTS" "agents"

# --- Website cheatsheet ---
info "website/docs/reference/cheatsheet.md"
check_count "$SOCLE_DIR/website/docs/reference/cheatsheet.md" \
    "[0-9]+ Commands \| [0-9]+ Agents" "$ACTUAL_COMMANDS" "commands footer"

# --- FeatureComparison.tsx ---
info "website/src/components/FeatureComparison.tsx"
check_count "$SOCLE_DIR/website/src/components/FeatureComparison.tsx" \
    "commands: '[0-9]+'" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/website/src/components/FeatureComparison.tsx" \
    "agents: '[0-9]+'" "$ACTUAL_AGENTS" "agents"
check_count "$SOCLE_DIR/website/src/components/FeatureComparison.tsx" \
    "skills: '[0-9]+'" "$ACTUAL_SKILLS" "skills"

# --- docusaurus.config.ts ---
info "website/docusaurus.config.ts"
check_count "$SOCLE_DIR/website/docusaurus.config.ts" \
    "Commands \([0-9]+\)" "$ACTUAL_COMMANDS" "commands"

echo ""

# =============================================================================
# Summary
# =============================================================================

if [[ "$ERRORS" -eq 0 ]]; then
    success "Tous les compteurs sont coherents"
    exit 0
else
    error_no_exit "$ERRORS incohérence(s) trouvée(s)"
    if $SHOW_FIX; then
        echo ""
        info "Pour corriger automatiquement, mettez a jour les fichiers ci-dessus"
        info "ou relancez les scripts de generation:"
        echo "  cd $SOCLE_DIR/website && npm run generate:all"
    fi
    exit 1
fi
