---
sidebar_position: 1
title: Bienvenue
description: Template de configuration Claude Code pour un workflow optimal
slug: /
---

import Stats, { SOCLE_STATS } from '@site/src/components/Stats';

# Bienvenue sur claude-socle

> **Template de configuration Claude Code pour un workflow optimal : Explore → Plan → TDD → Commit**

claude-socle est un ensemble complet de configurations, commandes et automatisations pour maximiser votre productivite avec Claude Code. Il propose un workflow structure et des agents specialises pour chaque type de tache.

<Stats items={SOCLE_STATS} />

## Pourquoi claude-socle ?

### Le probleme

Quand on utilise Claude Code sans structure :
- On code sans comprendre l'existant → bugs et regressions
- On implemente sans plan → refactoring constant
- On fait des commits geants → historique illisible
- On perd du temps a chercher les bonnes commandes

### La solution

claude-socle impose un workflow structure :

```
Explore → Plan → TDD → Commit
```

Chaque etape a ses commandes dediees, ses agents specialises et ses bonnes pratiques.

## Chiffres cles

| Composant | Nombre | Description |
|-----------|--------|-------------|
| **Commands** | 120 | Commandes declenchees manuellement (`/nom`) |
| **Agents** | 57 | Sub-agents autonomes avec contexte isole |
| **Skills** | 41 | Auto-declenchement sur mots-cles |
| **Rules** | 21 | Regles par technologie/fichier |

## Domaines couverts

| Domaine | Commandes | Description |
|---------|-----------|-------------|
| **WORK** | 11 | Workflow principal (explore, plan, commit, PR) |
| **DEV** | 23 | Developpement (TDD, API, composants, debug) |
| **QA** | 14 | Qualite (review, securite, performance, a11y) |
| **OPS** | 30 | Operations (CI/CD, Docker, monitoring, GitFlow) |
| **DOC** | 9 | Documentation (changelog, README, architecture) |
| **BIZ** | 11 | Business (model, MVP, pricing, pitch) |
| **GROWTH** | 11 | Croissance (SEO, analytics, landing, funnel) |
| **DATA** | 3 | Donnees (pipeline, analytics, modeling) |
| **LEGAL** | 5 | Legal (RGPD, CGU, paiement) |

## Demarrage rapide

```bash
# Cloner le template
git clone https://github.com/christopherlouet/claude-socle.git .claude

# Ou utiliser le script d'installation
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash
```

Puis dans Claude Code :

```bash
# Decouvrir les commandes disponibles
/assistant

# Commencer par explorer le code
/work:work-explore

# Planifier une modification
/work:work-plan
```

## Prochaines etapes

import Link from '@docusaurus/Link';

<div className="quick-actions">
  <Link className="quick-action" to="/docs/intro/quick-start">
    Quick Start en 5 min
  </Link>
  <Link className="quick-action" to="/docs/intro/architecture">
    Comprendre l'architecture
  </Link>
  <Link className="quick-action" to="/docs/workflow">
    Voir les workflows
  </Link>
</div>
