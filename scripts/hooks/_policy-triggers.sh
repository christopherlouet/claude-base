#!/usr/bin/env bash
# =============================================================================
# _policy-triggers.sh — Harness-neutral trigger detection for the build gates
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/), shared by the
# three gate shells: pre-commit-tests.sh, pre-push-ci.sh, pre-deploy-build.sh.
# Each function answers ONE question about a raw command string — "is this a
# real <commit|push|deploy> invocation?" — so the payload-vs-flag distinction
# (a message merely NAMING the operation) is decided in exactly one place per
# trigger.
#
#   is_git_commit_command <cmd>   0 = a real `git … commit` in command position
#   is_git_push_command <cmd>     0 = a real `git … push` in command position
#                                 (message/--grep values stripped first)
#   is_deploy_command <cmd>       0 = a deploy invocation
#
# What the gates RUN once triggered (npm test, ruff, go build, …) is
# stack detection against the machine, not policy — it stays in the shells.
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only, no top-level side effects beyond
# sourcing the shared strip helper.
# =============================================================================

# Avoid double-sourcing
if [ -n "${POLICY_TRIGGERS_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
POLICY_TRIGGERS_LOADED=1

# --- policy bootstrap (keep byte-identical across _policy-*.sh; guarded by policy-structure.bats) ---
# Shared message/--grep/--file value strip (single canonical copy in
# _core-helpers.sh). Missing helper file → no-op strip fallback: message
# payloads may then over-block, but a missing file can never turn into a
# silent bypass. POLICY_HAVE_CORE_STRIP keys on CORE_HELPERS_LOADED, NOT on
# `declare -F` alone: a sibling policy lib's no-op fallback also satisfies
# declare -F, and mistaking it for the real strip would skip the per-segment
# defenses that assume values were really stripped (pass-3 false-block class).
_policy_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=_core-helpers.sh
if [ -n "$_policy_dir" ] && [ -f "$_policy_dir/_core-helpers.sh" ]; then . "$_policy_dir/_core-helpers.sh"; fi
# shellcheck disable=SC2034  # consumed by dangerous-commands Category 9; set in every copy so the bootstrap stays byte-identical
if [ -n "${CORE_HELPERS_LOADED:-}" ] && declare -F strip_msg_values >/dev/null 2>&1; then
  POLICY_HAVE_CORE_STRIP=1
else
  POLICY_HAVE_CORE_STRIP=0
  declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }
fi
# --- end policy bootstrap ---

# Fire only on an actual `git … commit` at command position, tolerating global
# options (`git -c core.hooksPath=… commit`, `git -C dir commit`). A plain
# substring match both over-blocked read-only commands (`git log --grep "git
# commit"`) and MISSED the `git -c … commit` bypass form.
is_git_commit_command() {
  printf '%s' "$1" | grep -qE '(^|[;&|])[[:space:]]*git([[:space:]]+-[a-zA-Z]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+commit([[:space:]]|$)'
}

# `git [global-opts] push` in COMMAND position: start of a line/segment or
# after ; & | — a message or --grep payload merely NAMING "git push" is data.
# Lead-ins cover wrapper words, `VAR=…` env assignments and sudo; git itself
# may be path-prefixed (/usr/bin/git). Terminator accepts ;&| glued to push
# (`git push;echo done`). Misses fail OPEN (real CI still gates the branch).
is_git_push_command() {
  printf '%s' "$(strip_msg_values "$1")" \
    | grep -qE '(^|[;&|])[[:space:]]*((command|env|nohup|nice|sudo)[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:];&|]*[[:space:]]+)*([^[:space:];&|]*/)?git[[:space:]]+(-[^[:space:]]+[[:space:]]+([^-][^[:space:]]*[[:space:]]+)?)*push([[:space:]]|$|[;&|])'
}

# Trigger on the common deploy invocations. An earlier pattern required the
# word "deploy" TWICE (or a literal deploy.sh), so it was INERT on `npm run
# deploy`, `vercel deploy`, `make deploy`, … — the gate silently never ran.
# Still deliberately scoped (the build is expensive) and matches "deploy" as a
# verb/subcommand, so `npm run build` and other non-deploy commands don't fire.
is_deploy_command() {
  printf '%s' "$1" | grep -qiE '(^|[[:space:]&|;])((npm|yarn|pnpm)[[:space:]]+(run[[:space:]]+)?deploy|(vercel|netlify|wrangler|serverless|sls|flyctl|fly|firebase|eas|kamal|dokku)[[:space:]]+([^&|;]*[[:space:]])?deploy|make[[:space:]]+([^&|;]*[[:space:]])?deploy|(\./)?deploy\.sh)'
}
