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

Ce domaine contient **2 commandes** pour commandes diverses et orchestrateurs.

## Liste des commandes

| Commande | Description |
|----------|-------------|
| [`/assistant`](/docs/commands/other/assistant) | Point d'entrée unique du socle Claude Code. Guide vers les bonnes commandes, agents, skills et workflows. |
| [`/assistant-auto`](/docs/commands/other/assistant-auto) | Orchestrateur en mode automatique. Analyse et exécute immédiatement le workflow approprié. |

## Commandes en detail

<CommandGrid>
  <CommandCard
    name="assistant"
    description="Point d'entrée unique du socle Claude Code. Guide vers les bonnes commandes, agents, skills et workflows."
    domain="other"
    href="/docs/commands/other/assistant"
  />
  <CommandCard
    name="assistant-auto"
    description="Orchestrateur en mode automatique. Analyse et exécute immédiatement le workflow approprié."
    domain="other"
    href="/docs/commands/other/assistant-auto"
  />
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
