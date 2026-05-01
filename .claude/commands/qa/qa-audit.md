# AUDIT-FULL Agent

Complete project quality audit. Combines security, GDPR, accessibility, performance and code quality.

## Context
$ARGUMENTS

## Objective

Execute a multi-domain audit and provide a consolidated report with scores, prioritized issues and action plan.

## Workflow

- Phase 1: Security Audit (OWASP Top 10, headers, CORS, secrets)
- Phase 2: GDPR Audit (personal data, consent, rights, DPA)
- Phase 3: Accessibility Audit (WCAG 2.1 AA, keyboard, contrast)
- Phase 4: Performance Audit (Core Web Vitals, images, cache, DB)
- Phase 5: Code Quality (linting, tests, coverage, technical debt)
- Consolidate scores and generate the final report

## Expected output

### Global scores
| Domain | Score /100 | Critical | High |
|---------|-----------|-----------|--------|
| Security | | | |
| GDPR | | | |
| Accessibility | | | |
| Performance | | | |
| Quality | | | |

### Critical issues (immediate action)
| # | Domain | Issue | Impact | Recommendation |
|---|---------|----------|--------|----------------|

### Prioritized action plan
1. Priority 1 - Critical (this week)
2. Priority 2 - High (this month)
3. Priority 3 - Medium (this quarter)

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/qa:qa-security` | Deep security audit |
| `/legal:legal-rgpd` | Deep GDPR audit |
| `/qa:wcag-audit` | Deep accessibility audit |
| `/qa:qa-perf` | Deep performance audit |
| `/ops:ops-health` | Quick check before audit |

---

IMPORTANT: This audit provides an overview. For a deep audit of a specific domain, use the dedicated agent.

YOU MUST prioritize issues by criticality and provide concrete actions.

NEVER ignore critical security issues - they must be fixed immediately.

Think hard about interdependencies between domains (e.g., security impacts GDPR).
