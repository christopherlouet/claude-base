#!/bin/bash

# =============================================================================
# Claude-Socle Audit Script
# Valide la sante du socle : frontmatter SKILL.md, liens doc, schemas,
# coherence entre composants. Complement de validate-counts.sh qui ne
# verifie que les compteurs.
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
${BOLD}Claude-Socle Audit${NC}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Audit complet du socle. Verifie :
    - Frontmatter des skills (champs requis, syntaxe YAML)
    - Frontmatter des agents (name, description, tools)
    - Frontmatter des rules (paths si specifique)
    - Liens relatifs dans docs/ (fichiers cibles existent)
    - Coherence nom de dossier vs frontmatter.name

${BOLD}OPTIONS${NC}
    -h, --help      Afficher cette aide
    -v, --verbose   Afficher tous les checks (pas seulement les erreurs)
    --fix           Tenter de corriger les problemes simples (description manquante, etc.)

${BOLD}EXIT CODES${NC}
    0    Aucun probleme trouve
    1    Problemes detectes (voir output)

${BOLD}EXEMPLES${NC}
    $(basename "$0")              # Audit complet
    $(basename "$0") --verbose    # Avec tous les checks
EOF
}

# =============================================================================
# Variables
# =============================================================================

VERBOSE=false
ISSUES=0
CHECKED=0

# =============================================================================
# Parsing arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        --fix) echo "${YELLOW}Mode --fix pas encore implemente${NC}"; shift ;;
        *) echo "${RED}Option inconnue: $1${NC}"; show_help; exit 1 ;;
    esac
done

# =============================================================================
# Helpers
# =============================================================================

report_issue() {
    local file="$1"
    local issue="$2"
    echo "${RED}[X]${NC} ${file}: ${issue}"
    ((ISSUES++)) || true
}

report_ok() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "${GREEN}[OK]${NC} $1"
    fi
    ((CHECKED++)) || true
}

# Extract frontmatter field value from a markdown file
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '
        /^---$/ { fm = !fm; next }
        fm && $0 ~ "^"field":" {
            sub("^"field":[[:space:]]*", "")
            gsub(/^["'\''"]|["'\''"]$/, "")
            print
            exit
        }
    ' "$file"
}

# =============================================================================
# Audit: Skills frontmatter
# =============================================================================

audit_skills() {
    echo "${BOLD}[INFO] Audit des skills...${NC}"
    local skills_dir="$SOCLE_DIR/.claude/skills"

    [[ ! -d "$skills_dir" ]] && return 0

    while IFS= read -r -d '' skill_file; do
        local skill_dir
        skill_dir=$(dirname "$skill_file")
        local expected_name
        expected_name=$(basename "$skill_dir")
        local rel_path="${skill_file#"$SOCLE_DIR"/}"

        # Check: frontmatter delimiters
        if ! head -1 "$skill_file" | grep -q '^---$'; then
            report_issue "$rel_path" "frontmatter missing (no leading ---)"
            continue
        fi

        # Check: name field
        local name
        name=$(get_frontmatter_field "$skill_file" "name")
        if [[ -z "$name" ]]; then
            report_issue "$rel_path" "missing 'name' field"
        elif [[ "$name" != "$expected_name" ]]; then
            report_issue "$rel_path" "name='$name' but dir='$expected_name'"
        fi

        # Check: description field
        local desc
        desc=$(get_frontmatter_field "$skill_file" "description")
        if [[ -z "$desc" ]]; then
            report_issue "$rel_path" "missing 'description' field"
        elif [[ ${#desc} -lt 20 ]]; then
            report_issue "$rel_path" "description too short (${#desc} chars, min 20)"
        fi

        # Check: file size (SKILL.md should be under 500 lines per best practices)
        local lines
        lines=$(wc -l < "$skill_file")
        if [[ $lines -gt 500 ]]; then
            report_issue "$rel_path" "SKILL.md is $lines lines (recommended < 500, split to reference files)"
        fi

        report_ok "$rel_path"
    done < <(find "$skills_dir" -mindepth 2 -name "SKILL.md" -print0)
}

# =============================================================================
# Audit: Agents frontmatter
# =============================================================================

audit_agents() {
    echo "${BOLD}[INFO] Audit des agents...${NC}"
    local agents_dir="$SOCLE_DIR/.claude/agents"

    [[ ! -d "$agents_dir" ]] && return 0

    while IFS= read -r -d '' agent_file; do
        local rel_path="${agent_file#"$SOCLE_DIR"/}"

        if ! head -1 "$agent_file" | grep -q '^---$'; then
            report_issue "$rel_path" "frontmatter missing"
            continue
        fi

        local name
        name=$(get_frontmatter_field "$agent_file" "name")
        if [[ -z "$name" ]]; then
            report_issue "$rel_path" "missing 'name' field"
        fi

        local desc
        desc=$(get_frontmatter_field "$agent_file" "description")
        if [[ -z "$desc" ]]; then
            report_issue "$rel_path" "missing 'description' field"
        fi

        report_ok "$rel_path"
    done < <(find "$agents_dir" -maxdepth 2 -name "*.md" -print0)
}

# =============================================================================
# Audit: Rules frontmatter (paths)
# =============================================================================

audit_rules() {
    echo "${BOLD}[INFO] Audit des rules...${NC}"
    local rules_dir="$SOCLE_DIR/.claude/rules"

    [[ ! -d "$rules_dir" ]] && return 0

    while IFS= read -r -d '' rule_file; do
        local name
        name=$(basename "$rule_file" .md)
        [[ "$name" == "README" ]] && continue

        local rel_path="${rule_file#"$SOCLE_DIR"/}"

        # Rules MAY have frontmatter with paths, but it's not required (global rules)
        if head -1 "$rule_file" | grep -q '^---$'; then
            # If frontmatter exists, check paths field
            if ! grep -q '^paths:' "$rule_file" 2>/dev/null; then
                # Frontmatter without paths is OK (could be other metadata)
                :
            fi
        fi

        # Check if rule is registered in README.md
        if ! grep -q "\`$name\`" "$rules_dir/README.md" 2>/dev/null; then
            report_issue "$rel_path" "not registered in .claude/rules/README.md"
        fi

        report_ok "$rel_path"
    done < <(find "$rules_dir" -maxdepth 1 -name "*.md" -print0)
}

# =============================================================================
# Audit: Broken relative links in docs/
# =============================================================================

audit_doc_links() {
    echo "${BOLD}[INFO] Audit des liens dans docs/...${NC}"
    local docs_dir="$SOCLE_DIR/docs"

    [[ ! -d "$docs_dir" ]] && return 0

    while IFS= read -r -d '' doc_file; do
        local rel_path="${doc_file#"$SOCLE_DIR"/}"
        local doc_dir
        doc_dir=$(dirname "$doc_file")

        # Extract markdown relative links: [text](./path.md) or [text](../path.md)
        while IFS= read -r link; do
            [[ -z "$link" ]] && continue

            # Resolve relative to doc's directory
            local target
            target=$(cd "$doc_dir" && realpath -m "$link" 2>/dev/null || echo "")

            # Strip anchor if present
            target="${target%%#*}"

            if [[ -n "$target" ]] && [[ ! -e "$target" ]]; then
                report_issue "$rel_path" "broken link: $link"
            fi
        done < <(grep -oE '\]\((\./|\.\./)[^)]+\.md[^)]*\)' "$doc_file" 2>/dev/null | sed 's/^](\(.*\))$/\1/' | tr -d ')')

        report_ok "$rel_path"
    done < <(find "$docs_dir" -name "*.md" -print0)
}

# =============================================================================
# Audit: Counts coherence (delegue a validate-counts.sh)
# =============================================================================

audit_counts() {
    echo "${BOLD}[INFO] Audit des compteurs (via validate-counts.sh)...${NC}"
    if ! bash "$SCRIPT_DIR/validate-counts.sh" > /dev/null 2>&1; then
        # Re-run and capture output for display
        local output
        output=$(bash "$SCRIPT_DIR/validate-counts.sh" 2>&1 | grep -E "^\[X\]" || true)
        if [[ -n "$output" ]]; then
            while IFS= read -r line; do
                echo "${RED}$line${NC}"
                ((ISSUES++)) || true
            done <<< "$output"
        fi
    fi
}

# =============================================================================
# Main
# =============================================================================

cd "$SOCLE_DIR"

echo "${BOLD}=== Claude-Socle Audit ===${NC}"
echo ""

audit_skills
audit_agents
audit_rules
audit_doc_links
audit_counts

echo ""
echo "${BOLD}=== Resultat ===${NC}"
echo "Checks effectues : $CHECKED"

if [[ $ISSUES -eq 0 ]]; then
    echo "${GREEN}[OK]${NC} Aucun probleme detecte"
    exit 0
else
    echo "${RED}[X]${NC} $ISSUES probleme(s) detecte(s)"
    exit 1
fi
