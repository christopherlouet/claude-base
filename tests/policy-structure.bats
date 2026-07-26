#!/usr/bin/env bats

# =============================================================================
# Structural invariants of the core/shell split (specs/agnostic-core/ CS-003).
#
# 1. CORE PURITY — no harness plumbing in any _core-/_policy- file.
# 2. THIN SHELLS — no decision pattern table survives in a shell hook.
# 3. MANIFEST CLOSURE — every _*.sh lib sourced by a shipped hook ships too.
# 4. PORTABILITY-MAP DRIFT — every scripts/hooks/*.sh is classified in
#    specs/agnostic-core/portability-map.md, and vice versa.
# =============================================================================

load 'test_helper'

HOOKS_DIR="$BASE_DIR/scripts/hooks"
MANIFEST="$BASE_DIR/scripts/lib/minimal-manifest.txt"
PORTMAP="$BASE_DIR/specs/agnostic-core/portability-map.md"

@test "structure: core files are free of harness plumbing" {
    local bad=""
    for f in "$HOOKS_DIR"/_core-*.sh "$HOOKS_DIR"/_policy-*.sh; do
        [ -e "$f" ] || continue
        if grep -qE 'tool_input|hookSpecificOutput|CLAUDE_PROJECT_DIR|exit 2' "$f"; then
            bad="$bad $f"
        fi
    done
    [ -z "$bad" ]
}

@test "structure: core files are sourceable under set -euo pipefail" {
    for f in "$HOOKS_DIR"/_core-*.sh "$HOOKS_DIR"/_policy-*.sh; do
        [ -e "$f" ] || continue
        run bash -c "set -euo pipefail; . '$f'"
        [ "$status" -eq 0 ]
    done
}

@test "structure: shells retain no decision pattern tables" {
    # Each shell's formerly-inline distinctive policy tokens must now live
    # only in its core. A hit here means policy leaked back into a shell.
    ! grep -E 'Fork bomb|mkfs|PIPE_INTERP|visudo|masscan' "$HOOKS_DIR/command-validator.sh"
    ! grep -E 'AKIA|sk_live|xox\[baprs\]|PLACEHOLDER' "$HOOKS_DIR/secret-scan.sh"
    ! grep -E 'drop\[\[:space:\]\]\+table|force-reset|delete\[\[:space:\]\]\+from' "$HOOKS_DIR/destructive-ops.sh"
    ! grep -E 'drop\[\[:space:\]\]\+\(table|\*\.up\.sql' "$HOOKS_DIR/destructive-migration.sh"
    ! grep -E -- '--in-place|of=\[|pipx|CMD_UQ_CPMV' "$HOOKS_DIR/bash-write-guard.sh"
    ! grep -E 'grep -qE .*(commit|push|deploy)' "$HOOKS_DIR/pre-commit-tests.sh" "$HOOKS_DIR/pre-push-ci.sh" "$HOOKS_DIR/pre-deploy-build.sh"
}

@test "structure: every lib sourced by a shipped hook is in the manifest" {
    # manifest-hooks-coverage.bats guards settings.json-referenced hooks; this
    # closes the second hop — a lib a hook SOURCES must ship too, or the
    # installed guard degrades (or dies) without it.
    local missing=""
    for f in "$HOOKS_DIR"/*.sh; do
        while IFS= read -r lib; do
            [ -n "$lib" ] || continue
            [ -f "$HOOKS_DIR/$lib" ] || { missing="$missing $f->$lib(absent)"; continue; }
            grep -qE "^scripts/hooks/${lib}([[:space:]]|$|:)" "$MANIFEST" \
                || missing="$missing $f->$lib(unshipped)"
        done < <(grep -oE '_[a-z-]+\.sh' "$f" | sort -u)
    done
    if [ -n "$missing" ]; then
        echo "Sourced libs missing from manifest:$missing" >&2
        return 1
    fi
}

@test "structure: policy bootstrap block is byte-identical across the 4 policy libs" {
    # The bootstrap (dir resolve, core source, POLICY_HAVE_CORE_STRIP) is
    # deliberately copy-pasted — divergent copies of shared logic are the
    # documented root cause of past guard bugs, so the copies are pinned equal.
    local ref="" cur f
    ref=$(sed -n '/--- policy bootstrap /,/--- end policy bootstrap ---/p' \
        "$HOOKS_DIR/_policy-dangerous-commands.sh")
    [ -n "$ref" ]
    for f in _policy-destructive-sql.sh _policy-triggers.sh _policy-write-targets.sh; do
        cur=$(sed -n '/--- policy bootstrap /,/--- end policy bootstrap ---/p' "$HOOKS_DIR/$f")
        if [ "$cur" != "$ref" ]; then
            echo "Bootstrap drift in $f" >&2
            return 1
        fi
    done
}

# --- Degraded mode: shell shipped WITHOUT its policy core --------------------
# New behavior introduced by the split (the old inline hooks could not lose
# their logic to a missing file). Philosophy per guard, pinned here:
#   security Bash guards fail CLOSED (block everything, actionable message);
#   edit-path gates and build gates fail OPEN but must WARN on stderr.

_degraded_dir() {
    # A hooks dir holding ONLY the named shells (+ optional extra libs).
    mkdir -p "$TEST_DIR/hooks"
    local f
    for f in "$@"; do cp "$HOOKS_DIR/$f" "$TEST_DIR/hooks/"; done
}

_bash_envelope() { jq -n --arg c "$1" '{tool_name:"Bash", tool_input:{command:$c}}'; }

@test "degraded: command-validator without core fails CLOSED with a usable hint" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir; _degraded_dir command-validator.sh
    run bash -c "printf '%s' \"\$(jq -n --arg c 'ls -la' '{tool_input:{command:\$c}}')\" | bash '$TEST_DIR/hooks/command-validator.sh' 2>&1"
    [ "$status" -eq 2 ]
    [[ "$output" == *"policy core missing"* ]]
    # The hint must NOT teach the inline VAR=1 form (it never reaches a hook).
    [[ "$output" == *"settings.local.json"* ]]
    teardown_test_dir
}

@test "degraded: destructive-ops without core fails CLOSED" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir; _degraded_dir destructive-ops.sh
    run bash -c "printf '%s' \"\$(jq -n --arg c 'ls' '{tool_input:{command:\$c}}')\" | bash '$TEST_DIR/hooks/destructive-ops.sh' 2>&1"
    [ "$status" -eq 2 ]
    [[ "$output" == *"policy core missing"* ]]
    teardown_test_dir
}

@test "degraded: secret-scan without core fails OPEN but warns" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir; _degraded_dir secret-scan.sh
    local a="AKIA"; a="${a}1234567890ABCDEF"
    run bash -c "printf '%s' \"\$(jq -n --arg c \"key='$a'\" '{tool_input:{content:\$c}}')\" | bash '$TEST_DIR/hooks/secret-scan.sh' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DISABLED"* ]]
    teardown_test_dir
}

@test "degraded: destructive-migration without core fails OPEN but warns" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir; _degraded_dir destructive-migration.sh
    run bash -c "printf '%s' \"\$(jq -n '{tool_input:{file_path:\"migrations/0002_x.sql\", content:\"DROP TABLE users;\"}}')\" | bash '$TEST_DIR/hooks/destructive-migration.sh' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DISABLED"* ]]
    teardown_test_dir
}

@test "degraded: bash-write-guard without write-targets core fails OPEN but warns" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir; _degraded_dir bash-write-guard.sh _sensitive-paths.sh
    run bash -c "printf '%s' \"\$(jq -n '{tool_input:{command:\"echo x > .env\"}}')\" | bash '$TEST_DIR/hooks/bash-write-guard.sh' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DISABLED"* ]]
    teardown_test_dir
}

@test "degraded: the three build gates without triggers core fail OPEN but warn" {
    command -v jq >/dev/null 2>&1 || skip "jq not available"
    setup_test_dir
    _degraded_dir pre-commit-tests.sh pre-push-ci.sh pre-deploy-build.sh
    local g cmd
    for g in "pre-commit-tests.sh:git commit -m x" "pre-push-ci.sh:git push" "pre-deploy-build.sh:npm run deploy"; do
        cmd="${g#*:}"
        run bash -c "printf '%s' \"\$(jq -n --arg c '$cmd' '{tool_input:{command:\$c}}')\" | bash '$TEST_DIR/hooks/${g%%:*}' 2>&1"
        [ "$status" -eq 0 ]
        [[ "$output" == *"DISABLED"* ]]
    done
    teardown_test_dir
}

@test "structure: portability map covers every hook file (and only real ones)" {
    [ -f "$PORTMAP" ]
    local f base missing=""
    for f in "$HOOKS_DIR"/*.sh; do
        base=$(basename "$f")
        grep -q "\`$base\`" "$PORTMAP" || missing="$missing $base"
    done
    if [ -n "$missing" ]; then
        echo "Hooks missing from portability-map.md:$missing" >&2
        return 1
    fi
    # Reverse direction: no stale entry for a removed hook.
    local stale=""
    while IFS= read -r base; do
        [ -n "$base" ] || continue
        [ -f "$HOOKS_DIR/$base" ] || stale="$stale $base"
    done < <(grep -oE '\| `[a-z_-]+\.sh`' "$PORTMAP" | grep -oE '[a-z_-]+\.sh')
    if [ -n "$stale" ]; then
        echo "Stale portability-map entries:$stale" >&2
        return 1
    fi
}
