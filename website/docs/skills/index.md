---
sidebar_position: 1
title: "Skills"
description: "Catalogue des 42 skills auto-declenches"
---

import Stats from '@site/src/components/Stats';
import { SkillGrid } from '@site/src/components/SkillCard';
import SkillCard from '@site/src/components/SkillCard';

# Catalogue des Skills

> **42 skills** auto-declenches par mots-cles

<Stats items={[
  { number: 42, label: 'Skills Fork' },
  { number: 0, label: 'Skills Shared' },
  { number: 42, label: 'Total' },
]} />

## Qu'est-ce qu'un Skill ?

Les **skills** sont des comportements auto-declenches :

- **Declenchement automatique** : Active par mots-cles dans la conversation
- **Contexte configurable** : Fork (isole) ou Shared (partage)
- **Outils restreints** : Acces limite via `allowed-tools`
- **Transparence** : L'utilisateur voit quand un skill est active

## Skills par contexte

### Fork (42 skills)

Skills avec contexte isole.

| Skill | Description | Mots-cles |
|-------|-------------|-----------|
| [`agent-teams`](/docs/skills/agent-teams) | Orchestration d'equipes d'agents avec Agent Teams ... | agent, teams, env |
| [`api-mocking`](/docs/skills/api-mocking) | Configuration de mocks API pour les tests. Declenc... | api, mocking, mock api |
| [`data-pipeline`](/docs/skills/data-pipeline) | Conception de pipelines ETL/ELT. Declencher quand ... | data, pipeline, duplicate ids |
| [`dev-api`](/docs/skills/dev-api) | Développer et documenter une API REST ou GraphQL. ... | dev, api, success |
| [`dev-debug`](/docs/skills/dev-debug) | Deboguer et resoudre des problemes. Utiliser quand... | dev, debug |
| [`dev-document`](/docs/skills/dev-document) | Generation de documents (PDF, DOCX, XLSX, PPTX). D... | dev, document |
| [`dev-error-handling`](/docs/skills/dev-error-handling) | Strategie de gestion des erreurs. Declencher quand... | dev, error, handling |
| [`dev-flutter`](/docs/skills/dev-flutter) | Developpement Flutter avec Clean Architecture et B... | dev, flutter |
| [`dev-graphql`](/docs/skills/dev-graphql) | Developpement d'APIs GraphQL. Declencher quand l'u... | dev, graphql |
| [`dev-prompt-engineering`](/docs/skills/dev-prompt-engineering) | Optimisation de prompts pour LLMs. Declencher quan... | dev, prompt, engineering |
| [`dev-react-perf`](/docs/skills/dev-react-perf) | Optimisation des performances React/Next.js. Decle... | dev, react, perf |
| [`dev-refactor`](/docs/skills/dev-refactor) | Refactoring de code pour ameliorer la qualite. Dec... | dev, refactor |
| [`dev-supabase`](/docs/skills/dev-supabase) | Developpement backend avec Supabase. Declencher qu... | dev, supabase, users read own profile |
| [`dev-tdd`](/docs/skills/dev-tdd) | Développement TDD avec cycle Red-Green-Refactor. U... | dev, tdd, nom du test |
| [`doc-changelog`](/docs/skills/doc-changelog) | Maintenance du CHANGELOG selon Keep a Changelog. D... | doc, changelog |
| [`doc-generate`](/docs/skills/doc-generate) | Generation de documentation technique. Declencher ... | doc, generate, uuid |
| [`feature-flags`](/docs/skills/feature-flags) | Gestion de feature flags et toggles. Declencher qu... | feature, flags, feature flag |
| [`git-worktrees`](/docs/skills/git-worktrees) | Utilisation de git worktrees pour le developpement... | git, worktrees, cd ~/projects/myapp |
| [`growth-cro`](/docs/skills/growth-cro) | Optimisation du taux de conversion (CRO). Declench... | growth, cro, comment |
| [`ops-ci`](/docs/skills/ops-ci) | Configuration de pipelines CI/CD. Declencher quand... | ops |
| [`ops-database`](/docs/skills/ops-database) | Conception de schemas de base de donnees. Declench... | ops, database |
| [`ops-docker`](/docs/skills/ops-docker) | Containerisation Docker et Docker Compose. Declenc... | ops, docker, node |
| [`ops-infra-code`](/docs/skills/ops-infra-code) | Infrastructure as Code avec Terraform/OpenTofu. De... | ops, infra, code |
| [`ops-mobile-release`](/docs/skills/ops-mobile-release) | Publication d'apps sur App Store et Google Play. D... | ops, mobile, release |
| [`ops-monitoring`](/docs/skills/ops-monitoring) | Instrumentation d'applications pour monitoring. De... | ops, monitoring |
| [`ops-opnsense`](/docs/skills/ops-opnsense) | Configuration OPNsense via Terraform. Declencher p... | ops, opnsense, browningluke/opnsense |
| [`ops-proxmox`](/docs/skills/ops-proxmox) | Infrastructure Proxmox VE avec Terraform (VMs, LXC... | ops, proxmox, pve |
| [`parallel-agents`](/docs/skills/parallel-agents) | Orchestration d'agents paralleles pour maximiser l... | parallel, agents, qa-security |
| [`qa-chrome`](/docs/skills/qa-chrome) | Tests visuels et debugging navigateur via Chrome. ... | chrome, claude in chrome |
| [`qa-design`](/docs/skills/qa-design) | Audit de design UI/UX et verification des bonnes p... | design, '][^, `, ` |
| [`qa-e2e`](/docs/skills/qa-e2e) | Tests End-to-End avec Playwright ou Cypress. Decle... | e2e, end-to-end, test de bout en bout |
| [`qa-perf`](/docs/skills/qa-perf) | Optimisation des performances d'applications. Decl... | perf, /photo.jpg |
| [`qa-review`](/docs/skills/qa-review) | Effectuer une revue de code approfondie. Utiliser ... | review |
| [`qa-security`](/docs/skills/qa-security) | Effectuer un audit de sécurité basé sur OWASP. Uti... | security, **/*, password\s*= |
| [`qa-tech-debt`](/docs/skills/qa-tech-debt) | Gestion et priorisation de la dette technique. Dec... | tech, debt, dette technique |
| [`session-handoff`](/docs/skills/session-handoff) | Transfert de contexte entre sessions IA. Declenche... | session, handoff |
| [`state-management`](/docs/skills/state-management) | Patterns et implementation de state management. De... | state, management, state management |
| [`work-commit`](/docs/skills/work-commit) | Génère des messages de commit clairs suivant Conve... | work, commit, quoi |
| [`work-explore`](/docs/skills/work-explore) | Explorer et comprendre un codebase existant. Utili... | work, explore |
| [`work-plan`](/docs/skills/work-plan) | Planifier l'implémentation d'une fonctionnalité. U... | work, plan, pattern_similaire |
| [`work-pr`](/docs/skills/work-pr) | Créer une Pull Request complète et bien documentée... | work, type(scope): description, $(cat pr_body.md) |
| [`writing-skills`](/docs/skills/writing-skills) | Guide pour creer de nouveaux skills pour le socle ... | writing, skills, output attendu |



## Vue en cartes

<SkillGrid>
  <SkillCard
    name="agent-teams"
    description="Orchestration d'equipes d'agents avec Agent Teams natif. Declencher quand l'util"
    keywords={["agent","teams","env","teammatemode"]}
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
    keywords={["data","pipeline","duplicate ids","negative amounts"]}
    context="fork"
    href="/docs/skills/data-pipeline"
  />
  <SkillCard
    name="dev-api"
    description="Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur v"
    keywords={["dev","api","success","data"]}
    context="fork"
    href="/docs/skills/dev-api"
  />
  <SkillCard
    name="dev-debug"
    description="Deboguer et resoudre des problemes. Utiliser quand l'utilisateur a un bug, une e"
    keywords={["dev","debug"]}
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
    name="dev-graphql"
    description="Developpement d'APIs GraphQL. Declencher quand l'utilisateur veut creer des sche"
    keywords={["dev","graphql"]}
    context="fork"
    href="/docs/skills/dev-graphql"
  />
  <SkillCard
    name="dev-prompt-engineering"
    description="Optimisation de prompts pour LLMs. Declencher quand l'utilisateur veut ameliorer"
    keywords={["dev","prompt","engineering","instruction"]}
    context="fork"
    href="/docs/skills/dev-prompt-engineering"
  />
  <SkillCard
    name="dev-react-perf"
    description="Optimisation des performances React/Next.js. Declencher quand l'utilisateur veut"
    keywords={["dev","react","perf","/photo.jpg"]}
    context="fork"
    href="/docs/skills/dev-react-perf"
  />
  <SkillCard
    name="dev-refactor"
    description="Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur ve"
    keywords={["dev","refactor"]}
    context="fork"
    href="/docs/skills/dev-refactor"
  />
</SkillGrid>

[Voir tous les skills...](#skills-par-contexte)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Agents](/docs/agents) - Les sub-agents autonomes
