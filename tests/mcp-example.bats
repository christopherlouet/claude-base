#!/usr/bin/env bats

# =============================================================================
# Drift guards for .mcp.json.example — the reference MCP-server catalogue.
# Pass-3 audit: 9 of 13 example blocks pointed at npm packages that DO NOT
# EXIST (a phantom @anthropics/* scope), so the documented enable path
# ("copy a block into .mcp.json") produced a broken server; and no entry was
# version-pinned, contradicting the foundation's own pinning doctrine
# (an unpinned `npx -y pkg` executes whatever was published last).
# These pins keep the file structurally honest; package EXISTENCE was
# verified against the npm/PyPI registries when each pin was written.
# =============================================================================

load 'test_helper'

EXAMPLE="$BASE_DIR/.mcp.json.example"

setup() { skip_if_no_jq; }

@test "mcp example: valid JSON with a non-empty mcpServers object" {
    run jq -e '.mcpServers | type == "object" and length > 0' "$EXAMPLE"
    [ "$status" -eq 0 ]
}

@test "mcp example: no phantom @anthropics/* npm scope survives" {
    ! grep -q '@anthropics/' "$EXAMPLE"
}

@test "mcp example: every npx-launched package is version-pinned" {
    # npx args: ["-y", "pkg@version", ...] — the package token must contain a
    # trailing @version (scoped packages: the SECOND @).
    run jq -r '.mcpServers[] | select(.command == "npx") | .args[1]' "$EXAMPLE"
    [ "$status" -eq 0 ]
    local pkg
    while IFS= read -r pkg; do
        [ -n "$pkg" ] || continue
        [[ "$pkg" =~ [^/]@[0-9] ]] || { echo "unpinned npx package: $pkg"; return 1; }
    done <<< "$output"
}

@test "mcp example: every uvx-launched package is version-pinned (==)" {
    run jq -r '.mcpServers[] | select(.command == "uvx") | .args[0]' "$EXAMPLE"
    [ "$status" -eq 0 ]
    local pkg
    while IFS= read -r pkg; do
        [ -n "$pkg" ] || continue
        [[ "$pkg" == *"=="* ]] || { echo "unpinned uvx package: $pkg"; return 1; }
    done <<< "$output"
}

@test "mcp example: no fictional per-server 'enabled' flag" {
    run jq -e '[.mcpServers[] | has("enabled")] | any' "$EXAMPLE"
    [ "$status" -ne 0 ] || [ "$(jq -r '[.mcpServers[] | has("enabled")] | any' "$EXAMPLE")" = "false" ]
}

@test "mcp example: secrets come from env-var references, never literals" {
    # Every env value must be a ${VAR} reference.
    run jq -r '.mcpServers[].env // {} | to_entries[].value' "$EXAMPLE"
    local v
    while IFS= read -r v; do
        [ -n "$v" ] || continue
        [[ "$v" =~ ^\$\{[A-Z_]+\}$ ]] || { echo "non-env-reference value: $v"; return 1; }
    done <<< "$output"
}

@test "mcp example: .mcp.json itself still ships empty (documented contract)" {
    run jq -e '.mcpServers == {}' "$BASE_DIR/.mcp.json"
    [ "$status" -eq 0 ]
}
