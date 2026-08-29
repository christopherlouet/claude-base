#!/usr/bin/env bats

# =============================================================================
# Frontmatter drift guards for .claude/rules/*.md — the CARRIED set.
#
# A rule with a `paths:` frontmatter is conditional; one without is global and
# reaches every session before a single line of the repository is read. That
# cost is invisible: nothing fails, nothing warns, the session is simply heavier
# for everyone forever. Measured 2026-08-29 — the five global files were 19 803
# of the 35 162 bytes carried, and the largest of them was not a rule at all but
# the catalogue describing them, global only because a catalogue never got a
# scope (specs/guardrail-cleanup/carried-material.md).
#
# So the carried set is pinned as an explicit list: making a rule global stays
# possible and takes one line here, which is the deliberation the cost deserves.
# Self-application: these run on the real rules directory, no fixtures.
# =============================================================================

load 'test_helper'

RULES_DIR="$BASE_DIR/.claude/rules"

# _has_paths <file> — 0 if the file declares a paths: scope in its frontmatter.
#
# Anchored to the FIRST line on purpose. The first version of this helper looked
# for the first two `---` lines anywhere, and `.claude/rules/README.md` ends with
# a fenced example OF a frontmatter block — so the reader found `paths:` in the
# documentation and answered yes for a file that had none. It passed the mutation
# that removes the real frontmatter, which is the exact regression it exists to
# catch. A document SHOWING a construct is not a document USING it — the third
# time that same confusion surfaced in one day.
_has_paths() {
    [ "$(head -1 "$1")" = "---" ] || return 1
    awk 'NR==1 { next } /^---$/ { exit } { print }' "$1" | grep -q '^paths:'
}

# The rules that are global ON PURPOSE: each one applies to every file type, and
# each states behaviour rather than describing an inventory. Adding a name here
# adds its bytes to every session — say why in the pull request.
GLOBAL_BY_DESIGN="git self-improvement vendor-precedence workflow"

@test "rules: the globally-carried set is exactly the intended one" {
    local unexpected="" f name
    for f in "$RULES_DIR"/*.md; do
        name="$(basename "$f" .md)"
        _has_paths "$f" && continue
        case " $GLOBAL_BY_DESIGN " in
            *" $name "*) continue ;;
        esac
        unexpected="$unexpected $name"
    done
    [ -z "$unexpected" ] || {
        echo "carried by every session without being intended:$unexpected" >&2
        echo "give it a paths: scope, or add it to GLOBAL_BY_DESIGN and say why" >&2
        false
    }
}

@test "rules: every rule intended to be global really is" {
    # The other direction: a paths: scope added to an intentionally global rule
    # silently narrows it, and nothing else would notice.
    #
    # Offenders are collected and asserted at the END rather than negated in the
    # loop: `! cmd` is exempt from `set -e`, so a `! _has_paths` inside the loop
    # cannot fail the case. The first version did exactly that, and the mutation
    # that scopes a global rule was caught only by the control below — by
    # accident, because a control happened to be the last command in its body.
    local narrowed="" missing="" f name
    for name in $GLOBAL_BY_DESIGN; do
        f="$RULES_DIR/$name.md"
        if [ ! -f "$f" ]; then missing="$missing $name"; continue; fi
        if _has_paths "$f"; then narrowed="$narrowed $name"; fi
    done
    [ -z "$missing" ] || { echo "declared global but absent:$missing" >&2; false; }
    [ -z "$narrowed" ] || { echo "declared global but scoped:$narrowed" >&2; false; }
}

@test "rules: the catalogue is scoped, not carried" {
    # README.md is an index of the 32 rules, not a rule. The rules it lists are
    # activated by the harness on their own, so a session does not need the index
    # to receive them — it is worth having when someone works ON the rules.
    _has_paths "$RULES_DIR/README.md"
}

@test "CONTROL: the frontmatter reader finds a scope where one exists" {
    # Without this the three cases above could all pass on a reader that never
    # finds anything: two of them assert absence.
    _has_paths "$RULES_DIR/typescript.md"
}

@test "CONTROL: the frontmatter reader reports absence where there is none" {
    # And the mirror: a reader that answers yes to everything would pass the
    # catalogue case while proving nothing. A different file from the ones the
    # cases above assert on, so a mutation is attributed to one arm only.
    ! _has_paths "$RULES_DIR/workflow.md"
}

@test "CONTROL: the enumeration is not vacuous" {
    # A glob that matched nothing would make the first case pass with an empty
    # loop. The foundation ships far more than a handful of rules.
    local n
    n=$(find "$RULES_DIR" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d '[:space:]')
    [ "$n" -gt 20 ]
}
