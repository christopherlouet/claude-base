---
sidebar_position: 20
title: "growth-cro"
description: "Optimisation du taux de conversion (CRO). Declencher quand l'utilisateur veut optimiser les conversions, ameliorer un formulaire d'inscription, un checkout, une landing page, ou un onboarding."
tags:
  - "skill"
  - "fork"
---

# Skill: growth-cro

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Optimisation du taux de conversion (CRO). Declencher quand l'utilisateur veut optimiser les conversions, ameliorer un formulaire d'inscription, un checkout, une landing page, ou un onboarding.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Edit`, `Write` |
| **Mots-cles** | `growth`, `cro`, `comment`, `complete your profile: 3/5`, `connect your github repo`, `create your first project`, `start from a template` |

## Description detaillee

# Conversion Rate Optimization (CRO)

## Objectif

Identifier et corriger les points de friction dans les parcours utilisateur pour maximiser le taux de conversion.

## Domaines CRO

```
┌──────────────────────────────────────────────────────────────────┐
│                    CRO FRAMEWORK                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PAGE CRO           Optimiser les pages marketing/landing        │
│  ═════════                                                        │
│                                                                   │
│  SIGNUP FLOW CRO    Ameliorer inscription et creation compte     │
│  ══════════════                                                   │
│                                                                   │
│  ONBOARDING CRO     Reduire time-to-value post-inscription      │
│  ═════════════                                                    │
│                                                                   │
│  FORM CRO           Optimiser les formulaires de capture         │
│  ════════                                                         │
│                                                                   │
│  POPUP CRO          Ameliorer popups, modals, overlays           │
│  ═════════                                                        │
│                                                                   │
│  PAYWALL CRO        Optimiser paywalls et upsells                │
│  ═══════════                                                      │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Page CRO

### Checklist landing page

| # | Element | Bonnes pratiques |
|---|---------|-----------------|
| 1 | **Headline** | Benefice clair en < 10 mots, pas de jargon |
| 2 | **Sub-headline** | Expliquer le "comment" en 1 phrase |
| 3 | **CTA primaire** | Action specifique, visible above-the-fold |
| 4 | **Social proof** | Temoignages, logos clients, chiffres |
| 5 | **Objections** | FAQ ou sections repondant aux doutes |
| 6 | **Urgence/Rarete** | Timer, places limitees (si authentique) |
| 7 | **Visuel hero** | Screenshot produit ou demo video |
| 8 | **Navigation** | Minimale (pas de menu complet sur landing) |

### Patterns de conversion

```
Hero section (benefice + CTA)
    ↓
Social proof (logos, temoignages)
    ↓
Features/Benefits (3-5 max)
    ↓
How it works (3 etapes)
    ↓
Pricing (si applicable)
    ↓
FAQ (objections courantes)
    ↓
CTA final (meme action que le hero)
```

## 2. Signup Flow CRO

### Regles d'or

| # | Regle | Impact |
|---|-------|--------|
| 1 | Minimum de champs (email seul pour commencer) | +20-30% signups |
| 2 | Social login (Google, GitHub) | +15-25% signups |
| 3 | Pas de confirmation email bloquante | -40% drop-off |
| 4 | Progress indicator si multi-step | +10% completion |
| 5 | Proposition de valeur visible a cote du form | +15% signups |
| 6 | Password strength indicator | +5% completion |
| 7 | Error inline, pas au submit | +20% completion |

### Anti-patterns a eviter

- Demander trop d'info au signup (nom, tel, adresse)
- CAPTCHA visible pour tous les utilisateurs
- Email de confirmation avant acces au produit
- Redirection vers page de login apres signup
- Pas de feedback apres soumission du formulaire

## 3. Onboarding CRO

### Framework Time-to-Value

```
Signup → [Activation] → [Aha Moment] → [Habit Formation]
           |                |                |
           v                v                v
    Premier setup     Premiere valeur    Usage regulier
    (< 2 min)         (< 5 min)         (Jour 7+)
```

### Patterns efficaces

| Pattern | Quand | Exemple |
|---------|-------|---------|
| **Checklist** | 3-5 etapes d'activation | "Complete your profile: 3/5" |
| **Wizard** | Setup technique requis | "Connect your GitHub repo" |
| **Empty state** | Premiere visite page vide | "Create your first project" |
| **Template** | Produit complexe | "Start from a template" |
| **Tour guide** | Interface complexe | Tooltips de decouverte |

## 4. Form CRO

### Optimisation des formulaires

| # | Technique | Detail |
|---|-----------|--------|
| 1 | Un champ par ligne | Pas de layout multi-colonnes sur mobile |
| 2 | Labels au-dessus des champs | Pas de labels flottants |
| 3 | Input type correct | `email`, `tel`, `number` pour clavier adapte |
| 4 | Autocomplete HTML | `autocomplete="email"`, `"given-name"` |
| 5 | Taille de police >= 16px | Evite le zoom iOS |
| 6 | Bouton submit descriptif | "Create account" pas "Submit" |
| 7 | Feedback immediat | Validation au blur, pas au submit |
| 8 | Error recovery facile | Message + focus sur le champ en erreur |

## 5. Popup/Modal CRO

### Regles

| # | Regle | Detail |
|---|-------|--------|
| 1 | Timing: pas avant 30s ou 50% scroll | Laisser decouvrir le contenu |
| 2 | Exit-intent > time-based | Moins intrusif |
| 3 | Fermeture facile | X visible, click outside, Escape |
| 4 | Un seul popup a la fois | Pas de stack de modals |
| 5 | Frequence limitee | Max 1x par session ou 1x par semaine |
| 6 | Proposition de valeur claire | Pas juste "Subscribe" |
| 7 | Mobile: bottom sheet > modal centre | Meilleur UX mobile |

## 6. Paywall/Upgrade CRO

### Strategies

| Strategy | Detail | Quand |
|----------|--------|-------|
| **Feature gate** | Montrer la feature, bloquer l'acces | Feature premium demandee |
| **Usage limit** | "3/5 projects used" | Approche limite gratuite |
| **Trial expiration** | Countdown + valeur demontree | Fin de trial |
| **Upgrade prompt** | Suggestion contextuelle | Action premium tentee |
| **Social proof** | "Join 10,000+ teams" | Page pricing |

### Pricing page patterns

```
[ Free ]        [ Pro ★ ]        [ Enterprise ]
  $0              $29/mo           Custom
  3 projects      Unlimited        Unlimited
  1 user          10 users         Unlimited
  Basic support   Priority         Dedicated
                 [Start trial]
```

- Mettre en avant le plan recommande (badge, couleur)
- Toggle mensuel/annuel (montrer l'economie)
- Feature comparison table en dessous
- FAQ sur le billing

## Metriques a suivre

| Metrique | Formule | Cible |
|----------|---------|-------|
| **Conversion rate** | Conversions / Visiteurs | Depend du domaine |
| **Drop-off rate** | Abandons par etape du funnel | < 20% par etape |
| **Time to convert** | Duree visite → conversion | Reduire |
| **Bounce rate** | Rebonds / Sessions | < 40% landing pages |
| **Activation rate** | Users actives / Signups | > 40% |
| **Trial-to-paid** | Paiements / Trials | > 15% |

## Output attendu

```markdown
## Audit CRO : [Page/Flow]

### Taux de conversion estime actuel : X%
### Potentiel d'amelioration : +Y%

### Quick wins (impact immediat)
1. [Action] - Impact estime: +X%
2. [Action] - Impact estime: +X%

### Ameliorations structurelles
1. [Action] - Detail et implementation

### Tests A/B recommandes
1. [Hypothese] - Variante A vs B
```

## Regles

- Toujours baser les recommandations sur des donnees ou des best practices prouvees
- Proposer des quick wins ET des changements structurels
- Ne pas sacrifier l'UX pour la conversion (dark patterns interdits)
- Suggerer des tests A/B pour valider les changements importants

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux growth..."_
- _"Je veux cro..."_
- _"Je veux comment..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Landing Page A/B Test Optimization

# Example: Landing Page A/B Test Optimization

## Scenario
A SaaS product landing page has a 1.8% signup conversion rate. Goal: reach 3%+ through systematic A/B testing.

## Current State Analysis

| Metric | Value | Benchmark |
|--------|-------|-----------|
| Visitors/month | 25,000 | - |
| Signup rate | 1.8% | 3-5% (SaaS avg) |
| Bounce rate | 72% | < 50% |
| Avg time on page | 18s | > 45s |
| CTA clicks | 3.2% | > 8% |

## Identified Issues

1. **Headline**: Feature-focused ("AI-powered analytics platform") instead of benefit-focused
2. **CTA**: "Get Started" is vague, below the fold on mobile
3. **Social proof**: None visible above the fold
4. **Form friction**: 6-field signup form requiring credit card

## A/B Test Plan

### Test 1: Headline (highest impact)

```
Control (A): "AI-Powered Analytics Platform"
Variant (B): "Cut Your Reporting Time by 75%"
Variant (C): "Stop Wasting 10 Hours/Week on Reports"

Metric: Signup rate
Traffic split: 33/33/33
Min sample: 3,000 per variant (95% confidence, 80% power)
Duration: ~12 days at current traffic
```

### Test 2: CTA Copy + Placement

```
Control (A): "Get Started" (below fold)
Variant (B): "Start Free Trial - No Credit Card" (above fold)

Metric: CTA click rate
Min sample: 2,500 per variant
Duration: ~6 days
```

### Test 3: Social Proof

```
Control (A): No social proof above fold
Variant (B): Logo bar "Trusted by 500+ companies" + 3 logos
Variant (C): Testimonial quote + photo + company name

Metric: Signup rate
Duration: ~12 days
```

### Test 4: Form Simplification

```
Control (A): 6 fields + credit card
Variant (B): Email + password only (2 fields)
Variant (C): "Sign up with Google" single button

Metric: Form completion rate
Duration: ~10 days
```

## Expected Impact Model

```
Test 1 (Headline):     +0.3-0.5% conversion lift
Test 2 (CTA):          +0.2-0.4% conversion lift
Test 3 (Social proof): +0.1-0.3% conversion lift
Test 4 (Form):         +0.4-0.8% conversion lift
Combined (estimated):  1.8% -> 3.0-3.5%
```

## Implementation Checklist

- [ ] Set up analytics events: `page_view`, `cta_click`, `form_start`, `signup_complete`
- [ ] Configure A/B tool (PostHog/LaunchDarkly) with feature flags
- [ ] Run tests sequentially (not simultaneously) to avoid interaction effects
- [ ] Wait for statistical significance before calling winner (p < 0.05)
- [ ] Monitor for novelty effect: check results stable after 2 full weeks
- [ ] Document winning variants and roll forward

## Key Decisions

- **Sequential testing**: Avoids confounding variables from simultaneous changes
- **Benefit-first headlines**: Address pain point, not feature description
- **Reduce friction first**: Removing credit card requirement often gives largest lift
- **Statistical rigor**: Minimum sample sizes calculated upfront, no peeking
- **PostHog over Google Optimize**: Self-hosted, GDPR-friendly, integrates with product analytics



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
