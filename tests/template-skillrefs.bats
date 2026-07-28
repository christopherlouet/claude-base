#!/usr/bin/env bats

# =============================================================================
# Tests for the skill references shipped in templates/CLAUDE.*.md.
#
# Every installed project inherits its CLAUDE.md from one of these templates,
# so a skill name that no longer exists is not a cosmetic typo: it is a dead
# pointer handed to every new project, telling the model to invoke something
# that was renamed away.
#
# That is exactly what happened — `refactor(skills): harmonize skill names with
# command names` (2026-01-22) renamed the skills under .claude/skills/ and left
# the ten downstream templates citing the pre-rename names for six months. The
# 2026-07-11 truth pass swept a single one of them (`reviewing-code`), which is
# what a manual sweep buys you. This guard is the unguarded copy's guard.
# =============================================================================

load 'test_helper'

REPO_ROOT="$BATS_TEST_DIRNAME/.."

# skill_refs_in <template> — echo the skill names cited in the template's
# "## Available skills" table, one per line.
#
# Scoped to that section on purpose: templates carry other tables whose first
# column is also a backticked token (the neovim template's `nvim` command
# table), and a whole-file scan would report those as phantom skills.
# The heading casing is not uniform across templates ("Available skills" in
# four of them, "Available Skills" in the other six), so the match is
# case-insensitive: a case-sensitive scope silently skipped six templates and
# reported green on them.
skill_refs_in() {
    awk '
        tolower($0) ~ /^## available skills/ { in_section = 1; next }
        in_section && /^## / { in_section = 0 }
        in_section && /^\| `/ {
            if (match($0, /`[a-z0-9_-]+`/)) {
                token = substr($0, RSTART + 1, RLENGTH - 2)
                print token
            }
        }
    ' "$1"
}

@test "templates: every skill cited in the Available skills table exists" {
    local dead=""
    local template name

    for template in "$REPO_ROOT"/templates/CLAUDE.*.md; do
        while read -r name; do
            [[ -z "$name" ]] && continue
            if [[ ! -f "$REPO_ROOT/.claude/skills/$name/SKILL.md" ]]; then
                dead+="${template##*/}: $name"$'\n'
            fi
        done < <(skill_refs_in "$template")
    done

    if [[ -n "$dead" ]]; then
        printf 'Dead skill references in templates (no .claude/skills/<name>/SKILL.md):\n%s' "$dead" >&2
        return 1
    fi
}

@test "templates: the skills table is not silently empty" {
    # A zero-reference table would make the guard above vacuously green — the
    # classic way a reference check rots into a no-op.
    local template count
    for template in "$REPO_ROOT"/templates/CLAUDE.*.md; do
        grep -qi '^## available skills' "$template" || continue
        count=$(skill_refs_in "$template" | wc -l)
        [ "$count" -gt 0 ] || {
            printf 'Empty skills table in %s\n' "${template##*/}" >&2
            return 1
        }
    done
}

@test "authored docs: the pre-rename skill names are gone there too" {
    # The templates were not the rename's only unguarded copy: the hand-written
    # architecture page still taught two of the dead names as live triggers.
    # website/docs/{agents,commands,skills,rules} are generated mirrors and are
    # deliberately out of scope; intro/ and concepts/ are authored.
    local scan_paths=(
        "$REPO_ROOT/docs"
        "$REPO_ROOT/website/docs/intro"
        "$REPO_ROOT/website/docs/concepts"
        "$REPO_ROOT/.claude"
        "$REPO_ROOT/README.md"
        "$REPO_ROOT/CLAUDE.md"
    )
    local pattern='exploring-codebase|planning-implementation|test-driven-development|debugging-issues|generating-commit-messages|creating-pull-requests|reviewing-code'
    local hits

    # Lines carrying a URL are excluded: an external link may legitimately
    # contain one of these words (the O'Reilly TDD-by-Example URL does) and it
    # is not a skill reference.
    hits=$(grep -rnE "$pattern" "${scan_paths[@]}" 2>/dev/null | grep -v 'http' || true)

    if [[ -n "$hits" ]]; then
        printf 'Pre-rename skill names still cited in authored docs:\n%s\n' "$hits" >&2
        return 1
    fi
}

@test "templates: the pre-rename skill names are gone for good" {
    # Belt and braces: the six names the January rename orphaned must never
    # reappear anywhere in a template, table or prose.
    local legacy=(
        exploring-codebase
        planning-implementation
        test-driven-development
        debugging-issues
        generating-commit-messages
        creating-pull-requests
        reviewing-code
    )
    local name hits=""

    for name in "${legacy[@]}"; do
        if grep -rl -- "$name" "$REPO_ROOT"/templates/CLAUDE.*.md >/dev/null 2>&1; then
            hits+="$name: $(grep -rl -- "$name" "$REPO_ROOT"/templates/CLAUDE.*.md | xargs -n1 basename | tr '\n' ' ')"$'\n'
        fi
    done

    if [[ -n "$hits" ]]; then
        printf 'Pre-rename skill names still cited in templates:\n%s' "$hits" >&2
        return 1
    fi
}
