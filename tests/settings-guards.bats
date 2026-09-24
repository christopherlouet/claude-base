#!/usr/bin/env bats

# =============================================================================
# Drift guards for .claude/settings.json's guard wiring (pass-3 audit).
#
# 1. Matcher family: every PreToolUse file-mutation guard must use the SAME
#    matcher, including NotebookEdit — the tool was enabled in permissions
#    while main-branch-guard covered only Edit|Write and its siblings only
#    +MultiEdit, so a NotebookEdit on main did not auto-branch and a secret
#    written into an .ipynb cell was never scanned. (Matchers are anchored
#    regexes: "Edit|Write" does NOT substring-match NotebookEdit.)
# 2. permissions.allow must not carry dead tool names (TodoRead, AskFollowup
#    — the real tools are TodoWrite and AskUserQuestion).
# 3. The pre-push CI gate must be the tested script, not an inline bash -c
#    (the inline form was the last big untested guard and fired on payloads).
# =============================================================================

load 'test_helper'

SETTINGS="$BASE_DIR/.claude/settings.json"

setup() { skip_if_no_jq; }

GUARD_MATCHER='Edit|Write|MultiEdit|NotebookEdit'

@test "settings: every PreToolUse file-mutation guard uses the canonical matcher" {
    # substance-check is NOT in this family: it is a PostToolUse advisory hook
    # (own pin below) — listing it here made the assertion dead for that name.
    run jq -r --arg want "$GUARD_MATCHER" '
        .hooks.PreToolUse[]
        | select(.hooks[]?.command | test("main-branch-guard|secret-scan|config-protection|destructive-migration"))
        | select(.matcher != $want)
        | .description' "$SETTINGS"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "settings: substance-check is a PostToolUse advisory on Edit|Write|MultiEdit" {
    # Intentionally NO NotebookEdit: the hook reads .tool_input.file_path only,
    # so a NotebookEdit matcher entry would be a dead trigger. This pins both
    # the event (PostToolUse, non-blocking) and the matcher.
    run jq -r '.hooks.PostToolUse[]
        | select(.hooks[]?.command | test("substance-check"))
        | .matcher' "$SETTINGS"
    [ "$status" -eq 0 ]
    [ "$output" = "Edit|Write|MultiEdit" ]
}

@test "settings: base-integrity PostToolUse matcher still covers NotebookEdit" {
    run jq -r '.hooks.PostToolUse[]
        | select(.hooks[]?.command | test("base-integrity-check"))
        | .matcher' "$SETTINGS"
    [[ "$output" == *"NotebookEdit"* ]]
}

@test "settings: permissions.allow carries no dead tool names" {
    run jq -r '.permissions.allow[] | select(. == "TodoRead" or . == "AskFollowup")' "$SETTINGS"
    [ -z "$output" ]
}

@test "settings: the pre-push CI gate is the tested script, not inline bash" {
    run jq -r '.hooks.PreToolUse[]
        | select(.description | test("pre-push CI|Check local CI"; "i"))
        | .hooks[0].command' "$SETTINGS"
    [[ "$output" == *"pre-push-ci.sh"* ]]
    [[ "$output" != *"grep -q"* ]]
}

# =============================================================================
# permissions.deny — rules that cannot match anything (Phase 3, 2026-09-01)
#
# Measured on this repository: the platform's Bash deny matcher is
# token-boundary aware. `rm -rf node_modules` is refused; `rm -rf /tmp/<probe>`
# is not, though the list carries `Bash(rm -rf /:*)`. Same binary, same flags —
# the rule's text ends inside a token the real command continues.
#
# Two shapes follow from that law and can never refuse anything:
#   - a rule whose text ends with `=` (`dd if=`) — the value continues the token;
#     measured: `dd if=/dev/null of=/dev/null count=0` ran unrefused.
#   - a rule whose text begins with a redirection (`> /dev/sda`) — a command's
#     first token is a program, never an operator.
#
# A rule that cannot fire is worse than an absent one: it reads as coverage.
# That class is covered by command-validator.sh instead, demonstrated —
# `dd if=/dev/zero of=/dev/sda` and `mkfs.ext4 /dev/sda1` are both refused by
# the hook. See specs/guardrail-cleanup/native-coverage.md.
#
# These pin the SHAPE, not the list: a new rule of either shape fails here.
# =============================================================================

# The command text a Bash deny rule matches on: "Bash(dd if=:*)" -> "dd if=".
DENY_FILTER='.permissions.deny[]
    | select(startswith("Bash("))
    | ltrimstr("Bash(") | rtrimstr(")") | rtrimstr(":*")'

@test "settings: no deny rule ends mid-token on '=' (it could never match)" {
    run jq -r "$DENY_FILTER | select(endswith(\"=\"))" "$SETTINGS"
    [ "$status" -eq 0 ]
    [ -z "$output" ] || {
        echo "deny rules ending on '=' can never match: $output" >&2
        false
    }
}

@test "settings: no deny rule starts with a redirection (never in command position)" {
    run jq -r "$DENY_FILTER | select(test(\"^[<>]\"))" "$SETTINGS"
    [ "$status" -eq 0 ]
    [ -z "$output" ] || {
        echo "deny rules starting with a redirection can never match: $output" >&2
        false
    }
}

@test "settings: the deny scanner is not vacuous — it flags both planted shapes" {
    # Without this the two cases above would pass on an empty list, on a
    # missing key, or on a filter that silently matches nothing.
    local fixture="$BATS_TEST_TMPDIR/planted-settings.json"
    printf '%s\n' \
        '{"permissions":{"deny":["Bash(sudo:*)","Bash(dd if=:*)","Bash(> /dev/sda:*)"]}}' \
        > "$fixture"

    run jq -r "$DENY_FILTER | select(endswith(\"=\"))" "$fixture"
    [ "$output" = "dd if=" ]

    run jq -r "$DENY_FILTER | select(test(\"^[<>]\"))" "$fixture"
    [ "$output" = "> /dev/sda" ]

    # And the healthy rule beside them is flagged by neither.
    run jq -r "$DENY_FILTER | select(endswith(\"=\") or test(\"^[<>]\"))" "$fixture"
    [[ "$output" != *"sudo"* ]]
}

@test "settings: the deny list still carries the rules measured to fire" {
    # chmod 777 and eval were each observed refusing a real, harmless tool call.
    # They are the evidence that this layer refuses at all, so a removal here
    # would take the instrument with it.
    run jq -r "$DENY_FILTER" "$SETTINGS"
    [[ "$output" == *"chmod 777"* ]]
    [[ "$output" == *"eval"* ]]
}

# -----------------------------------------------------------------------------
# Fable sub-agents — a deliberate choice, never a silent one (2026-09-24)
# -----------------------------------------------------------------------------
# The foundation pins no agent to Fable, by cost (docs/reference/best-practices.md),
# yet Fable stays a "rare, deliberate" option — so the rule is `ask`, not `deny`:
# a deny outranks every approval and would forbid the deliberate case too.
# Claude Code 2.1.178 matches tool parameters with `Tool(param:value)`.
FABLE_RULE='Agent(model:fable)'

@test "settings: a sub-agent explicitly launched on Fable asks first" {
    run jq -r --arg r "$FABLE_RULE" '(.permissions.ask // []) | index($r) != null' "$SETTINGS"
    [ "$output" = "true" ]
}

@test "settings: the Fable rule is neither denied nor pre-allowed" {
    # deny would outrank the ask (no deliberate case left); allow would skip it.
    run jq -r --arg r "$FABLE_RULE" \
        '[(.permissions.deny // []), (.permissions.allow // [])] | flatten | index($r) == null' "$SETTINGS"
    [ "$output" = "true" ]
}

# _fable_pins <file>... — print each file whose FRONTMATTER (between the first
# two `---` lines, never the body) sets `model:` to a Fable tier: `fable`,
# `best` (resolves to Fable in Claude apps gateway sessions) or a full
# `claude-fable-*` id, bare or quoted either way.
_fable_pins() {
    awk 'FNR == 1 { fm = 0 }
         /^---[[:space:]]*$/ { fm++; next }
         fm == 1 && tolower($0) ~ /^model:[[:space:]]*["\047]?(fable|best|claude-fable)/ { print FILENAME; nextfile }' "$@"
}

@test "agents/skills: no frontmatter pins Fable (it would bypass the ask rule)" {
    # The rule sees the Agent tool's `model` parameter only; a frontmatter pin
    # never reaches it (measured: a `model: fable` agent ran on Fable unasked),
    # and a forked skill's `model:` is the same kind of pin.
    run _fable_pins "$BASE_DIR"/.claude/agents/*.md "$BASE_DIR"/.claude/skills/*/SKILL.md
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "agents/skills: the Fable-pin scanner is not vacuous" {
    local d="$BATS_TEST_TMPDIR"
    printf -- '---\nname: a\nmodel: fable\n---\n' > "$d/a.md"
    printf -- "---\nname: b\nmodel: 'claude-fable-5-1'\n---\n" > "$d/b.md"
    printf -- '---\nname: c\nmodel: "Best"  \n---\n' > "$d/c.md"
    printf -- '---\nname: d\nmodel: sonnet\n---\nmodel: fable\n' > "$d/d.md"
    run _fable_pins "$d/a.md" "$d/b.md" "$d/c.md" "$d/d.md"
    [ "$status" -eq 0 ]
    [[ "$output" == *"a.md"* ]]
    [[ "$output" == *"b.md"* ]]
    [[ "$output" == *"c.md"* ]]
    # A body line is an example, not a pin.
    [[ "$output" != *"d.md"* ]]
}

# -----------------------------------------------------------------------------
# Hook timeouts are SECONDS, and a timed-out PreToolUse guard FAILS OPEN
# -----------------------------------------------------------------------------
# Measured 2026-09-25 (Claude Code 2.1.281, fresh headless sessions): a hook
# `sleep 1` with timeout 3 completed and `sleep 4` with timeout 2 was cut, so the
# unit is the second; every value here had been written in milliseconds (2000 =
# 33 min, 180000 = 50 h), bounding nothing. And a PreToolUse guard that would
# have blocked (exit 2) but outlived its timeout let the command RUN. So a
# budget too tight on a guard is a silent bypass, not a safety margin.
TIMEOUTS_FILTER='.hooks | to_entries[] | .key as $e | .value[] | .hooks[] | {e:$e, t:(.timeout // 0), c:(.command // "")}'

@test "settings: no hook timeout is millisecond-sized (the unit is seconds)" {
    run jq -r "$TIMEOUTS_FILTER | select(.t > 3600) | \"\(.e) \(.t) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "timeouts above 1 h (written in ms?): $output" >&2; return 1; }
}

@test "settings: every blocking PreToolUse guard has at least 30 s (a timeout fails open)" {
    run jq -r "$TIMEOUTS_FILTER | select(.e == \"PreToolUse\" and (.c | test(\"scripts/hooks/\"))) | select(.t < 30) | \"\(.t) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "guards that would fail open under load: $output" >&2; return 1; }
}

@test "settings: the timeout guards are not vacuous — they flag both planted shapes" {
    local fixture="$BATS_TEST_TMPDIR/s.json"
    printf '%s' '{"hooks":{"PreToolUse":[{"hooks":[{"command":"bash scripts/hooks/x.sh","timeout":5}]}],"Stop":[{"hooks":[{"command":"y","timeout":5000}]}]}}' > "$fixture"
    run jq -r "$TIMEOUTS_FILTER | select(.t > 3600) | .c" "$fixture"
    [ "$output" = "y" ]
    run jq -r "$TIMEOUTS_FILTER | select(.e == \"PreToolUse\" and (.c | test(\"scripts/hooks/\"))) | select(.t < 30) | .c" "$fixture"
    [ "$output" = "bash scripts/hooks/x.sh" ]
}

@test "settings: no hook carries onFailure (not a Claude Code field; measured inert)" {
    # 26 hooks carried "onFailure": "block"/"ignore" and five docs taught it as
    # what makes a guard block. Measured 2026-09-25: a timed-out guard with
    # onFailure "block" let the command run exactly like one without it.
    run jq -r '[.. | objects | select(has("onFailure"))] | length' "$SETTINGS"
    [ "$output" = "0" ]
}
