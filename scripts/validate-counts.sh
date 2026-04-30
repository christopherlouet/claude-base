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
    --mixed        Mode bilingue temporaire (FR/EN coexistent pendant la
                   migration FR->EN). Layer 2 (scan_drift global) reste
                   strict, Layer 1 patterns FR-specifiques tolerent un miss.

${BOLD}EXEMPLES${NC}
    $(basename "$0")
    $(basename "$0") --verbose
    $(basename "$0") --fix
    $(basename "$0") --mixed   # pendant la migration FR->EN
EOF
}

# =============================================================================
# Variables
# =============================================================================

ERRORS=0
SHOW_FIX=false
MIXED=false

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
        --mixed)
            MIXED=true
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

if $MIXED; then
    info "Mode --mixed actif (migration FR->EN en cours)"
    echo ""
fi

info "Comptage des fichiers reels..."
echo ""

# Count commands (md files in commands/ subdirectories, exclude README.md index files)
ACTUAL_COMMANDS=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -not -name "README.md" -type f | wc -l)

# Count agents (exclude README.md index files)
ACTUAL_AGENTS=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l)

# Count skills (directories with SKILL.md)
ACTUAL_SKILLS=$(find "$SOCLE_DIR/.claude/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l)

# Count rules (exclude README.md index files)
ACTUAL_RULES=$(find "$SOCLE_DIR/.claude/rules" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l)

# Count tests (count `@test` lines across .bats files — fast, static, no execution)
ACTUAL_TESTS=$(awk '/^@test/{n++} END{print n+0}' "$SOCLE_DIR"/tests/*.bats 2>/dev/null || echo 0)
ACTUAL_TEST_FILES=$(find "$SOCLE_DIR/tests" -name "*.bats" -type f 2>/dev/null | wc -l)

echo "  Commands : $ACTUAL_COMMANDS"
echo "  Agents   : $ACTUAL_AGENTS"
echo "  Skills   : $ACTUAL_SKILLS"
echo "  Rules    : $ACTUAL_RULES"
echo "  Tests    : $ACTUAL_TESTS (in $ACTUAL_TEST_FILES files)"
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
# Layer 2 : Scan anti-drift global (catch any stale total-counter)
# =============================================================================
# Detecte tout chiffre qui apparait dans un contexte "compteur total" mais qui
# ne correspond pas au canonique. Patterns ciblés (faible faux-positif) :
#   - `Label (N)`     : ex. `Skills (47)`, `Agents (63)`, `WORK (12)`
#   - `(N) Label`     : ex. `(54) skills disponibles`
#   - `**N Label**`   : ex. `**54 skills**`
#   - `'N Label'`     : ex. `'131 Commands'` dans composants TS/TSX
# Exclusions : CHANGELOG (historique), node_modules, build, .docusaurus, memory.

info "Scan anti-drift global..."
echo ""

DRIFT_ERRORS=0

scan_drift() {
    local label_singular="$1"   # "skill"
    local label_plural="$2"     # "skills"
    local actual="$3"           # 54

    # Patterns CIBLES = uniquement des contextes qui parlent du TOTAL.
    # On evite "15 work commands" (subset par domaine), "22 Haiku agents" (par modele), etc.
    # Cas catalogues comme "TOTAL" :
    #   1. `Label disponibles (N)`             -- ex. `Skills disponibles (54)` (French canonical header)
    #   2. `## Label (N)` / `### Label (N)`    -- heading markdown, ex. `## Skills (54)`
    #   3. `'N Label'` / `'N Sub-Agents'`      -- string literal in TS/TSX components
    #   4. `\*\*Label\*\* \| N \|`             -- table row with bold label cell
    #   5. `# Label (N)`                        -- top heading
    # Le label peut etre singulier (Skill) ou pluriel (Skills), Capitalize ou ALLCAPS.
    # La forme `Sub-Agents` est acceptee pour agent.
    local label_cap_singular label_cap_plural alt_form
    label_cap_singular="$(echo "${label_singular:0:1}" | tr '[:lower:]' '[:upper:]')${label_singular:1}"
    label_cap_plural="$(echo "${label_plural:0:1}" | tr '[:lower:]' '[:upper:]')${label_plural:1}"
    alt_form=""
    [[ "$label_singular" == "agent" ]] && alt_form="|Sub-Agents?|sub-agents?"

    # Construire la regex unifiee
    local lab="(${label_cap_singular}|${label_cap_plural}${alt_form})"
    local pattern_re="(${lab}\s+disponibles?\s+\(([0-9]+)\)|^#{1,4}\s+${lab}\s+\(([0-9]+)\)|'([0-9]+)\s+${lab}'|\|\s*\*\*${lab}\*\*\s*\|\s*([0-9]+)\s*\||^#{1,4}\s+([0-9]+)\s+${lab}\b)"

    while IFS= read -r match; do
        [[ -z "$match" ]] && continue
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"

        # Skip le scanner lui-meme
        [[ "$file_part" == *"validate-counts.sh"* ]] && continue

        # Extraire le ou les chiffres dans le contexte total
        local nums
        nums=$(echo "$content" | grep -oiE "${pattern_re}" | grep -oE '[0-9]+' | sort -u)

        for n in $nums; do
            [[ "$n" -le 5 ]] && continue
            if [[ "$n" != "$actual" ]]; then
                local rel="${file_part#"$SOCLE_DIR"/}"
                error_no_exit "${rel}:${line_num} drift → $n ${label_plural} (canonique: $actual)"
                DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
            fi
        done
    done < <(
        grep -rniE "$pattern_re" \
            --include="*.md" --include="*.ts" --include="*.tsx" --include="*.json" \
            --exclude-dir=node_modules --exclude-dir=.git \
            --exclude-dir=build --exclude-dir=.docusaurus \
            --exclude-dir=memory \
            --exclude="CHANGELOG.md" \
            "$SOCLE_DIR" 2>/dev/null
    )
}

scan_drift "command" "commands" "$ACTUAL_COMMANDS"
scan_drift "agent" "agents" "$ACTUAL_AGENTS"
scan_drift "skill" "skills" "$ACTUAL_SKILLS"
scan_drift "rule" "rules" "$ACTUAL_RULES"

# -----------------------------------------------------------------------------
# Scan drift dedie aux compteurs de tests (patterns specifiques README badge
# shields.io + section "Test layout")
# -----------------------------------------------------------------------------
scan_tests_drift() {
    local actual_tests="$1"
    local actual_files="$2"

    # Pattern 1 : badge shields.io `tests-N+passing` ou `tests-N%20passing`
    while IFS= read -r match; do
        [[ -z "$match" ]] && continue
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"
        [[ "$file_part" == *"validate-counts.sh"* ]] && continue
        local n
        n=$(echo "$content" | grep -oiE 'tests-[0-9]+' | grep -oE '[0-9]+' | head -1)
        if [[ -n "$n" ]] && [[ "$n" != "$actual_tests" ]]; then
            local rel="${file_part#"$SOCLE_DIR"/}"
            error_no_exit "${rel}:${line_num} drift → tests-$n badge (canonique: $actual_tests)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
    done < <(
        grep -rniE 'tests-[0-9]+(%20|\+| )passing' \
            --include="*.md" --include="*.ts" --include="*.tsx" \
            --exclude-dir=node_modules --exclude-dir=.git \
            --exclude-dir=build --exclude-dir=.docusaurus \
            --exclude-dir=memory \
            --exclude="CHANGELOG.md" \
            "$SOCLE_DIR" 2>/dev/null
    )

    # Pattern 2 : `(N files, M tests)` capture les deux compteurs
    while IFS= read -r match; do
        [[ -z "$match" ]] && continue
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"
        [[ "$file_part" == *"validate-counts.sh"* ]] && continue
        local nf nt rel
        nf=$(echo "$content" | grep -oE '\([0-9]+ files?' | grep -oE '[0-9]+' | head -1)
        nt=$(echo "$content" | grep -oE '[0-9]+ tests\)' | grep -oE '[0-9]+' | head -1)
        rel="${file_part#"$SOCLE_DIR"/}"
        if [[ -n "$nf" ]] && [[ "$nf" != "$actual_files" ]]; then
            error_no_exit "${rel}:${line_num} drift → $nf test files (canonique: $actual_files)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
        if [[ -n "$nt" ]] && [[ "$nt" != "$actual_tests" ]]; then
            error_no_exit "${rel}:${line_num} drift → $nt tests (canonique: $actual_tests)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
    done < <(
        grep -rnE '\([0-9]+ files?,\s*[0-9]+ tests\)' \
            --include="*.md" --include="*.ts" --include="*.tsx" \
            --exclude-dir=node_modules --exclude-dir=.git \
            --exclude-dir=build --exclude-dir=.docusaurus \
            --exclude-dir=memory \
            --exclude="CHANGELOG.md" \
            "$SOCLE_DIR" 2>/dev/null
    )
}

scan_tests_drift "$ACTUAL_TESTS" "$ACTUAL_TEST_FILES"

if [[ "$DRIFT_ERRORS" -eq 0 ]]; then
    success "Aucun drift detecte (scan global)"
else
    error_no_exit "$DRIFT_ERRORS drift(s) detecte(s) (scan global)"
    ERRORS=$((ERRORS + DRIFT_ERRORS))
fi

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
