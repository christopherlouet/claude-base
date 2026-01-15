#!/bin/bash

# =============================================================================
# Claude-Socle IDE Integration Script
# Configure les IDE pour une intégration optimale avec claude-socle
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Charger la librairie commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # Used by sourced scripts
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Variables
TARGET_DIR=""
# shellcheck disable=SC2034  # Set via command-line parsing
IDE_TYPE=""
DRY_RUN=false
FORCE=false

# =============================================================================
# Aide et version
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle IDE Integration${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") <setup|check|remove> <ide> [OPTIONS] [CHEMIN]

${BOLD}DESCRIPTION${NC}
    Configure les IDE pour une intégration optimale avec claude-socle.
    Génère des snippets, tasks, keybindings et recommendations d'extensions.

${BOLD}COMMANDES${NC}
    setup <ide>     Configure l'IDE spécifié
    check <ide>     Vérifie la configuration existante
    remove <ide>    Supprime la configuration claude-socle

${BOLD}IDE SUPPORTÉS${NC}
    vscode          Visual Studio Code
    cursor          Cursor (fork de VSCode)
    idea            IntelliJ IDEA / WebStorm / PyCharm
    vim             Vim / Neovim
    all             Tous les IDE détectés

${BOLD}OPTIONS${NC}
    -h, --help      Affiche cette aide
    -v, --version   Affiche la version
    -n, --dry-run   Simule sans modifier
    -f, --force     Écrase les fichiers existants

${BOLD}EXEMPLES${NC}
    # Configurer VSCode dans le projet courant
    $(basename "$0") setup vscode

    # Configurer VSCode dans un projet spécifique
    $(basename "$0") setup vscode /chemin/projet

    # Vérifier la configuration IntelliJ
    $(basename "$0") check idea

    # Configurer tous les IDE (mode dry-run)
    $(basename "$0") setup all --dry-run

    # Supprimer la configuration
    $(basename "$0") remove vscode

EOF
}

show_version() {
    echo "Claude-Socle IDE Integration v${VERSION}"
}

# =============================================================================
# Configuration VSCode / Cursor
# =============================================================================

setup_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    info "Configuration VSCode/Cursor..."

    make_dir "$config_dir"

    # Settings
    setup_vscode_settings "$config_dir"

    # Tasks
    setup_vscode_tasks "$config_dir"

    # Extensions
    setup_vscode_extensions "$config_dir"

    # Snippets
    setup_vscode_snippets "$config_dir"

    # Keybindings info
    info "Keybindings recommandés (à ajouter manuellement):"
    echo "  Ctrl+Shift+E : Explorer"
    echo "  Ctrl+Shift+P : Plan"
    echo "  Ctrl+Shift+C : Commit"
    echo ""

    success "VSCode configuré dans $config_dir"
}

setup_vscode_settings() {
    local config_dir="$1"
    local settings_file="$config_dir/settings.json"

    if [[ -f "$settings_file" ]] && ! $FORCE; then
        warning "settings.json existe déjà (utilisez --force pour écraser)"
        return
    fi

    cat > "$settings_file" << 'EOF'
{
    // ==========================================================================
    // Claude-Socle VSCode Settings
    // ==========================================================================

    // Editor
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit",
        "source.organizeImports": "explicit"
    },

    // TypeScript
    "typescript.preferences.importModuleSpecifier": "relative",
    "typescript.suggest.autoImports": true,
    "typescript.updateImportsOnFileMove.enabled": "always",

    // Files
    "files.exclude": {
        "**/.git": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/.next": true,
        "**/coverage": true
    },

    // Terminal
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.defaultProfile.osx": "zsh",

    // Git
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,

    // Claude Code
    "claude-code.autoFormat": true,
    "claude-code.showAgentSuggestions": true,

    // Search
    "search.exclude": {
        "**/node_modules": true,
        "**/dist": true,
        "**/.git": true,
        "**/coverage": true
    },

    // Workbench
    "workbench.editor.labelFormat": "short",
    "workbench.tree.indent": 16
}
EOF

    success "settings.json créé"
}

setup_vscode_tasks() {
    local config_dir="$1"
    local tasks_file="$config_dir/tasks.json"

    if [[ -f "$tasks_file" ]] && ! $FORCE; then
        warning "tasks.json existe déjà (utilisez --force pour écraser)"
        return
    fi

    cat > "$tasks_file" << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        // ==========================================================================
        // Claude-Socle Tasks
        // ==========================================================================
        {
            "label": "Claude: Validate Project",
            "type": "shell",
            "command": "./scripts/validate.sh",
            "args": ["."],
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Claude: Doctor",
            "type": "shell",
            "command": "./scripts/doctor.sh",
            "args": ["."],
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Claude: Update from Socle",
            "type": "shell",
            "command": "./scripts/update.sh",
            "args": ["."],
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Claude: Run Tests (Bats)",
            "type": "shell",
            "command": "./scripts/test.sh",
            "group": {
                "kind": "test",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Claude: Lint Scripts",
            "type": "shell",
            "command": "./scripts/lint.sh",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        // ==========================================================================
        // Standard Tasks
        // ==========================================================================
        {
            "label": "npm: install",
            "type": "shell",
            "command": "npm install",
            "group": "build",
            "problemMatcher": []
        },
        {
            "label": "npm: test",
            "type": "shell",
            "command": "npm test",
            "group": {
                "kind": "test",
                "isDefault": false
            },
            "problemMatcher": []
        },
        {
            "label": "npm: lint",
            "type": "shell",
            "command": "npm run lint",
            "group": "build",
            "problemMatcher": ["$eslint-stylish"]
        },
        {
            "label": "npm: build",
            "type": "shell",
            "command": "npm run build",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        }
    ]
}
EOF

    success "tasks.json créé"
}

setup_vscode_extensions() {
    local config_dir="$1"
    local extensions_file="$config_dir/extensions.json"

    if [[ -f "$extensions_file" ]] && ! $FORCE; then
        warning "extensions.json existe déjà (utilisez --force pour écraser)"
        return
    fi

    cat > "$extensions_file" << 'EOF'
{
    // ==========================================================================
    // Claude-Socle Recommended Extensions
    // ==========================================================================
    "recommendations": [
        // Essential
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "editorconfig.editorconfig",

        // Git
        "eamodio.gitlens",
        "mhutchie.git-graph",

        // Testing
        "orta.vscode-jest",
        "hbenl.vscode-test-explorer",

        // TypeScript
        "ms-vscode.vscode-typescript-next",
        "pmneo.tsimporter",

        // Productivity
        "christian-kohler.path-intellisense",
        "streetsidesoftware.code-spell-checker",
        "wayou.vscode-todo-highlight",
        "gruntfuggly.todo-tree",

        // Shell/Bash
        "timonwong.shellcheck",
        "foxundermoon.shell-format",
        "mads-hartmann.bash-ide-vscode",

        // Markdown
        "yzhang.markdown-all-in-one",
        "davidanson.vscode-markdownlint",

        // Docker
        "ms-azuretools.vscode-docker",

        // YAML/JSON
        "redhat.vscode-yaml",
        "zainchen.json"
    ],
    "unwantedRecommendations": []
}
EOF

    success "extensions.json créé"
}

setup_vscode_snippets() {
    local config_dir="$1"
    local snippets_file="$config_dir/claude-socle.code-snippets"

    if [[ -f "$snippets_file" ]] && ! $FORCE; then
        warning "claude-socle.code-snippets existe déjà (utilisez --force pour écraser)"
        return
    fi

    cat > "$snippets_file" << 'EOF'
{
    // ==========================================================================
    // Claude-Socle Snippets
    // ==========================================================================

    // Workflow Commands
    "Claude Explore": {
        "prefix": ["claude-explore", "/explore"],
        "body": [
            "/project:work-explore ${1:cible}"
        ],
        "description": "Explorer et comprendre le code"
    },
    "Claude Plan": {
        "prefix": ["claude-plan", "/plan"],
        "body": [
            "/project:work-plan ${1:feature}"
        ],
        "description": "Planifier une implémentation"
    },
    "Claude Commit": {
        "prefix": ["claude-commit", "/commit"],
        "body": [
            "/project:work-commit"
        ],
        "description": "Créer un commit propre"
    },
    "Claude PR": {
        "prefix": ["claude-pr", "/pr"],
        "body": [
            "/project:work-pr ${1:description}"
        ],
        "description": "Créer une Pull Request"
    },

    // Development
    "Claude TDD": {
        "prefix": ["claude-tdd", "/tdd"],
        "body": [
            "/project:dev-tdd ${1:feature}"
        ],
        "description": "Développement TDD"
    },
    "Claude Test": {
        "prefix": ["claude-test", "/test"],
        "body": [
            "/project:dev-test ${1:cible}"
        ],
        "description": "Générer des tests"
    },
    "Claude Debug": {
        "prefix": ["claude-debug", "/debug"],
        "body": [
            "/project:dev-debug ${1:problème}"
        ],
        "description": "Déboguer un problème"
    },
    "Claude Refactor": {
        "prefix": ["claude-refactor", "/refactor"],
        "body": [
            "/project:dev-refactor ${1:cible}"
        ],
        "description": "Refactoring guidé"
    },

    // Quality
    "Claude Review": {
        "prefix": ["claude-review", "/review"],
        "body": [
            "/project:qa-review ${1:cible}"
        ],
        "description": "Code review détaillée"
    },
    "Claude Security": {
        "prefix": ["claude-security", "/security"],
        "body": [
            "/project:qa-security ${1:cible}"
        ],
        "description": "Audit de sécurité OWASP"
    },

    // Workflows complets
    "Claude Flow Feature": {
        "prefix": ["claude-flow-feature", "/flow-feature"],
        "body": [
            "/project:work-flow-feature \"${1:description}\""
        ],
        "description": "Workflow complet pour nouvelle feature"
    },
    "Claude Flow Bugfix": {
        "prefix": ["claude-flow-bugfix", "/flow-bugfix"],
        "body": [
            "/project:work-flow-bugfix \"${1:description}\""
        ],
        "description": "Workflow complet pour bugfix"
    },

    // Conventional Commits
    "Commit feat": {
        "prefix": "commit-feat",
        "body": [
            "feat(${1:scope}): ${2:description}"
        ],
        "description": "Commit: nouvelle fonctionnalité"
    },
    "Commit fix": {
        "prefix": "commit-fix",
        "body": [
            "fix(${1:scope}): ${2:description}"
        ],
        "description": "Commit: correction de bug"
    },
    "Commit refactor": {
        "prefix": "commit-refactor",
        "body": [
            "refactor(${1:scope}): ${2:description}"
        ],
        "description": "Commit: refactoring"
    },
    "Commit test": {
        "prefix": "commit-test",
        "body": [
            "test(${1:scope}): ${2:description}"
        ],
        "description": "Commit: tests"
    },
    "Commit docs": {
        "prefix": "commit-docs",
        "body": [
            "docs(${1:scope}): ${2:description}"
        ],
        "description": "Commit: documentation"
    }
}
EOF

    success "claude-socle.code-snippets créé"
}

check_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    info "Vérification de la configuration VSCode..."

    local issues=0

    if [[ ! -d "$config_dir" ]]; then
        echo -e "  ${RED}✗${NC} Répertoire .vscode manquant"
        ((issues++))
    else
        for file in settings.json tasks.json extensions.json; do
            if [[ -f "$config_dir/$file" ]]; then
                echo -e "  ${GREEN}✓${NC} $file"
            else
                echo -e "  ${YELLOW}⚠${NC} $file manquant"
                ((issues++))
            fi
        done

        if [[ -f "$config_dir/claude-socle.code-snippets" ]]; then
            echo -e "  ${GREEN}✓${NC} claude-socle.code-snippets"
        else
            echo -e "  ${YELLOW}⚠${NC} snippets manquants"
            ((issues++))
        fi
    fi

    echo ""
    if [[ $issues -eq 0 ]]; then
        success "Configuration VSCode complète"
    else
        warning "$issues fichier(s) manquant(s). Lancez: ./scripts/ide.sh setup vscode"
    fi

    return $issues
}

remove_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    if [[ ! -d "$config_dir" ]]; then
        warning "Aucune configuration VSCode trouvée"
        return
    fi

    info "Suppression de la configuration VSCode..."

    for file in settings.json tasks.json extensions.json claude-socle.code-snippets; do
        if [[ -f "$config_dir/$file" ]]; then
            rm "$config_dir/$file"
            success "Supprimé: $file"
        fi
    done

    # Supprimer le répertoire s'il est vide
    if [[ -z "$(ls -A "$config_dir" 2>/dev/null)" ]]; then
        rmdir "$config_dir"
        success "Répertoire .vscode supprimé"
    fi
}

# =============================================================================
# Configuration IntelliJ IDEA
# =============================================================================

setup_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    info "Configuration IntelliJ IDEA..."

    make_dir "$config_dir"

    # File templates
    setup_idea_templates "$config_dir"

    # Run configurations
    setup_idea_run_configs "$config_dir"

    # Code style
    setup_idea_codestyle "$config_dir"

    success "IntelliJ IDEA configuré dans $config_dir"
}

setup_idea_templates() {
    local config_dir="$1"
    local templates_dir="$config_dir/fileTemplates"

    make_dir "$templates_dir"

    # Claude Agent template
    cat > "$templates_dir/Claude Agent Command.md" << 'EOF'
# ${NAME}

${DESCRIPTION}

## Contexte
$ARGUMENTS

## Instructions

1. Analyser le contexte
2. Exécuter les actions
3. Valider les résultats

## Checklist

- [ ] Étape 1
- [ ] Étape 2
- [ ] Étape 3
EOF

    success "Templates IntelliJ créés"
}

setup_idea_run_configs() {
    local config_dir="$1"
    local run_dir="$config_dir/runConfigurations"

    make_dir "$run_dir"

    # Validate configuration
    cat > "$run_dir/Claude_Validate.xml" << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Claude: Validate" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="$PROJECT_DIR$/scripts/validate.sh" />
    <option name="SCRIPT_OPTIONS" value="." />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <option name="EXECUTE_SCRIPT_FILE" value="true" />
    <method v="2" />
  </configuration>
</component>
EOF

    # Doctor configuration
    cat > "$run_dir/Claude_Doctor.xml" << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Claude: Doctor" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="$PROJECT_DIR$/scripts/doctor.sh" />
    <option name="SCRIPT_OPTIONS" value="." />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <option name="EXECUTE_SCRIPT_FILE" value="true" />
    <method v="2" />
  </configuration>
</component>
EOF

    # Test configuration
    cat > "$run_dir/Claude_Test.xml" << 'EOF'
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Claude: Run Tests" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="$PROJECT_DIR$/scripts/test.sh" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="true" />
    <option name="EXECUTE_SCRIPT_FILE" value="true" />
    <method v="2" />
  </configuration>
</component>
EOF

    success "Run configurations IntelliJ créées"
}

setup_idea_codestyle() {
    local config_dir="$1"
    local codestyle_dir="$config_dir/codeStyles"

    make_dir "$codestyle_dir"

    cat > "$codestyle_dir/Project.xml" << 'EOF'
<component name="ProjectCodeStyleConfiguration">
  <code_scheme name="Project" version="173">
    <option name="RIGHT_MARGIN" value="100" />
    <ShellScriptCodeStyleSettings>
      <option name="INDENT" value="4" />
      <option name="USE_TABS" value="false" />
    </ShellScriptCodeStyleSettings>
    <TypeScriptCodeStyleSettings version="0">
      <option name="FORCE_SEMICOLON_STYLE" value="true" />
      <option name="SPACE_BEFORE_FUNCTION_LEFT_PARENTH" value="false" />
      <option name="USE_DOUBLE_QUOTES" value="false" />
    </TypeScriptCodeStyleSettings>
    <codeStyleSettings language="TypeScript">
      <option name="INDENT_SIZE" value="2" />
      <option name="CONTINUATION_INDENT_SIZE" value="2" />
      <option name="TAB_SIZE" value="2" />
    </codeStyleSettings>
    <codeStyleSettings language="JavaScript">
      <option name="INDENT_SIZE" value="2" />
      <option name="CONTINUATION_INDENT_SIZE" value="2" />
      <option name="TAB_SIZE" value="2" />
    </codeStyleSettings>
  </code_scheme>
</component>
EOF

    success "Code style IntelliJ configuré"
}

check_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    info "Vérification de la configuration IntelliJ..."

    local issues=0

    if [[ ! -d "$config_dir" ]]; then
        echo -e "  ${RED}✗${NC} Répertoire .idea manquant"
        ((issues++))
    else
        if [[ -d "$config_dir/runConfigurations" ]]; then
            echo -e "  ${GREEN}✓${NC} Run configurations"
        else
            echo -e "  ${YELLOW}⚠${NC} Run configurations manquantes"
            ((issues++))
        fi

        if [[ -d "$config_dir/codeStyles" ]]; then
            echo -e "  ${GREEN}✓${NC} Code style"
        else
            echo -e "  ${YELLOW}⚠${NC} Code style manquant"
            ((issues++))
        fi
    fi

    echo ""
    if [[ $issues -eq 0 ]]; then
        success "Configuration IntelliJ complète"
    else
        warning "$issues élément(s) manquant(s). Lancez: ./scripts/ide.sh setup idea"
    fi

    return $issues
}

remove_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    if [[ ! -d "$config_dir" ]]; then
        warning "Aucune configuration IntelliJ trouvée"
        return
    fi

    info "Suppression de la configuration claude-socle IntelliJ..."

    # Supprimer les run configurations claude-socle
    if [[ -d "$config_dir/runConfigurations" ]]; then
        rm -f "$config_dir/runConfigurations/Claude_"*.xml
        success "Run configurations supprimées"
    fi

    # Supprimer les templates
    if [[ -d "$config_dir/fileTemplates" ]]; then
        rm -f "$config_dir/fileTemplates/Claude"*.md
        success "Templates supprimés"
    fi
}

# =============================================================================
# Configuration Vim/Neovim
# =============================================================================

setup_vim() {
    local dir="$1"

    info "Configuration Vim/Neovim..."

    local vimrc="$dir/.vimrc.claude"
    # shellcheck disable=SC2034  # Reserved for future Neovim support
    local nvim_dir="$dir/.config/nvim"

    # Créer un fichier de configuration Vim
    cat > "$vimrc" << 'EOF'
" =============================================================================
" Claude-Socle Vim Configuration
" Sourcez ce fichier dans votre .vimrc: source .vimrc.claude
" =============================================================================

" Abréviations pour les commandes Claude
iabbrev cexplore /project:work-explore
iabbrev cplan /project:work-plan
iabbrev ccommit /project:work-commit
iabbrev ctdd /project:dev-tdd
iabbrev creview /project:qa-review

" Mappings pour les scripts
nnoremap <leader>cv :!./scripts/validate.sh .<CR>
nnoremap <leader>cd :!./scripts/doctor.sh .<CR>
nnoremap <leader>ct :!./scripts/test.sh<CR>
nnoremap <leader>cl :!./scripts/lint.sh<CR>

" Configuration pour les fichiers du socle
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=fr,en
autocmd BufRead,BufNewFile .claude/commands/*.md setlocal filetype=markdown

" Snippets Conventional Commits (avec vim-snippets)
" feat:
" fix:
" refactor:
" test:
" docs:
EOF

    success "Configuration Vim créée: $vimrc"
    echo ""
    echo -e "${DIM}Ajoutez cette ligne à votre .vimrc:${NC}"
    echo "  source $vimrc"
}

check_vim() {
    local dir="$1"

    info "Vérification de la configuration Vim..."

    if [[ -f "$dir/.vimrc.claude" ]]; then
        echo -e "  ${GREEN}✓${NC} .vimrc.claude"
        success "Configuration Vim présente"
    else
        echo -e "  ${YELLOW}⚠${NC} .vimrc.claude manquant"
        warning "Lancez: ./scripts/ide.sh setup vim"
    fi
}

remove_vim() {
    local dir="$1"

    if [[ -f "$dir/.vimrc.claude" ]]; then
        rm "$dir/.vimrc.claude"
        success "Configuration Vim supprimée"
    else
        warning "Aucune configuration Vim trouvée"
    fi
}

# =============================================================================
# Fonctions principales
# =============================================================================

setup_all() {
    local dir="$1"

    info "Configuration de tous les IDE..."
    echo ""

    setup_vscode "$dir"
    echo ""

    setup_idea "$dir"
    echo ""

    setup_vim "$dir"
    echo ""

    success "Tous les IDE ont été configurés"
}

check_all() {
    local dir="$1"
    local total_issues=0

    check_vscode "$dir" || ((total_issues+=$?))
    echo ""

    check_idea "$dir" || ((total_issues+=$?))
    echo ""

    check_vim "$dir" || ((total_issues+=$?))
    echo ""

    if [[ $total_issues -eq 0 ]]; then
        success "Toutes les configurations IDE sont complètes"
    else
        warning "$total_issues problème(s) détecté(s)"
    fi
}

remove_all() {
    local dir="$1"

    remove_vscode "$dir"
    remove_idea "$dir"
    remove_vim "$dir"

    success "Configurations IDE supprimées"
}

# =============================================================================
# Parse arguments
# =============================================================================

parse_args() {
    if [[ $# -lt 1 ]]; then
        show_help
        exit 1
    fi

    local command=""
    local ide=""

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
            -n|--dry-run)
                export DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            setup|check|remove)
                command="$1"
                shift
                ;;
            vscode|cursor|idea|vim|all)
                ide="$1"
                shift
                ;;
            *)
                if [[ -d "$1" ]]; then
                    TARGET_DIR="$1"
                else
                    error "Argument inconnu: $1"
                fi
                shift
                ;;
        esac
    done

    # Valeurs par défaut
    [[ -z "$TARGET_DIR" ]] && TARGET_DIR="."
    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    if [[ -z "$command" ]]; then
        error "Commande requise: setup, check, ou remove"
    fi

    if [[ -z "$ide" ]]; then
        error "IDE requis: vscode, cursor, idea, vim, ou all"
    fi

    # Cursor utilise la même config que VSCode
    [[ "$ide" == "cursor" ]] && ide="vscode"

    # Exécuter la commande
    case "$command" in
        setup)
            case "$ide" in
                vscode) setup_vscode "$TARGET_DIR" ;;
                idea) setup_idea "$TARGET_DIR" ;;
                vim) setup_vim "$TARGET_DIR" ;;
                all) setup_all "$TARGET_DIR" ;;
            esac
            ;;
        check)
            case "$ide" in
                vscode) check_vscode "$TARGET_DIR" ;;
                idea) check_idea "$TARGET_DIR" ;;
                vim) check_vim "$TARGET_DIR" ;;
                all) check_all "$TARGET_DIR" ;;
            esac
            ;;
        remove)
            case "$ide" in
                vscode) remove_vscode "$TARGET_DIR" ;;
                idea) remove_idea "$TARGET_DIR" ;;
                vim) remove_vim "$TARGET_DIR" ;;
                all) remove_all "$TARGET_DIR" ;;
            esac
            ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

main() {
    parse_args "$@"
}

main "$@"
