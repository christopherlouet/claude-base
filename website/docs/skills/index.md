---
sidebar_position: 1
title: "Skills"
description: "Catalogue des 54 skills auto-declenches"
---

import Stats from '@site/src/components/Stats';
import { SkillGrid } from '@site/src/components/SkillCard';
import SkillCard from '@site/src/components/SkillCard';

# Catalogue des Skills

> **54 skills** auto-declenches par mots-cles

<Stats items={[
  { number: 54, label: 'Skills Fork' },
  { number: 0, label: 'Skills Shared' },
  { number: 54, label: 'Total' },
]} />

## Qu'est-ce qu'un Skill ?

Les **skills** sont des comportements auto-declenches :

- **Declenchement automatique** : Active par mots-cles dans la conversation
- **Contexte configurable** : Fork (isole) ou Shared (partage)
- **Outils restreints** : Acces limite via `allowed-tools`
- **Transparence** : L'utilisateur voit quand un skill est active

## Skills par contexte

### Fork (54 skills)

Skills avec contexte isole.

| Skill | Description | Mots-cles |
|-------|-------------|-----------|
| [`agent-teams`](/docs/skills/agent-teams) | Orchestration d'equipes d'agents avec Agent Teams ... | agent, teams, audit-team |
| [`api-mocking`](/docs/skills/api-mocking) | Configuration de mocks API pour les tests. Declenc... | api, mocking, mock api |
| [`data-pipeline`](/docs/skills/data-pipeline) | Conception de pipelines ETL/ELT. Declencher quand ... | data, pipeline |
| [`dev-api`](/docs/skills/dev-api) | Développer et documenter une API REST ou GraphQL. ... | dev, api, field1 |
| [`dev-auth`](/docs/skills/dev-auth) | Implementation auth web moderne (better-auth, Luci... | dev, auth, user peut edit si owner |
| [`dev-debug`](/docs/skills/dev-debug) | Deboguer et resoudre des problemes. Utiliser quand... | dev, debug, quick fix pour l'instant |
| [`dev-document`](/docs/skills/dev-document) | Generation de documents (PDF, DOCX, XLSX, PPTX). D... | dev, document |
| [`dev-error-handling`](/docs/skills/dev-error-handling) | Strategie de gestion des erreurs. Declencher quand... | dev, error, handling |
| [`dev-flutter`](/docs/skills/dev-flutter) | Developpement Flutter avec Clean Architecture et B... | dev, flutter |
| [`dev-frontend-design`](/docs/skills/dev-frontend-design) | Design UI distinctif avec direction artistique for... | dev, frontend, design |
| [`dev-graphql`](/docs/skills/dev-graphql) | Developpement d'APIs GraphQL. Declencher quand l'u... | dev, graphql |
| [`dev-i18n`](/docs/skills/dev-i18n) | Internationalisation (i18n) et localisation (l10n)... | dev, i18n, d'accord |
| [`dev-nextjs`](/docs/skills/dev-nextjs) | Developpement Next.js (App Router, Server Componen... | dev, nextjs, use client |
| [`dev-prisma`](/docs/skills/dev-prisma) | Developpement avec Prisma ORM (schema, migrations,... | dev, prisma |
| [`dev-prompt-engineering`](/docs/skills/dev-prompt-engineering) | Optimisation de prompts pour LLMs. Declencher quan... | dev, prompt, engineering |
| [`dev-react-perf`](/docs/skills/dev-react-perf) | Optimisation des performances React/Next.js. Decle... | dev, react, perf |
| [`dev-refactor`](/docs/skills/dev-refactor) | Refactoring de code pour ameliorer la qualite. Dec... | dev, refactor |
| [`dev-shadcn`](/docs/skills/dev-shadcn) | Integration et customisation de shadcn/ui (composa... | dev, shadcn |
| [`dev-supabase`](/docs/skills/dev-supabase) | Developpement backend avec Supabase. Declencher qu... | dev, supabase |
| [`dev-tdd`](/docs/skills/dev-tdd) | Développement TDD avec cycle Red-Green-Refactor. U... | dev, tdd, comme reference |
| [`doc-changelog`](/docs/skills/doc-changelog) | Maintenance du CHANGELOG selon Keep a Changelog. D... | doc, changelog |
| [`doc-generate`](/docs/skills/doc-generate) | Generation de documentation technique. Declencher ... | doc, generate |
| [`feature-flags`](/docs/skills/feature-flags) | Gestion de feature flags et toggles. Declencher qu... | feature, flags, feature flag |
| [`git-worktrees`](/docs/skills/git-worktrees) | Utilisation de git worktrees pour le developpement... | git, worktrees, sessions paralleles |
| [`growth-cro`](/docs/skills/growth-cro) | Optimisation du taux de conversion (CRO). Declench... | growth, cro, comment |
| [`ops-ci`](/docs/skills/ops-ci) | Configuration de pipelines CI/CD. Declencher quand... | ops |
| [`ops-ci-fix`](/docs/skills/ops-ci-fix) | Diagnostic et reparation autonome des pipelines CI... | ops, fix |
| [`ops-database`](/docs/skills/ops-database) | Conception de schemas de base de donnees. Declench... | ops, database |
| [`ops-docker`](/docs/skills/ops-docker) | Containerisation Docker et Docker Compose. Declenc... | ops, docker |
| [`ops-infra-code`](/docs/skills/ops-infra-code) | Infrastructure as Code avec Terraform/OpenTofu. De... | ops, infra, code |
| [`ops-mobile-release`](/docs/skills/ops-mobile-release) | Publication d'apps sur App Store et Google Play. D... | ops, mobile, release |
| [`ops-monitoring`](/docs/skills/ops-monitoring) | Instrumentation d'applications pour monitoring. De... | ops, monitoring |
| [`ops-opnsense`](/docs/skills/ops-opnsense) | Configuration OPNsense via Terraform. Declencher p... | ops, opnsense |
| [`ops-proxmox`](/docs/skills/ops-proxmox) | Infrastructure Proxmox VE avec Terraform (VMs, LXC... | ops, proxmox, pve |
| [`ops-standup`](/docs/skills/ops-standup) | Briefing matinal cross-repo. Agregation des commit... | ops, standup, aucune activite |
| [`parallel-agents`](/docs/skills/parallel-agents) | Orchestration d'agents paralleles pour maximiser l... | parallel, agents |
| [`qa-chrome`](/docs/skills/qa-chrome) | Tests visuels et debugging navigateur via Chrome. ... | chrome, claude in chrome |
| [`qa-design`](/docs/skills/qa-design) | Audit de design UI/UX et verification des bonnes p... | design, champ invalide, image |
| [`qa-e2e`](/docs/skills/qa-e2e) | Tests End-to-End avec Playwright ou Cypress. Decle... | e2e, end-to-end, test de bout en bout |
| [`qa-perf`](/docs/skills/qa-perf) | Optimisation des performances d'applications. Decl... | perf |
| [`qa-review`](/docs/skills/qa-review) | Effectuer une revue de code approfondie. Utiliser ... | review |
| [`qa-security`](/docs/skills/qa-security) | Effectuer un audit de sécurité basé sur OWASP. Uti... | security |
| [`qa-tech-debt`](/docs/skills/qa-tech-debt) | Gestion et priorisation de la dette technique. Dec... | tech, debt, dette technique |
| [`session-handoff`](/docs/skills/session-handoff) | Transfert de contexte entre sessions IA. Declenche... | session, handoff |
| [`state-management`](/docs/skills/state-management) | Patterns et implementation de state management. De... | state, management, state management |
| [`web-scraping`](/docs/skills/web-scraping) | Scraping web propre pour LLM via Firecrawl (scrape... | web, scraping, extrait les donnees de ... |
| [`work-batch`](/docs/skills/work-batch) | Execution sequentielle de user stories depuis un f... | work, batch |
| [`work-brainstorm`](/docs/skills/work-brainstorm) | Ideation structuree avant specification. Transform... | work, brainstorm, j'ai une idee vague |
| [`work-commit`](/docs/skills/work-commit) | Génère des messages de commit clairs suivant Conve... | work, commit, add |
| [`work-explore`](/docs/skills/work-explore) | Explorer et comprendre un codebase existant. Utili... | work, explore |
| [`work-plan`](/docs/skills/work-plan) | Planifier l'implémentation d'une fonctionnalité. U... | work, plan |
| [`work-pr`](/docs/skills/work-pr) | Créer une Pull Request complète et bien documentée... | work, fix bug |
| [`work-quick`](/docs/skills/work-quick) | Workflow rapide pour changements triviaux (single-... | work, quick |
| [`writing-skills`](/docs/skills/writing-skills) | Guide pour creer de nouveaux skills pour le socle ... | writing, skills |



## Vue en cartes

<SkillGrid>
  <SkillCard
    name="agent-teams"
    description="Orchestration d'equipes d'agents avec Agent Teams natif. Declencher quand l'util"
    keywords={["agent","teams","audit-team"]}
    context="fork"
    href="/docs/skills/agent-teams"
  />
  <SkillCard
    name="api-mocking"
    description="Configuration de mocks API pour les tests. Declencher quand l'utilisateur veut m"
    keywords={["api","mocking","mock api","msw"]}
    context="fork"
    href="/docs/skills/api-mocking"
  />
  <SkillCard
    name="data-pipeline"
    description="Conception de pipelines ETL/ELT. Declencher quand l'utilisateur veut creer des f"
    keywords={["data","pipeline"]}
    context="fork"
    href="/docs/skills/data-pipeline"
  />
  <SkillCard
    name="dev-api"
    description="Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur v"
    keywords={["dev","api","field1","string"]}
    context="fork"
    href="/docs/skills/dev-api"
  />
  <SkillCard
    name="dev-auth"
    description="Implementation auth web moderne (better-auth, Lucia, NextAuth/Auth.js, Clerk, Su"
    keywords={["dev","auth","user peut edit si owner","email inconnu"]}
    context="fork"
    href="/docs/skills/dev-auth"
  />
  <SkillCard
    name="dev-debug"
    description="Deboguer et resoudre des problemes. Utiliser quand l'utilisateur a un bug, une e"
    keywords={["dev","debug","quick fix pour l'instant","essayons juste de changer x"]}
    context="fork"
    href="/docs/skills/dev-debug"
  />
  <SkillCard
    name="dev-document"
    description="Generation de documents (PDF, DOCX, XLSX, PPTX). Declencher quand l'utilisateur "
    keywords={["dev","document"]}
    context="fork"
    href="/docs/skills/dev-document"
  />
  <SkillCard
    name="dev-error-handling"
    description="Strategie de gestion des erreurs. Declencher quand l'utilisateur veut implemente"
    keywords={["dev","error","handling"]}
    context="fork"
    href="/docs/skills/dev-error-handling"
  />
  <SkillCard
    name="dev-flutter"
    description="Developpement Flutter avec Clean Architecture et BLoC. Declencher quand l'utilis"
    keywords={["dev","flutter"]}
    context="fork"
    href="/docs/skills/dev-flutter"
  />
  <SkillCard
    name="dev-frontend-design"
    description="Design UI distinctif avec direction artistique forte. Declencher quand l'utilisa"
    keywords={["dev","frontend","design","parce que c'est joli"]}
    context="fork"
    href="/docs/skills/dev-frontend-design"
  />
  <SkillCard
    name="dev-graphql"
    description="Developpement d'APIs GraphQL. Declencher quand l'utilisateur veut creer des sche"
    keywords={["dev","graphql"]}
    context="fork"
    href="/docs/skills/dev-graphql"
  />
  <SkillCard
    name="dev-i18n"
    description="Internationalisation (i18n) et localisation (l10n) d'applications web et mobile."
    keywords={["dev","i18n","d'accord"]}
    context="fork"
    href="/docs/skills/dev-i18n"
  />
</SkillGrid>

[Voir tous les skills...](#skills-par-contexte)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Agents](/docs/agents) - Les sub-agents autonomes
