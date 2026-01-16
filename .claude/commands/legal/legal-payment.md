# Agent PAYMENT

Intégration de paiements et gestion des abonnements.

## Contexte
$ARGUMENTS

## Processus d'intégration

### 1. Analyse des besoins

#### Questions clés
- Quel type de paiement ? (one-shot, abonnement, usage-based)
- B2B ou B2C ?
- Quelles devises ? Quels pays ?
- Facturation nécessaire ?

#### Explorer le projet
```bash
# Stack existante
cat package.json 2>/dev/null

# Configuration existante
grep -rn "stripe\|payment\|billing" --include="*.ts" --include="*.js" --include="*.env*" | head -20
```

### 2. Choix du provider

| Provider | Forces | Faiblesses | Idéal pour |
|----------|--------|------------|------------|
| **Stripe** | Complet, DX excellente, mondial | Commission 2.9% + 0.30€ | SaaS, startups |
| **Paddle** | Merchant of record (TVA gérée) | Commission plus élevée | Vente internationale |
| **LemonSqueezy** | MoR, simple | Moins de features | Indie hackers |
| **Gumroad** | Ultra simple | Commission élevée | Digital products |

### 3. Architecture recommandée

```
┌─────────────────────────────────────────────────────────┐
│                      Frontend                            │
├─────────────────────────────────────────────────────────┤
│  Checkout         Pricing Page        Customer Portal    │
│  (Stripe.js)      (Plans)             (Billing)          │
└─────────┬───────────────────────────────────┬───────────┘
          │                                   │
          ▼                                   ▼
┌─────────────────────┐         ┌─────────────────────────┐
│      Backend        │         │        Webhooks         │
├─────────────────────┤         ├─────────────────────────┤
│ - Create checkout   │         │ - checkout.completed    │
│ - Manage subscriptions│       │ - invoice.paid          │
│ - Customer portal   │         │ - subscription.updated  │
│ - Usage reporting   │         │ - subscription.deleted  │
└─────────┬───────────┘         └───────────┬─────────────┘
          │                                 │
          ▼                                 ▼
┌─────────────────────────────────────────────────────────┐
│                      Database                            │
├─────────────────────────────────────────────────────────┤
│  users (stripe_customer_id, subscription_status, plan)  │
└─────────────────────────────────────────────────────────┘
```

### 4. Implémentation Stripe

#### Installation
```bash
npm install stripe @stripe/stripe-js
```

#### Configuration backend
```typescript
// lib/stripe.ts
import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
});
```

#### Créer une checkout session
```typescript
// api/create-checkout.ts
import { stripe } from '@/lib/stripe';

export async function createCheckout(userId: string, priceId: string) {
  const session = await stripe.checkout.sessions.create({
    customer_email: user.email,
    // ou customer: stripeCustomerId si existant
    mode: 'subscription', // ou 'payment' pour one-shot
    payment_method_types: ['card'],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${BASE_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${BASE_URL}/pricing`,
    metadata: { userId },
  });

  return session.url;
}
```

#### Webhooks essentiels
```typescript
// api/webhooks/stripe.ts
import { stripe } from '@/lib/stripe';

const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function handleWebhook(req: Request) {
  const sig = req.headers.get('stripe-signature')!;
  const body = await req.text();

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(body, sig, endpointSecret);
  } catch (err) {
    return new Response('Webhook Error', { status: 400 });
  }

  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object);
      break;

    case 'invoice.paid':
      await handleInvoicePaid(event.data.object);
      break;

    case 'customer.subscription.updated':
      await handleSubscriptionUpdate(event.data.object);
      break;

    case 'customer.subscription.deleted':
      await handleSubscriptionCanceled(event.data.object);
      break;
  }

  return new Response('OK', { status: 200 });
}
```

### 5. Gestion des abonnements

#### États d'abonnement
```typescript
type SubscriptionStatus =
  | 'trialing'      // Période d'essai
  | 'active'        // Actif et payé
  | 'past_due'      // Paiement en retard
  | 'canceled'      // Annulé (accès jusqu'à fin période)
  | 'unpaid'        // Impayé
  | 'incomplete';   // Paiement initial échoué
```

#### Logique d'accès aux features
```typescript
function hasAccess(user: User, feature: string): boolean {
  const plan = PLANS[user.plan];

  // Vérifier le statut d'abonnement
  if (!['trialing', 'active', 'past_due'].includes(user.subscriptionStatus)) {
    return false;
  }

  // Vérifier si le plan inclut la feature
  return plan.features.includes(feature);
}
```

### 6. Customer Portal

```typescript
// Accès au portail de facturation
async function createPortalSession(customerId: string) {
  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: `${BASE_URL}/settings`,
  });

  return session.url;
}
```

Fonctionnalités du portal :
- [ ] Voir les factures
- [ ] Mettre à jour le moyen de paiement
- [ ] Changer de plan (upgrade/downgrade)
- [ ] Annuler l'abonnement

### 7. Cas particuliers

#### Période d'essai
```typescript
const session = await stripe.checkout.sessions.create({
  // ...
  subscription_data: {
    trial_period_days: 14,
  },
});
```

#### Coupons et réductions
```typescript
const session = await stripe.checkout.sessions.create({
  // ...
  discounts: [{ coupon: 'LAUNCH20' }],
  allow_promotion_codes: true, // Ou laisser le user entrer un code
});
```

#### Usage-based billing
```typescript
// Reporter l'usage
await stripe.subscriptionItems.createUsageRecord(
  subscriptionItemId,
  {
    quantity: 100, // unités utilisées
    timestamp: Math.floor(Date.now() / 1000),
    action: 'increment',
  }
);
```

### 8. Tests

#### Mode test Stripe
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

#### Cartes de test
| Scénario | Numéro de carte |
|----------|-----------------|
| Succès | 4242 4242 4242 4242 |
| Refusée | 4000 0000 0000 0002 |
| Auth requise | 4000 0025 0000 3155 |
| Fonds insuffisants | 4000 0000 0000 9995 |

#### Test des webhooks
```bash
# Stripe CLI pour tester en local
stripe listen --forward-to localhost:3000/api/webhooks/stripe
stripe trigger checkout.session.completed
```

### 9. Checklist sécurité

- [ ] Clés API en variables d'environnement
- [ ] Webhook signature vérifiée
- [ ] HTTPS obligatoire
- [ ] Pas de prix côté client (utiliser price_id)
- [ ] Idempotency keys pour les requêtes sensibles
- [ ] Logs des événements de paiement

### 10. Conformité

#### Factures
- [ ] Numéro de facture séquentiel
- [ ] Mentions légales obligatoires
- [ ] TVA correcte selon le pays (si non MoR)

#### CGV
- [ ] Conditions d'abonnement claires
- [ ] Politique de remboursement
- [ ] Politique d'annulation

> Pour les aspects légaux complets, utiliser `/legal`

## Output attendu

### Architecture retenue
```
Provider: [Stripe/Paddle/...]
Type: [subscription/one-shot/usage]
Intégration: [Checkout hosted/embedded/custom]
```

### Plans à créer dans Stripe
| Plan | Price ID | Prix/mois | Prix/an | Features |
|------|----------|-----------|---------|----------|
| Free | - | 0€ | - | |
| Pro | price_xxx | X€ | X€ | |
| Business | price_xxx | X€ | X€ | |

### Webhooks à implémenter
| Event | Action |
|-------|--------|
| checkout.session.completed | |
| invoice.paid | |
| customer.subscription.updated | |
| customer.subscription.deleted | |

### Code d'implémentation
[Snippets prêts à l'emploi]

### Checklist de lancement
- [ ] Products/Prices créés dans Stripe
- [ ] Webhooks configurés
- [ ] Customer portal activé
- [ ] Tests en mode test validés
- [ ] Passage en mode live

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/legal` | CGV et mentions légales |
| `/rgpd` | Conformité données de paiement |
| `/security` | Sécurité des transactions |
| `/pricing` | Définir la stratégie de prix |

---

IMPORTANT: Toujours utiliser les webhooks pour synchroniser l'état - ne jamais faire confiance au retour du checkout seul.

YOU MUST vérifier la signature des webhooks - c'est une faille de sécurité majeure sinon.

NEVER stocker les numéros de carte - utiliser Stripe.js/Elements.

Think hard sur les edge cases (paiement échoué, downgrade, remboursement) avant d'implémenter.
