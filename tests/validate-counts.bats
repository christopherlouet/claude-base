#!/usr/bin/env bats

# =============================================================================
# Tests pour validate-counts.sh (Layer 1 + Layer 2 anti-drift scan)
#
# Strategie d'isolation : on construit un faux socle dans TEST_DIR, on copie
# le script + sa librairie commune dedans, et on l'execute. Le script utilise
# `dirname(BASH_SOURCE)` donc il scanne TEST_DIR au lieu du vrai repo.
# Aucun risque de polluer le repo reel.
# =============================================================================

load 'test_helper'

VALIDATE_COUNTS_SCRIPT_REAL="$BATS_TEST_DIRNAME/../scripts/validate-counts.sh"

setup() {
    setup_test_dir

    # Construire un faux socle minimal dans TEST_DIR avec des compteurs connus :
    # 3 commands, 2 agents, 1 skill, 4 rules, 5 tests, 1 test file
    mkdir -p "$TEST_DIR/.claude/commands/work"
    mkdir -p "$TEST_DIR/.claude/agents"
    mkdir -p "$TEST_DIR/.claude/skills/sample-skill"
    mkdir -p "$TEST_DIR/.claude/rules"
    mkdir -p "$TEST_DIR/scripts/lib"
    mkdir -p "$TEST_DIR/tests"
    mkdir -p "$TEST_DIR/website/src/pages"
    mkdir -p "$TEST_DIR/website/src/components"
    mkdir -p "$TEST_DIR/website/docs/intro"
    mkdir -p "$TEST_DIR/website/docs/reference"

    touch "$TEST_DIR/.claude/commands/work/cmd1.md" \
          "$TEST_DIR/.claude/commands/work/cmd2.md" \
          "$TEST_DIR/.claude/commands/work/cmd3.md"
    touch "$TEST_DIR/.claude/agents/agent1.md" \
          "$TEST_DIR/.claude/agents/agent2.md"
    touch "$TEST_DIR/.claude/skills/sample-skill/SKILL.md"
    touch "$TEST_DIR/.claude/rules/rule1.md" \
          "$TEST_DIR/.claude/rules/rule2.md" \
          "$TEST_DIR/.claude/rules/rule3.md" \
          "$TEST_DIR/.claude/rules/rule4.md"

    # 1 fichier de test avec 5 @test → ACTUAL_TESTS=5, ACTUAL_TEST_FILES=1
    # NB: on n'utilise PAS un heredoc avec @test litteral, car bats preprocess
    # les @test lignes des fichiers .bats meme dans les heredocs et les casse.
    # printf evite la collision avec le preprocessor bats.
    {
        echo "#!/usr/bin/env bats"
        printf '@test "test%s" { :; }\n' 1 2 3 4 5
    } > "$TEST_DIR/tests/sample.bats"

    # Copier le script et sa librairie (le script resoudera SOCLE_DIR=TEST_DIR)
    cp "$VALIDATE_COUNTS_SCRIPT_REAL" "$TEST_DIR/scripts/validate-counts.sh"
    cp -r "$BATS_TEST_DIRNAME/../scripts/lib/"* "$TEST_DIR/scripts/lib/"
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"

    # Path du script copie pour les tests
    VALIDATE_SCRIPT="$TEST_DIR/scripts/validate-counts.sh"
    export VALIDATE_SCRIPT
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de base (smoke)
# =============================================================================

@test "validate-counts.sh existe et est executable" {
    [ -f "$VALIDATE_COUNTS_SCRIPT_REAL" ]
    [ -x "$VALIDATE_COUNTS_SCRIPT_REAL" ]
}

@test "validate-counts.sh affiche l'aide avec --help" {
    run "$VALIDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"compteurs"* ]] || [[ "$output" == *"Validate"* ]]
}

@test "validate-counts.sh sur un faux socle coherent : exit 0" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}

@test "validate-counts.sh affiche les compteurs reels dans sa sortie" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    # Le faux socle a 3 commands / 2 agents / 1 skill / 4 rules / 5 tests
    # Assertions souples (regex) car bats peut normaliser les espaces.
    [[ "$output" =~ Commands[[:space:]]*:[[:space:]]*3 ]]
    [[ "$output" =~ Agents[[:space:]]*:[[:space:]]*2 ]]
    [[ "$output" =~ Skills[[:space:]]*:[[:space:]]*1 ]]
    [[ "$output" =~ Rules[[:space:]]*:[[:space:]]*4 ]]
    [[ "$output" =~ Tests[[:space:]]*:[[:space:]]*5 ]]
}

# =============================================================================
# Tests Layer 1 — Source-of-truth files
# =============================================================================

@test "validate-counts.sh detecte un drift dans CLAUDE.md (commands)" {
    # Creer un CLAUDE.md avec un compteur faux : "999 commandes" au lieu de 3
    cat > "$TEST_DIR/CLAUDE.md" <<'EOF'
# Test
Le socle a 999 commandes.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"999"* ]] || [[ "$output" == *"incohérence"* ]]
}

# =============================================================================
# Tests Layer 2 — Scan global anti-drift (scan_drift)
# =============================================================================

@test "scan_drift Layer 2 : detecte le pattern 'Skills (N)' header markdown" {
    # On a 1 skill reel mais on declare 99 dans une heading markdown
    cat > "$TEST_DIR/website/docs/intro/architecture.md" <<'EOF'
# Architecture

## Skills (99)
Les skills auto-declenches.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"99 skills"* ]]
    [[ "$output" == *"canonique: 1"* ]]
}

@test "scan_drift Layer 2 : detecte le pattern 'N Sub-Agents' string literal TS" {
    # On a 2 agents reels mais on declare 88 dans un literal TSX
    cat > "$TEST_DIR/website/src/pages/index.tsx" <<'EOF'
const stats = ['88 Sub-Agents', '3 Commands'];
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]] || [[ "$output" == *"88 sub-agents"* ]]
}

@test "scan_drift Layer 2 : detecte le pattern '| **Rules** | N |' table cell bold" {
    # On a 4 rules reelles mais on declare 77 dans un tableau markdown
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Stats

| Composant | Nombre |
|-----------|--------|
| **Rules** | 77 |
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"77 rules"* ]]
}

@test "scan_drift Layer 2 : detecte le pattern 'Skills disponibles (N)'" {
    cat > "$TEST_DIR/.claude/skills/README.md" <<'EOF'
# Skills

## Skills disponibles (66)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"66 skills"* ]]
}

# =============================================================================
# Tests Layer 2 — scan_tests_drift (badges + Test layout)
# =============================================================================

@test "scan_tests_drift : detecte le pattern badge 'tests-N passing'" {
    # On a 5 tests reels mais le badge declare 200
    cat > "$TEST_DIR/README.md" <<'EOF'
# Test
[![Tests](https://img.shields.io/badge/tests-200%20passing-brightgreen)](./tests)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"tests-200"* ]]
    # canonique = ACTUAL_TESTS du faux socle (5)
    [[ "$output" =~ canonique:[[:space:]]*5 ]]
}

@test "scan_tests_drift : detecte le pattern '(N files, M tests)' Test layout" {
    # On a 1 test file et 5 tests reels mais on declare 17 et 999
    cat > "$TEST_DIR/README.md" <<'EOF'
# Test
### Test layout (17 files, 999 tests)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"17 test files"* ]] || [[ "$output" == *"17"* ]]
    [[ "$output" == *"999 tests"* ]]
}

# =============================================================================
# Tests anti-faux-positifs
# =============================================================================

@test "scan_drift : ne flag PAS les nombres <= 5 (subset/exemple)" {
    # 1 skill reel, mais on mentionne "3 skills" dans une heading
    # Le scan doit ignorer les nombres <= 5 pour eviter de flag les exemples
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Test

## Skills (3)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift : ne flag PAS les sous-totaux par domaine (WORK 15)" {
    # On declare "WORK (15)" qui est un sous-total domain, pas un total canonique
    # Le scan ne doit PAS flag car le pattern label est WORK, pas Skills/Agents/Rules/Commands
    cat > "$TEST_DIR/website/sidebars.ts" <<'EOF'
const sidebars = {
  commands: [
    { label: 'WORK (15)' },
    { label: 'OPS (34)' }
  ]
};
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift : ne flag PAS le CHANGELOG (historique)" {
    # Le CHANGELOG contient des refs historiques aux anciens compteurs
    # Le scan doit l'exclure explicitement
    cat > "$TEST_DIR/CHANGELOG.md" <<'EOF'
# Changelog

## v0.1.0
- 41 skills released
- 21 rules added
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Tests d'integration : le vrai repo doit toujours passer
# =============================================================================

@test "validate-counts.sh sur le VRAI repo : exit 0 (regression test)" {
    run "$VALIDATE_COUNTS_SCRIPT_REAL"
    [ "$status" -eq 0 ]
    [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}
