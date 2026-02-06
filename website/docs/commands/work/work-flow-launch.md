---
sidebar_position: 8
title: "/work:work-flow-launch"
description: "Workflow technique pour développer et lancer un produit, du setup projet au go-live."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-FLOW-LAUNCH

Workflow technique pour développer et lancer un produit, du setup projet au go-live.

## Contexte
`&lt;arguments&gt;`

## Objectif

Cet agent couvre le **workflow technique** de développement et déploiement.
Pour l'analyse business préalable, utiliser `/biz:biz-launch`.

## Scope de cet agent

```
┌─────────────────────────────────────────────────────────────┐
│               BIZ-LAUNCH vs WORK-FLOW-LAUNCH                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BIZ-LAUNCH                     WORK-FLOW-LAUNCH (ici)     │
│  ══════════════════════         ══════════════════════      │
│  ✓ Analyse de marché            ✓ Setup projet              │
│  ✓ Business model               ✓ Développement MVP         │
│  ✓ Définition MVP               ✓ Tests & QA                │
│  ✓ Stratégie pricing            ✓ CI/CD                     │
│  ✓ Conformité RGPD/Legal        ✓ Landing page              │
│  ✓ Recommandations GTM          ✓ Analytics & SEO           │
│                                 ✓ Go-Live                   │
│                                                             │
│  AVANT le dev ─────────────────► PENDANT et APRÈS le dev   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Workflow technique

```
┌─────────────────────────────────────────────────────────────┐
│                  TECHNICAL LAUNCH WORKFLOW                   │
├─────────────────────────────────────────────────────────────┤
│  PHASE 1: SETUP                                             │
│  ├── 1. Setup Projet & Stack                                │
│  ├── 2. CI/CD Configuration                                 │
│  └── 3. Environment Setup                                   │
├─────────────────────────────────────────────────────────────┤
│  PHASE 2: DÉVELOPPEMENT                                     │
│  ├── 4. Core Features                                       │
│  ├── 5. Tests & QA                                          │
│  └── 6. Security Review                                     │
├─────────────────────────────────────────────────────────────┤
│  PHASE 3: LANCEMENT                                         │
│  ├── 7. Landing Page                                        │
│  ├── 8. Analytics & SEO                                     │
│  └── 9. Go-Live                                             │
└─────────────────────────────────────────────────────────────┘
```

## Prérequis

Avant de commencer ce workflow, assurez-vous d'avoir :
- [ ] Analyse business complétée (`/biz:biz-launch`)
- [ ] MVP défini et scope validé
- [ ] Budget et timeline approuvés

---

# PHASE 1 : SETUP

## Étape 1/6 : Setup Projet & Stack

### Objectif
Mettre en place l'environnement technique et choisir la stack.

### Stack technique
```markdown
**Frontend:** [React/Vue/etc.]
**Backend:** [Node/Python/etc.]
**Database:** [PostgreSQL/MongoDB/etc.]
**Hosting:** [Vercel/AWS/etc.]
**CI/CD:** [GitHub Actions/etc.]
```

### Structure projet
```
/project
├── /src
├── /tests
├── /docs
├── .env.example
├── docker-compose.yml
├── README.md
└── package.json
```

### Setup checklist
- [ ] Repo Git créé
- [ ] Structure de dossiers
- [ ] Linter/Formatter configuré
- [ ] CI/CD basique
- [ ] Variables d'environnement
- [ ] README initial

---

## Étape 2/6 : Core Features

### Objectif
Développer les fonctionnalités MVP.

### Process par feature
```
1. User Story → 2. Tests → 3. Code → 4. Review → 5. Merge
```

### Suivi des features
| Feature | Status | Owner | Deadline |
|---------|--------|-------|----------|
| Auth | | | |
| Core 1 | | | |
| Core 2 | | | |

### Checklist dev
- [ ] Auth/User management
- [ ] Feature core 1
- [ ] Feature core 2
- [ ] API documentée
- [ ] Error handling

---

## Étape 3/6 : Tests & QA

### Objectif
Assurer la qualité du produit.

### Pyramide de tests
```
        /\
       /  \      E2E (peu)
      /────\
     /      \    Integration
    /────────\
   /          \  Unit (beaucoup)
  /────────────\
```

### QA Checklist
- [ ] Tests unitaires &gt; 80%
- [ ] Tests d'intégration
- [ ] Tests E2E critiques
- [ ] Tests manuels
- [ ] Security review
- [ ] Performance OK
- [ ] Responsive OK
- [ ] Accessibilité OK

---

# PHASE 3 : LANCEMENT

## Étape 4/6 : Landing Page

### Objectif
Page de conversion optimisée.

### Structure
```
┌─────────────────────────────────┐
│            HERO                 │  Proposition de valeur
│         [CTA Principal]         │
├─────────────────────────────────┤
│         PROBLÈME                │  Pain points
├─────────────────────────────────┤
│         SOLUTION                │  Comment on résout
├─────────────────────────────────┤
│        FEATURES                 │  Bénéfices clés
├─────────────────────────────────┤
│       SOCIAL PROOF              │  Témoignages, logos
├─────────────────────────────────┤
│        PRICING                  │  Plans et prix
├─────────────────────────────────┤
│          CTA                    │  Dernier appel à l'action
├─────────────────────────────────┤
│         FOOTER                  │  Liens, légal
└─────────────────────────────────┘
```

### Checklist landing
- [ ] Headline accrocheur
- [ ] Proposition de valeur claire
- [ ] CTA visible et clair
- [ ] Social proof
- [ ] Mobile responsive
- [ ] Loading &lt; 3s
- [ ] SEO basique

---

## Étape 5/6 : Analytics & SEO

### Objectif
Mesurer et être trouvé.

### Analytics setup
```javascript
// Events à tracker
- Page views
- Sign ups
- Conversions
- Feature usage
- Errors
```

### SEO Checklist
- [ ] Meta title/description
- [ ] Open Graph tags
- [ ] Sitemap.xml
- [ ] Robots.txt
- [ ] Schema markup
- [ ] Core Web Vitals OK
- [ ] Google Search Console

### Outils
- Analytics: [Plausible/GA/Mixpanel]
- Error tracking: [Sentry]
- Uptime: [UptimeRobot]

---

## Étape 6/6 : Go-Live

### Objectif
Lancer officiellement le produit.

### Pre-launch checklist
- [ ] Domain configuré
- [ ] SSL actif
- [ ] DNS propagé
- [ ] Emails fonctionnels
- [ ] Paiements testés
- [ ] Légal en place (CGU, CGV, Privacy)
- [ ] Support prêt

### Launch day
```
T-24h : Final checks
T-12h : Notify team
T-0   : Go live
T+1h  : Monitor metrics
T+24h : First retrospective
```

### Post-launch monitoring
- [ ] Uptime OK
- [ ] Errors &lt; threshold
- [ ] Performance OK
- [ ] User feedback collected

---

## Output final attendu

### Launch Summary
```
🚀 LAUNCH COMPLETE

Produit: [Nom]
URL: [https://...]
Date: [YYYY-MM-DD]

Business:
- Marché: [TAM/SAM/SOM]
- Modèle: [Revenue model]
- Pricing: [Prix]

Technique:
- Stack: [Technologies]
- Tests: [Coverage]%
- Performance: [Metrics]

Marketing:
- Landing: ✅
- Analytics: ✅
- SEO: ✅

Status: LIVE 🟢
```

### Prochaines étapes
1. Collecter du feedback utilisateur
2. Monitorer les métriques
3. Itérer sur le produit
4. Planifier v1.1

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/biz:biz-launch` | Analyse business préalable |
| `/dev:dev-testing-setup` | Configurer les tests |
| `/ops:ops-ci` | Configuration CI/CD avancée |
| `/qa:qa-automation` | Automatisation des tests |
| `/qa:qa-security` | Audit de sécurité |
| `/growth:growth-seo` | SEO avancé |
| `/growth:growth-analytics` | Analytics avancé |

---

IMPORTANT: Faire d'abord l'analyse business avec `/biz:biz-launch` avant ce workflow.

YOU MUST avoir le legal en place avant le go-live (CGU, CGV, RGPD).

NEVER sacrifier la qualité pour aller plus vite - mieux vaut reporter.

Think hard sur ce qui est vraiment MVP vs nice-to-have.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
