#!/usr/bin/env bash
# =============================================================================
# pre-push-ci.sh — PreToolUse hook (Bash).
#
# Runs the project's local CI (lint / type-check / tests, per detected stack)
# before a REAL `git push`, and blocks the push (exit 2) when it is red — a
# red push wastes a CI round-trip and, with required status checks, a merge
# slot. Extracted from the last big inline settings.json `bash -c` gate, which
# shipped with zero test coverage and fired on PAYLOADS: its whole-command
# `grep -q "git push"` ran the full local CI for
# `git commit -m "docs: explain the git push flow"` — and blocked the commit
# if CI was red. Now message values are stripped (shared helper) and
# `git push` must be in COMMAND position.
#
# Stacks: Node (package.json scripts: lint / typecheck / tsc / test),
# Python (ruff / mypy / pytest when present), Go (vet + test).
# Disable with SKIP_PRE_PUSH_CI=1.
# =============================================================================
set -u

[ "${SKIP_PRE_PUSH_CI:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

CMD=$(cat 2>/dev/null | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

# Shared message-value strip; missing helper degrades to no strip (a payload
# mentioning "git push" may then over-trigger — never the reverse).
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_hook-helpers.sh
if [ -n "$_dir" ] && [ -f "$_dir/_hook-helpers.sh" ]; then . "$_dir/_hook-helpers.sh"; fi
declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }

# `git [global-opts] push` in COMMAND position: start of a line/segment or
# after ; & | — a message or --grep payload merely NAMING "git push" is data.
if ! printf '%s' "$(strip_msg_values "$CMD")" \
    | grep -qE '(^|[;&|])[[:space:]]*((command|env|nohup|nice)[[:space:]]+)*git[[:space:]]+(-[^[:space:]]+[[:space:]]+([^-][^[:space:]]*[[:space:]]+)?)*push([[:space:]]|$)'; then
  exit 0
fi

echo "=== Pre-push CI check ==="
FAILED=0

if [ -f package.json ]; then
  if grep -q '"lint"' package.json; then
    echo "[1/3] Lint..."
    npm run lint --silent 2>&1 | tail -5
    [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "FAILED: Lint"; FAILED=1; }
  fi
  if grep -q '"typecheck"' package.json; then
    echo "[2/3] Type-check..."
    npm run typecheck --silent 2>&1 | tail -5
    [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "FAILED: Type-check"; FAILED=1; }
  elif [ -f tsconfig.json ] && [ -f node_modules/.bin/tsc ]; then
    echo "[2/3] tsc --noEmit..."
    npx tsc --noEmit 2>&1 | tail -5
    [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "FAILED: TypeScript"; FAILED=1; }
  fi
  if grep -q '"test"' package.json; then
    echo "[3/3] Tests..."
    npm test --silent 2>&1 | tail -10
    [ "${PIPESTATUS[0]}" -ne 0 ] && { echo "FAILED: Tests"; FAILED=1; }
  fi
elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  if command -v ruff >/dev/null 2>&1; then
    echo "[1/3] Ruff..."
    ruff check . 2>&1 | tail -5
    [ "${PIPESTATUS[0]}" -ne 0 ] && FAILED=1
  fi
  if command -v mypy >/dev/null 2>&1; then
    echo "[2/3] Mypy..."
    mypy . --ignore-missing-imports 2>&1 | tail -5
    [ "${PIPESTATUS[0]}" -ne 0 ] && FAILED=1
  fi
  if command -v pytest >/dev/null 2>&1; then
    echo "[3/3] Pytest..."
    pytest --tb=short -q 2>&1 | tail -10
    [ "${PIPESTATUS[0]}" -ne 0 ] && FAILED=1
  fi
elif [ -f go.mod ]; then
  echo "[1/2] Go vet..."
  go vet ./... 2>&1 | tail -5
  [ "${PIPESTATUS[0]}" -ne 0 ] && FAILED=1
  echo "[2/2] Go test..."
  go test ./... 2>&1 | tail -10
  [ "${PIPESTATUS[0]}" -ne 0 ] && FAILED=1
fi

if [ "$FAILED" -ne 0 ]; then
  echo "BLOCKED: Local CI failed. Fix before pushing. (Bypass once: SKIP_PRE_PUSH_CI=1.)"
  exit 2
fi
echo "=== Local CI OK ==="
exit 0
