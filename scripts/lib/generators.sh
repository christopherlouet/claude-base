#!/bin/bash

# =============================================================================
# Claude-Socle Generators Library
# Generation de CLAUDE.md intelligent
# Extrait de new-project.sh pour maintenance independante
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

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

        # Extract test frameworks from detected dependencies
        local test_tools=()
        for dep in "${DETECTED_DEPENDENCIES[@]}"; do
            case "$dep" in
                Jest|Vitest|Cypress|Playwright) test_tools+=("$dep") ;;
            esac
        done
        if [[ ${#test_tools[@]} -gt 0 ]]; then
            local IFS=','
            echo "- **Tests**: ${test_tools[*]}" >> "$output_file"
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
    echo "## Agents Disponibles ($(count_commands_cached) commandes, $(count_agents_cached) agents)" >> "$output_file"
    echo "" >> "$output_file"
    cat >> "$output_file" << 'EOF'
| Catégorie | Commandes |
|-----------|-----------|
| **Workflow** | \`/work:work-explore\`, \`/work:work-plan\`, \`/work:work-commit\`, \`/work:work-pr\` |
| **Développement** | \`/dev:dev-tdd\`, \`/dev:dev-test\`, \`/dev:dev-debug\`, \`/dev:dev-refactor\`, \`/dev:dev-api\` |
| **Qualité** | \`/qa:qa-review\`, \`/qa:qa-security\`, \`/qa:qa-perf\`, \`/qa:wcag-audit\` |
| **Ops** | \`/ops:ops-hotfix\`, \`/ops:ops-release\`, \`/ops:ops-migrate\`, \`/ops:ops-docker\` |

Utilisez \`/doc:doc-onboard\` pour découvrir tous les agents disponibles.

EOF

    success "CLAUDE.md généré avec les informations du projet"
}

# =============================================================================
# Export des fonctions pour les sous-shells
# =============================================================================

export -f generate_smart_claude_md
