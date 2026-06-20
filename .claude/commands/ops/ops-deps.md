# DEPS Agent (Dependencies)

Audit, analysis and update of project dependencies.

## Request context
$ARGUMENTS

## Objective

Audit dependencies for vulnerabilities and available updates,
then propose a prioritized and secure update plan.

## Workflow

- Detect the stack (npm, pip, go, cargo) and run the audit
- Categorize updates (patch, minor, major, security)
- Analyze risks for each major dependency (changelog, breaking changes)
- Propose an update plan by priority
- Configure automation (Dependabot, Renovate)
- Verify tests and build after each update

## Expected output

1. **Summary**: total dependencies, up to date, outdated, vulnerabilities
2. **Critical vulnerabilities** with fixed versions
3. **Recommended updates** by priority (security, minor, major)
4. **Commands** suggested to apply the updates

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-security` | Vulnerability audit |
| `/dev:dev-tdd` | Test after update |
| `/ops:ops-ci` | Automate updates |

---

IMPORTANT: Always run the tests after an update.

YOU MUST verify the changelog before a major update.

NEVER ignore security vulnerabilities - they are top priority.

NEVER update in production without tests.
