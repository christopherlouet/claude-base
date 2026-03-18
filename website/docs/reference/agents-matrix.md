---
sidebar_position: 3
title: Matrice des Agents
description: Liste complete des 57 agents
---

# Matrice des Agents

> **57 sub-agents** avec modele et outils

## Par modele

### Haiku (26 agents - Rapide/Economique)

| Agent | Description | Outils |
|-------|-------------|--------|
| `biz-competitor` | Analyse concurrentielle | Read, Grep, Glob, WebSearch |
| `biz-model` | Business model | Read, Grep, Glob, WebSearch |
| `biz-mvp` | Definition MVP | Read, Grep, Glob, Edit, Write |
| `biz-personas` | Personas utilisateur | Read, Grep, Glob, Edit, Write |
| `dev-design-system` | Design tokens et composants | Read, Grep, Glob |
| `dev-prisma` | ORM Prisma | Read, Grep, Glob, Bash |
| `dev-trpc` | APIs type-safe tRPC | Read, Grep, Glob |
| `doc-changelog` | Generer changelog | Read, Grep, Glob, Edit, Write |
| `doc-explain` | Expliquer du code | Read, Grep, Glob |
| `doc-generate` | Generer documentation | Read, Grep, Glob, Edit, Write |
| `doc-onboard` | Onboarding developpeur | Read, Grep, Glob |
| `growth-cro` | Optimisation taux de conversion | Read, Grep, Glob |
| `growth-localization` | Localisation multi-marches | Read, Grep, Glob |
| `growth-seo` | Audit SEO technique | Read, Grep, Glob, WebFetch |
| `legal-privacy-policy` | Politique de confidentialite | Read, Grep, Glob, Edit, Write |
| `legal-terms-of-service` | Conditions Generales | Read, Grep, Glob, Edit, Write |
| `ops-deps` | Audit dependances | Read, Grep, Glob, Bash |
| `ops-health` | Health check rapide | Read, Grep, Glob, Bash |
| `ops-serverless` | Deploiement serverless | Read, Grep, Glob, Bash |
| `ops-vercel` | Deploiement Vercel | Read, Grep, Glob, Bash |
| `wcag-audit` | Audit accessibilite WCAG | Read, Grep, Glob |
| `qa-coverage` | Couverture de tests | Read, Grep, Glob, Bash |
| `qa-design` | Audit UI/UX | Read, Grep, Glob |
| `qa-responsive` | Audit responsive | Read, Grep, Glob |
| `qa-tech-debt` | Dette technique | Read, Grep, Glob |
| `work-explore` | Explorer un codebase | Read, Grep, Glob |

### Sonnet (31 agents - Complexe/Analyse)

| Agent | Description | Outils |
|-------|-------------|--------|
| `data-analytics` | Analyse de donnees | Read, Grep, Glob, Edit, Write, Bash |
| `data-modeling` | Modelisation data warehouse | Read, Grep, Glob, Edit, Write |
| `data-pipeline` | Pipelines ETL/ELT | Read, Grep, Glob, Edit, Write, Bash |
| `dev-ai-integration` | Integration LLMs (OpenAI, Claude) | Read, Grep, Glob, Bash |
| `dev-component` | Composants UI | Read, Grep, Glob, Edit, Write |
| `dev-debug` | Investigation bugs | Read, Grep, Glob, Bash |
| `dev-document` | Generation documents (PDF, DOCX) | Read, Grep, Glob, Edit, Write, Bash |
| `dev-flutter` | Flutter widgets et screens | Read, Grep, Glob, Edit, Write, Bash |
| `dev-prompt-engineering` | Optimisation prompts LLM | Read, Grep, Glob, WebFetch |
| `dev-rag` | Systemes RAG | Read, Grep, Glob, Bash |
| `dev-supabase` | Backend Supabase | Read, Grep, Glob, Edit, Write, Bash |
| `dev-tdd` | Developpement TDD | Read, Grep, Glob, Edit, Write, Bash |
| `dev-test` | Generation de tests | Read, Grep, Glob, Edit, Write, Bash |
| `growth-analytics` | Setup analytics et tracking | Read, Grep, Glob, Edit, Write, Bash |
| `growth-funnel` | Optimisation funnels | Read, Grep, Glob, Edit, Write |
| `growth-landing` | Landing pages | Read, Grep, Glob, Edit, Write |
| `legal-payment` | Integration paiement | Read, Grep, Glob, Edit, Write |
| `legal-rgpd` | Conformite RGPD | Read, Grep, Glob, Edit, Write |
| `ops-ci` | Configuration CI/CD | Read, Grep, Glob, Edit, Write, Bash |
| `ops-database` | Schema et migrations DB | Read, Grep, Glob, Edit, Write, Bash |
| `ops-docker` | Containerisation Docker | Read, Grep, Glob, Edit, Write, Bash |
| `ops-infra-code` | Infrastructure as Code (Terraform) | Read, Grep, Glob, Edit, Write, Bash |
| `ops-migration` | Migration de frameworks | Read, Grep, Glob, Bash |
| `ops-monitoring` | Instrumentation et monitoring | Read, Grep, Glob, Edit, Write, Bash |
| `ops-opnsense` | Configuration OPNsense | Read, Grep, Glob, Edit, Write, Bash |
| `ops-proxmox` | Infrastructure Proxmox VE | Read, Grep, Glob, Edit, Write, Bash |
| `qa-audit` | Audit qualite complet | Read, Grep, Glob, Bash |
| `qa-chrome` | Tests visuels Chrome | Read, Grep, Glob, Bash |
| `qa-e2e` | Tests End-to-End | Read, Grep, Glob, Bash |
| `qa-perf` | Audit performance | Read, Grep, Glob, Bash |
| `qa-security` | Audit securite OWASP | Read, Grep, Glob, Bash |

## Par domaine

### Exploration & Documentation (5)

| Agent | Modele | Usage |
|-------|--------|-------|
| `work-explore` | haiku | Explorer et comprendre le code |
| `doc-onboard` | haiku | Onboarding nouveau developpeur |
| `doc-changelog` | haiku | Generer le changelog |
| `doc-explain` | haiku | Expliquer du code complexe |
| `doc-generate` | haiku | Generer de la documentation |

### Qualite & Audits (10)

| Agent | Modele | Usage |
|-------|--------|-------|
| `qa-security` | sonnet | Audit securite OWASP Top 10 |
| `qa-audit` | sonnet | Audit complet (secu + RGPD + a11y + perf) |
| `qa-perf` | sonnet | Audit performance, Core Web Vitals |
| `qa-chrome` | sonnet | Tests visuels et debugging Chrome |
| `qa-e2e` | sonnet | Tests End-to-End (Playwright, Cypress) |
| `wcag-audit` | haiku | Audit accessibilite WCAG 2.1 |
| `qa-coverage` | haiku | Analyse couverture de tests |
| `qa-design` | haiku | Audit UI/UX (100+ regles) |
| `qa-responsive` | haiku | Audit responsive/mobile-first |
| `qa-tech-debt` | haiku | Identifier la dette technique |

### Operations (12)

| Agent | Modele | Usage |
|-------|--------|-------|
| `ops-ci` | sonnet | Configuration CI/CD |
| `ops-database` | sonnet | Schema et migrations DB |
| `ops-docker` | sonnet | Containerisation Docker |
| `ops-infra-code` | sonnet | Infrastructure as Code (Terraform) |
| `ops-migration` | sonnet | Migration de frameworks et versions |
| `ops-monitoring` | sonnet | Instrumentation et monitoring |
| `ops-opnsense` | sonnet | Configuration OPNsense via Terraform |
| `ops-proxmox` | sonnet | Infrastructure Proxmox VE |
| `ops-deps` | haiku | Audit dependances, vulnerabilites |
| `ops-health` | haiku | Health check rapide du projet |
| `ops-serverless` | haiku | Deploiement serverless |
| `ops-vercel` | haiku | Deploiement Vercel |

### Developpement (13)

| Agent | Modele | Usage |
|-------|--------|-------|
| `dev-ai-integration` | sonnet | Integration LLMs (OpenAI, Claude API) |
| `dev-component` | sonnet | Creation de composants UI |
| `dev-debug` | sonnet | Investigation et diagnostic de bugs |
| `dev-document` | sonnet | Generation documents bureautiques |
| `dev-flutter` | sonnet | Widgets et screens Flutter |
| `dev-prompt-engineering` | sonnet | Optimisation prompts LLM |
| `dev-rag` | sonnet | Architecture RAG |
| `dev-supabase` | sonnet | Backend Supabase |
| `dev-tdd` | sonnet | Developpement TDD (Red-Green-Refactor) |
| `dev-test` | sonnet | Generation de tests |
| `dev-design-system` | haiku | Design tokens et composants |
| `dev-prisma` | haiku | ORM Prisma |
| `dev-trpc` | haiku | APIs type-safe tRPC |

### Business & Growth (10)

| Agent | Modele | Usage |
|-------|--------|-------|
| `growth-analytics` | sonnet | Setup analytics et tracking |
| `growth-funnel` | sonnet | Optimisation funnels |
| `growth-landing` | sonnet | Landing pages optimisees |
| `biz-model` | haiku | Analyse business model |
| `biz-competitor` | haiku | Analyse concurrentielle |
| `biz-mvp` | haiku | Definition MVP |
| `biz-personas` | haiku | Personas utilisateur |
| `growth-cro` | haiku | Optimisation taux de conversion |
| `growth-localization` | haiku | Localisation multi-marches |
| `growth-seo` | haiku | Audit SEO technique |

### Data (3)

| Agent | Modele | Usage |
|-------|--------|-------|
| `data-analytics` | sonnet | Analyse de donnees |
| `data-modeling` | sonnet | Modelisation data warehouse |
| `data-pipeline` | sonnet | Pipelines ETL/ELT |

### Legal (4)

| Agent | Modele | Usage |
|-------|--------|-------|
| `legal-payment` | sonnet | Integration paiement |
| `legal-rgpd` | sonnet | Conformite RGPD |
| `legal-privacy-policy` | haiku | Politique de confidentialite |
| `legal-terms-of-service` | haiku | Conditions Generales |

---

## Voir aussi

- [Matrice des Commands](/docs/reference/commands-matrix)
- [Cheatsheet](/docs/reference/cheatsheet)
- [Architecture](/docs/intro/architecture)
