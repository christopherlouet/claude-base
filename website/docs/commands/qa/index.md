---
sidebar_position: 1
title: "QA"
description: "Commandes QA - Qualite (review, securite, performance, accessibilite)"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Commandes QA

> Qualite (review, securite, performance, accessibilite)

## Vue d'ensemble

Ce domaine contient **16 commandes** pour qualite (review, securite, performance, accessibilite).

## Liste des commandes

| Commande | Description |
|----------|-------------|
| [`/qa:qa-audit`](/docs/commands/qa/qa-audit) | Audit qualite complet d'un projet. Combine securite, RGPD, accessibilite, performance et qualite de code. |
| [`/qa:qa-automation`](/docs/commands/qa/qa-automation) | Mettre en place une strategie d'automatisation des tests complete. |
| [`/qa:qa-chrome`](/docs/commands/qa/qa-chrome) | Tests visuels et debugging navigateur via l'integration Chrome de Claude Code. |
| [`/qa:qa-coverage`](/docs/commands/qa/qa-coverage) | Analyse et ameliore la couverture de tests du code. |
| [`/qa:qa-design`](/docs/commands/qa/qa-design) | Audit de design UI/UX et verification des bonnes pratiques web. |
| [`/qa:qa-e2e`](/docs/commands/qa/qa-e2e) | Tests End-to-End avec Playwright ou Cypress. |
| [`/qa:qa-kaizen`](/docs/commands/qa/qa-kaizen) | Amelioration continue du code et des processus avec la methodologie Kaizen. |
| [`/qa:qa-loop`](/docs/commands/qa/qa-loop) | Boucle autonome audit → fix → test → re-audit avec criteres d'arret. |
| [`/qa:qa-mobile`](/docs/commands/qa/qa-mobile) | Audit de qualite specifique aux applications mobiles (Flutter, React Native). |
| [`/qa:qa-neovim`](/docs/commands/qa/qa-neovim) | Audit qualite et performance d'une configuration Neovim. |
| [`/qa:qa-perf`](/docs/commands/qa/qa-perf) | Analyse et optimisation des performances. |
| [`/qa:qa-responsive`](/docs/commands/qa/qa-responsive) | Audit responsive et mobile-first d'une application web. |
| [`/qa:qa-review`](/docs/commands/qa/qa-review) | Effectue une code review approfondie et constructive. |
| [`/qa:qa-security`](/docs/commands/qa/qa-security) | Audit de sécurité basé sur OWASP Top 10. |
| [`/qa:qa-tech-debt`](/docs/commands/qa/qa-tech-debt) | Identification et priorisation de la dette technique dans le codebase. |
| [`/qa:wcag-audit`](/docs/commands/qa/wcag-audit) | Audit d'accessibilite base sur WCAG 2.1/2.2 et referentiel axe-core. |

## Commandes en detail

<CommandGrid>
  <CommandCard
    name="qa-audit"
    description="Audit qualite complet d'un projet. Combine securite, RGPD, accessibilite, performance et qualite de code."
    domain="qa"
    href="/docs/commands/qa/qa-audit"
  />
  <CommandCard
    name="qa-automation"
    description="Mettre en place une strategie d'automatisation des tests complete."
    domain="qa"
    href="/docs/commands/qa/qa-automation"
  />
  <CommandCard
    name="qa-chrome"
    description="Tests visuels et debugging navigateur via l'integration Chrome de Claude Code."
    domain="qa"
    href="/docs/commands/qa/qa-chrome"
  />
  <CommandCard
    name="qa-coverage"
    description="Analyse et ameliore la couverture de tests du code."
    domain="qa"
    href="/docs/commands/qa/qa-coverage"
  />
  <CommandCard
    name="qa-design"
    description="Audit de design UI/UX et verification des bonnes pratiques web."
    domain="qa"
    href="/docs/commands/qa/qa-design"
  />
  <CommandCard
    name="qa-e2e"
    description="Tests End-to-End avec Playwright ou Cypress."
    domain="qa"
    href="/docs/commands/qa/qa-e2e"
  />
  <CommandCard
    name="qa-kaizen"
    description="Amelioration continue du code et des processus avec la methodologie Kaizen."
    domain="qa"
    href="/docs/commands/qa/qa-kaizen"
  />
  <CommandCard
    name="qa-loop"
    description="Boucle autonome audit → fix → test → re-audit avec criteres d'arret."
    domain="qa"
    href="/docs/commands/qa/qa-loop"
  />
  <CommandCard
    name="qa-mobile"
    description="Audit de qualite specifique aux applications mobiles (Flutter, React Native)."
    domain="qa"
    href="/docs/commands/qa/qa-mobile"
  />
  <CommandCard
    name="qa-neovim"
    description="Audit qualite et performance d'une configuration Neovim."
    domain="qa"
    href="/docs/commands/qa/qa-neovim"
  />
  <CommandCard
    name="qa-perf"
    description="Analyse et optimisation des performances."
    domain="qa"
    href="/docs/commands/qa/qa-perf"
  />
  <CommandCard
    name="qa-responsive"
    description="Audit responsive et mobile-first d'une application web."
    domain="qa"
    href="/docs/commands/qa/qa-responsive"
  />
  <CommandCard
    name="qa-review"
    description="Effectue une code review approfondie et constructive."
    domain="qa"
    href="/docs/commands/qa/qa-review"
  />
  <CommandCard
    name="qa-security"
    description="Audit de sécurité basé sur OWASP Top 10."
    domain="qa"
    href="/docs/commands/qa/qa-security"
  />
  <CommandCard
    name="qa-tech-debt"
    description="Identification et priorisation de la dette technique dans le codebase."
    domain="qa"
    href="/docs/commands/qa/qa-tech-debt"
  />
  <CommandCard
    name="wcag-audit"
    description="Audit d'accessibilite base sur WCAG 2.1/2.2 et referentiel axe-core."
    domain="qa"
    href="/docs/commands/qa/wcag-audit"
  />
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
