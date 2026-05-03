---
sidebar_position: 5
title: "/legal:legal-rgpd"
description: "GDPR compliance audit of a project."
tags:
  - "legal"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--legal">LEGAL</span>


# GDPR Agent

GDPR compliance audit of a project.

## Request context
`&lt;arguments&gt;`

## Objective

Analyze the codebase to identify the personal data collected,
verify GDPR compliance and propose a prioritized action plan.

## Workflow

- Scan the code to identify personal data (email, phone, IP, etc.)
- Map data flows (collection, storage, transmission)
- Verify the legal basis of each processing (Art. 6)
- Audit consent and cookies (banner, blocking, dark patterns)
- Verify the implementation of data subject rights (access, rectification, erasure, portability)
- Analyze retention periods and purge mechanisms
- Identify transfers outside the EU and the safeguards
- Verify data security (encryption, hashing, RBAC)
- Generate the draft of the processing register (Art. 30)

## Expected output

1. **Compliance summary** with estimated level
2. **Personal data** identified with location and legal basis
3. **Compliance by domain** (consent, rights, retention, transfers, security)
4. **Critical non-compliance** with recommendations
5. **Action plan** prioritized

## Related agents

| Agent | Usage |
|-------|-------|
| `/legal:legal-docs` | Complete legal documents |
| `/legal:legal-privacy-policy` | Privacy policy |
| `/qa:qa-security` | Data security |

---

IMPORTANT: This audit is a technical analysis of the code. It does not replace legal advice.

YOU MUST identify all personal data flows, including to third-party services.

NEVER consider that a popular service is automatically GDPR-compliant.

Think hard about the data flows and risks before concluding.


---

## See also

- [Back to LEGAL commands](/docs/commands/legal)
- [All commands](/docs/commands)
