#!/bin/bash
# Test approfondi du contenu de la Phase 4: Chrome Integration
# Vérifie que les fichiers documentent correctement les capacités Chrome

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "=== Test du contenu Phase 4: Chrome Integration ==="
echo ""

check_content() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if grep -qi "$pattern" "$file"; then
        echo "  ✓ $description"
        return 0
    else
        echo "  ⚠️  WARNING: Manque '$description' (pattern: $pattern)"
        ((WARNINGS++))
        return 1
    fi
}

# Test du SKILL
echo "--- Contenu du skill qa-chrome ---"
SKILL=".claude/skills/qa-chrome/SKILL.md"

check_content "$SKILL" "chrome.*flag\|--chrome" "Mentionne le flag --chrome"
check_content "$SKILL" "extension.*chrome\|claude in chrome" "Mentionne l'extension Chrome"
check_content "$SKILL" "screenshot\|capture" "Documente les captures d'écran"
check_content "$SKILL" "gif\|enregistr" "Documente l'enregistrement GIF"
check_content "$SKILL" "console" "Documente le debugging console"
check_content "$SKILL" "dom" "Mentionne l'inspection DOM"
check_content "$SKILL" "responsive" "Documente le test responsive"
check_content "$SKILL" "limitations?\|limit" "Documente les limitations"

echo ""

# Test de l'AGENT
echo "--- Contenu de l'agent qa-chrome ---"
AGENT=".claude/agents/qa-chrome.md"

check_content "$AGENT" "audit.*visuel\|visual.*test" "Objectif: audit visuel"
check_content "$AGENT" "375.*768.*1440\|mobile.*tablet.*desktop" "Tailles d'écran responsive"
check_content "$AGENT" "rapport\|report" "Format du rapport documenté"
check_content "$AGENT" "score" "Score d'évaluation mentionné"
check_content "$AGENT" "severit" "Niveau de sévérité documenté"

echo ""

# Test de la COMMAND
echo "--- Contenu de la commande qa-chrome ---"
COMMAND=".claude/commands/qa/qa-chrome.md"

check_content "$COMMAND" "workflow" "Documente le workflow"
check_content "$COMMAND" "capabilities?\|capacit" "Documente les capacités"
check_content "$COMMAND" "\$ARGUMENTS" "Utilise les arguments"

echo ""

# Vérification de la cohérence entre les fichiers
echo "--- Cohérence entre skill/agent/command ---"

# Le skill doit mentionner l'agent
if grep -q "qa-chrome" "$SKILL"; then
    echo "  ✓ Skill et agent sont cohérents"
else
    echo "  ⚠️  WARNING: Incohérence skill/agent"
    ((WARNINGS++))
fi

# L'agent doit référencer le skill
if grep -A10 "^skills:" "$AGENT" | grep -q "qa-chrome"; then
    echo "  ✓ Agent charge le skill"
else
    echo "  ❌ ERREUR: Agent ne charge pas le skill"
    ((ERRORS++))
fi

echo ""

# Résumé
echo "=== Résumé du test de contenu ==="
echo "Erreurs: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        echo "✅ Contenu Phase 4 - EXCELLENT (aucun warning)"
    else
        echo "✅ Contenu Phase 4 - VALIDE ($WARNINGS warnings)"
    fi
    exit 0
else
    echo "❌ Contenu Phase 4 - ÉCHEC ($ERRORS erreurs, $WARNINGS warnings)"
    exit 1
fi
