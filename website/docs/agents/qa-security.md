---
sidebar_position: 59
title: "qa-security"
description: "OWASP Top 10 security audit. The `qa-security` skill provides the detailed checklist."
tags:
  - "agent"
  - "opus"
---

# Agent: qa-security

<span className="badge badge--opus">Opus</span>

> OWASP Top 10 security audit. The `qa-security` skill provides the detailed checklist.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | opus |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | `Edit`, `Write`, `NotebookEdit` |
| **Injected skills** | `qa-security` |

## Detailed description

# Agent QA-SECURITY

OWASP Top 10 security audit. The `qa-security` skill provides the detailed checklist.

## Expected output

### Summary
- **Overall risk level**: [Critical/High/Medium/Low]
- **Vulnerabilities found**: [number]

### Detailed vulnerabilities
| Severity | OWASP category | File:Line | Description | Remediation |
|----------|----------------|-----------|-------------|-------------|

### Priority recommendations
1. [Immediate action]
2. [Short-term action]
3. [Medium-term action]

## Constraints

- Check all 10 OWASP categories without exception
- Never ignore critical vulnerabilities
- Propose concrete remediations with code examples

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
