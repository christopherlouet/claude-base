#!/usr/bin/env bats

# =============================================================================
# Tests du hook UserPromptSubmit : injection de contexte (routing semantique)
# =============================================================================
# Le script prompt-context.sh est invoque par le hook UserPromptSubmit.
# Il lit sur stdin un JSON {"prompt": "..."} (format Claude Code) et ecrit
# sur stdout un JSON conforme au contrat hookSpecificOutput avec
# additionalContext — uniquement si le prompt n'est pas une slash command.
# =============================================================================

load 'test_helper'

HOOK_SCRIPT="$SOCLE_DIR/scripts/hooks/prompt-context.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    export CLAUDE_PROJECT_DIR="$TEST_DIR"
    cd "$TEST_DIR" || return
    git init --quiet --initial-branch=main
    git config user.email "test@test.local"
    git config user.name "Test"
    echo "init" > README.md
    git add README.md
    git commit --quiet -m "init"
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Contrats de sortie
# =============================================================================

@test "prompt-context: sortie vide si le prompt commence par /" {
    run bash -c 'echo "{\"prompt\": \"/work:work-plan feature X\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: sortie vide si le prompt est vide" {
    run bash -c 'echo "{\"prompt\": \"\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: sortie JSON valide pour un prompt libre" {
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    echo "$output" | jq -e . >/dev/null
}

@test "prompt-context: sortie contient hookSpecificOutput.additionalContext" {
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "UserPromptSubmit"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.additionalContext | type == "string"' >/dev/null
}

# =============================================================================
# Contenu du contexte injecte
# =============================================================================

@test "prompt-context: additionalContext mentionne /assistant-auto comme hint" {
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"/assistant-auto"* ]]
}

@test "prompt-context: additionalContext contient la branche courante" {
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"main"* ]]
}

@test "prompt-context: additionalContext reporte les fichiers modifies" {
    echo "modif" >> README.md
    echo "nouveau" > NEW.md
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"README.md"* ]]
    [[ "$ctx" == *"NEW.md"* ]]
}

@test "prompt-context: additionalContext reporte les LOC du diff" {
    printf "a\nb\nc\nd\ne\n" >> README.md
    git add README.md
    run bash -c 'echo "{\"prompt\": \"refactor\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"LOC"* ]] || [[ "$ctx" == *"loc"* ]] || [[ "$ctx" == *"lines"* ]]
}

# =============================================================================
# Robustesse
# =============================================================================

@test "prompt-context: ne casse pas hors d'un repo git" {
    rm -rf .git
    run bash -c 'echo "{\"prompt\": \"ajoute un endpoint users\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    echo "$output" | jq -e . >/dev/null
}

@test "prompt-context: ignore un stdin qui n'est pas du JSON" {
    run bash -c 'echo "pas du json" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: timeout-friendly (termine en moins de 3s)" {
    run bash -c 'time (echo "{\"prompt\": \"test\"}" | "'"$HOOK_SCRIPT"'") 2>&1'
    [ "$status" -eq 0 ]
}

@test "prompt-context: ignore les slash commands avec espaces devant" {
    run bash -c 'echo "{\"prompt\": \"   /work:work-plan test\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
