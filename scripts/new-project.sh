#!/bin/bash

# =============================================================================
# Claude-Socle New Project Script
# Crée un nouveau projet ou configure un projet existant avec Claude Code
# =============================================================================

set -euo pipefail

VERSION="1.1.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Activer le handler d'erreur et vérifier les prérequis
enable_error_handler
check_base_requirements

# Variables du projet
PROJECT_NAME=""
PROJECT_TYPE=""
PROJECT_PATH=""
EXISTING_PROJECT=false
INCLUDE_CICD=false
INCLUDE_HOOKS=false
INCLUDE_MCP=false
INCLUDE_DOCKER=false
NON_INTERACTIVE=false
FORCE_TYPE=""

# Variables de détection
DETECTED_TYPE=""
DETECTED_FRAMEWORK=""
DETECTED_CICD=false
DETECTED_HOOKS=false
DETECTED_DOCKER=false
DETECTED_DEPENDENCIES=()
DETECTED_SCRIPTS=()
DETECTED_FOLDERS=()
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
    Installe 79 agents spécialisés et configure le workflow Explore → Plan → Code → Commit.

${BOLD}ARGUMENTS${NC}
    CHEMIN              Chemin vers un projet existant à configurer (optionnel)
                        Si omis, crée un nouveau projet interactivement

${BOLD}OPTIONS${NC}
    -h, --help          Affiche cette aide
    -v, --version       Affiche la version
    -y, --yes           Mode non-interactif (accepte les valeurs par défaut)
    -t, --type TYPE     Force le type de projet (react, vue, node-api, python, go, rust, java, fullstack, generic)
    --ci                Inclut GitHub Actions (CI/CD)
    --hooks             Inclut pre-commit hooks (husky)
    --mcp               Inclut configuration MCP
    --docker            Inclut Dockerfile
    --all               Inclut toutes les options (ci, hooks, mcp, docker)

${BOLD}EXEMPLES${NC}
    # Nouveau projet interactif
    $(basename "$0")

    # Configurer un projet existant
    $(basename "$0") ./mon-projet

    # Mode non-interactif avec détection auto
    $(basename "$0") -y ./mon-projet

    # Nouveau projet React avec CI/CD
    $(basename "$0") -y -t react --ci ./nouveau-projet

    # Tout inclure
    $(basename "$0") -y --all ./mon-projet

${BOLD}TYPES DE PROJET${NC}
    react       React / Next.js
    vue         Vue.js / Nuxt.js
    node-api    Node.js API (Express, Fastify, NestJS)
    python      Python (Django, FastAPI, Flask)
    go          Go (Gin, Echo, Fiber)
    rust        Rust (Actix, Axum, Rocket)
    java        Java / Spring Boot
    fullstack   Monorepo (Turborepo, Nx)
    generic     Autre / Générique

${BOLD}FICHIERS INSTALLÉS${NC}
    .claude/commands/   79 agents Claude Code
    .claude/skills/     9 skills spécialisés
    .claude/settings.json (8 hooks configurés)
    CLAUDE.md           Instructions du projet (généré intelligemment)

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
            -t|--type)
                FORCE_TYPE="$2"
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
# Fonctions de détection
# =============================================================================

detect_stack() {
    local dir="$1"

    info "Analyse de la stack technique..."
    echo ""

    # Reset
    DETECTED_TYPE=""
    DETECTED_FRAMEWORK=""
    DETECTED_CICD=false
    DETECTED_HOOKS=false
    DETECTED_DOCKER=false
    DETECTED_DEPENDENCIES=()
    DETECTED_SCRIPTS=()
    DETECTED_FOLDERS=()
    DETECTED_MAIN_DEPS=()

    # Détecter le gestionnaire de paquets
    if [[ -f "$dir/bun.lockb" ]] || [[ -f "$dir/bun.lock" ]]; then
        DETECTED_PKG_MANAGER="bun"
    elif [[ -f "$dir/pnpm-lock.yaml" ]]; then
        DETECTED_PKG_MANAGER="pnpm"
    elif [[ -f "$dir/yarn.lock" ]]; then
        DETECTED_PKG_MANAGER="yarn"
    else
        DETECTED_PKG_MANAGER="npm"
    fi

    # Détecter Node.js / JavaScript
    if [[ -f "$dir/package.json" ]]; then
        DETECTED_DEPENDENCIES+=("Node.js")
        if [[ "$DETECTED_PKG_MANAGER" != "npm" ]]; then
            DETECTED_DEPENDENCIES+=("$DETECTED_PKG_MANAGER")
        fi

        # Extraire les scripts
        extract_npm_scripts "$dir/package.json"

        # Extraire les dépendances principales
        extract_main_dependencies "$dir/package.json"

        # Lire package.json pour détecter le framework
        if grep -q '"react"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="react"
            DETECTED_FRAMEWORK="React"
            if grep -q '"next"' "$dir/package.json" 2>/dev/null; then
                DETECTED_FRAMEWORK="Next.js"
            fi
        elif grep -q '"vue"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="vue"
            DETECTED_FRAMEWORK="Vue.js"
            if grep -q '"nuxt"' "$dir/package.json" 2>/dev/null; then
                DETECTED_FRAMEWORK="Nuxt.js"
            fi
        elif grep -q '"angular"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="generic"
            DETECTED_FRAMEWORK="Angular"
        elif grep -q '"svelte"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="generic"
            DETECTED_FRAMEWORK="Svelte"
        elif grep -q '"express"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="node-api"
            DETECTED_FRAMEWORK="Express.js"
        elif grep -q '"fastify"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="node-api"
            DETECTED_FRAMEWORK="Fastify"
        elif grep -q '"nestjs"' "$dir/package.json" 2>/dev/null || grep -q '"@nestjs"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="node-api"
            DETECTED_FRAMEWORK="NestJS"
        else
            DETECTED_TYPE="node-api"
            DETECTED_FRAMEWORK="Node.js"
        fi

        # Détecter TypeScript
        if [[ -f "$dir/tsconfig.json" ]] || grep -q '"typescript"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("TypeScript")
        fi

        # Détecter les outils de test
        if grep -q '"jest"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Jest")
        fi
        if grep -q '"vitest"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Vitest")
        fi
        if grep -q '"cypress"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Cypress")
        fi
        if grep -q '"playwright"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Playwright")
        fi

        # Détecter les outils de build
        if grep -q '"vite"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Vite")
        fi
        if grep -q '"webpack"' "$dir/package.json" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Webpack")
        fi

        # Détecter husky/lint-staged
        if grep -q '"husky"' "$dir/package.json" 2>/dev/null || [[ -d "$dir/.husky" ]]; then
            DETECTED_HOOKS=true
            DETECTED_DEPENDENCIES+=("Husky")
        fi
    fi

    # Détecter Python
    if [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]] || [[ -f "$dir/Pipfile" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="python"
            DETECTED_FRAMEWORK="Python"
        fi
        DETECTED_DEPENDENCIES+=("Python")

        # Extraire les dépendances Python
        extract_python_dependencies "$dir"

        # Détecter le framework Python
        if [[ -f "$dir/requirements.txt" ]]; then
            if grep -qi "django" "$dir/requirements.txt" 2>/dev/null; then
                DETECTED_FRAMEWORK="Django"
            elif grep -qi "fastapi" "$dir/requirements.txt" 2>/dev/null; then
                DETECTED_FRAMEWORK="FastAPI"
            elif grep -qi "flask" "$dir/requirements.txt" 2>/dev/null; then
                DETECTED_FRAMEWORK="Flask"
            fi
        fi
        if [[ -f "$dir/pyproject.toml" ]]; then
            if grep -qi "django" "$dir/pyproject.toml" 2>/dev/null; then
                DETECTED_FRAMEWORK="Django"
            elif grep -qi "fastapi" "$dir/pyproject.toml" 2>/dev/null; then
                DETECTED_FRAMEWORK="FastAPI"
            elif grep -qi "flask" "$dir/pyproject.toml" 2>/dev/null; then
                DETECTED_FRAMEWORK="Flask"
            fi
        fi
    fi

    # Détecter Go
    if [[ -f "$dir/go.mod" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="go"
            DETECTED_FRAMEWORK="Go"
        fi
        DETECTED_DEPENDENCIES+=("Go")

        # Détecter le framework Go
        if grep -q "gin-gonic" "$dir/go.mod" 2>/dev/null; then
            DETECTED_FRAMEWORK="Gin"
        elif grep -q "echo" "$dir/go.mod" 2>/dev/null; then
            DETECTED_FRAMEWORK="Echo"
        elif grep -q "fiber" "$dir/go.mod" 2>/dev/null; then
            DETECTED_FRAMEWORK="Fiber"
        fi
    fi

    # Détecter Rust
    if [[ -f "$dir/Cargo.toml" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="rust"
            DETECTED_FRAMEWORK="Rust"
        fi
        DETECTED_DEPENDENCIES+=("Rust")

        # Détecter le framework Rust
        if grep -q "actix-web" "$dir/Cargo.toml" 2>/dev/null; then
            DETECTED_FRAMEWORK="Actix Web"
        elif grep -q "axum" "$dir/Cargo.toml" 2>/dev/null; then
            DETECTED_FRAMEWORK="Axum"
        elif grep -q "rocket" "$dir/Cargo.toml" 2>/dev/null; then
            DETECTED_FRAMEWORK="Rocket"
        fi
    fi

    # Détecter Java
    if [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="java"
            DETECTED_FRAMEWORK="Java"
        fi
        DETECTED_DEPENDENCIES+=("Java")

        # Détecter Spring Boot
        if [[ -f "$dir/pom.xml" ]] && grep -q "spring-boot" "$dir/pom.xml" 2>/dev/null; then
            DETECTED_FRAMEWORK="Spring Boot"
        elif [[ -f "$dir/build.gradle" ]] && grep -q "spring-boot" "$dir/build.gradle" 2>/dev/null; then
            DETECTED_FRAMEWORK="Spring Boot"
        fi
    fi

    # Détecter Monorepo / Fullstack
    if [[ -d "$dir/packages" ]] || [[ -d "$dir/apps" ]]; then
        if [[ -f "$dir/package.json" ]] && grep -q '"workspaces"' "$dir/package.json" 2>/dev/null; then
            DETECTED_TYPE="fullstack"
            DETECTED_FRAMEWORK="Monorepo"
            DETECTED_DEPENDENCIES+=("Workspaces")
        fi
    fi
    if [[ -f "$dir/turbo.json" ]]; then
        DETECTED_TYPE="fullstack"
        DETECTED_FRAMEWORK="Turborepo"
        DETECTED_DEPENDENCIES+=("Turborepo")
    fi
    if [[ -f "$dir/nx.json" ]]; then
        DETECTED_TYPE="fullstack"
        DETECTED_FRAMEWORK="Nx"
        DETECTED_DEPENDENCIES+=("Nx")
    fi

    # Détecter Docker
    if [[ -f "$dir/Dockerfile" ]] || [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/docker-compose.yaml" ]]; then
        DETECTED_DOCKER=true
        DETECTED_DEPENDENCIES+=("Docker")
    fi

    # Détecter CI/CD
    if [[ -d "$dir/.github/workflows" ]]; then
        DETECTED_CICD=true
        DETECTED_DEPENDENCIES+=("GitHub Actions")
    fi
    if [[ -f "$dir/.gitlab-ci.yml" ]]; then
        DETECTED_CICD=true
        DETECTED_DEPENDENCIES+=("GitLab CI")
    fi
    if [[ -f "$dir/bitbucket-pipelines.yml" ]]; then
        DETECTED_CICD=true
        DETECTED_DEPENDENCIES+=("Bitbucket Pipelines")
    fi

    # Détecter pre-commit
    if [[ -f "$dir/.pre-commit-config.yaml" ]]; then
        DETECTED_HOOKS=true
        DETECTED_DEPENDENCIES+=("pre-commit")
    fi

    # Détecter bases de données (limiter la profondeur pour la performance)
    local db_files
    db_files=$(find "$dir" -maxdepth 2 \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name ".env*" -o -name "docker-compose*" \) -type f 2>/dev/null | head -20)
    if [[ -n "$db_files" ]]; then
        if echo "$db_files" | xargs grep -lq "postgres\|postgresql" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("PostgreSQL")
        fi
        if echo "$db_files" | xargs grep -lq "mongodb\|mongo" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("MongoDB")
        fi
        if echo "$db_files" | xargs grep -lq "redis" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Redis")
        fi
    fi

    # Détecter Deno
    if [[ -f "$dir/deno.json" ]] || [[ -f "$dir/deno.jsonc" ]]; then
        DETECTED_DEPENDENCIES+=("Deno")
        DETECTED_PKG_MANAGER="deno"
    fi

    # Détecter la structure de dossiers
    detect_folder_structure "$dir"

    # Afficher les résultats de la détection
    if [[ ${#DETECTED_DEPENDENCIES[@]} -gt 0 ]]; then
        echo -e "${BOLD}  Stack détectée:${NC}"
        echo ""
        if [[ -n "$DETECTED_FRAMEWORK" ]]; then
            detected "Framework principal: ${BOLD}$DETECTED_FRAMEWORK${NC}"
        fi

        echo -e "  ${DIM}Technologies:${NC} ${DETECTED_DEPENDENCIES[*]}"
        echo ""

        if [[ ${#DETECTED_SCRIPTS[@]} -gt 0 ]]; then
            detected "Scripts détectés: ${#DETECTED_SCRIPTS[@]} (${DETECTED_PKG_MANAGER})"
        fi

        if [[ ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
            detected "Structure de dossiers analysée"
        fi

        if $DETECTED_CICD; then
            detected "CI/CD déjà configuré"
        fi
        if $DETECTED_HOOKS; then
            detected "Pre-commit hooks déjà configurés"
        fi
        if $DETECTED_DOCKER; then
            detected "Docker déjà configuré"
        fi
        echo ""
    else
        warning "Aucune stack technique détectée"
        echo ""
    fi
}

extract_npm_scripts() {
    local package_json="$1"

    # Extraire les scripts avec une approche simple
    if command -v node &> /dev/null; then
        # Utiliser Node.js si disponible
        DETECTED_SCRIPTS=($(node -e "
            const pkg = require('$package_json');
            if (pkg.scripts) {
                Object.keys(pkg.scripts).forEach(s => console.log(s));
            }
        " 2>/dev/null))
    else
        # Fallback: extraction basique avec sed (compatible macOS/Linux)
        DETECTED_SCRIPTS=($(sed -n 's/.*"\([^"]*\)"[[:space:]]*:.*/\1/p' "$package_json" 2>/dev/null | head -20))
    fi
}

extract_main_dependencies() {
    local package_json="$1"

    if command -v node &> /dev/null; then
        DETECTED_MAIN_DEPS=($(node -e "
            const pkg = require('$package_json');
            const deps = { ...pkg.dependencies, ...pkg.devDependencies };
            const important = ['react', 'vue', 'angular', 'next', 'nuxt', 'express', 'fastify', 'nestjs', 'prisma', 'typeorm', 'sequelize', 'mongoose', 'jest', 'vitest', 'cypress', 'playwright', 'tailwindcss', 'styled-components', 'emotion'];
            important.forEach(dep => {
                if (deps[dep] || deps['@' + dep + '/core']) console.log(dep);
            });
        " 2>/dev/null))
    fi
}

extract_python_dependencies() {
    local dir="$1"

    if [[ -f "$dir/requirements.txt" ]]; then
        DETECTED_MAIN_DEPS=($(grep -oP '^[a-zA-Z][a-zA-Z0-9_-]*' "$dir/requirements.txt" 2>/dev/null | head -10))
    fi
}

detect_folder_structure() {
    local dir="$1"

    # Détecter les dossiers courants
    local common_folders=("src" "lib" "app" "pages" "components" "services" "utils" "hooks" "api" "routes" "controllers" "models" "views" "tests" "test" "__tests__" "spec" "public" "static" "assets" "styles" "config" "scripts" "docs" "packages" "apps")

    for folder in "${common_folders[@]}"; do
        if [[ -d "$dir/$folder" ]]; then
            # Compter les fichiers dans le dossier
            local count=$(find "$dir/$folder" -type f 2>/dev/null | wc -l)
            if [[ $count -gt 0 ]]; then
                DETECTED_FOLDERS+=("$folder:$count")
            fi
        fi
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
    mkdir -p "$dir/.github/workflows"

    # Mapping des fonctionnalités manquantes vers les fichiers
    for missing in "${CICD_MISSING[@]}"; do
        case "$missing" in
            "Audit sécurité"|"Cache dépendances"|"Upload couverture"|"Tests automatisés"|"Linting")
                # Ces fonctionnalités sont dans ci.yml
                if [[ "$added_ci" == false ]] && [[ ! -f "$dir/.github/workflows/ci.yml" ]]; then
                    cp "$SOCLE_DIR/.github/workflows/ci.yml" "$dir/.github/workflows/"
                    success "ci.yml ajouté (lint, test, build, security)"
                    added_ci=true
                fi
                ;;
            "Validation PR")
                if [[ ! -f "$dir/.github/workflows/pr-check.yml" ]]; then
                    cp "$SOCLE_DIR/.github/workflows/pr-check.yml" "$dir/.github/workflows/"
                    success "pr-check.yml ajouté (validation PR, labels)"
                fi
                ;;
            "Release automatisée")
                if [[ ! -f "$dir/.github/workflows/release.yml" ]]; then
                    cp "$SOCLE_DIR/.github/workflows/release.yml" "$dir/.github/workflows/"
                    success "release.yml ajouté (changelog, GitHub Release)"
                fi
                ;;
        esac
    done
}

# =============================================================================
# Génération intelligente du CLAUDE.md
# =============================================================================

generate_smart_claude_md() {
    local output_file="$1"

    info "Génération intelligente du CLAUDE.md..."

    cat > "$output_file" << EOF
# Projet ${PROJECT_NAME}

EOF

    # Section Commandes Essentielles
    echo "## Commandes Essentielles" >> "$output_file"
    echo "" >> "$output_file"

    if [[ ${#DETECTED_SCRIPTS[@]} -gt 0 ]]; then
        echo "| Commande | Description |" >> "$output_file"
        echo "|----------|-------------|" >> "$output_file"

        # Mapper les scripts courants à leurs descriptions
        for script in "${DETECTED_SCRIPTS[@]}"; do
            local desc=""
            case "$script" in
                dev|start:dev|serve)     desc="Serveur de développement" ;;
                start)                    desc="Démarrer l'application" ;;
                build)                    desc="Build de production" ;;
                test)                     desc="Lancer les tests" ;;
                test:watch)               desc="Tests en mode watch" ;;
                test:cov|test:coverage)   desc="Tests avec couverture" ;;
                test:e2e)                 desc="Tests end-to-end" ;;
                lint)                     desc="Vérifier le code (linter)" ;;
                lint:fix)                 desc="Corriger automatiquement le linting" ;;
                format)                   desc="Formater le code" ;;
                typecheck|type-check)     desc="Vérifier les types TypeScript" ;;
                clean)                    desc="Nettoyer les fichiers générés" ;;
                db:migrate)               desc="Lancer les migrations DB" ;;
                db:seed)                  desc="Peupler la base de données" ;;
                docker:build)             desc="Build de l'image Docker" ;;
                docker:up)                desc="Démarrer les containers" ;;
                storybook)                desc="Lancer Storybook" ;;
                generate)                 desc="Générer du code" ;;
                preview)                  desc="Prévisualiser le build" ;;
                *)                        desc="Script $script" ;;
            esac
            local run_cmd="$DETECTED_PKG_MANAGER run"
            [[ "$DETECTED_PKG_MANAGER" == "yarn" ]] && run_cmd="yarn"
            [[ "$DETECTED_PKG_MANAGER" == "bun" ]] && run_cmd="bun run"
            echo "| \`$run_cmd $script\` | $desc |" >> "$output_file"
        done
    else
        # Scripts par défaut selon le type de projet
        case "$PROJECT_TYPE" in
            react|vue)
                cat >> "$output_file" << 'EOF'
| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm run build` | Build de production |
| `npm test` | Lancer les tests |
| `npm run lint` | Vérifier le code |
EOF
                ;;
            python)
                cat >> "$output_file" << 'EOF'
| Commande | Description |
|----------|-------------|
| `pip install -r requirements.txt` | Installer les dépendances |
| `python main.py` | Lancer l'application |
| `pytest` | Lancer les tests |
| `flake8` | Vérifier le code |
EOF
                ;;
            go)
                cat >> "$output_file" << 'EOF'
| Commande | Description |
|----------|-------------|
| `go mod download` | Télécharger les dépendances |
| `go run .` | Lancer l'application |
| `go test ./...` | Lancer les tests |
| `go build` | Compiler |
EOF
                ;;
            *)
                cat >> "$output_file" << 'EOF'
| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run build` | Build de production |
EOF
                ;;
        esac
    fi

    echo "" >> "$output_file"

    # Section Structure du Projet
    echo "## Structure du Projet" >> "$output_file"
    echo "" >> "$output_file"
    echo '```' >> "$output_file"

    if [[ ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
        for folder_info in "${DETECTED_FOLDERS[@]}"; do
            local folder="${folder_info%%:*}"
            local count="${folder_info##*:}"
            local desc=""

            case "$folder" in
                src)         desc="Code source principal" ;;
                lib)         desc="Bibliothèques et utilitaires" ;;
                app)         desc="Application principale" ;;
                pages)       desc="Pages de l'application" ;;
                components)  desc="Composants UI réutilisables" ;;
                services)    desc="Logique métier et services" ;;
                utils)       desc="Fonctions utilitaires" ;;
                hooks)       desc="Custom hooks" ;;
                api)         desc="Endpoints API" ;;
                routes)      desc="Définition des routes" ;;
                controllers) desc="Contrôleurs" ;;
                models)      desc="Modèles de données" ;;
                views)       desc="Vues / Templates" ;;
                tests|test|__tests__|spec) desc="Tests" ;;
                public)      desc="Fichiers publics statiques" ;;
                static)      desc="Assets statiques" ;;
                assets)      desc="Ressources (images, fonts)" ;;
                styles)      desc="Styles CSS/SCSS" ;;
                config)      desc="Configuration" ;;
                scripts)     desc="Scripts utilitaires" ;;
                docs)        desc="Documentation" ;;
                packages)    desc="Packages du monorepo" ;;
                apps)        desc="Applications du monorepo" ;;
                *)           desc="$folder" ;;
            esac

            echo "/$folder    # $desc ($count fichiers)" >> "$output_file"
        done
    else
        echo "/src        # Code source" >> "$output_file"
        echo "/tests      # Tests" >> "$output_file"
    fi

    echo '```' >> "$output_file"
    echo "" >> "$output_file"

    # Section Technologies
    if [[ ${#DETECTED_DEPENDENCIES[@]} -gt 0 ]] || [[ ${#DETECTED_MAIN_DEPS[@]} -gt 0 ]]; then
        echo "## Technologies Utilisées" >> "$output_file"
        echo "" >> "$output_file"

        if [[ -n "$DETECTED_FRAMEWORK" ]]; then
            echo "- **Framework**: $DETECTED_FRAMEWORK" >> "$output_file"
        fi

        if [[ ${#DETECTED_MAIN_DEPS[@]} -gt 0 ]]; then
            echo "- **Dépendances principales**: ${DETECTED_MAIN_DEPS[*]}" >> "$output_file"
        fi

        if [[ " ${DETECTED_DEPENDENCIES[*]} " =~ " TypeScript " ]]; then
            echo "- **Langage**: TypeScript" >> "$output_file"
        fi

        if [[ " ${DETECTED_DEPENDENCIES[*]} " =~ " Jest " ]] || [[ " ${DETECTED_DEPENDENCIES[*]} " =~ " Vitest " ]]; then
            echo "- **Tests**: ${DETECTED_DEPENDENCIES[*]}" | grep -oE "(Jest|Vitest|Cypress|Playwright)" | tr '\n' ', ' | sed 's/,$/\n/' >> "$output_file" 2>/dev/null || true
        fi

        echo "" >> "$output_file"
    fi

    # Section Conventions de Code
    cat >> "$output_file" << 'EOF'
## Conventions de Code

### Principes
- IMPORTANT: Toujours comprendre le code existant avant de modifier
- IMPORTANT: Écrire des tests pour les nouvelles fonctionnalités
- YOU MUST suivre les conventions de nommage du projet
- Préférer les fonctions pures et l'immutabilité

### Git & Commits
- Format de commit: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Branches: `feature/`, `fix/`, `refactor/`
- IMPORTANT: Ne jamais push sur main directement

EOF

    # Section Workflow
    cat >> "$output_file" << 'EOF'
## Workflow Préféré

1. **EXPLORE**: Lire et comprendre avant de coder
2. **PLAN**: Proposer un plan avant d'implémenter
3. **CODE**: Implémenter avec tests
4. **COMMIT**: Commits atomiques et descriptifs

EOF

    # Section Agents Disponibles
    cat >> "$output_file" << 'EOF'
## Agents Disponibles (79 agents)

| Catégorie | Commandes |
|-----------|-----------|
| **Workflow** | \`/project:explore\`, \`/project:plan\`, \`/project:commit\`, \`/project:pr\` |
| **Développement** | \`/project:tdd\`, \`/project:test\`, \`/project:debug\`, \`/project:refactor\`, \`/project:api\` |
| **Qualité** | \`/project:review\`, \`/project:security\`, \`/project:perf\`, \`/project:a11y\` |
| **Ops** | \`/project:hotfix\`, \`/project:release\`, \`/project:migrate\`, \`/project:docker\` |

Utilisez \`/project:onboard\` pour découvrir tous les agents disponibles.

EOF

    success "CLAUDE.md généré avec les informations du projet"
}

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

get_project_name() {
    if $EXISTING_PROJECT; then
        PROJECT_NAME=$(basename "$PROJECT_PATH")
        info "Projet existant: ${BOLD}$PROJECT_NAME${NC}"
        echo ""
        return
    fi

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

        PROJECT_PATH="${PWD}/${PROJECT_NAME}"

        if [[ -d "$PROJECT_PATH" ]]; then
            warning "Le dossier '$PROJECT_NAME' existe déjà"
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
    print_option "9" "Autre / Générique"
    echo ""

    if [[ -n "$default_choice" ]]; then
        prompt "Choix [1-9] (défaut: $default_choice):"
    else
        prompt "Choix [1-9]:"
    fi
    read -r -n 1 choice
    echo ""

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
        9) PROJECT_TYPE="generic" ;;
        *) PROJECT_TYPE="${DETECTED_TYPE:-generic}" ;;
    esac
}

get_options() {
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
    if $EXISTING_PROJECT; then
        info "Configuration du projet existant..."
    else
        info "Création du projet..."
        mkdir -p "$PROJECT_PATH"
    fi

    cd "$PROJECT_PATH"

    # Créer la structure de base
    mkdir -p .claude/commands

    # Copier les commandes Claude
    info "Installation des commandes Claude..."
    cp -r "$SOCLE_DIR/.claude/commands/"* .claude/commands/
    cp "$SOCLE_DIR/.claude/settings.json" .claude/

    # Copier les skills
    if [[ -d "$SOCLE_DIR/.claude/skills" ]]; then
        mkdir -p .claude/skills
        cp -r "$SOCLE_DIR/.claude/skills/"* .claude/skills/
    fi
    success "Commandes Claude installées (79 agents, 9 skills, 8 hooks)"

    # Générer ou copier CLAUDE.md
    if [[ ! -f "CLAUDE.md" ]]; then
        if $EXISTING_PROJECT && [[ ${#DETECTED_SCRIPTS[@]} -gt 0 || ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
            # Générer un CLAUDE.md intelligent pour les projets existants
            generate_smart_claude_md "CLAUDE.md"
        else
            # Copier le template pour les nouveaux projets
            info "Configuration du template CLAUDE.md..."
            case $PROJECT_TYPE in
                react)     cp "$SOCLE_DIR/templates/CLAUDE.react.md" CLAUDE.md ;;
                vue)       cp "$SOCLE_DIR/templates/CLAUDE.vue.md" CLAUDE.md ;;
                node-api)  cp "$SOCLE_DIR/templates/CLAUDE.node-api.md" CLAUDE.md ;;
                python)    cp "$SOCLE_DIR/templates/CLAUDE.python.md" CLAUDE.md ;;
                go)        cp "$SOCLE_DIR/templates/CLAUDE.go.md" CLAUDE.md ;;
                rust)      cp "$SOCLE_DIR/templates/CLAUDE.rust.md" CLAUDE.md ;;
                java)      cp "$SOCLE_DIR/templates/CLAUDE.java.md" CLAUDE.md ;;
                fullstack) cp "$SOCLE_DIR/templates/CLAUDE.fullstack.md" CLAUDE.md ;;
                *)         cp "$SOCLE_DIR/CLAUDE.md" CLAUDE.md ;;
            esac

            # Remplacer le nom du projet dans CLAUDE.md
            sed -i "s/# Projet .*/# Projet ${PROJECT_NAME}/" CLAUDE.md 2>/dev/null || \
            sed -i '' "s/# Projet .*/# Projet ${PROJECT_NAME}/" CLAUDE.md 2>/dev/null || true

            success "Template CLAUDE.md configuré (${PROJECT_TYPE})"
        fi
    else
        warning "CLAUDE.md existe déjà, ignoré"
    fi

    # Copier CLAUDE.local.md.example (seulement si n'existe pas)
    if [[ ! -f "CLAUDE.local.md.example" ]]; then
        cp "$SOCLE_DIR/CLAUDE.local.md.example" .
        success "CLAUDE.local.md.example copié"
    fi

    # GitHub Actions
    # Gestion CI/CD selon l'action choisie
    if $INCLUDE_CICD; then
        info "Installation de GitHub Actions..."
        mkdir -p .github/workflows
        cp -r "$SOCLE_DIR/.github/workflows/"* .github/workflows/
        success "GitHub Actions installés"
    elif [[ "$CICD_ACTION" == "merge" ]]; then
        merge_cicd_workflows "$(pwd)"
    elif [[ "$CICD_ACTION" == "replace" ]]; then
        warning "Remplacement des workflows existants..."
        mkdir -p .github/workflows
        rm -f .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null || true
        cp -r "$SOCLE_DIR/.github/workflows/"* .github/workflows/
        success "GitHub Actions remplacés par les templates du socle"
    fi

    # Pre-commit hooks
    if $INCLUDE_HOOKS; then
        info "Installation des pre-commit hooks..."
        mkdir -p .husky
        cp -r "$SOCLE_DIR/.husky/"* .husky/
        cp "$SOCLE_DIR/.lintstagedrc.json" .
        cp "$SOCLE_DIR/.commitlintrc.json" .
        cp "$SOCLE_DIR/.pre-commit-config.yaml" . 2>/dev/null || true
        chmod +x .husky/* 2>/dev/null || true
        success "Pre-commit hooks installés"
    fi

    # MCP
    if $INCLUDE_MCP; then
        info "Installation de la configuration MCP..."
        cp "$SOCLE_DIR/.mcp.json" .
        success "Configuration MCP installée"
    fi

    # Docker
    if $INCLUDE_DOCKER; then
        info "Création des fichiers Docker..."
        create_dockerfile
        success "Fichiers Docker créés"
    fi

    # .gitignore (merge si existe déjà)
    if [[ -f ".gitignore" ]]; then
        # Ajouter les entrées Claude si pas déjà présentes
        if ! grep -q "CLAUDE.local.md" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# Claude Code" >> .gitignore
            echo "CLAUDE.local.md" >> .gitignore
            echo ".claude/settings.local.json" >> .gitignore
            success ".gitignore mis à jour"
        fi
    else
        cp "$SOCLE_DIR/.gitignore" .
        success ".gitignore créé"
    fi

    # Initialiser git si pas déjà fait
    if [[ ! -d .git ]]; then
        git init -q
        success "Repository git initialisé"
    fi
}

create_dockerfile() {
    # Ne pas écraser un Dockerfile existant
    if [[ -f "Dockerfile" ]]; then
        warning "Dockerfile existe déjà, ignoré"
        return
    fi

    # Créer un Dockerfile basique selon le type de projet
    case $PROJECT_TYPE in
        react|vue)
            cat > Dockerfile << 'EOF'
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
            ;;
        node-api)
            cat > Dockerfile << 'EOF'
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
USER nodejs
EXPOSE 3000
CMD ["node", "dist/index.js"]
EOF
            ;;
        python)
            cat > Dockerfile << 'EOF'
FROM python:3.12-slim
WORKDIR /app
RUN useradd --create-home appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8000
CMD ["python", "main.py"]
EOF
            ;;
        go)
            cat > Dockerfile << 'EOF'
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

FROM scratch
COPY --from=builder /app/main /main
EXPOSE 8080
ENTRYPOINT ["/main"]
EOF
            ;;
        rust)
            cat > Dockerfile << 'EOF'
FROM rust:1.75-alpine AS builder
WORKDIR /app
RUN apk add --no-cache musl-dev
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM alpine:latest
COPY --from=builder /app/target/release/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
EOF
            ;;
        java)
            cat > Dockerfile << 'EOF'
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
            ;;
        *)
            cat > Dockerfile << 'EOF'
FROM ubuntu:22.04
WORKDIR /app
COPY . .
# Customize this Dockerfile for your project
CMD ["bash"]
EOF
            ;;
    esac

    # Créer .dockerignore si n'existe pas
    if [[ ! -f ".dockerignore" ]]; then
        cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
Dockerfile*
docker-compose*
.dockerignore
README.md
.vscode
.idea
coverage
dist
build
*.log
__pycache__
*.pyc
.pytest_cache
target
EOF
    fi
}

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
    echo -e "     /project:explore, /project:plan, /project:commit, etc."
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parser les arguments en premier
    parse_args "$@"

    # Afficher le banner (sauf en mode non-interactif silencieux)
    if ! $NON_INTERACTIVE; then
        print_banner
    fi

    # Vérifier si un chemin est passé en argument
    if [[ -n "$PROJECT_PATH" ]]; then
        if [[ -d "$PROJECT_PATH" ]]; then
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
                PROJECT_PATH="${PWD}/${PROJECT_NAME}"
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
