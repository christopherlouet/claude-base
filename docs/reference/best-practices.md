# Bonnes Pratiques Claude Code (Boris Cherny)

## Verification : Le Multiplicateur de Qualite

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Donnez toujours a Claude un moyen de valider son travail:

| Complexite | Methode | Exemple |
|------------|---------|---------|
| Simple | Commande bash | `npm run lint`, `npm run typecheck` |
| Moderee | Suite de tests | `npm test`, `pytest`, `go test` |
| Complexe | Browser/Simulateur | Playwright, Chrome DevTools, emulateur mobile |

Integration: hooks PostToolUse (auto-format, type-check, lint), PreToolUse sur commit (tests obligatoires), agents QA (`/qa:qa-audit`).

## Modele Recommande

> "I use Opus 4.6 with adaptive thinking for everything." -- Boris Cherny

| Contexte | Modele | Justification |
|----------|--------|---------------|
| Taches complexes | **Opus 4.6** | Meilleur raisonnement, adaptive thinking, 1M contexte |
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

> Adapter le niveau de raisonnement a la tache.

| Tache | Effort | Pourquoi |
|-------|--------|----------|
| Explorer du code, lire des fichiers | `low` | Pas besoin de raisonnement profond |
| Implementer une feature standard | `medium` | Equilibre vitesse/qualite |
| Concevoir une architecture, refactoring | `high` | Raisonnement approfondi necessaire |
| Audit critique, debug complexe | `max` | Raisonnement maximum (Opus 4.6 uniquement) |

Commande: `/effort low`, `/effort medium`, `/effort high`, `/effort max`.

## Memoire Automatique (CLI 2.1.76+)

Claude Code memorise automatiquement preferences, decisions et contexte projet dans `~/.claude/memory/`.

| Memoriser (auto) | CLAUDE.md (git) | Rules (auto-activees) |
|-------------------|-----------------|----------------------|
| Preferences personnelles | Conventions projet | Regles par langage |
| Decisions d'architecture | Workflow obligatoire | Patterns de code |
| Contexte equipe | References documentation | Checklist verification |

Ne pas dupliquer : si c'est dans CLAUDE.md, pas besoin de le memoriser. Utiliser "remember that..." pour forcer une memorisation explicite.

## Sessions Paralleles

> "The single biggest productivity unlock." -- Boris Cherny

Utiliser git worktrees pour 5+ sessions Claude Code en parallele. Voir le skill `git-worktrees` pour les details.

## Gestion du Contexte

| Situation | Action | Quand |
|-----------|--------|-------|
| Session longue, contexte intact | `/compact` | Entre phases (Explore → Plan → TDD) |
| Changement de sujet total | `/clear` | Nouvelle tache sans rapport |
| Session normale | Laisser faire | Auto-compaction si necessaire |

## Recuperation Rapide

Si un refactoring casse tout : `/rewind` (revient au dernier etat stable). Plus rapide que `git stash` ou `git checkout`. Checkpoints sauvegardes automatiquement avant chaque modification.

## Optimisation Tokens (RTK)

> Reduire la consommation de tokens de 60-90% avec [RTK](https://github.com/rtk-ai/rtk).

Installation: `brew install rtk`. Le socle inclut un hook PreToolUse qui reecrit automatiquement les commandes. Desactive par defaut, activer avec `ENABLE_RTK=1` dans la section `env` de `.claude/settings.json` ou `.claude/settings.local.json`.

`rtk gain` pour voir les economies. `rtk discover` pour trouver les commandes non optimisees.

## Commande Rapide

`/work:work-commit-push-pr "description"` -- commit + push + PR en une seule commande.
