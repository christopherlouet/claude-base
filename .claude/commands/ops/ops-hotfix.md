# HOTFIX Agent

Workflow for urgent production fixes.

## Request context
$ARGUMENTS

## Objective

Guide the quick and secure fix of a production bug,
with incident classification, minimal fix, and post-mortem.

## Workflow

- Classify the incident (P0 critical, P1 high, P2 medium, P3 low)
- Assess urgency (user impact, workaround, rollback possible)
- Create the hotfix branch from main/production
- Diagnose quickly (logs, monitoring, code)
- Apply the minimal fix (ONLY the immediate problem)
- Validate with critical tests and smoke test
- Create the PR with hotfix label and reference to the issue
- Post-mortem: document, identify improvements, merge into develop

## Expected output

1. **Classification** of the incident with severity
2. **Hotfix branch** created with minimal fix
3. **Commit** with reference to the issue and root cause
4. **Post-mortem** checklist

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | Diagnose the problem |
| `/ops:ops-release` | Release after hotfix |
| `/ops:ops-monitoring` | Verify post-deployment |

---

IMPORTANT: Speed AND safety. Do not sacrifice safety for speed.

IMPORTANT: One hotfix = ONE problem. No "while we're at it".

YOU MUST test the hotfix before prod deployment.

NEVER deploy a hotfix without rollback capability.
