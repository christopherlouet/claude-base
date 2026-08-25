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

setup() {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    # Run from a neutral cwd with no .gitleaks.toml so the hook's gitleaks
    # defense-in-depth branch is deterministically NOT taken here — these cases
    # exercise the built-in scan in isolation, and must pass identically whether
    # or not the contributor has gitleaks installed. The dedicated gitleaks-branch
    # tests below cd into their own dir (which DOES carry a .gitleaks.toml).
    cd "$BATS_TEST_TMPDIR"
}

# build a PreToolUse payload with the given content
payload() { jq -n --arg c "$1" '{tool_input:{content:$c}}'; }

# --- pass-3: NotebookEdit payloads carry .new_source, not .content ----------
# The matcher covers NotebookEdit since pass-3; without the .new_source
# extraction a secret written into an .ipynb cell was never scanned.

@test "blocks a Stripe live key written into a notebook cell (NotebookEdit)" {
    local k="sk_live_"; k="${k}4eC39HqLyjWDarjtT1zdp7dcKLMNOPQR"
    run bash "$HOOK" <<<"$(jq -n --arg c "stripe = '$k'" \
        '{tool_name:"NotebookEdit", tool_input:{notebook_path:"nb.ipynb", new_source:$c}}')"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Stripe"* ]]
}

@test "allows a clean notebook cell (NotebookEdit)" {
    run bash "$HOOK" <<<"$(jq -n \
        '{tool_name:"NotebookEdit", tool_input:{notebook_path:"nb.ipynb", new_source:"print(1)"}}')"
    [ "$status" -eq 0 ]
}

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

@test "blocks a Slack bot token (xoxb)" {
    local t="xoxb-"; t="${t}012345678901234567890abcdef"
    run bash "$HOOK" <<<"$(payload "const slack = '$t';")"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Slack token"* ]]
}

@test "blocks a Google API key (AIza)" {
    # AIza + exactly 35 chars from [0-9A-Za-z_-]
    local body="abcdefghijklmnopqrstuvwxyz"; body="${body}012345678"   # 26+9 = 35
    local k="AIza"; k="${k}${body}"
    run bash "$HOOK" <<<"$(payload "const g = \"$k\";")"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Google"* ]]
}

@test "blocks a PRIVATE KEY block header" {
    # Assembled from fragments so no contiguous "PRIVATE KEY" literal is committed.
    local a="-----BEGIN RSA "; local b="PRIV"; local c="ATE KEY-----"
    local pk="${a}${b}${c}"
    run bash "$HOOK" <<<"$(payload "$pk")"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Private key"* ]]
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

# Write a fake `gitleaks` that consumes stdin, prints $1 on stderr, exits $2,
# and writes $3 to whatever `--report-path` it was given ("" = write nothing,
# which is what the real binary does when it fails before scanning).
#
# The shim MUST mirror the real contract: the hook decides on the report, so a
# fake that only sets an exit code no longer represents "gitleaks found a
# secret" — it represents "gitleaks exited 1", which is also what a broken
# config does. Faithfulness here is the whole point of these cases.
_fake_gitleaks() { # <dir> <stderr-line> <exit-code> [report-body]
    mkdir -p "$1/bin"
    { printf '#!/usr/bin/env bash\ncat >/dev/null 2>&1 || true\n'
      printf 'body=%q\n' "${4-}"
      printf 'prev=""\nfor a in "$@"; do [ "$prev" = --report-path ] && printf %%s "$body" > "$a"; prev="$a"; done\n'
      printf 'echo %q >&2\nexit %s\n' "$2" "$3"; } > "$1/bin/gitleaks"
    chmod +x "$1/bin/gitleaks"
    : > "$1/.gitleaks.toml"
}

# A minimal report body carrying one finding, shaped like the real one.
_finding_report() { printf '[{"RuleID":"generic-api-key","Match":"REDACTED"}]'; }

@test "gitleaks branch: a CLEAN scan does not block (no-leaks-found regression)" {
    local d="$BATS_TEST_TMPDIR/gl-clean"; _fake_gitleaks "$d" "10:23AM INF no leaks found" 0 '[]'
    cd "$d"
    PATH="$d/bin:$PATH" run bash "$HOOK" <<<"$(payload 'const x = 1;')"
    [ "$status" -eq 0 ]
}

@test "gitleaks branch: a scan that FINDS leaks blocks (finding recorded)" {
    local d="$BATS_TEST_TMPDIR/gl-leak"
    _fake_gitleaks "$d" "Finding: generic-api-key at line 1" 1 "$(_finding_report)"
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

# The regression, in shim form: exit 1 with NO report is exactly what a broken
# config produces. It must fail open. Paired with the case above, which exits 1
# WITH a report and must block — same status, opposite verdicts, which is what
# the exit code alone could never express.
@test "gitleaks branch: exit 1 with no report fails OPEN (config error, not a finding)" {
    local d="$BATS_TEST_TMPDIR/gl-exit1-noreport"
    _fake_gitleaks "$d" "Error: failed to load config" 1
    cd "$d"
    PATH="$d/bin:$PATH" run bash "$HOOK" <<<"$(payload 'const x = 1;')"
    [ "$status" -eq 0 ]
}

# --- gitleaks branch, with the REAL binary ------------------------------------
# The shimmed tests above pin the exit-code contract, but their fake gitleaks
# ignores stdin — so they cannot see WHAT the real binary scans. This case runs
# the real gitleaks from a cwd carrying a secret-bearing file, with clean
# content on stdin: a correct invocation reads 0 findings.
#
# `detect --no-git --pipe` silently ignores --pipe and walks the working
# directory instead. It then finds the neighbouring file and blocks an innocent
# write. Any project with gitleaks, a .gitleaks.toml and a secret on disk (a
# terraform.tfvars, a .env) can no longer write anything at all.
@test "gitleaks branch: real binary scans STDIN, not the working directory" {
    command -v gitleaks >/dev/null 2>&1 || skip "gitleaks not available"

    local d="$BATS_TEST_TMPDIR/gl-real"
    mkdir -p "$d"
    # A REAL config, not the empty stub the shimmed tests use: an empty
    # .gitleaks.toml carries zero rules, so the real binary would find nothing
    # and the case would pass while proving nothing.
    printf '[extend]\nuseDefault = true\n' > "$d/.gitleaks.toml"

    # Neighbour file holding a detectable secret, assembled at runtime so no
    # literal appears in this source file (same convention as above).
    local k="ghp_"; k="${k}Xk29fQmR7bTzL4vN8sYwEc1JdHp6Ua3ZgKiO"
    printf 'token = "%s"\n' "$k" > "$d/leaky-neighbour.txt"

    cd "$d"
    run bash "$HOOK" <<<"$(payload 'const x = 1;')"

    [ "$status" -eq 0 ] || {
        echo "an innocent write was blocked by a secret sitting NEXT TO it:"
        echo "$output"
        return 1
    }
}

# gitleaks returns exit 1 for its OWN errors as well as for findings, so the
# exit code alone cannot tell "secret found" from "tool broke". Measured on the
# real binary: a malformed config exits 1, an unknown subcommand exits 1, only an
# unknown FLAG exits 126. The shimmed error case above returns 2 — a status the
# real binary never produces for this class, which is why it could not catch this.
#
# These two cases must move together: the first proves a broken config does not
# block, the second proves the fix did not simply switch detection off.
@test "gitleaks branch: a MALFORMED config fails OPEN, it does not block every write" {
    command -v gitleaks >/dev/null 2>&1 || skip "gitleaks not available"

    local d="$BATS_TEST_TMPDIR/gl-badconf"
    mkdir -p "$d"
    printf 'this is [not valid toml\n' > "$d/.gitleaks.toml"

    cd "$d"
    run bash "$HOOK" <<<"$(payload 'const x = 1;')"

    [ "$status" -eq 0 ] || {
        echo "a broken .gitleaks.toml made the gate block an innocent write:"
        echo "$output"
        return 1
    }
}

@test "gitleaks branch: real binary still BLOCKS a real secret in the written content" {
    command -v gitleaks >/dev/null 2>&1 || skip "gitleaks not available"

    local d="$BATS_TEST_TMPDIR/gl-realleak"
    mkdir -p "$d"
    printf '[extend]\nuseDefault = true\n' > "$d/.gitleaks.toml"

    # A GitLab PAT ON PURPOSE: it is NOT in POLICY_SECRETS_PATTERNS, so only the
    # gitleaks layer can catch it. A GitHub/AWS token here would be blocked by
    # the built-in scan and this case would pass with gitleaks entirely broken —
    # proving nothing about the layer it is meant to cover. Verified by mutation.
    local k="glpat-"; k="${k}xY3kL9mN2pQ7rS4tU6vW"

    cd "$d"
    run bash "$HOOK" <<<"$(payload "token = \"$k\"")"

    [ "$status" -eq 2 ] || {
        echo "a secret only gitleaks can see was NOT blocked — that layer is off:"
        echo "$output"
        return 1
    }
}

# The control for the case above: the same token, with no .gitleaks.toml, must
# pass. If it were blocked here, the case above would be proving the built-in
# scan rather than the gitleaks layer.
@test "gitleaks branch: the gitleaks-only secret is NOT caught by the built-in scan" {
    local k="glpat-"; k="${k}xY3kL9mN2pQ7rS4tU6vW"
    run bash "$HOOK" <<<"$(payload "token = \"$k\"")"
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
