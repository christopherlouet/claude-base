---
sidebar_position: 6
title: Startup
description: Guide pour entrepreneurs et SaaS
---

# Guide : Startup

Guide complet pour lancer et developper un produit.

## Phases de lancement

```
Idee → Validation → MVP → Lancement → Croissance
```

## Commandes par phase

### Phase 1 : Validation

| Commande | Usage |
|----------|-------|
| `/biz-model` | Business model, Lean Canvas |
| `/biz-market` | Etude de marche |
| `/biz-personas` | Personas utilisateurs |
| `/biz-competitor` | Analyse concurrentielle |

### Phase 2 : MVP

| Commande | Usage |
|----------|-------|
| `/biz-mvp` | Definition du MVP |
| `/biz-pricing` | Strategie de pricing |
| `/work-plan` | Plan technique |

### Phase 3 : Lancement

| Commande | Usage |
|----------|-------|
| `/legal-rgpd` | Conformite RGPD |
| `/legal-terms-of-service` | CGU |
| `/legal-privacy-policy` | Politique de confidentialite |
| `/growth-landing` | Landing page |
| `/growth-seo` | SEO |

### Phase 4 : Croissance

| Commande | Usage |
|----------|-------|
| `/growth-analytics` | Analytics |
| `/growth-funnel` | Optimisation funnel |
| `/growth-onboarding` | Parcours utilisateur |
| `/growth-email` | Email marketing |
| `/growth-retention` | Retention |

## Workflow complet

### 1. Valider l'idee

```bash
# Creer le Lean Canvas
/biz-model "Mon SaaS de gestion de projets"

# Analyser le marche
/biz-market

# Definir les personas
/biz-personas

# Analyser la concurrence
/biz-competitor
```

### 2. Definir le MVP

```bash
# Scope du MVP
/biz-mvp

# Strategie de prix
/biz-pricing
```

### 3. Preparer le legal

```bash
# RGPD
/legal-rgpd

# CGU
/legal-terms-of-service

# Privacy Policy
/legal-privacy-policy
```

### 4. Preparer le lancement

```bash
# Landing page
/growth-landing

# SEO
/growth-seo

# Analytics
/growth-analytics
```

### 5. Lancer

```bash
# Workflow complet
/work-flow-launch "Mon SaaS"
```

## Lean Canvas

```
┌─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│   PROBLEM   │  SOLUTION   │   UNIQUE    │  UNFAIR     │  CUSTOMER   │
│             │             │   VALUE     │  ADVANTAGE  │  SEGMENTS   │
│  - Prob 1   │  - Sol 1    │  PROPOSITION│             │             │
│  - Prob 2   │  - Sol 2    │             │  Ce qu'on   │  - Segment 1│
│  - Prob 3   │  - Sol 3    │  Pourquoi   │  ne peut    │  - Segment 2│
│             │             │  nous ?     │  pas copier │             │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│  KEY        │             │             │             │  CHANNELS   │
│  METRICS    │             │             │             │             │
│             │             │             │             │  Comment    │
│  KPIs       │             │             │             │  atteindre  │
│  principaux │             │             │             │  les clients│
├─────────────┴─────────────┴─────────────┴─────────────┴─────────────┤
│                         COST STRUCTURE                              │
│                                                                     │
│  - Couts fixes      - Couts variables      - Burn rate             │
├─────────────────────────────────────────────────────────────────────┤
│                         REVENUE STREAMS                             │
│                                                                     │
│  - Abonnements      - One-time      - Freemium                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Checklist de lancement

### Business
- [ ] Lean Canvas valide
- [ ] Personas definis
- [ ] MVP scope clair
- [ ] Pricing etabli

### Legal
- [ ] RGPD conforme
- [ ] CGU/CGV
- [ ] Privacy Policy
- [ ] Mentions legales

### Tech
- [ ] MVP fonctionnel
- [ ] Tests automatises
- [ ] CI/CD en place
- [ ] Monitoring actif

### Growth
- [ ] Landing page optimisee
- [ ] SEO technique
- [ ] Analytics configure
- [ ] Funnel defini

### Launch
- [ ] Domaine configure
- [ ] Support pret
- [ ] Communication planifiee

## KPIs a suivre

| Phase | KPIs |
|-------|------|
| Pre-launch | Inscrits waitlist, taux de conversion landing |
| Launch | Signups, activations, premier paiement |
| Growth | MRR, churn, LTV, CAC, NPS |

---

## Voir aussi

- [Business Model](/docs/commands/biz/biz-model)
- [Launch](/docs/workflow/launch)
- [Growth](/docs/commands/growth)
