#!/bin/bash
# Test suite complète pour la Phase 4: Chrome Integration
# Exécute tous les tests de validation

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║       TEST SUITE PHASE 4: CHROME INTEGRATION                      ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0

run_test() {
    local test_script=$1
    local test_name=$2
    
    echo "▶ Exécution: $test_name"
    echo "─────────────────────────────────────────────────────────────────"
    
    if "$SCRIPT_DIR/$test_script"; then
        echo "✅ PASS: $test_name"
        ((TOTAL_PASSED++))
    else
        echo "❌ FAIL: $test_name"
        ((TOTAL_FAILED++))
    fi
    
    echo ""
}

# Exécution séquentielle des tests
run_test "validate-phase4-chrome.sh" "Validation structure (T016, T017, T018)"
run_test "test-phase4-chrome-content.sh" "Test contenu sémantique"
run_test "test-phase4-regression.sh" "Test non-régression"

# Résumé final
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    RÉSUMÉ DES TESTS                               ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Tests passés:  $TOTAL_PASSED"
echo "Tests échoués: $TOTAL_FAILED"
echo ""

if [[ $TOTAL_FAILED -eq 0 ]]; then
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║  ✅✅✅  PHASE 4: CHROME INTEGRATION - SUCCESS  ✅✅✅           ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Livrables validés:"
    echo "  ✓ .claude/skills/qa-chrome/SKILL.md"
    echo "  ✓ .claude/agents/qa-chrome.md"
    echo "  ✓ .claude/commands/qa/qa-chrome.md"
    echo ""
    echo "Capacités Chrome Integration opérationnelles:"
    echo "  ✓ Tests visuels navigateur"
    echo "  ✓ Debugging console et DOM"
    echo "  ✓ Tests responsive multi-devices"
    echo "  ✓ Capture GIF de parcours utilisateur"
    echo "  ✓ Extraction de données web"
    echo ""
    exit 0
else
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║     ❌  PHASE 4: CHROME INTEGRATION - FAILURE  ❌                ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Vérifiez les erreurs ci-dessus."
    exit 1
fi
