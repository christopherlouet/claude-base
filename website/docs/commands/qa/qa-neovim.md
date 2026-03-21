---
sidebar_position: 11
title: "/qa:qa-neovim"
description: "Audit qualite et performance d'une configuration Neovim."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-NEOVIM

Audit qualite et performance d'une configuration Neovim.

## Cible
`&lt;arguments&gt;`

## Objectif

Evaluer la performance, les plugins, les keymaps, la sante et la qualite du code Lua d'une configuration Neovim.

## Workflow

- Mesurer le temps de demarrage (objectif &lt; 50ms)
- Auditer les plugins : lazy loading, doublons, maintenance
- Verifier les keymaps : descriptions, conflits, conventions LSP
- Executer les health checks (:checkhealth)
- Linter le code Lua (luacheck, conventions vim.keymap.set, augroups)
- Verifier la securite (secrets, exrc, sources plugins)
- Evaluer la structure et organisation des fichiers

## Output attendu

### Score global /100
| Categorie | Score |
|-----------|-------|
| Performance | /20 |
| Plugins | /20 |
| Keymaps | /15 |
| Health | /15 |
| Code quality | /15 |
| Organisation | /15 |

### Recommandations prioritaires
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-neovim` | Implementer les corrections |
| `/dev:dev-refactor` | Restructurer la config |
| `/dev:dev-debug` | Investiguer un probleme specifique |

---

IMPORTANT: Mesurer le temps de demarrage AVANT et APRES chaque optimisation.

YOU MUST verifier les keymaps avec `desc` pour which-key.

NEVER desactiver les health checks - ils revelent les vrais problemes.

Think hard sur le ratio benefice/complexite des plugins.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
