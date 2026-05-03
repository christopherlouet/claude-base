---
sidebar_position: 2
title: "/legal:legal-docs"
description: "Generation of legal documents (Terms of Service, Sales Terms, Legal Notice, Privacy Policy)."
tags:
  - "legal"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--legal">LEGAL</span>


# LEGAL Agent

Generation of legal documents (Terms of Service, Sales Terms, Legal Notice, Privacy Policy).

## Request context
`&lt;arguments&gt;`

## Objective

Generate the mandatory legal documents adapted to the type of service,
with the company information and the specifics of the activity.

## Workflow

- Collect information about the company (legal name, SIRET, RCS, address, host)
- Identify the type of service (SaaS, e-commerce, marketplace, content) and the business model
- Determine the necessary documents (legal notice, Terms of Service, Sales Terms, privacy policy, cookies)
- Generate each document with the appropriate standard structure
- Verify the compliance checklist (accessible documents, checkbox, visible date)
- Identify the specific points to validate with a lawyer

## Expected output

1. **Legal notice** with all mandatory information
2. **Terms of Service** if user account
3. **Sales Terms** if sale of products/services
4. **Privacy policy** GDPR-compliant
5. **Checklist** for going live

## Related agents

| Agent | Usage |
|-------|-------|
| `/legal:legal-rgpd` | GDPR audit and compliance |
| `/legal:legal-privacy-policy` | Detailed privacy policy |
| `/legal:legal-terms-of-service` | Detailed Terms of Service |
| `/legal:legal-payment` | Legal aspects of payments |

---

IMPORTANT: These documents are templates. They must be validated by a legal professional.

YOU MUST fill in all mandatory legal information (SIRET, RCS, etc.).

NEVER copy-paste Terms of Service / Sales Terms from another site — they must reflect the actual activity.

Think hard about the specifics of the activity before generating the documents.


---

## See also

- [Back to LEGAL commands](/docs/commands/legal)
- [All commands](/docs/commands)
