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
