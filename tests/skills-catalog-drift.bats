#!/usr/bin/env bats

# =============================================================================
# Drift guard: docs/reference/skills-catalog.md vs the real skill frontmatter.
#
# A skill carrying `disable-model-invocation: true` cannot be loaded by the
# model at all — not by auto-trigger, and not by a Skill call from inside a
# command either (measured: "cannot be used with Skill tool due to
# disable-model-invocation"). The catalogue's tables carry a trigger column, so
# listing trigger phrases for such a skill promises a behaviour the harness
# refuses. This guard pins the two together on the REAL catalogue.
# =============================================================================

load 'test_helper'

SKILLS_DIR="$BASE_DIR/.claude/skills"
CATALOG="$BASE_DIR/docs/reference/skills-catalog.md"

# _fm <file> — print the first frontmatter block (between the two first ---).
_fm() {
    awk '/^---$/{c++; if(c==2) exit; next} c==1 {print}' "$1"
}

# _manual_only — names of the model-disabled skills, one per line.
_manual_only() {
    local f
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        if _fm "$f" | grep -q '^disable-model-invocation:[[:space:]]*true'; then
            basename "$(dirname "$f")"
        fi
    done
}

# _row <name> — the catalogue table row for a skill, or empty.
_row() {
    grep -E '^\|[[:space:]]*`'"$1"'`[[:space:]]*\|' "$CATALOG" | head -1
}

@test "catalog: every model-disabled skill is marked manual in the catalogue" {
    local bad="" name row
    for name in $(_manual_only); do
        row=$(_row "$name")
        [ -n "$row" ] || continue          # not listed at all: nothing promised
        case "$row" in
            *manual*|*Manual*) ;;
            *) bad="$bad $name" ;;
        esac
    done
    if [ -n "$bad" ]; then
        echo "catalogue promises an automatic trigger for skills that cannot be" >&2
        echo "invoked by the model at all:$bad" >&2
        return 1
    fi
}

@test "catalog: an auto-triggerable skill is NOT marked manual" {
    # The converse drift: a row labelled manual while the skill can auto-trigger
    # would send a reader to type a command they never needed.
    local bad="" f name row
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        _fm "$f" | grep -q '^disable-model-invocation:[[:space:]]*true' && continue
        name=$(basename "$(dirname "$f")")
        row=$(_row "$name")
        [ -n "$row" ] || continue
        case "$row" in
            *"manual only"*|*"Manual only"*) bad="$bad $name" ;;
        esac
    done
    [ -z "$bad" ] || { echo "marked manual but model-invocable:$bad" >&2; return 1; }
}

@test "catalog: manual-only skills exist and are listed (guard is not vacuous)" {
    local name listed=0
    for name in $(_manual_only); do
        [ -n "$(_row "$name")" ] && listed=$((listed + 1))
    done
    [ "$listed" -gt 0 ]
}

@test "catalog: negative probe — an unmarked row IS caught" {
    setup_test_dir
    printf -- '| `probe` | "plan", "architecture" | fork |\n' > "$TEST_DIR/cat.md"
    run bash -c 'grep -E "^\|[[:space:]]*\`probe\`[[:space:]]*\|" "$1" | grep -qi manual' \
        _ "$TEST_DIR/cat.md"
    [ "$status" -ne 0 ]
    printf -- '| `probe` | **manual only** — run `/probe` | fork |\n' > "$TEST_DIR/cat.md"
    run bash -c 'grep -E "^\|[[:space:]]*\`probe\`[[:space:]]*\|" "$1" | grep -qi manual' \
        _ "$TEST_DIR/cat.md"
    [ "$status" -eq 0 ]
    teardown_test_dir
}
