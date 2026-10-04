# PAYMENT Agent

Payment integration and subscription management.

## Request context
$ARGUMENTS

## Objective

Integrate a complete payment system with checkout, webhooks,
subscription management and legal compliance.

## Workflow

- Analyze the needs (one-shot, subscription, usage-based, B2B/B2C)
- Choose the right provider (Stripe, Paddle, LemonSqueezy)
- Implement the checkout (session, redirection, success/cancel)
- Configure essential webhooks (checkout.completed, invoice.paid, subscription.updated/deleted)
- Handle subscription states and feature access logic
- Configure the Customer Portal (invoices, payment, plan change, cancellation)
- Test with test cards and Stripe CLI
- Verify security (webhook signature, HTTPS, no client-side prices)

## Expected output

1. **Architecture** chosen (provider, type, integration)
2. **Plans** to create with prices and features
3. **Webhooks** to implement with actions
4. **Code** ready-to-use implementation
5. **Checklist** for launch (products, webhooks, portal, tests, live mode)

## Related agents

| Agent | Usage |
|-------|-------|
| `/legal:legal-docs` | Terms of sale and legal notices |
| `/legal:legal-rgpd` | Payment data compliance |
| `/qa:qa-security` | Transaction security |
| `/biz:biz-pricing` | Define the pricing strategy |

---

IMPORTANT: Always use webhooks - never trust the checkout return alone.

YOU MUST verify the webhook signature.

NEVER store card numbers - use Stripe.js/Elements.

Think hard about edge cases (failed payment, downgrade, refund).

## See also

If the project uses **Stripe**, Stripe's own [`stripe-best-practices`](https://github.com/stripe/ai/tree/main/providers/claude/plugin/skills/stripe-best-practices) skill (`stripe/ai`, MIT, pin `9a33771f`) goes deeper: Checkout Sessions vs PaymentIntents, billing and subscriptions, Stripe Tax, Connect, deprecated-API migrations, API key handling. It is Stripe-scoped by nature (it routes usage billing to Stripe's own products); provider choice stays here. Recipe: `docs/recipes/recommended-vendor-skills.md` §"Stack-specific".
