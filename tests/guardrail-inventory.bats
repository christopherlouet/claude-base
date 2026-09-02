#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/guardrail-inventory.sh — the Phase 1 enumerator of
# specs/guardrail-cleanup/ (US1, EF-001).
#
# WHAT THIS TOOL IS, AND IS NOT. It REPORTS. It refuses nothing, blocks nothing
# and exits 0 whatever it finds. The pass it belongs to exists because guardrails
# get added on the day they seem sensible; adding one to enumerate the others
# would be the pass contradicting itself on its first move. The drift guard that
# would keep the inventory true is deliberately deferred (plan decision D1, task
# T604) until the record is complete and it can be judged like everything else.
#
# WHY FIVE SOURCES. The spec scopes the guardrails to "18 items, ten blocking
# and eight advisory". That figure is exactly right for scripts/hooks/ — and it
# enumerates one directory of four. EF-001 requires completeness to be
# ESTABLISHED, not asserted, so the enumerator reads:
#
#   1. scripts/hooks/*.sh          — classified by whether they can `exit 2`
#   2. .claude/settings.json       — including INLINE commands that have no script
#   3. .husky/*                    — the git hooks, and what they invoke
#   4. .github/workflows/*.yml     — named steps that can fail a check
#   5. permissions.deny            — the native rules, each carrying the class
#                                    the measured matcher law assigns it
#
# An inventory built from source 1 alone would satisfy the stated number while
# failing the stated requirement — and would reproduce, at the level of the audit
# itself, the exact edge case the spec names: "a guardrail exists but is not
# listed anywhere".
#
# THE NON-VACUITY CONTROL IS THE POINT. A tool that enumerates nothing prints a
# clean, sorted, empty list and looks like success. Every "it finds them" test
# here is paired with one proving it FAILS TO FIND a guardrail that has been
# hidden from it. A test that cannot fail proves nothing — this repository has
# been bitten by that twice, most recently in the change this pass just shipped.
# =============================================================================

load 'test_helper'

INVENTORY="$BATS_TEST_DIRNAME/../scripts/guardrail-inventory.sh"

setup() {
    setup_test_dir
    # A miniature foundation with a KNOWN answer, so every count below is
    # asserted against something we planted rather than against the real repo's
    # moving numbers.
    mkdir -p "$TEST_DIR/scripts/hooks" "$TEST_DIR/.claude" "$TEST_DIR/.husky" \
             "$TEST_DIR/.github/workflows"

    # two blocking, one advisory, one shared library
    printf '#!/usr/bin/env bash\nexit 2\n'      > "$TEST_DIR/scripts/hooks/blocker-one.sh"
    printf '#!/usr/bin/env bash\n  exit 2\n'    > "$TEST_DIR/scripts/hooks/blocker-two.sh"
    printf '#!/usr/bin/env bash\necho hi\n'     > "$TEST_DIR/scripts/hooks/adviser.sh"
    printf '#!/usr/bin/env bash\nhelper() { :; }\n' > "$TEST_DIR/scripts/hooks/_shared-lib.sh"

    cat > "$TEST_DIR/.claude/settings.json" <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [
        { "type": "command", "command": "bash scripts/hooks/blocker-one.sh" } ] }
    ],
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "echo '=== banner ==='" } ] }
    ]
  },
  "permissions": {
    "allow": [ "Bash(git status:*)" ],
    "deny": [
      "Bash(sudo:*)",
      "Bash(chmod 777:*)",
      "Bash(rm -rf /:*)",
      "Bash(mkfs:*)",
      "Bash(eval)",
      "Read(./secrets/**)"
    ]
  }
}
JSON

    printf '#!/usr/bin/env sh\nbash scripts/hooks/blocker-two.sh\n' > "$TEST_DIR/.husky/pre-commit"
    cat > "$TEST_DIR/.github/workflows/ci.yml" <<'YML'
jobs:
  build:
    steps:
      - name: Checkout
      - name: Run ShellCheck
      - name: Validate documentation counts
YML
}

run_inventory() { run bash "$INVENTORY" --root "$TEST_DIR"; }

# --- It reports, and never refuses ------------------------------------------

@test "the enumerator always exits 0 — it reports, it does not gate" {
    run_inventory
    [ "$status" -eq 0 ]
}

@test "it still exits 0 on a tree with no guardrails at all" {
    rm -rf "$TEST_DIR/scripts/hooks" "$TEST_DIR/.husky" "$TEST_DIR/.github"
    rm -f "$TEST_DIR/.claude/settings.json"
    run_inventory
    [ "$status" -eq 0 ]
}

# --- Source 1: scripts/hooks/ -----------------------------------------------

@test "source hooks: a script that can exit 2 is listed as blocking" {
    run_inventory
    [[ "$output" == *"blocker-one.sh"* ]]
    [[ "$output" =~ blocker-one\.sh[[:space:]]*\|[[:space:]]*blocking ]]
}

@test "source hooks: a script that cannot exit 2 is listed as advisory" {
    run_inventory
    [[ "$output" =~ adviser\.sh[[:space:]]*\|[[:space:]]*advisory ]]
}

@test "source hooks: an underscore-prefixed shared library is NOT a guardrail" {
    run_inventory
    [[ "$output" != *"_shared-lib.sh"* ]]
}

@test "CONTROL: hiding a hook script removes it from the report" {
    rm "$TEST_DIR/scripts/hooks/blocker-one.sh"
    run_inventory
    [[ "$output" != *"blocker-one.sh"* ]]
    # …and the others are still there, so the tool did not simply go blind.
    [[ "$output" == *"blocker-two.sh"* ]]
}

@test "source hooks: a semicolon-terminated exit 2 counts as blocking" {
    # Found by cross-checking two independent measurements that disagreed. The
    # real pre-commit-tests.sh terminates its refusal with a semicolon inside a
    # brace group, and a pattern demanding whitespace-or-end after the 2 silently
    # classified a blocking guardrail as advisory. A terminator is any non-digit.
    #
    # (This comment deliberately avoids writing a closing brace inline: the bats
    # branch of substance-check.sh counts braces without stripping strings or
    # comments, so a lone one here would close the test block early and the test
    # would be reported as empty. Recorded in enumeration.md, not worked around
    # silently.)
    printf '#!/usr/bin/env bash\n[ -z "$X" ] && { echo no; exit 2; }\n' \
        > "$TEST_DIR/scripts/hooks/semicolon.sh"
    run_inventory
    [[ "$output" =~ semicolon\.sh[[:space:]]*\|[[:space:]]*blocking ]]
}

@test "source hooks: exit 20 is NOT read as exit 2" {
    printf '#!/usr/bin/env bash\nexit 20\n' > "$TEST_DIR/scripts/hooks/exit-twenty.sh"
    run_inventory
    [[ "$output" =~ exit-twenty\.sh[[:space:]]*\|[[:space:]]*advisory ]]
}

@test "source hooks: an exit 2 that only appears in a COMMENT is not blocking" {
    # A script documenting how blocking works does not itself block. Getting
    # this wrong inflates the blocking tier, and the whole pass turns on that
    # tier being honest.
    printf '#!/usr/bin/env bash\n# a hook refuses with exit 2 — this one does not\necho fine\n' \
        > "$TEST_DIR/scripts/hooks/comment-only.sh"
    run_inventory
    [[ "$output" =~ comment-only\.sh[[:space:]]*\|[[:space:]]*advisory ]]
}

# --- Source 2: settings.json, inline commands included ----------------------

@test "source settings: an inline command with no script is still enumerated" {
    run_inventory
    [[ "$output" == *"settings.json"* ]]
    [[ "$output" == *"inline"* ]]
}

@test "CONTROL: emptying settings.json drops its rows, not the others" {
    echo '{}' > "$TEST_DIR/.claude/settings.json"
    run_inventory
    [[ "$output" != *"inline"* ]]
    [[ "$output" == *"blocker-one.sh"* ]]
}

# --- Source 3: .husky -------------------------------------------------------

@test "source husky: a git hook is enumerated" {
    run_inventory
    [[ "$output" == *"pre-commit"* ]]
}

@test "CONTROL: removing the git hook removes its row" {
    rm "$TEST_DIR/.husky/pre-commit"
    run_inventory
    [[ "$output" != *"pre-commit"* ]]
}

# --- Source 4: workflows ----------------------------------------------------

@test "source workflows: a named CI step is enumerated" {
    run_inventory
    [[ "$output" == *"Run ShellCheck"* ]]
}

@test "source workflows: infrastructure steps are not counted as gates" {
    run_inventory
    [[ "$output" != *"Checkout"* ]]
}

@test "CONTROL: removing the workflow removes its rows" {
    rm "$TEST_DIR/.github/workflows/ci.yml"
    run_inventory
    [[ "$output" != *"Run ShellCheck"* ]]
    [[ "$output" == *"blocker-one.sh"* ]]
}

# --- Source 5: the native permissions.deny rules ----------------------------
#
# These refuse before any hook is consulted, and no inventory listed them until
# now. Enumerating them without saying which ones can FIRE would reproduce the
# defect Phase 3 found, so each row carries the class the measured law assigns
# it (native-coverage.md, T202): the native Bash matcher is token-boundary
# aware, so a rule whose prefix ends mid-token matches only its exact literal.

@test "source deny: a native deny rule is enumerated" {
    run_inventory
    [[ "$output" == *"Bash(sudo:*)"* ]]
}

@test "source deny: a rule ending on a whole token is reported as blocking" {
    # `sudo` is continued by a SPACE in every command it aims at, so the
    # boundary falls where the rule ends and the rule covers what it reads as.
    run_inventory
    [[ "$output" =~ Bash\(sudo:\*\)[[:space:]]*\|[[:space:]]*blocking[[:space:]]*\| ]]
}

@test "source deny: a multi-token prefix ending on a whole token is blocking" {
    run_inventory
    [[ "$output" =~ Bash\(chmod\ 777:\*\)[[:space:]]*\|[[:space:]]*blocking[[:space:]]*\| ]]
}

@test "source deny: a rule ending on a path fragment is literal-only" {
    # A prefix ending on a bare slash lands INSIDE the last token of any real
    # command that names a directory under it, and the command continues that
    # token. Measured, arms 1 and 5 of native-coverage.md.
    run_inventory
    [[ "$output" =~ Bash\(rm\ -rf\ /:\*\)[[:space:]]*\|[[:space:]]*blocking-literal-only ]]
}

@test "source deny: a command whose normal form is suffixed is literal-only" {
    # `mkfs` never appears bare in the harm it names — `mkfs.ext4` is a
    # different token. Lexically the prefix ends on a whole word, so this class
    # is carried by a named exception rather than by the shape of the string.
    run_inventory
    [[ "$output" =~ Bash\(mkfs:\*\)[[:space:]]*\|[[:space:]]*blocking-literal-only ]]
}

@test "source deny: the missed form is named on the row that claims one" {
    run_inventory
    [[ "$output" =~ Bash\(mkfs:\*\).*mkfs\.ext4 ]]
}

@test "source deny: a rule with no :* suffix matches its literal and nothing else" {
    run_inventory
    [[ "$output" =~ Bash\(eval\)[[:space:]]*\|[[:space:]]*blocking-literal-only ]]
}

@test "source deny: the token law is a Bash claim, so a non-Bash rule keeps it" {
    # The law was measured on the Bash matcher. Applying it to a Read rule
    # would be exactly the overclaim this pass exists to remove.
    run_inventory
    [[ "$output" =~ Read\(\./secrets/\*\*\)[[:space:]]*\|[[:space:]]*blocking[[:space:]]*\| ]]
}

@test "source deny: an allow rule is not reported as a refusal" {
    # Paired with the presence it depends on: an enumerator that reads nothing
    # would satisfy the absence for free, and prove nothing.
    run_inventory
    [[ "$output" == *"Bash(sudo:*)"* ]]
    [[ "$output" != *"git status"* ]]
}

@test "CONTROL: dropping the deny list drops its rows, not the others" {
    # The before-reading is part of the control: without it this passes on an
    # enumerator that never had a fifth source.
    run_inventory
    [[ "$output" == *"Bash(sudo:*)"* ]]

    python3 -c 'import json,sys;p=sys.argv[1];d=json.load(open(p));d["permissions"].pop("deny");json.dump(d,open(p,"w"))' \
        "$TEST_DIR/.claude/settings.json"
    run_inventory
    [[ "$output" != *"Bash(sudo:*)"* ]]
    [[ "$output" == *"blocker-one.sh"* ]]
    [[ "$output" == *"inline"* ]]
}

@test "source deny: --source deny reports the deny rules and nothing else" {
    run bash "$INVENTORY" --root "$TEST_DIR" --source deny
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bash(sudo:*)"* ]]
    [[ "$output" != *"blocker-one.sh"* ]]
    [[ "$output" != *"Run ShellCheck"* ]]
}

@test "self-application: every deny rule of the real foundation is reported" {
    # DERIVED from the file, never copied: a pinned number would pass while the
    # tool went half-blind, and would teach the next reader to bump it. The law
    # asserted here is that two independent counts agree.
    run bash "$INVENTORY" --source deny
    local reported expected
    reported=$(printf '%s\n' "$output" | grep -c '^deny | ' || true)
    expected=$(python3 -c 'import json;print(len(json.load(open(".claude/settings.json"))["permissions"]["deny"]))')
    [ "$expected" -gt 0 ]
    [ "$reported" -eq "$expected" ]
}

@test "self-application: the real foundation shows both ends of the measured law" {
    # The pair that established the law lives in the real settings file. If
    # either end stops being reported, the model has drifted from what was
    # measured on 2026-09-01.
    run bash "$INVENTORY" --source deny
    [[ "$output" =~ Bash\(rm\ -rf\ /:\*\)[[:space:]]*\|[[:space:]]*blocking-literal-only ]]
    [[ "$output" =~ Bash\(sudo:\*\)[[:space:]]*\|[[:space:]]*blocking[[:space:]]*\| ]]
}

# --- Output shape -----------------------------------------------------------

@test "output is stable: two consecutive runs are byte-identical" {
    run bash "$INVENTORY" --root "$TEST_DIR"
    local first="$output"
    run bash "$INVENTORY" --root "$TEST_DIR"
    [ "$first" = "$output" ]
}

@test "output is sorted, so a diff between two runs means a real change" {
    run bash "$INVENTORY" --root "$TEST_DIR"
    local body sorted
    body=$(printf '%s\n' "$output" | grep ' | ' || true)
    sorted=$(printf '%s\n' "$body" | LC_ALL=C sort)
    [ "$body" = "$sorted" ]
}

# --- Self-application: it must work on the REAL foundation ------------------

@test "self-application: the enumerator runs on the real foundation and exits 0" {
    run bash "$INVENTORY"
    [ "$status" -eq 0 ]
}

@test "self-application: it finds the real foundation's known guardrails" {
    # Named, load-bearing examples rather than a total: a count would break on
    # every unrelated addition and teach people to update the number without
    # looking. These four must appear, whatever else does.
    run bash "$INVENTORY"
    [[ "$output" == *"command-validator.sh"* ]]
    [[ "$output" == *"main-branch-guard.sh"* ]]
    [[ "$output" == *"secret-scan.sh"* ]]
    [[ "$output" == *"pre-commit"* ]]
}

@test "self-application CONTROL: the real run is not trivially empty" {
    # If the tool silently enumerated nothing, every "contains" assertion above
    # would still pass on an empty string in a broken shell. Assert substance.
    run bash "$INVENTORY"
    local rows
    rows=$(printf '%s\n' "$output" | grep -c ' | ' || true)
    [ "$rows" -gt 20 ]
}
