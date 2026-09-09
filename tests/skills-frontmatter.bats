#!/usr/bin/env bats

# =============================================================================
# Frontmatter drift guards for .claude/skills/*/SKILL.md.
#
# Since Claude Code 2.1.218, a skill with `context: fork` runs its forked
# subagent in the BACKGROUND by default: the result arrives asynchronously,
# the subagent gets the narrower background tool set, and its edits bypass
# /rewind checkpoints. The foundation's skills are workflow skills that must
# guide the CURRENT conversation, so every fork skill must opt out explicitly
# with `background: false` (or a deliberate, documented `background: true`).
# Self-application: these tests run on the real catalog, no fixtures.
# =============================================================================

load 'test_helper'

SKILLS_DIR="$BASE_DIR/.claude/skills"

# _fm <file> — print the first frontmatter block (between the two first ---).
_fm() {
    awk '/^---$/{c++; if(c==2) exit; next} c==1 {print}' "$1"
}

@test "skills: every context:fork skill declares background explicitly" {
    local missing="" f
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        if _fm "$f" | grep -q '^context: fork' && ! _fm "$f" | grep -q '^background:'; then
            missing="$missing $(basename "$(dirname "$f")")"
        fi
    done
    if [ -n "$missing" ]; then
        echo "fork skills relying on the CC 2.1.218 background default:$missing" >&2
        return 1
    fi
}

@test "skills: background values are valid booleans" {
    local bad="" f val
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        val=$(_fm "$f" | sed -n 's/^background:[[:space:]]*//p' | sed 's/[[:space:]]*#.*$//' | head -1)
        [ -z "$val" ] && continue
        case "$val" in
            true|false|yes|no|on|off|1|0) ;;
            *) bad="$bad $(basename "$(dirname "$f")")=$val" ;;
        esac
    done
    [ -z "$bad" ] || { echo "invalid background values:$bad" >&2; return 1; }
}

@test "skills: background without context:fork is flagged (dead field)" {
    local orphan="" f
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        if _fm "$f" | grep -q '^background:' && ! _fm "$f" | grep -q '^context: fork'; then
            orphan="$orphan $(basename "$(dirname "$f")")"
        fi
    done
    [ -z "$orphan" ] || { echo "background: without context: fork (no effect):$orphan" >&2; return 1; }
}

@test "skills: negative probe — a fork skill without background IS caught" {
    setup_test_dir
    mkdir -p "$TEST_DIR/skills/probe"
    printf -- '---\nname: probe\ndescription: x\ncontext: fork\n---\nbody\n' \
        > "$TEST_DIR/skills/probe/SKILL.md"
    run bash -c '
        f="$1"
        awk "/^---\$/{c++; if(c==2) exit; next} c==1 {print}" "$f" | grep -q "^context: fork" \
        && ! awk "/^---\$/{c++; if(c==2) exit; next} c==1 {print}" "$f" | grep -q "^background:"
    ' _ "$TEST_DIR/skills/probe/SKILL.md"
    [ "$status" -eq 0 ]
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# A skill carrying `disable-model-invocation: true` cannot be loaded by the model
# at all — not by auto-trigger, and not by a Skill call made from inside a
# command either. Measured, not assumed: invoking one returns
# "cannot be used with Skill tool due to disable-model-invocation".
# So a command telling the model to use such a skill states an impossibility,
# and the pointer reads as working prose while doing nothing.
# -----------------------------------------------------------------------------

COMMANDS_DIR="$BASE_DIR/.claude/commands"

# _manual_only_skills — print the name of every model-disabled skill.
_manual_only_skills() {
    local f
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        [ -f "$f" ] || continue
        if _fm "$f" | grep -q '^disable-model-invocation:[[:space:]]*true'; then
            basename "$(dirname "$f")"
        fi
    done
}

# _dead_pointers <skills-dir> <commands-dir> — print "command -> skill" for each
# command instructing the model to use a manual-only skill. The backticks in the
# pattern are load-bearing: they stop `ops-ci` from matching `ops-ci-fix`.
_dead_pointers() {
    local name f
    for name in $(_manual_only_skills); do
        for f in $(find "$COMMANDS_DIR" -name '*.md' 2>/dev/null); do
            if grep -qE '(`'"$name"'` skill|skill `'"$name"'`)' "$f"; then
                echo "$(basename "$f") -> $name"
            fi
        done
    done
}

@test "commands: none tells the model to use a manual-only skill" {
    local dead
    dead=$(_dead_pointers)
    if [ -n "$dead" ]; then
        echo "commands pointing at a skill the model cannot invoke:" >&2
        echo "$dead" >&2
        return 1
    fi
}

@test "commands: manual-only skills exist (the guard has something to check)" {
    # Without this, the guard above passes vacuously the day the flag disappears.
    [ -n "$(_manual_only_skills)" ]
}

@test "commands: negative probe — a dead pointer IS caught" {
    setup_test_dir
    mkdir -p "$TEST_DIR/skills/probe" "$TEST_DIR/commands"
    printf -- '---\nname: probe\ndescription: x\ncontext: fork\nbackground: false\ndisable-model-invocation: true\n---\nbody\n' \
        > "$TEST_DIR/skills/probe/SKILL.md"
    printf -- '# Probe\n\nUse the `probe` skill for the detailed methodology.\n' \
        > "$TEST_DIR/commands/probe.md"
    run bash -c 'grep -qE "(\`probe\` skill|skill \`probe\`)" "$1"' _ "$TEST_DIR/commands/probe.md"
    [ "$status" -eq 0 ]
    # and the substring trap: `probe-extra` must NOT match the `probe` pattern
    printf -- '# Other\n\nUse the `probe-extra` skill for the detailed methodology.\n' \
        > "$TEST_DIR/commands/other.md"
    run bash -c 'grep -qE "(\`probe\` skill|skill \`probe\`)" "$1"' _ "$TEST_DIR/commands/other.md"
    [ "$status" -ne 0 ]
    teardown_test_dir
}
