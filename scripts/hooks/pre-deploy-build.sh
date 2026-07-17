#!/usr/bin/env bash
# =============================================================================
# pre-deploy-build.sh — PreToolUse hook (Bash).
#
# Before a deploy command, run the project's PRODUCTION build and BLOCK the
# deploy (exit 2) if it fails — "never ship a broken build". Extracted from an
# inline settings.json `bash -c` gate (which shipped with ZERO test coverage)
# and fixed:
#
#   the inline version blocked on a failed `npm run build`, but the Go branch
#   ran `go build ./...` and IGNORED its exit status (no PIPESTATUS check, no
#   exit 2) — so a broken Go build sailed straight through to the deploy. This
#   version blocks on a failed Go build too.
#
# The trigger is preserved from the inline gate (a deploy-ish command): the
# build is expensive, so the match stays deliberately narrow to avoid running
# it on unrelated commands. No jq / not a deploy command /
# SKIP_PRE_DEPLOY_BUILD=1 → no-op (exit 0).
# Payload on STDIN as JSON (.tool_input.command).
# =============================================================================
set -u

[ "${SKIP_PRE_DEPLOY_BUILD:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

CMD=$(cat | jq -r '.tool_input.command // empty' 2>/dev/null || true)
# Trigger detection lives in the harness-neutral core _policy-triggers.sh
# (specs/agnostic-core/ core/shell split; directly tested by
# tests/policy-triggers.bats). Missing core → no-op (the build gate is
# advisory; the deploy pipeline's own checks remain the backstop).
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-triggers.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-triggers.sh" ]; then . "$_dir/_policy-triggers.sh"; else exit 0; fi
is_deploy_command "$CMD" || exit 0

echo "=== Pre-deploy build check ==="

# Build with the stack's production build; block on failure. PIPESTATUS is
# checked so the `| tail` does not mask the real exit status.
if [ -f package.json ] && grep -q '"build"' package.json; then
  echo "[1/1] Build prod..."
  npm run build --silent 2>&1 | tail -5
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "BLOCKED: Production build failed. Fix before deploying."
    exit 2
  fi
  echo "Build OK"
elif [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  echo "[1/1] Go build..."
  go build ./... 2>&1 | tail -5
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "BLOCKED: Go build failed. Fix before deploying."
    exit 2
  fi
  echo "Build OK"
fi

echo "=== Pre-deploy check OK ==="
exit 0
