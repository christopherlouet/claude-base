#!/usr/bin/env bash
# =============================================================================
# pre-commit-tests.sh — PreToolUse hook (Bash).
#
# Before a `git commit`, run the project's test suite and BLOCK the commit
# (exit 2) if it fails — the "tests must pass before commit" discipline.
# Extracted from an inline settings.json `bash -c` gate (which shipped with
# ZERO test coverage); behaviour preserved, with one latent typo fixed:
# the Husky-installed check tested a bogus path `.husky/_]` (missing space)
# instead of `.husky/_`.
#
# Detects the stack: npm test (package.json "test"), else pytest (pyproject),
# else go test (go.mod). No jq / not a `git commit` / SKIP_PRE_COMMIT_TESTS=1
# → no-op (exit 0). The git pre-commit hook and CI remain the backstops.
# Payload on STDIN as JSON (.tool_input.command).
# =============================================================================
set -u

[ "${SKIP_PRE_COMMIT_TESTS:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

CMD=$(cat | jq -r '.tool_input.command // empty' 2>/dev/null || true)
printf '%s' "$CMD" | grep -q "git commit" || exit 0

# Husky (JS): if configured but not installed, try to repair so the project's
# own git hooks still run. Best-effort — never fatal.
if [ -f package.json ] && grep -q "husky" package.json; then
  if [ ! -d node_modules/husky ] && [ ! -d .husky/_ ]; then
    echo "[WARN] Husky configured but not installed. Installing..."
    npm install --silent 2>/dev/null || true
    npx husky install 2>/dev/null || true
    [ ! -d node_modules/husky ] && echo "[WARN] Husky cannot be installed. Tests run manually."
  fi
fi

# Run the stack's test suite; block on failure (checked via PIPESTATUS so the
# `| tail` does not mask the real exit status).
if [ -f package.json ] && grep -q '"test"' package.json; then
  echo "Running tests before commit..."
  npm test 2>&1 | tail -20
  [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "BLOCKED: Tests failed. Fix before committing."; exit 2; }
elif [ -f pyproject.toml ] && command -v pytest >/dev/null 2>&1; then
  echo "Running tests before commit..."
  pytest --tb=short -q 2>&1 | tail -20
  [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "BLOCKED: Tests failed. Fix before committing."; exit 2; }
elif [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  echo "Running tests before commit..."
  go test ./... 2>&1 | tail -20
  [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "BLOCKED: Tests failed. Fix before committing."; exit 2; }
fi

exit 0
