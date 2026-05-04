# Recipe: adding subscription / billing to a Next.js app

**Audience**: developers building a Next.js app who need to add a subscription system. NOT a recommendation that you should monetize — only guidance for the case where you've already decided you need to.

This recipe lives outside the `nextjs` preset deliberately. Subscription / billing is a product decision, not a stack essential. The preset bundles what every Next.js app needs (TypeScript, React patterns, accessibility, performance). Monetization patterns belong in a recipe you opt into, not in the default install.

---

## Why this is a recipe, not a preset

A preset bundles **plugins and rules essential to a stack**. Adding payment processing changes the application's domain model (users, subscriptions, billing portal, webhook handling, dunning, taxation), not the stack itself. Two developers using Next.js + Stripe will diverge wildly on:

- Which auth provider they pair it with (NextAuth/Auth.js, Clerk, better-auth, Supabase Auth, Lucia, custom)
- Which database to store subscription state (Postgres direct, Prisma, Drizzle, Supabase, PlanetScale)
- Which billing model (one-shot purchases, recurring subscriptions, usage-based, hybrid)
- Which deploy target (Vercel, self-hosted, AWS, GCP)

Bundling one specific path in a preset would be opinionated in a way that doesn't add value. Documenting the patterns we know work is useful. Hence this recipe.

---

## What you actually need to handle

If you're adding a subscription system to a Next.js app, you'll touch at minimum:

1. **A payment provider integration** — Stripe is the most common; Paddle, Lemon Squeezy, Polar are alternatives with different MoR / tax-handling tradeoffs
2. **Webhook handler** — receives subscription state changes from the provider, updates your DB
3. **Billing portal** — letting users manage their own subscriptions (most providers ship a hosted one)
4. **Subscription state in your DB** — `subscriptions` table or equivalent with status, plan, period_end, customer_id
5. **Access gates** — middleware or route checks that verify subscription status before serving paid content
6. **Idempotency on webhook handling** — webhooks can replay; your handler must be idempotent
7. **Dunning / failed payment flows** — what happens when a card declines on renewal
8. **Tax handling** — depending on your jurisdiction(s) and provider, you may need explicit VAT / sales tax handling
9. **Refund flow** — at minimum, a documented procedure (often manual through the provider dashboard)

The provider's docs cover 1-3 well. The rest is your code.

---

## Pattern 1: Stripe Checkout + webhook + Postgres

### Schema

```sql
CREATE TABLE subscriptions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  stripe_customer_id        text NOT NULL,
  stripe_subscription_id    text UNIQUE,
  status          text NOT NULL,
  plan            text,
  current_period_end        timestamptz,
  cancel_at_period_end      boolean DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
```

`status` mirrors Stripe's subscription lifecycle (`active`, `trialing`, `past_due`, `canceled`, `incomplete`, `unpaid`).

### Webhook route (Next.js App Router)

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from "next/headers";
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(req: Request) {
  const body = await req.text();
  const sig = (await headers()).get("stripe-signature");
  if (!sig) return new Response("missing signature", { status: 400 });

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, WEBHOOK_SECRET);
  } catch (err) {
    return new Response(`webhook verification failed: ${err}`, { status: 400 });
  }

  // Idempotency: skip if we've already processed this event
  if (await isEventProcessed(event.id)) {
    return new Response(null, { status: 200 });
  }

  switch (event.type) {
    case "customer.subscription.created":
    case "customer.subscription.updated":
    case "customer.subscription.deleted":
      await syncSubscription(event.data.object);
      break;
    case "invoice.payment_failed":
      await handleFailedPayment(event.data.object);
      break;
  }

  await markEventProcessed(event.id);
  return new Response(null, { status: 200 });
}
```

The `isEventProcessed` / `markEventProcessed` calls hit a `webhook_events` table keyed by Stripe event id. This is the idempotency guard — Stripe replays webhooks on transient failures and your handler must absorb that.

### Access gate (middleware)

```typescript
// middleware.ts
export async function middleware(req: NextRequest) {
  const session = await getSession(req);
  const path = req.nextUrl.pathname;

  if (!path.startsWith("/app")) return NextResponse.next();
  if (!session) return NextResponse.redirect(new URL("/login", req.url));

  const sub = await getActiveSubscription(session.userId);
  if (!sub) return NextResponse.redirect(new URL("/billing", req.url));

  return NextResponse.next();
}
```

`getActiveSubscription` reads from your DB, not from Stripe — webhook keeps it in sync. Querying Stripe on every request is slow and rate-limit-prone.

---

## Things that bite you

| Issue | Mitigation |
|---|---|
| Webhook retries on transient errors → duplicate processing | Idempotency table keyed on `event.id` |
| Stripe customer created without local user (email collision, signup race) | Always pass `client_reference_id` = your user id when creating Checkout Sessions; reconcile on webhook |
| Test card flows produce different webhook event order than prod | Use Stripe CLI's `stripe listen --forward-to` to replay webhooks locally with the same ordering |
| `current_period_end` drift between Stripe and DB after upgrade/downgrade | Always re-pull the subscription from Stripe on `customer.subscription.updated`, never trust the diff |
| User cancels at end of period — they should still have access until then | Check `status === "active" \|\| status === "trialing"` AND `current_period_end > now()` |
| Tax handling varies by country and provider | Stripe Tax / Paddle / Lemon Squeezy each handle this differently — read their docs, do not improvise |
| Local dev webhook signature mismatches | `stripe listen --forward-to localhost:3000/api/webhooks/stripe` produces a different signing secret than prod. Use a `.env.local` override. |
| Refund flow not designed | At minimum, document the manual procedure (provider dashboard → refund → mark sub canceled in DB) |

---

## Plugin recommendations

This recipe deliberately avoids prescribing specific marketplace plugins. The marketplace evolves; pinning today's "best Stripe plugin" in a recipe ages poorly. To find current options:

- Search the [official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) for `stripe`, `billing`, `subscription`
- Check [claudemarketplaces.com](https://claudemarketplaces.com/) for community plugins
- Cross-reference with the plugin's last commit date and issue activity

A plugin worth using will:
- Be maintained by the upstream vendor or a recognized community contributor
- Have commits within the last 3 months
- Cover webhook scaffolding (the painful part), not just the Checkout button
- Match your auth provider choice rather than imposing one

If no plugin meets these criteria, write the integration yourself with the provider's official SDK. The provider's code lives longer than third-party wrappers.

---

## Out of scope for this recipe

- Auth provider setup (separate concern; many recipes online)
- Database choice (Postgres assumed; adapt for your DB)
- Multi-tenant pricing models (org-level vs user-level subscriptions need their own design pass)
- One-time purchases without recurring billing (simpler; doesn't need this recipe)
- Marketplace / multi-seller billing (different architecture, e.g. Stripe Connect)
- Mobile in-app purchases (Apple / Google Play have their own APIs and store rules)

---

## Compatibility with the `nextjs` preset

The `nextjs` preset installs:
- TypeScript / React / Next.js / accessibility / performance / security rules
- Workflow tooling (TDD, audit-loop, qa-review)
- Stack-relevant skills

It does NOT install Stripe, billing schema, or webhook handlers. If you're using the `nextjs` preset, this recipe layers on top: you write the integration code yourself or via a marketplace plugin you select.

The recipe assumes you've installed the foundation via:

```bash
./scripts/new-project.sh --preset nextjs ./my-app
```
