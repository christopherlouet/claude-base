---
name: ops-ci-fix
description: Autonomous diagnosis and repair of failing CI/CD pipelines. Scan GitHub Actions workflows, identify failure causes, and apply fixes. Trigger when CI is broken, tests fail in CI, or workflows are stuck.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[workflow-name] [--dry-run]"
---

# CI Fixer — CI/CD Diagnosis and Repair

## Goal

Diagnose failing CI/CD pipelines, identify the root cause,
and apply automatic fixes when safe.

## Phase 1: Discovery and workflow state

### Scan the workflows

```bash
# List recent runs
gh run list --limit 20 --json databaseId,status,conclusion,name,createdAt,headBranch

# Identify workflow files
ls -la .github/workflows/
```

### Classify the state

| State | Criterion | Urgency |
|------|---------|---------|
| **Failed** | conclusion = failure | High |
| **Stuck** | status = in_progress for > 30 min | High |
| **Cancelled** | conclusion = cancelled (recurring) | Medium |
| **Stale** | No successful run for 7+ days | Low |

### Check the runners (if self-hosted)

```bash
# Runner status
gh api repos/{owner}/{repo}/actions/runners --jq '.runners[] | {name, status, busy}'
```

## Phase 2: Failure diagnosis

For each failing workflow:

### 2.1 Extract the logs

```bash
# Logs of the failed run
gh run view <run-id> --log-failed
```

### 2.2 Classify the cause

| Category | Patterns in logs | Typical fix |
|-----------|----------------------|-------------|
| **Test failure** | `FAIL`, `AssertionError`, `expect(` | Fix the test or the code |
| **Build error** | `error TS`, `SyntaxError`, `cannot find` | Fix the compilation error |
| **Dep install** | `npm ERR!`, `ERESOLVE`, `peer dep` | Fix package.json / lockfile |
| **Auth/secrets** | `401`, `403`, `secret not found` | Check the configured secrets |
| **Timeout** | `timed out`, `exceeded deadline` | Increase timeout or optimize |
| **Disk space** | `no space left`, `ENOSPC` | Clean caches / reduce artifacts |
| **Rate limit** | `rate limit`, `429` | Add retry / space out the requests |
| **Runner offline** | `no runner matching`, `offline` | Check self-hosted runners |
| **Flaky test** | Sometimes passes, sometimes fails | Identify the flaky test, stabilize it |
| **Config error** | `invalid workflow`, `syntax error` | Fix the workflow YAML |

### 2.3 Distinguish local error vs CI-only

```bash
# Reproduce locally
npm test          # or pytest, go test, etc.
npm run build
npm run lint
```

If it passes locally but fails in CI: environment issue (versions, secrets, cache).

## Phase 3: Repair

### Fix priority order (from safest to riskiest)

1. **Re-run**: flaky workflows → `gh run rerun <run-id>`
2. **Fix config**: invalid YAML → edit `.github/workflows/`
3. **Fix deps**: corrupted lockfile → `rm -rf node_modules package-lock.json && npm install`
4. **Fix tests**: breaking test → identify and fix
5. **Fix build**: compilation error → fix the source code
6. **Cancel stuck**: stuck workflows → `gh run cancel <run-id>`

### Guardrails

IMPORTANT: In `--dry-run` mode, show the proposed actions WITHOUT executing them.

| Action | Safe | Confirmation required |
|--------|------|---------------------|
| Re-run a workflow | Yes | No |
| Cancel a stuck run | Yes | No |
| Fix workflow YAML | Medium | Show the diff first |
| Regenerate lockfile | Medium | Show the diff first |
| Modify source code | Risky | Yes — propose, do not apply without approval |
| Modify secrets | Risky | Never — guide the user |

### Applying fixes

For each applicable fix:

1. Identify the precise root cause (not the symptom)
2. Propose the minimal fix
3. Apply if safe, otherwise show and wait for confirmation
4. Verify the fix: re-run the workflow or run the tests locally

## Phase 4: Verification

After the fixes:

```bash
# Check that tests pass locally
npm test && npm run build && npm run lint

# If a workflow was re-run, check its status
gh run view <run-id> --json status,conclusion
```

### Validation loop (max 2 iterations)

1. Apply the fix
2. Verify (local tests + re-run CI if possible)
3. If still failing: re-diagnose with the new logs
4. If 2 iterations fail: escalate with a detailed report

## Phase 5: Report

```markdown
# CI Fix Report — YYYY-MM-DD

## Workflows analyzed
| Workflow | Branch | Status before | Cause | Action | Status after |
|----------|---------|-------------|-------|--------|-------------|
| ci.yml | main | Failed | Test failure | Fix test | Passing |
| deploy.yml | main | Stuck | Timeout | Cancel + re-run | In progress |

## Fixes applied
1. [Fix 1]: description, modified file, reason
2. [Fix 2]: ...

## Manual actions required
- [ ] Configure the `DEPLOY_TOKEN` secret (expired)
- [ ] Update the self-hosted runner v2.x → v3.x

## Recommendations
- Add a cache for npm ci (would reduce time by 3 min)
- The `auth.spec.ts` test is flaky (3 failures out of 10 runs)
```

## Rules

- ALWAYS diagnose before fixing (Phase 2 before Phase 3)
- NEVER modify secrets — guide the user
- NEVER force-push or modify git history
- ALWAYS show the diff of workflow modifications before applying
- When in doubt, propose the fix without applying it
- Follow the 3-failures rule: after 2 failed fix iterations, escalate
