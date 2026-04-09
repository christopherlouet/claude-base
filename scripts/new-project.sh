#!/bin/bash

# =============================================================================
# Claude-Socle New Project Script
# Crée un nouveau projet ou configure un projet existant avec Claude Code
# =============================================================================

set -euo pipefail

VERSION=$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/VERSION" 2>/dev/null || echo "1.1.0")

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/detection.sh
source "$SCRIPT_DIR/lib/detection.sh"
# shellcheck source=lib/generators.sh
source "$SCRIPT_DIR/lib/generators.sh"
# shellcheck source=lib/docker.sh
source "$SCRIPT_DIR/lib/docker.sh"

# Activer le handler d'erreur et vérifier les prérequis
enable_error_handler
check_base_requirements

# Path constants
COMMANDS_DIR=".claude/commands"
AGENTS_DIR=".claude/agents"
SKILLS_DIR=".claude/skills"
RULES_DIR=".claude/rules"
STYLES_DIR=".claude/output-styles"
TEMPLATES_DIR=".claude/templates"

# Cached counts (computed once, reused everywhere)
_CACHED_CMD_COUNT=""
_CACHED_AGENT_COUNT=""
_CACHED_SKILL_COUNT=""

count_commands_cached() {
    if [[ -z "$_CACHED_CMD_COUNT" ]]; then
        _CACHED_CMD_COUNT=$(find "$SOCLE_DIR/$COMMANDS_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "$_CACHED_CMD_COUNT"
}

count_agents_cached() {
    if [[ -z "$_CACHED_AGENT_COUNT" ]]; then
        _CACHED_AGENT_COUNT=$(find "$SOCLE_DIR/$AGENTS_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "$_CACHED_AGENT_COUNT"
}

count_skills_cached() {
    if [[ -z "$_CACHED_SKILL_COUNT" ]]; then
        _CACHED_SKILL_COUNT=$(count_skills "$SOCLE_DIR")
    fi
    echo "$_CACHED_SKILL_COUNT"
}

# Variables du projet
PROJECT_NAME=""
PROJECT_TYPE=""
PROJECT_PATH=""
PARENT_PATH=""
EXISTING_PROJECT=false
INCLUDE_CICD=false
INCLUDE_HOOKS=false
INCLUDE_MCP=false
INCLUDE_DOCKER=false
NON_INTERACTIVE=false
FORCE_TYPE=""

# Nouvelles options (mode simple / installation directe)
SIMPLE_MODE=false
SKIP_PROMPTS=false
DESIGN_STYLE=""

# Variables de détection (used by lib/detection.sh functions)
DETECTED_TYPE=""
DETECTED_FRAMEWORK=""
DETECTED_CICD=false
DETECTED_HOOKS=false
DETECTED_DOCKER=false
# shellcheck disable=SC2034  # Used by lib/detection.sh
DETECTED_DEPENDENCIES=()
DETECTED_SCRIPTS=()
DETECTED_FOLDERS=()
# shellcheck disable=SC2034  # Used by lib/detection.sh
DETECTED_MAIN_DEPS=()
DETECTED_PKG_MANAGER="npm"

# Variables d'analyse CI/CD
CICD_MISSING=()
CICD_PRESENT=()
CICD_ACTION="skip"

# =============================================================================
# Aide et version
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle New Project${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Crée un nouveau projet ou configure un projet existant avec Claude Code.
    Installe commandes, agents et skills pour le workflow Explore → Plan → Code → Commit.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Chemin vers un projet existant à configurer (optionnel)
                        Si omis, crée un nouveau projet interactivement

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -y, --yes           Mode non-interactif (accepte les valeurs par défaut)
    -n, --dry-run       Simule l'installation sans rien copier
    -q, --quiet         Mode silencieux (erreurs uniquement)
    --verbose           Mode verbeux (debug)
    -t, --type TYPE     Force le type de projet (react, vue, node-api, python, go, rust, java, fullstack, generic)
    -p, --path CHEMIN   Dossier parent où créer le projet (défaut: répertoire courant)
    --ci                Inclut GitHub Actions (CI/CD)
    --hooks             Inclut pre-commit hooks (husky)
    --mcp               Inclut configuration MCP
    --docker            Inclut Dockerfile
    --all               Inclut toutes les options (ci, hooks, mcp, docker)
    --style STYLE       Direction design (terminal, cockpit, vitality, editorial, glass, signal)
    --skip-prompts      Saute les questions optionnelles (utilise les flags fournis)
    --simple            Mode installation simple (équivalent à l'ancien install.sh)
    --install-only      Alias pour --simple

${BOLD}EXEMPLES${NC}
    # Nouveau projet interactif
    $(basename "$0")

    # Nouveau projet dans un dossier spécifique
    $(basename "$0") --path ~/projects

    # Configurer un projet existant
    $(basename "$0") ./mon-projet

    # Mode non-interactif avec détection auto
    $(basename "$0") -y ./mon-projet

    # Nouveau projet React avec CI/CD dans un dossier spécifique
    $(basename "$0") -y -t react --ci --path /var/www mon-app

    # Projet React avec direction design
    $(basename "$0") -y -t react --style vitality ./mon-app

    # Tout inclure
    $(basename "$0") -y --all ./mon-projet

    # Mode simple (installation rapide sans détection)
    $(basename "$0") --simple .
    $(basename "$0") --simple --all ./mon-projet

    # Mode dry-run (simulation)
    $(basename "$0") --dry-run --simple .
    $(basename "$0") -n -y ./mon-projet

    # Mode verbeux pour debug
    $(basename "$0") --verbose ./mon-projet

${BOLD}TYPES DE PROJET${NC}
    react       React / Next.js
    vue         Vue.js / Nuxt.js
    node-api    Node.js API (Express, Fastify, NestJS)
    python      Python (Django, FastAPI, Flask)
    go          Go (Gin, Echo, Fiber)
    rust        Rust (Actix, Axum, Rocket)
    java        Java / Spring Boot
    fullstack   Monorepo (Turborepo, Nx)
    flutter     Flutter / Dart (iOS, Android, Web)
    neovim      Neovim / Lua config
    generic     Autre / Générique

${BOLD}FICHIERS INSTALLÉS${NC}
    .claude/commands/       Commandes Claude Code
    .claude/skills/         Skills spécialisés
    .claude/agents/         Agents avec contexte isolé
    .claude/rules/          Règles contextuelles par path
    .claude/output-styles/  Styles de sortie
    .claude/templates/      Templates (spec, Proxmox, etc.)
    .claude/settings.json   Hooks configurés
    CLAUDE.md               Instructions du projet (généré intelligemment)

${BOLD}PLUS D'INFOS${NC}
    https://github.com/anthropics/claude-code
EOF
}

show_version() {
    echo "claude-socle new-project v${VERSION}"
}

# =============================================================================
# Parsing des arguments
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
            -y|--yes)
                NON_INTERACTIVE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                export QUIET=true
                shift
                ;;
            --verbose)
                export VERBOSE=true
                shift
                ;;
            -t|--type)
                FORCE_TYPE="$2"
                shift 2
                ;;
            -p|--path)
                PARENT_PATH="$2"
                shift 2
                ;;
            --ci)
                INCLUDE_CICD=true
                shift
                ;;
            --hooks)
                INCLUDE_HOOKS=true
                shift
                ;;
            --mcp)
                INCLUDE_MCP=true
                shift
                ;;
            --docker)
                INCLUDE_DOCKER=true
                shift
                ;;
            --all)
                INCLUDE_CICD=true
                INCLUDE_HOOKS=true
                INCLUDE_MCP=true
                INCLUDE_DOCKER=true
                shift
                ;;
            --style)
                DESIGN_STYLE="$2"
                shift 2
                ;;
            --skip-prompts)
                SKIP_PROMPTS=true
                shift
                ;;
            --simple|--install-only)
                SIMPLE_MODE=true
                NON_INTERACTIVE=true
                SKIP_PROMPTS=true
                shift
                ;;
            -*)
                error "Option inconnue: $1\nUtilisez --help pour l'aide"
                ;;
            *)
                # C'est un chemin de projet
                if [[ -z "$PROJECT_PATH" ]]; then
                    PROJECT_PATH="$1"
                else
                    error "Trop d'arguments: $1\nUtilisez --help pour l'aide"
                fi
                shift
                ;;
        esac
    done
}

# =============================================================================
# Analyse et amélioration CI/CD
# =============================================================================

analyze_existing_cicd() {
    local dir="$1"
    local missing=()
    local present=()

    # Reset des tableaux globaux
    CICD_MISSING=()
    CICD_PRESENT=()

    # Analyser GitHub Actions
    if [[ -d "$dir/.github/workflows" ]]; then
        local workflow_files
        workflow_files=$(ls "$dir/.github/workflows"/*.yml "$dir/.github/workflows"/*.yaml 2>/dev/null || true)

        if [[ -n "$workflow_files" ]]; then
            # Vérifier tests automatisés
            if echo "$workflow_files" | xargs grep -l "npm test\|yarn test\|pnpm test\|bun test\|pytest\|go test\|cargo test\|mvn test" &>/dev/null; then
                present+=("Tests automatisés")
            else
                missing+=("Tests automatisés")
            fi

            # Vérifier lint
            if echo "$workflow_files" | xargs grep -l "eslint\|npm run lint\|yarn lint\|flake8\|pylint\|golint\|clippy" &>/dev/null; then
                present+=("Linting")
            else
                missing+=("Linting")
            fi

            # Vérifier security audit
            if echo "$workflow_files" | xargs grep -l "npm audit\|snyk\|safety\|gosec\|cargo audit\|trivy" &>/dev/null; then
                present+=("Audit sécurité")
            else
                missing+=("Audit sécurité")
            fi

            # Vérifier cache
            if echo "$workflow_files" | xargs grep -l "actions/cache" &>/dev/null; then
                present+=("Cache dépendances")
            else
                missing+=("Cache dépendances")
            fi

            # Vérifier coverage
            if echo "$workflow_files" | xargs grep -l "codecov\|coveralls\|coverage" &>/dev/null; then
                present+=("Upload couverture")
            else
                missing+=("Upload couverture")
            fi

            # Vérifier PR checks
            if [[ -f "$dir/.github/workflows/pr-check.yml" ]] || echo "$workflow_files" | xargs grep -l "pull_request.*opened\|commitlint\|semantic-pull-request" &>/dev/null; then
                present+=("Validation PR")
            else
                missing+=("Validation PR")
            fi

            # Vérifier release automation
            if echo "$workflow_files" | xargs grep -l "release\|changelog\|gh-release\|action-gh-release" &>/dev/null; then
                present+=("Release automatisée")
            else
                missing+=("Release automatisée")
            fi
        fi
    fi

    # Stocker les résultats
    CICD_MISSING=("${missing[@]}")
    CICD_PRESENT=("${present[@]}")
}

suggest_cicd_improvements() {
    echo ""
    info "Analyse de la CI/CD existante:"
    echo ""

    # Afficher les éléments présents
    for item in "${CICD_PRESENT[@]}"; do
        echo -e "  ${GREEN}✓${NC} $item"
    done

    # Afficher les éléments manquants
    for item in "${CICD_MISSING[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} Manquant: $item"
    done

    echo ""

    # Calculer et afficher le score
    local total=$((${#CICD_PRESENT[@]} + ${#CICD_MISSING[@]}))
    if [[ $total -gt 0 ]]; then
        local score=$((${#CICD_PRESENT[@]} * 100 / total))
        echo -e "  Score CI/CD: ${BOLD}${score}%${NC} (${#CICD_PRESENT[@]}/${total})"
    fi
    echo ""
}

get_cicd_choice() {
    echo ""
    prompt "GitHub Actions détecté. Que voulez-vous faire?"
    echo ""
    echo "  1) Garder l'existant (recommandé si score > 70%)"
    echo "  2) Ajouter les workflows manquants"
    echo "  3) Remplacer par les templates du socle"
    echo ""
    prompt "Choix [1-3] (défaut: 1):"
    read -r -n 1 choice
    echo ""

    case $choice in
        2) CICD_ACTION="merge" ;;
        3) CICD_ACTION="replace" ;;
        *) CICD_ACTION="skip" ;;
    esac
}

merge_cicd_workflows() {
    local dir="$1"
    local added_ci=false

    info "Ajout des workflows manquants..."

    # Créer le dossier workflows si nécessaire
    make_dir "$dir/.github/workflows"

    # Mapping des fonctionnalités manquantes vers les fichiers
    for missing in "${CICD_MISSING[@]}"; do
        case "$missing" in
            "Audit sécurité"|"Cache dépendances"|"Upload couverture"|"Tests automatisés"|"Linting")
                # Ces fonctionnalités sont dans ci.yml
                if [[ "$added_ci" == false ]] && [[ ! -f "$dir/.github/workflows/ci.yml" ]]; then
                    copy_file "$SOCLE_DIR/.github/workflows/ci.yml" "$dir/.github/workflows/"
                    success "ci.yml ajouté (lint, test, build, security)"
                    added_ci=true
                fi
                ;;
            "Validation PR")
                if [[ ! -f "$dir/.github/workflows/pr-check.yml" ]]; then
                    copy_file "$SOCLE_DIR/.github/workflows/pr-check.yml" "$dir/.github/workflows/"
                    success "pr-check.yml ajouté (validation PR, labels)"
                fi
                ;;
            "Release automatisée")
                if [[ ! -f "$dir/.github/workflows/release.yml" ]]; then
                    copy_file "$SOCLE_DIR/.github/workflows/release.yml" "$dir/.github/workflows/"
                    success "release.yml ajouté (changelog, GitHub Release)"
                fi
                ;;
        esac
    done
}

# =============================================================================
# Fonctions d'installation (mode simple / réutilisables)
# =============================================================================

# Retourne la liste des rules à copier selon le type de projet détecté.
# Les rules universelles sont toujours incluses. Les rules spécifiques
# ne sont copiées que si le langage correspondant est détecté.
# Arguments:
#   $1 - Type de projet détecté (react, vue, node-api, python, go, flutter, etc.)
# Output: Liste de noms de fichiers rules à copier (un par ligne)
get_rules_for_type() {
    local project_type="$1"

    # Rules universelles (toujours copiées)
    local rules=("git.md" "workflow.md" "tdd-enforcement.md" "verification.md" "security.md" "testing.md" "lsp.md" "README.md")

    # Rules spécifiques au type de projet
    case "$project_type" in
        react|vue|node-api|fullstack|generic)
            rules+=("typescript.md" "react.md" "nextjs.md" "accessibility.md" "performance.md" "api.md" "design-style.md")
            ;;
        flutter)
            rules+=("flutter.md" "design-style.md")
            ;;
        python)
            rules+=("python.md")
            ;;
        go)
            rules+=("go.md")
            ;;
        rust)
            rules+=("rust.md")
            ;;
        java)
            rules+=("java.md")
            ;;
    esac

    # Si type non reconnu ou generic, ajouter TS/web par défaut (cas le plus courant)
    if [[ "$project_type" == "generic" || -z "$project_type" ]]; then
        rules+=("typescript.md" "react.md" "accessibility.md" "performance.md" "api.md" "design-style.md")
    fi

    # Dédupliquer et retourner
    printf '%s\n' "${rules[@]}" | sort -u
}

# Copie les rules filtrées par type de projet
# Arguments:
#   $1 - Répertoire source des rules
#   $2 - Répertoire cible des rules
#   $3 - Type de projet détecté
copy_filtered_rules() {
    local source_dir="$1"
    local target_dir="$2"
    local project_type="$3"

    if [[ ! -d "$source_dir" ]]; then
        return
    fi

    local rules_list
    rules_list=$(get_rules_for_type "$project_type")
    local copied=0
    local skipped=0

    while IFS= read -r rule_file; do
        if [[ -f "$source_dir/$rule_file" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} cp $source_dir/$rule_file → $target_dir/$rule_file"
            else
                cp "$source_dir/$rule_file" "$target_dir/$rule_file"
            fi
            ((copied++)) || true
        fi
    done <<< "$rules_list"

    # Compter les rules non copiées
    local total_rules
    total_rules=$(find "$source_dir" -name "*.md" -maxdepth 1 | wc -l)
    skipped=$((total_rules - copied))

    if [[ $skipped -gt 0 ]]; then
        debug "Rules: $copied copiées, $skipped ignorées (langages non détectés)"
    fi
}

# Installe tous les fichiers .claude/ (commands, skills, agents, rules, etc.)
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
# Copies a socle subdirectory to target, with dry-run support
# Arguments:
#   $1 - Relative subdirectory (e.g. ".claude/commands")
#   $2 - Target base directory
#   $3 - Label for debug output
copy_socle_dir() {
    local subdir="$1"
    local target_dir="$2"
    local label="$3"

    if [[ -d "$SOCLE_DIR/$subdir" ]]; then
        # Check directory is not empty before copying
        if find "$SOCLE_DIR/$subdir" -maxdepth 1 -mindepth 1 -print -quit | grep -q .; then
            debug "Copie des $label..."
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/$subdir/* → $target_dir/$subdir/"
            else
                cp -r "$SOCLE_DIR/$subdir/"* "$target_dir/$subdir/"
            fi
        fi
    fi
}

install_claude_files() {
    local target_dir="$1"

    info "Installation des fichiers Claude..."

    # Créer la structure de base
    for dir in "$COMMANDS_DIR" "$SKILLS_DIR" "$AGENTS_DIR" "$RULES_DIR" "$STYLES_DIR" "$TEMPLATES_DIR"; do
        make_dir "$target_dir/$dir"
    done

    # Copier les sous-répertoires
    copy_socle_dir "$COMMANDS_DIR" "$target_dir" "commandes"
    copy_socle_dir "$SKILLS_DIR" "$target_dir" "skills"
    copy_socle_dir "$AGENTS_DIR" "$target_dir" "agents"
    copy_socle_dir "$STYLES_DIR" "$target_dir" "output-styles"
    copy_socle_dir "$TEMPLATES_DIR" "$target_dir" "templates"

    # Copier settings.json
    copy_file "$SOCLE_DIR/.claude/settings.json" "$target_dir/.claude/"

    # Copier les rules (filtrées par type de projet)
    debug "Copie des rules filtrées pour type: ${DETECTED_TYPE:-generic}..."
    copy_filtered_rules "$SOCLE_DIR/$RULES_DIR" "$target_dir/$RULES_DIR" "${DETECTED_TYPE:-generic}"

    # Copier docs/reference/ (requis pour les @imports de CLAUDE.md)
    if [[ -d "$SOCLE_DIR/docs/reference" ]]; then
        debug "Copie de docs/reference/ (requis pour @imports CLAUDE.md)..."
        make_dir "$target_dir/docs/reference"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/docs/reference/* → $target_dir/docs/reference/"
        else
            cp -r "$SOCLE_DIR/docs/reference/"* "$target_dir/docs/reference/"
        fi
    fi

    # Copier les docs supplementaires referencees par CLAUDE.md
    for doc_file in "docs/ARCHITECTURE.md" "docs/WORKFLOWS.md"; do
        if [[ -f "$SOCLE_DIR/$doc_file" ]]; then
            debug "Copie de $doc_file..."
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} cp $SOCLE_DIR/$doc_file → $target_dir/$doc_file"
            else
                cp "$SOCLE_DIR/$doc_file" "$target_dir/$doc_file"
            fi
        fi
    done

    # Copier docs/guides/ (reference dans CLAUDE.md)
    if [[ -d "$SOCLE_DIR/docs/guides" ]]; then
        debug "Copie de docs/guides/..."
        make_dir "$target_dir/docs/guides"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/docs/guides/* → $target_dir/docs/guides/"
        else
            cp -r "$SOCLE_DIR/docs/guides/"* "$target_dir/docs/guides/"
        fi
    fi

    # Copier .mcp.env.example si disponible
    if [[ -f "$SOCLE_DIR/.mcp.env.example" ]] && [[ ! -f "$target_dir/.mcp.env.example" ]]; then
        copy_file "$SOCLE_DIR/.mcp.env.example" "$target_dir/"
    fi

    success "Commandes, skills, agents, rules, styles, templates et docs copiés"
}

# Installe GitHub Actions
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
install_cicd_files() {
    local target_dir="$1"

    info "Installation de GitHub Actions..."
    make_dir "$target_dir/.github/workflows"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.github/workflows/* → $target_dir/.github/workflows/"
    else
        cp -r "$SOCLE_DIR/.github/workflows/"* "$target_dir/.github/workflows/"
    fi

    success "GitHub Actions installés"
}

# Installe pre-commit hooks (husky)
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
install_hooks_files() {
    local target_dir="$1"

    info "Installation des pre-commit hooks..."
    make_dir "$target_dir/.husky"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r husky + config files → $target_dir/"
    else
        cp -r "$SOCLE_DIR/.husky/"* "$target_dir/.husky/"
        cp "$SOCLE_DIR/.pre-commit-config.yaml" "$target_dir/" 2>/dev/null || true
        cp "$SOCLE_DIR/.lintstagedrc.json" "$target_dir/"
        cp "$SOCLE_DIR/.commitlintrc.json" "$target_dir/"
        if ! chmod +x "$target_dir/.husky/"* 2>/dev/null; then
                warning "Impossible de rendre les hooks husky exécutables"
            fi
    fi

    success "Pre-commit hooks installés"
}

# Installe la configuration MCP
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
install_mcp_file() {
    local target_dir="$1"

    info "Installation de la configuration MCP..."
    copy_file "$SOCLE_DIR/.mcp.json" "$target_dir/"
    success "Configuration MCP installée"
}

# Met à jour ou crée .gitignore
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
update_gitignore_file() {
    local target_dir="$1"

    if [[ -f "$target_dir/.gitignore" ]]; then
        if ! grep -q "CLAUDE.local.md" "$target_dir/.gitignore" 2>/dev/null; then
            if ! $DRY_RUN; then
                echo "" >> "$target_dir/.gitignore"
                echo "# Claude Code (l'utilisateur peut retirer ces lignes si besoin)" >> "$target_dir/.gitignore"
                echo ".claude/" >> "$target_dir/.gitignore"
                echo "CLAUDE.md" >> "$target_dir/.gitignore"
                echo "CLAUDE.local.md" >> "$target_dir/.gitignore"
                echo ".claude/settings.local.json" >> "$target_dir/.gitignore"
            else
                echo -e "${DIM}[DRY-RUN]${NC} Ajout entrées Claude à .gitignore"
            fi
            success ".gitignore mis à jour"
        fi
    else
        copy_file "$SOCLE_DIR/.gitignore" "$target_dir/"
        success ".gitignore créé"
    fi
}

# Installe CLAUDE.md (copie le template générique)
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
install_claude_md_file() {
    local target_dir="$1"

    if [[ -f "$target_dir/CLAUDE.md" ]]; then
        warning "CLAUDE.md existe déjà, ignoré"
    else
        copy_file "$SOCLE_DIR/CLAUDE.md" "$target_dir/"
        success "CLAUDE.md copié"
    fi

    # Injecter la direction design si spécifiée
    if [[ -n "$DESIGN_STYLE" ]] && [[ -f "$target_dir/CLAUDE.md" ]]; then
        if ! $DRY_RUN; then
            printf '\n## Design Direction\nStyle: %s\n' "$DESIGN_STYLE" >> "$target_dir/CLAUDE.md"
            success "Design direction ajoutée: $DESIGN_STYLE"
        else
            echo -e "${DIM}[DRY-RUN]${NC} Ajout Design Direction: $DESIGN_STYLE dans CLAUDE.md"
        fi
    fi

    # Copier CLAUDE.local.md.example
    if [[ ! -f "$target_dir/CLAUDE.local.md.example" ]]; then
        copy_file "$SOCLE_DIR/CLAUDE.local.md.example" "$target_dir/"
        success "CLAUDE.local.md.example copié"
    fi
}

# Affiche le résumé d'installation (mode simple)
print_simple_summary() {
    local target_dir="$1"

    echo ""
    separator "="
    success "Installation terminée!"
    separator "="
    echo ""

    info "Fichiers installés:"
    echo "  - .claude/commands/      ($(count_commands_cached) commandes)"
    echo "  - .claude/skills/        ($(count_skills_cached) skills)"
    echo "  - .claude/agents/        ($(count_agents_cached) agents)"
    local rules_count
    rules_count=$(find "$target_dir/$RULES_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  - .claude/rules/         ($rules_count règles contextuelles)"
    echo "  - .claude/output-styles/ (styles de sortie)"
    echo "  - .claude/templates/     (templates spec, Proxmox, etc.)"
    echo "  - .claude/settings.json  ($(count_hooks "$SOCLE_DIR") hooks)"
    echo "  - docs/reference/        (fichiers @import CLAUDE.md)"
    echo "  - docs/guides/           (guides par domaine)"
    echo "  - CLAUDE.md"
    echo "  - CLAUDE.local.md.example"
    echo ""

    info "Prochaines étapes:"
    echo "  1. Personnalisez CLAUDE.md selon votre projet"
    echo "  2. Copiez CLAUDE.local.md.example en CLAUDE.local.md"
    echo "  3. Lancez Claude Code: cd $target_dir && claude"
    echo ""

    info "Commandes disponibles:"
    echo "  /work:work-explore, /work:work-plan, /work:work-commit, etc."
    echo ""
}

# Exécution du mode simple (installation directe sans détection)
run_simple_mode() {
    local target_dir

    # Déterminer le répertoire cible
    if [[ -n "$PROJECT_PATH" ]]; then
        target_dir="$PROJECT_PATH"
    else
        target_dir="."
    fi

    # Convertir en chemin absolu
    if [[ ! -d "$target_dir" ]]; then
        if ! $DRY_RUN; then
            mkdir -p "$target_dir" || error "Impossible de créer le dossier: $target_dir"
        fi
    fi
    target_dir="$(get_absolute_path "$target_dir")"

    info "Installation de claude-socle dans: $target_dir"
    $DRY_RUN && warning "Mode dry-run activé - aucune modification ne sera effectuée"
    echo ""

    # Nettoyer les anciens fichiers Claude si le dossier existe
    if [[ -d "$target_dir/.claude" ]]; then
        clean_claude_dirs "$target_dir"
    fi

    # Installation des fichiers Claude
    install_claude_files "$target_dir"

    # Installation CLAUDE.md
    install_claude_md_file "$target_dir"

    # Composants optionnels
    $INCLUDE_CICD && install_cicd_files "$target_dir"
    $INCLUDE_HOOKS && install_hooks_files "$target_dir"
    $INCLUDE_MCP && install_mcp_file "$target_dir"
    $INCLUDE_DOCKER && create_dockerfile "$target_dir"

    # Mettre à jour .gitignore
    update_gitignore_file "$target_dir"

    # Initialiser git si pas déjà fait
    if [[ ! -d "$target_dir/.git" ]] && ! $DRY_RUN; then
        if (cd "$target_dir" && git init -q); then
            success "Repository git initialisé"
        else
            warning "Échec de git init dans $target_dir"
        fi
    fi

    # Afficher le résumé
    print_simple_summary "$target_dir"
}

# =============================================================================
# Génération intelligente du CLAUDE.md
# =============================================================================


# =============================================================================
# Fonctions principales
# =============================================================================

print_banner() {
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   █████╗ ██╗      █████╗ ██╗   ██╗██████╗ ███████╗           ║"
    echo "║  ██╔══██╗██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝           ║"
    echo "║  ██║  ╚═╝██║     ███████║██║   ██║██║  ██║█████╗             ║"
    echo "║  ██║  ██╗██║     ██╔══██║██║   ██║██║  ██║██╔══╝             ║"
    echo "║  ╚█████╔╝███████╗██║  ██║╚██████╔╝██████╔╝███████╗           ║"
    echo "║   ╚════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝           ║"
    echo "║                                                               ║"
    echo "║              SOCLE - Project Configuration                    ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

get_project_path() {
    # Si --path a été fourni, valider et utiliser
    if [[ -n "$PARENT_PATH" ]]; then
        # Convertir en chemin absolu
        if [[ "$PARENT_PATH" = /* ]]; then
            PARENT_PATH="$PARENT_PATH"
        else
            PARENT_PATH="$(cd "$PWD" && cd "$PARENT_PATH" 2>/dev/null && pwd)" || PARENT_PATH="$PWD/$PARENT_PATH"
        fi

        # Créer le dossier parent s'il n'existe pas
        if [[ ! -d "$PARENT_PATH" ]]; then
            if $NON_INTERACTIVE; then
                mkdir -p "$PARENT_PATH" || error "Impossible de créer le dossier: $PARENT_PATH"
            else
                warning "Le dossier '$PARENT_PATH' n'existe pas"
                prompt "Voulez-vous le créer? (Y/n)"
                read -r -n 1 CREATE_PARENT
                echo
                if [[ ! $CREATE_PARENT =~ ^[Nn]$ ]]; then
                    mkdir -p "$PARENT_PATH" || error "Impossible de créer le dossier: $PARENT_PATH"
                    success "Dossier créé: $PARENT_PATH"
                else
                    error "Dossier parent requis pour créer le projet"
                fi
            fi
        fi
        return
    fi

    # Mode interactif : demander le chemin
    if ! $NON_INTERACTIVE; then
        echo ""
        prompt "Dossier où créer le projet (défaut: répertoire courant):"
        read -r INPUT_PATH

        if [[ -n "$INPUT_PATH" ]]; then
            # Expansion du tilde
            INPUT_PATH="${INPUT_PATH/#\~/$HOME}"

            # Convertir en chemin absolu
            if [[ "$INPUT_PATH" = /* ]]; then
                PARENT_PATH="$INPUT_PATH"
            else
                PARENT_PATH="$PWD/$INPUT_PATH"
            fi

            # Créer si n'existe pas
            if [[ ! -d "$PARENT_PATH" ]]; then
                warning "Le dossier '$PARENT_PATH' n'existe pas"
                prompt "Voulez-vous le créer? (Y/n)"
                read -r -n 1 CREATE_PARENT
                echo
                if [[ ! $CREATE_PARENT =~ ^[Nn]$ ]]; then
                    mkdir -p "$PARENT_PATH" || error "Impossible de créer le dossier: $PARENT_PATH"
                    success "Dossier créé: $PARENT_PATH"
                else
                    PARENT_PATH="$PWD"
                    info "Utilisation du répertoire courant"
                fi
            fi
        else
            PARENT_PATH="$PWD"
        fi
    else
        PARENT_PATH="$PWD"
    fi
}

get_project_name() {
    if $EXISTING_PROJECT; then
        PROJECT_NAME=$(basename "$PROJECT_PATH")
        info "Projet existant: ${BOLD}$PROJECT_NAME${NC}"
        echo ""
        return
    fi

    # D'abord, obtenir le chemin parent
    get_project_path

    while true; do
        prompt "Nom du projet (ex: my-awesome-app):"
        read -r PROJECT_NAME

        if [[ -z "$PROJECT_NAME" ]]; then
            warning "Le nom du projet ne peut pas être vide"
            continue
        fi

        if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
            warning "Le nom doit commencer par une lettre et contenir uniquement lettres, chiffres, - et _"
            continue
        fi

        PROJECT_PATH="${PARENT_PATH}/${PROJECT_NAME}"

        if [[ -d "$PROJECT_PATH" ]]; then
            warning "Le dossier '$PROJECT_PATH' existe déjà"
            prompt "Voulez-vous l'utiliser quand même? (y/N)"
            read -r -n 1 USE_EXISTING
            echo
            if [[ $USE_EXISTING =~ ^[Yy]$ ]]; then
                break
            fi
        else
            break
        fi
    done
}

get_project_type() {
    echo ""
    prompt "Type de projet:"
    echo ""

    # Définir le choix par défaut basé sur la détection
    local default_choice=""
    case $DETECTED_TYPE in
        react)     default_choice="1" ;;
        vue)       default_choice="2" ;;
        node-api)  default_choice="3" ;;
        python)    default_choice="4" ;;
        go)        default_choice="5" ;;
        rust)      default_choice="6" ;;
        java)      default_choice="7" ;;
        fullstack) default_choice="8" ;;
        flutter)   default_choice="9" ;;
        neovim)    default_choice="10" ;;
        *)         default_choice="" ;;
    esac

    # Afficher les options avec indication du défaut
    print_option() {
        local num="$1"
        local label="$2"
        if [[ "$num" == "$default_choice" ]]; then
            echo -e "  ${GREEN}${num})${NC} ${BOLD}${label}${NC} ${GREEN}← détecté${NC}"
        else
            echo "  $num) $label"
        fi
    }

    print_option "1" "React / Next.js"
    print_option "2" "Vue.js"
    print_option "3" "Node.js API"
    print_option "4" "Python"
    print_option "5" "Go"
    print_option "6" "Rust"
    print_option "7" "Java / Spring Boot"
    print_option "8" "Fullstack (Monorepo)"
    print_option "9" "Flutter / Mobile"
    print_option "10" "Neovim / Lua"
    print_option "11" "Autre / Générique"
    echo ""

    if [[ -n "$default_choice" ]]; then
        prompt "Choix [1-11] (défaut: $default_choice): "
    else
        prompt "Choix [1-11]: "
    fi
    read -r choice

    # Utiliser le défaut si entrée vide
    if [[ -z "$choice" ]] && [[ -n "$default_choice" ]]; then
        choice="$default_choice"
    fi

    case $choice in
        1) PROJECT_TYPE="react" ;;
        2) PROJECT_TYPE="vue" ;;
        3) PROJECT_TYPE="node-api" ;;
        4) PROJECT_TYPE="python" ;;
        5) PROJECT_TYPE="go" ;;
        6) PROJECT_TYPE="rust" ;;
        7) PROJECT_TYPE="java" ;;
        8) PROJECT_TYPE="fullstack" ;;
        9) PROJECT_TYPE="flutter" ;;
        10) PROJECT_TYPE="neovim" ;;
        11) PROJECT_TYPE="generic" ;;
        *) PROJECT_TYPE="${DETECTED_TYPE:-generic}" ;;
    esac
}

get_options() {
    # Si --skip-prompts est activé, utiliser les flags fournis sans poser de questions
    if $SKIP_PROMPTS; then
        debug "Skip prompts activé - utilisation des flags CLI"
        # Respecter la détection pour éviter les doublons
        $DETECTED_CICD && INCLUDE_CICD=false
        $DETECTED_HOOKS && INCLUDE_HOOKS=false
        $DETECTED_DOCKER && INCLUDE_DOCKER=false
        return
    fi

    echo ""
    info "Options supplémentaires:"
    echo ""

    # CI/CD
    if $DETECTED_CICD; then
        # Analyser la CI/CD existante et proposer des améliorations
        analyze_existing_cicd "$PROJECT_PATH"
        suggest_cicd_improvements

        if [[ ${#CICD_MISSING[@]} -gt 0 ]]; then
            get_cicd_choice
        else
            echo -e "  ${GREEN}✓${NC} CI/CD complète, aucune amélioration suggérée"
            CICD_ACTION="skip"
        fi
        INCLUDE_CICD=false
    else
        if $EXISTING_PROJECT; then
            prompt "Ajouter GitHub Actions (CI/CD)? (Y/n)"
        else
            prompt "Inclure GitHub Actions (CI/CD)? (Y/n)"
        fi
        read -r -n 1 choice
        echo
        [[ ! $choice =~ ^[Nn]$ ]] && INCLUDE_CICD=true
    fi

    # Hooks
    if $DETECTED_HOOKS; then
        echo -e "  ${DIM}Pre-commit hooks déjà présents${NC}"
        INCLUDE_HOOKS=false
    else
        if $EXISTING_PROJECT; then
            prompt "Ajouter pre-commit hooks (husky)? (Y/n)"
        else
            prompt "Inclure pre-commit hooks (husky)? (Y/n)"
        fi
        read -r -n 1 choice
        echo
        [[ ! $choice =~ ^[Nn]$ ]] && INCLUDE_HOOKS=true
    fi

    # MCP
    prompt "Inclure configuration MCP? (y/N)"
    read -r -n 1 choice
    echo
    [[ $choice =~ ^[Yy]$ ]] && INCLUDE_MCP=true

    # Docker
    if $DETECTED_DOCKER; then
        echo -e "  ${DIM}Docker déjà présent${NC}"
        INCLUDE_DOCKER=false
    else
        if $EXISTING_PROJECT; then
            prompt "Ajouter Dockerfile? (y/N)"
        else
            prompt "Inclure Dockerfile? (y/N)"
        fi
        read -r -n 1 choice
        echo
        [[ $choice =~ ^[Yy]$ ]] && INCLUDE_DOCKER=true
    fi

    # Design direction (uniquement pour projets avec UI)
    case "$PROJECT_TYPE" in
        react|vue|fullstack|flutter|generic)
            if [[ -z "$DESIGN_STYLE" ]]; then
                echo ""
                info "Direction design (personnalité visuelle de l'app):"
                echo ""
                echo "  1) terminal   — Monospace, fond noir, accents néon"
                echo "  2) cockpit    — Dense, dark, indicateurs temps réel"
                echo "  3) vitality   — Couleurs vives, arrondi, énergie positive"
                echo "  4) editorial  — Typo soignée, espaces blancs, magazine"
                echo "  5) glass      — Transparences, blur, profondeur"
                echo "  6) signal     — Efficacité brute, zéro décoration"
                echo ""
                prompt "Choix [1-6] (défaut: aucun, skip avec Entrée): "
                read -r style_choice
                case $style_choice in
                    1) DESIGN_STYLE="terminal" ;;
                    2) DESIGN_STYLE="cockpit" ;;
                    3) DESIGN_STYLE="vitality" ;;
                    4) DESIGN_STYLE="editorial" ;;
                    5) DESIGN_STYLE="glass" ;;
                    6) DESIGN_STYLE="signal" ;;
                    *) DESIGN_STYLE="" ;;
                esac
            fi
            ;;
    esac
}

confirm_choices() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Résumé de la configuration${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Projet:       ${GREEN}${PROJECT_NAME}${NC}"
    echo -e "  Chemin:       ${CYAN}${PROJECT_PATH}${NC}"
    echo -e "  Type:         ${YELLOW}${PROJECT_TYPE}${NC}"
    if [[ -n "$DETECTED_FRAMEWORK" ]]; then
        echo -e "  Framework:    ${YELLOW}${DETECTED_FRAMEWORK}${NC}"
    fi
    echo ""
    echo "  Options à installer:"
    $INCLUDE_CICD && echo -e "    ${GREEN}✓${NC} GitHub Actions" || echo -e "    ${DIM}○ GitHub Actions (skip)${NC}"
    $INCLUDE_HOOKS && echo -e "    ${GREEN}✓${NC} Pre-commit hooks" || echo -e "    ${DIM}○ Pre-commit hooks (skip)${NC}"
    $INCLUDE_MCP && echo -e "    ${GREEN}✓${NC} Configuration MCP" || echo -e "    ${DIM}○ Configuration MCP (skip)${NC}"
    $INCLUDE_DOCKER && echo -e "    ${GREEN}✓${NC} Dockerfile" || echo -e "    ${DIM}○ Dockerfile (skip)${NC}"
    if [[ -n "$DESIGN_STYLE" ]]; then
        echo -e "    ${GREEN}✓${NC} Design: ${YELLOW}${DESIGN_STYLE}${NC}"
    fi
    echo ""

    if $EXISTING_PROJECT; then
        echo -e "  ${GREEN}✓${NC} CLAUDE.md sera généré automatiquement avec:"
        echo -e "    - Scripts npm détectés (${#DETECTED_SCRIPTS[@]} scripts)"
        echo -e "    - Structure de dossiers (${#DETECTED_FOLDERS[@]} dossiers)"
        echo -e "    - Technologies et dépendances"
        echo ""
        echo -e "  ${DIM}Note: Les fichiers existants ne seront pas écrasés${NC}"
        echo ""
    fi

    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    if $EXISTING_PROJECT; then
        prompt "Configurer Claude Code pour ce projet? (Y/n)"
    else
        prompt "Créer le projet avec cette configuration? (Y/n)"
    fi
    read -r -n 1 confirm
    echo

    if [[ $confirm =~ ^[Nn]$ ]]; then
        info "Opération annulée"
        exit 0
    fi
}

create_project() {
    echo ""

    # Convertir PROJECT_PATH en chemin absolu (TARGET_DIR)
    local TARGET_DIR
    if $EXISTING_PROJECT; then
        info "Configuration du projet existant..."
        TARGET_DIR="$(get_absolute_path "$PROJECT_PATH")"
    else
        info "Création du projet..."
        if ! $DRY_RUN; then
            mkdir -p "$PROJECT_PATH"
        else
            echo -e "${DIM}[DRY-RUN]${NC} mkdir -p $PROJECT_PATH"
        fi
        TARGET_DIR="$(get_absolute_path "$PROJECT_PATH")"
    fi

    debug "Répertoire cible: $TARGET_DIR"
    $DRY_RUN && warning "Mode dry-run activé - aucune modification ne sera effectuée"

    # Nettoyer les anciens fichiers Claude si le dossier existe
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        clean_claude_dirs "$TARGET_DIR"
    fi

    # Installer les fichiers Claude (commandes, agents, skills, rules, styles, templates)
    install_claude_files "$TARGET_DIR"
    success "Commandes Claude installées ($(count_commands_cached) commandes, $(count_agents_cached) agents, $(count_skills_cached) skills)"

    # Générer ou copier CLAUDE.md
    if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        # Utiliser le template spécifique si un type est détecté
        # La génération intelligente est réservée aux projets sans template dédié
        local use_template=false
        case $PROJECT_TYPE in
            react|vue|node-api|python|go|rust|java|fullstack|flutter|neovim)
                use_template=true
                ;;
        esac

        if $use_template; then
            # Copier le template spécifique au type de projet
            info "Configuration du template CLAUDE.md..."
            case $PROJECT_TYPE in
                react)     copy_file "$SOCLE_DIR/templates/CLAUDE.react.md" "$TARGET_DIR/CLAUDE.md" ;;
                vue)       copy_file "$SOCLE_DIR/templates/CLAUDE.vue.md" "$TARGET_DIR/CLAUDE.md" ;;
                node-api)  copy_file "$SOCLE_DIR/templates/CLAUDE.node-api.md" "$TARGET_DIR/CLAUDE.md" ;;
                python)    copy_file "$SOCLE_DIR/templates/CLAUDE.python.md" "$TARGET_DIR/CLAUDE.md" ;;
                go)        copy_file "$SOCLE_DIR/templates/CLAUDE.go.md" "$TARGET_DIR/CLAUDE.md" ;;
                rust)      copy_file "$SOCLE_DIR/templates/CLAUDE.rust.md" "$TARGET_DIR/CLAUDE.md" ;;
                java)      copy_file "$SOCLE_DIR/templates/CLAUDE.java.md" "$TARGET_DIR/CLAUDE.md" ;;
                fullstack) copy_file "$SOCLE_DIR/templates/CLAUDE.fullstack.md" "$TARGET_DIR/CLAUDE.md" ;;
                flutter)   copy_file "$SOCLE_DIR/templates/CLAUDE.flutter.md" "$TARGET_DIR/CLAUDE.md" ;;
                neovim)    copy_file "$SOCLE_DIR/templates/CLAUDE.neovim.md" "$TARGET_DIR/CLAUDE.md" ;;
            esac
            success "Template CLAUDE.md configuré (${PROJECT_TYPE})"
        elif $EXISTING_PROJECT && [[ ${#DETECTED_SCRIPTS[@]} -gt 0 || ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
            # Générer un CLAUDE.md intelligent pour les projets existants sans template
            generate_smart_claude_md "$TARGET_DIR/CLAUDE.md"
        else
            # Copier le template générique
            info "Configuration du template CLAUDE.md..."
            copy_file "$SOCLE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

            # Remplacer le nom du projet dans CLAUDE.md
            if ! $DRY_RUN; then
                # Escape PROJECT_NAME for safe sed substitution (use | delimiter)
                local safe_name="${PROJECT_NAME//|/\\|}"
                sed -i "s|# Projet .*|# Projet ${safe_name}|" "$TARGET_DIR/CLAUDE.md" 2>/dev/null || \
                sed -i '' "s|# Projet .*|# Projet ${safe_name}|" "$TARGET_DIR/CLAUDE.md" 2>/dev/null || true
            fi

            success "Template CLAUDE.md configuré (${PROJECT_TYPE})"
        fi
    else
        warning "CLAUDE.md existe déjà, ignoré"
    fi

    # Copier CLAUDE.local.md.example (seulement si n'existe pas)
    if [[ ! -f "$TARGET_DIR/CLAUDE.local.md.example" ]]; then
        copy_file "$SOCLE_DIR/CLAUDE.local.md.example" "$TARGET_DIR/"
        success "CLAUDE.local.md.example copié"
    fi

    # Composants optionnels (using shared functions)
    if $INCLUDE_CICD; then
        install_cicd_files "$TARGET_DIR"
    elif [[ "$CICD_ACTION" == "merge" ]]; then
        merge_cicd_workflows "$TARGET_DIR"
    elif [[ "$CICD_ACTION" == "replace" ]]; then
        warning "Remplacement des workflows existants..."
        make_dir "$TARGET_DIR/.github/workflows"
        if ! $DRY_RUN; then
            rm -f "$TARGET_DIR/.github/workflows/"*.yml "$TARGET_DIR/.github/workflows/"*.yaml 2>/dev/null || true
            cp -r "$SOCLE_DIR/.github/workflows/"* "$TARGET_DIR/.github/workflows/"
        else
            echo -e "${DIM}[DRY-RUN]${NC} Remplacement des workflows dans $TARGET_DIR/.github/workflows/"
        fi
        success "GitHub Actions remplacés par les templates du socle"
    fi
    $INCLUDE_HOOKS && install_hooks_files "$TARGET_DIR"
    $INCLUDE_MCP && install_mcp_file "$TARGET_DIR"
    $INCLUDE_DOCKER && create_dockerfile "$TARGET_DIR"

    # .gitignore et git init
    update_gitignore_file "$TARGET_DIR"

    if [[ ! -d "$TARGET_DIR/.git" ]]; then
        if ! $DRY_RUN; then
            if (cd "$TARGET_DIR" && git init -q); then
                success "Repository git initialisé"
            else
                warning "Échec de git init dans $TARGET_DIR"
            fi
        else
            echo -e "${DIM}[DRY-RUN]${NC} git init dans $TARGET_DIR"
        fi
    fi
}

# Crée un Dockerfile dans un répertoire spécifié
# Arguments:
#   $1 - Répertoire cible (chemin absolu, défaut: répertoire courant)

print_next_steps() {
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    if $EXISTING_PROJECT; then
        echo -e "${BOLD}${GREEN}  Projet configuré avec succès !${NC}"
    else
        echo -e "${BOLD}${GREEN}  Projet créé avec succès !${NC}"
    fi
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    info "Prochaines étapes:"
    echo ""

    if ! $EXISTING_PROJECT; then
        echo -e "  ${CYAN}1.${NC} Aller dans le projet:"
        echo -e "     ${YELLOW}cd ${PROJECT_NAME}${NC}"
        echo ""
    fi

    echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "1" || echo "2" ).${NC} Vérifier et personnaliser CLAUDE.md"
    echo ""
    echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "2" || echo "3" ).${NC} Lancer Claude Code:"
    echo -e "     ${YELLOW}claude${NC}"
    echo ""

    if $INCLUDE_HOOKS; then
        echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "3" || echo "4" ).${NC} Activer les hooks (optionnel):"
        case "$DETECTED_PKG_MANAGER" in
            bun)
                echo -e "     ${YELLOW}bun add -d husky lint-staged @commitlint/cli @commitlint/config-conventional${NC}"
                echo -e "     ${YELLOW}bunx husky install${NC}"
                ;;
            pnpm)
                echo -e "     ${YELLOW}pnpm add -D husky lint-staged @commitlint/cli @commitlint/config-conventional${NC}"
                echo -e "     ${YELLOW}pnpm exec husky install${NC}"
                ;;
            yarn)
                echo -e "     ${YELLOW}yarn add -D husky lint-staged @commitlint/cli @commitlint/config-conventional${NC}"
                echo -e "     ${YELLOW}yarn husky install${NC}"
                ;;
            *)
                echo -e "     ${YELLOW}npm install husky lint-staged @commitlint/cli @commitlint/config-conventional -D${NC}"
                echo -e "     ${YELLOW}npx husky install${NC}"
                ;;
        esac
        echo ""
    fi

    echo -e "  ${CYAN}Commandes disponibles:${NC}"
    echo -e "     /work:work-explore, /work:work-plan, /work:work-commit, etc."
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

validate_socle_dirs() {
    for required_dir in "$COMMANDS_DIR" "$SKILLS_DIR" "$AGENTS_DIR" "$RULES_DIR"; do
        [[ -d "$SOCLE_DIR/$required_dir" ]] || error "Socle directory missing: $SOCLE_DIR/$required_dir"
    done
}

main() {
    # Parser les arguments en premier
    parse_args "$@"

    # Validate that the socle installation is intact
    validate_socle_dirs

    # Mode simple: installation directe sans détection de stack
    if $SIMPLE_MODE; then
        # Afficher le banner (sauf en mode silencieux)
        if ! $QUIET; then
            echo ""
            echo -e "${BOLD}${CYAN}Claude-Socle - Installation Simple${NC}"
            echo ""
        fi
        run_simple_mode
        exit 0
    fi

    # Afficher le banner (sauf en mode non-interactif silencieux)
    if ! $NON_INTERACTIVE; then
        print_banner
    fi

    # Vérifier si un chemin est passé en argument
    if [[ -n "$PROJECT_PATH" ]]; then
        # Si --path est aussi fourni, PROJECT_PATH est le nom du projet
        if [[ -n "$PARENT_PATH" ]]; then
            PROJECT_NAME="$PROJECT_PATH"
            # Valider le nom du projet
            if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
                error "Le nom du projet doit commencer par une lettre et contenir uniquement lettres, chiffres, - et _"
            fi
            # Résoudre le chemin parent
            if [[ "$PARENT_PATH" = /* ]]; then
                PARENT_PATH="$PARENT_PATH"
            else
                PARENT_PATH="$(cd "$PWD" && cd "$PARENT_PATH" 2>/dev/null && pwd)" || PARENT_PATH="$PWD/$PARENT_PATH"
            fi
            # Créer le dossier parent si nécessaire
            if [[ ! -d "$PARENT_PATH" ]]; then
                mkdir -p "$PARENT_PATH" || error "Impossible de créer le dossier: $PARENT_PATH"
            fi
            PROJECT_PATH="${PARENT_PATH}/${PROJECT_NAME}"
            if [[ -d "$PROJECT_PATH" ]]; then
                EXISTING_PROJECT=true
                PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
                info "Analyse du projet existant: $PROJECT_PATH"
                echo ""
                detect_stack "$PROJECT_PATH"
            else
                info "Création du nouveau projet: $PROJECT_PATH"
            fi
        elif [[ -d "$PROJECT_PATH" ]]; then
            PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
            EXISTING_PROJECT=true
            info "Analyse du projet existant: $PROJECT_PATH"
            echo ""
            detect_stack "$PROJECT_PATH"
        elif $NON_INTERACTIVE; then
            # En mode non-interactif, créer le dossier s'il n'existe pas
            mkdir -p "$PROJECT_PATH"
            PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
            info "Création du nouveau projet: $PROJECT_PATH"
        else
            error "Le chemin '$PROJECT_PATH' n'existe pas"
        fi
    fi

    # Appliquer le type forcé si spécifié
    if [[ -n "$FORCE_TYPE" ]]; then
        PROJECT_TYPE="$FORCE_TYPE"
        DETECTED_TYPE="$FORCE_TYPE"
    fi

    # Mode non-interactif
    if $NON_INTERACTIVE; then
        # Utiliser le nom du dossier ou un nom par défaut
        if [[ -z "$PROJECT_NAME" ]]; then
            if [[ -n "$PROJECT_PATH" ]]; then
                PROJECT_NAME=$(basename "$PROJECT_PATH")
            else
                PROJECT_NAME="new-project"
                # Utiliser PARENT_PATH si fourni, sinon PWD
                local base_path="${PARENT_PATH:-$PWD}"
                if [[ -n "$PARENT_PATH" ]] && [[ ! -d "$PARENT_PATH" ]]; then
                    mkdir -p "$PARENT_PATH" || error "Impossible de créer le dossier: $PARENT_PATH"
                fi
                PROJECT_PATH="${base_path}/${PROJECT_NAME}"
                mkdir -p "$PROJECT_PATH"
            fi
        fi

        # Utiliser le type détecté ou générique
        if [[ -z "$PROJECT_TYPE" ]]; then
            PROJECT_TYPE="${DETECTED_TYPE:-generic}"
        fi

        # Utiliser les valeurs par défaut pour les options non spécifiées
        # (Les options sont déjà à false par défaut, --ci/--hooks/etc les activent)

        # Respecter la détection pour éviter les doublons
        $DETECTED_CICD && INCLUDE_CICD=false
        $DETECTED_HOOKS && INCLUDE_HOOKS=false
        $DETECTED_DOCKER && INCLUDE_DOCKER=false

        info "Mode non-interactif activé"
        info "Projet: $PROJECT_NAME ($PROJECT_TYPE)"
        echo ""

        create_project
        print_next_steps
    else
        # Mode interactif standard
        get_project_name
        get_project_type
        get_options
        confirm_choices
        create_project
        print_next_steps
    fi
}

# Lancer le script
main "$@"
