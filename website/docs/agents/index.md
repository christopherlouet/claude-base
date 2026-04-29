---
sidebar_position: 1
title: "Agents"
description: "Catalogue des 63 sub-agents claude-socle"
---

import Stats from '@site/src/components/Stats';
import { AgentGrid } from '@site/src/components/AgentCard';
import AgentCard from '@site/src/components/AgentCard';

# Catalogue des Agents

> **63 sub-agents** avec contexte isole pour des taches autonomes

<Stats items={[
  { number: 22, label: 'Agents Haiku' },
  { number: 35, label: 'Agents Sonnet' },
  { number: 63, label: 'Total' },
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
| [`biz-model`](/docs/agents/biz-model) | Analyse business et proposition de business model pour un pr... | Read, Grep, Glob... |
| [`dev-design-system`](/docs/agents/dev-design-system) | Design systems et bibliotheques de composants. | Read, Grep, Glob |
| [`dev-prisma`](/docs/agents/dev-prisma) | Prisma ORM pour bases de donnees type-safe. | Read, Grep, Glob... |
| [`dev-trpc`](/docs/agents/dev-trpc) | APIs type-safe avec tRPC. | Read, Grep, Glob |
| [`doc-changelog`](/docs/agents/doc-changelog) | Gestion du changelog selon la convention Keep a Changelog. | Read, Grep, Glob... |
| [`doc-explain`](/docs/agents/doc-explain) | Explication pedagogique de code complexe. | Read, Grep, Glob |
| [`doc-onboard`](/docs/agents/doc-onboard) | Guide de decouverte et comprehension d'un codebase. | Read, Grep, Glob |
| [`growth-cro`](/docs/agents/growth-cro) | Audit et optimisation du taux de conversion. | Read, Grep, Glob |
| [`growth-localization`](/docs/agents/growth-localization) | Strategie de localisation et expansion internationale. | Read, Grep, Glob |
| [`legal-privacy-policy`](/docs/agents/legal-privacy-policy) | Creation de politique de confidentialite conforme RGPD. | Read, Grep, Glob... |
| [`legal-terms-of-service`](/docs/agents/legal-terms-of-service) | Creation de Conditions Generales d'Utilisation conformes. | Read, Grep, Glob... |
| [`ops-cost`](/docs/agents/ops-cost) | Analyse de la consommation de tokens et recommandations d'op... | Read, Grep, Glob... |
| [`ops-deps`](/docs/agents/ops-deps) | Audit, analyse et recommandations pour les dependances du pr... | Read, Grep, Glob... |
| [`ops-health`](/docs/agents/ops-health) | Health check rapide pour evaluer l'etat general d'un projet. | Read, Grep, Glob... |
| [`ops-serverless`](/docs/agents/ops-serverless) | Deploiement d'applications serverless. | Read, Grep, Glob... |
| [`ops-vercel`](/docs/agents/ops-vercel) | Deploiement sur Vercel. | Read, Grep, Glob... |
| [`qa-coverage`](/docs/agents/qa-coverage) | Analyse de la couverture de tests et de la qualite des tests... | Read, Grep, Glob... |
| [`qa-design`](/docs/agents/qa-design) | Audit de design UI/UX avec 100+ regles de verification. | Read, Grep, Glob |
| [`qa-responsive`](/docs/agents/qa-responsive) | Audit de la conception responsive et de l'experience mobile. | Read, Grep, Glob |
| [`qa-tech-debt`](/docs/agents/qa-tech-debt) | Identification et priorisation de la dette technique. | Read, Grep, Glob |
| [`wcag-audit`](/docs/agents/wcag-audit) | Audit d'accessibilite selon WCAG 2.1/2.2 niveau AA, inspire ... | Read, Grep, Glob |
| [`work-explore`](/docs/agents/work-explore) | Mode EXPLORATION : analyse du codebase sans modifier de fich... | Read, Grep, Glob |

### Sonnet (35 agents)

Agents pour les taches complexes necessitant une analyse approfondie.

| Agent | Description | Outils |
|-------|-------------|--------|
| [`biz-competitor`](/docs/agents/biz-competitor) | Analyse concurrentielle et positionnement strategique pour u... | Read, Grep, Glob... |
| [`biz-mvp`](/docs/agents/biz-mvp) | Definition et planification du Minimum Viable Product. | Read, Grep, Glob... |
| [`biz-personas`](/docs/agents/biz-personas) | Creation de personas utilisateur bases sur des donnees. | Read, Grep, Glob... |
| [`data-analytics`](/docs/agents/data-analytics) | Analyse de donnees et generation d'insights actionnables. | Read, Grep, Glob... |
| [`data-modeling`](/docs/agents/data-modeling) | Conception de modeles de donnees dimensionnels pour analytic... | Read, Grep, Glob... |
| [`data-pipeline`](/docs/agents/data-pipeline) | Conception et implementation de pipelines de donnees ETL/ELT... | Read, Grep, Glob... |
| [`dev-ai-integration`](/docs/agents/dev-ai-integration) | Integration de LLMs et APIs IA dans les applications. | Read, Grep, Glob... |
| [`dev-component`](/docs/agents/dev-component) | Creation de composants UI modulaires et reutilisables. | Read, Grep, Glob... |
| [`dev-document`](/docs/agents/dev-document) | Generation de documents bureautiques et rapports. | Read, Grep, Glob... |
| [`dev-flutter`](/docs/agents/dev-flutter) | Developpement Flutter avec Clean Architecture et BLoC. | Read, Grep, Glob... |
| [`dev-prompt-engineering`](/docs/agents/dev-prompt-engineering) | Optimisation systematique de prompts pour applications LLM. | Read, Grep, Glob... |
| [`dev-supabase`](/docs/agents/dev-supabase) | Integration complete de Supabase comme backend. | Read, Grep, Glob... |
| [`dev-test`](/docs/agents/dev-test) | Generation de tests complets et maintenables. | Read, Grep, Glob... |
| [`doc-generate`](/docs/agents/doc-generate) | Generation de documentation complete et maintenable. | Read, Grep, Glob... |
| [`growth-analytics`](/docs/agents/growth-analytics) | Implementation de l'analytics et du tracking. | Read, Grep, Glob... |
| [`growth-funnel`](/docs/agents/growth-funnel) | Analyse et optimisation des funnels de conversion. | Read, Grep, Glob... |
| [`growth-landing`](/docs/agents/growth-landing) | Creation de landing pages optimisees pour la conversion. | Read, Grep, Glob... |
| [`growth-seo`](/docs/agents/growth-seo) | Audit SEO technique et recommandations d'optimisation. | Read, Grep, Glob... |
| [`legal-payment`](/docs/agents/legal-payment) | Integration paiement securisee et conforme. | Read, Grep, Glob... |
| [`legal-rgpd`](/docs/agents/legal-rgpd) | Conformite RGPD (Reglement General sur la Protection des Don... | Read, Grep, Glob... |
| [`ops-ci`](/docs/agents/ops-ci) | Configuration de pipelines CI/CD complets. | Read, Grep, Glob... |
| [`ops-database`](/docs/agents/ops-database) | Conception et gestion de bases de donnees. | Read, Grep, Glob... |
| [`ops-deploy`](/docs/agents/ops-deploy) | Deploiement securise avec validation pre-deploy obligatoire. | Read, Grep, Glob... |
| [`ops-docker`](/docs/agents/ops-docker) | Containerisation Docker optimisee pour la production. | Read, Grep, Glob... |
| [`ops-infra-code`](/docs/agents/ops-infra-code) | Infrastructure as Code avec Terraform/OpenTofu. Le skill `op... | Read, Grep, Glob... |
| [`ops-migration`](/docs/agents/ops-migration) | Planification et execution de migrations techniques. | Read, Grep, Glob... |
| [`ops-monitoring`](/docs/agents/ops-monitoring) | Instrumentation complete pour observabilite (3 piliers). | Read, Grep, Glob... |
| [`ops-opnsense`](/docs/agents/ops-opnsense) | Configuration OPNsense en IaC avec Terraform. Le skill `ops-... | Read, Grep, Glob... |
| [`ops-proxmox`](/docs/agents/ops-proxmox) | Gestion d'infrastructure Proxmox VE avec Terraform. Le skill... | Read, Grep, Glob... |
| [`qa-chrome`](/docs/agents/qa-chrome) | Audit visuel et tests navigateur. Prerequis : `claude --chro... | Read, Grep, Glob... |
| [`qa-claudemd`](/docs/agents/qa-claudemd) | Audit de conformite au CLAUDE.md du projet et aux convention... | Read, Grep, Glob... |
| [`qa-e2e`](/docs/agents/qa-e2e) | Tests End-to-End pour parcours utilisateur critiques. | Read, Grep, Glob... |
| [`qa-perf`](/docs/agents/qa-perf) | Analyse et optimisation des performances. | Read, Grep, Glob... |
| [`work-batch`](/docs/agents/work-batch) | Execution autonome de stories depuis un PRD. Le skill `work-... | Read, Grep, Glob... |
| [`work-quick`](/docs/agents/work-quick) | Workflow rapide pour changements triviaux. Le skill `work-qu... | Read, Grep, Glob... |


### Opus (6 agents)

Agents pour les taches critiques.

| Agent | Description | Outils |
|-------|-------------|--------|
| [`dev-debug`](/docs/agents/dev-debug) | Diagnostic et resolution de bugs. Le skill `dev-debug` fourn... | Read, Grep, Glob... |
| [`dev-rag`](/docs/agents/dev-rag) | Architecture et implementation de systemes RAG. | Read, Grep, Glob... |
| [`dev-tdd`](/docs/agents/dev-tdd) | Developpement guide par les tests. Le skill `dev-tdd` fourni... | Read, Grep, Glob... |
| [`qa-audit`](/docs/agents/qa-audit) | Audit qualite complet couvrant 5 domaines. | Read, Grep, Glob... |
| [`qa-loop`](/docs/agents/qa-loop) | Boucle autonome **AUDIT (parallele) → VALIDATE → FIX → VERIF... | Read, Grep, Glob... |
| [`qa-security`](/docs/agents/qa-security) | Audit de securite OWASP Top 10. Le skill `qa-security` fourn... | Read, Grep, Glob... |


## Vue en cartes

<AgentGrid>
  <AgentCard
    name="biz-competitor"
    description="Analyse concurrentielle et positionnement strategique pour un projet."
    model="sonnet"
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
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-mvp"
  />
  <AgentCard
    name="biz-personas"
    description="Creation de personas utilisateur bases sur des donnees."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-personas"
  />
  <AgentCard
    name="data-analytics"
    description="Analyse de donnees et generation d'insights actionnables."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-analytics"
  />
  <AgentCard
    name="data-modeling"
    description="Conception de modeles de donnees dimensionnels pour analytics."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-modeling"
  />
  <AgentCard
    name="data-pipeline"
    description="Conception et implementation de pipelines de donnees ETL/ELT."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-pipeline"
  />
  <AgentCard
    name="dev-ai-integration"
    description="Integration de LLMs et APIs IA dans les applications."
    model="sonnet"
    tools={["Read","Grep","Glob","Bash"]}
    href="/docs/agents/dev-ai-integration"
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
    description="Diagnostic et resolution de bugs. Le skill `dev-debug` fournit la methodologie d"
    model="opus"
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
    name="dev-document"
    description="Generation de documents bureautiques et rapports."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-document"
  />
</AgentGrid>

[Voir tous les agents...](#agents-par-modele)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
