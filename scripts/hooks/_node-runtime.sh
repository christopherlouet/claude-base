#!/usr/bin/env bash
# =============================================================================
# _node-runtime.sh — sourced helper: run a project's Node checks on the
# project's own Node, not on whichever Node launched Claude Code.
#
# A hook inherits Claude Code's environment. When the project pins a newer Node
# (mise.toml / .mise.toml / .tool-versions, engines.node), the test gates ran
# the suite on the older one and blocked a green project (seen: 1,212 tests
# green on Node 24, 105 vitest workers crashing on Node 20). So:
#   - with mise on PATH and a mise config in the project, npm/npx run through
#     `mise exec --`, auto-install OFF (a .tool-versions is not trust-gated:
#     without it, a first commit downloads every listed tool, outside the gate
#     budget); if mise refuses (untrusted config, tool not installed), say so
#     and fall back to the inherited Node;
#   - if the Node selected that way is still below engines.node, the npm checks
#     are SKIPPED with the reason, never run: a suite on the wrong runtime
#     proves nothing either way, and CI is the backstop (the same stance as a
#     missing tool).
#
# Usage (bash 3.2-safe):
#   . _node-runtime.sh
#   if node_runtime_select <gate-name>; then
#     gate_run_tail 20 ${NODE_RUN[@]+"${NODE_RUN[@]}"} npm test
#   fi
# node_runtime_select returns 1 (and prints why) when the npm checks must be
# skipped; NODE_RUN holds the command prefix (empty for the inherited Node).
# =============================================================================

# node_engines_min_major <range> — the minimum major of a simple engines.node
# range (">=24", "^20.1", "18.x", ">=18 <21", "~22"); empty when it cannot
# tell ("*", "lts/*", "<=22"). Empty = no check. Any "||" alternation is
# "cannot tell": its first number need not be its minimum (">=22 || ^18"),
# and a wrong minimum would skip the suite of a project that should run.
node_engines_min_major() {
    case "${1:-}" in *'||'*) return 0 ;; esac
    printf '%s' "${1:-}" | sed -nE 's/^[[:space:]]*(>=|\^|~|=)?[[:space:]]*v?([0-9]+).*/\2/p'
}

node_runtime_select() {
    local gate="${1:-gate}" need have
    NODE_RUN=()
    if command -v mise >/dev/null 2>&1 \
        && { [ -f mise.toml ] || [ -f .mise.toml ] || [ -f .tool-versions ]; }; then
        if env MISE_AUTO_INSTALL=0 MISE_EXEC_AUTO_INSTALL=0 mise exec -- node -v >/dev/null 2>&1; then
            NODE_RUN=(env MISE_AUTO_INSTALL=0 MISE_EXEC_AUTO_INSTALL=0 mise exec --)
        else
            echo "[$gate] mise config found but 'mise exec' failed (untrusted config: 'mise trust'; tool not installed: 'mise install'); using the inherited Node."
        fi
    fi
    [ -f package.json ] && command -v jq >/dev/null 2>&1 || return 0
    need=$(node_engines_min_major "$(jq -r '.engines.node // empty' package.json 2>/dev/null)")
    [ -n "$need" ] || return 0
    have=$(${NODE_RUN[@]+"${NODE_RUN[@]}"} node -v 2>/dev/null | sed -nE 's/^v?([0-9]+).*/\1/p')
    [ -n "$have" ] || return 0
    if [ "$have" -lt "$need" ]; then
        if [ -n "${NODE_RUN[*]-}" ]; then
            echo "[$gate] npm checks skipped: package.json needs Node $(jq -r '.engines.node' package.json), the project's mise runtime is Node $have. CI remains the backstop."
        else
            echo "[$gate] npm checks skipped: package.json needs Node $(jq -r '.engines.node' package.json), this hook runs Node $have and finds no project runtime (mise) to switch to. CI remains the backstop."
        fi
        return 1
    fi
    return 0
}
