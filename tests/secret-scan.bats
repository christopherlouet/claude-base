#!/usr/bin/env bats

# Tests for scripts/hooks/secret-scan.sh — the built-in (zero-dependency)
# secret gate. Blocks writing a hardcoded provider secret; ignores self-declared
# placeholders to stay zero-false-positive. Requires jq (the hook fails open
# without it). Input is a PreToolUse payload on stdin.
#
# NOTE: the test secrets are assembled at runtime from fragments (prefix var +
# body) so no full secret literal appears in this file — otherwise GitHub Push
# Protection would block the push on our own fixtures. The hook still receives
# the fully-formed secret at runtime.

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/secret-scan.sh"

setup() { command -v jq >/dev/null 2>&1 || skip "jq not available"; }

# build a PreToolUse payload with the given content
payload() { jq -n --arg c "$1" '{tool_input:{content:$c}}'; }

@test "blocks a Stripe live secret key" {
    local k="sk_live_"; k="${k}4eC39HqLyjWDarjtT1zdp7dcKLMNOPQR"
    run bash "$HOOK" <<<"$(payload "const stripe = '$k';")"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Stripe"* ]]
}

@test "blocks an AWS access key" {
    local a="AKIA"; a="${a}1234567890ABCDEF"
    run bash "$HOOK" <<<"$(payload "$a")"
    [ "$status" -eq 2 ]
}

@test "blocks a GitHub token" {
    local g="ghp_"; g="${g}0123456789abcdefghijklmnopqrstuvwxyz"
    run bash "$HOOK" <<<"$(payload "token=$g")"
    [ "$status" -eq 2 ]
}

@test "blocks a Slack webhook URL" {
    local s="https://hooks.slack.com/services/TAAAAAAAA/BBBBBBBBB/"; s="${s}abcdefghij1234567890XY"
    run bash "$HOOK" <<<"$(jq -n --arg c "$s" '{tool_input:{new_string:$c}}')"
    [ "$status" -eq 2 ]
}

@test "blocks a secret inside a MultiEdit edits array" {
    local k="sk_live_"; k="${k}4eC39HqLyjWDarjtT1zdp7dcKLMNOPQR"
    run bash "$HOOK" <<<"$(jq -n --arg k "key=$k" '{tool_input:{edits:[{new_string:"ok"},{new_string:$k}]}}')"
    [ "$status" -eq 2 ]
}

@test "allows a self-declared placeholder (EXAMPLE)" {
    local a="AKIA"; a="${a}IOSFODNN7EXAMPLE"
    run bash "$HOOK" <<<"$(payload "# example key: $a")"
    [ "$status" -eq 0 ]
}

@test "blocks a real secret even when a placeholder word sits elsewhere on the line" {
    # Same-line smuggle: appending "// example" must NOT quiet the gate — the
    # placeholder check applies to the matched SECRET VALUE, not the whole line.
    local a="AKIA"; a="${a}1234567890ABCDEF"
    run bash "$HOOK" <<<"$(payload "const k = \"$a\"; // see example.com")"
    [ "$status" -eq 2 ]
}

@test "allows ordinary code (zero false positive)" {
    run bash "$HOOK" <<<"$(payload 'export function add(a, b) { return a + b; }')"
    [ "$status" -eq 0 ]
}

@test "allows reading the secret from an env var" {
    run bash "$HOOK" <<<"$(payload 'const k = process.env.STRIPE_SECRET_KEY;')"
    [ "$status" -eq 0 ]
}

@test "respects the SKIP_SECRET_SCAN opt-out" {
    local a="AKIA"; a="${a}1234567890ABCDEF"
    SKIP_SECRET_SCAN=1 run bash "$HOOK" <<<"$(payload "$a")"
    [ "$status" -eq 0 ]
}

@test "empty / non-matching payload exits cleanly" {
    run bash "$HOOK" <<<'{"tool_input":{}}'
    [ "$status" -eq 0 ]
}

# --- gitleaks defense-in-depth branch -----------------------------------------
# The hook keys the block on gitleaks' EXIT CODE, never on its log text. A clean
# gitleaks run prints "INF no leaks found" (contains the substring "leak"); the
# previous `grep -qiE 'secret|leak|finding'` false-blocked EVERY edit in any
# project with gitleaks + a .gitleaks.toml. These shim gitleaks on PATH to pin
# the contract: exit 0 = allow, exit 1 = block, any other error = fail OPEN.

# Write a fake `gitleaks` that consumes stdin, prints $1 on stderr, exits $2.
_fake_gitleaks() { # <dir> <stderr-line> <exit-code>
    mkdir -p "$1/bin"
    { printf '#!/usr/bin/env bash\ncat >/dev/null 2>&1 || true\n'
      printf 'echo %q >&2\nexit %s\n' "$2" "$3"; } > "$1/bin/gitleaks"
    chmod +x "$1/bin/gitleaks"
    : > "$1/.gitleaks.toml"
}

@test "gitleaks branch: a CLEAN scan does not block (no-leaks-found regression)" {
    local d="$BATS_TEST_TMPDIR/gl-clean"; _fake_gitleaks "$d" "10:23AM INF no leaks found" 0
    cd "$d"
    PATH="$d/bin:$PATH" run bash "$HOOK" <<<"$(payload 'const x = 1;')"
    [ "$status" -eq 0 ]
}

@test "gitleaks branch: a scan that FINDS leaks blocks (exit 1)" {
    local d="$BATS_TEST_TMPDIR/gl-leak"; _fake_gitleaks "$d" "Finding: generic-api-key at line 1" 1
    cd "$d"
    PATH="$d/bin:$PATH" run bash "$HOOK" <<<"$(payload 'const x = 1;')"
    [ "$status" -eq 2 ]
    [[ "$output" == *gitleaks* ]]
}

@test "gitleaks branch: a tooling error (removed flag) fails OPEN, not blocks" {
    local d="$BATS_TEST_TMPDIR/gl-err"; _fake_gitleaks "$d" "Error: unknown flag --pipe" 2
    cd "$d"
    PATH="$d/bin:$PATH" run bash "$HOOK" <<<"$(payload 'const x = 1;')"
    [ "$status" -eq 0 ]
}

# Self-application (base-maintenance rule): scanning real foundation source files
# must NOT block — a standing zero-false-positive regression guard on the repo.
@test "self-application: real foundation scripts produce no false positive" {
    local f
    for f in "$BATS_TEST_DIRNAME/../scripts/hooks/command-validator.sh" \
             "$BATS_TEST_DIRNAME/../scripts/hooks/setup-deps.sh" \
             "$BATS_TEST_DIRNAME/../scripts/sync-counts.sh"; do
        [ -f "$f" ] || continue
        run bash "$HOOK" <<<"$(jq -Rs '{tool_input:{content:.}}' < "$f")"
        [ "$status" -eq 0 ] || { echo "false positive on $f: $output"; return 1; }
    done
}
