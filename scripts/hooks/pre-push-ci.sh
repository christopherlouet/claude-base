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

# Trigger detection (incl. the message-value strip so a payload NAMING
# "git push" never runs the full local CI) lives in the harness-neutral core
# _policy-triggers.sh (specs/agnostic-core/ core/shell split; directly tested
# by tests/policy-triggers.bats). Missing core → no-op: misses fail OPEN, the
# real CI still gates the branch.
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-triggers.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-triggers.sh" ]; then
  . "$_dir/_policy-triggers.sh"
else
  echo >&2 "[pre-push-ci] policy core _policy-triggers.sh missing - pre-push CI gate DISABLED. Run 'claude-base update' to restore."
  exit 0
fi
# One time budget for the whole gate (_gate-budget.sh): a gate cut by the hook
# timeout would let the action through, so it blocks when the budget runs out.
# Missing helper → unbounded, as before.
if [ -n "$_dir" ] && [ -f "$_dir/_gate-budget.sh" ]; then
  # shellcheck source=_gate-budget.sh
  . "$_dir/_gate-budget.sh"
else
  gate_budget_init() { :; }
  gate_run() { "$@"; }
  gate_run_tail() { local n="$1"; shift; "$@" 2>&1 | tail -"$n"; return "${PIPESTATUS[0]}"; }
  gate_block_if_timed_out() { :; }
fi
is_git_push_command "$CMD" || exit 0
gate_budget_init

echo "=== Pre-push CI check ==="
FAILED=0

# `npm init -y` writes a test script that ALWAYS exits 1 — no npm suite, not a
# red one: running it refused every push of a fresh project. It means "no NPM
# suite" only: a package.json holding nothing else (husky in a Python or Go
# repo) does not claim the project, so the Python / Go checks still run. Exact
# match, and only when no pretest/posttest makes `npm test` a real suite.
NPM_PLACEHOLDER=0
if [ -f package.json ] && [ "$(jq -r 'if (.scripts.pretest // .scripts.posttest) then "" else (.scripts.test // "") end' package.json 2>/dev/null)" = 'echo "Error: no test specified" && exit 1' ]; then
  NPM_PLACEHOLDER=1
  echo "[npm] tests skipped: package.json test script is npm's placeholder. Replace it with a real test command."
fi

if [ -f package.json ] && { grep -q '"lint"' package.json || grep -q '"typecheck"' package.json \
     || { [ -f tsconfig.json ] && [ -f node_modules/.bin/tsc ]; } \
     || { [ "$NPM_PLACEHOLDER" = 0 ] && grep -q '"test"' package.json; }; }; then
  if grep -q '"lint"' package.json; then
    echo "[1/3] Lint..."
    gate_run_tail 5 npm run lint --silent
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && { echo "FAILED: Lint"; FAILED=1; }
  fi
  if grep -q '"typecheck"' package.json; then
    echo "[2/3] Type-check..."
    gate_run_tail 5 npm run typecheck --silent
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && { echo "FAILED: Type-check"; FAILED=1; }
  elif [ -f tsconfig.json ] && [ -f node_modules/.bin/tsc ]; then
    echo "[2/3] tsc --noEmit..."
    gate_run_tail 5 npx tsc --noEmit
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && { echo "FAILED: TypeScript"; FAILED=1; }
  fi
  if [ "$NPM_PLACEHOLDER" = 0 ] && grep -q '"test"' package.json; then
    echo "[3/3] Tests..."
    gate_run_tail 10 npm test --silent
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && { echo "FAILED: Tests"; FAILED=1; }
  fi
elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  if command -v ruff >/dev/null 2>&1; then
    echo "[1/3] Ruff..."
    gate_run_tail 5 ruff check .
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && FAILED=1
  fi
  if command -v mypy >/dev/null 2>&1; then
    echo "[2/3] Mypy..."
    gate_run_tail 5 mypy . --ignore-missing-imports
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && FAILED=1
  fi
  if command -v pytest >/dev/null 2>&1; then
    echo "[3/3] Pytest..."
    gate_run_tail 10 pytest --tb=short -q
    rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
    [ "$rc" -ne 0 ] && FAILED=1
  fi
elif [ -f go.mod ]; then
  echo "[1/2] Go vet..."
  gate_run_tail 5 go vet ./...
  rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
  [ "$rc" -ne 0 ] && FAILED=1
  echo "[2/2] Go test..."
  gate_run_tail 10 go test ./...
  rc=$?; gate_block_if_timed_out "$rc" "pre-push-ci"
  [ "$rc" -ne 0 ] && FAILED=1
fi

if [ "$FAILED" -ne 0 ]; then
  echo "BLOCKED: Local CI failed. Fix before pushing. (Bypass once: SKIP_PRE_PUSH_CI=1.)"
  exit 2
fi
echo "=== Local CI OK ==="
exit 0
