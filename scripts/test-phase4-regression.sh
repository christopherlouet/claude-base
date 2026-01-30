#!/bin/bash
# Test de non-régression Phase 4: Chrome Integration
# Vérifie que les tâches T016, T017, T018 sont complètes

set -euo pipefail

ERRORS=0

echo "=== Test de non-régression Phase 4 ==="
echo ""

# Vérification T016: SKILL
echo "--- T016: Skill qa-chrome ---"
SKILL=".claude/skills/qa-chrome/SKILL.md"

# Frontmatter complet requis
if grep -q "^name: qa-chrome$" "$SKILL" && \
   grep -q "^description:" "$SKILL" && \
   grep -q "^context: fork$" "$SKILL" && \
   grep -q "^disable-model-invocation: true$" "$SKILL" && \
   grep -q "^argument-hint:" "$SKILL" && \
   grep -A5 "^allowed-tools:" "$SKILL" | grep -q "Bash\|Read\|Grep"; then
    echo "✅ T016 COMPLETE: Skill frontmatter conforme"
else
    echo "❌ T016 ECHEC: Frontmatter incomplet"
    ((ERRORS++))
fi

# Instructions présentes
if grep -qi "test.*visuel\|debugging.*console\|responsive\|capture.*gif" "$SKILL"; then
    echo "✅ T016 COMPLETE: Instructions documentées"
else
    echo "❌ T016 ECHEC: Instructions manquantes"
    ((ERRORS++))
fi

# Prérequis documentés
if grep -qi "prerequis\|--chrome\|extension" "$SKILL"; then
    echo "✅ T016 COMPLETE: Prérequis documentés"
else
    echo "❌ T016 ECHEC: Prérequis manquants"
    ((ERRORS++))
fi

echo ""

# Vérification T017: AGENT
echo "--- T017: Agent qa-chrome ---"
AGENT=".claude/agents/qa-chrome.md"

# Frontmatter conforme
if grep -q "^name: qa-chrome$" "$AGENT" && \
   grep -q "^model: sonnet$" "$AGENT" && \
   grep -q "^permissionMode: default$" "$AGENT" && \
   grep -q "^tools: Read, Grep, Glob, Bash$" "$AGENT"; then
    echo "✅ T017 COMPLETE: Agent frontmatter conforme"
else
    echo "❌ T017 ECHEC: Frontmatter incomplet"
    ((ERRORS++))
fi

# Skills préchargés
if grep -A10 "^skills:" "$AGENT" | grep -q "qa-chrome" && \
   grep -A10 "^skills:" "$AGENT" | grep -q "qa-design"; then
    echo "✅ T017 COMPLETE: Skills préchargés (qa-chrome, qa-design)"
else
    echo "❌ T017 ECHEC: Skills manquants"
    ((ERRORS++))
fi

# Checklist d'audit documentée
if grep -qi "audit.*visuel\|checklist\|workflow" "$AGENT"; then
    echo "✅ T017 COMPLETE: Workflow d'audit documenté"
else
    echo "❌ T017 ECHEC: Workflow manquant"
    ((ERRORS++))
fi

echo ""

# Vérification T018: COMMAND
echo "--- T018: Command qa-chrome ---"
COMMAND=".claude/commands/qa/qa-chrome.md"

# Invoque l'agent
if grep -qi "qa-chrome" "$COMMAND"; then
    echo "✅ T018 COMPLETE: Invoque l'agent qa-chrome"
else
    echo "❌ T018 ECHEC: Agent non invoqué"
    ((ERRORS++))
fi

# Arguments documentés
if grep -q '\$ARGUMENTS' "$COMMAND"; then
    echo "✅ T018 COMPLETE: Arguments documentés"
else
    echo "❌ T018 ECHEC: Arguments manquants"
    ((ERRORS++))
fi

# Capacités inline documentées
if grep -qi "navigation\|console\|screenshot\|responsive\|capacit" "$COMMAND"; then
    echo "✅ T018 COMPLETE: Capacités documentées inline"
else
    echo "❌ T018 ECHEC: Capacités non documentées"
    ((ERRORS++))
fi

echo ""

# Résumé final
echo "=== Résumé ==="
echo "Total d'erreurs: $ERRORS"
echo ""

if [[ $ERRORS -eq 0 ]]; then
    echo "✅✅✅ PHASE 4 COMPLETE - Toutes les tâches (T016, T017, T018) passent"
    echo ""
    echo "Checkpoint atteint: Triplet Chrome (skill/agent/command) créé et validé."
    exit 0
else
    echo "❌ PHASE 4 INCOMPLETE - $ERRORS échecs"
    exit 1
fi
