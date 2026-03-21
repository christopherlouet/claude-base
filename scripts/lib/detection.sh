#!/bin/bash

# =============================================================================
# Claude-Socle Detection Library
# Fonctions de detection de stack technique
# Extrait de new-project.sh pour reutilisation (doctor.sh, validate.sh, learn.sh)
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

detect_nodejs() {
    local dir="$1"

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

    [[ -f "$dir/package.json" ]] || return 0

    DETECTED_DEPENDENCIES+=("Node.js")
    if [[ "$DETECTED_PKG_MANAGER" != "npm" ]]; then
        DETECTED_DEPENDENCIES+=("$DETECTED_PKG_MANAGER")
    fi

    extract_npm_scripts "$dir/package.json"
    extract_main_dependencies "$dir/package.json"

    # Détecter le framework
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

    # TypeScript
    if [[ -f "$dir/tsconfig.json" ]] || grep -q '"typescript"' "$dir/package.json" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("TypeScript")
    fi

    # Test tools
    for tool in jest vitest cypress playwright; do
        if grep -q "\"$tool\"" "$dir/package.json" 2>/dev/null; then
            local tool_name="${tool^}"  # capitalize first letter
            DETECTED_DEPENDENCIES+=("$tool_name")
        fi
    done

    # Build tools
    for tool in vite webpack; do
        if grep -q "\"$tool\"" "$dir/package.json" 2>/dev/null; then
            local tool_name="${tool^}"
            DETECTED_DEPENDENCIES+=("$tool_name")
        fi
    done

    # Husky/lint-staged
    if grep -q '"husky"' "$dir/package.json" 2>/dev/null || [[ -d "$dir/.husky" ]]; then
        DETECTED_HOOKS=true
        DETECTED_DEPENDENCIES+=("Husky")
    fi

    # Deno
    if [[ -f "$dir/deno.json" ]] || [[ -f "$dir/deno.jsonc" ]]; then
        DETECTED_DEPENDENCIES+=("Deno")
        DETECTED_PKG_MANAGER="deno"
    fi

    # Monorepo / Fullstack
    if [[ -d "$dir/packages" ]] || [[ -d "$dir/apps" ]]; then
        if grep -q '"workspaces"' "$dir/package.json" 2>/dev/null; then
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
}

detect_python() {
    local dir="$1"
    [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]] || [[ -f "$dir/Pipfile" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="python"
        DETECTED_FRAMEWORK="Python"
    fi
    DETECTED_DEPENDENCIES+=("Python")

    extract_python_dependencies "$dir"

    # Détecter le framework Python
    for config_file in "$dir/requirements.txt" "$dir/pyproject.toml"; do
        if [[ -f "$config_file" ]]; then
            if grep -qi "django" "$config_file" 2>/dev/null; then
                DETECTED_FRAMEWORK="Django"
            elif grep -qi "fastapi" "$config_file" 2>/dev/null; then
                DETECTED_FRAMEWORK="FastAPI"
            elif grep -qi "flask" "$config_file" 2>/dev/null; then
                DETECTED_FRAMEWORK="Flask"
            fi
        fi
    done
}

detect_go() {
    local dir="$1"
    [[ -f "$dir/go.mod" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="go"
        DETECTED_FRAMEWORK="Go"
    fi
    DETECTED_DEPENDENCIES+=("Go")

    if grep -q "gin-gonic" "$dir/go.mod" 2>/dev/null; then
        DETECTED_FRAMEWORK="Gin"
    elif grep -q "echo" "$dir/go.mod" 2>/dev/null; then
        DETECTED_FRAMEWORK="Echo"
    elif grep -q "fiber" "$dir/go.mod" 2>/dev/null; then
        DETECTED_FRAMEWORK="Fiber"
    fi
}

detect_rust() {
    local dir="$1"
    [[ -f "$dir/Cargo.toml" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="rust"
        DETECTED_FRAMEWORK="Rust"
    fi
    DETECTED_DEPENDENCIES+=("Rust")

    if grep -q "actix-web" "$dir/Cargo.toml" 2>/dev/null; then
        DETECTED_FRAMEWORK="Actix Web"
    elif grep -q "axum" "$dir/Cargo.toml" 2>/dev/null; then
        DETECTED_FRAMEWORK="Axum"
    elif grep -q "rocket" "$dir/Cargo.toml" 2>/dev/null; then
        DETECTED_FRAMEWORK="Rocket"
    fi
}

detect_java() {
    local dir="$1"
    [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="java"
        DETECTED_FRAMEWORK="Java"
    fi
    DETECTED_DEPENDENCIES+=("Java")

    if { [[ -f "$dir/pom.xml" ]] && grep -q "spring-boot" "$dir/pom.xml" 2>/dev/null; } || \
       { [[ -f "$dir/build.gradle" ]] && grep -q "spring-boot" "$dir/build.gradle" 2>/dev/null; }; then
        DETECTED_FRAMEWORK="Spring Boot"
    fi
}

detect_flutter() {
    local dir="$1"
    [[ -f "$dir/pubspec.yaml" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="flutter"
        DETECTED_FRAMEWORK="Flutter"
    fi
    DETECTED_DEPENDENCIES+=("Flutter" "Dart")

    # Packages Flutter courants
    for pkg in supabase firebase; do
        if grep -q "$pkg" "$dir/pubspec.yaml" 2>/dev/null; then
            DETECTED_DEPENDENCIES+=("${pkg^}")
        fi
    done
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

    # Plateformes cibles
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
}

detect_neovim() {
    local dir="$1"

    # Cherche init.lua + lua/ à la racine ou dans nvim/ (dotfiles pattern)
    local nvim_root=""
    if [[ -f "$dir/init.lua" ]] && [[ -d "$dir/lua" ]]; then
        nvim_root="$dir"
    elif [[ -f "$dir/nvim/init.lua" ]] && [[ -d "$dir/nvim/lua" ]]; then
        nvim_root="$dir/nvim"
    elif [[ -f "$dir/.config/nvim/init.lua" ]] && [[ -d "$dir/.config/nvim/lua" ]]; then
        nvim_root="$dir/.config/nvim"
    fi

    [[ -n "$nvim_root" ]] || return 0

    if [[ -z "$DETECTED_TYPE" ]]; then
        DETECTED_TYPE="neovim"
        DETECTED_FRAMEWORK="Neovim"
    fi
    DETECTED_DEPENDENCIES+=("Lua" "Neovim")

    if [[ "$nvim_root" != "$dir" ]]; then
        local subdir="${nvim_root#$dir/}"
        DETECTED_DEPENDENCIES+=("(config in $subdir/)")
    fi

    # Plugin manager
    if grep -rq "lazy.nvim\|folke/lazy" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("lazy.nvim")
    elif grep -rq "packer.nvim\|wbthomason/packer" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("packer.nvim")
    fi

    # LSP, Treesitter, plugins
    if grep -rq "nvim-lspconfig\|neovim/nvim-lspconfig" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("LSP")
    fi
    if grep -rq "nvim-treesitter" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("Treesitter")
    fi
    if grep -rq "telescope.nvim\|nvim-telescope" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("Telescope")
    fi
    if grep -rq "nvim-cmp\|hrsh7th/nvim-cmp" "$nvim_root/lua" 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("nvim-cmp")
    fi
}

detect_database() {
    local dir="$1"

    # Use -exec grep instead of xargs to handle filenames with spaces safely
    if find "$dir" -maxdepth 2 \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name ".env*" -o -name "docker-compose*" \) -type f -exec grep -lq "postgres\|postgresql" {} + 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("PostgreSQL")
    fi
    if find "$dir" -maxdepth 2 \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name ".env*" -o -name "docker-compose*" \) -type f -exec grep -lq "mongodb\|mongo" {} + 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("MongoDB")
    fi
    if find "$dir" -maxdepth 2 \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name ".env*" -o -name "docker-compose*" \) -type f -exec grep -lq "redis" {} + 2>/dev/null; then
        DETECTED_DEPENDENCIES+=("Redis")
    fi
}

detect_cicd() {
    local dir="$1"

    # Docker
    if [[ -f "$dir/Dockerfile" ]] || [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/docker-compose.yaml" ]]; then
        DETECTED_DOCKER=true
        DETECTED_DEPENDENCIES+=("Docker")
    fi

    # CI/CD
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

    # Pre-commit
    if [[ -f "$dir/.pre-commit-config.yaml" ]]; then
        DETECTED_HOOKS=true
        DETECTED_DEPENDENCIES+=("pre-commit")
    fi
}

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

    # Run all sub-detectors
    detect_nodejs "$dir"
    detect_python "$dir"
    detect_go "$dir"
    detect_rust "$dir"
    detect_java "$dir"
    detect_flutter "$dir"
    detect_neovim "$dir"
    detect_database "$dir"
    detect_cicd "$dir"
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
        # Utiliser Node.js si disponible (NODE_PATH pour éviter l'injection de commande)
        mapfile -t DETECTED_SCRIPTS < <(NODE_PKG_PATH="$package_json" node -e "
            const pkg = require(process.env.NODE_PKG_PATH);
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
        mapfile -t DETECTED_MAIN_DEPS < <(NODE_PKG_PATH="$package_json" node -e "
            const pkg = require(process.env.NODE_PKG_PATH);
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
# Export des fonctions pour les sous-shells
# =============================================================================

export -f detect_nodejs detect_python detect_go detect_rust detect_java
export -f detect_flutter detect_neovim detect_database detect_cicd detect_stack
export -f detect_folder_structure
export -f extract_npm_scripts extract_main_dependencies extract_python_dependencies
