---
sidebar_position: 1
title: "WORK"
description: "Commandes WORK - Workflow principal (explore, plan, commit, PR)"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Commandes WORK

> Workflow principal (explore, plan, commit, PR)

## Vue d'ensemble

Ce domaine contient **14 commandes** pour workflow principal (explore, plan, commit, pr).

## Liste des commandes

| Commande | Description |
|----------|-------------|
| [`/work:work-batch`](/docs/commands/work/work-batch) | Execution autonome et sequentielle de user stories depuis un fichier PRD (JSON ou Markdown). |
| [`/work:work-clarify`](/docs/commands/work/work-clarify) | Pose des questions ciblees pour reduire l'ambiguite dans une specification. |
| [`/work:work-commit`](/docs/commands/work/work-commit) | Prepare et effectue un commit propre suivant les conventions. |
| [`/work:work-commit-push-pr`](/docs/commands/work/work-commit-push-pr) | Workflow complet: commit + push + PR en une seule commande. |
| [`/work:work-explore`](/docs/commands/work/work-explore) | Analyse le codebase sans ecrire de code. Mode EXPLORATION uniquement. |
| [`/work:work-flow-bugfix`](/docs/commands/work/work-flow-bugfix) | Workflow complet pour corriger un bug, du diagnostic au deploiement. |
| [`/work:work-flow-feature`](/docs/commands/work/work-flow-feature) | Workflow complet pour developper une nouvelle fonctionnalite, de l'exploration au merge. |
| [`/work:work-flow-launch`](/docs/commands/work/work-flow-launch) | Workflow technique pour developper et lancer un produit, du setup au go-live. |
| [`/work:work-flow-release`](/docs/commands/work/work-flow-release) | Workflow complet pour preparer et publier une release. |
| [`/work:work-plan`](/docs/commands/work/work-plan) | Concois un plan d'implementation detaille. Mode PLANIFICATION uniquement. |
| [`/work:work-pr`](/docs/commands/work/work-pr) | Cree une Pull Request complete et bien documentee. |
| [`/work:work-quick`](/docs/commands/work/work-quick) | Workflow rapide pour changements triviaux (1-3 fichiers, < 50 lignes, zero risque). |
| [`/work:work-specify`](/docs/commands/work/work-specify) | Cree une specification fonctionnelle structuree. Mode SPECIFICATION uniquement. |
| [`/work:work-team`](/docs/commands/work/work-team) | Lance une equipe d'agents coordonnes (Agent Teams) pour paralleliser le travail. |

## Commandes en detail

<CommandGrid>
  <CommandCard
    name="work-batch"
    description="Execution autonome et sequentielle de user stories depuis un fichier PRD (JSON ou Markdown)."
    domain="work"
    href="/docs/commands/work/work-batch"
  />
  <CommandCard
    name="work-clarify"
    description="Pose des questions ciblees pour reduire l'ambiguite dans une specification."
    domain="work"
    href="/docs/commands/work/work-clarify"
  />
  <CommandCard
    name="work-commit"
    description="Prepare et effectue un commit propre suivant les conventions."
    domain="work"
    href="/docs/commands/work/work-commit"
  />
  <CommandCard
    name="work-commit-push-pr"
    description="Workflow complet: commit + push + PR en une seule commande."
    domain="work"
    href="/docs/commands/work/work-commit-push-pr"
  />
  <CommandCard
    name="work-explore"
    description="Analyse le codebase sans ecrire de code. Mode EXPLORATION uniquement."
    domain="work"
    href="/docs/commands/work/work-explore"
  />
  <CommandCard
    name="work-flow-bugfix"
    description="Workflow complet pour corriger un bug, du diagnostic au deploiement."
    domain="work"
    href="/docs/commands/work/work-flow-bugfix"
  />
  <CommandCard
    name="work-flow-feature"
    description="Workflow complet pour developper une nouvelle fonctionnalite, de l'exploration au merge."
    domain="work"
    href="/docs/commands/work/work-flow-feature"
  />
  <CommandCard
    name="work-flow-launch"
    description="Workflow technique pour developper et lancer un produit, du setup au go-live."
    domain="work"
    href="/docs/commands/work/work-flow-launch"
  />
  <CommandCard
    name="work-flow-release"
    description="Workflow complet pour preparer et publier une release."
    domain="work"
    href="/docs/commands/work/work-flow-release"
  />
  <CommandCard
    name="work-plan"
    description="Concois un plan d'implementation detaille. Mode PLANIFICATION uniquement."
    domain="work"
    href="/docs/commands/work/work-plan"
  />
  <CommandCard
    name="work-pr"
    description="Cree une Pull Request complete et bien documentee."
    domain="work"
    href="/docs/commands/work/work-pr"
  />
  <CommandCard
    name="work-quick"
    description="Workflow rapide pour changements triviaux (1-3 fichiers, < 50 lignes, zero risque)."
    domain="work"
    href="/docs/commands/work/work-quick"
  />
  <CommandCard
    name="work-specify"
    description="Cree une specification fonctionnelle structuree. Mode SPECIFICATION uniquement."
    domain="work"
    href="/docs/commands/work/work-specify"
  />
  <CommandCard
    name="work-team"
    description="Lance une equipe d'agents coordonnes (Agent Teams) pour paralleliser le travail."
    domain="work"
    href="/docs/commands/work/work-team"
  />
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
