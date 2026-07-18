#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/hooks/_policy-triggers.sh — the harness-neutral
# trigger detection shared by the three build/test gates (pre-commit-tests,
# pre-push-ci, pre-deploy-build).
#
#   is_git_commit_command <cmd>   0 = a real `git … commit` in command position
#   is_git_push_command <cmd>     0 = a real `git … push` in command position
#                                 (message values stripped first)
#   is_deploy_command <cmd>       0 = a deploy invocation
#
# Per the guardrail-testing lesson: matchers are exercised across argument
# orderings AND payload-embedding (trigger token inside a message value).
# =============================================================================

load 'test_helper'

POLICY="$BASE_DIR/scripts/hooks/_policy-triggers.sh"

t_commit() { run bash -c ". '$POLICY'; is_git_commit_command \"\$1\"" _ "$1"; }
t_push()   { run bash -c ". '$POLICY'; is_git_push_command \"\$1\"" _ "$1"; }
t_deploy() { run bash -c ". '$POLICY'; is_deploy_command \"\$1\"" _ "$1"; }

@test "policy-trig: core file exists, sourceable, functions defined" {
    [ -f "$POLICY" ]
    run bash -c "set -euo pipefail; . '$POLICY'; declare -F is_git_commit_command >/dev/null && declare -F is_git_push_command >/dev/null && declare -F is_deploy_command >/dev/null"
    [ "$status" -eq 0 ]
}

# --- commit trigger ----------------------------------------------------------

@test "policy-trig: matches plain git commit" {
    t_commit 'git commit -m "x"'
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches git with global options before commit" {
    t_commit 'git -c core.hooksPath=/dev/null commit -m x'
    [ "$status" -eq 0 ]
    t_commit 'git -C subdir commit -m x'
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches a chained commit after &&" {
    t_commit 'npm test && git commit -m x'
    [ "$status" -eq 0 ]
}

@test "policy-trig: does NOT match git log --grep 'git commit'" {
    t_commit 'git log --grep "git commit"'
    [ "$status" -eq 1 ]
}

@test "policy-trig: does NOT match a non-git command" {
    t_commit "npm run build"
    [ "$status" -eq 1 ]
}

# --- push trigger ------------------------------------------------------------

@test "policy-trig: matches plain git push" {
    t_push "git push origin main"
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches env-assignment and wrapper lead-ins" {
    t_push "GIT_TRACE=1 git push"
    [ "$status" -eq 0 ]
    t_push "command git push"
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches abs-path git push with glued separator" {
    t_push "/usr/bin/git push;echo done"
    [ "$status" -eq 0 ]
}

@test "policy-trig: does NOT match 'git push' inside a commit message" {
    t_push 'git commit -m "docs: explain the git push flow"'
    [ "$status" -eq 1 ]
}

@test "policy-trig: does NOT match git push mentioned via --grep" {
    t_push 'git log --grep "git push"'
    [ "$status" -eq 1 ]
}

# --- deploy trigger ----------------------------------------------------------

@test "policy-trig: matches npm run deploy" {
    t_deploy "npm run deploy"
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches vercel/netlify/fly deploys" {
    t_deploy "vercel deploy --prod"
    [ "$status" -eq 0 ]
    t_deploy "netlify deploy"
    [ "$status" -eq 0 ]
    t_deploy "flyctl deploy"
    [ "$status" -eq 0 ]
}

@test "policy-trig: matches make deploy and ./deploy.sh" {
    t_deploy "make deploy"
    [ "$status" -eq 0 ]
    t_deploy "./deploy.sh"
    [ "$status" -eq 0 ]
}

@test "policy-trig: does NOT match npm run build" {
    t_deploy "npm run build"
    [ "$status" -eq 1 ]
}

@test "policy-trig: empty command matches no trigger" {
    t_commit ""
    [ "$status" -eq 1 ]
    t_push ""
    [ "$status" -eq 1 ]
    t_deploy ""
    [ "$status" -eq 1 ]
}
