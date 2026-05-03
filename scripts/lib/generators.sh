#!/bin/bash

# =============================================================================
# Claude-Socle Generators Library
# Smart CLAUDE.md generation
# Extracted from new-project.sh for independent maintenance
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

generate_smart_claude_md() {
    local output_file="$1"

    info "Smart CLAUDE.md generation..."

    cat > "$output_file" << EOF
# ${PROJECT_NAME} Project

EOF

    # Essential Commands section
    echo "## Essential Commands" >> "$output_file"
    echo "" >> "$output_file"

    if [[ ${#DETECTED_SCRIPTS[@]} -gt 0 ]]; then
        echo "| Command | Description |" >> "$output_file"
        echo "|---------|-------------|" >> "$output_file"

        # Map common scripts to their descriptions
        for script in "${DETECTED_SCRIPTS[@]}"; do
            local desc=""
            case "$script" in
                dev|start:dev|serve)     desc="Development server" ;;
                start)                    desc="Start the application" ;;
                build)                    desc="Production build" ;;
                test)                     desc="Run tests" ;;
                test:watch)               desc="Tests in watch mode" ;;
                test:cov|test:coverage)   desc="Tests with coverage" ;;
                test:e2e)                 desc="End-to-end tests" ;;
                lint)                     desc="Check the code (linter)" ;;
                lint:fix)                 desc="Automatically fix linting" ;;
                format)                   desc="Format the code" ;;
                typecheck|type-check)     desc="Check TypeScript types" ;;
                clean)                    desc="Clean generated files" ;;
                db:migrate)               desc="Run DB migrations" ;;
                db:seed)                  desc="Seed the database" ;;
                docker:build)             desc="Build the Docker image" ;;
                docker:up)                desc="Start the containers" ;;
                storybook)                desc="Launch Storybook" ;;
                generate)                 desc="Generate code" ;;
                preview)                  desc="Preview the build" ;;
                *)                        desc="Script $script" ;;
            esac
            local run_cmd="$DETECTED_PKG_MANAGER run"
            [[ "$DETECTED_PKG_MANAGER" == "yarn" ]] && run_cmd="yarn"
            [[ "$DETECTED_PKG_MANAGER" == "bun" ]] && run_cmd="bun run"
            echo "| \`$run_cmd $script\` | $desc |" >> "$output_file"
        done
    else
        # Default scripts based on project type
        case "$PROJECT_TYPE" in
            react|vue)
                cat >> "$output_file" << 'EOF'
| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Development server |
| `npm run build` | Production build |
| `npm test` | Run tests |
| `npm run lint` | Check the code |
EOF
                ;;
            python)
                cat >> "$output_file" << 'EOF'
| Command | Description |
|---------|-------------|
| `pip install -r requirements.txt` | Install dependencies |
| `python main.py` | Run the application |
| `pytest` | Run tests |
| `flake8` | Check the code |
EOF
                ;;
            go)
                cat >> "$output_file" << 'EOF'
| Command | Description |
|---------|-------------|
| `go mod download` | Download dependencies |
| `go run .` | Run the application |
| `go test ./...` | Run tests |
| `go build` | Compile |
EOF
                ;;
            flutter)
                cat >> "$output_file" << 'EOF'
| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter test` | Run tests |
| `flutter build apk` | Build Android |
| `flutter build ios` | Build iOS |
| `flutter build web` | Build Web |
| `flutter analyze` | Analyze the code |
EOF
                ;;
            *)
                cat >> "$output_file" << 'EOF'
| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Development server |
| `npm test` | Run tests |
| `npm run build` | Production build |
EOF
                ;;
        esac
    fi

    echo "" >> "$output_file"

    # Project Structure section
    echo "## Project Structure" >> "$output_file"
    echo "" >> "$output_file"
    echo '```' >> "$output_file"

    if [[ ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
        for folder_info in "${DETECTED_FOLDERS[@]}"; do
            local folder="${folder_info%%:*}"
            local count="${folder_info##*:}"
            local desc=""

            case "$folder" in
                src)         desc="Main source code" ;;
                lib)         desc="Libraries and utilities" ;;
                app)         desc="Main application" ;;
                pages)       desc="Application pages" ;;
                components)  desc="Reusable UI components" ;;
                services)    desc="Business logic and services" ;;
                utils)       desc="Utility functions" ;;
                hooks)       desc="Custom hooks" ;;
                api)         desc="API endpoints" ;;
                routes)      desc="Route definitions" ;;
                controllers) desc="Controllers" ;;
                models)      desc="Data models" ;;
                views)       desc="Views / Templates" ;;
                tests|test|__tests__|spec) desc="Tests" ;;
                public)      desc="Static public files" ;;
                static)      desc="Static assets" ;;
                assets)      desc="Resources (images, fonts)" ;;
                styles)      desc="CSS/SCSS styles" ;;
                config)      desc="Configuration" ;;
                scripts)     desc="Utility scripts" ;;
                docs)        desc="Documentation" ;;
                packages)    desc="Monorepo packages" ;;
                apps)        desc="Monorepo applications" ;;
                android)     desc="Native Android code" ;;
                ios)         desc="Native iOS code" ;;
                macos)       desc="Native macOS code" ;;
                linux)       desc="Native Linux code" ;;
                windows)     desc="Native Windows code" ;;
                widgets)     desc="Reusable Flutter widgets" ;;
                screens)     desc="Application screens" ;;
                providers)   desc="State management (Provider/Riverpod)" ;;
                blocs)       desc="State management (BLoC)" ;;
                repositories) desc="Data access layer" ;;
                *)           desc="$folder" ;;
            esac

            echo "/$folder    # $desc ($count files)" >> "$output_file"
        done
    else
        echo "/src        # Source code" >> "$output_file"
        echo "/tests      # Tests" >> "$output_file"
    fi

    echo '```' >> "$output_file"
    echo "" >> "$output_file"

    # Technologies section
    if [[ ${#DETECTED_DEPENDENCIES[@]} -gt 0 ]] || [[ ${#DETECTED_MAIN_DEPS[@]} -gt 0 ]]; then
        echo "## Technologies Used" >> "$output_file"
        echo "" >> "$output_file"

        if [[ -n "$DETECTED_FRAMEWORK" ]]; then
            echo "- **Framework**: $DETECTED_FRAMEWORK" >> "$output_file"
        fi

        if [[ ${#DETECTED_MAIN_DEPS[@]} -gt 0 ]]; then
            echo "- **Main dependencies**: ${DETECTED_MAIN_DEPS[*]}" >> "$output_file"
        fi

        if [[ " ${DETECTED_DEPENDENCIES[*]} " =~ " TypeScript " ]]; then
            echo "- **Language**: TypeScript" >> "$output_file"
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

    # Code Conventions section
    cat >> "$output_file" << 'EOF'
## Code Conventions

### Principles
- IMPORTANT: Always understand the existing code before modifying
- IMPORTANT: Write tests for new features
- YOU MUST follow the project's naming conventions
- Prefer pure functions and immutability

### Git & Commits
- Commit format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Branches: `feature/`, `fix/`, `refactor/`
- IMPORTANT: Never push directly to main

EOF

    # Workflow section
    cat >> "$output_file" << 'EOF'
## Preferred Workflow

1. **EXPLORE**: Read and understand before coding
2. **PLAN**: Propose a plan before implementing
3. **CODE**: Implement with tests
4. **COMMIT**: Atomic and descriptive commits

EOF

    # Available Agents section
    echo "## Available Agents ($(count_commands_cached) commands, $(count_agents_cached) agents)" >> "$output_file"
    echo "" >> "$output_file"
    cat >> "$output_file" << 'EOF'
| Category | Commands |
|----------|----------|
| **Workflow** | \`/work:work-explore\`, \`/work:work-plan\`, \`/work:work-commit\`, \`/work:work-pr\` |
| **Development** | \`/dev:dev-tdd\`, \`/dev:dev-test\`, \`/dev:dev-debug\`, \`/dev:dev-refactor\`, \`/dev:dev-api\` |
| **Quality** | \`/qa:qa-review\`, \`/qa:qa-security\`, \`/qa:qa-perf\`, \`/qa:wcag-audit\` |
| **Ops** | \`/ops:ops-hotfix\`, \`/ops:ops-release\`, \`/ops:ops-migrate\`, \`/ops:ops-docker\` |

Use \`/doc:doc-onboard\` to discover all available agents.

EOF

    success "CLAUDE.md generated with project information"
}

# =============================================================================
# Export functions for sub-shells
# =============================================================================

export -f generate_smart_claude_md
