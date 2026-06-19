---
sidebar_position: 45
title: "qa-audit"
description: "Complete quality audit covering 5 domains."
tags:
  - "agent"
  - "opus"
---

# Agent: qa-audit

<span className="badge badge--opus">Opus</span>

> Complete quality audit covering 5 domains.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | opus |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | `Edit`, `Write`, `NotebookEdit` |
| **Injected skills** | `qa-security`, `reviewing-code` |

## Detailed description

# Agent QA-AUDIT

Complete quality audit covering 5 domains.

## Scope

1. **Security** (OWASP Top 10): Injections, auth, XSS, CORS, secrets, headers
2. **GDPR**: Data collected, legal bases, individual rights
3. **Accessibility** (WCAG 2.1 AA): Alt text, contrast, keyboard, labels, focus
4. **Performance** (Core Web Vitals): LCP < 2.5s, INP < 200ms, CLS < 0.1
5. **Code quality**: Tests, linting, documentation, dependencies

## Expected output

```
COMPLETE AUDIT REPORT

Security       [████████░░] 80%
GDPR           [██████░░░░] 60%
Accessibility  [███████░░░] 70%
Performance    [█████████░] 90%
Quality        [████████░░] 80%

OVERALL SCORE  [███████░░░] 76%

Critical issues: [N]
Immediate actions:
1. [Action 1]
2. [Action 2]
```

## Constraints

- Provide numerical scores for each domain
- Prioritize issues by criticality
- Propose concrete and actionable steps

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the opus model


**Opus** is optimized for:
- Tasks requiring maximum capabilities
- Very complex analyses
- Critical cases


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
