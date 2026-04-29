---
sidebar_position: 0
title: "Qu'est-ce que Claude Code ?"
description: "Comprendre Claude Code et le socle en 2 minutes"
---

# Qu'est-ce que Claude Code ?

> Comprendre l'outil et le socle en 2 minutes, avant de commencer

## Claude Code en bref

Claude Code est un **outil IA agentique** d'Anthropic qui vit dans votre terminal. Contrairement a un chatbot classique, il peut :

| Chatbot classique | Claude Code |
|-------------------|-------------|
| Repond a des questions | **Execute** des taches dans votre code |
| Copier-coller de snippets | **Lit, modifie et cree** des fichiers directement |
| Pas de contexte projet | **Comprend** votre codebase entier |
| Interaction manuelle | **Orchestre** des sous-agents autonomes |

Claude Code lit votre code, execute des commandes, lance des tests, cree des commits et des PRs — le tout pilote par langage naturel.

## Pourquoi un socle ?

Claude Code est puissant mais non structure. Sans cadre, on :
- Code sans comprendre l'existant (bugs)
- Implemente sans plan (refactoring constant)
- Oublie les tests (regressions)
- Fait des commits geants (historique illisible)

**claude-socle** impose un workflow structure avec des commandes, agents, skills et rules pre-configures :

```
Explore → Specify → Plan → TDD → Audit → Commit
```

## Les 4 composants du socle

| Composant | Declenchement | Exemple | Nombre |
|-----------|--------------|---------|--------|
| **Commands** | Manuel (`/nom`) | `/work:work-explore` | 126 |
| **Agents** | Via commandes | Sub-agents autonomes isolees | 62 |
| **Skills** | Automatique (mots-cles) | Se declenche quand on parle de "bug" | 44 |
| **Rules** | Automatique (fichiers) | S'active quand on modifie un `.tsx` | 25 |

### Comment ca s'articule

```
Vous tapez une commande
        ↓
   La commande lance un Agent
        ↓
   L'agent utilise des Skills (auto-detectees)
        ↓
   Les Rules s'appliquent selon les fichiers modifies
```

## Par ou commencer ?

| Votre profil | Chemin recommande |
|-------------|-------------------|
| **Jamais utilise Claude Code** | [Formation Claude Code](/docs/guides/claude-code-training) (3h45, 9 modules) |
| **Connait Claude Code, decouvre le socle** | [Parcours socle](/docs/guides/learning-path) (9h30, 5 niveaux) |
| **Presse** (5 min) | [Quick Start](/docs/intro/quick-start) |
| **Developpeur (web, mobile, API, backend, infra…)** | [Stack Recipes](/docs/concepts/stack-recipes) — commandes/agents/skills par stack |
| **Tech lead / equipe** | [Guide Equipe](/docs/guides/team-guide) |
| **Etendre le socle** | [Extending Guide](/docs/guides/extending-guide) |

## Prochaine etape

import Link from '@docusaurus/Link';

<div className="quick-actions">
  <Link className="button button--primary button--lg" to="/docs/guides/claude-code-training">
    Formation Claude Code (prerequis)
  </Link>
  <Link className="button button--secondary button--lg" to="/docs/guides/learning-path">
    Parcours socle (apres la formation)
  </Link>
</div>
