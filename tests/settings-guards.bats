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
