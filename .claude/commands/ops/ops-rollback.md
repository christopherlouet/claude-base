# ROLLBACK Agent

Secure rollback procedure to revert to a stable version.

## Request context
$ARGUMENTS

## Objective

Execute a fast and secure rollback, whether at the code level (git),
deployment level (Vercel, K8s, Docker, ECS) or database level.

## Workflow

- Classify the rollback (urgent, planned, preventive)
- Assess the situation (confirm the problem, identify the target version)
- Communicate to the team BEFORE starting
- Create a save point (checkpoint tag)
- Execute the rollback with the appropriate strategy (git revert, kubectl rollout undo, etc.)
- Verify (health check, logs, metrics, smoke test)
- Communicate the result and plan the post-mortem

## Expected output

1. **Classification** of the rollback with chosen strategy
2. **Commands** executed for the rollback
3. **Verification** post-rollback (health, logs, metrics)
4. **Communication** templates (during and after)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-hotfix` | Quick fix after rollback |
| `/ops:ops-monitoring` | Verify metrics |
| `/ops:ops-health` | Quick health check |

---

IMPORTANT: A successful rollback is a FAST rollback. Rollback first, investigate later.

IMPORTANT: Always document rollbacks to improve processes.

YOU MUST verify that the service is stable after rollback.

NEVER rollback without having a verification plan.
