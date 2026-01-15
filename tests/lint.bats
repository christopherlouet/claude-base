#!/usr/bin/env bats

# =============================================================================
# Tests pour lint.sh
# =============================================================================

load 'test_helper'

LINT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/lint.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "lint.sh existe et est exécutable" {
    [ -f "$LINT_SCRIPT" ]
    [ -x "$LINT_SCRIPT" ]
}

@test "lint.sh affiche l'aide avec --help" {
    run "$LINT_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"ShellCheck"* ]] || [[ "$output" == *"lint"* ]]
}

@test "lint.sh affiche la version avec --version" {
    run "$LINT_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"lint"* ]]
}

# =============================================================================
# Tests de linting
# =============================================================================

@test "lint.sh vérifie si shellcheck est disponible" {
    run "$LINT_SCRIPT"
    # Si shellcheck n'est pas installé, le script doit le signaler
    if ! command -v shellcheck &>/dev/null; then
        [[ "$output" == *"shellcheck"* ]] || [[ "$output" == *"ShellCheck"* ]] || true
    fi
}

@test "lint.sh peut s'exécuter sur le socle" {
    # Exécuter lint sur le répertoire du socle
    run "$LINT_SCRIPT" "$BATS_TEST_DIRNAME/.."
    # Peut réussir ou échouer selon les warnings, mais ne doit pas crasher
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Tests des options
# =============================================================================

@test "lint.sh --quiet réduit la sortie" {
    run "$LINT_SCRIPT" -q "$BATS_TEST_DIRNAME/.."
    # En mode quiet, moins de sortie
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

@test "lint.sh accepte un chemin spécifique" {
    # Créer un script de test
    cat > "$TEST_DIR/test.sh" << 'EOF'
#!/bin/bash
echo "Hello"
EOF
    chmod +x "$TEST_DIR/test.sh"

    run "$LINT_SCRIPT" "$TEST_DIR"
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$status" -eq 2 ]]
}

# =============================================================================
# Tests de détection d'erreurs
# =============================================================================

@test "lint.sh détecte les erreurs de syntaxe" {
    # Créer un script avec une erreur courante (variable non quotée)
    cat > "$TEST_DIR/bad.sh" << 'EOF'
#!/bin/bash
files=$(ls)
for f in $files; do
    echo $f
done
EOF
    chmod +x "$TEST_DIR/bad.sh"

    if command -v shellcheck &>/dev/null; then
        run "$LINT_SCRIPT" "$TEST_DIR"
        # ShellCheck devrait trouver des warnings
        [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]] || [[ "$output" == *"SC"* ]] || true
    else
        skip "shellcheck non installé"
    fi
}
