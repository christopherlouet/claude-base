---
sidebar_position: 4
title: "/legal:legal-privacy-policy"
description: "Generates a Privacy Policy compliant with GDPR and international standards."
tags:
  - "legal"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--legal">LEGAL</span>


# PRIVACY-POLICY Agent

Generates a Privacy Policy compliant with GDPR and international standards.

## Request context
`<arguments>`

## Objective

Create a transparent, complete privacy policy compliant
with data protection regulations (GDPR, CCPA).

## Workflow

- Identify the data controller and the DPO
- List collected data (directly, automatically, via third parties)
- Document the purposes and legal bases of each processing operation
- Identify recipients and sub-processors with guarantees
- Document transfers outside the EU and protection mechanisms
- Define retention periods by data type
- Detail data subjects' rights and how to exercise them
- Describe the cookie policy and security measures
- Generate the GDPR checklist (Articles 13-14)

## Expected output

1. **Complete and structured privacy policy**
2. **Processing table** (data, purpose, legal basis, duration)
3. **List of sub-processors** with countries and guarantees
4. **GDPR compliance checklist**

## Related agents

| Agent | Usage |
|-------|-------|
| `/legal:legal-rgpd` | Full GDPR compliance audit |
| `/legal:legal-terms-of-service` | Terms of Service |
| `/legal:legal-docs` | Other legal documents |

---

IMPORTANT: This policy is a template. Have it validated by a legal expert/DPO.

YOU MUST adapt the policy to the actual processing operations performed.

YOU MUST keep the policy up to date when changes occur.

NEVER collect more data than necessary (minimization).


---

## See also

- [Back to LEGAL commands](/docs/commands/legal)
- [All commands](/docs/commands)
