#!/bin/bash

# =============================================================================
# Claude-Socle Learn Script
# Tutoriel interactif pour apprendre à utiliser claude-socle
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Variables
MODE="interactive"      # interactive, quick, agent
SELECTED_AGENT=""
SCORE=0
TOTAL_QUESTIONS=0
CURRENT_LESSON=0

# =============================================================================
# Aide et version
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Learn${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Tutoriel interactif pour apprendre à utiliser claude-socle.
    Découvrez les agents, le workflow et les bonnes pratiques.

${BOLD}OPTIONS${NC}
    -h, --help              Affiche cette aide
    -v, --version           Affiche la version
    -q, --quick             Mode rapide (5 minutes)
    -a, --agent AGENT       Apprendre un agent spécifique
    -l, --list              Liste les agents disponibles pour l'apprentissage
    --reset                 Réinitialiser la progression

${BOLD}EXEMPLES${NC}
    # Tutoriel complet interactif
    $(basename "$0")

    # Version courte (5 min)
    $(basename "$0") --quick

    # Apprendre un agent spécifique
    $(basename "$0") --agent tdd
    $(basename "$0") --agent commit

    # Voir les agents disponibles
    $(basename "$0") --list

${BOLD}AGENTS POPULAIRES${NC}
    work-explore    Explorer et comprendre le code
    work-plan       Planifier une implémentation
    work-commit     Créer des commits propres
    dev-tdd         Développement TDD
    qa-review       Code review

EOF
}

show_version() {
    echo "Claude-Socle Learn v${VERSION}"
}

# =============================================================================
# Utilitaires d'affichage
# =============================================================================

clear_screen() {
    clear 2>/dev/null || printf '\033[2J\033[H'
}

print_header() {
    local title="$1"
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $title${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_progress() {
    local current="$1"
    local total="$2"
    local width=40
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "  Progression: ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d/%d\n\n" "$current" "$total"
}

print_score() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║          VOTRE SCORE                  ║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════╣${NC}"

    local percentage=0
    if [[ $TOTAL_QUESTIONS -gt 0 ]]; then
        percentage=$((SCORE * 100 / TOTAL_QUESTIONS))
    fi

    local color="$RED"
    local level="Débutant"
    if [[ $percentage -ge 80 ]]; then
        color="$GREEN"
        level="Expert"
    elif [[ $percentage -ge 60 ]]; then
        color="$YELLOW"
        level="Intermédiaire"
    elif [[ $percentage -ge 40 ]]; then
        color="$CYAN"
        level="Apprenti"
    fi

    printf "${BOLD}║${NC}  Bonnes réponses: ${color}%d/%d${NC}             ${BOLD}║${NC}\n" "$SCORE" "$TOTAL_QUESTIONS"
    printf "${BOLD}║${NC}  Pourcentage:     ${color}%d%%${NC}                  ${BOLD}║${NC}\n" "$percentage"
    printf "${BOLD}║${NC}  Niveau:          ${color}%s${NC}           ${BOLD}║${NC}\n" "$level"
    echo -e "${BOLD}╚═══════════════════════════════════════╝${NC}"
    echo ""
}

wait_for_enter() {
    echo ""
    echo -e "${DIM}Appuyez sur Entrée pour continuer...${NC}"
    read -r
}

# =============================================================================
# Quiz et questions
# =============================================================================

ask_question() {
    local question="$1"
    local correct="$2"
    shift 2
    local options=("$@")

    ((TOTAL_QUESTIONS++))

    echo -e "${CYAN}Question:${NC} $question"
    echo ""

    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $opt"
        ((i++))
    done

    echo ""
    prompt "Votre réponse (1-${#options[@]}):"
    read -r -n 1 answer
    echo ""

    if [[ "$answer" == "$correct" ]]; then
        ((SCORE++))
        echo -e "${GREEN}✓ Correct !${NC}"
        return 0
    else
        echo -e "${RED}✗ Incorrect.${NC} La bonne réponse était: $correct"
        return 1
    fi
}

ask_yes_no() {
    local question="$1"
    local correct="$2"  # "y" ou "n"

    ((TOTAL_QUESTIONS++))

    echo -e "${CYAN}Vrai ou Faux:${NC} $question"
    echo ""
    echo "  1) Vrai"
    echo "  2) Faux"
    echo ""
    prompt "Votre réponse (1-2):"
    read -r -n 1 answer
    echo ""

    local user_answer="n"
    [[ "$answer" == "1" ]] && user_answer="y"

    if [[ "$user_answer" == "$correct" ]]; then
        ((SCORE++))
        echo -e "${GREEN}✓ Correct !${NC}"
        return 0
    else
        local expected="Faux"
        [[ "$correct" == "y" ]] && expected="Vrai"
        echo -e "${RED}✗ Incorrect.${NC} La bonne réponse était: $expected"
        return 1
    fi
}

# =============================================================================
# Leçons
# =============================================================================

lesson_introduction() {
    clear_screen
    print_header "LEÇON 1: Introduction à claude-socle"

    cat << 'EOF'
Bienvenue dans le tutoriel claude-socle !

Claude-socle est un template de configuration pour Claude Code qui vous aide à :

  • Structurer votre workflow de développement
  • Utiliser 79 agents spécialisés
  • Suivre les meilleures pratiques
  • Automatiser les tâches répétitives

EOF

    echo -e "${BOLD}Le workflow principal :${NC}"
    echo ""
    echo "  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐"
    echo "  │ EXPLORE │───▶│  PLAN   │───▶│  CODE   │───▶│ COMMIT  │"
    echo "  └─────────┘    └─────────┘    └─────────┘    └─────────┘"
    echo ""
    echo -e "${DIM}Ce workflow garantit que vous comprenez le code avant de le modifier.${NC}"

    wait_for_enter

    # Quiz
    echo ""
    ask_question "Quelle est la première étape du workflow ?" "1" \
        "Explore" "Plan" "Code" "Commit"

    wait_for_enter
}

lesson_workflow() {
    clear_screen
    print_header "LEÇON 2: Le Workflow Explore → Plan → Code → Commit"

    cat << 'EOF'
Chaque étape du workflow a un rôle précis :

EOF

    echo -e "${BOLD}1. EXPLORE${NC} (/project:work-explore)"
    echo "   Comprendre le code existant AVANT de modifier"
    echo "   → Identifier les patterns et conventions en place"
    echo ""

    echo -e "${BOLD}2. PLAN${NC} (/project:work-plan)"
    echo "   Proposer une architecture AVANT d'implémenter"
    echo "   → Lister les fichiers à créer/modifier"
    echo "   → Attendre validation avant de coder"
    echo ""

    echo -e "${BOLD}3. CODE${NC} (/project:dev-tdd ou direct)"
    echo "   Implémenter en suivant le plan validé"
    echo "   → Tests first si applicable (TDD)"
    echo ""

    echo -e "${BOLD}4. COMMIT${NC} (/project:work-commit)"
    echo "   Message de commit descriptif"
    echo "   → Conventional Commits (feat, fix, refactor...)"
    echo ""

    wait_for_enter

    # Quiz
    ask_yes_no "On peut coder directement sans explorer d'abord" "n"
    wait_for_enter

    ask_question "Que fait l'étape PLAN ?" "2" \
        "Exécute les tests" \
        "Propose une architecture avant d'implémenter" \
        "Crée le commit" \
        "Déploie en production"

    wait_for_enter
}

lesson_agents() {
    clear_screen
    print_header "LEÇON 3: Les Agents Spécialisés"

    cat << 'EOF'
Claude-socle inclut 79 agents organisés en catégories :

EOF

    echo -e "${BOLD}WORK-${NC} : Workflow principal (8 agents)"
    echo "  /project:work-explore, /project:work-plan, /project:work-commit..."
    echo ""

    echo -e "${BOLD}DEV-${NC} : Développement (10 agents)"
    echo "  /project:dev-tdd, /project:dev-test, /project:dev-refactor..."
    echo ""

    echo -e "${BOLD}QA-${NC} : Qualité (8 agents)"
    echo "  /project:qa-review, /project:qa-security, /project:qa-perf..."
    echo ""

    echo -e "${BOLD}OPS-${NC} : Opérations (16 agents)"
    echo "  /project:ops-hotfix, /project:ops-release, /project:ops-docker..."
    echo ""

    echo -e "${BOLD}DOC-${NC} : Documentation (9 agents)"
    echo "  /project:doc-generate, /project:doc-changelog, /project:doc-readme..."
    echo ""

    echo -e "${DIM}Astuce: Utilisez /project:assistant pour obtenir de l'aide sur le choix d'agent${NC}"

    wait_for_enter

    # Quiz
    ask_question "Combien d'agents sont disponibles au total ?" "3" \
        "50" "65" "79" "100"

    wait_for_enter

    ask_question "Quelle catégorie utiliser pour un audit de sécurité ?" "2" \
        "DEV-" "QA-" "OPS-" "DOC-"

    wait_for_enter
}

lesson_tdd() {
    clear_screen
    print_header "LEÇON 4: Test-Driven Development (TDD)"

    cat << 'EOF'
Le TDD est une approche où on écrit les tests AVANT le code.

EOF

    echo -e "${BOLD}Le cycle TDD : Red → Green → Refactor${NC}"
    echo ""
    echo "  ┌─────────┐"
    echo "  │   RED   │ ← Écrire un test qui échoue"
    echo "  └────┬────┘"
    echo "       │"
    echo "       ▼"
    echo "  ┌─────────┐"
    echo "  │  GREEN  │ ← Écrire le code minimum pour passer"
    echo "  └────┬────┘"
    echo "       │"
    echo "       ▼"
    echo "  ┌──────────┐"
    echo "  │ REFACTOR │ ← Améliorer le code"
    echo "  └────┬─────┘"
    echo "       │"
    echo "       └──────▶ Répéter"
    echo ""

    echo -e "${CYAN}Commande:${NC} /project:dev-tdd [feature]"
    echo ""
    echo -e "${DIM}Exemple: /project:dev-tdd validation email${NC}"

    wait_for_enter

    # Quiz
    ask_question "Dans le cycle TDD, que fait-on en premier ?" "1" \
        "Écrire un test qui échoue (RED)" \
        "Écrire le code de production" \
        "Refactoriser" \
        "Déployer"

    wait_for_enter
}

lesson_commits() {
    clear_screen
    print_header "LEÇON 5: Conventional Commits"

    cat << 'EOF'
Les messages de commit suivent un format standardisé :

    type(scope): description

EOF

    echo -e "${BOLD}Types principaux :${NC}"
    echo ""
    echo "  ${GREEN}feat${NC}     → Nouvelle fonctionnalité"
    echo "  ${YELLOW}fix${NC}      → Correction de bug"
    echo "  ${BLUE}refactor${NC} → Refactoring (pas de changement fonctionnel)"
    echo "  ${CYAN}test${NC}     → Ajout/modification de tests"
    echo "  ${MAGENTA}docs${NC}     → Documentation"
    echo "  ${DIM}chore${NC}    → Maintenance, dépendances"
    echo ""

    echo -e "${BOLD}Exemples :${NC}"
    echo "  feat(auth): add OAuth2 Google login"
    echo "  fix(api): handle null response from server"
    echo "  refactor(utils): extract validation helpers"
    echo ""

    echo -e "${CYAN}Commande:${NC} /project:work-commit"

    wait_for_enter

    # Quiz
    ask_question "Quel type pour une nouvelle fonctionnalité ?" "1" \
        "feat" "fix" "refactor" "chore"

    wait_for_enter

    ask_question "Quel type pour une correction de bug ?" "2" \
        "feat" "fix" "refactor" "docs"

    wait_for_enter
}

lesson_practice() {
    clear_screen
    print_header "LEÇON 6: Mise en Pratique"

    cat << 'EOF'
Voyons un exemple complet de workflow !

Scénario : Ajouter une fonctionnalité de validation d'email

EOF

    echo -e "${BOLD}Étape 1: Explorer${NC}"
    echo -e "  ${CYAN}/project:work-explore${NC} le système de validation actuel"
    echo ""

    echo -e "${BOLD}Étape 2: Planifier${NC}"
    echo -e "  ${CYAN}/project:work-plan${NC} ajouter validation email avec regex"
    echo ""

    echo -e "${BOLD}Étape 3: Coder en TDD${NC}"
    echo -e "  ${CYAN}/project:dev-tdd${NC} email validation function"
    echo ""

    echo -e "${BOLD}Étape 4: Review${NC}"
    echo -e "  ${CYAN}/project:qa-review${NC} les changements"
    echo ""

    echo -e "${BOLD}Étape 5: Commit${NC}"
    echo -e "  ${CYAN}/project:work-commit${NC}"
    echo ""

    echo -e "${DIM}Ou utilisez le workflow complet :${NC}"
    echo -e "  ${CYAN}/project:work-flow-feature${NC} \"validation email\""

    wait_for_enter

    # Quiz final
    ask_question "Pour une nouvelle feature, quel workflow utiliser ?" "4" \
        "/project:ops-hotfix" \
        "/project:work-flow-bugfix" \
        "/project:qa-security" \
        "/project:work-flow-feature"

    wait_for_enter
}

# =============================================================================
# Mode Quick
# =============================================================================

quick_tutorial() {
    clear_screen
    print_header "TUTORIEL RAPIDE (5 min)"
    print_progress 0 4

    cat << 'EOF'
Bienvenue ! Voici l'essentiel de claude-socle en 5 minutes.

═══════════════════════════════════════════════════════════════
                    LE WORKFLOW PRINCIPAL
═══════════════════════════════════════════════════════════════

  EXPLORE → PLAN → CODE → COMMIT

  1. Explorer le code existant avant de modifier
  2. Planifier les changements
  3. Coder (en TDD si possible)
  4. Commiter avec un message clair

EOF
    wait_for_enter

    clear_screen
    print_header "TUTORIEL RAPIDE (5 min)"
    print_progress 1 4

    cat << 'EOF'
═══════════════════════════════════════════════════════════════
                    COMMANDES ESSENTIELLES
═══════════════════════════════════════════════════════════════

  /project:work-explore [cible]   → Comprendre le code
  /project:work-plan [feature]    → Planifier
  /project:work-commit            → Créer un commit
  /project:dev-tdd [feature]      → Développer en TDD
  /project:qa-review              → Code review

  /project:assistant              → Aide pour choisir un agent

EOF
    wait_for_enter

    clear_screen
    print_header "TUTORIEL RAPIDE (5 min)"
    print_progress 2 4

    cat << 'EOF'
═══════════════════════════════════════════════════════════════
                    WORKFLOWS COMPLETS
═══════════════════════════════════════════════════════════════

  Pour une nouvelle feature :
    /project:work-flow-feature "description"

  Pour un bugfix :
    /project:work-flow-bugfix "description"

  Pour une release :
    /project:work-flow-release "v2.0.0"

  Ces workflows combinent automatiquement les bonnes étapes !

EOF
    wait_for_enter

    clear_screen
    print_header "TUTORIEL RAPIDE (5 min)"
    print_progress 3 4

    cat << 'EOF'
═══════════════════════════════════════════════════════════════
                    BONNES PRATIQUES
═══════════════════════════════════════════════════════════════

  ✓ Toujours explorer avant de modifier
  ✓ Planifier avant de coder
  ✓ Écrire des tests (couverture > 80%)
  ✓ Messages de commit: type(scope): description
  ✓ Utiliser les workflows complets pour les tâches courantes

  ✗ Ne jamais coder sans comprendre l'existant
  ✗ Ne pas commit sans review
  ✗ Ne pas push --force sur main

EOF
    wait_for_enter

    clear_screen
    print_header "TUTORIEL RAPIDE (5 min)"
    print_progress 4 4

    echo -e "${GREEN}Félicitations !${NC} Vous connaissez maintenant l'essentiel."
    echo ""
    echo "Pour aller plus loin :"
    echo "  • Lancez le tutoriel complet : ./scripts/learn.sh"
    echo "  • Apprenez un agent : ./scripts/learn.sh --agent tdd"
    echo "  • Consultez la doc : docs/GUIDE.md"
    echo ""

    SCORE=4
    TOTAL_QUESTIONS=4
    print_score
}

# =============================================================================
# Mode Agent spécifique
# =============================================================================

learn_agent() {
    local agent="$1"
    # shellcheck disable=SC2034  # Used for path resolution
    local agent_file="$SOCLE_DIR/.claude/commands/${agent}.md"

    # Normaliser le nom de l'agent
    agent="${agent#work-}"
    agent="${agent#dev-}"
    agent="${agent#qa-}"
    agent="${agent#ops-}"
    agent="${agent#doc-}"

    # Trouver le fichier de l'agent
    local found=""
    for prefix in "" "work-" "dev-" "qa-" "ops-" "doc-" "biz-" "growth-" "data-" "legal-"; do
        if [[ -f "$SOCLE_DIR/.claude/commands/${prefix}${agent}.md" ]]; then
            found="$SOCLE_DIR/.claude/commands/${prefix}${agent}.md"
            agent="${prefix}${agent}"
            break
        fi
    done

    if [[ -z "$found" ]]; then
        error "Agent '$agent' non trouvé. Utilisez --list pour voir les agents disponibles."
    fi

    clear_screen
    print_header "APPRENTISSAGE: /project:$agent"

    # Extraire les informations de l'agent
    echo -e "${BOLD}Description:${NC}"
    head -20 "$found" | grep -A 5 "^#" | head -6
    echo ""

    echo -e "${BOLD}Quand utiliser cet agent:${NC}"
    grep -i "quand\|when\|utiliser\|use" "$found" | head -5 || echo "  Consultez la documentation complète"
    echo ""

    echo -e "${BOLD}Exemple d'utilisation:${NC}"
    echo "  /project:$agent [arguments]"
    echo ""

    echo -e "${DIM}Fichier: $found${NC}"

    wait_for_enter

    # Quiz spécifique à l'agent
    case "$agent" in
        *tdd*)
            ask_question "Le TDD commence par ?" "1" \
                "Écrire un test qui échoue" \
                "Écrire le code" \
                "Refactoriser"
            ;;
        *commit*)
            ask_question "Format d'un message de commit ?" "2" \
                "description: type" \
                "type(scope): description" \
                "scope-type-description"
            ;;
        *review*)
            ask_question "Que vérifie une code review ?" "4" \
                "Uniquement les bugs" \
                "Uniquement le style" \
                "Uniquement la sécurité" \
                "Qualité, lisibilité, bugs, sécurité"
            ;;
        *security*)
            ask_question "OWASP Top 10 concerne ?" "2" \
                "Les 10 meilleurs frameworks" \
                "Les 10 vulnérabilités web les plus critiques" \
                "Les 10 langages les plus sûrs"
            ;;
        *)
            ask_yes_no "Cet agent fait partie des 79 agents disponibles" "y"
            ;;
    esac

    echo ""
    print_score
}

list_agents() {
    print_header "AGENTS DISPONIBLES POUR L'APPRENTISSAGE"

    echo -e "${BOLD}Workflow (WORK-)${NC}"
    echo "  explore, plan, commit, pr, flow-feature, flow-bugfix, flow-release"
    echo ""

    echo -e "${BOLD}Développement (DEV-)${NC}"
    echo "  tdd, test, debug, refactor, api, component, hook"
    echo ""

    echo -e "${BOLD}Qualité (QA-)${NC}"
    echo "  review, security, perf, a11y, audit, coverage"
    echo ""

    echo -e "${BOLD}Opérations (OPS-)${NC}"
    echo "  hotfix, release, docker, deps, ci, monitoring"
    echo ""

    echo -e "${BOLD}Documentation (DOC-)${NC}"
    echo "  generate, changelog, readme, explain, architecture"
    echo ""

    echo -e "${DIM}Usage: ./scripts/learn.sh --agent <nom>${NC}"
    echo -e "${DIM}Exemple: ./scripts/learn.sh --agent tdd${NC}"
}

# =============================================================================
# Tutoriel complet interactif
# =============================================================================

interactive_tutorial() {
    local lessons=(
        "lesson_introduction"
        "lesson_workflow"
        "lesson_agents"
        "lesson_tdd"
        "lesson_commits"
        "lesson_practice"
    )
    local total=${#lessons[@]}

    clear_screen
    print_header "BIENVENUE DANS LE TUTORIEL CLAUDE-SOCLE"

    cat << 'EOF'
Ce tutoriel interactif vous guidera à travers :

  1. Introduction à claude-socle
  2. Le workflow Explore → Plan → Code → Commit
  3. Les 79 agents spécialisés
  4. Le développement TDD
  5. Les Conventional Commits
  6. Mise en pratique

Durée estimée : 15-20 minutes

EOF

    prompt "Prêt à commencer ? (O/n)"
    read -r -n 1 start
    echo ""

    if [[ "$start" =~ ^[Nn]$ ]]; then
        echo "À bientôt !"
        exit 0
    fi

    # Exécuter chaque leçon
    for i in "${!lessons[@]}"; do
        CURRENT_LESSON=$((i + 1))
        clear_screen
        print_progress "$CURRENT_LESSON" "$total"
        ${lessons[$i]}
    done

    # Résultat final
    clear_screen
    print_header "TUTORIEL TERMINÉ"

    print_score

    echo ""
    echo -e "${BOLD}Prochaines étapes :${NC}"
    echo ""
    echo "  1. Essayez /project:work-explore sur votre projet"
    echo "  2. Planifiez une feature avec /project:work-plan"
    echo "  3. Consultez docs/CHEATSHEET.md pour la référence rapide"
    echo ""

    if [[ $TOTAL_QUESTIONS -gt 0 ]] && [[ $((SCORE * 100 / TOTAL_QUESTIONS)) -ge 80 ]]; then
        echo -e "${GREEN}Excellent travail ! Vous êtes prêt à utiliser claude-socle !${NC}"
    else
        echo -e "${YELLOW}Relancez le tutoriel pour améliorer votre score !${NC}"
    fi
    echo ""
}

# =============================================================================
# Parse arguments
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -q|--quick)
                MODE="quick"
                shift
                ;;
            -a|--agent)
                MODE="agent"
                SELECTED_AGENT="$2"
                shift 2
                ;;
            -l|--list)
                list_agents
                exit 0
                ;;
            --reset)
                info "Progression réinitialisée"
                exit 0
                ;;
            *)
                error "Option inconnue: $1. Utilisez --help pour l'aide."
                ;;
        esac
    done
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"

    case "$MODE" in
        quick)
            quick_tutorial
            ;;
        agent)
            learn_agent "$SELECTED_AGENT"
            ;;
        interactive)
            interactive_tutorial
            ;;
    esac
}

main "$@"
