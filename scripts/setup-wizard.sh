#!/usr/bin/env bash
# Setup Wizard - Configuration intelligente du socle Claude Code
# Usage: ./scripts/setup-wizard.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="${1:-.}"

# Helpers
print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -rp "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy] ]]
}

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice

    echo -e "${BLUE}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i + 1)). ${options[$i]}"
    done

    while true; do
        read -rp "Choix (1-${#options[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options[@]})); then
            echo "$((choice - 1))"
            return
        fi
        print_error "Choix invalide"
    done
}

ask_multiple() {
    local prompt="$1"
    shift
    local options=("$@")
    local selections=()

    echo -e "${BLUE}$prompt${NC} (separés par des espaces)"
    for i in "${!options[@]}"; do
        echo "  $((i + 1)). ${options[$i]}"
    done

    read -rp "Choix (ex: 1 3 4): " -a choices

    for choice in "${choices[@]}"; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options[@]})); then
            selections+=("${options[$((choice - 1))]}")
        fi
    done

    printf '%s\n' "${selections[@]}"
}

# Wizard steps
detect_project_type() {
    print_header "Detection du type de projet"

    local detected=()

    # Detect package managers and frameworks
    [[ -f "$TARGET_DIR/package.json" ]] && detected+=("Node.js")
    [[ -f "$TARGET_DIR/pubspec.yaml" ]] && detected+=("Flutter")
    [[ -f "$TARGET_DIR/Cargo.toml" ]] && detected+=("Rust")
    [[ -f "$TARGET_DIR/go.mod" ]] && detected+=("Go")
    [[ -f "$TARGET_DIR/requirements.txt" ]] || [[ -f "$TARGET_DIR/pyproject.toml" ]] && detected+=("Python")
    [[ -f "$TARGET_DIR/composer.json" ]] && detected+=("PHP")
    [[ -f "$TARGET_DIR/Gemfile" ]] && detected+=("Ruby")
    [[ -f "$TARGET_DIR/pom.xml" ]] || [[ -f "$TARGET_DIR/build.gradle" ]] && detected+=("Java")
    [[ -f "$TARGET_DIR/*.csproj" ]] 2>/dev/null && detected+=("C#")

    # Detect frameworks
    if [[ -f "$TARGET_DIR/package.json" ]]; then
        local pkg_content
        pkg_content=$(cat "$TARGET_DIR/package.json" 2>/dev/null || echo "{}")
        [[ "$pkg_content" == *"next"* ]] && detected+=("Next.js")
        [[ "$pkg_content" == *"react"* ]] && detected+=("React")
        [[ "$pkg_content" == *"vue"* ]] && detected+=("Vue.js")
        [[ "$pkg_content" == *"express"* ]] && detected+=("Express")
        [[ "$pkg_content" == *"fastify"* ]] && detected+=("Fastify")
    fi

    if [[ ${#detected[@]} -gt 0 ]]; then
        print_success "Technologies detectées:"
        for tech in "${detected[@]}"; do
            echo "  - $tech"
        done
        echo "${detected[@]}"
    else
        print_warning "Aucune technologie detectée"
        echo ""
    fi
}

choose_project_type() {
    print_header "Type de projet"

    local types=("Web (React/Next.js/Vue)" "Mobile (Flutter)" "API Backend (Node/Python)" "Data Engineering" "Fullstack" "Autre")
    local choice
    choice=$(ask_choice "Quel type de projet?" "${types[@]}")

    case $choice in
        0) echo "web" ;;
        1) echo "mobile" ;;
        2) echo "api" ;;
        3) echo "data" ;;
        4) echo "fullstack" ;;
        *) echo "other" ;;
    esac
}

choose_languages() {
    print_header "Langages de programmation"

    local languages=("TypeScript" "JavaScript" "Dart (Flutter)" "Python" "Go" "Rust" "Java" "C#" "Ruby" "PHP")
    local selected
    selected=$(ask_multiple "Quels langages utilisez-vous?" "${languages[@]}")

    echo "$selected"
}

choose_features() {
    print_header "Fonctionnalités"

    local features=("CI/CD (GitHub Actions)" "Docker" "Testing (Jest/Vitest)" "Linting (ESLint/Prettier)" "Database (PostgreSQL/MongoDB)" "Auth (JWT/OAuth)" "Monitoring" "Documentation")
    local selected
    selected=$(ask_multiple "Quelles fonctionnalités avez-vous besoin?" "${features[@]}")

    echo "$selected"
}

generate_config() {
    local project_type="$1"
    local languages="$2"
    local features="$3"

    print_header "Generation de la configuration"

    # Create .claude directory structure
    mkdir -p "$TARGET_DIR/.claude"

    # Copy base structure
    print_step "Copie de la structure de base..."
    cp -r "$SOCLE_DIR/.claude/commands" "$TARGET_DIR/.claude/" 2>/dev/null || true
    cp -r "$SOCLE_DIR/.claude/skills" "$TARGET_DIR/.claude/" 2>/dev/null || true
    cp -r "$SOCLE_DIR/.claude/rules" "$TARGET_DIR/.claude/" 2>/dev/null || true
    cp -r "$SOCLE_DIR/.claude/agents" "$TARGET_DIR/.claude/" 2>/dev/null || true
    cp -r "$SOCLE_DIR/.claude/output-styles" "$TARGET_DIR/.claude/" 2>/dev/null || true

    # Generate settings.json based on project type
    print_step "Generation de settings.json..."
    generate_settings "$project_type" "$features"

    # Generate customized CLAUDE.md
    print_step "Generation de CLAUDE.md..."
    generate_claude_md "$project_type" "$languages"

    # Copy MCP config if needed
    if [[ "$features" == *"Database"* ]] || [[ "$features" == *"Monitoring"* ]]; then
        print_step "Configuration MCP..."
        cp "$SOCLE_DIR/.mcp.json" "$TARGET_DIR/" 2>/dev/null || true
    fi

    print_success "Configuration generee!"
}

generate_settings() {
    local project_type="$1"
    local features="$2"

    local settings_file="$TARGET_DIR/.claude/settings.json"

    # Start with base settings
    cat > "$settings_file" << 'EOF'
{
  "version": "1.0",
  "hooks": {
    "PreToolUse": [
EOF

    # Add protection for main branch
    cat >> "$settings_file" << 'EOF'
      {
        "matcher": "Edit|Write",
        "command": "git rev-parse --abbrev-ref HEAD 2>/dev/null | grep -qE '^(main|master)$' && echo 'BLOCK: Ne pas modifier directement sur main/master. Créez une branche.' || true"
      }
EOF

    cat >> "$settings_file" << 'EOF'
    ],
    "PostToolUse": [
EOF

    # Add auto-format if linting is selected
    if [[ "$features" == *"Linting"* ]]; then
        if [[ "$project_type" == "web" ]] || [[ "$project_type" == "api" ]] || [[ "$project_type" == "fullstack" ]]; then
            cat >> "$settings_file" << 'EOF'
      {
        "matcher": "Edit|Write",
        "command": "[[ \"$CLAUDE_TOOL_ARG_file_path\" =~ \\.(ts|tsx|js|jsx)$ ]] && npx prettier --write \"$CLAUDE_TOOL_ARG_file_path\" 2>/dev/null || true"
      },
EOF
        fi

        if [[ "$project_type" == "mobile" ]]; then
            cat >> "$settings_file" << 'EOF'
      {
        "matcher": "Edit|Write",
        "command": "[[ \"$CLAUDE_TOOL_ARG_file_path\" =~ \\.dart$ ]] && dart format \"$CLAUDE_TOOL_ARG_file_path\" 2>/dev/null || true"
      },
EOF
        fi
    fi

    # Add auto npm install
    if [[ "$project_type" == "web" ]] || [[ "$project_type" == "api" ]] || [[ "$project_type" == "fullstack" ]]; then
        cat >> "$settings_file" << 'EOF'
      {
        "matcher": "Edit|Write",
        "command": "[[ \"$CLAUDE_TOOL_ARG_file_path\" =~ package\\.json$ ]] && npm install 2>/dev/null || true"
      }
EOF
    fi

    # Add auto flutter pub get
    if [[ "$project_type" == "mobile" ]]; then
        cat >> "$settings_file" << 'EOF'
      {
        "matcher": "Edit|Write",
        "command": "[[ \"$CLAUDE_TOOL_ARG_file_path\" =~ pubspec\\.yaml$ ]] && flutter pub get 2>/dev/null || true"
      }
EOF
    fi

    cat >> "$settings_file" << 'EOF'
    ]
  }
}
EOF

    print_success "settings.json genere"
}

generate_claude_md() {
    local project_type="$1"
    local languages="$2"

    local claude_md="$TARGET_DIR/CLAUDE.md"

    cat > "$claude_md" << EOF
# Projet $(basename "$TARGET_DIR")

> Configuration Claude Code generee par le setup wizard

## Type de projet
- **Type**: $project_type
- **Langages**: $languages

## Workflow Obligatoire

\`\`\`
/work-explore → /work-plan → /dev-* → /work-commit
\`\`\`

EOF

    # Add project-specific sections
    case $project_type in
        web)
            cat >> "$claude_md" << 'EOF'
## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run build` | Build de production |
| `npm run lint` | Vérifier le code |

## Structure Recommandée

```
/src
├── /components     # Composants UI
├── /hooks          # Custom hooks
├── /services       # Logique métier
├── /utils          # Utilitaires
└── /types          # Types TypeScript
```

## Agents Recommandés

- `/work-explore` - Explorer le code
- `/dev-component` - Créer des composants
- `/dev-hook` - Créer des hooks
- `/qa-perf` - Optimiser les performances
- `/qa-a11y` - Accessibilité
EOF
            ;;

        mobile)
            cat >> "$claude_md" << 'EOF'
## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter run` | Lancer sur device |
| `flutter test` | Lancer les tests |
| `flutter build` | Build production |
| `flutter analyze` | Analyser le code |

## Structure Clean Architecture

```
/lib
├── /core           # Constantes, erreurs, utils
├── /features       # Features par domaine
│   └── /[feature]
│       ├── /data
│       ├── /domain
│       └── /presentation
├── /shared         # Widgets partagés
└── /config         # Routes, injection
```

## Agents Recommandés

- `/work-explore` - Explorer le code
- `/dev-flutter` - Créer des widgets/screens
- `/dev-supabase` - Backend Supabase
- `/qa-mobile` - Audit mobile
EOF
            ;;

        api)
            cat >> "$claude_md" << 'EOF'
## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run build` | Build production |

## Structure Recommandée

```
/src
├── /api            # Routes et controllers
├── /services       # Logique métier
├── /repositories   # Accès données
├── /models         # Types et schemas
├── /validators     # Validation input
└── /config         # Configuration
```

## Agents Recommandés

- `/dev-api` - Créer des endpoints
- `/dev-api-versioning` - Versioning API
- `/doc-api-spec` - Documentation OpenAPI
- `/qa-security` - Audit sécurité OWASP
EOF
            ;;

        data)
            cat >> "$claude_md" << 'EOF'
## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `dbt run` | Exécuter les modèles |
| `dbt test` | Tests data quality |
| `airflow dags test` | Tester les DAGs |

## Structure Recommandée

```
/data-platform
├── /ingestion      # Sources de données
├── /staging        # Zone de préparation
├── /warehouse      # Modèles transformés
├── /orchestration  # DAGs Airflow
└── /quality        # Tests et validations
```

## Agents Recommandés

- `/data-pipeline` - Créer des pipelines ETL
- `/data-modeling` - Modèles dbt
- `/data-analytics` - Dashboards et KPIs
- `/ops-monitoring` - Monitoring pipelines
EOF
            ;;
    esac

    # Common sections
    cat >> "$claude_md" << 'EOF'

## Conventions de Code

- Mode strict TypeScript activé
- Pas de `any` sauf cas exceptionnels
- Tests minimum 80% couverture
- Conventional Commits

## Anti-patterns à Éviter

- Coder sans explorer l'existant
- Implémenter sans plan validé
- Commits géants multi-fonctionnalités
- Ignorer les warnings de lint/types

## Documentation

- [Guide Workflows](docs/WORKFLOWS.md)
- [Architecture](docs/ARCHITECTURE.md)
EOF

    print_success "CLAUDE.md genere"
}

show_summary() {
    print_header "Resume de la configuration"

    echo -e "Fichiers crees:"
    echo -e "  ${GREEN}✓${NC} .claude/commands/"
    echo -e "  ${GREEN}✓${NC} .claude/skills/"
    echo -e "  ${GREEN}✓${NC} .claude/rules/"
    echo -e "  ${GREEN}✓${NC} .claude/agents/"
    echo -e "  ${GREEN}✓${NC} .claude/output-styles/"
    echo -e "  ${GREEN}✓${NC} .claude/settings.json"
    echo -e "  ${GREEN}✓${NC} CLAUDE.md"

    echo ""
    echo -e "${CYAN}Prochaines etapes:${NC}"
    echo "  1. Reviser CLAUDE.md pour l'adapter a votre projet"
    echo "  2. Tester avec: claude"
    echo "  3. Commencer avec: /work-explore"
    echo ""
    echo -e "${GREEN}Configuration terminee!${NC}"
}

# Main
main() {
    print_header "Claude Code Setup Wizard v1.0"
    echo "Ce wizard va configurer le socle Claude Code pour votre projet."
    echo ""

    # Check if already configured
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        if ! ask_yes_no "Une configuration existe déjà. Écraser?" "n"; then
            print_warning "Configuration annulee"
            exit 0
        fi
    fi

    # Detect existing project
    local detected
    detected=$(detect_project_type)

    # Choose project type
    local project_type
    project_type=$(choose_project_type)

    # Choose languages
    local languages
    languages=$(choose_languages)

    # Choose features
    local features
    features=$(choose_features)

    # Generate config
    generate_config "$project_type" "$languages" "$features"

    # Show summary
    show_summary
}

main "$@"
