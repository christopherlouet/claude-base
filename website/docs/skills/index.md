---
sidebar_position: 1
title: "Skills"
description: "Catalogue des 27 skills auto-declenches"
---

import Stats from '@site/src/components/Stats';
import { SkillGrid } from '@site/src/components/SkillCard';
import SkillCard from '@site/src/components/SkillCard';

# Catalogue des Skills

> **32 skills** auto-declenches par mots-cles

<Stats items={[
  { number: 32, label: 'Skills Fork' },
  { number: 0, label: 'Skills Shared' },
  { number: 32, label: 'Total' },
]} />

## Qu'est-ce qu'un Skill ?

Les **skills** sont des comportements auto-declenches :

- **Declenchement automatique** : Active par mots-cles dans la conversation
- **Contexte configurable** : Fork (isole) ou Shared (partage)
- **Outils restreints** : Acces limite via `allowed-tools`
- **Transparence** : L'utilisateur voit quand un skill est active

## Skills par contexte

### Fork (32 skills)

Skills avec contexte isole.

| Skill | Description | Mots-cles |
|-------|-------------|-----------|
| [`api-development`](/docs/skills/api-development) | Développer et documenter une API REST ou GraphQL. ... | api, development, success |
| [`api-mocking`](/docs/skills/api-mocking) | Configuration de mocks API pour les tests. Declenc... | api, mocking, mock api |
| [`changelog-maintenance`](/docs/skills/changelog-maintenance) | Maintenance du CHANGELOG selon Keep a Changelog. D... | changelog, maintenance |
| [`ci-cd-pipeline`](/docs/skills/ci-cd-pipeline) | Configuration de pipelines CI/CD. Declencher quand... | pipeline |
| [`creating-pull-requests`](/docs/skills/creating-pull-requests) | Créer une Pull Request complète et bien documentée... | creating, pull, requests |
| [`data-pipeline`](/docs/skills/data-pipeline) | Conception de pipelines ETL/ELT. Declencher quand ... | data, pipeline, duplicate ids |
| [`database-design`](/docs/skills/database-design) | Conception de schemas de base de donnees. Declench... | database, design |
| [`debugging-issues`](/docs/skills/debugging-issues) | Déboguer et résoudre des problèmes. Utiliser quand... | debugging, issues |
| [`docker-containerization`](/docs/skills/docker-containerization) | Containerisation Docker et Docker Compose. Declenc... | docker, containerization, node |
| [`documentation-generation`](/docs/skills/documentation-generation) | Generation de documentation technique. Declencher ... | documentation, generation, uuid |
| [`e2e-testing`](/docs/skills/e2e-testing) | Tests End-to-End avec Playwright ou Cypress. Decle... | e2e, testing, end-to-end |
| [`error-handling`](/docs/skills/error-handling) | Strategie de gestion des erreurs. Declencher quand... | error, handling |
| [`exploring-codebase`](/docs/skills/exploring-codebase) | Explorer et comprendre un codebase existant. Utili... | exploring, codebase |
| [`feature-flags`](/docs/skills/feature-flags) | Gestion de feature flags et toggles. Declencher qu... | feature, flags, feature flag |
| [`flutter-development`](/docs/skills/flutter-development) | Developpement Flutter avec Clean Architecture et B... | flutter, development |
| [`generating-commit-messages`](/docs/skills/generating-commit-messages) | Génère des messages de commit clairs suivant Conve... | generating, commit, messages |
| [`graphql-development`](/docs/skills/graphql-development) | Developpement d'APIs GraphQL. Declencher quand l'u... | graphql, development |
| [`infrastructure-as-code`](/docs/skills/infrastructure-as-code) | Infrastructure as Code avec Terraform/OpenTofu. De... | infrastructure, code, aws_instance |
| [`mobile-release`](/docs/skills/mobile-release) | Publication d'apps sur App Store et Google Play. D... | mobile, release, deploy to testflight |
| [`monitoring-instrumentation`](/docs/skills/monitoring-instrumentation) | Instrumentation d'applications pour monitoring. De... | monitoring, instrumentation |
| [`performance-optimization`](/docs/skills/performance-optimization) | Optimisation des performances d'applications. Decl... | performance, optimization, /photo.jpg |
| [`planning-implementation`](/docs/skills/planning-implementation) | Planifier l'implémentation d'une fonctionnalité. U... | planning, implementation, pattern_similaire |
| [`prompt-engineering`](/docs/skills/prompt-engineering) | Optimisation de prompts pour LLMs. Declencher quan... | prompt, engineering, instruction |
| [`proxmox-infrastructure`](/docs/skills/proxmox-infrastructure) | Infrastructure Proxmox VE avec Terraform (VMs, LXC... | proxmox, infrastructure, pve |
| [`react-performance`](/docs/skills/react-performance) | Optimisation des performances React/Next.js. Decle... | react, performance, /photo.jpg |
| [`refactoring`](/docs/skills/refactoring) | Refactoring de code pour ameliorer la qualite. Dec... | refactoring |
| [`reviewing-code`](/docs/skills/reviewing-code) | Effectuer une revue de code approfondie. Utiliser ... | reviewing, code |
| [`security-audit`](/docs/skills/security-audit) | Effectuer un audit de sécurité basé sur OWASP. Uti... | security, audit, **/* |
| [`state-management`](/docs/skills/state-management) | Patterns et implementation de state management. De... | state, management, state management |
| [`supabase-development`](/docs/skills/supabase-development) | Developpement backend avec Supabase. Declencher qu... | supabase, development, users read own profile |
| [`tech-debt-management`](/docs/skills/tech-debt-management) | Gestion et priorisation de la dette technique. Dec... | tech, debt, management |
| [`test-driven-development`](/docs/skills/test-driven-development) | Développement TDD avec cycle Red-Green-Refactor. U... | test, driven, development |



## Vue en cartes

<SkillGrid>
  <SkillCard
    name="api-development"
    description="Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur v"
    keywords={["api","development","success","data"]}
    context="fork"
    href="/docs/skills/api-development"
  />
  <SkillCard
    name="api-mocking"
    description="Configuration de mocks API pour les tests. Declencher quand l'utilisateur veut m"
    keywords={["api","mocking","mock api","msw"]}
    context="fork"
    href="/docs/skills/api-mocking"
  />
  <SkillCard
    name="changelog-maintenance"
    description="Maintenance du CHANGELOG selon Keep a Changelog. Declencher quand l'utilisateur "
    keywords={["changelog","maintenance"]}
    context="fork"
    href="/docs/skills/changelog-maintenance"
  />
  <SkillCard
    name="ci-cd-pipeline"
    description="Configuration de pipelines CI/CD. Declencher quand l'utilisateur veut configurer"
    keywords={["pipeline"]}
    context="fork"
    href="/docs/skills/ci-cd-pipeline"
  />
  <SkillCard
    name="creating-pull-requests"
    description="Créer une Pull Request complète et bien documentée. Utiliser quand l'utilisateur"
    keywords={["creating","pull","requests","type(scope): description"]}
    context="fork"
    href="/docs/skills/creating-pull-requests"
  />
  <SkillCard
    name="data-pipeline"
    description="Conception de pipelines ETL/ELT. Declencher quand l'utilisateur veut creer des f"
    keywords={["data","pipeline","duplicate ids","negative amounts"]}
    context="fork"
    href="/docs/skills/data-pipeline"
  />
  <SkillCard
    name="database-design"
    description="Conception de schemas de base de donnees. Declencher quand l'utilisateur veut cr"
    keywords={["database","design"]}
    context="fork"
    href="/docs/skills/database-design"
  />
  <SkillCard
    name="debugging-issues"
    description="Déboguer et résoudre des problèmes. Utiliser quand l'utilisateur a un bug, une e"
    keywords={["debugging","issues"]}
    context="fork"
    href="/docs/skills/debugging-issues"
  />
  <SkillCard
    name="docker-containerization"
    description="Containerisation Docker et Docker Compose. Declencher quand l'utilisateur veut d"
    keywords={["docker","containerization","node","dist/index.js"]}
    context="fork"
    href="/docs/skills/docker-containerization"
  />
  <SkillCard
    name="documentation-generation"
    description="Generation de documentation technique. Declencher quand l'utilisateur veut creer"
    keywords={["documentation","generation","uuid","email"]}
    context="fork"
    href="/docs/skills/documentation-generation"
  />
  <SkillCard
    name="e2e-testing"
    description="Tests End-to-End avec Playwright ou Cypress. Declencher quand l'utilisateur veut"
    keywords={["e2e","testing","end-to-end","test de bout en bout"]}
    context="fork"
    href="/docs/skills/e2e-testing"
  />
  <SkillCard
    name="error-handling"
    description="Strategie de gestion des erreurs. Declencher quand l'utilisateur veut implemente"
    keywords={["error","handling"]}
    context="fork"
    href="/docs/skills/error-handling"
  />
</SkillGrid>

[Voir tous les skills...](#skills-par-contexte)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Agents](/docs/agents) - Les sub-agents autonomes
