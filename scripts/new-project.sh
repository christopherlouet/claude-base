#!/usr/bin/env bash

# =============================================================================
# Claude-Base New Project Script
# Creates a new project or configures an existing project with Claude Code
# =============================================================================

set -euo pipefail

VERSION=$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/VERSION" 2>/dev/null || echo "1.1.0")

# Load the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/detection.sh
source "$SCRIPT_DIR/lib/detection.sh"
# shellcheck source=lib/preset-detect.sh
source "$SCRIPT_DIR/lib/preset-detect.sh"
# shellcheck source=lib/menu.sh
source "$SCRIPT_DIR/lib/menu.sh"
# shellcheck source=lib/category-map.sh
source "$SCRIPT_DIR/lib/category-map.sh"
# shellcheck source=lib/generators.sh
source "$SCRIPT_DIR/lib/generators.sh"
# shellcheck source=lib/preset-recommendations.sh
source "$SCRIPT_DIR/lib/preset-recommendations.sh"
# shellcheck source=lib/docker.sh
source "$SCRIPT_DIR/lib/docker.sh"

# Enable the error handler and check prerequisites
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
        _CACHED_CMD_COUNT=$(find "$BASE_DIR/$COMMANDS_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "$_CACHED_CMD_COUNT"
}

count_agents_cached() {
    if [[ -z "$_CACHED_AGENT_COUNT" ]]; then
        _CACHED_AGENT_COUNT=$(find "$BASE_DIR/$AGENTS_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "$_CACHED_AGENT_COUNT"
}

count_skills_cached() {
    if [[ -z "$_CACHED_SKILL_COUNT" ]]; then
        _CACHED_SKILL_COUNT=$(count_skills "$BASE_DIR")
    fi
    echo "$_CACHED_SKILL_COUNT"
}

# Project variables
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

# New options (simple mode / direct install)
SIMPLE_MODE=false
MINIMAL_MODE=false
SKIP_PROMPTS=false
DESIGN_STYLE=""

# Preset mode (curated bundle per stack — see specs/presets/spec.md)
PRESET_NAME=""
PRESET_FILE=""
PRESET_LIST_AND_EXIT=false
DETECT_ONLY=false
# Optional override: path to a directory containing preset JSON files.
# When set, resolve_preset_file() looks there BEFORE the official presets dir.
# Intended for testing only (synthetic presets); not documented in --help.
PRESETS_DIR_OVERRIDE=""
# Set by load_preset() — used by install_claude_files / apply_preset_filter
PRESET_SKILLS_DROP=()
# Set by load_preset() — mutually exclusive with PRESET_SKILLS_DROP (XOR).
# When non-empty, apply_preset_filter() removes every installed skill whose
# top-level directory name is NOT in this list.
PRESET_SKILLS_KEEP=()
# Populated by populate_matched_presets() — list of preset names whose
# detect rule matches PROJECT_PATH. Empty when --preset was passed
# explicitly (EF-016) or when no preset matches.
MATCHED_PRESETS=()

# Detection variables (used by lib/detection.sh functions)
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

# CI/CD analysis variables
CICD_MISSING=()
CICD_PRESENT=()
CICD_ACTION="skip"

# =============================================================================
# Help and version
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Base New Project${NC} v${VERSION}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS] [PATH]

${BOLD}DESCRIPTION${NC}
    Creates a new project or configures an existing project with Claude Code.
    Installs commands, agents and skills for the Explore → Plan → Code → Commit workflow.

${BOLD}ARGUMENTS${NC}
    PATH                Path to an existing project to configure (optional)
                        If omitted, creates a new project interactively

${BOLD}OPTIONS${NC}
    -h, --help          Show this help
    -v, --version       Show the version
    -y, --yes           Non-interactive mode (accepts default values)
    -n, --dry-run       Simulate the install without copying anything
    -q, --quiet         Quiet mode (errors only)
    --verbose           Verbose mode (debug)
    -t, --type TYPE     Force the project type (react, vue, node-api, python, go, rust, java, fullstack, generic)
    -p, --path PATH     Parent folder where the project will be created (default: current directory)
    --ci                Include GitHub Actions (CI/CD)
    --hooks             Include pre-commit hooks (husky)
    --mcp               Include MCP configuration
    --docker            Include Dockerfile
    --all               Include all options (ci, hooks, mcp, docker)
    --style STYLE       Design direction (terminal, cockpit, vitality, editorial, glass, signal)
    --skip-prompts      Skip optional questions (use the provided flags)
    --simple            Simple install mode (equivalent to the old install.sh)
    --install-only      Alias for --simple
    --minimal           Minimal install (Level 1+2 learning-path) via manifest
    --preset NAME       Curated bundle per stack — applies foundation filters,
                        installs marketplace plugins, and sets defaults.
                        Run --list-presets to see what's available.
    --list-presets      List available presets and exit
    --detect-only PATH  Scan PATH against preset detect rules, print matching
                        preset names, then exit 0 (no file writes).

${BOLD}EXAMPLES${NC}
    # Interactive new project
    $(basename "$0")

    # New project in a specific folder
    $(basename "$0") --path ~/projects

    # Configure an existing project
    $(basename "$0") ./my-project

    # Non-interactive mode with auto detection
    $(basename "$0") -y ./my-project

    # New React project with CI/CD in a specific folder
    $(basename "$0") -y -t react --ci --path /var/www my-app

    # React project with design direction
    $(basename "$0") -y -t react --style vitality ./my-app

    # Include everything
    $(basename "$0") -y --all ./my-project

    # Simple mode (quick install without detection)
    $(basename "$0") --simple .
    $(basename "$0") --simple --all ./my-project

    # Preset (Next.js stack — see specs/presets/spec.md)
    $(basename "$0") --preset nextjs ./my-app
    $(basename "$0") --list-presets

    # Dry-run mode (simulation)
    $(basename "$0") --dry-run --simple .
    $(basename "$0") -n -y ./my-project

    # Verbose mode for debug
    $(basename "$0") --verbose ./my-project

${BOLD}PROJECT TYPES${NC}
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
    generic     Other / Generic

${BOLD}INSTALLED FILES${NC}
    .claude/commands/       Claude Code commands
    .claude/skills/         Specialized skills
    .claude/agents/         Agents with isolated context
    .claude/rules/          Path-contextual rules
    .claude/output-styles/  Output styles
    .claude/templates/      Templates (spec, Proxmox, etc.)
    .claude/settings.json   Configured hooks
    CLAUDE.md               Project instructions (smartly generated)

${BOLD}MORE INFO${NC}
    https://github.com/anthropics/claude-code
EOF
}

show_version() {
    echo "claude-base new-project v${VERSION}"
}

# =============================================================================
# Argument parsing
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
            --minimal)
                MINIMAL_MODE=true
                NON_INTERACTIVE=true
                SKIP_PROMPTS=true
                shift
                ;;
            --preset)
                PRESET_NAME="$2"
                shift 2
                ;;
            --presets-dir)
                PRESETS_DIR_OVERRIDE="$2"
                shift 2
                ;;
            --list-presets)
                PRESET_LIST_AND_EXIT=true
                shift
                ;;
            --detect-only)
                DETECT_ONLY=true
                shift
                ;;
            -*)
                error "Unknown option: $1\nUse --help for help"
                ;;
            *)
                # This is a project path
                if [[ -z "$PROJECT_PATH" ]]; then
                    PROJECT_PATH="$1"
                else
                    error "Too many arguments: $1\nUse --help for help"
                fi
                shift
                ;;
        esac
    done
}

# =============================================================================
# CI/CD analysis and improvement
# =============================================================================

analyze_existing_cicd() {
    local dir="$1"
    local missing=()
    local present=()

    # Reset global arrays
    CICD_MISSING=()
    CICD_PRESENT=()

    # Analyze GitHub Actions
    if [[ -d "$dir/.github/workflows" ]]; then
        local workflow_files
        workflow_files=$(ls "$dir/.github/workflows"/*.yml "$dir/.github/workflows"/*.yaml 2>/dev/null || true)

        if [[ -n "$workflow_files" ]]; then
            # Check automated tests
            if echo "$workflow_files" | xargs grep -l "npm test\|yarn test\|pnpm test\|bun test\|pytest\|go test\|cargo test\|mvn test" &>/dev/null; then
                present+=("Automated tests")
            else
                missing+=("Automated tests")
            fi

            # Check lint
            if echo "$workflow_files" | xargs grep -l "eslint\|npm run lint\|yarn lint\|flake8\|pylint\|golint\|clippy" &>/dev/null; then
                present+=("Linting")
            else
                missing+=("Linting")
            fi

            # Check security audit
            if echo "$workflow_files" | xargs grep -l "npm audit\|snyk\|safety\|gosec\|cargo audit\|trivy" &>/dev/null; then
                present+=("Security audit")
            else
                missing+=("Security audit")
            fi

            # Check cache
            if echo "$workflow_files" | xargs grep -l "actions/cache" &>/dev/null; then
                present+=("Dependency cache")
            else
                missing+=("Dependency cache")
            fi

            # Check coverage
            if echo "$workflow_files" | xargs grep -l "codecov\|coveralls\|coverage" &>/dev/null; then
                present+=("Coverage upload")
            else
                missing+=("Coverage upload")
            fi

            # Check PR checks
            if [[ -f "$dir/.github/workflows/pr-check.yml" ]] || echo "$workflow_files" | xargs grep -l "pull_request.*opened\|commitlint\|semantic-pull-request" &>/dev/null; then
                present+=("PR validation")
            else
                missing+=("PR validation")
            fi

            # Check release automation
            if echo "$workflow_files" | xargs grep -l "release\|changelog\|gh-release\|action-gh-release" &>/dev/null; then
                present+=("Automated release")
            else
                missing+=("Automated release")
            fi
        fi
    fi

    # Store results
    CICD_MISSING=("${missing[@]}")
    CICD_PRESENT=("${present[@]}")
}

suggest_cicd_improvements() {
    echo ""
    info "Analysis of existing CI/CD:"
    echo ""

    # Show present items
    for item in "${CICD_PRESENT[@]}"; do
        echo -e "  ${GREEN}✓${NC} $item"
    done

    # Show missing items
    for item in "${CICD_MISSING[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} Missing: $item"
    done

    echo ""

    # Compute and show the score
    local total=$((${#CICD_PRESENT[@]} + ${#CICD_MISSING[@]}))
    if [[ $total -gt 0 ]]; then
        local score=$((${#CICD_PRESENT[@]} * 100 / total))
        echo -e "  CI/CD score: ${BOLD}${score}%${NC} (${#CICD_PRESENT[@]}/${total})"
    fi
    echo ""
}

get_cicd_choice() {
    echo ""
    prompt "GitHub Actions detected. What do you want to do?"
    echo ""
    echo "  1) Keep the existing one (recommended if score > 70%)"
    echo "  2) Add the missing workflows"
    echo "  3) Replace with the foundation templates"
    echo ""
    prompt "Choice [1-3] (default: 1):"
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

    info "Adding missing workflows..."

    # Create the workflows folder if necessary
    make_dir "$dir/.github/workflows"

    # Mapping of missing features to files
    for missing in "${CICD_MISSING[@]}"; do
        case "$missing" in
            "Security audit"|"Dependency cache"|"Coverage upload"|"Automated tests"|"Linting")
                # These features are in ci.yml
                if [[ "$added_ci" == false ]] && [[ ! -f "$dir/.github/workflows/ci.yml" ]]; then
                    copy_file "$BASE_DIR/.github/workflows/ci.yml" "$dir/.github/workflows/"
                    success "ci.yml added (lint, test, build, security)"
                    added_ci=true
                fi
                ;;
            "PR validation")
                if [[ ! -f "$dir/.github/workflows/pr-check.yml" ]]; then
                    copy_file "$BASE_DIR/.github/workflows/pr-check.yml" "$dir/.github/workflows/"
                    success "pr-check.yml added (PR validation, labels)"
                fi
                ;;
            "Automated release")
                if [[ ! -f "$dir/.github/workflows/release.yml" ]]; then
                    copy_file "$BASE_DIR/.github/workflows/release.yml" "$dir/.github/workflows/"
                    success "release.yml added (changelog, GitHub Release)"
                fi
                ;;
        esac
    done
}

# =============================================================================
# Install functions (simple mode / reusable)
# =============================================================================

# Returns the list of rules to copy based on the detected project type.
# Universal rules are always included. Specific rules are only copied
# if the corresponding language is detected.
# Arguments:
#   $1 - Detected project type (react, vue, node-api, python, go, flutter, etc.)
# Output: List of rule file names to copy (one per line)
get_rules_for_type() {
    local project_type="$1"

    # Universal rules (always copied) — applicable to all projects
    # regardless of language/framework. Includes deploy-safety (Docker/env files)
    # and research (check native before building custom) since these are
    # cross-cutting concerns, not stack-specific.
    local rules=("git.md" "workflow.md" "tdd-enforcement.md" "verification.md" "security.md" "testing.md" "lsp.md" "deploy-safety.md" "research.md" "README.md")

    # Rules specific to the project type
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

    # If type is unknown or generic, add TS/web by default (most common case)
    if [[ "$project_type" == "generic" || -z "$project_type" ]]; then
        rules+=("typescript.md" "react.md" "accessibility.md" "performance.md" "api.md" "design-style.md")
    fi

    # Deduplicate and return
    printf '%s\n' "${rules[@]}" | sort -u
}

# Copy rules filtered by project type
# Arguments:
#   $1 - Source rules directory
#   $2 - Target rules directory
#   $3 - Detected project type
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

    # Count rules not copied
    local total_rules
    total_rules=$(find "$source_dir" -name "*.md" -maxdepth 1 | wc -l)
    skipped=$((total_rules - copied))

    if [[ $skipped -gt 0 ]]; then
        debug "Rules: $copied copied, $skipped skipped (languages not detected)"
    fi
}

# =============================================================================
# Preset support (curated bundles per stack — see specs/presets/spec.md)
# =============================================================================

# Resolve a preset name to a JSON file path. Searches official then community.
# Arguments:
#   $1 - Preset name (e.g. "nextjs")
# Output: path to .json file, or empty if not found.
resolve_preset_file() {
    local name="$1"
    # PRESETS_DIR_OVERRIDE is checked first so tests can inject synthetic presets
    # without touching the official presets tree.
    if [[ -n "$PRESETS_DIR_OVERRIDE" ]]; then
        local override_file="$PRESETS_DIR_OVERRIDE/$name.json"
        if [[ -f "$override_file" ]]; then
            echo "$override_file"
            return
        fi
    fi
    local official="$BASE_DIR/.claude/presets/$name.json"
    local community="$BASE_DIR/.claude/presets/community/$name.json"
    if [[ -f "$official" ]]; then
        echo "$official"
    elif [[ -f "$community" ]]; then
        echo "$community"
    else
        echo ""
    fi
}

# List all available presets (official + community) with status and displayName.
list_presets() {
    if ! command -v jq >/dev/null 2>&1; then
        warning "jq required to list presets"
        return 1
    fi
    local presets_dir="$BASE_DIR/.claude/presets"
    [[ -d "$presets_dir" ]] || { info "No presets directory found"; return 0; }

    info "Available presets:"
    echo ""
    printf "  %-20s %-22s %s\n" "NAME" "STATUS" "DISPLAY NAME"
    printf "  %-20s %-22s %s\n" "----" "------" "------------"
    local found=0
    while IFS= read -r f; do
        local name status display
        name=$(jq -r '.name // ""' "$f" 2>/dev/null)
        status=$(jq -r '.status // ""' "$f" 2>/dev/null)
        display=$(jq -r '.displayName // ""' "$f" 2>/dev/null)
        [[ -z "$name" ]] && continue
        printf "  %-20s %-22s %s\n" "$name" "$status" "$display"
        found=$((found + 1))
    done < <(find "$presets_dir" -maxdepth 2 -name "*.json" -type f | sort)

    if [[ $found -eq 0 ]]; then
        echo "  (none — see specs/presets/roadmap.md)"
    fi
    echo ""
    info "Use: $(cli_usage init) --preset <name> <project-path>"
}

# Load a preset JSON file and populate PRESET_* globals.
# Arguments:
#   $1 - Preset name
# On success: sets PRESET_FILE and applies the preset's defaults to global flags
# (only if those flags weren't explicitly set by the user). Returns 0.
# On failure (preset not found, invalid JSON): returns 2.
load_preset() {
    local name="$1"
    local file
    file=$(resolve_preset_file "$name")
    if [[ -z "$file" ]]; then
        error "preset not found: $name\nRun: $(basename "$0") --list-presets"
    fi

    if ! command -v jq >/dev/null 2>&1; then
        error "jq is required to use --preset"
    fi

    if ! jq -e . "$file" >/dev/null 2>&1; then
        error "preset has invalid JSON: $file"
    fi

    PRESET_FILE="$file"
    info "Preset: $(jq -r '.displayName // .name' "$file") ($(jq -r '.status' "$file"))"
    debug "Preset file: $file"

    # Apply preset defaults — but only if the user did not pass the flag.
    # This way --preset nextjs --no-mcp would still respect the user's no-mcp
    # (though --no-mcp doesn't exist; we use absence of --mcp as default).
    # Convention: a flag is considered "user-set" if its global is true.
    # For ci/hooks/mcp/docker, all default to false, so any true at this
    # point came from the user.
    local p_ci p_hooks p_mcp p_docker p_style
    p_ci=$(jq -r '.defaults.ci // false' "$file")
    p_hooks=$(jq -r '.defaults.hooks // false' "$file")
    p_mcp=$(jq -r '.defaults.mcp // false' "$file")
    p_docker=$(jq -r '.defaults.docker // false' "$file")
    p_style=$(jq -r '.defaults.designStyle // ""' "$file")

    [[ "$INCLUDE_CICD" = "false" && "$p_ci" = "true" ]] && INCLUDE_CICD=true
    [[ "$INCLUDE_HOOKS" = "false" && "$p_hooks" = "true" ]] && INCLUDE_HOOKS=true
    [[ "$INCLUDE_MCP" = "false" && "$p_mcp" = "true" ]] && INCLUDE_MCP=true
    [[ "$INCLUDE_DOCKER" = "false" && "$p_docker" = "true" ]] && INCLUDE_DOCKER=true
    [[ -z "$DESIGN_STYLE" && -n "$p_style" ]] && DESIGN_STYLE="$p_style"

    # Apply foundation type if user did not pass --type.
    if [[ -z "$FORCE_TYPE" ]]; then
        local first_type
        first_type=$(jq -r '.appliesToTypes[0] // ""' "$file")
        if [[ -n "$first_type" ]]; then
            FORCE_TYPE="$first_type"
            debug "Preset sets type: $FORCE_TYPE"
        fi
    fi

    # Capture skills.drop list for later filtering by apply_preset_filter().
    # XOR invariant: a preset may declare EITHER drop[] OR keep[], never both.
    # The validator (validate-presets.sh) enforces this at authoring time;
    # apply_preset_filter() branches on which list is non-empty at runtime.
    PRESET_SKILLS_DROP=()
    while IFS= read -r skill; do
        [[ -z "$skill" ]] && continue
        PRESET_SKILLS_DROP+=("$skill")
    done < <(jq -r '.foundation.skills.drop[]? // empty' "$file")

    # Capture skills.keep list (mutually exclusive with drop — XOR).
    PRESET_SKILLS_KEEP=()
    while IFS= read -r skill; do
        [[ -z "$skill" ]] && continue
        PRESET_SKILLS_KEEP+=("$skill")
    done < <(jq -r '.foundation.skills.keep[]? // empty' "$file")
}

# Apply the preset's skill filter to the target installation.
# Called after install_claude_files() has already copied every skill.
#
# XOR invariant: a preset declares EITHER foundation.skills.drop[] OR
# foundation.skills.keep[], never both (validator enforces this).
#   - drop branch: remove the explicitly listed skills.
#   - keep branch: remove every installed skill whose top-level directory
#     name is NOT in the keep list.
#
# Arguments:
#   $1 - Target directory (absolute path)
apply_preset_filter() {
    local target_dir="$1"
    [[ -z "$PRESET_FILE" ]] && return 0

    # --- keep branch ---
    if [[ ${#PRESET_SKILLS_KEEP[@]} -gt 0 ]]; then
        local removed=0
        local skill_name
        while IFS= read -r skill_dir; do
            skill_name="$(basename "$skill_dir")"
            # Check whether skill_name is in the keep list.
            local keep=false
            local s
            for s in "${PRESET_SKILLS_KEEP[@]}"; do
                if [[ "$s" = "$skill_name" ]]; then
                    keep=true
                    break
                fi
            done
            if ! $keep; then
                if $DRY_RUN; then
                    echo -e "${DIM}[DRY-RUN]${NC} rm -rf $skill_dir (keep filter: not in keep list)"
                else
                    rm -rf "$skill_dir"
                fi
                removed=$((removed + 1))
            fi
        done < <(find "$target_dir/.claude/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
        if [[ $removed -gt 0 ]]; then
            debug "Preset keep-filter: $removed skill(s) removed (not in keep list)"
        fi
        return 0
    fi

    # --- drop branch (unchanged) ---
    [[ ${#PRESET_SKILLS_DROP[@]} -eq 0 ]] && return 0

    local dropped=0
    local skill
    for skill in "${PRESET_SKILLS_DROP[@]}"; do
        local skill_path="$target_dir/.claude/skills/$skill"
        if [[ -d "$skill_path" ]]; then
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} rm -rf $skill_path"
            else
                rm -rf "$skill_path"
            fi
            dropped=$((dropped + 1))
        fi
    done
    if [[ $dropped -gt 0 ]]; then
        debug "Preset filter: $dropped skill(s) dropped (out of stack scope)"
    fi
}

# Install marketplace plugins listed in the preset.
# Lenient mode (B): if `claude plugin install` is unavailable (CLI < 2.1.119)
# OR if a plugin install fails, warn and continue. Foundation install completes
# regardless. Optional plugins are skipped without confirmation.
install_marketplace_plugins() {
    [[ -z "$PRESET_FILE" ]] && return 0
    if ! command -v jq >/dev/null 2>&1; then
        return 0
    fi

    local count
    count=$(jq -r '.marketplacePlugins | length' "$PRESET_FILE" 2>/dev/null || echo 0)
    [[ "$count" = "0" || -z "$count" ]] && return 0

    # Capability check: does `claude plugin` exist?
    if ! command -v claude >/dev/null 2>&1; then
        warning "claude CLI not found — skipping marketplace plugin install"
        return 0
    fi
    if ! claude plugin --help >/dev/null 2>&1; then
        warning "claude plugin command not available (CLI < 2.1.119?) — skipping marketplace plugin install"
        return 0
    fi

    info "Installing marketplace plugins from preset..."
    local i id rationale optional installed=0 skipped=0 failed=0
    for i in $(seq 0 $((count - 1))); do
        id=$(jq -r ".marketplacePlugins[$i].id" "$PRESET_FILE")
        rationale=$(jq -r ".marketplacePlugins[$i].rationale // \"\"" "$PRESET_FILE")
        optional=$(jq -r ".marketplacePlugins[$i].optional // false" "$PRESET_FILE")

        if [[ "$optional" = "true" ]] && ! $NON_INTERACTIVE; then
            if ! confirm "Install optional plugin $id ($rationale)?" "y"; then
                skipped=$((skipped + 1))
                continue
            fi
        fi

        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} claude plugin install $id"
            installed=$((installed + 1))
        elif claude plugin install "$id" 2>&1 | tail -3; then
            installed=$((installed + 1))
        else
            warning "Failed to install $id — continuing"
            failed=$((failed + 1))
        fi
    done
    info "Marketplace plugins: $installed installed, $skipped skipped, $failed failed"
}

# Note: print_recommended_vendor_skills moved to scripts/lib/preset-recommendations.sh
# (sourced above) so update.sh can reuse the same printer at the end of an update.

# Populate MATCHED_PRESETS by scanning PROJECT_PATH against every preset's
# detect block (via lib/preset-detect.sh::scan_presets).
#
# Skipped entirely when:
#   - --preset was passed explicitly (EF-016: explicit user intent wins,
#     no commentary about other matches);
#   - PROJECT_PATH is empty or does not exist on disk (nothing to scan).
#
# Errors degrade silently: scan_presets returns 0 with empty output when
# jq is missing or any preset is malformed.
populate_matched_presets() {
    MATCHED_PRESETS=()
    [[ -n "$PRESET_NAME" ]] && return 0
    [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]] && return 0

    local matches preset
    matches=$(scan_presets "$PROJECT_PATH" 2>/dev/null)
    [[ -z "$matches" ]] && return 0

    while IFS= read -r preset; do
        [[ -n "$preset" ]] && MATCHED_PRESETS+=("$preset")
    done <<< "$matches"
}

# Print one or more suggestion lines based on MATCHED_PRESETS.
# No-op when the list is empty.
# Phase 5 (US-4) refines the interactive flow to surface matches inside
# the type menu; this helper covers the non-interactive paths today.
print_preset_suggestions() {
    [[ ${#MATCHED_PRESETS[@]} -eq 0 ]] && return 0

    echo ""
    if [[ ${#MATCHED_PRESETS[@]} -eq 1 ]]; then
        info "Detected stack — preset matches: ${BOLD}${MATCHED_PRESETS[0]}${NC}"
        echo "  Try: $(cli_usage init) --preset ${MATCHED_PRESETS[0]} <path>"
    else
        info "Detected stack — multiple presets match: ${MATCHED_PRESETS[*]}"
        echo "  Try: $(cli_usage init) --preset <name> <path>"
    fi
    echo ""
}

# Install all .claude/ files (commands, skills, agents, rules, etc.)
# Arguments:
#   $1 - Target directory (absolute path)
# Copies a foundation subdirectory to target, with dry-run support
# Arguments:
#   $1 - Relative subdirectory (e.g. ".claude/commands")
#   $2 - Target base directory
#   $3 - Label for debug output
copy_base_dir() {
    local subdir="$1"
    local target_dir="$2"
    local label="$3"

    if [[ -d "$BASE_DIR/$subdir" ]]; then
        # Check directory is not empty before copying
        if find "$BASE_DIR/$subdir" -maxdepth 1 -mindepth 1 -print -quit | grep -q .; then
            debug "Copying $label..."
            if $DRY_RUN; then
                echo -e "${DIM}[DRY-RUN]${NC} cp -r $BASE_DIR/$subdir/* → $target_dir/$subdir/"
            else
                cp -r "$BASE_DIR/$subdir/"* "$target_dir/$subdir/"
            fi
        fi
    fi
}

install_claude_files() {
    local target_dir="$1"

    info "Installing Claude files..."

    # Create the base structure
    for dir in "$COMMANDS_DIR" "$SKILLS_DIR" "$AGENTS_DIR" "$RULES_DIR" "$STYLES_DIR" "$TEMPLATES_DIR"; do
        make_dir "$target_dir/$dir"
    done

    # Copy subdirectories
    copy_base_dir "$COMMANDS_DIR" "$target_dir" "commands"
    copy_base_dir "$SKILLS_DIR" "$target_dir" "skills"
    copy_base_dir "$AGENTS_DIR" "$target_dir" "agents"
    copy_base_dir "$STYLES_DIR" "$target_dir" "output-styles"
    copy_base_dir "$TEMPLATES_DIR" "$target_dir" "templates"

    # Copy settings.json
    copy_file "$BASE_DIR/.claude/settings.json" "$target_dir/.claude/"

    # Copy rules (filtered by project type)
    debug "Copying filtered rules for type: ${DETECTED_TYPE:-generic}..."
    copy_filtered_rules "$BASE_DIR/$RULES_DIR" "$target_dir/$RULES_DIR" "${DETECTED_TYPE:-generic}"

    # Copy docs/reference/ to .claude/docs/reference/ (required for CLAUDE.md @imports)
    if [[ -d "$BASE_DIR/docs/reference" ]]; then
        debug "Copying docs/reference/ to .claude/docs/reference/ (required for CLAUDE.md @imports)..."
        make_dir "$target_dir/.claude/docs/reference"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $BASE_DIR/docs/reference/* → $target_dir/.claude/docs/reference/"
        else
            cp -r "$BASE_DIR/docs/reference/"* "$target_dir/.claude/docs/reference/"
        fi
    fi

    # Copy docs/guides/ to .claude/docs/guides/
    if [[ -d "$BASE_DIR/docs/guides" ]]; then
        debug "Copying docs/guides/ to .claude/docs/guides/..."
        make_dir "$target_dir/.claude/docs/guides"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp -r $BASE_DIR/docs/guides/* → $target_dir/.claude/docs/guides/"
        else
            cp -r "$BASE_DIR/docs/guides/"* "$target_dir/.claude/docs/guides/"
        fi
    fi

    # Copy docs/STACK-RECIPES.md to .claude/docs/ (consolidation of the 13 legacy stack guides)
    if [[ -f "$BASE_DIR/docs/STACK-RECIPES.md" ]]; then
        debug "Copying docs/STACK-RECIPES.md to .claude/docs/..."
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp $BASE_DIR/docs/STACK-RECIPES.md → $target_dir/.claude/docs/"
        else
            cp "$BASE_DIR/docs/STACK-RECIPES.md" "$target_dir/.claude/docs/STACK-RECIPES.md"
        fi
    fi

    # Copy .mcp.env.example if available
    if [[ -f "$BASE_DIR/.mcp.env.example" ]] && [[ ! -f "$target_dir/.mcp.env.example" ]]; then
        copy_file "$BASE_DIR/.mcp.env.example" "$target_dir/"
    fi

    # Copy scripts/hooks/ (referenced by settings.json)
    # Without these scripts, the SessionStart/PreToolUse/UserPromptSubmit hooks
    # fail silently. Counterpart of the update.sh fix (commit dcaa059).
    if [[ -d "$BASE_DIR/scripts/hooks" ]]; then
        debug "Copying scripts/hooks/ (required for settings.json)..."
        make_dir "$target_dir/scripts/hooks"
        if $DRY_RUN; then
            echo -e "${DIM}[DRY-RUN]${NC} cp $BASE_DIR/scripts/hooks/*.sh → $target_dir/scripts/hooks/"
            echo -e "${DIM}[DRY-RUN]${NC} chmod +x $target_dir/scripts/hooks/*.sh"
        else
            cp "$BASE_DIR/scripts/hooks/"*.sh "$target_dir/scripts/hooks/" 2>/dev/null || true
            find "$target_dir/scripts/hooks" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
        fi
    fi

    success "Commands, skills, agents, rules, styles, templates, docs and hook scripts copied"
}

# Install GitHub Actions
# Arguments:
#   $1 - Target directory (absolute path)
install_cicd_files() {
    local target_dir="$1"

    info "Installing GitHub Actions..."
    make_dir "$target_dir/.github/workflows"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r $BASE_DIR/.github/workflows/* → $target_dir/.github/workflows/"
    else
        cp -r "$BASE_DIR/.github/workflows/"* "$target_dir/.github/workflows/"
    fi

    success "GitHub Actions installed"
}

# Install pre-commit hooks (husky)
# Arguments:
#   $1 - Target directory (absolute path)
install_hooks_files() {
    local target_dir="$1"

    info "Installing pre-commit hooks..."
    make_dir "$target_dir/.husky"

    if $DRY_RUN; then
        echo -e "${DIM}[DRY-RUN]${NC} cp -r husky + config files → $target_dir/"
    else
        cp -r "$BASE_DIR/.husky/"* "$target_dir/.husky/"
        cp "$BASE_DIR/.pre-commit-config.yaml" "$target_dir/" 2>/dev/null || true
        cp "$BASE_DIR/.lintstagedrc.json" "$target_dir/"
        cp "$BASE_DIR/.commitlintrc.json" "$target_dir/"
        if ! chmod +x "$target_dir/.husky/"* 2>/dev/null; then
                warning "Unable to make husky hooks executable"
            fi
    fi

    success "Pre-commit hooks installed"
}

# Install MCP configuration
# Arguments:
#   $1 - Target directory (absolute path)
install_mcp_file() {
    local target_dir="$1"

    info "Installing MCP configuration..."
    copy_file "$BASE_DIR/.mcp.json" "$target_dir/"
    success "MCP configuration installed"
}

# Update or create .gitignore
# Arguments:
#   $1 - Target directory (absolute path)
update_gitignore_file() {
    local target_dir="$1"

    if [[ -f "$target_dir/.gitignore" ]]; then
        if ! grep -q "CLAUDE.local.md" "$target_dir/.gitignore" 2>/dev/null; then
            if ! $DRY_RUN; then
                echo "" >> "$target_dir/.gitignore"
                echo "# Claude Code — local config only" >> "$target_dir/.gitignore"
                echo "# .claude/ and CLAUDE.md are intentionally versioned (team config)" >> "$target_dir/.gitignore"
                echo "CLAUDE.local.md" >> "$target_dir/.gitignore"
                echo ".claude/settings.local.json" >> "$target_dir/.gitignore"
                echo ".mcp.env" >> "$target_dir/.gitignore"
            else
                echo -e "${DIM}[DRY-RUN]${NC} Adding Claude entries (local config) to .gitignore"
            fi
            success ".gitignore updated"
        fi
    else
        copy_file "$BASE_DIR/.gitignore" "$target_dir/"
        success ".gitignore created"
    fi
}

# Install CLAUDE.md (copy generic template + rewrite paths)
# Arguments:
#   $1 - Target directory (absolute path)
install_claude_md_file() {
    local target_dir="$1"

    if [[ -f "$target_dir/CLAUDE.md" ]]; then
        warning "CLAUDE.md already exists, skipped"
    else
        copy_file "$BASE_DIR/CLAUDE.md" "$target_dir/"
        if ! $DRY_RUN; then
            rewrite_claude_md_paths "$target_dir/CLAUDE.md"
            # Align with update.sh: ensure the 7 canonical @imports
            ensure_claude_md_imports "$target_dir/CLAUDE.md"
        fi
        success "CLAUDE.md copied"
    fi

    # Inject the design direction if specified
    if [[ -n "$DESIGN_STYLE" ]] && [[ -f "$target_dir/CLAUDE.md" ]]; then
        if ! $DRY_RUN; then
            printf '\n## Design Direction\nStyle: %s\n' "$DESIGN_STYLE" >> "$target_dir/CLAUDE.md"
            success "Design direction added: $DESIGN_STYLE"
        else
            echo -e "${DIM}[DRY-RUN]${NC} Adding Design Direction: $DESIGN_STYLE in CLAUDE.md"
        fi
    fi

    # Copy CLAUDE.local.md.example
    if [[ ! -f "$target_dir/CLAUDE.local.md.example" ]]; then
        copy_file "$BASE_DIR/CLAUDE.local.md.example" "$target_dir/"
        success "CLAUDE.local.md.example copied"
    fi
}

# Print the install summary (simple mode)
print_simple_summary() {
    local target_dir="$1"

    echo ""
    separator "="
    success "Installation complete!"
    separator "="
    echo ""

    info "Installed files:"
    echo "  - .claude/commands/      ($(count_commands_cached) commands)"
    echo "  - .claude/skills/        ($(count_skills_cached) skills)"
    echo "  - .claude/agents/        ($(count_agents_cached) agents)"
    # Counts that read from $target_dir are guarded with [ -d ] because in
    # dry-run mode the target directory does NOT exist on disk. Without the
    # guard, `find $non_existent_dir | wc -l | tr -d ' '` exits 1 (pipefail
    # propagates find's failure) and `set -eo pipefail` kills the assignment
    # in bash 5+. Reading from $BASE_DIR is always safe.
    local rules_count=0 rules_total project_type_label
    if [[ -d "$target_dir/$RULES_DIR" ]]; then
        rules_count=$(find "$target_dir/$RULES_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    rules_total=$(find "$BASE_DIR/$RULES_DIR" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    project_type_label="${PROJECT_TYPE:-generic}"
    echo "  - .claude/rules/         ($rules_count rules for stack '$project_type_label', $rules_total available in the foundation)"
    echo "  - .claude/output-styles/ (output styles)"
    echo "  - .claude/templates/     (spec templates, Proxmox, etc.)"
    echo "  - .claude/settings.json  ($(count_hooks "$BASE_DIR") hooks)"
    echo "  - .claude/docs/reference/ (CLAUDE.md @import files)"
    echo "  - .claude/docs/guides/    (guides per domain)"
    local hook_scripts_count=0
    if [[ -d "$target_dir/scripts/hooks" ]]; then
        hook_scripts_count=$(find "$target_dir/scripts/hooks" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "  - scripts/hooks/         ($hook_scripts_count scripts referenced by settings.json)"
    echo "  - CLAUDE.md"
    echo "  - CLAUDE.local.md.example"
    echo ""

    info "Next steps:"
    echo "  1. Customize CLAUDE.md for your project"
    echo "  2. Copy CLAUDE.local.md.example to CLAUDE.local.md"
    echo "  3. Launch Claude Code: cd $target_dir && claude"
    echo ""

    info "Available commands:"
    echo "  /work:work-explore, /work:work-plan, /work:work-commit, etc."
    echo ""
}

# Run simple mode (direct install without detection)
run_minimal_mode() {
    local target_dir

    if [[ -n "$PROJECT_PATH" ]]; then
        target_dir="$PROJECT_PATH"
    else
        target_dir="."
    fi

    if [[ ! -d "$target_dir" ]]; then
        if ! $DRY_RUN; then
            mkdir -p "$target_dir" || error "Unable to create folder: $target_dir"
        fi
    fi
    target_dir="$(get_absolute_path "$target_dir")"

    info "Minimal install in: $target_dir"
    $DRY_RUN && { warning "Dry-run mode - no changes"; return 0; }
    echo ""

    local export_script="$BASE_DIR/scripts/export-minimal.sh"
    [[ -x "$export_script" ]] || error "export-minimal.sh not found or not executable: $export_script"

    "$export_script" --dest-dir "$target_dir" || error "export-minimal.sh failed"

    # Write foundation version marker (T1.3)
    write_foundation_marker "$target_dir" "$VERSION"

    success "Minimal install complete in $target_dir"
    echo ""
    info "Next steps:"
    echo "  cd \"$target_dir\""
    echo "  # Read .claude/docs/guides/learning-path.md"
    echo "  claude"
}

run_simple_mode() {
    local target_dir

    # Determine the target directory
    if [[ -n "$PROJECT_PATH" ]]; then
        target_dir="$PROJECT_PATH"
    else
        target_dir="."
    fi

    # Convert to absolute path
    if [[ ! -d "$target_dir" ]]; then
        if ! $DRY_RUN; then
            mkdir -p "$target_dir" || error "Unable to create folder: $target_dir"
        fi
    fi
    target_dir="$(get_absolute_path "$target_dir")"

    info "Installing claude-base in: $target_dir"
    $DRY_RUN && warning "Dry-run mode enabled - no changes will be made"
    echo ""

    # Clean old Claude files if the folder exists
    if [[ -d "$target_dir/.claude" ]]; then
        clean_claude_dirs "$target_dir"
    fi

    # Install Claude files
    install_claude_files "$target_dir"

    # Apply preset filter (drops skills listed in preset.foundation.skills.drop)
    apply_preset_filter "$target_dir"

    # Install CLAUDE.md
    install_claude_md_file "$target_dir"

    # Optional components
    $INCLUDE_CICD && install_cicd_files "$target_dir"
    $INCLUDE_HOOKS && install_hooks_files "$target_dir"
    $INCLUDE_MCP && install_mcp_file "$target_dir"
    $INCLUDE_DOCKER && create_dockerfile "$target_dir"

    # Update .gitignore
    update_gitignore_file "$target_dir"

    # Install marketplace plugins (capability-checked, lenient on failure)
    install_marketplace_plugins

    # Print recommended vendor skills (information only, no install).
    # 2nd arg lets the printer detect project-scoped installs via
    # detect_skill_install_status (T3.2).
    print_recommended_vendor_skills "$PRESET_FILE" "$target_dir"

    # Write foundation version marker (T1.3) — skip in dry-run
    if ! $DRY_RUN; then
        write_foundation_marker "$target_dir" "$VERSION"
    fi

    # Initialize git if not already done
    if [[ ! -d "$target_dir/.git" ]] && ! $DRY_RUN; then
        if (cd "$target_dir" && git init -q); then
            success "git repository initialized"
        else
            warning "git init failed in $target_dir"
        fi
    fi

    # Show the summary
    print_simple_summary "$target_dir"
}

# =============================================================================
# Smart CLAUDE.md generation
# =============================================================================


# =============================================================================
# Main functions
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
    echo "║              claude-base - Project Configuration                    ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

get_project_path() {
    # If --path was provided, validate and use it
    if [[ -n "$PARENT_PATH" ]]; then
        # Convert to absolute path
        if [[ "$PARENT_PATH" = /* ]]; then
            PARENT_PATH="$PARENT_PATH"
        else
            PARENT_PATH="$(cd "$PWD" && cd "$PARENT_PATH" 2>/dev/null && pwd)" || PARENT_PATH="$PWD/$PARENT_PATH"
        fi

        # Create the parent folder if it doesn't exist
        if [[ ! -d "$PARENT_PATH" ]]; then
            if $NON_INTERACTIVE; then
                mkdir -p "$PARENT_PATH" || error "Unable to create folder: $PARENT_PATH"
            else
                warning "The folder '$PARENT_PATH' does not exist"
                prompt "Do you want to create it? (Y/n)"
                read -r -n 1 CREATE_PARENT
                echo
                if [[ ! $CREATE_PARENT =~ ^[Nn]$ ]]; then
                    mkdir -p "$PARENT_PATH" || error "Unable to create folder: $PARENT_PATH"
                    success "Folder created: $PARENT_PATH"
                else
                    error "Parent folder required to create the project"
                fi
            fi
        fi
        return
    fi

    # Interactive mode: ask for the path
    if ! $NON_INTERACTIVE; then
        echo ""
        prompt "Folder where the project will be created (default: current directory):"
        read -r INPUT_PATH

        if [[ -n "$INPUT_PATH" ]]; then
            # Tilde expansion
            INPUT_PATH="${INPUT_PATH/#\~/$HOME}"

            # Convert to absolute path
            if [[ "$INPUT_PATH" = /* ]]; then
                PARENT_PATH="$INPUT_PATH"
            else
                PARENT_PATH="$PWD/$INPUT_PATH"
            fi

            # Create if it doesn't exist
            if [[ ! -d "$PARENT_PATH" ]]; then
                warning "The folder '$PARENT_PATH' does not exist"
                prompt "Do you want to create it? (Y/n)"
                read -r -n 1 CREATE_PARENT
                echo
                if [[ ! $CREATE_PARENT =~ ^[Nn]$ ]]; then
                    mkdir -p "$PARENT_PATH" || error "Unable to create folder: $PARENT_PATH"
                    success "Folder created: $PARENT_PATH"
                else
                    PARENT_PATH="$PWD"
                    info "Using the current directory"
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
        info "Existing project: ${BOLD}$PROJECT_NAME${NC}"
        echo ""
        return
    fi

    # First, get the parent path
    get_project_path

    while true; do
        prompt "Project name (e.g.: my-awesome-app):"
        read -r PROJECT_NAME

        if [[ -z "$PROJECT_NAME" ]]; then
            warning "The project name cannot be empty"
            continue
        fi

        if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
            warning "The name must start with a letter and contain only letters, digits, - and _"
            continue
        fi

        PROJECT_PATH="${PARENT_PATH}/${PROJECT_NAME}"

        if [[ -d "$PROJECT_PATH" ]]; then
            warning "The folder '$PROJECT_PATH' already exists"
            prompt "Do you want to use it anyway? (y/N)"
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
    # ------------------------------------------------------------------
    # Pre-detection category prompt (spec: preset-category-prompt EF-001)
    # Fires only when ALL 4 guards hold (NON_INTERACTIVE already filtered
    # upstream by the caller):
    #   (a) stdin is a TTY              → [ -t 0 ]
    #   (b) no --preset flag was passed → -z "$PRESET_NAME"
    #   (c) no --type flag was passed   → -z "$FORCE_TYPE"
    #   (d) no detection hit            → ${#MATCHED_PRESETS[@]} -eq 0
    # The category prompt itself defaults to "other-generic" (CP1 lock)
    # which is regression-safe (falls back to the unfiltered menu).
    # ------------------------------------------------------------------
    local SELECTED_CATEGORY_SLUG=""
    if [ -t 0 ] \
        && [[ -z "$PRESET_NAME" ]] \
        && [[ -z "$FORCE_TYPE" ]] \
        && [[ ${#MATCHED_PRESETS[@]} -eq 0 ]]; then
        SELECTED_CATEGORY_SLUG=$(ask_category)
    fi

    echo ""
    prompt "Project type:"
    echo ""

    # Branch on whether the category prompt ran. When it did AND the user
    # picked a non-default category, route to the filtered menu. Otherwise
    # the original menu logic (preserves existing behavior + MATCHED_PRESETS
    # handling).
    local use_filtered=false
    if [[ -n "$SELECTED_CATEGORY_SLUG" ]]; then
        use_filtered=true
    fi

    if $use_filtered; then
        # Render filtered menu (sets _TYPE_MENU_TOTAL + _FILTERED_PRESETS
        # + _FILTERED_STD_TYPES).
        print_filtered_type_menu "$SELECTED_CATEGORY_SLUG"
        echo ""

        local total="${_TYPE_MENU_TOTAL:-0}"
        if [[ "$total" -eq 0 ]]; then
            # No relevant entries at all — fall back to the unfiltered menu.
            use_filtered=false
        else
            prompt "Choice [1-$total]: "
            read -r choice

            if ! apply_filtered_type_choice "$choice"; then
                # Invalid input → fall back to other-generic (current behavior).
                PROJECT_TYPE="generic"
            fi
            return 0
        fi
    fi

    # Original (unfiltered) menu logic — regression-safe path.
    local n=${#MATCHED_PRESETS[@]}
    local default_choice=""
    if [[ $n -gt 0 ]]; then
        default_choice="1"
    else
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
    fi

    # Render the menu (sets _TYPE_MENU_TOTAL).
    print_type_menu "$default_choice"
    echo ""

    local total="${_TYPE_MENU_TOTAL:-11}"
    if [[ -n "$default_choice" ]]; then
        prompt "Choice [1-$total] (default: $default_choice): "
    else
        prompt "Choice [1-$total]: "
    fi
    read -r choice

    if [[ -z "$choice" ]] && [[ -n "$default_choice" ]]; then
        choice="$default_choice"
    fi

    if ! apply_type_choice "$choice"; then
        # Invalid input — fall back to detected type or generic.
        PROJECT_TYPE="${DETECTED_TYPE:-generic}"
    fi
}

get_options() {
    # If --skip-prompts is enabled, use the provided flags without asking
    if $SKIP_PROMPTS; then
        debug "Skip prompts enabled - using CLI flags"
        # Honor detection to avoid duplicates
        $DETECTED_CICD && INCLUDE_CICD=false
        $DETECTED_HOOKS && INCLUDE_HOOKS=false
        $DETECTED_DOCKER && INCLUDE_DOCKER=false
        return
    fi

    echo ""
    info "Additional options:"
    echo ""

    # CI/CD
    if $DETECTED_CICD; then
        # Analyze the existing CI/CD and propose improvements
        analyze_existing_cicd "$PROJECT_PATH"
        suggest_cicd_improvements

        if [[ ${#CICD_MISSING[@]} -gt 0 ]]; then
            get_cicd_choice
        else
            echo -e "  ${GREEN}✓${NC} CI/CD complete, no improvements suggested"
            CICD_ACTION="skip"
        fi
        INCLUDE_CICD=false
    else
        if $EXISTING_PROJECT; then
            prompt "Add GitHub Actions (CI/CD)? (Y/n)"
        else
            prompt "Include GitHub Actions (CI/CD)? (Y/n)"
        fi
        read -r -n 1 choice
        echo
        [[ ! $choice =~ ^[Nn]$ ]] && INCLUDE_CICD=true
    fi

    # Hooks
    if $DETECTED_HOOKS; then
        echo -e "  ${DIM}Pre-commit hooks already present${NC}"
        INCLUDE_HOOKS=false
    else
        if $EXISTING_PROJECT; then
            prompt "Add pre-commit hooks (husky)? (Y/n)"
        else
            prompt "Include pre-commit hooks (husky)? (Y/n)"
        fi
        read -r -n 1 choice
        echo
        [[ ! $choice =~ ^[Nn]$ ]] && INCLUDE_HOOKS=true
    fi

    # MCP
    prompt "Include MCP configuration? (y/N)"
    read -r -n 1 choice
    echo
    [[ $choice =~ ^[Yy]$ ]] && INCLUDE_MCP=true

    # Docker
    if $DETECTED_DOCKER; then
        echo -e "  ${DIM}Docker already present${NC}"
        INCLUDE_DOCKER=false
    else
        if $EXISTING_PROJECT; then
            prompt "Add Dockerfile? (y/N)"
        else
            prompt "Include Dockerfile? (y/N)"
        fi
        read -r -n 1 choice
        echo
        [[ $choice =~ ^[Yy]$ ]] && INCLUDE_DOCKER=true
    fi

    # Design direction (only for projects with UI)
    case "$PROJECT_TYPE" in
        react|vue|fullstack|flutter|generic)
            if [[ -z "$DESIGN_STYLE" ]]; then
                echo ""
                info "Design direction (visual personality of the app):"
                echo ""
                echo "  1) terminal   — Monospace, black background, neon accents"
                echo "  2) cockpit    — Dense, dark, real-time indicators"
                echo "  3) vitality   — Vivid colors, rounded, positive energy"
                echo "  4) editorial  — Refined typography, white space, magazine"
                echo "  5) glass      — Transparencies, blur, depth"
                echo "  6) signal     — Raw efficiency, zero decoration"
                echo ""
                prompt "Choice [1-6] (default: none, skip with Enter): "
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
    echo -e "${BOLD}  Configuration summary${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Project:      ${GREEN}${PROJECT_NAME}${NC}"
    echo -e "  Path:         ${CYAN}${PROJECT_PATH}${NC}"
    echo -e "  Type:         ${YELLOW}${PROJECT_TYPE}${NC}"
    if [[ -n "$DETECTED_FRAMEWORK" ]]; then
        echo -e "  Framework:    ${YELLOW}${DETECTED_FRAMEWORK}${NC}"
    fi
    echo ""
    echo "  Options to install:"
    $INCLUDE_CICD && echo -e "    ${GREEN}✓${NC} GitHub Actions" || echo -e "    ${DIM}○ GitHub Actions (skip)${NC}"
    $INCLUDE_HOOKS && echo -e "    ${GREEN}✓${NC} Pre-commit hooks" || echo -e "    ${DIM}○ Pre-commit hooks (skip)${NC}"
    $INCLUDE_MCP && echo -e "    ${GREEN}✓${NC} MCP configuration" || echo -e "    ${DIM}○ MCP configuration (skip)${NC}"
    $INCLUDE_DOCKER && echo -e "    ${GREEN}✓${NC} Dockerfile" || echo -e "    ${DIM}○ Dockerfile (skip)${NC}"
    if [[ -n "$DESIGN_STYLE" ]]; then
        echo -e "    ${GREEN}✓${NC} Design: ${YELLOW}${DESIGN_STYLE}${NC}"
    fi
    echo ""

    if $EXISTING_PROJECT; then
        echo -e "  ${GREEN}✓${NC} CLAUDE.md will be generated automatically with:"
        echo -e "    - Detected npm scripts (${#DETECTED_SCRIPTS[@]} scripts)"
        echo -e "    - Folder structure (${#DETECTED_FOLDERS[@]} folders)"
        echo -e "    - Technologies and dependencies"
        echo ""
        echo -e "  ${DIM}Note: Existing files will not be overwritten${NC}"
        echo ""
    fi

    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    if $EXISTING_PROJECT; then
        prompt "Configure Claude Code for this project? (Y/n)"
    else
        prompt "Create the project with this configuration? (Y/n)"
    fi
    read -r -n 1 confirm
    echo

    if [[ $confirm =~ ^[Nn]$ ]]; then
        info "Operation cancelled"
        exit 0
    fi
}

create_project() {
    echo ""

    # Convert PROJECT_PATH to absolute path (TARGET_DIR)
    local TARGET_DIR
    if $EXISTING_PROJECT; then
        info "Configuring existing project..."
        TARGET_DIR="$(get_absolute_path "$PROJECT_PATH")"
    else
        info "Creating project..."
        if ! $DRY_RUN; then
            mkdir -p "$PROJECT_PATH"
        else
            echo -e "${DIM}[DRY-RUN]${NC} mkdir -p $PROJECT_PATH"
        fi
        TARGET_DIR="$(get_absolute_path "$PROJECT_PATH")"
    fi

    debug "Target directory: $TARGET_DIR"
    $DRY_RUN && warning "Dry-run mode enabled - no changes will be made"

    # Clean old Claude files if the folder exists
    if [[ -d "$TARGET_DIR/.claude" ]]; then
        clean_claude_dirs "$TARGET_DIR"
    fi

    # Install Claude files (commands, agents, skills, rules, styles, templates)
    install_claude_files "$TARGET_DIR"
    success "Claude commands installed ($(count_commands_cached) commands, $(count_agents_cached) agents, $(count_skills_cached) skills)"

    # Generate or copy CLAUDE.md
    if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        # Use the specific template if a type is detected
        # Smart generation is reserved for projects without a dedicated template
        local use_template=false
        case $PROJECT_TYPE in
            react|vue|node-api|python|go|rust|java|fullstack|flutter|neovim)
                use_template=true
                ;;
        esac

        if $use_template; then
            # Copy the template specific to the project type
            info "Configuring CLAUDE.md template..."
            case $PROJECT_TYPE in
                react)     copy_file "$BASE_DIR/templates/CLAUDE.react.md" "$TARGET_DIR/CLAUDE.md" ;;
                vue)       copy_file "$BASE_DIR/templates/CLAUDE.vue.md" "$TARGET_DIR/CLAUDE.md" ;;
                node-api)  copy_file "$BASE_DIR/templates/CLAUDE.node-api.md" "$TARGET_DIR/CLAUDE.md" ;;
                python)    copy_file "$BASE_DIR/templates/CLAUDE.python.md" "$TARGET_DIR/CLAUDE.md" ;;
                go)        copy_file "$BASE_DIR/templates/CLAUDE.go.md" "$TARGET_DIR/CLAUDE.md" ;;
                rust)      copy_file "$BASE_DIR/templates/CLAUDE.rust.md" "$TARGET_DIR/CLAUDE.md" ;;
                java)      copy_file "$BASE_DIR/templates/CLAUDE.java.md" "$TARGET_DIR/CLAUDE.md" ;;
                fullstack) copy_file "$BASE_DIR/templates/CLAUDE.fullstack.md" "$TARGET_DIR/CLAUDE.md" ;;
                flutter)   copy_file "$BASE_DIR/templates/CLAUDE.flutter.md" "$TARGET_DIR/CLAUDE.md" ;;
                neovim)    copy_file "$BASE_DIR/templates/CLAUDE.neovim.md" "$TARGET_DIR/CLAUDE.md" ;;
            esac
            success "CLAUDE.md template configured (${PROJECT_TYPE})"
        elif $EXISTING_PROJECT && [[ ${#DETECTED_SCRIPTS[@]} -gt 0 || ${#DETECTED_FOLDERS[@]} -gt 0 ]]; then
            # Generate a smart CLAUDE.md for existing projects without a template
            generate_smart_claude_md "$TARGET_DIR/CLAUDE.md"
        else
            # Copy the generic template
            info "Configuring CLAUDE.md template..."
            copy_file "$BASE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

            # Replace the project name in CLAUDE.md
            if ! $DRY_RUN; then
                # Escape PROJECT_NAME for safe sed substitution (use | delimiter)
                local safe_name="${PROJECT_NAME//|/\\|}"
                # `-i.bak` works on both GNU sed (Linux) and BSD sed (macOS).
                sed -i.bak "s|# Projet .*|# Projet ${safe_name}|" "$TARGET_DIR/CLAUDE.md" 2>/dev/null \
                    && rm -f "$TARGET_DIR/CLAUDE.md.bak" || true
            fi

            success "CLAUDE.md template configured (${PROJECT_TYPE})"
        fi

        # Align CLAUDE.md with the v1.30+ layout and ensure the 7 canonical
        # @imports (consistency with run_simple_mode and update.sh).
        if ! $DRY_RUN && [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
            rewrite_claude_md_paths "$TARGET_DIR/CLAUDE.md"
            ensure_claude_md_imports "$TARGET_DIR/CLAUDE.md"
        fi
    else
        warning "CLAUDE.md already exists, skipped"
    fi

    # Copy CLAUDE.local.md.example (only if it doesn't exist)
    if [[ ! -f "$TARGET_DIR/CLAUDE.local.md.example" ]]; then
        copy_file "$BASE_DIR/CLAUDE.local.md.example" "$TARGET_DIR/"
        success "CLAUDE.local.md.example copied"
    fi

    # Optional components (using shared functions)
    if $INCLUDE_CICD; then
        install_cicd_files "$TARGET_DIR"
    elif [[ "$CICD_ACTION" == "merge" ]]; then
        merge_cicd_workflows "$TARGET_DIR"
    elif [[ "$CICD_ACTION" == "replace" ]]; then
        warning "Replacing existing workflows..."
        make_dir "$TARGET_DIR/.github/workflows"
        if ! $DRY_RUN; then
            rm -f "$TARGET_DIR/.github/workflows/"*.yml "$TARGET_DIR/.github/workflows/"*.yaml 2>/dev/null || true
            cp -r "$BASE_DIR/.github/workflows/"* "$TARGET_DIR/.github/workflows/"
        else
            echo -e "${DIM}[DRY-RUN]${NC} Replacing workflows in $TARGET_DIR/.github/workflows/"
        fi
        success "GitHub Actions replaced with the foundation templates"
    fi
    $INCLUDE_HOOKS && install_hooks_files "$TARGET_DIR"
    $INCLUDE_MCP && install_mcp_file "$TARGET_DIR"
    $INCLUDE_DOCKER && create_dockerfile "$TARGET_DIR"

    # .gitignore and git init
    update_gitignore_file "$TARGET_DIR"

    # Write foundation version marker (T1.3) — skip in dry-run
    if ! $DRY_RUN; then
        write_foundation_marker "$TARGET_DIR" "$VERSION"
    fi

    if [[ ! -d "$TARGET_DIR/.git" ]]; then
        if ! $DRY_RUN; then
            if (cd "$TARGET_DIR" && git init -q); then
                success "git repository initialized"
            else
                warning "git init failed in $TARGET_DIR"
            fi
        else
            echo -e "${DIM}[DRY-RUN]${NC} git init in $TARGET_DIR"
        fi
    fi
}

# Create a Dockerfile in a specified directory
# Arguments:
#   $1 - Target directory (absolute path, default: current directory)

print_next_steps() {
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    if $EXISTING_PROJECT; then
        echo -e "${BOLD}${GREEN}  Project configured successfully!${NC}"
    else
        echo -e "${BOLD}${GREEN}  Project created successfully!${NC}"
    fi
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    info "Next steps:"
    echo ""

    if ! $EXISTING_PROJECT; then
        echo -e "  ${CYAN}1.${NC} Go into the project:"
        echo -e "     ${YELLOW}cd ${PROJECT_NAME}${NC}"
        echo ""
    fi

    echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "1" || echo "2" ).${NC} Check and customize CLAUDE.md"
    echo ""
    echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "2" || echo "3" ).${NC} Launch Claude Code:"
    echo -e "     ${YELLOW}claude${NC}"
    echo ""

    if $INCLUDE_HOOKS; then
        echo -e "  ${CYAN}$( $EXISTING_PROJECT && echo "3" || echo "4" ).${NC} Enable the hooks (optional):"
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

    echo -e "  ${CYAN}Available commands:${NC}"
    echo -e "     /work:work-explore, /work:work-plan, /work:work-commit, etc."
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

validate_base_dirs() {
    for required_dir in "$COMMANDS_DIR" "$SKILLS_DIR" "$AGENTS_DIR" "$RULES_DIR"; do
        [[ -d "$BASE_DIR/$required_dir" ]] || error "Foundation directory missing: $BASE_DIR/$required_dir"
    done
}

main() {
    # Parse arguments first
    parse_args "$@"

    # Validate that the foundation installation is intact
    validate_base_dirs

    # --list-presets short-circuits everything else
    if $PRESET_LIST_AND_EXIT; then
        list_presets
        exit 0
    fi

    # --detect-only: scan the target dir, print matches, exit. No file writes.
    if $DETECT_ONLY; then
        if [[ -n "$PRESET_NAME" ]]; then
            error "--detect-only and --preset are mutually exclusive"
        fi
        if [[ -z "$PROJECT_PATH" ]]; then
            error "--detect-only requires a path argument"
        fi
        if [[ ! -d "$PROJECT_PATH" ]]; then
            error "Path does not exist: $PROJECT_PATH"
        fi
        local _matches
        _matches=$(scan_presets "$PROJECT_PATH")
        if [[ -z "$_matches" ]]; then
            info "No matching preset for: $PROJECT_PATH"
        else
            info "Matching preset(s) for $PROJECT_PATH:"
            while IFS= read -r _p; do
                [[ -n "$_p" ]] && echo "  - $_p"
            done <<< "$_matches"
        fi
        exit 0
    fi

    # Load preset (if any) BEFORE mode dispatch so defaults propagate
    # to MINIMAL/SIMPLE/interactive modes consistently.
    if [[ -n "$PRESET_NAME" ]]; then
        if $MINIMAL_MODE; then
            error "--preset and --minimal are mutually exclusive"
        fi
        load_preset "$PRESET_NAME"
        # Preset implies non-interactive simple install (avoid double-asking
        # for things the preset already decided).
        if [[ -z "$PROJECT_PATH" ]]; then
            error "--preset requires a project path argument"
        fi
        SIMPLE_MODE=true
        NON_INTERACTIVE=true
        SKIP_PROMPTS=true
    fi

    # Minimal mode: delegates to export-minimal.sh with --dest-dir
    if $MINIMAL_MODE; then
        if ! $QUIET; then
            echo ""
            echo -e "${BOLD}${CYAN}Claude-Base - Minimal Install${NC}"
            echo ""
        fi
        run_minimal_mode
        exit 0
    fi

    # Simple mode: direct install without stack detection
    if $SIMPLE_MODE; then
        # Honor -t/--type even in simple mode (otherwise the rules filter
        # falls back to "generic" and copies React/TS instead of the requested stack).
        if [[ -n "$FORCE_TYPE" ]]; then
            PROJECT_TYPE="$FORCE_TYPE"
            DETECTED_TYPE="$FORCE_TYPE"
        fi
        # Show the banner (except in quiet mode)
        if ! $QUIET; then
            echo ""
            echo -e "${BOLD}${CYAN}Claude-Base - Simple Install${NC}"
            echo ""
        fi
        # Detect matching presets (skipped when --preset was explicit, EF-016).
        populate_matched_presets
        if ! $QUIET; then
            print_preset_suggestions
        fi
        run_simple_mode
        exit 0
    fi

    # Show the banner (except in quiet non-interactive mode)
    if ! $NON_INTERACTIVE; then
        print_banner
    fi

    # Check whether a path is passed as argument
    if [[ -n "$PROJECT_PATH" ]]; then
        # If --path is also provided, PROJECT_PATH is the project name
        if [[ -n "$PARENT_PATH" ]]; then
            PROJECT_NAME="$PROJECT_PATH"
            # Validate the project name
            if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
                error "The project name must start with a letter and contain only letters, digits, - and _"
            fi
            # Resolve the parent path
            if [[ "$PARENT_PATH" = /* ]]; then
                PARENT_PATH="$PARENT_PATH"
            else
                PARENT_PATH="$(cd "$PWD" && cd "$PARENT_PATH" 2>/dev/null && pwd)" || PARENT_PATH="$PWD/$PARENT_PATH"
            fi
            # Create the parent folder if necessary
            if [[ ! -d "$PARENT_PATH" ]]; then
                mkdir -p "$PARENT_PATH" || error "Unable to create folder: $PARENT_PATH"
            fi
            PROJECT_PATH="${PARENT_PATH}/${PROJECT_NAME}"
            if [[ -d "$PROJECT_PATH" ]]; then
                EXISTING_PROJECT=true
                PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
                info "Analyzing existing project: $PROJECT_PATH"
                echo ""
                detect_stack "$PROJECT_PATH"
                # Matches are surfaced inside the type menu (US-4) — no banner.
                populate_matched_presets
            else
                info "Creating new project: $PROJECT_PATH"
            fi
        elif [[ -d "$PROJECT_PATH" ]]; then
            PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
            EXISTING_PROJECT=true
            info "Analyzing existing project: $PROJECT_PATH"
            echo ""
            detect_stack "$PROJECT_PATH"
            # Matches are surfaced inside the type menu (US-4) — no banner.
            populate_matched_presets
        elif $NON_INTERACTIVE; then
            # In non-interactive mode, create the folder if it doesn't exist
            mkdir -p "$PROJECT_PATH"
            PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
            info "Creating new project: $PROJECT_PATH"
        else
            error "The path '$PROJECT_PATH' does not exist"
        fi
    fi

    # Apply the forced type if specified
    if [[ -n "$FORCE_TYPE" ]]; then
        PROJECT_TYPE="$FORCE_TYPE"
        DETECTED_TYPE="$FORCE_TYPE"
    fi

    # Non-interactive mode
    if $NON_INTERACTIVE; then
        # Use the folder name or a default name
        if [[ -z "$PROJECT_NAME" ]]; then
            if [[ -n "$PROJECT_PATH" ]]; then
                PROJECT_NAME=$(basename "$PROJECT_PATH")
            else
                PROJECT_NAME="new-project"
                # Use PARENT_PATH if provided, otherwise PWD
                local base_path="${PARENT_PATH:-$PWD}"
                if [[ -n "$PARENT_PATH" ]] && [[ ! -d "$PARENT_PATH" ]]; then
                    mkdir -p "$PARENT_PATH" || error "Unable to create folder: $PARENT_PATH"
                fi
                PROJECT_PATH="${base_path}/${PROJECT_NAME}"
                mkdir -p "$PROJECT_PATH"
            fi
        fi

        # Use the detected type or generic
        if [[ -z "$PROJECT_TYPE" ]]; then
            PROJECT_TYPE="${DETECTED_TYPE:-generic}"
        fi

        # Use defaults for unspecified options
        # (Options are already false by default, --ci/--hooks/etc enable them)

        # Honor detection to avoid duplicates
        $DETECTED_CICD && INCLUDE_CICD=false
        $DETECTED_HOOKS && INCLUDE_HOOKS=false
        $DETECTED_DOCKER && INCLUDE_DOCKER=false

        info "Non-interactive mode enabled"
        info "Project: $PROJECT_NAME ($PROJECT_TYPE)"
        echo ""

        create_project
        print_next_steps
    else
        # Standard interactive mode
        get_project_name
        get_project_type
        # If the user picked a preset entry from the type menu, load it
        # and skip per-option prompts (preset decides defaults).
        if [[ -n "$PRESET_NAME" && -z "$PRESET_FILE" ]]; then
            load_preset "$PRESET_NAME"
            SKIP_PROMPTS=true
        fi
        get_options
        confirm_choices
        create_project
        print_next_steps
    fi
}

# Run the script
main "$@"
