---
sidebar_position: 3
title: Matrice des Agents
description: Liste complete des 56 agents
---

# Matrice des Agents

> **56 sub-agents** avec modele et outils

## Par modele

### Haiku (Rapide/Economique)

| Agent | Description | Outils |
|-------|-------------|--------|
| `work-explore` | Explorer un codebase | Read, Grep, Glob |
| `doc-onboard` | Onboarding developpeur | Read, Grep, Glob |
| `doc-changelog` | Generer changelog | Read, Grep, Glob |
| `doc-explain` | Expliquer du code | Read, Grep, Glob |
| `doc-generate` | Generer documentation | Read, Grep, Glob |
| `qa-a11y` | Audit accessibilite | Read, Grep, Glob |
| `qa-coverage` | Couverture de tests | Read, Grep, Glob, Bash |
| `qa-responsive` | Audit responsive | Read, Grep, Glob |
| `ops-deps` | Audit dependances | Read, Grep, Glob, Bash |
| `ops-health` | Health check | Read, Grep, Glob, Bash |
| `biz-model` | Business model | Read, Grep, Glob, WebSearch |
| `biz-competitor` | Analyse concurrence | Read, Grep, Glob, WebSearch |
| `biz-mvp` | Definition MVP | Read, Grep, Glob |
| `biz-personas` | Personas utilisateur | Read, Grep, Glob |
| `growth-seo` | Audit SEO | Read, Grep, Glob, WebFetch |
| `growth-analytics` | Setup analytics | Read, Grep, Glob |
| `growth-funnel` | Optimisation funnel | Read, Grep, Glob |
| `growth-landing` | Landing page | Read, Grep, Glob |
| `data-analytics` | Analyse donnees | Read, Grep, Glob |
| `data-modeling` | Modelisation | Read, Grep, Glob |
| `data-pipeline` | Pipelines ETL | Read, Grep, Glob |
| `dev-component` | Composants UI | Read, Grep, Glob |
| `dev-flutter` | Flutter widgets | Read, Grep, Glob |
| `dev-supabase` | Backend Supabase | Read, Grep, Glob |
| `dev-test` | Generation tests | Read, Grep, Glob |
| `legal-payment` | Integration paiement | Read, Grep, Glob |
| `legal-privacy-policy` | Privacy policy | Read, Grep, Glob |
| `legal-rgpd` | Conformite RGPD | Read, Grep, Glob |
| `legal-terms-of-service` | CGU | Read, Grep, Glob |
| `ops-ci` | CI/CD | Read, Grep, Glob |
| `ops-database` | Schema DB | Read, Grep, Glob |
| `ops-docker` | Docker | Read, Grep, Glob |
| `ops-monitoring` | Monitoring | Read, Grep, Glob |
| `ops-infra-code` | Infrastructure as Code (Terraform) | Read, Grep, Glob, Edit, Write, Bash |

### Sonnet (Complexe/Analyse)

| Agent | Description | Outils |
|-------|-------------|--------|
| `qa-security` | Audit securite OWASP | Read, Grep, Glob |
| `qa-audit` | Audit complet | Read, Grep, Glob, Bash |
| `qa-perf` | Audit performance | Read, Grep, Glob, Bash |
| `dev-debug` | Investigation bugs | Read, Grep, Glob, Bash |

## Par domaine

### Exploration & Documentation

| Agent | Modele | Usage |
|-------|--------|-------|
| `work-explore` | haiku | Explorer et comprendre le code |
| `doc-onboard` | haiku | Onboarding nouveau developpeur |
| `doc-changelog` | haiku | Generer le changelog |
| `doc-explain` | haiku | Expliquer du code complexe |
| `doc-generate` | haiku | Generer de la documentation |

### Qualite & Audits

| Agent | Modele | Usage |
|-------|--------|-------|
| `qa-security` | sonnet | Audit securite OWASP Top 10 |
| `qa-audit` | sonnet | Audit complet (secu + RGPD + a11y + perf) |
| `qa-perf` | sonnet | Audit performance, Core Web Vitals |
| `qa-a11y` | haiku | Audit accessibilite WCAG 2.1 |
| `qa-coverage` | haiku | Analyse couverture de tests |
| `qa-responsive` | haiku | Audit responsive/mobile-first |

### Operations

| Agent | Modele | Usage |
|-------|--------|-------|
| `ops-deps` | haiku | Audit dependances, vulnerabilites |
| `ops-health` | haiku | Health check rapide du projet |
| `ops-ci` | haiku | Configuration CI/CD |
| `ops-database` | haiku | Schema et migrations |
| `ops-docker` | haiku | Dockerisation |
| `ops-monitoring` | haiku | Monitoring et alertes |
| `ops-infra-code` | sonnet | Infrastructure as Code (Terraform, OpenTofu) |

### Developpement

| Agent | Modele | Usage |
|-------|--------|-------|
| `dev-debug` | sonnet | Investigation et diagnostic de bugs |
| `dev-component` | haiku | Creation de composants |
| `dev-flutter` | haiku | Widgets et screens Flutter |
| `dev-supabase` | haiku | Backend Supabase |
| `dev-test` | haiku | Generation de tests |

### Business & Growth

| Agent | Modele | Usage |
|-------|--------|-------|
| `biz-model` | haiku | Analyse business model |
| `biz-competitor` | haiku | Analyse concurrentielle |
| `biz-mvp` | haiku | Definition MVP |
| `biz-personas` | haiku | Personas utilisateur |
| `growth-seo` | haiku | Audit SEO technique |
| `growth-analytics` | haiku | Setup analytics |
| `growth-funnel` | haiku | Optimisation funnel |
| `growth-landing` | haiku | Landing page |

### Data

| Agent | Modele | Usage |
|-------|--------|-------|
| `data-analytics` | haiku | Analyse de donnees |
| `data-modeling` | haiku | Modelisation |
| `data-pipeline` | haiku | Pipelines ETL |

### Legal

| Agent | Modele | Usage |
|-------|--------|-------|
| `legal-payment` | haiku | Integration paiement |
| `legal-privacy-policy` | haiku | Privacy policy |
| `legal-rgpd` | haiku | Conformite RGPD |
| `legal-terms-of-service` | haiku | CGU |

---

## Voir aussi

- [Matrice des Commands](/docs/reference/commands-matrix)
- [Cheatsheet](/docs/reference/cheatsheet)
- [Architecture](/docs/intro/architecture)
