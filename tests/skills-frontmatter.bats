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
# So any file telling the model to use such a skill states an impossibility, and
# the pointer reads as working prose while doing nothing.
#
# Scope is the whole `.claude/` tree, not just commands: skills point at each
# other too. The pattern is the IMPERATIVE form ("Use the `x` skill") and only
# that, because a catalogue row or a "see also" line naming a manual-only skill
# is correct prose — a guard that accused it would be a bug in the guard.
# -----------------------------------------------------------------------------

CLAUDE_DIR="$BASE_DIR/.claude"

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

# _scanned_files — every markdown file the guard inspects.
_scanned_files() {
    find "$CLAUDE_DIR" -name '*.md' 2>/dev/null
}

# _dead_pointers — print "file -> skill" for each imperative pointer at a
# manual-only skill. The backticks are load-bearing: they stop `ops-ci` from
# matching `ops-ci-fix`.
_dead_pointers() {
    local name f
    for name in $(_manual_only_skills); do
        for f in $(_scanned_files); do
            if grep -qE 'Use the `'"$name"'` skill' "$f"; then
                echo "${f#"$BASE_DIR/"} -> $name"
            fi
        done
    done
}

@test "claude tree: nothing tells the model to use a manual-only skill" {
    local dead
    dead=$(_dead_pointers)
    if [ -n "$dead" ]; then
        echo "files instructing the model to use a skill it cannot invoke:" >&2
        echo "$dead" >&2
        return 1
    fi
}

@test "claude tree: the scan is not vacuous (both halves have subjects)" {
    # Without this, the guard above passes by scanning nothing — proven: pointing
    # it at a missing directory left every case green.
    local files
    [ -n "$(_manual_only_skills)" ]
    files=$(_scanned_files | wc -l)
    [ "$files" -gt 50 ]
}

@test "claude tree: negative probe — the real helper catches a dead pointer" {
    setup_test_dir
    mkdir -p "$TEST_DIR/skills/probe" "$TEST_DIR/commands"
    printf -- '---\nname: probe\ndescription: x\ncontext: fork\nbackground: false\ndisable-model-invocation: true\n---\nbody\n' \
        > "$TEST_DIR/skills/probe/SKILL.md"
    printf -- '# Probe\n\nUse the `probe` skill for the detailed methodology.\n' \
        > "$TEST_DIR/commands/probe.md"
    # a descriptive mention and a substring near-miss must NOT be flagged
    printf -- '# Other\n\n| `probe` skill | see also |\nUse the `probe-extra` skill here.\n' \
        > "$TEST_DIR/commands/other.md"

    # drive the REAL helpers by repointing their inputs at the fixture tree
    SKILLS_DIR="$TEST_DIR/skills" CLAUDE_DIR="$TEST_DIR" run _dead_pointers
    [ "$status" -eq 0 ]
    [[ "$output" == *"probe.md -> probe"* ]]
    [[ "$output" != *"other.md"* ]]
    teardown_test_dir
}

# =============================================================================
# allowed-tools GRANTS, it does not restrict (measured 2026-09-25)
# =============================================================================
# A skill's allowed-tools pre-approves the listed tools for its turn. Measured:
# with `allowed-tools: Bash`, a command that otherwise needs approval ran
# unprompted; a deny rule still won. Forty skills listed bare Bash, so a user
# who removed Bash from their own allow list got it back, silently, for every
# skill turn — and a copied skill carried a whole shell grant with it.
#
# The same holds for every other tool (2026-09-26): 38 skills granted bare
# Write, 37 bare Edit, one WebFetch, one WebSearch, and all 53 bare Read.
#
# Be exact about what that bought. The foundation's shipped settings.json
# ALREADY allows Read, Bash, Edit, Write, WebFetch and WebSearch on every turn (a
# v1.9.0 choice; deny rules and hooks are the safety net), so in an installed
# project these grants added nothing. They mattered in a project that narrowed
# its allow list, and in a skill copied elsewhere — where they silently widened
# what runs unprompted. Even bare Read: in the project a read needs no prompt,
# so the grant only ever mattered OUTSIDE it (~/.ssh, ~/.aws).
#
# Two independent reviews broke two scanners that tried to tell a safe grant
# from a dangerous one (a list of dangerous names missed PowerShell, Monitor and
# mcp__*; "real scopes" passed Edit(~/**), Bash(bash:*), WebFetch(domain:*.com);
# a YAML comment, a quoted key or a BOM hid the grant from both). So a
# foundation skill or command declares NO allowed-tools — nothing to parse,
# and no exception list either: the one drafted here was never used and two
# shapes (a block list, a YAML continuation line) slipped past it. A real
# need later gets its own reviewed design.
# Out of scope, like every guard here: a key spelled with YAML escapes
# ("allowed\x2dtools") is deliberate obfuscation, not an accident.
# _grant_decls <file>... — print "<file><TAB><line>" for each frontmatter line
# whose KEY is allowed-tools in any accidental spelling (quoted, spaced before
# the colon, any case, `_` for `-`, after a BOM). A top-level key only:
# disallowedTools, a nested key or a description mentioning it is not a grant.
_grant_decls() {
    awk 'FNR == 1 { fm = 0; sub(/^\357\273\277/, "") }
         fm == 0 && FNR == 1 && /^---[[:space:]]*$/ { fm = 1; next }
         fm == 1 && /^---[[:space:]]*$/ { fm = 2; next }
         fm == 1 && tolower($0) ~ /^["\047]?allowed[-_ ]?tools[[:space:]"\047]*:/ {
             print FILENAME "\t" $0 }' "$@"
}

@test "skills & commands: none pre-approves tools through allowed-tools" {
    local files=( "$BASE_DIR"/.claude/skills/*/SKILL.md ) f out
    while IFS= read -r -d '' f; do files+=( "$f" ); done \
        < <(find "$BASE_DIR/.claude/commands" -name '*.md' -print0)
    [ "${#files[@]}" -gt 100 ] || { echo "scan set too small: ${#files[@]}" >&2; return 1; }
    out=$(_grant_decls "${files[@]}")
    [ -z "$out" ] || { echo "declares allowed-tools: $out" >&2; return 1; }
}

@test "skills & commands: the allowed-tools scanner is not vacuous" {
    local d="$BATS_TEST_TMPDIR" f
    # Each shape an independent review slipped past a parsing scanner.
    printf -- '---\nname: a\nallowed-tools:\n  - Read\n---\n' > "$d/plain.md"
    printf -- '---\nname: a\nallowed-tools: [Read, Write]\n---\n' > "$d/inline.md"
    printf -- '---\nname: a\n"allowed-tools": [Write]\n---\n' > "$d/quoted.md"
    printf -- '---\nname: a\nallowed-tools : [Write]\n---\n' > "$d/spaced.md"
    printf -- '\357\273\277---\nname: a\nallowed-tools: [Write]\n---\n' > "$d/bom.md"
    printf -- '---\nname: a\nAllowed_Tools: [Write]\n---\n' > "$d/case.md"
    for f in "$d"/*.md; do
        [ "$(_grant_decls "$f" | cut -f1)" = "$f" ] || { echo "not flagged: $f" >&2; return 1; }
    done
}

@test "skills & commands: only an allowed-tools KEY in the frontmatter counts" {
    local d="$BATS_TEST_TMPDIR"
    printf -- '---\nname: a\ndescription: x\n---\nNever declare allowed-tools here.\n' > "$d/body.md"
    printf -- 'no frontmatter\nallowed-tools: [Write]\n' > "$d/nofm.md"
    # The review of the first version: a restriction and a mention were flagged.
    printf -- '---\nname: a\ndisallowedTools: Write\n---\n' > "$d/disallowed.md"
    printf -- '---\nname: a\ndescription: never use allowed-tools: it grants\n---\n' > "$d/descr.md"
    # A first line that merely ENDS in --- opens no frontmatter; a nested key is no grant.
    printf -- 'Notes ---\nallowed-tools: [Write]\n' > "$d/notfm.md"
    printf -- '---\nname: a\nmetadata:\n  allowed-tools: x\n---\n' > "$d/nested.md"
    [ -z "$(_grant_decls "$d/body.md" "$d/nofm.md" "$d/disallowed.md" "$d/descr.md" "$d/notfm.md" "$d/nested.md")" ]
}

# -----------------------------------------------------------------------------
# Agents: a `skills:` preload of a manual-only skill loads NOTHING (2026-09-25)
# -----------------------------------------------------------------------------
# The skills doc: disable-model-invocation "also prevents the skill from being
# preloaded into subagents". Measured: the qa-chrome agent preloads qa-chrome
# (manual-only) and qa-design; in its subagent context qa-design's body was
# present and qa-chrome's absent. Three agents carried such a preload, silently
# empty since 2026-01-30 — the same dead pointer as above, in frontmatter.

# _agent_preloads <agent.md> — print "agent skill" for each `skills:` entry.
_agent_preloads() {
    awk 'FNR == 1 { fm = 0; inlist = 0; a = FILENAME; sub(/.*\//, "", a); sub(/\.md$/, "", a) }
         /^---[[:space:]]*$/ { fm++; inlist = 0; next }
         fm != 1 { next }
         /^skills:/ {
             inlist = 1; line = $0; sub(/^skills:[[:space:]]*/, "", line)
             gsub(/[][,"\047]/, " ", line); n = split(line, p, /[ \t]+/)
             for (i = 1; i <= n; i++) if (p[i] != "") print a, p[i]
             next
         }
         inlist && /^[[:space:]]*$/ { next }
         inlist && /^[[:space:]]*-/ { s = $0; sub(/^[[:space:]]*-[[:space:]]*/, "", s); sub(/[[:space:]]*#.*$/, "", s); gsub(/["\047[:space:]]/, "", s); print a, s; next }
         inlist { inlist = 0 }' "$@"
}

@test "agents: no agent preloads a manual-only or missing skill (it would load nothing)" {
    # A missing name (typo, deleted skill) is the same silent nothing: the
    # sub-agents doc says Claude Code skips it with a debug-log warning only.
    local manual dead=""
    manual=" $(_manual_only_skills | tr '\n' ' ') "
    while read -r agent skill; do
        [ -n "$skill" ] || continue
        case "$manual" in *" $skill "*) dead="$dead $agent->$skill(manual-only)" ;; esac
        [ -f "$SKILLS_DIR/$skill/SKILL.md" ] || dead="$dead $agent->$skill(missing)"
    done < <(_agent_preloads "$CLAUDE_DIR"/agents/*.md)
    [ -z "$dead" ] || { echo "dead preloads:$dead" >&2; return 1; }
}

@test "agents: the preload scanner is not vacuous" {
    run _agent_preloads "$CLAUDE_DIR"/agents/*.md
    [ -n "$output" ]
    local d="$BATS_TEST_TMPDIR"
    printf -- '---\nname: x\nskills:\n  - alpha\n  - "beta"   # note\n\n  - epsilon\n---\nskills:\n  - body\n' > "$d/x.md"
    printf -- '---\nname: y\nskills: [gamma, delta]\n---\n' > "$d/y.md"
    run _agent_preloads "$d/x.md" "$d/y.md"
    [[ "$output" == *"x alpha"* ]]
    [[ "$output" == *"x beta"* ]]
    [[ "$output" != *"#"* ]]                 # a trailing comment is not part of the name
    [[ "$output" == *"x epsilon"* ]]         # a blank line does not end the list
    [[ "$output" == *"y gamma"* ]]
    [[ "$output" == *"y delta"* ]]
    [[ "$output" != *"body"* ]]
}
