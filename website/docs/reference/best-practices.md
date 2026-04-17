---
sidebar_position: 12
title: "Bonnes Pratiques Claude Code (Boris Cherny)"
description: " \"Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result.\" -- Boris Cherny"
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Bonnes Pratiques Claude Code (Boris Cherny)

## Verification : Le Multiplicateur de Qualite

&gt; "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Donnez toujours a Claude un moyen de valider son travail:

| Complexite | Methode | Exemple |
|------------|---------|---------|
| Simple | Commande bash | `npm run lint`, `npm run typecheck` |
| Moderee | Suite de tests | `npm test`, `pytest`, `go test` |
| Complexe | Browser/Simulateur | Playwright, Chrome DevTools, emulateur mobile |

Integration: hooks PostToolUse (auto-format, type-check, lint), PreToolUse sur commit (tests obligatoires), agents QA (`/qa:qa-audit`).

## Modele Recommande

&gt; "I use Opus with adaptive thinking for everything." -- Boris Cherny

| Contexte | Modele | Justification |
|----------|--------|---------------|
| Taches complexes | **Opus 4.7** | Raisonnement le plus avance, adaptive thinking, 1M contexte, effort `xhigh` |
| Audits et analyses | **Sonnet** | Bon equilibre vitesse/qualite |
| Taches simples | **Haiku** | Rapide pour les operations triviales |

## Prompting Avance

| A eviter | Preferer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Techniques: "Grill me on these changes", "Prove to me this works", "Knowing everything you know now, implement the elegant solution".

Voir `docs/guides/PROMPTING-GUIDE.md` pour le guide complet.

## Effort Levels

&gt; Adapter le niveau de raisonnement a la tache.

| Tache | Effort | Pourquoi |
|-------|--------|----------|
| Explorer du code, lire des fichiers | `low` | Pas besoin de raisonnement profond |
| Implementer une feature standard | `medium` | Equilibre vitesse/qualite |
| Concevoir une architecture, audit, debug complexe | `high` | Raisonnement approfondi necessaire |
| Architecture systeme critique, audit securite avance | `xhigh` | Raisonnement maximum (Opus 4.7 requis) |

Commande: `/effort low`, `/effort medium`, `/effort high`, `/effort xhigh` (slider interactif).

## Memoire Automatique (CLI 2.1.76+)

Claude Code memorise automatiquement preferences, decisions et contexte projet dans `~/.claude/memory/`.

| Memoriser (auto) | CLAUDE.md (git) | Rules (auto-activees) |
|-------------------|-----------------|----------------------|
| Preferences personnelles | Conventions projet | Regles par langage |
| Decisions d'architecture | Workflow obligatoire | Patterns de code |
| Contexte equipe | References documentation | Checklist verification |

Ne pas dupliquer : si c'est dans CLAUDE.md, pas besoin de le memoriser. Utiliser "remember that..." pour forcer une memorisation explicite.

## Sessions Paralleles

&gt; "The single biggest productivity unlock." -- Boris Cherny

Utiliser git worktrees pour 5+ sessions Claude Code en parallele. Voir le skill `git-worktrees` pour les details.

## Gestion du Contexte

| Situation | Action | Quand |
|-----------|--------|-------|
| Session longue, contexte intact | `/compact` | Entre phases (Explore → Plan → TDD) |
| Changement de sujet total | `/clear` | Nouvelle tache sans rapport |
| Session normale | Laisser faire | Auto-compaction si necessaire |

## Recuperation Rapide

Si un refactoring casse tout : `/rewind` (ou `/undo`, alias equivalent) revient au dernier etat stable. Plus rapide que `git stash` ou `git checkout`. Checkpoints sauvegardes automatiquement avant chaque modification.

## Reprise de Session

`/recap` genere un resume de la session en cours — decisions prises, fichiers modifies, etat du travail. Utile pour reprendre une session apres une pause ou un `/compact`.

| Situation | Action |
|-----------|--------|
| Retour apres une pause | `/recap` pour retrouver le contexte |
| Apres `/compact` | `/recap` pour verifier ce qui a ete conserve |
| Onboarding sur session existante | `claude --resume &lt;id&gt;` puis `/recap` |

Configurable via `/config` (activer/desactiver le recap automatique au resume).

## Optimisation Tokens

### Prompt Caching 1h (CLI 2.1.108+)

Variable `ENABLE_PROMPT_CACHING_1H` pour un cache de prompt d'1 heure au lieu de 5 minutes. Reduit significativement les couts pour les sessions longues.

Activer dans `.claude/settings.local.json` :

```json
{
  "env": {
    "ENABLE_PROMPT_CACHING_1H": "1"
  }
}
```

Compatible avec API key, Bedrock, Vertex et Foundry. Alternative : `FORCE_PROMPT_CACHING_5M` pour forcer le TTL 5 minutes (utile si telemetrie desactivee).

### RTK (optionnel)

&gt; Reduire la consommation de tokens de 60-90% avec [RTK](https://github.com/rtk-ai/rtk).

Installation: `brew install rtk`. Le socle inclut un hook PreToolUse qui reecrit automatiquement les commandes. Desactive par defaut, activer avec `ENABLE_RTK=1` dans la section `env` de `.claude/settings.json` ou `.claude/settings.local.json`.

`rtk gain` pour voir les economies. `rtk discover` pour trouver les commandes non optimisees.

## Commande Rapide

`/work:work-commit-push-pr "description"` -- commit + push + PR en une seule commande.
