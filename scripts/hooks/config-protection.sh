#!/usr/bin/env bash
# config-protection.sh — PreToolUse hook (Edit|Write|MultiEdit).
#
# Blocks modifying an EXISTING linter/formatter config file. Agents frequently
# weaken these to make a failing check pass instead of fixing the code; this
# steers them back to the source. First-time CREATION of a config is allowed
# (bootstrapping a project is legitimate). Matches by config FILENAME, not a
# path substring, and ignores configs under test/fixture/example dirs.
#
# Payload arrives on STDIN as JSON; the target is .tool_input.file_path (the same
# field for Edit, Write and MultiEdit). Block = exit 2 with a stderr reason.
# Disable with SKIP_CONFIG_PROTECTION=1.
#
# Deliberately NOT covered (v1): pyproject.toml, tsconfig.json.

set -euo pipefail

[ "${SKIP_CONFIG_PROTECTION:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || true)

# jq is the documented path. Absent jq → fail OPEN (do not block): blocking every
# edit would break normal work, and this hook is a guardrail, not a security gate.
command -v jq >/dev/null 2>&1 || exit 0
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
[ -z "$FILE" ] && exit 0

# A config under a test / fixture / example / dependency tree is not the
# project's ACTIVE config — never block it (US-4 / EC-2).
case "/$FILE/" in
  */tests/*|*/test/*|*/__tests__/*|*/fixtures/*|*/__fixtures__/*|*/examples/*|*/example/*|*/node_modules/*)
    exit 0 ;;
esac

base=$(basename "$FILE")

# Recognized linter/formatter config filenames (EF-003). pyproject.toml and
# tsconfig.json are intentionally absent (out of scope v1).
if ! printf '%s' "$base" | grep -qE \
  '^(\.eslintrc(\.(js|cjs|mjs|json|ya?ml))?|eslint\.config\.(js|cjs|mjs|ts|mts|cts)|\.prettierrc(\.(js|cjs|mjs|json|ya?ml|toml))?|prettier\.config\.(js|cjs|mjs|ts)|biome\.jsonc?|\.?ruff\.toml|\.markdownlint\.(jsonc?|ya?ml))$'; then
  exit 0
fi

# Only block a MODIFICATION: the config must already exist (EF-002). Resolve a
# relative path against the project dir, then cwd.
if [ -e "$FILE" ] || { [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -e "$CLAUDE_PROJECT_DIR/$FILE" ]; }; then
  echo >&2 "BLOCKED: '$base' is a linter/formatter config — fix the underlying code instead of relaxing the rules. (Bypass: SKIP_CONFIG_PROTECTION=1.)"
  exit 2
fi

exit 0
