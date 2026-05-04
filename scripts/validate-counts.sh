#!/usr/bin/env bash

# =============================================================================
# Claude-Socle Validate Counts Script
# Verifies that counters (commands, agents, skills, rules) are consistent
# between actual files and documentation
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCLE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

enable_error_handler
check_base_requirements

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << EOF
${BOLD}Claude-Socle Validate Counts${NC}

${BOLD}USAGE${NC}
    $(basename "$0") [OPTIONS]

${BOLD}DESCRIPTION${NC}
    Verifies that counters for commands, agents, skills and rules
    are consistent between actual files and documentation.

${BOLD}OPTIONS${NC}
    -h, --help     Show this help
    -v, --verbose  Verbose mode
    --fix          Show correction commands
    --mixed        Temporary bilingual mode (FR/EN coexist during the
                   FR->EN migration). Layer 2 (global scan_drift) stays
                   strict, Layer 1 FR-specific patterns tolerate a miss.

${BOLD}EXAMPLES${NC}
    $(basename "$0")
    $(basename "$0") --verbose
    $(basename "$0") --fix
    $(basename "$0") --mixed   # during the FR->EN migration
EOF
}

# =============================================================================
# Variables
# =============================================================================

ERRORS=0
SHOW_FIX=false
MIXED=false

# =============================================================================
# Argument parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --fix)
            SHOW_FIX=true
            shift
            ;;
        --mixed)
            MIXED=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# =============================================================================
# Count actual files
# =============================================================================

if $MIXED; then
    info "Mode --mixed active (FR->EN migration in progress)"
    echo ""
fi

info "Counting actual files..."
echo ""

# `wc -l` on BSD (macOS) pads its output with leading whitespace
# (e.g. "       1") whereas GNU wc emits "1". Strip whitespace via `tr` so
# the comparisons below (which use literal string equality) work uniformly.
# Without this, every counter on macOS reads as " N" and fails to match the
# clean integers extracted from documentation files.

# Count commands (md files in commands/ subdirectories, exclude README.md index files)
ACTUAL_COMMANDS=$(find "$SOCLE_DIR/.claude/commands" -name "*.md" -not -name "README.md" -type f | wc -l | tr -d '[:space:]')

# Count agents (exclude README.md index files)
ACTUAL_AGENTS=$(find "$SOCLE_DIR/.claude/agents" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d '[:space:]')

# Count skills (directories with SKILL.md)
ACTUAL_SKILLS=$(find "$SOCLE_DIR/.claude/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d '[:space:]')

# Count rules (exclude README.md index files)
ACTUAL_RULES=$(find "$SOCLE_DIR/.claude/rules" -name "*.md" -not -name "README.md" -type f 2>/dev/null | wc -l | tr -d '[:space:]')

# Count tests (count `@test` lines across .bats files — fast, static, no execution)
ACTUAL_TESTS=$(awk '/^@test/{n++} END{print n+0}' "$SOCLE_DIR"/tests/*.bats 2>/dev/null || echo 0)
ACTUAL_TEST_FILES=$(find "$SOCLE_DIR/tests" -name "*.bats" -type f 2>/dev/null | wc -l | tr -d '[:space:]')

echo "  Commands : $ACTUAL_COMMANDS"
echo "  Agents   : $ACTUAL_AGENTS"
echo "  Skills   : $ACTUAL_SKILLS"
echo "  Rules    : $ACTUAL_RULES"
echo "  Tests    : $ACTUAL_TESTS (in $ACTUAL_TEST_FILES files)"
echo ""

# =============================================================================
# Check documentation files
# =============================================================================

check_count() {
    local file="$1"
    local pattern="$2"
    local expected="$3"
    local label="$4"

    local rel_path="${file#"$SOCLE_DIR"/}"

    if [[ ! -f "$file" ]]; then
        debug "File not found: $rel_path"
        return
    fi

    # `-oE` (extended regex, POSIX) instead of `-oP` (Perl regex, GNU-only).
    # The patterns passed by callers use only ERE-compatible features
    # (character classes, +/* quantifiers, anchors) so no semantic loss.
    local found
    found=$(grep -oE "$pattern" "$file" 2>/dev/null | head -1 || echo "")

    if [[ -z "$found" ]]; then
        debug "$rel_path: pattern not found for $label"
        return
    fi

    local count
    count=$(echo "$found" | grep -oE '[0-9]+' | head -1)

    if [[ "$count" != "$expected" ]]; then
        error_no_exit "$rel_path: $label = $count (expected: $expected)"
        ERRORS=$((ERRORS + 1))
    else
        if $VERBOSE; then
            success "$rel_path: $label = $count"
        fi
    fi
}

info "Checking documentation..."
echo ""

# Layer 1 redundant checks for files now covered by:
#   - counts.json + CI gate (TS consumers: Stats.tsx, FeatureComparison.tsx,
#     index.tsx, sidebars.ts, docusaurus.config.ts)
#   - inject-counts-md.ts (instrumented MD: intro/index.md, intro/architecture.md,
#     README.md, docs/CHEATSHEET.md, docs/ARCHITECTURE.md)
# were removed as part of the counts-source-of-truth refactor.
# See specs/counts-source-of-truth/ for design notes.
#
# Remaining Layer 1 check: CLAUDE.md FR-era patterns kept as defense-in-depth
# in case narrative counters are ever re-added to CLAUDE.md.

# --- CLAUDE.md (defense in depth) ---
info "CLAUDE.md"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ commandes" "$ACTUAL_COMMANDS" "commands"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ sub-agents" "$ACTUAL_AGENTS" "agents"
check_count "$SOCLE_DIR/CLAUDE.md" \
    "[0-9]+ skills" "$ACTUAL_SKILLS" "skills"

echo ""

# =============================================================================
# Layer 2 : Global anti-drift scan (catch any stale total-counter)
# =============================================================================
# Detects any number that appears in a "total counter" context but does not
# match the canonical value. Targeted patterns (low false-positive) :
#   - `Label (N)`     : e.g. `Skills (47)`, `Agents (63)`, `WORK (12)`
#   - `(N) Label`     : e.g. `(54) skills available`
#   - `**N Label**`   : e.g. `**54 skills**`
#   - `'N Label'`     : e.g. `'131 Commands'` in TS/TSX components
# Exclusions : CHANGELOG (history), node_modules, build, .docusaurus, memory.

info "Global anti-drift scan..."
echo ""

DRIFT_ERRORS=0

scan_drift() {
    local label_singular="$1"   # "skill"
    local label_plural="$2"     # "skills"
    local actual="$3"           # 54

    # TARGETED patterns = only contexts that talk about the TOTAL.
    # We avoid "15 work commands" (subset by domain), "22 Haiku agents" (by model), etc.
    # Cataloged "TOTAL" cases :
    #   1. `Label disponibles (N)`             -- e.g. `Skills disponibles (54)` (French canonical header)
    #   2. `## Label (N[ available|...])`      -- markdown heading, e.g. `## Skills (54)` or `## Skills (54 available)`
    #   3. `'N Label'` / `'N Sub-Agents'`      -- string literal in TS/TSX components
    #   4. `\*\*Label\*\* \| ... \| N \|`      -- table row with bold label cell, possibly multi-column
    #   5. `# N Label`                          -- top heading prefix
    # The label can be singular (Skill) or plural (Skills), Capitalized or ALLCAPS.
    # The form `Sub-Agents` is accepted for agent.
    local label_cap_singular label_cap_plural alt_form
    label_cap_singular="$(echo "${label_singular:0:1}" | tr '[:lower:]' '[:upper:]')${label_singular:1}"
    label_cap_plural="$(echo "${label_plural:0:1}" | tr '[:lower:]' '[:upper:]')${label_plural:1}"
    alt_form=""
    [[ "$label_singular" == "agent" ]] && alt_form="|Sub-Agents?|sub-agents?"

    # POSIX ERE only — `\s` and `\b` are GNU-only; replaced with `[[:space:]]`.
    # IMPORTANT: split into separate patterns instead of one big alternation.
    # BSD grep -E (macOS) does NOT treat `^` inside `(...|^pattern|...)` as a
    # line anchor — it's parsed as literal `^`. Splitting each pattern into
    # its own grep invocation avoids this entirely (each `^` is then at the
    # start of its own pattern, which BSD grep handles correctly).
    local lab="(${label_cap_singular}|${label_cap_plural}${alt_form})"
    local ws='[[:space:]]'

    # Each entry is a separate ERE pattern. The 5th uses `($|[^[:alnum:]_])`
    # in place of `\b` (word boundary) for portability.
    local patterns=(
        "${lab}${ws}+disponibles?${ws}+\(([0-9]+)\)"
        "^#{1,4}${ws}+${lab}${ws}+\(([0-9]+)[^)]*\)"
        "'([0-9]+)${ws}+${lab}'"
        "\|${ws}*\*\*${lab}\*\*${ws}*\|(${ws}*[^|]*\|){0,4}${ws}*([0-9]+)${ws}*\|"
        "^#{1,4}${ws}+([0-9]+)${ws}+${lab}($|[^[:alnum:]_])"
    )

    process_match() {
        local match="$1" pattern="$2"
        [[ -z "$match" ]] && return
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"

        # Skip the scanner itself
        [[ "$file_part" == *"validate-counts.sh"* ]] && return

        # Extract the number(s) from the matched portion of this line
        local nums
        nums=$(echo "$content" | grep -oiE "$pattern" | grep -oE '[0-9]+' | sort -u)
        for n in $nums; do
            [[ "$n" -le 5 ]] && continue
            if [[ "$n" != "$actual" ]]; then
                local rel="${file_part#"$SOCLE_DIR"/}"
                error_no_exit "${rel}:${line_num} drift -> $n ${label_plural} (canonical: $actual)"
                DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
            fi
        done
    }

    # Run one grep per pattern so each `^` anchor is independently honored.
    # De-duplicate via sort -u so the same line+number isn't reported twice.
    local seen_keys=""
    local pat
    for pat in "${patterns[@]}"; do
        while IFS= read -r match; do
            [[ -z "$match" ]] && continue
            # Dedup on file:line — across patterns, the same line might match more than one
            local file_part="${match%%:*}"
            local rest="${match#*:}"
            local line_num="${rest%%:*}"
            local key="$file_part:$line_num"
            case "$seen_keys" in
                *"|$key|"*) continue ;;
            esac
            seen_keys="${seen_keys}|$key|"
            process_match "$match" "$pat"
        done < <(
            grep -rniE "$pat" \
                --include="*.md" --include="*.ts" --include="*.tsx" --include="*.json" \
                --exclude-dir=node_modules --exclude-dir=.git \
                --exclude-dir=build --exclude-dir=.docusaurus \
                --exclude-dir=memory \
                --exclude="CHANGELOG.md" \
                "$SOCLE_DIR" 2>/dev/null
        )
    done
}

scan_drift "command" "commands" "$ACTUAL_COMMANDS"
scan_drift "agent" "agents" "$ACTUAL_AGENTS"
scan_drift "skill" "skills" "$ACTUAL_SKILLS"
scan_drift "rule" "rules" "$ACTUAL_RULES"

# -----------------------------------------------------------------------------
# Dedicated drift scan for test counters (specific patterns: README shields.io
# badge + "Test layout" section)
# -----------------------------------------------------------------------------
scan_tests_drift() {
    local actual_tests="$1"
    local actual_files="$2"

    # Pattern 1 : shields.io badge `tests-N+passing` or `tests-N%20passing`
    while IFS= read -r match; do
        [[ -z "$match" ]] && continue
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"
        [[ "$file_part" == *"validate-counts.sh"* ]] && continue
        local n
        n=$(echo "$content" | grep -oiE 'tests-[0-9]+' | grep -oE '[0-9]+' | head -1)
        if [[ -n "$n" ]] && [[ "$n" != "$actual_tests" ]]; then
            local rel="${file_part#"$SOCLE_DIR"/}"
            error_no_exit "${rel}:${line_num} drift -> tests-$n badge (canonical: $actual_tests)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
    done < <(
        grep -rniE 'tests-[0-9]+(%20|\+| )passing' \
            --include="*.md" --include="*.ts" --include="*.tsx" \
            --exclude-dir=node_modules --exclude-dir=.git \
            --exclude-dir=build --exclude-dir=.docusaurus \
            --exclude-dir=memory \
            --exclude="CHANGELOG.md" \
            "$SOCLE_DIR" 2>/dev/null
    )

    # Pattern 2 : `(N files, M tests)` captures both counters
    while IFS= read -r match; do
        [[ -z "$match" ]] && continue
        local file_part="${match%%:*}"
        local rest="${match#*:}"
        local line_num="${rest%%:*}"
        local content="${rest#*:}"
        [[ "$file_part" == *"validate-counts.sh"* ]] && continue
        local nf nt rel
        nf=$(echo "$content" | grep -oE '\([0-9]+ files?' | grep -oE '[0-9]+' | head -1)
        nt=$(echo "$content" | grep -oE '[0-9]+ tests\)' | grep -oE '[0-9]+' | head -1)
        rel="${file_part#"$SOCLE_DIR"/}"
        if [[ -n "$nf" ]] && [[ "$nf" != "$actual_files" ]]; then
            error_no_exit "${rel}:${line_num} drift -> $nf test files (canonical: $actual_files)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
        if [[ -n "$nt" ]] && [[ "$nt" != "$actual_tests" ]]; then
            error_no_exit "${rel}:${line_num} drift -> $nt tests (canonical: $actual_tests)"
            DRIFT_ERRORS=$((DRIFT_ERRORS + 1))
        fi
    done < <(
        grep -rnE '\([0-9]+ files?,[[:space:]]*[0-9]+ tests\)' \
            --include="*.md" --include="*.ts" --include="*.tsx" \
            --exclude-dir=node_modules --exclude-dir=.git \
            --exclude-dir=build --exclude-dir=.docusaurus \
            --exclude-dir=memory \
            --exclude="CHANGELOG.md" \
            "$SOCLE_DIR" 2>/dev/null
    )
}

scan_tests_drift "$ACTUAL_TESTS" "$ACTUAL_TEST_FILES"

if [[ "$DRIFT_ERRORS" -eq 0 ]]; then
    success "No drift detected (global scan)"
else
    error_no_exit "$DRIFT_ERRORS drift(s) detected (global scan)"
    ERRORS=$((ERRORS + DRIFT_ERRORS))
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

if [[ "$ERRORS" -eq 0 ]]; then
    success "All counters are consistent"
    exit 0
else
    error_no_exit "$ERRORS inconsistency(ies) found"
    if $SHOW_FIX; then
        echo ""
        info "To fix automatically, update the files above"
        info "or re-run the generation scripts:"
        echo "  cd $SOCLE_DIR/website && npm run generate:all"
    fi
    exit 1
fi
