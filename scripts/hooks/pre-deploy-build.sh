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
# Trigger on the common deploy invocations. The previous pattern required the
# word "deploy" TWICE (or a literal deploy.sh), so it was INERT on `npm run
# deploy`, `vercel deploy`, `make deploy`, … — the gate silently never ran.
# Still deliberately scoped (the build is expensive) and matches "deploy" as a
# verb/subcommand, so `npm run build` and other non-deploy commands don't fire.
printf '%s' "$CMD" | grep -qiE '(^|[[:space:]&|;])((npm|yarn|pnpm)[[:space:]]+(run[[:space:]]+)?deploy|(vercel|netlify|wrangler|serverless|sls|flyctl|fly|firebase|eas|kamal|dokku)[[:space:]]+([^&|;]*[[:space:]])?deploy|make[[:space:]]+([^&|;]*[[:space:]])?deploy|(\./)?deploy\.sh)' || exit 0

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
