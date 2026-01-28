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
    Installe 118 commandes, 56 agents et 40 skills pour le workflow Explore → Plan → Code → Commit.

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
    .claude/commands/       118 commandes Claude Code
    .claude/skills/         40 skills spécialisés
    .claude/agents/         56 agents avec contexte isolé
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

    # Détecter Flutter / Dart
    if [[ -f "$dir/pubspec.yaml" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="flutter"
            DETECTED_FRAMEWORK="Flutter"
        fi
        DETECTED_DEPENDENCIES+=("Flutter" "Dart")

        # Détecter les packages Flutter courants
        if grep -q "supabase" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Supabase")
        fi
        if grep -q "firebase" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Firebase")
        fi
        if grep -q "riverpod\|flutter_riverpod" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Riverpod")
        elif grep -q "provider" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Provider")
        elif grep -q "bloc\|flutter_bloc" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("BLoC")
        fi
        if grep -q "graphql" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("GraphQL")
        fi

        # Détecter les plateformes cibles
        local platforms=()
        [[ -d "$dir/android" ]] && platforms+=("Android")
        [[ -d "$dir/ios" ]] && platforms+=("iOS")
        [[ -d "$dir/web" ]] && platforms+=("Web")
        [[ -d "$dir/macos" ]] && platforms+=("macOS")
        [[ -d "$dir/linux" ]] && platforms+=("Linux")
        [[ -d "$dir/windows" ]] && platforms+=("Windows")
        if [[ ${#platforms[@]} -gt 0 ]]; then
            DETECTED_DEPENDENCIES+=("Platforms: ${platforms[*]}")
        fi
    fi

    # Détecter Neovim config
    # Cherche init.lua + lua/ à la racine ou dans nvim/ (dotfiles pattern)
    local nvim_root=""
    if [[ -f "$dir/init.lua" ]] && [[ -d "$dir/lua" ]]; then
        nvim_root="$dir"
    elif [[ -f "$dir/nvim/init.lua" ]] && [[ -d "$dir/nvim/lua" ]]; then
        nvim_root="$dir/nvim"
    elif [[ -f "$dir/.config/nvim/init.lua" ]] && [[ -d "$dir/.config/nvim/lua" ]]; then
        nvim_root="$dir/.config/nvim"
    fi

    if [[ -n "$nvim_root" ]]; then
        if [[ -z "$DETECTED_TYPE" ]]; then
            DETECTED_TYPE="neovim"
            DETECTED_FRAMEWORK="Neovim"
        fi
        DETECTED_DEPENDENCIES+=("Lua" "Neovim")

        # Indiquer si la config est dans un sous-dossier
        if [[ "$nvim_root" != "$dir" ]]; then
            local subdir="${nvim_root#$dir/}"
            DETECTED_DEPENDENCIES+=("(config in $subdir/)")
        fi

        # Détecter le plugin manager
        if grep -rq "lazy.nvim\|folke/lazy" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("lazy.nvim")
        elif grep -rq "packer.nvim\|wbthomason/packer" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("packer.nvim")
        fi

        # Détecter LSP
        if grep -rq "nvim-lspconfig\|neovim/nvim-lspconfig" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("LSP")
        fi

        # Détecter Treesitter
        if grep -rq "nvim-treesitter" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Treesitter")
        fi

        # Détecter d'autres plugins courants
        if grep -rq "telescope.nvim\|nvim-telescope" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("Telescope")
        fi
        if grep -rq "nvim-cmp\|hrsh7th/nvim-cmp" "$nvim_root/lua" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("nvim-cmp")
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
        mapfile -t DETECTED_SCRIPTS < <(node -e "
            const pkg = require('$package_json');
            if (pkg.scripts) {
                Object.keys(pkg.scripts).forEach(s => console.log(s));
            }
        " 2>/dev/null)
    else
        # Fallback: extraction basique avec sed (compatible macOS/Linux)
        mapfile -t DETECTED_SCRIPTS < <(sed -n 's/.*"\([^"]*\)"[[:space:]]*:.*/\1/p' "$package_json" 2>/dev/null | head -20)
    fi
}

extract_main_dependencies() {
    local package_json="$1"

    if command -v node &> /dev/null; then
        mapfile -t DETECTED_MAIN_DEPS < <(node -e "
            const pkg = require('$package_json');
            const deps = { ...pkg.dependencies, ...pkg.devDependencies };
            const important = ['react', 'vue', 'angular', 'next', 'nuxt', 'express', 'fastify', 'nestjs', 'prisma', 'typeorm', 'sequelize', 'mongoose', 'jest', 'vitest', 'cypress', 'playwright', 'tailwindcss', 'styled-components', 'emotion'];
            important.forEach(dep => {
                if (deps[dep] || deps['@' + dep + '/core']) console.log(dep);
            });
        " 2>/dev/null)
    fi
}

extract_python_dependencies() {
    local dir="$1"

    if [[ -f "$dir/requirements.txt" ]]; then
        mapfile -t DETECTED_MAIN_DEPS < <(grep -oP '^[a-zA-Z][a-zA-Z0-9_-]*' "$dir/requirements.txt" 2>/dev/null | head -10)
    fi
}

detect_folder_structure() {
    local dir="$1"

    # Détecter les dossiers courants (incluant Flutter: lib, android, ios, web, macos, linux, windows)
    local common_folders=("src" "lib" "app" "pages" "components" "services" "utils" "hooks" "api" "routes" "controllers" "models" "views" "tests" "test" "__tests__" "spec" "public" "static" "assets" "styles" "config" "scripts" "docs" "packages" "apps" "android" "ios" "web" "macos" "linux" "windows" "widgets" "screens" "providers" "blocs" "repositories")

    for folder in "${common_folders[@]}"; do
        if [[ -d "$dir/$folder" ]]; then
            # Compter les fichiers dans le dossier
            local count
            count=$(find "$dir/$folder" -type f 2>/dev/null | wc -l)
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

# Installe tous les fichiers .claude/ (commands, skills, agents, rules, etc.)
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
install_claude_files() {
    local target_dir="$1"

    info "Installation des fichiers Claude..."

    # Créer la structure de base
    make_dir "$target_dir/.claude/commands"
    make_dir "$target_dir/.claude/skills"
    make_dir "$target_dir/.claude/agents"
    make_dir "$target_dir/.claude/rules"
    make_dir "$target_dir/.claude/output-styles"
    make_dir "$target_dir/.claude/templates"

    # Copier les commandes
    debug "Copie des commandes..."
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/commands/* → $target_dir/.claude/commands/"
    else
        cp -r "$SOCLE_DIR/.claude/commands/"* "$target_dir/.claude/commands/"
    fi

    # Copier settings.json
    copy_file "$SOCLE_DIR/.claude/settings.json" "$target_dir/.claude/"

    # Copier les skills
    if [[ -d "$SOCLE_DIR/.claude/skills" ]]; then
        debug "Copie des skills..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/skills/* → $target_dir/.claude/skills/"
        else
            cp -r "$SOCLE_DIR/.claude/skills/"* "$target_dir/.claude/skills/"
        fi
    fi

    # Copier les agents
    if [[ -d "$SOCLE_DIR/.claude/agents" ]]; then
        debug "Copie des agents..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/agents/* → $target_dir/.claude/agents/"
        else
            cp -r "$SOCLE_DIR/.claude/agents/"* "$target_dir/.claude/agents/"
        fi
    fi

    # Copier les rules
    if [[ -d "$SOCLE_DIR/.claude/rules" ]]; then
        debug "Copie des rules..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/rules/* → $target_dir/.claude/rules/"
        else
            cp -r "$SOCLE_DIR/.claude/rules/"* "$target_dir/.claude/rules/"
        fi
    fi

    # Copier les output-styles
    if [[ -d "$SOCLE_DIR/.claude/output-styles" ]]; then
        debug "Copie des output-styles..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/output-styles/* → $target_dir/.claude/output-styles/"
        else
            cp -r "$SOCLE_DIR/.claude/output-styles/"* "$target_dir/.claude/output-styles/"
        fi
    fi

    # Copier les templates
    if [[ -d "$SOCLE_DIR/.claude/templates" ]]; then
        debug "Copie des templates..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/templates/* → $target_dir/.claude/templates/"
        else
            cp -r "$SOCLE_DIR/.claude/templates/"* "$target_dir/.claude/templates/"
        fi
    fi

    success "Commandes, skills, agents, rules, styles et templates copiés"
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
        chmod +x "$target_dir/.husky/"* 2>/dev/null || true
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
                echo "# Claude Code local config" >> "$target_dir/.gitignore"
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
    echo "  - .claude/commands/      (118 commandes)"
    echo "  - .claude/skills/        ($(count_skills "$SOCLE_DIR") skills)"
    echo "  - .claude/agents/        (56 agents)"
    echo "  - .claude/rules/         (règles contextuelles)"
    echo "  - .claude/output-styles/ (styles de sortie)"
    echo "  - .claude/templates/     (templates spec, Proxmox, etc.)"
    echo "  - .claude/settings.json  ($(count_hooks "$SOCLE_DIR") hooks)"
    echo "  - CLAUDE.md"
    echo "  - CLAUDE.local.md.example"
    echo ""

    info "Prochaines étapes:"
    echo "  1. Personnalisez CLAUDE.md selon votre projet"
    echo "  2. Copiez CLAUDE.local.md.example en CLAUDE.local.md"
    echo "  3. Lancez Claude Code: cd $target_dir && claude"
    echo ""

    info "Commandes disponibles:"
    echo "  /explore, /plan, /commit, etc."
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
    $INCLUDE_DOCKER && create_dockerfile_in_dir "$target_dir"

    # Mettre à jour .gitignore
    update_gitignore_file "$target_dir"

    # Initialiser git si pas déjà fait
    if [[ ! -d "$target_dir/.git" ]] && ! $DRY_RUN; then
        (cd "$target_dir" && git init -q)
        success "Repository git initialisé"
    fi

    # Afficher le résumé
    print_simple_summary "$target_dir"
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
            flutter)
                cat >> "$output_file" << 'EOF'
| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter run` | Lancer en mode debug |
| `flutter test` | Lancer les tests |
| `flutter build apk` | Build Android |
| `flutter build ios` | Build iOS |
| `flutter build web` | Build Web |
| `flutter analyze` | Analyser le code |
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
                android)     desc="Code Android natif" ;;
                ios)         desc="Code iOS natif" ;;
                macos)       desc="Code macOS natif" ;;
                linux)       desc="Code Linux natif" ;;
                windows)     desc="Code Windows natif" ;;
                widgets)     desc="Widgets Flutter réutilisables" ;;
                screens)     desc="Écrans de l'application" ;;
                providers)   desc="State management (Provider/Riverpod)" ;;
                blocs)       desc="State management (BLoC)" ;;
                repositories) desc="Couche d'accès aux données" ;;
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
## Agents Disponibles (118 commandes, 56 agents)

| Catégorie | Commandes |
|-----------|-----------|
| **Workflow** | \`/work-explore\`, \`/work-plan\`, \`/work-commit\`, \`/work-pr\` |
| **Développement** | \`/dev-tdd\`, \`/dev-test\`, \`/dev-debug\`, \`/dev-refactor\`, \`/dev-api\` |
| **Qualité** | \`/qa-review\`, \`/qa-security\`, \`/qa-perf\`, \`/qa-a11y\` |
| **Ops** | \`/ops-hotfix\`, \`/ops-release\`, \`/ops-migrate\`, \`/ops-docker\` |

Utilisez \`/doc-onboard\` pour découvrir tous les agents disponibles.

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

clean_claude_dirs() {
    local dir="$1"

    info "Nettoyage des anciens fichiers Claude..."

    # Liste des sous-dossiers à nettoyer
    local dirs_to_clean=("commands" "skills" "agents" "rules" "output-styles" "templates")

    for subdir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir/.claude/$subdir" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} rm -rf $dir/.claude/$subdir"
            else
                rm -rf "$dir/.claude/$subdir"
            fi
            debug "Supprimé: .claude/$subdir"
        fi
    done

    success "Anciens fichiers nettoyés"
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

    # Créer la structure de base
    make_dir "$TARGET_DIR/.claude/commands"

    # Copier les commandes Claude
    info "Installation des commandes Claude..."
    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/commands/* → $TARGET_DIR/.claude/commands/"
    else
        cp -r "$SOCLE_DIR/.claude/commands/"* "$TARGET_DIR/.claude/commands/"
    fi

    # Copier les agents
    if [[ -d "$SOCLE_DIR/.claude/agents" ]]; then
        make_dir "$TARGET_DIR/.claude/agents"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/agents/* → $TARGET_DIR/.claude/agents/"
        else
            cp -r "$SOCLE_DIR/.claude/agents/"* "$TARGET_DIR/.claude/agents/"
        fi
    fi

    # Copier les rules
    if [[ -d "$SOCLE_DIR/.claude/rules" ]]; then
        make_dir "$TARGET_DIR/.claude/rules"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/rules/* → $TARGET_DIR/.claude/rules/"
        else
            cp -r "$SOCLE_DIR/.claude/rules/"* "$TARGET_DIR/.claude/rules/"
        fi
    fi

    # Copier les output-styles
    if [[ -d "$SOCLE_DIR/.claude/output-styles" ]]; then
        make_dir "$TARGET_DIR/.claude/output-styles"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/output-styles/* → $TARGET_DIR/.claude/output-styles/"
        else
            cp -r "$SOCLE_DIR/.claude/output-styles/"* "$TARGET_DIR/.claude/output-styles/"
        fi
    fi

    # Copier les templates
    if [[ -d "$SOCLE_DIR/.claude/templates" ]]; then
        make_dir "$TARGET_DIR/.claude/templates"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/templates/* → $TARGET_DIR/.claude/templates/"
        else
            cp -r "$SOCLE_DIR/.claude/templates/"* "$TARGET_DIR/.claude/templates/"
        fi
    fi

    copy_file "$SOCLE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"

    # Copier les skills
    if [[ -d "$SOCLE_DIR/.claude/skills" ]]; then
        make_dir "$TARGET_DIR/.claude/skills"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.claude/skills/* → $TARGET_DIR/.claude/skills/"
        else
            cp -r "$SOCLE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
        fi
    fi
    success "Commandes Claude installées (118 commandes, 56 agents, 40 skills)"

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
                sed -i "s/# Projet .*/# Projet ${PROJECT_NAME}/" "$TARGET_DIR/CLAUDE.md" 2>/dev/null || \
                sed -i '' "s/# Projet .*/# Projet ${PROJECT_NAME}/" "$TARGET_DIR/CLAUDE.md" 2>/dev/null || true
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

    # GitHub Actions
    # Gestion CI/CD selon l'action choisie
    if $INCLUDE_CICD; then
        info "Installation de GitHub Actions..."
        make_dir "$TARGET_DIR/.github/workflows"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $SOCLE_DIR/.github/workflows/* → $TARGET_DIR/.github/workflows/"
        else
            cp -r "$SOCLE_DIR/.github/workflows/"* "$TARGET_DIR/.github/workflows/"
        fi
        success "GitHub Actions installés"
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

    # Pre-commit hooks
    if $INCLUDE_HOOKS; then
        info "Installation des pre-commit hooks..."
        make_dir "$TARGET_DIR/.husky"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r husky + config files → $TARGET_DIR/"
        else
            cp -r "$SOCLE_DIR/.husky/"* "$TARGET_DIR/.husky/"
            cp "$SOCLE_DIR/.lintstagedrc.json" "$TARGET_DIR/"
            cp "$SOCLE_DIR/.commitlintrc.json" "$TARGET_DIR/"
            cp "$SOCLE_DIR/.pre-commit-config.yaml" "$TARGET_DIR/" 2>/dev/null || true
            chmod +x "$TARGET_DIR/.husky/"* 2>/dev/null || true
        fi
        success "Pre-commit hooks installés"
    fi

    # MCP
    if $INCLUDE_MCP; then
        info "Installation de la configuration MCP..."
        copy_file "$SOCLE_DIR/.mcp.json" "$TARGET_DIR/"
        success "Configuration MCP installée"
    fi

    # Docker
    if $INCLUDE_DOCKER; then
        create_dockerfile_in_dir "$TARGET_DIR"
    fi

    # .gitignore (merge si existe déjà)
    if [[ -f "$TARGET_DIR/.gitignore" ]]; then
        # Ajouter les entrées Claude si pas déjà présentes
        if ! grep -q "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            if ! $DRY_RUN; then
                echo "" >> "$TARGET_DIR/.gitignore"
                echo "# Claude Code" >> "$TARGET_DIR/.gitignore"
                echo "CLAUDE.local.md" >> "$TARGET_DIR/.gitignore"
                echo ".claude/settings.local.json" >> "$TARGET_DIR/.gitignore"
            else
                echo -e "${DIM}[DRY-RUN]${NC} Ajout entrées Claude à .gitignore"
            fi
            success ".gitignore mis à jour"
        fi
    else
        copy_file "$SOCLE_DIR/.gitignore" "$TARGET_DIR/"
        success ".gitignore créé"
    fi

    # Initialiser git si pas déjà fait
    if [[ ! -d "$TARGET_DIR/.git" ]]; then
        if ! $DRY_RUN; then
            (cd "$TARGET_DIR" && git init -q)
        else
            echo -e "${DIM}[DRY-RUN]${NC} git init dans $TARGET_DIR"
        fi
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
        flutter)
            cat > Dockerfile << 'EOF'
# Flutter Web Build
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Production stage (nginx for web)
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
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

# Crée un Dockerfile dans un répertoire spécifié (pour mode simple)
# Arguments:
#   $1 - Répertoire cible (chemin absolu)
create_dockerfile_in_dir() {
    local target_dir="$1"

    info "Création des fichiers Docker..."

    # Ne pas écraser un Dockerfile existant
    if [[ -f "$target_dir/Dockerfile" ]]; then
        warning "Dockerfile existe déjà, ignoré"
        return
    fi

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} Création de Dockerfile dans $target_dir"
        return
    fi

    # Utiliser le type détecté ou générique
    local type="${PROJECT_TYPE:-generic}"

    # Créer un Dockerfile basique selon le type de projet
    case $type in
        react|vue)
            cat > "$target_dir/Dockerfile" << 'EOF'
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
            cat > "$target_dir/Dockerfile" << 'EOF'
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
            cat > "$target_dir/Dockerfile" << 'EOF'
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
            cat > "$target_dir/Dockerfile" << 'EOF'
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
            cat > "$target_dir/Dockerfile" << 'EOF'
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
            cat > "$target_dir/Dockerfile" << 'EOF'
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
        flutter)
            cat > "$target_dir/Dockerfile" << 'EOF'
# Flutter Web Build
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Production stage (nginx for web)
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
            ;;
        *)
            cat > "$target_dir/Dockerfile" << 'EOF'
FROM ubuntu:22.04
WORKDIR /app
COPY . .
# Customize this Dockerfile for your project
CMD ["bash"]
EOF
            ;;
    esac

    # Créer .dockerignore si n'existe pas
    if [[ ! -f "$target_dir/.dockerignore" ]]; then
        cat > "$target_dir/.dockerignore" << 'EOF'
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

    success "Fichiers Docker créés"
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
    echo -e "     /work-explore, /work-plan, /work-commit, etc."
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
