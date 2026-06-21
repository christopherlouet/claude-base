#!/usr/bin/env bash
# =============================================================================
# _vendor-precedence-hint.sh — Sourceable helper for prompt-context.sh
# =============================================================================
# NOT a hook by itself. Do not register in settings.json.
#
# For each graduated foundation skill whose canonical *vendor* skill is actually
# INSTALLED on the machine, emit a one-line markdown precedence hint so the
# assistant prefers the vendor over the foundation pointer this session
# (.claude/rules/vendor-precedence.md, tier 3 — vendor owns the tool API).
#
# Self-contained ON PURPOSE — no jq, no registry read, no common.sh:
#   - It lives in scripts/hooks/ because `init` copies ONLY scripts/hooks/*.sh
#     to downstream projects (not scripts/lib/ nor .claude/curation/).
#   - Pure shell so it can never break the standalone UserPromptSubmit hook and
#     fires even in projects that did not receive the curation registry.
#
# Design (see specs/dynamic-vendor-precedence/spec.md):
#   - Fires ONLY when the vendor skill is installed (an installed vendor skill
#     already implies the project uses the tool → no stack detection needed).
#   - Detection = the dominant `npx skills add` path, which symlinks each skill
#     into .claude/skills/<name> (with a .agents/skills fallback for the global
#     symlink bug vercel-labs/skills#851). Marketplace-plugin installs are NOT
#     detectable here (documented limitation).
# =============================================================================

# Internal table — one row per graduated record (v1: the 3 high-confidence
# pointer-skills). Format: foundationSkill|vendorId|sentinel dirs (space-sep).
# Any sentinel dir present ⟹ the vendor skill is installed. Extend with one row
# per record (e.g. dev-nextjs, dev-graphql) once its install dir names are
# verified and the foundation skill has graduated.
_VPREC_TABLE='dev-prisma|prisma/skills|prisma-cli prisma-client-api prisma-postgres
dev-supabase|supabase/agent-skills|supabase supabase-postgres-best-practices
dev-shadcn|shadcn-ui/ui/skills/shadcn|shadcn'

# _vprec_is_installed <dir_name> <project_dir> <home_dir>
# Return 0 if <dir_name> exists as a skill dir under any of the 4 search roots:
#   {project,home} × {.claude/skills, .agents/skills}
_vprec_is_installed() {
    local name="$1" project="$2" home="$3" root
    for root in \
        "$project/.claude/skills" \
        "$project/.agents/skills" \
        "$home/.claude/skills" \
        "$home/.agents/skills"; do
        [ -d "$root/$name" ] && return 0
    done
    return 1
}

# vendor_precedence_hints <project_dir> [home_dir]
# Print one markdown bullet per installed vendor skill. Silent (exit 0) when
# nothing is installed. Never reads the network, jq, or any registry file.
vendor_precedence_hints() {
    local project_dir="${1:-$PWD}"
    local home_dir="${2:-${HOME:-}}"
    local fskill vendor sentinels dir hit

    while IFS='|' read -r fskill vendor sentinels; do
        if [ -z "$fskill" ] || [ -z "$vendor" ]; then
            continue
        fi
        hit=0
        for dir in $sentinels; do
            if _vprec_is_installed "$dir" "$project_dir" "$home_dir"; then
                hit=1
                break
            fi
        done
        [ "$hit" = "1" ] || continue
        # Single-quoted format on purpose: the backticks are literal markdown and
        # the values are supplied as printf args (no shell expansion wanted here).
        # shellcheck disable=SC2016
        printf -- '- `%s` (vendor, installed) is canonical here — prefer it over the foundation `%s` pointer (vendor-precedence T3).\n' \
            "$vendor" "$fskill"
    done <<EOF
$_VPREC_TABLE
EOF
    return 0
}
