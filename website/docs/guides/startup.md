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
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-market` | Etude de marche |
| `/biz:biz-personas` | Personas utilisateurs |
| `/biz:biz-competitor` | Analyse concurrentielle |

### Phase 2 : MVP

| Commande | Usage |
|----------|-------|
| `/biz:biz-mvp` | Definition du MVP |
| `/biz:biz-pricing` | Strategie de pricing |
| `/work:work-plan` | Plan technique |

### Phase 3 : Lancement

| Commande | Usage |
|----------|-------|
| `/legal:legal-rgpd` | Conformite RGPD |
| `/legal:legal-terms-of-service` | CGU |
| `/legal:legal-privacy-policy` | Politique de confidentialite |
| `/growth:growth-landing` | Landing page |
| `/growth:growth-seo` | SEO |

### Phase 4 : Croissance

| Commande | Usage |
|----------|-------|
| `/growth:growth-analytics` | Analytics |
| `/growth:growth-funnel` | Optimisation funnel |
| `/growth:growth-onboarding` | Parcours utilisateur |
| `/growth:growth-email` | Email marketing |
| `/growth:growth-retention` | Retention |

## Workflow complet

### 1. Valider l'idee

```bash
# Creer le Lean Canvas
/biz:biz-model "Mon SaaS de gestion de projets"

# Analyser le marche
/biz:biz-market

# Definir les personas
/biz:biz-personas

# Analyser la concurrence
/biz:biz-competitor
```

### 2. Definir le MVP

```bash
# Scope du MVP
/biz:biz-mvp

# Strategie de prix
/biz:biz-pricing
```

### 3. Preparer le legal

```bash
# RGPD
/legal:legal-rgpd

# CGU
/legal:legal-terms-of-service

# Privacy Policy
/legal:legal-privacy-policy
```

### 4. Preparer le lancement

```bash
# Landing page
/growth:growth-landing

# SEO
/growth:growth-seo

# Analytics
/growth:growth-analytics
```

### 5. Lancer

```bash
# Workflow complet
/work:work-flow-launch "Mon SaaS"
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
