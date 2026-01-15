#!/usr/bin/env bats

# =============================================================================
# Tests pour ide.sh (intégration IDE)
# =============================================================================

load 'test_helper'

IDE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/ide.sh"

setup() {
    setup_test_dir
    TEST_PROJECT="$TEST_DIR/test-project"
    mkdir -p "$TEST_PROJECT"
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base
# =============================================================================

@test "ide.sh existe et est exécutable" {
    [[ -x "$IDE_SCRIPT" ]]
}

@test "ide.sh --help affiche l'aide" {
    run "$IDE_SCRIPT" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"setup"* ]]
    [[ "$output" == *"vscode"* ]]
    [[ "$output" == *"idea"* ]]
}

@test "ide.sh --version affiche la version" {
    run "$IDE_SCRIPT" --version
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"IDE Integration"* ]]
}

@test "ide.sh -h est équivalent à --help" {
    run "$IDE_SCRIPT" -h
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
}

@test "ide.sh -v est équivalent à --version" {
    run "$IDE_SCRIPT" -v
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"IDE"* ]]
}

# =============================================================================
# Tests d'erreur
# =============================================================================

@test "ide.sh sans arguments affiche l'aide" {
    run "$IDE_SCRIPT"
    [[ "$status" -eq 1 ]] || [[ "$output" == *"USAGE"* ]]
}

@test "ide.sh avec commande invalide échoue" {
    run "$IDE_SCRIPT" invalid-command vscode
    [[ "$status" -ne 0 ]]
}

@test "ide.sh avec IDE invalide échoue" {
    run "$IDE_SCRIPT" setup invalid-ide
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# Tests VSCode setup
# =============================================================================

@test "ide.sh setup vscode crée le répertoire .vscode" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
}

@test "ide.sh setup vscode crée settings.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/settings.json" ]]
}

@test "ide.sh setup vscode crée tasks.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/tasks.json" ]]
}

@test "ide.sh setup vscode crée extensions.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/extensions.json" ]]
}

@test "ide.sh setup vscode crée les snippets" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/claude-socle.code-snippets" ]]
}

@test "settings.json contient la configuration Claude" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "formatOnSave" "$TEST_PROJECT/.vscode/settings.json"
    grep -q "eslint" "$TEST_PROJECT/.vscode/settings.json"
}

@test "tasks.json contient les tâches Claude" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "Claude" "$TEST_PROJECT/.vscode/tasks.json"
    grep -q "validate.sh" "$TEST_PROJECT/.vscode/tasks.json"
    grep -q "doctor.sh" "$TEST_PROJECT/.vscode/tasks.json"
}

@test "extensions.json contient les recommandations" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "recommendations" "$TEST_PROJECT/.vscode/extensions.json"
    grep -q "prettier" "$TEST_PROJECT/.vscode/extensions.json"
    grep -q "eslint" "$TEST_PROJECT/.vscode/extensions.json"
}

@test "snippets contient les commandes Claude" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "work-explore" "$TEST_PROJECT/.vscode/claude-socle.code-snippets"
    grep -q "work-plan" "$TEST_PROJECT/.vscode/claude-socle.code-snippets"
    grep -q "dev-tdd" "$TEST_PROJECT/.vscode/claude-socle.code-snippets"
}

# =============================================================================
# Tests VSCode check
# =============================================================================

@test "ide.sh check vscode détecte configuration complète" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    run "$IDE_SCRIPT" check vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"complète"* ]] || [[ "$output" == *"✓"* ]]
}

@test "ide.sh check vscode détecte configuration manquante" {
    run "$IDE_SCRIPT" check vscode "$TEST_PROJECT"
    [[ "$output" == *"manquant"* ]] || [[ "$output" == *"⚠"* ]] || [[ "$output" == *"✗"* ]]
}

# =============================================================================
# Tests VSCode remove
# =============================================================================

@test "ide.sh remove vscode supprime la configuration" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ -d "$TEST_PROJECT/.vscode" ]]

    run "$IDE_SCRIPT" remove vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -f "$TEST_PROJECT/.vscode/settings.json" ]]
}

# =============================================================================
# Tests IntelliJ setup
# =============================================================================

@test "ide.sh setup idea crée le répertoire .idea" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea" ]]
}

@test "ide.sh setup idea crée les run configurations" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea/runConfigurations" ]]
}

@test "ide.sh setup idea crée le code style" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea/codeStyles" ]]
}

@test "run configurations IntelliJ contiennent les scripts Claude" {
    "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Validate.xml" ]]
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Doctor.xml" ]]
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Test.xml" ]]
}

# =============================================================================
# Tests Vim setup
# =============================================================================

@test "ide.sh setup vim crée .vimrc.claude" {
    run "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test ".vimrc.claude contient les abréviations Claude" {
    "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    grep -q "cexplore" "$TEST_PROJECT/.vimrc.claude"
    grep -q "cplan" "$TEST_PROJECT/.vimrc.claude"
    grep -q "ccommit" "$TEST_PROJECT/.vimrc.claude"
}

@test ".vimrc.claude contient les mappings" {
    "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    grep -q "nnoremap" "$TEST_PROJECT/.vimrc.claude"
    grep -q "validate.sh" "$TEST_PROJECT/.vimrc.claude"
}

# =============================================================================
# Tests all
# =============================================================================

@test "ide.sh setup all configure tous les IDE" {
    run "$IDE_SCRIPT" setup all "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
    [[ -d "$TEST_PROJECT/.idea" ]]
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test "ide.sh check all vérifie tous les IDE" {
    "$IDE_SCRIPT" setup all "$TEST_PROJECT"
    run "$IDE_SCRIPT" check all "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Tests --force
# =============================================================================

@test "ide.sh setup --force écrase les fichiers existants" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    echo "modified" >> "$TEST_PROJECT/.vscode/settings.json"

    run "$IDE_SCRIPT" setup vscode --force "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    ! grep -q "modified" "$TEST_PROJECT/.vscode/settings.json"
}

# =============================================================================
# Tests cursor (alias vscode)
# =============================================================================

@test "ide.sh setup cursor équivaut à vscode" {
    run "$IDE_SCRIPT" setup cursor "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
}

# =============================================================================
# Tests de structure
# =============================================================================

@test "ide.sh source la librairie commune" {
    grep -q "source.*lib/common.sh" "$IDE_SCRIPT"
}

@test "ide.sh utilise set -euo pipefail" {
    grep -q "set -euo pipefail" "$IDE_SCRIPT"
}
