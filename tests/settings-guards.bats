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
# Hook timeouts are SECONDS, and a timed-out PreToolUse guard fails OPEN by default
# -----------------------------------------------------------------------------
# Measured 2026-09-25 (Claude Code 2.1.281, fresh headless sessions): a hook
# `sleep 1` with timeout 3 completed and `sleep 4` with timeout 2 was cut, so the
# unit is the second; every value here had been written in milliseconds (2000 =
# 33 min, 180000 = 50 h), bounding nothing. And a PreToolUse guard that would
# have blocked (exit 2) but outlived its timeout let the command RUN. So a
# budget too tight on a guard is a silent bypass, not a safety margin. Under
# onFailure "block" (below) it is the opposite failure, a refused legitimate
# call, so the floor stays either way.
TIMEOUTS_FILTER='.hooks | to_entries[] | .key as $e | .value[] | .hooks[] | {e:$e, t:(.timeout // 0), c:(.command // "")}'

@test "settings: no hook timeout is millisecond-sized (the unit is seconds)" {
    run jq -r "$TIMEOUTS_FILTER | select(.t > 3600) | \"\(.e) \(.t) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "timeouts above 1 h (written in ms?): $output" >&2; return 1; }
}

@test "settings: every blocking PreToolUse guard has at least 30 s (a cut guard misjudges the call)" {
    run jq -r "$TIMEOUTS_FILTER | select(.e == \"PreToolUse\" and (.c | test(\"scripts/hooks/\"))) | select(.t < 30) | \"\(.t) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "guards that would be cut under load: $output" >&2; return 1; }
}

@test "settings: the timeout guards are not vacuous — they flag both planted shapes" {
    local fixture="$BATS_TEST_TMPDIR/s.json"
    printf '%s' '{"hooks":{"PreToolUse":[{"hooks":[{"command":"bash scripts/hooks/x.sh","timeout":5}]}],"Stop":[{"hooks":[{"command":"y","timeout":5000}]}]}}' > "$fixture"
    run jq -r "$TIMEOUTS_FILTER | select(.t > 3600) | .c" "$fixture"
    [ "$output" = "y" ]
    run jq -r "$TIMEOUTS_FILTER | select(.e == \"PreToolUse\" and (.c | test(\"scripts/hooks/\"))) | select(.t < 30) | .c" "$fixture"
    [ "$output" = "bash scripts/hooks/x.sh" ]
}

# onFailure arrived in Claude Code 2.1.295 (it did not exist when the 2026-09-25
# measurement above found it inert). Measured 2026-10-17 on 2.1.302, fresh
# headless sessions, one hook each: "block" makes a guard that times out, exits
# 1 or cannot start BLOCK the call; absent or "continue" lets it through. One
# INVALID value ("ignore", which older installs carry) on any PreToolUse hook,
# even under another matcher, silently disables EVERY PreToolUse guard. 2.1.292
# ignores the field entirely, so "block" is safe on older CLIs.
ONFAILURE_FILTER='.hooks | to_entries[] | .key as $e | .value[] | .hooks[] | select(has("onFailure")) | {e:$e, o:.onFailure, c:(.command // "")}'
GUARDS_FILTER='.hooks.PreToolUse[]? | .hooks[] | select((.command // "") | test("scripts/hooks/")) | {o:(.onFailure // "<absent>"), c:.command, s:((.command | capture("scripts/hooks/(?<s>[A-Za-z0-9_-]+\\.sh)").s) // "")}'
# Correctness guards that fail open on purpose: a crash or a missing script must
# not refuse every Bash call over a check that protects no secret and no branch.
# Each carries an explicit "continue" (so doctor's hook-fail-open, which flags an
# ABSENT value, stays quiet); every other guard carries "block".
FAIL_OPEN_BY_DESIGN='["zsh-pipestatus-guard.sh"]'
WRONG_ONFAILURE="$GUARDS_FILTER | select(if (.s | IN(\$open[])) then .o != \"continue\" else .o != \"block\" end)"

@test "settings: every onFailure is block or continue (one bad value disables all PreToolUse guards)" {
    run jq -r "$ONFAILURE_FILTER | select(.o != \"block\" and .o != \"continue\") | \"\(.e) \(.o) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "invalid onFailure values: $output" >&2; return 1; }
}

@test "settings: every PreToolUse guard fails closed (onFailure block), bar the listed correctness guards" {
    run jq -r --argjson open "$FAIL_OPEN_BY_DESIGN" "$WRONG_ONFAILURE | \"\(.o) \(.c)\"" "$SETTINGS"
    [ -z "$output" ] || { echo "guards whose onFailure contradicts their policy: $output" >&2; return 1; }
    run jq -r "[$GUARDS_FILTER] | length" "$SETTINGS"
    [ "$output" -gt 0 ]
    # The exception list names only guards that exist: a stale entry would
    # silently pre-approve a future guard of that name failing open.
    run jq -r --argjson open "$FAIL_OPEN_BY_DESIGN" "[$GUARDS_FILTER | .s] as \$have | \$open[] | select(IN(\$have[]) | not)" "$SETTINGS"
    [ -z "$output" ] || { echo "FAIL_OPEN_BY_DESIGN names no registered guard: $output" >&2; return 1; }
}

@test "settings: the onFailure guards are not vacuous — they flag every planted shape" {
    local fixture="$BATS_TEST_TMPDIR/s.json"
    printf '%s' '{"hooks":{"PreToolUse":[{"hooks":[{"command":"bash scripts/hooks/x.sh"},{"command":"bash scripts/hooks/y.sh","onFailure":"block"},{"command":"bash scripts/hooks/w.sh","onFailure":"continue"},{"command":"bash scripts/hooks/zsh-pipestatus-guard.sh","onFailure":"block"},{"command":"bash scripts/hooks/zsh-pipestatus-guard.sh"}]}],"PostToolUse":[{"hooks":[{"command":"z","onFailure":"ignore"}]}]}}' > "$fixture"
    run jq -r "$ONFAILURE_FILTER | select(.o != \"block\" and .o != \"continue\") | .c" "$fixture"
    [ "$output" = "z" ]
    # Flagged: an unlisted guard absent or on continue, a listed one on block or absent.
    run jq -r --argjson open "$FAIL_OPEN_BY_DESIGN" "[$WRONG_ONFAILURE | \"\(.s) \(.o)\"] | join(\",\")" "$fixture"
    [ "$output" = "x.sh <absent>,w.sh continue,zsh-pipestatus-guard.sh block,zsh-pipestatus-guard.sh <absent>" ]
}

@test "settings: no PreToolUse guard exits outside 0/2 on odd input (under block, any other code blocks the tool)" {
    # With onFailure "block", an exit 1 is no longer a silent pass: it refuses
    # the call. A guard that crashes on an empty payload, on garbage, outside a
    # git repository, or on its own TRIGGER path (a commit, a push, a deploy, a
    # migration, an edit on main) would then block the call with a harness
    # error instead of its own verdict. Each guard is fed every payload, in a
    # plain directory and in a repository on main whose fixtures make every
    # guard block at least once (asserted below, so the trigger paths really ran).
    command -v npm >/dev/null 2>&1 || skip "npm is needed to make the three gates block"
    local plain="$BATS_TEST_TMPDIR/plain" repo="$BATS_TEST_TMPDIR/repo" dir script input rc bad="" ran=0 want blocked unblocked=""
    mkdir -p "$plain" "$repo/migrations"
    git -C "$repo" init -q -b main
    printf 'a\n' > "$repo/notes.txt"
    git -C "$repo" add notes.txt
    git -C "$repo" -c user.email=t@t -c user.name=t -c core.hooksPath=/dev/null commit -qm init
    # An existing `feature` ref makes main-branch-guard's automatic
    # feature/auto-* branch fail, the one case where it blocks an edit on main.
    git -C "$repo" branch feature
    # Failing test and build scripts make the commit, push and deploy gates block.
    printf '%s' '{ "name": "fixture", "version": "1.0.0", "scripts": { "test": "exit 1", "build": "exit 1" } }' > "$repo/package.json"
    printf '{}' > "$repo/.eslintrc.json"
    # Assembled from fragments so no committed line looks like a live key.
    local fake_key="AKIA""1234567890ABCDEF"
    local payloads=(
        ''
        'not json'
        '{"tool_name":"Bash","tool_input":{"command":"ls"}}'
        '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
        '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'
        '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}'
        '{"tool_name":"Bash","tool_input":{"command":"npm run deploy"}}'
        '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}'
        '{"tool_name":"Bash","tool_input":{"command":"echo x > .env"}}'
        '{"tool_name":"Edit","tool_input":{"file_path":"notes.txt","old_string":"a","new_string":"b"}}'
        '{"tool_name":"Edit","tool_input":{"file_path":".env","old_string":"a","new_string":"b"}}'
        '{"tool_name":"Write","tool_input":{"file_path":"migrations/001.sql","content":"DROP TABLE users;"}}'
        '{"tool_name":"Edit","tool_input":{"file_path":".claude/settings.json","old_string":"a","new_string":"b"}}'
        '{"tool_name":"Bash","tool_input":{"command":"psql -c \"DROP TABLE users\""}}'
        '{"tool_name":"Bash","tool_input":{"command":"sed -i s/a/b/ .eslintrc.json"}}'
        '{"tool_name":"Edit","tool_input":{"file_path":".eslintrc.json","old_string":"{","new_string":"["}}'
        "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"k.txt\",\"content\":\"$fake_key\"}}"
        '{"tool_name":"Bash","tool_input":{"command":"./deploy.sh production"}}'
        '{"tool_name":"Bash","tool_input":{"command":"false | true; echo \"${PIPESTATUS[0]}\""}}'
        '{"tool_name":"Write","tool_input":{"file_path":"~/.claude/rules/lessons.md","content":"- a lesson"}}'
    )
    while IFS= read -r script; do
        ran=$((ran + 1))
        blocked=0
        for dir in "$plain" "$repo"; do
            for input in "${payloads[@]}"; do
                rc=0
                # A zsh Bash tool, so the zsh guard's trigger path runs; SHELL is
                # read by name only, zsh need not be installed. A one-byte
                # lessons budget under a scratch HOME makes the lessons guard
                # block without reading the real store.
                (cd "$dir" && printf '%s' "$input" | env -u CLAUDE_CODE_SHELL CLAUDE_PROJECT_DIR="$dir" SHELL=/bin/zsh HOME="$BATS_TEST_TMPDIR/home" LESSONS_BUDGET=1 bash "$BASE_DIR/$script" >/dev/null 2>&1) || rc=$?
                if [ "$rc" -eq 2 ]; then blocked=1; fi
                if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then bad="$bad $script(exit $rc in ${dir##*/} on '${input:0:40}')"; fi
            done
        done
        [ "$blocked" -eq 1 ] || unblocked="$unblocked $script"
    done < <(jq -r '.hooks.PreToolUse[].hooks[].command' "$SETTINGS" | grep -oE 'scripts/hooks/[A-Za-z0-9_-]+\.sh' | sort -u)
    [ -z "$bad" ] || { echo "guards exiting outside 0/2:$bad" >&2; return 1; }
    [ -z "$unblocked" ] || { echo "guards whose trigger path no payload reached:$unblocked" >&2; return 1; }
    # Not vacuous: as many scripts ran as there are guards (fail-closed or listed).
    want=$(jq --argjson open "$FAIL_OPEN_BY_DESIGN" "[$GUARDS_FILTER | select(.o == \"block\" or (.s | IN(\$open[])))] | length" "$SETTINGS")
    [ "$ran" -gt 0 ] && [ "$ran" -eq "$want" ] || { echo "ran $ran guard scripts, $want are guards" >&2; return 1; }
}

@test "agents: no hook timeout in agent frontmatter is millisecond-sized" {
    # Hooks declared in an agent's frontmatter use the same seconds unit; nine
    # carried 5000 (83 min) after settings.json had been fixed.
    run grep -rnE '^[[:space:]]*timeout:[[:space:]]*[0-9]{4,}' "$BASE_DIR"/.claude/agents
    [ "$status" -eq 1 ] || { echo "ms-sized timeouts: $output" >&2; return 1; }
}

@test "settings: no deny rule mixes a * wildcard with the trailing :* prefix" {
    # Claude Code (2.1.260+) warns at every session start about this shape: the
    # * is then matched as a literal, not a wildcard. `Bash(rm -rf /*:*)` was the
    # one instance; measured 2026-09-25, a command starting `rm -rf /*` was
    # refused by Claude Code's built-in "Dangerous rm operation" check and the
    # rule never produced its own denial, while the command-validator policy
    # also refuses the glob form (policy-dangerous-commands.bats). Removed, not
    # rewritten: `Bash(rm -rf /*)` would refuse every rm -rf of an absolute path.
    run jq -r '.permissions.deny[] | select(test("^Bash\\(.*\\*.*:\\*\\)$"))' "$SETTINGS"
    [ -z "$output" ] || { echo "mixed-wildcard deny rules: $output" >&2; return 1; }
}
