#!/usr/bin/env bash
# =============================================================================
# _sensitive-paths.sh — sourceable helpers shared by the file-mutation guards.
#
# Sourced by: config-protection.sh (Edit|Write|MultiEdit) and
#             bash-write-guard.sh (Bash). Classifies a file BASENAME as a
#             protected linter/formatter config or a secrets/credentials file,
#             so both the edit-path and the Bash-path guards agree on the SAME
#             set (one representation, no drift).
#
# NOT a hook by itself. Do not register in settings.json.
# =============================================================================

# Avoid double-sourcing.
[ -n "${SENSITIVE_PATHS_LOADED:-}" ] && return 0
SENSITIVE_PATHS_LOADED=1

# is_protected_config <basename>
# Returns 0 if <basename> is a linter/formatter config we protect from being
# WEAKENED (agents relax these to make a failing check pass). pyproject.toml and
# tsconfig.json are intentionally out of scope (they carry non-lint settings).
is_protected_config() {
    printf '%s' "$1" | grep -qE \
      '^(\.eslintrc(\.(js|cjs|mjs|json|ya?ml))?|eslint\.config\.(js|cjs|mjs|ts|mts|cts)|\.prettierrc(\.(js|cjs|mjs|json|ya?ml|toml))?|prettier\.config\.(js|cjs|mjs|ts)|biome\.jsonc?|\.?ruff\.toml|\.markdownlint\.(jsonc?|ya?ml))$'
}

# is_secret_file <basename>
# Returns 0 if <basename> is a secrets / credentials file whose contents should
# not be clobbered by a Bash redirection. `.env.example` / `.env.sample` /
# `.env.template` are excluded — those are meant to be edited and committed.
is_secret_file() {
    case "$1" in
        .env.example|.env.sample|.env.template|.env.dist) return 1 ;;
    esac
    printf '%s' "$1" | grep -qE \
      '^(\.env(\.[A-Za-z0-9_.-]+)?|.+\.pem|.+\.key|id_rsa|id_dsa|id_ecdsa|id_ed25519|credentials|\.netrc|\.pgpass|\.npmrc)$'
}
