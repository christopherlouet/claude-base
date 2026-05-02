#!/bin/bash

# =============================================================================
# Claude-Socle IDE Integration Script
# Configures IDEs for optimal integration with claude-socle
# =============================================================================

set -euo pipefail

VERSION="1.0.0"

# Load the common library
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
# Help and version
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle IDE Integration${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") <setup|check|remove> <ide> [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Configures IDEs for optimal integration with claude-socle.
    Generates snippets, tasks, keybindings and extension recommendations.

${BOLD}COMMANDS${NC}
    setup <ide>     Configure the specified IDE
    check <ide>     Check the existing configuration
    remove <ide>    Remove the claude-socle configuration

${BOLD}SUPPORTED IDES${NC}
    vscode          Visual Studio Code
    cursor          Cursor (VSCode fork)
    idea            IntelliJ IDEA / WebStorm / PyCharm
    vim             Vim / Neovim
    all             All detected IDEs

${BOLD}OPTIONS${NC}
    -h, --help      Show this help
    -v, --version   Show the version
    -n, --dry-run   Simulate without modifying
    -f, --force     Overwrite existing files

${BOLD}EXAMPLES${NC}
    # Configure VSCode in the current project
    $(basename "$0") setup vscode

    # Configure VSCode in a specific project
    $(basename "$0") setup vscode /path/to/project

    # Check the IntelliJ configuration
    $(basename "$0") check idea

    # Configure all IDEs (dry-run mode)
    $(basename "$0") setup all --dry-run

    # Remove the configuration
    $(basename "$0") remove vscode

EOF
}

show_version() {
    echo "Claude-Socle IDE Integration v${VERSION}"
}

# =============================================================================
# VSCode / Cursor configuration
# =============================================================================

setup_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    info "Configuring VSCode/Cursor..."

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
    info "Recommended keybindings (to add manually):"
    echo "  Ctrl+Shift+E : Explore"
    echo "  Ctrl+Shift+P : Plan"
    echo "  Ctrl+Shift+C : Commit"
    echo ""

    success "VSCode configured in $config_dir"
}

setup_vscode_settings() {
    local config_dir="$1"
    local settings_file="$config_dir/settings.json"

    if [[ -f "$settings_file" ]] && ! $FORCE; then
        warning "settings.json already exists (use --force to overwrite)"
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

    success "settings.json created"
}

setup_vscode_tasks() {
    local config_dir="$1"
    local tasks_file="$config_dir/tasks.json"

    if [[ -f "$tasks_file" ]] && ! $FORCE; then
        warning "tasks.json already exists (use --force to overwrite)"
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

    success "tasks.json created"
}

setup_vscode_extensions() {
    local config_dir="$1"
    local extensions_file="$config_dir/extensions.json"

    if [[ -f "$extensions_file" ]] && ! $FORCE; then
        warning "extensions.json already exists (use --force to overwrite)"
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

    success "extensions.json created"
}

setup_vscode_snippets() {
    local config_dir="$1"
    local snippets_file="$config_dir/claude-socle.code-snippets"

    if [[ -f "$snippets_file" ]] && ! $FORCE; then
        warning "claude-socle.code-snippets already exists (use --force to overwrite)"
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
            "/work-explore ${1:target}"
        ],
        "description": "Explore and understand the code"
    },
    "Claude Plan": {
        "prefix": ["claude-plan", "/plan"],
        "body": [
            "/work-plan ${1:feature}"
        ],
        "description": "Plan an implementation"
    },
    "Claude Commit": {
        "prefix": ["claude-commit", "/commit"],
        "body": [
            "/work-commit"
        ],
        "description": "Create a clean commit"
    },
    "Claude PR": {
        "prefix": ["claude-pr", "/pr"],
        "body": [
            "/work-pr ${1:description}"
        ],
        "description": "Create a Pull Request"
    },

    // Development
    "Claude TDD": {
        "prefix": ["claude-tdd", "/tdd"],
        "body": [
            "/dev-tdd ${1:feature}"
        ],
        "description": "TDD development"
    },
    "Claude Test": {
        "prefix": ["claude-test", "/test"],
        "body": [
            "/dev-test ${1:target}"
        ],
        "description": "Generate tests"
    },
    "Claude Debug": {
        "prefix": ["claude-debug", "/debug"],
        "body": [
            "/dev-debug ${1:problem}"
        ],
        "description": "Debug a problem"
    },
    "Claude Refactor": {
        "prefix": ["claude-refactor", "/refactor"],
        "body": [
            "/dev-refactor ${1:target}"
        ],
        "description": "Guided refactoring"
    },

    // Quality
    "Claude Review": {
        "prefix": ["claude-review", "/review"],
        "body": [
            "/qa-review ${1:target}"
        ],
        "description": "Detailed code review"
    },
    "Claude Security": {
        "prefix": ["claude-security", "/security"],
        "body": [
            "/qa-security ${1:target}"
        ],
        "description": "OWASP security audit"
    },

    // Full workflows
    "Claude Flow Feature": {
        "prefix": ["claude-flow-feature", "/flow-feature"],
        "body": [
            "/work-flow-feature \"${1:description}\""
        ],
        "description": "Full workflow for new feature"
    },
    "Claude Flow Bugfix": {
        "prefix": ["claude-flow-bugfix", "/flow-bugfix"],
        "body": [
            "/work-flow-bugfix \"${1:description}\""
        ],
        "description": "Full workflow for bugfix"
    },

    // Conventional Commits
    "Commit feat": {
        "prefix": "commit-feat",
        "body": [
            "feat(${1:scope}): ${2:description}"
        ],
        "description": "Commit: new feature"
    },
    "Commit fix": {
        "prefix": "commit-fix",
        "body": [
            "fix(${1:scope}): ${2:description}"
        ],
        "description": "Commit: bug fix"
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

    success "claude-socle.code-snippets created"
}

check_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    info "Checking the VSCode configuration..."

    local issues=0

    if [[ ! -d "$config_dir" ]]; then
        echo -e "  ${RED}✗${NC} .vscode directory missing"
        ((issues++))
    else
        for file in settings.json tasks.json extensions.json; do
            if [[ -f "$config_dir/$file" ]]; then
                echo -e "  ${GREEN}✓${NC} $file"
            else
                echo -e "  ${YELLOW}⚠${NC} $file missing"
                ((issues++))
            fi
        done

        if [[ -f "$config_dir/claude-socle.code-snippets" ]]; then
            echo -e "  ${GREEN}✓${NC} claude-socle.code-snippets"
        else
            echo -e "  ${YELLOW}⚠${NC} snippets missing"
            ((issues++))
        fi
    fi

    echo ""
    if [[ $issues -eq 0 ]]; then
        success "VSCode configuration complete"
    else
        warning "$issues file(s) missing. Run: ./scripts/ide.sh setup vscode"
    fi

    return $issues
}

remove_vscode() {
    local dir="$1"
    local config_dir="$dir/.vscode"

    if [[ ! -d "$config_dir" ]]; then
        warning "No VSCode configuration found"
        return
    fi

    info "Removing the VSCode configuration..."

    for file in settings.json tasks.json extensions.json claude-socle.code-snippets; do
        if [[ -f "$config_dir/$file" ]]; then
            rm "$config_dir/$file"
            success "Removed: $file"
        fi
    done

    # Remove the directory if it is empty
    if [[ -z "$(ls -A "$config_dir" 2>/dev/null)" ]]; then
        rmdir "$config_dir"
        success ".vscode directory removed"
    fi
}

# =============================================================================
# IntelliJ IDEA configuration
# =============================================================================

setup_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    info "Configuring IntelliJ IDEA..."

    make_dir "$config_dir"

    # File templates
    setup_idea_templates "$config_dir"

    # Run configurations
    setup_idea_run_configs "$config_dir"

    # Code style
    setup_idea_codestyle "$config_dir"

    success "IntelliJ IDEA configured in $config_dir"
}

setup_idea_templates() {
    local config_dir="$1"
    local templates_dir="$config_dir/fileTemplates"

    make_dir "$templates_dir"

    # Claude Agent template
    cat > "$templates_dir/Claude Agent Command.md" << 'EOF'
# ${NAME}

${DESCRIPTION}

## Context
$ARGUMENTS

## Instructions

1. Analyze the context
2. Execute the actions
3. Validate the results

## Checklist

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
EOF

    success "IntelliJ templates created"
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

    success "IntelliJ run configurations created"
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

    success "IntelliJ code style configured"
}

check_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    info "Checking the IntelliJ configuration..."

    local issues=0

    if [[ ! -d "$config_dir" ]]; then
        echo -e "  ${RED}✗${NC} .idea directory missing"
        ((issues++))
    else
        if [[ -d "$config_dir/runConfigurations" ]]; then
            echo -e "  ${GREEN}✓${NC} Run configurations"
        else
            echo -e "  ${YELLOW}⚠${NC} Run configurations missing"
            ((issues++))
        fi

        if [[ -d "$config_dir/codeStyles" ]]; then
            echo -e "  ${GREEN}✓${NC} Code style"
        else
            echo -e "  ${YELLOW}⚠${NC} Code style missing"
            ((issues++))
        fi
    fi

    echo ""
    if [[ $issues -eq 0 ]]; then
        success "IntelliJ configuration complete"
    else
        warning "$issues item(s) missing. Run: ./scripts/ide.sh setup idea"
    fi

    return $issues
}

remove_idea() {
    local dir="$1"
    local config_dir="$dir/.idea"

    if [[ ! -d "$config_dir" ]]; then
        warning "No IntelliJ configuration found"
        return
    fi

    info "Removing the claude-socle IntelliJ configuration..."

    # Remove the claude-socle run configurations
    if [[ -d "$config_dir/runConfigurations" ]]; then
        rm -f "$config_dir/runConfigurations/Claude_"*.xml
        success "Run configurations removed"
    fi

    # Remove the templates
    if [[ -d "$config_dir/fileTemplates" ]]; then
        rm -f "$config_dir/fileTemplates/Claude"*.md
        success "Templates removed"
    fi
}

# =============================================================================
# Vim/Neovim configuration
# =============================================================================

setup_vim() {
    local dir="$1"

    info "Configuring Vim/Neovim..."

    local vimrc="$dir/.vimrc.claude"
    # shellcheck disable=SC2034  # Reserved for future Neovim support
    local nvim_dir="$dir/.config/nvim"

    # Create a Vim configuration file
    cat > "$vimrc" << 'EOF'
" =============================================================================
" Claude-Socle Vim Configuration
" Source this file in your .vimrc: source .vimrc.claude
" =============================================================================

" Abbreviations for Claude commands
iabbrev cexplore /work-explore
iabbrev cplan /work-plan
iabbrev ccommit /work-commit
iabbrev ctdd /dev-tdd
iabbrev creview /qa-review

" Mappings for the scripts
nnoremap <leader>cv :!./scripts/validate.sh .<CR>
nnoremap <leader>cd :!./scripts/doctor.sh .<CR>
nnoremap <leader>ct :!./scripts/test.sh<CR>
nnoremap <leader>cl :!./scripts/lint.sh<CR>

" Configuration for foundation files
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=fr,en
autocmd BufRead,BufNewFile .claude/commands/**/*.md setlocal filetype=markdown
autocmd BufRead,BufNewFile .claude/commands/*.md setlocal filetype=markdown

" Conventional Commits snippets (with vim-snippets)
" feat:
" fix:
" refactor:
" test:
" docs:
EOF

    success "Vim configuration created: $vimrc"
    echo ""
    echo -e "${DIM}Add this line to your .vimrc:${NC}"
    echo "  source $vimrc"
}

check_vim() {
    local dir="$1"

    info "Checking the Vim configuration..."

    if [[ -f "$dir/.vimrc.claude" ]]; then
        echo -e "  ${GREEN}✓${NC} .vimrc.claude"
        success "Vim configuration present"
    else
        echo -e "  ${YELLOW}⚠${NC} .vimrc.claude missing"
        warning "Run: ./scripts/ide.sh setup vim"
    fi
}

remove_vim() {
    local dir="$1"

    if [[ -f "$dir/.vimrc.claude" ]]; then
        rm "$dir/.vimrc.claude"
        success "Vim configuration removed"
    else
        warning "No Vim configuration found"
    fi
}

# =============================================================================
# Main functions
# =============================================================================

setup_all() {
    local dir="$1"

    info "Configuring all IDEs..."
    echo ""

    setup_vscode "$dir"
    echo ""

    setup_idea "$dir"
    echo ""

    setup_vim "$dir"
    echo ""

    success "All IDEs have been configured"
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
        success "All IDE configurations are complete"
    else
        warning "$total_issues issue(s) detected"
    fi
}

remove_all() {
    local dir="$1"

    remove_vscode "$dir"
    remove_idea "$dir"
    remove_vim "$dir"

    success "IDE configurations removed"
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
                    error "Unknown argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Default values
    [[ -z "$TARGET_DIR" ]] && TARGET_DIR="."
    TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

    if [[ -z "$command" ]]; then
        error "Command required: setup, check, or remove"
    fi

    if [[ -z "$ide" ]]; then
        error "IDE required: vscode, cursor, idea, vim, or all"
    fi

    # Cursor uses the same config as VSCode
    [[ "$ide" == "cursor" ]] && ide="vscode"

    # Execute the command
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
