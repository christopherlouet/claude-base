---
sidebar_position: 1
title: "Agents"
description: "Catalogue des 47 sub-agents claude-socle"
---

import Stats from '@site/src/components/Stats';
import { AgentGrid } from '@site/src/components/AgentCard';
import AgentCard from '@site/src/components/AgentCard';

# Catalogue des Agents

> **47 sub-agents** avec contexte isole pour des taches autonomes

<Stats items={[
  { number: 22, label: 'Agents Haiku' },
  { number: 25, label: 'Agents Sonnet' },
  { number: 47, label: 'Total' },
]} />

## Qu'est-ce qu'un Agent ?

Les **agents** sont des sub-agents autonomes avec un contexte isole :

- **Declenchement automatique** : Claude delegue selon le contexte
- **Contexte isole** : Ne pollue pas la conversation principale
- **Outils restreints** : Acces limite selon la tache
- **Modele specifique** : Haiku (rapide) ou Sonnet (complexe)

## Agents par modele

### Haiku (22 agents)

Agents rapides et economiques pour les taches simples.

| Agent | Description | Outils |
|-------|-------------|--------|
| [`biz-competitor`](/docs/agents/biz-competitor) | Analyse concurrentielle et positionnement strategique. | Read, Grep, Glob... |
| [`biz-model`](/docs/agents/biz-model) | Analyse business et proposition de business model pour un pr... | Read, Grep, Glob... |
| [`biz-mvp`](/docs/agents/biz-mvp) | Definition et planification du Minimum Viable Product. | Read, Grep, Glob... |
| [`biz-personas`](/docs/agents/biz-personas) | Creation de personas utilisateur bases sur des donnees. | Read, Grep, Glob... |
| [`dev-design-system`](/docs/agents/dev-design-system) | Design systems et bibliotheques de composants. | Read, Grep, Glob |
| [`dev-prisma`](/docs/agents/dev-prisma) | Prisma ORM pour bases de donnees type-safe. | Read, Grep, Glob... |
| [`dev-trpc`](/docs/agents/dev-trpc) | APIs type-safe avec tRPC. | Read, Grep, Glob |
| [`doc-changelog`](/docs/agents/doc-changelog) | Gestion du changelog selon la convention Keep a Changelog. | Read, Grep, Glob... |
| [`doc-explain`](/docs/agents/doc-explain) | Explication pedagogique de code complexe. | Read, Grep, Glob |
| [`doc-generate`](/docs/agents/doc-generate) | Generation de documentation complete et maintenable. | Read, Grep, Glob... |
| [`doc-onboard`](/docs/agents/doc-onboard) | Guide de decouverte et comprehension d'un codebase. | Read, Grep, Glob |
| [`growth-seo`](/docs/agents/growth-seo) | Audit SEO technique et recommandations d'optimisation. | Read, Grep, Glob... |
| [`legal-privacy-policy`](/docs/agents/legal-privacy-policy) | Creation de politique de confidentialite conforme RGPD. | Read, Grep, Glob... |
| [`legal-terms-of-service`](/docs/agents/legal-terms-of-service) | Creation de Conditions Generales d'Utilisation conformes. | Read, Grep, Glob... |
| [`ops-deps`](/docs/agents/ops-deps) | Audit, analyse et recommandations pour les dependances du pr... | Read, Grep, Glob... |
| [`ops-health`](/docs/agents/ops-health) | Health check rapide pour evaluer l'etat general d'un projet. | Read, Grep, Glob... |
| [`ops-serverless`](/docs/agents/ops-serverless) | Deploiement d'applications serverless. | Read, Grep, Glob... |
| [`ops-vercel`](/docs/agents/ops-vercel) | Deploiement sur Vercel. | Read, Grep, Glob... |
| [`qa-a11y`](/docs/agents/qa-a11y) | Audit d'accessibilite selon les normes WCAG 2.1 niveau AA. | Read, Grep, Glob |
| [`qa-coverage`](/docs/agents/qa-coverage) | Analyse de la couverture de tests et de la qualite des tests... | Read, Grep, Glob... |
| [`qa-responsive`](/docs/agents/qa-responsive) | Audit de la conception responsive et de l'experience mobile. | Read, Grep, Glob |
| [`work-explore`](/docs/agents/work-explore) | Tu es en mode EXPLORATION. Analyse le codebase sans jamais m... | Read, Grep, Glob |

### Sonnet (24 agents)

Agents pour les taches complexes necessitant une analyse approfondie.

| Agent | Description | Outils |
|-------|-------------|--------|
| [`data-analytics`](/docs/agents/data-analytics) | Analyse de donnees et generation d'insights. | Read, Grep, Glob... |
| [`data-modeling`](/docs/agents/data-modeling) | Conception de modeles de donnees pour analytics. | Read, Grep, Glob... |
| [`data-pipeline`](/docs/agents/data-pipeline) | Conception et implementation de pipelines de donnees. | Read, Grep, Glob... |
| [`dev-component`](/docs/agents/dev-component) | Creation de composants UI modulaires et reutilisables. | Read, Grep, Glob... |
| [`dev-debug`](/docs/agents/dev-debug) | Diagnostic et resolution de bugs de maniere methodique. | Read, Grep, Glob... |
| [`dev-flutter`](/docs/agents/dev-flutter) | Developpement d'applications Flutter avec bonnes pratiques. | Read, Grep, Glob... |
| [`dev-prompt-engineering`](/docs/agents/dev-prompt-engineering) | Optimisation systematique de prompts pour applications LLM. | Read, Grep, Glob... |
| [`dev-rag`](/docs/agents/dev-rag) | Architecture et implementation de systemes RAG. | Read, Grep, Glob... |
| [`dev-supabase`](/docs/agents/dev-supabase) | Integration complete de Supabase comme backend. | Read, Grep, Glob... |
| [`dev-test`](/docs/agents/dev-test) | Generation de tests complets et maintenables. | Read, Grep, Glob... |
| [`growth-analytics`](/docs/agents/growth-analytics) | Implementation de l'analytics et du tracking. | Read, Grep, Glob... |
| [`growth-funnel`](/docs/agents/growth-funnel) | Analyse et optimisation des funnels de conversion. | Read, Grep, Glob... |
| [`growth-landing`](/docs/agents/growth-landing) | Creation de landing pages optimisees pour la conversion. | Read, Grep, Glob... |
| [`legal-payment`](/docs/agents/legal-payment) | Integration paiement securisee et conforme. | Read, Grep, Glob... |
| [`legal-rgpd`](/docs/agents/legal-rgpd) | Conformite RGPD (Reglement General sur la Protection des Don... | Read, Grep, Glob... |
| [`ops-ci`](/docs/agents/ops-ci) | Configuration de pipelines CI/CD complets. | Read, Grep, Glob... |
| [`ops-database`](/docs/agents/ops-database) | Conception et gestion de bases de donnees. | Read, Grep, Glob... |
| [`ops-docker`](/docs/agents/ops-docker) | Containerisation Docker optimisee pour la production. | Read, Grep, Glob... |
| [`ops-monitoring`](/docs/agents/ops-monitoring) | Instrumentation complete pour observabilite. | Read, Grep, Glob... |
| [`qa-audit`](/docs/agents/qa-audit) | Audit qualite complet d'un projet couvrant securite, RGPD, a... | Read, Grep, Glob... |
| [`qa-e2e`](/docs/agents/qa-e2e) | Tests End-to-End pour parcours utilisateur critiques. | Read, Grep, Glob... |
| [`qa-perf`](/docs/agents/qa-perf) | Analyse et optimisation des performances. | Read, Grep, Glob... |
| [`ops-infra-code`](/docs/agents/ops-infra-code) | Infrastructure as Code (Terraform, OpenTofu). Creer des modul... | Read, Grep, Glob... |
| [`qa-security`](/docs/agents/qa-security) | Audit de securite approfondi base sur OWASP Top 10. | Read, Grep, Glob... |



## Vue en cartes

<AgentGrid>
  <AgentCard
    name="biz-competitor"
    description="Analyse concurrentielle et positionnement strategique."
    model="haiku"
    tools={["Read","Grep","Glob","WebSearch"]}
    href="/docs/agents/biz-competitor"
  />
  <AgentCard
    name="biz-model"
    description="Analyse business et proposition de business model pour un projet."
    model="haiku"
    tools={["Read","Grep","Glob","WebSearch"]}
    href="/docs/agents/biz-model"
  />
  <AgentCard
    name="biz-mvp"
    description="Definition et planification du Minimum Viable Product."
    model="haiku"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-mvp"
  />
  <AgentCard
    name="biz-personas"
    description="Creation de personas utilisateur bases sur des donnees."
    model="haiku"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-personas"
  />
  <AgentCard
    name="data-analytics"
    description="Analyse de donnees et generation d'insights."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-analytics"
  />
  <AgentCard
    name="data-modeling"
    description="Conception de modeles de donnees pour analytics."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-modeling"
  />
  <AgentCard
    name="data-pipeline"
    description="Conception et implementation de pipelines de donnees."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-pipeline"
  />
  <AgentCard
    name="dev-component"
    description="Creation de composants UI modulaires et reutilisables."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-component"
  />
  <AgentCard
    name="dev-debug"
    description="Diagnostic et resolution de bugs de maniere methodique."
    model="sonnet"
    tools={["Read","Grep","Glob","Bash"]}
    href="/docs/agents/dev-debug"
  />
  <AgentCard
    name="dev-design-system"
    description="Design systems et bibliotheques de composants."
    model="haiku"
    tools={["Read","Grep","Glob"]}
    href="/docs/agents/dev-design-system"
  />
  <AgentCard
    name="dev-flutter"
    description="Developpement d'applications Flutter avec bonnes pratiques."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-flutter"
  />
  <AgentCard
    name="dev-prisma"
    description="Prisma ORM pour bases de donnees type-safe."
    model="haiku"
    tools={["Read","Grep","Glob","Bash"]}
    href="/docs/agents/dev-prisma"
  />
</AgentGrid>

[Voir tous les agents...](#agents-par-modele)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
