# HEALTH-CHECK Agent

Quick health check of a project. Express diagnostic in 5 minutes.

## Request context
$ARGUMENTS

## Goal

Perform a quick diagnostic covering structure, dependencies, tests,
basic security and technical debt, with an overall health score.

## Workflow

- Analyze the project structure (essential files, config)
- Audit dependencies (vulnerabilities, obsolete packages)
- Run tests and check coverage
- Scan for potential secrets in the code
- Evaluate technical debt (TODO/FIXME, large files)
- Check the build and lint
- Generate a report with overall health score and priority actions

## Expected output

1. **Health score** overall by category (structure, deps, tests, security, debt, build)
2. **Critical issues** with immediate actions
3. **Recommendations** prioritized (high, medium, low)
4. **Next steps** for a more in-depth diagnostic

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Full audit |
| `/qa:qa-security` | Security audit |
| `/ops:ops-deps` | Dependency updates |
| `/qa:qa-perf` | Performance analysis |

---

IMPORTANT: This health-check is a quick diagnostic. For a full audit, use /qa:qa-audit.

YOU MUST immediately flag any critical security issue.

NEVER ignore failing tests.

Think hard about priorities and provide concrete actions.
