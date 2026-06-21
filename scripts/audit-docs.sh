#!/usr/bin/env bash

# =============================================================================
# Claude-Base — Doc Drift Firewall
# Spec: specs/audit-docs/spec.md
# Plan: specs/audit-docs/plan.md
#
# Catches 5 categories of syntactic doc drift in hand-maintained docs:
#   1. paths   — unknown ~/X prefixes
#   2. verbs   — unknown `claude-base <verb>` invocations
#   3. flags   — unknown `claude-base init --<flag>` / `update --<flag>`
#   4. scripts — references to missing ./scripts/X.sh
#   5. npm    — unknown `npm --prefix website run <X>` scripts
#
# Out of scope: semantic drift, auto-fix, counter prose drift (owned by
# validate-counts.sh), .claude/rules/* (user-project script descriptors),
# auto-generated mirrors (website/docs/{agents,commands,skills,rules}/**).
#
# Allowlists are bash arrays at the top of this script — 1-line edit to extend.
# Env-var bypass per category: AUDIT_DOCS_SKIP_{PATHS,VERBS,FLAGS,SCRIPTS,NPM}=1
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Allowlists (locked at plan time, verified via grep on live code 2026-05-19)
# =============================================================================

# bin/claude-base case @ ~line 120
# add/remove/modules shipped by specs/foundation-modules S2
# shellcheck disable=SC2034  # consumed by audit_verbs via is_in_array nameref
KNOWN_VERBS=(init update validate doctor lessons preset add remove modules uninstall version help)

# scripts/new-project.sh @ lines 258-337
# shellcheck disable=SC2034  # consumed by _audit_flags_pass via nameref
KNOWN_INIT_FLAGS=(
    --verbose --ci --hooks --mcp --docker --all --style --skip-prompts
    --minimal --preset --presets-dir --list-presets --detect-only
    --yes -y --type -t --simple --install-only
)

# scripts/update.sh
# shellcheck disable=SC2034  # consumed by _audit_flags_pass via nameref
KNOWN_UPDATE_FLAGS=(
    --add-hook --add-plugin --agents --all --backup-only --changelog
    --clean --detect-only --detect-orphans --hook-scripts --no-preset --preset
    --presets-dir --remove-orphans --restore --rules --settings --skills
    --styles --templates --upgrade-claude-md --verbose
)

# Path prefixes legitimate when audit_paths scans claude-containing paths.
# The regex `~/.*claude.*` already filters out unrelated ~/X paths
# (~/.zshrc, ~/.ssh, ~/.kube, etc.) so this allowlist need only enumerate
# the foundation's canonical claude-related paths. Tildes are intentional
# literal strings (we string-match against grep extractions, not paths to
# expand) — silence SC2088.
# shellcheck disable=SC2088
KNOWN_PATH_PREFIXES=(
    "~/.claude/"                  # Claude Code user config dir
    "~/.claude.json"              # Claude Code user state file
    "~/.local/share/claude-base"  # canonical foundation install per install.sh:33
    "~/dev/vendor-skills/"        # user-suggested vendor clone location
    "~/dev/"                      # broader user-dev convention
)

# =============================================================================
# Env-var bypass (5 per-category skips)
# =============================================================================

SKIP_PATHS="${AUDIT_DOCS_SKIP_PATHS:-0}"
SKIP_VERBS="${AUDIT_DOCS_SKIP_VERBS:-0}"
SKIP_FLAGS="${AUDIT_DOCS_SKIP_FLAGS:-0}"
SKIP_SCRIPTS="${AUDIT_DOCS_SKIP_SCRIPTS:-0}"
SKIP_NPM="${AUDIT_DOCS_SKIP_NPM:-0}"

# =============================================================================
# CLI args
# =============================================================================

TARGET=""
SINGLE_CATEGORY=""
VERBOSE=0

show_help() {
    cat <<EOF
${BOLD}Claude-Base Doc Drift Firewall${NC}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Catches 5 categories of syntactic doc drift in hand-maintained docs:
    paths, claude-base verbs, init/update CLI flags, local script
    references, website npm scripts. Exits 0 on clean, 1 on drift.

${BOLD}OPTIONS${NC}
    -h, --help            Show this help
    --verbose             Print extraction patterns + match counts per category
    --category <name>     Run only one category: paths|verbs|flags|scripts|npm
    --target <file|dir>   Audit one file or one directory recursively
                          (default: 8 hand-maintained doc globs under \$BASE_DIR)

${BOLD}ENVIRONMENT${NC}
    AUDIT_DOCS_SKIP_PATHS=1     Skip the paths category
    AUDIT_DOCS_SKIP_VERBS=1     Skip the verbs category
    AUDIT_DOCS_SKIP_FLAGS=1     Skip the flags category
    AUDIT_DOCS_SKIP_SCRIPTS=1   Skip the scripts category
    AUDIT_DOCS_SKIP_NPM=1       Skip the npm category

${BOLD}EXIT CODES${NC}
    0    No drift detected
    1    Drift detected (see output)
    2    Tooling failure (missing dep, bad arg)

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        --verbose) VERBOSE=1; shift ;;
        --category) SINGLE_CATEGORY="$2"; shift 2 ;;
        --target) TARGET="$2"; shift 2 ;;
        *) error "Unknown option: $1"; show_help; exit 2 ;;
    esac
done

# =============================================================================
# Derived allowlist: KNOWN_NPM_SCRIPTS (live from website/package.json)
# =============================================================================

KNOWN_NPM_SCRIPTS=()
if [[ -f "$BASE_DIR/website/package.json" ]] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r s; do
        KNOWN_NPM_SCRIPTS+=("$s")
    done < <(jq -r '.scripts | keys[]' "$BASE_DIR/website/package.json")
fi

# =============================================================================
# Scope enumeration
# =============================================================================

# enumerate_scope_files() — print one absolute path per line
enumerate_scope_files() {
    if [[ -n "$TARGET" ]]; then
        # --target mode: single file or directory
        if [[ -f "$TARGET" ]]; then
            echo "$TARGET"
        elif [[ -d "$TARGET" ]]; then
            find "$TARGET" -type f -name '*.md' 2>/dev/null | sort
        else
            error "Target not found: $TARGET"
            exit 2
        fi
    else
        # Default mode: 8 hand-maintained doc globs
        local globs=(
            "$BASE_DIR/docs"
            "$BASE_DIR/website/docs/intro"
            "$BASE_DIR/website/docs/concepts"
            "$BASE_DIR/website/docs/examples"
            "$BASE_DIR/website/docs/tutorials"
            "$BASE_DIR/website/docs/workflow"
            "$BASE_DIR/website/docs/guides"
            "$BASE_DIR/website/docs/reference"
        )
        for g in "${globs[@]}"; do
            [[ -d "$g" ]] && find "$g" -type f -name '*.md' 2>/dev/null
        done | sort -u
    fi
}

# Cache the scope files list to avoid re-running find 5 times.
SCOPE_FILES=()
while IFS= read -r f; do
    [[ -n "$f" ]] && SCOPE_FILES+=("$f")
done < <(enumerate_scope_files)

if [[ ${#SCOPE_FILES[@]} -eq 0 ]]; then
    info "audit-docs: no files in scope, nothing to audit"
    exit 0
fi

# =============================================================================
# Drift accumulator
# =============================================================================

DRIFTS=()

report_drift() {
    local file="$1" line="$2" category="$3" message="$4"
    # Normalize file path to relative if under BASE_DIR
    local rel="$file"
    case "$file" in
        "$BASE_DIR/"*) rel="${file#"$BASE_DIR/"}" ;;
    esac
    DRIFTS+=("$rel:$line: [$category] $message")
}

# =============================================================================
# Helpers
# =============================================================================

# is_in_array <value> <array_name>
is_in_array() {
    local needle="$1"
    local -n haystack="$2"
    local item
    for item in "${haystack[@]}"; do
        [[ "$item" = "$needle" ]] && return 0
    done
    return 1
}

# =============================================================================
# Category: paths (EF-001)
# =============================================================================

audit_paths() {
    if [[ "$SKIP_PATHS" = "1" ]]; then
        info "audit_paths: skipped (AUDIT_DOCS_SKIP_PATHS=1)"
        return 0
    fi
    [[ "$VERBOSE" = "1" ]] && info "audit_paths: scanning ${#SCOPE_FILES[@]} files for ~/X patterns containing 'claude'"

    # Threat model: typos of FOUNDATION install paths (PR #199 historical bug
    # `~/.claude-base/` vs canonical `~/.local/share/claude-base/`). Scope the
    # regex to paths that contain "claude" — out-of-scope common user-home
    # paths (~/.zshrc, ~/.ssh/*, ~/.kube/*, ~/.tmux.conf) are tutorial-legit
    # and not the firewall's job.
    local raw
    # shellcheck disable=SC2088  # literal pattern for grep, not a path
    raw=$(grep -nEoH '~/[a-zA-Z0-9._/-]*claude[a-zA-Z0-9._/-]*' "${SCOPE_FILES[@]}" 2>/dev/null || true)
    [[ -z "$raw" ]] && return 0

    local line file_part lineno path_match
    while IFS= read -r line; do
        # line format: file:linenum:match
        file_part="${line%%:*}"
        local rest="${line#*:}"
        lineno="${rest%%:*}"
        path_match="${rest#*:}"

        # Check against allowlist
        local known=0
        local prefix
        for prefix in "${KNOWN_PATH_PREFIXES[@]}"; do
            if [[ "$path_match" == "$prefix"* ]]; then
                known=1
                break
            fi
        done

        if [[ "$known" = "0" ]]; then
            report_drift "$file_part" "$lineno" "paths" "unknown path prefix: $path_match"
        fi
    done <<< "$raw"
}

# =============================================================================
# Category: verbs (EF-002)
# =============================================================================

audit_verbs() {
    if [[ "$SKIP_VERBS" = "1" ]]; then
        info "audit_verbs: skipped (AUDIT_DOCS_SKIP_VERBS=1)"
        return 0
    fi
    [[ "$VERBOSE" = "1" ]] && info "audit_verbs: scanning ${#SCOPE_FILES[@]} files for claude-base WORD patterns (CLI context only)"

    local raw
    raw=$(grep -nEoH 'claude-base [a-z][a-z-]+' "${SCOPE_FILES[@]}" 2>/dev/null || true)
    [[ -z "$raw" ]] && return 0

    local line file_part lineno match word original
    while IFS= read -r line; do
        file_part="${line%%:*}"
        local rest="${line#*:}"
        lineno="${rest%%:*}"
        match="${rest#*:}"
        word="${match#claude-base }"

        # Pass 1: known verb? → not drift
        if is_in_array "$word" KNOWN_VERBS; then
            continue
        fi

        # Pass 2: require CLI context. The match is a real CLI invocation only
        # if one of these holds:
        #   (a) the line wraps it in backticks (`claude-base WORD`)
        #   (b) the line is a shell-prompt invocation ($ claude-base WORD ...)
        #   (c) the line starts with claude-base AND has CLI-shape evidence
        #       (a --flag or a / path-arg) — this filters paragraph prose like
        #       "claude-base is a foundation" while keeping code blocks like
        #       "claude-base init --foo ./project".
        original=$(sed -n "${lineno}p" "$file_part" 2>/dev/null || echo "")
        if [[ "$original" == *'`claude-base '* ]]; then
            report_drift "$file_part" "$lineno" "verbs" "unknown claude-base verb: $word"
        elif [[ "$original" =~ ^[[:space:]]*\$[[:space:]]+claude-base[[:space:]] ]]; then
            report_drift "$file_part" "$lineno" "verbs" "unknown claude-base verb: $word"
        elif [[ "$original" =~ ^claude-base[[:space:]] ]] \
             && { [[ "$original" == *' --'* ]] || [[ "$original" == *' /'* ]] || [[ "$original" == *' ./'* ]]; }; then
            report_drift "$file_part" "$lineno" "verbs" "unknown claude-base verb: $word"
        fi
        # Else: prose context, silently ignore
    done <<< "$raw"
}

# =============================================================================
# Category: flags (EF-003)
# =============================================================================

audit_flags() {
    if [[ "$SKIP_FLAGS" = "1" ]]; then
        info "audit_flags: skipped (AUDIT_DOCS_SKIP_FLAGS=1)"
        return 0
    fi
    [[ "$VERBOSE" = "1" ]] && info "audit_flags: scanning ${#SCOPE_FILES[@]} files for init/update --flag patterns"

    # Pass 1: claude-base init --flag
    _audit_flags_pass "init" KNOWN_INIT_FLAGS
    # Pass 2: claude-base update --flag
    _audit_flags_pass "update" KNOWN_UPDATE_FLAGS
}

_audit_flags_pass() {
    local verb="$1"
    local allowlist_name="$2"
    local -n allowlist="$allowlist_name"

    local raw
    raw=$(grep -nEoH "claude-base ${verb}[^\n]*--[a-zA-Z][a-zA-Z-]+" "${SCOPE_FILES[@]}" 2>/dev/null || true)
    [[ -z "$raw" ]] && return 0

    local line file_part lineno match flag
    while IFS= read -r line; do
        file_part="${line%%:*}"
        local rest="${line#*:}"
        lineno="${rest%%:*}"
        match="${rest#*:}"

        # Extract the flag(s) from the match — may be multiple --X --Y; take the last
        # by matching the trailing --[a-zA-Z][a-zA-Z-]+
        flag="${match##*--}"
        flag="--${flag}"

        # Check allowlist
        local known=0
        local f
        for f in "${allowlist[@]}"; do
            [[ "$flag" = "$f" ]] && { known=1; break; }
        done

        if [[ "$known" = "0" ]]; then
            report_drift "$file_part" "$lineno" "flags" "unknown $verb flag: $flag"
        fi
    done <<< "$raw"
}

# =============================================================================
# Category: scripts (EF-004, EF-013)
# =============================================================================

audit_scripts() {
    if [[ "$SKIP_SCRIPTS" = "1" ]]; then
        info "audit_scripts: skipped (AUDIT_DOCS_SKIP_SCRIPTS=1)"
        return 0
    fi
    [[ "$VERBOSE" = "1" ]] && info "audit_scripts: scanning ${#SCOPE_FILES[@]} files for ./scripts/X.sh patterns"

    # Build the audit files list, excluding .claude/rules/**
    local audit_files=()
    local f
    for f in "${SCOPE_FILES[@]}"; do
        case "$f" in
            *.claude/rules/*) continue ;;
            *) audit_files+=("$f") ;;
        esac
    done
    [[ ${#audit_files[@]} -eq 0 ]] && return 0

    local raw
    raw=$(grep -nEoH '\./scripts/[a-zA-Z][a-zA-Z0-9_-]*\.sh' "${audit_files[@]}" 2>/dev/null || true)
    [[ -z "$raw" ]] && return 0

    local line file_part lineno script original
    while IFS= read -r line; do
        file_part="${line%%:*}"
        local rest="${line#*:}"
        lineno="${rest%%:*}"
        script="${rest#*:}"

        # EF-013: skip if the original line contains an http(s):// URL — the
        # match is part of a remote URL, not a local script reference.
        original=$(sed -n "${lineno}p" "$file_part" 2>/dev/null || echo "")
        if [[ "$original" == *"http://"* ]] || [[ "$original" == *"https://"* ]]; then
            continue
        fi

        # Cross-check existence relative to BASE_DIR
        # script = "./scripts/X.sh" — strip leading "./"
        local rel_script="${script#./}"
        if [[ ! -f "$BASE_DIR/$rel_script" ]]; then
            report_drift "$file_part" "$lineno" "scripts" "missing local script: $script"
        fi
    done <<< "$raw"
}

# =============================================================================
# Category: npm (EF-005)
# =============================================================================

audit_npm() {
    if [[ "$SKIP_NPM" = "1" ]]; then
        info "audit_npm: skipped (AUDIT_DOCS_SKIP_NPM=1)"
        return 0
    fi
    [[ "$VERBOSE" = "1" ]] && info "audit_npm: scanning ${#SCOPE_FILES[@]} files for npm --prefix website run X patterns"

    local raw
    # Match both forms: "npm --prefix website run X" and "cd website && npm run X"
    raw=$(grep -nEoH '(npm --prefix website run [a-zA-Z][a-zA-Z0-9:_-]*|cd website && npm run [a-zA-Z][a-zA-Z0-9:_-]*)' "${SCOPE_FILES[@]}" 2>/dev/null || true)
    [[ -z "$raw" ]] && return 0

    local line file_part lineno match script
    while IFS= read -r line; do
        file_part="${line%%:*}"
        local rest="${line#*:}"
        lineno="${rest%%:*}"
        match="${rest#*:}"

        # Extract the script name (after "run ")
        script="${match##*run }"

        # Cross-check against live KNOWN_NPM_SCRIPTS
        local known=0
        local s
        for s in "${KNOWN_NPM_SCRIPTS[@]}"; do
            [[ "$script" = "$s" ]] && { known=1; break; }
        done

        if [[ "$known" = "0" ]]; then
            report_drift "$file_part" "$lineno" "npm" "unknown website npm script: $script"
        fi
    done <<< "$raw"
}

# =============================================================================
# Final report + exit
# =============================================================================

final_report() {
    if [[ ${#DRIFTS[@]} -eq 0 ]]; then
        success "audit-docs: no drift detected"
        exit 0
    fi

    error_no_exit "audit-docs: ${#DRIFTS[@]} drift(s) detected:"
    local d
    for d in "${DRIFTS[@]}"; do
        echo "  $d"
    done
    exit 1
}

# =============================================================================
# Main dispatcher
# =============================================================================

if [[ -n "$SINGLE_CATEGORY" ]]; then
    case "$SINGLE_CATEGORY" in
        paths)   audit_paths ;;
        verbs)   audit_verbs ;;
        flags)   audit_flags ;;
        scripts) audit_scripts ;;
        npm)     audit_npm ;;
        *) error "Unknown category: $SINGLE_CATEGORY (expected: paths|verbs|flags|scripts|npm)"; exit 2 ;;
    esac
else
    audit_paths
    audit_verbs
    audit_flags
    audit_scripts
    audit_npm
fi

final_report
