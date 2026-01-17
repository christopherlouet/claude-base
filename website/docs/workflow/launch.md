---
sidebar_position: 6
title: Lancement Produit
description: Workflow pour lancer un nouveau produit
---

# Workflow : Lancement Produit

Guide complet pour lancer un nouveau produit ou SaaS.

## Commande rapide

```bash
/work-flow-launch "Mon nouveau SaaS"
```

## Vue d'ensemble

Le workflow de lancement couvre :

1. **Business** - Model, pricing, MVP
2. **Legal** - RGPD, CGU, mentions legales
3. **Tech** - Infrastructure, securite, performance
4. **Growth** - Landing, SEO, analytics
5. **Launch** - Go-live et monitoring

## Etapes detaillees

### 1. Business

```bash
/biz-model "Mon SaaS de gestion de projets"
```

Definir :
- Value proposition
- Business model (Lean Canvas)
- Pricing strategy
- MVP scope

### 2. Legal

```bash
/legal-rgpd
/legal-terms-of-service
/legal-privacy-policy
```

Preparer :
- Conformite RGPD
- CGU/CGV
- Politique de confidentialite
- Mentions legales

### 3. Infrastructure

```bash
/ops-ci
/ops-monitoring
/ops-backup
```

Configurer :
- CI/CD pipeline
- Monitoring et alertes
- Backup et recovery
- Secrets management

### 4. Securite

```bash
/qa-security
/qa-audit
```

Verifier :
- OWASP Top 10
- Authentification securisee
- Protection des donnees
- Tests de penetration

### 5. Performance

```bash
/qa-perf
/ops-load-testing
```

Optimiser :
- Core Web Vitals
- Temps de reponse API
- Tests de charge
- CDN et caching

### 6. Growth

```bash
/growth-landing
/growth-seo
/growth-analytics
```

Preparer :
- Landing page optimisee
- SEO technique
- Analytics et tracking
- Funnel de conversion

### 7. Go-Live

```bash
/ops-release
```

Deployer :
- Production deployment
- DNS et certificats
- Monitoring actif
- Support pret

## Checklist de lancement

### Business
- [ ] Business model valide
- [ ] Pricing defini
- [ ] MVP scope clair
- [ ] Personas documentes

### Legal
- [ ] RGPD conforme
- [ ] CGU/CGV redigees
- [ ] Privacy policy
- [ ] Mentions legales

### Tech
- [ ] CI/CD operationnel
- [ ] Monitoring actif
- [ ] Backups configures
- [ ] Securite auditee

### Growth
- [ ] Landing optimisee
- [ ] SEO en place
- [ ] Analytics configure
- [ ] Email ready

### Launch
- [ ] Domaine configure
- [ ] SSL actif
- [ ] Support pret
- [ ] Communication planifiee

## Exemple concret

```bash
> /work-flow-launch "TaskFlow - Gestion de projets simplifiee"

# Claude enchaine automatiquement :
# 1. Analyse le projet
# 2. Propose le business model
# 3. Prepare les documents legaux
# 4. Configure l'infrastructure
# 5. Audite la securite
# 6. Optimise la performance
# 7. Prepare le growth
# 8. Guide le go-live
```

---

## Voir aussi

- [Business Model](/docs/commands/biz/biz-model)
- [Landing Page](/docs/commands/growth/growth-landing)
- [RGPD](/docs/commands/legal/legal-rgpd)
