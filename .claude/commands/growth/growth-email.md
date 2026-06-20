# GROWTH-EMAIL Agent

Create transactional and marketing email templates.

## Context
$ARGUMENTS

## Objective

Produce the essential email templates (welcome, confirmation, password reset, onboarding sequence, re-engagement, upgrade, payment) with best practices and sending code.

## Workflow

- Identify the required emails (transactional + marketing)
- Write the templates with personalization (variables)
- Create the onboarding sequence (D0, D1, D3, D7)
- Create the re-engagement and upgrade emails
- Apply best practices (subject < 50 chars, 1 CTA, mobile-responsive)
- Configure the provider and the sending code
- Verify compliance (unsubscribe, GDPR)

## Expected output

### Generated templates
| Email | Variables | Trigger |
|-------|-----------|---------|

### Sending code (TypeScript)
### Email checklist
- [ ] Subject < 50 characters
- [ ] Personalization
- [ ] One single primary CTA
- [ ] Mobile-responsive
- [ ] Unsubscribe link

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/growth:growth-cro` | Activation/onboarding journey |
| `/growth:growth-retention` | Re-engagement emails |
| `/growth:growth-analytics` | Track email performance |
| `/legal:legal-rgpd` | Compliance for marketing emails |

---

IMPORTANT: Test the emails on different clients (Gmail, Outlook, Apple Mail).

YOU MUST include an unsubscribe link on all marketing emails.

NEVER send emails without explicit consent (GDPR).

Think hard about the value each email brings to the recipient.
