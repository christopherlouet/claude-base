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
