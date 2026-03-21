---
sidebar_position: 3
title: "/legal:legal-payment"
description: "Integration de paiements et gestion des abonnements."
tags:
  - "legal"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--legal">LEGAL</span>


# Agent PAYMENT

Integration de paiements et gestion des abonnements.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Integrer un systeme de paiement complet avec checkout, webhooks,
gestion des abonnements et conformite legale.

## Workflow

- Analyser les besoins (one-shot, abonnement, usage-based, B2B/B2C)
- Choisir le provider adapte (Stripe, Paddle, LemonSqueezy)
- Implementer le checkout (session, redirection, success/cancel)
- Configurer les webhooks essentiels (checkout.completed, invoice.paid, subscription.updated/deleted)
- Gerer les etats d'abonnement et la logique d'acces aux features
- Configurer le Customer Portal (factures, paiement, changement de plan, annulation)
- Tester avec les cartes de test et Stripe CLI
- Verifier la securite (signature webhook, HTTPS, pas de prix client-side)

## Output attendu

1. **Architecture** retenue (provider, type, integration)
2. **Plans** a creer avec prix et features
3. **Webhooks** a implementer avec actions
4. **Code** d'implementation pret a l'emploi
5. **Checklist** de lancement (products, webhooks, portal, tests, mode live)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/legal:legal-docs` | CGV et mentions legales |
| `/legal:legal-rgpd` | Conformite donnees de paiement |
| `/qa:qa-security` | Securite des transactions |
| `/biz:biz-pricing` | Definir la strategie de prix |

---

IMPORTANT: Toujours utiliser les webhooks - ne jamais faire confiance au retour du checkout seul.

YOU MUST verifier la signature des webhooks.

NEVER stocker les numeros de carte - utiliser Stripe.js/Elements.

Think hard sur les edge cases (paiement echoue, downgrade, remboursement).


---

## Voir aussi

- [Retour aux commandes LEGAL](/docs/commands/legal)
- [Toutes les commandes](/docs/commands)
