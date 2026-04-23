---
sidebar_position: 1
title: "Autres"
description: "Commandes Autres - Commandes diverses et orchestrateurs"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Commandes Autres

> Commandes diverses et orchestrateurs

## Vue d'ensemble

Ce domaine contient **4 commandes** pour commandes diverses et orchestrateurs.

## Liste des commandes

| Commande | Description |
|----------|-------------|
| [`/assistant`](/docs/commands/other/assistant) | Point d'entree unique du socle Claude Code. Guide vers les bonnes commandes, agents, skills et workflows. |
| [`/assistant-auto`](/docs/commands/other/assistant-auto) | Orchestrateur en mode automatique. Choisis le workflow adapte semantiquement a partir de la demande + du contexte repo injecte, puis execute immediatement via Skill. |
| [`/git-rename`](/docs/commands/other/git-rename) | Renomme la branche courante (typiquement une branche `feature/auto-*` creee par le hook PreToolUse). |
| [`/lessons`](/docs/commands/other/lessons) | Liste les `feedback` memories capturees pour le projet courant (et globalement) — les "lecons" apprises a partir des corrections utilisateur. |

## Commandes en detail

<CommandGrid>
  <CommandCard
    name="assistant"
    description="Point d'entree unique du socle Claude Code. Guide vers les bonnes commandes, agents, skills et workflows."
    domain="other"
    href="/docs/commands/other/assistant"
  />
  <CommandCard
    name="assistant-auto"
    description="Orchestrateur en mode automatique. Choisis le workflow adapte semantiquement a partir de la demande + du contexte repo injecte, puis execute immediatement via Skill."
    domain="other"
    href="/docs/commands/other/assistant-auto"
  />
  <CommandCard
    name="git-rename"
    description="Renomme la branche courante (typiquement une branche `feature/auto-*` creee par le hook PreToolUse)."
    domain="other"
    href="/docs/commands/other/git-rename"
  />
  <CommandCard
    name="lessons"
    description="Liste les `feedback` memories capturees pour le projet courant (et globalement) — les &quot;lecons&quot; apprises a partir des corrections utilisateur."
    domain="other"
    href="/docs/commands/other/lessons"
  />
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
