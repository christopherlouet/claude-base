#!/bin/bash
# Validation de la Phase 4: Chrome Integration
# Ce script valide que les fichiers skill/agent/command pour qa-chrome sont conformes

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "=== Validation Phase 4: Chrome Integration ==="
echo ""

# Fonction de validation
validate_file() {
    local file=$1
    local type=$2
    
    if [[ ! -f "$file" ]]; then
        echo "❌ ERREUR: Fichier manquant: $file"
        ((ERRORS++))
        return 1
    fi
    
    echo "✓ Fichier existe: $file"
    return 0
}

validate_frontmatter_field() {
    local file=$1
    local field=$2
    local expected_value=$3
    
    if ! grep -q "^${field}:" "$file"; then
        echo "  ⚠️  WARNING: Champ manquant '$field' dans $file"
        ((WARNINGS++))
        return 1
    fi
    
    if [[ -n "$expected_value" ]]; then
        local actual=$(grep "^${field}:" "$file" | head -1 | cut -d: -f2- | xargs)
        if [[ "$actual" != "$expected_value" ]]; then
            echo "  ⚠️  WARNING: '$field' attendu='$expected_value', actuel='$actual'"
            ((WARNINGS++))
        fi
    fi
    
    echo "  ✓ Champ '$field' présent"
    return 0
}

# T016 - Validation du SKILL
echo "--- T016: Validation skill qa-chrome ---"
SKILL_FILE=".claude/skills/qa-chrome/SKILL.md"
if validate_file "$SKILL_FILE" "skill"; then
    validate_frontmatter_field "$SKILL_FILE" "name" "qa-chrome"
    validate_frontmatter_field "$SKILL_FILE" "description" ""
    validate_frontmatter_field "$SKILL_FILE" "context" "fork"
    validate_frontmatter_field "$SKILL_FILE" "disable-model-invocation" "true"
    validate_frontmatter_field "$SKILL_FILE" "argument-hint" ""
    
    # Vérifier que allowed-tools contient Bash
    if grep -A5 "^allowed-tools:" "$SKILL_FILE" | grep -q "Bash"; then
        echo "  ✓ allowed-tools contient Bash"
    else
        echo "  ❌ ERREUR: allowed-tools ne contient pas Bash"
        ((ERRORS++))
    fi
fi
echo ""

# T017 - Validation de l'AGENT
echo "--- T017: Validation agent qa-chrome ---"
AGENT_FILE=".claude/agents/qa-chrome.md"
if validate_file "$AGENT_FILE" "agent"; then
    validate_frontmatter_field "$AGENT_FILE" "name" "qa-chrome"
    validate_frontmatter_field "$AGENT_FILE" "model" "sonnet"
    validate_frontmatter_field "$AGENT_FILE" "permissionMode" "default"
    
    # Vérifier que tools contient les 4 outils requis
    if grep -q "^tools: Read, Grep, Glob, Bash" "$AGENT_FILE"; then
        echo "  ✓ tools contient Read, Grep, Glob, Bash"
    else
        echo "  ⚠️  WARNING: tools peut ne pas contenir tous les outils requis"
        ((WARNINGS++))
    fi
    
    # Vérifier que skills contient qa-chrome et qa-design
    if grep -A5 "^skills:" "$AGENT_FILE" | grep -q "qa-chrome"; then
        echo "  ✓ skills contient qa-chrome"
    else
        echo "  ❌ ERREUR: skills ne contient pas qa-chrome"
        ((ERRORS++))
    fi
    
    if grep -A5 "^skills:" "$AGENT_FILE" | grep -q "qa-design"; then
        echo "  ✓ skills contient qa-design"
    else
        echo "  ⚠️  WARNING: skills ne contient pas qa-design (recommandé)"
        ((WARNINGS++))
    fi
fi
echo ""

# T018 - Validation de la COMMAND
echo "--- T018: Validation command qa-chrome ---"
COMMAND_FILE=".claude/commands/qa/qa-chrome.md"
if validate_file "$COMMAND_FILE" "command"; then
    # Vérifier que la commande documente les prérequis --chrome
    if grep -qi "chrome" "$COMMAND_FILE" && grep -qi "prerequis\|prérequis" "$COMMAND_FILE"; then
        echo "  ✓ Documente les prérequis Chrome"
    else
        echo "  ⚠️  WARNING: Prérequis Chrome non documentés"
        ((WARNINGS++))
    fi
    
    # Vérifier que $ARGUMENTS est mentionné
    if grep -q '\$ARGUMENTS' "$COMMAND_FILE"; then
        echo "  ✓ Utilise la variable \$ARGUMENTS"
    else
        echo "  ⚠️  WARNING: Variable \$ARGUMENTS non utilisée"
        ((WARNINGS++))
    fi
fi
echo ""

# Résumé
echo "=== Résumé de la validation ==="
echo "Erreurs: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -eq 0 ]]; then
    echo "✅ Phase 4: Chrome Integration - VALIDE"
    exit 0
else
    echo "❌ Phase 4: Chrome Integration - ÉCHEC ($ERRORS erreurs)"
    exit 1
fi
